import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/schema/tables/messages_table.dart';
import '../../core/schema/app_database.dart';

part 'messages_dao.g.dart';

final messagesDaoProvider = Provider<MessagesDao>(
  (ref) => MessagesDao(ref.read(databaseProvider)),
);

@DriftAccessor(tables: [Messages])
class MessagesDao extends DatabaseAccessor<AppDatabase>
    with _$MessagesDaoMixin {
  MessagesDao(super.db);

  // ==================== MESSAGE OPERATIONS ====================

  /// Get all messages for a specific chat
  Future<List<Message>> getMessagesByChat(String chatId) {
    return (select(messages)
          ..where((m) => m.chatRemoteId.equals(chatId))
          ..orderBy([(m) => OrderingTerm.desc(m.createdAt)]))
        .get();
  }

  /// Get a specific message by remote ID
  Future<Message?> getMessageByRemoteId(String remoteId) {
    return (select(messages)
          ..where((m) => m.remoteId.isNotNull() & m.remoteId.equals(remoteId)))
        .getSingleOrNull();
  }

  /// Get a specific message by temp ID (for optimistic updates)
  Future<Message?> getMessageByTempId(String tempId) {
    return (select(
      messages,
    )..where((m) => m.id.equals(tempId))).getSingleOrNull();
  }

  /// Insert a new message (optimistic)
  Future<int> insertMessage(MessagesCompanion message) {
    return into(messages).insert(message);
  }

  /// Upsert (insert or update) a message
  Future<void> upsertMessage(Message message) {
    return into(messages).insert(message, mode: InsertMode.insertOrReplace);
  }

  /// Upsert message by remote ID (update existing message with server data)
  Future<void> upsertMessageByRemoteId(
    String tempId,
    String remoteId,
    DateTime createdAt,
  ) async {
    final existingMessage = await getMessageByTempId(tempId);
    if (existingMessage != null) {
      await (update(messages)..where((m) => m.id.equals(tempId))).write(
        MessagesCompanion(
          remoteId: Value(remoteId),
          createdAt: Value(createdAt),
          isSynced: const Value(true),
          messageStatus: Value(MessageStatus.arrived),
        ),
      );
    }
  }

  /// Update message sync status
  Future<void> updateMessageSyncStatus(String messageId, bool isSynced) {
    return (update(messages)..where((m) => m.id.equals(messageId))).write(
      MessagesCompanion(isSynced: Value(isSynced)),
    );
  }

  /// Update message status
  Future<void> updateMessageStatus(String messageId, MessageStatus status) {
    return (update(messages)..where((m) => m.id.equals(messageId))).write(
      MessagesCompanion(messageStatus: Value(status)),
    );
  }

  /// Delete a message by ID
  Future<int> deleteMessage(String messageId) {
    return (delete(messages)..where((m) => m.id.equals(messageId))).go();
  }

  /// Delete all messages for a specific chat
  Future<int> deleteMessagesByChat(String chatId) {
    return (delete(messages)..where((m) => m.chatRemoteId.equals(chatId))).go();
  }

  /// Get unsent messages (for retry logic)
  Future<List<Message>> getUnsentMessages() {
    return (select(messages)
          ..where((m) => m.isSynced.equals(false))
          ..orderBy([(m) => OrderingTerm.asc(m.createdAt)]))
        .get();
  }

  /// Get messages with sending or error status (for retry logic)
  Future<List<Message>> getMessagesNeedingRetry() {
    return (select(messages)
          ..where((m) => m.isSynced.equals(false))
          ..orderBy([(m) => OrderingTerm.asc(m.createdAt)]))
        .get();
  }

  /// Delete messages by their IDs
  Future<int> deleteMessages(List<String> messageIds) {
    return (delete(messages)..where((m) => m.id.isIn(messageIds))).go();
  }

  // ==================== WATCH OPERATIONS ====================

  /// Watch all messages for a specific chat (ordered by creation time DESC)
  Stream<List<Message>> watchMessagesByChat(String chatId) {
    return (select(messages)
          ..where((m) => m.chatRemoteId.equals(chatId))
          ..orderBy([(m) => OrderingTerm.desc(m.createdAt)]))
        .watch();
  }

  /// Watch the newest [limit] messages for a specific chat (ordered DESC)
  ///
  /// This is used by the chat screen pagination logic.
  Stream<List<Message>> watchMessagesByChatPaged(
    String chatId, {
    required int limit,
  }) {
    return (select(messages)
          ..where((m) => m.chatRemoteId.equals(chatId))
          ..orderBy([(m) => OrderingTerm.desc(m.createdAt)])
          ..limit(limit))
        .watch();
  }

  /// Watch the newest message for a specific chat
  /// Returns null if there are no messages.
  Stream<Message?> watchLastMessageByChat(String chatId) {
    return (select(messages)
          ..where((m) => m.chatRemoteId.equals(chatId))
          ..orderBy([(m) => OrderingTerm.desc(m.createdAt)])
          ..limit(1))
        .watchSingleOrNull();
  }

  /// Watch a specific message by ID
  Stream<Message?> watchMessageById(String messageId) {
    return (select(
      messages,
    )..where((m) => m.id.equals(messageId))).watchSingleOrNull();
  }

  // ==================== HELPER METHODS ====================

  /// Parse body JSON to Map
  Map<String, dynamic> parseBodyJson(String bodyJson) {
    return jsonDecode(bodyJson) as Map<String, dynamic>;
  }

  /// Convert body Map to JSON string
  String bodyToJson(Map<String, dynamic> body) {
    return jsonEncode(body);
  }
}
