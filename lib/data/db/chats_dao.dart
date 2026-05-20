import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/schema/tables/chats_table.dart';
import '../../core/schema/app_database.dart';

part 'chats_dao.g.dart';

final chatDaoProvider = Provider<ChatDao>(
  (ref) => ChatDao(ref.read(databaseProvider)),
);

@DriftAccessor(tables: [Chats])
class ChatDao extends DatabaseAccessor<AppDatabase> with _$ChatDaoMixin {
  ChatDao(super.db);

  // ==================== CHAT OPERATIONS ====================

  /// Get all chats for a specific camp
  Future<List<Chat>> getChatsByCamp(String campId) {
    return (select(
      chats,
    )..where((chat) => chat.campRemoteId.equals(campId))).get();
  }

  /// Get a specific chat by ID
  Future<Chat?> getChatById(String chatId) {
    return (select(
      chats,
    )..where((chat) => chat.remoteId.equals(chatId))).getSingleOrNull();
  }

  /// Get a chat by chat type and typeId (e.g. Group + groupId).
  Future<Chat?> getChatByTypeAndTypeId(String type, String typeId) {
    return (select(
          chats,
        )..where((chat) => chat.type.equals(type) & chat.typeId.equals(typeId)))
        .getSingleOrNull();
  }

  /// Upsert (insert or update) a chat
  Future<void> upsertChatCompanion(ChatsCompanion chat) {
    return into(chats).insert(chat, mode: InsertMode.insertOrReplace);
  }

  /// Upsert (insert or update) a chat
  Future<void> upsertChat(Chat chat) {
    return into(chats).insert(chat, mode: InsertMode.insertOrReplace);
  }

  /// Upsert multiple chats
  Future<void> upsertAllChats(List<Chat> chatList) async {
    await deleteChatsByCamp(chatList.first.campRemoteId);
    await batch((batch) {
      batch.insertAll(chats, chatList, mode: InsertMode.insertOrReplace);
    });
  }

  /// Delete a chat by ID
  Future<int> deleteChat(String chatId) {
    return (delete(chats)..where((chat) => chat.remoteId.equals(chatId))).go();
  }

  /// Delete all chats for a specific camp
  Future<int> deleteChatsByCamp(String campId) {
    return (delete(
      chats,
    )..where((chat) => chat.campRemoteId.equals(campId))).go();
  }

  /// Update chat lastMessageAt timestamp
  Future<int> updateChatLastMessageAt(String chatId, DateTime lastMessageAt) {
    return (update(chats)..where((chat) => chat.remoteId.equals(chatId))).write(
      ChatsCompanion(lastMessageAt: Value(lastMessageAt)),
    );
  }

  /// Upsert chat lastSeenAt timestamp (current user read marker).
  Future<int> updateChatLastSeenAt(String chatId, DateTime lastSeenAt) {
    return transaction(() async {
      final existing = await getChatById(chatId);
      if (existing == null) {
        return 0;
      }

      await into(chats).insert(
        existing.copyWith(lastSeenAt: Value(lastSeenAt)),
        mode: InsertMode.insertOrReplace,
      );
      return 1;
    });
  }

  // ==================== WATCH OPERATIONS ====================

  /// Watch all chats for a specific camp
  Stream<List<Chat>> watchChatsByCamp(String campId) {
    return (select(chats)
          ..where((chat) => chat.campRemoteId.equals(campId))
          ..orderBy([(chat) => OrderingTerm.desc(chat.lastMessageAt)]))
        .watch();
  }

  /// Watch a specific chat by ID
  Stream<Chat?> watchChatById(String chatId) {
    return (select(
      chats,
    )..where((chat) => chat.remoteId.equals(chatId))).watchSingleOrNull();
  }

  /// Watch chats by type (Room, Group, General, etc.)
  Stream<List<Chat>> watchChatsByType(String campId, String type) {
    return (select(chats)
          ..where(
            (chat) => chat.campRemoteId.equals(campId) & chat.type.equals(type),
          )
          ..orderBy([(chat) => OrderingTerm.desc(chat.lastMessageAt)]))
        .watch();
  }
}
