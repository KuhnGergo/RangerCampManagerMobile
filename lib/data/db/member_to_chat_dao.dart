import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/schema/tables/chats_table.dart';
import 'package:mastercs_mobile/core/schema/tables/member_to_camp_table.dart';
import 'package:mastercs_mobile/core/schema/tables/member_to_chat_table.dart';
import 'package:mastercs_mobile/core/schema/tables/users_table.dart';
import 'package:mastercs_mobile/data/db/chats_dao.dart';
import 'package:mastercs_mobile/models/member_to_chat.dart' as model;
import '../../core/schema/app_database.dart';

part 'member_to_chat_dao.g.dart';

final memberToChatDaoProvider = Provider<MemberToChatDao>(
  (ref) =>
      MemberToChatDao(ref.read(databaseProvider), ref.read(chatDaoProvider)),
);

@DriftAccessor(tables: [Chats, MemberToChat, MemberToCamp, Users])
class MemberToChatDao extends DatabaseAccessor<AppDatabase>
    with _$MemberToChatDaoMixin {
  final ChatDao _chatDao;

  MemberToChatDao(super.db, this._chatDao);

  /// Get all chats for a specific user
  Future<List<Chat>> getChatsByUser(String userRemoteId) async {
    final memberChats = await (select(
      memberToChat,
    )..where((m) => m.userRemoteId.equals(userRemoteId))).get();

    if (memberChats.isEmpty) return [];

    final chatIds = memberChats.map((m) => m.chatRemoteId).toList();
    return (select(chats)..where((chat) => chat.remoteId.isIn(chatIds))).get();
  }

  /// Add a user to a chat
  Future<void> addUserToChat(
    String userRemoteId,
    String chatRemoteId,
    String? lastViewed,
  ) async {
    await into(memberToChat).insert(
      MemberToChatData(
        userRemoteId: userRemoteId,
        chatRemoteId: chatRemoteId,
        lastViewed: lastViewed != null ? DateTime.parse(lastViewed) : null,
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  /// Add multiple users to a chat
  Future<void> upsertUsersToChats(
    List<String> chatRemoteIds,
    List<MemberToChatData> members,
  ) async {
    for (var chatId in chatRemoteIds) {
      await (delete(
        memberToChat,
      )..where((tbl) => tbl.chatRemoteId.equals(chatId))).go();
    }
    await batch((batch) {
      batch.insertAll(memberToChat, members, mode: InsertMode.insertOrReplace);
    });
  }

  /// Remove a user from a chat
  /// Used when a user leaves a chat.
  Future<int> removeUserFromChat(String userRemoteId, String chatRemoteId) {
    return (delete(memberToChat)..where(
          (m) =>
              m.userRemoteId.equals(userRemoteId) &
              m.chatRemoteId.equals(chatRemoteId),
        ))
        .go();
  }

  /// Clear all members associated with a specific chat
  Future<int> clearMembersByChatId(String chatRemoteId) {
    return (delete(
      memberToChat,
    )..where((m) => m.chatRemoteId.equals(chatRemoteId))).go();
  }

  /// Remove a user from all chats in a camp
  /// Used when a user leaves a camp
  Future<int> removeUserFromCampChats(
    String userRemoteId,
    String campId,
  ) async {
    final campChats = await _chatDao.getChatsByCamp(campId);

    final chatIds = campChats.map((c) => c.remoteId).toList();

    if (chatIds.isEmpty) return 0;

    return (delete(memberToChat)..where(
          (m) =>
              m.userRemoteId.equals(userRemoteId) &
              m.chatRemoteId.isIn(chatIds),
        ))
        .go();
  }

  /// Get count of members in a chat
  Future<int> getChatMemberCount(String chatRemoteId) async {
    final result = await (select(
      memberToChat,
    )..where((m) => m.chatRemoteId.equals(chatRemoteId))).get();
    return result.length;
  }

  /// Update last viewed timestamp for a user in a chat
  Future<int> updateMemberChatLastViewed(
    String userRemoteId,
    String chatRemoteId,
    DateTime lastViewed,
  ) {
    return (update(memberToChat)..where(
          (m) =>
              m.userRemoteId.equals(userRemoteId) &
              m.chatRemoteId.equals(chatRemoteId),
        ))
        .write(
          MemberToChatData(
            userRemoteId: userRemoteId,
            chatRemoteId: chatRemoteId,
            lastViewed: lastViewed,
          ),
        );
  }

  /// Upsert last viewed timestamp for a user in a chat.
  /// Ensures updates are not dropped when the mapping row does not exist yet.
  Future<void> upsertMemberChatLastViewed(
    String userRemoteId,
    String chatRemoteId,
    DateTime lastViewed,
  ) async {
    await into(memberToChat).insert(
      MemberToChatData(
        userRemoteId: userRemoteId,
        chatRemoteId: chatRemoteId,
        lastViewed: lastViewed,
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  /// Clear all chat data for a camp (including member mappings)
  Future<void> clearCampChatData(String campId) async {
    final campChats = await _chatDao.getChatsByCamp(campId);
    final chatIds = campChats.map((c) => c.remoteId).toList();

    await batch((batch) {
      // Delete member-to-chat mappings
      for (final chatId in chatIds) {
        batch.deleteWhere(memberToChat, (m) => m.chatRemoteId.equals(chatId));
      }
      // Delete chats
      batch.deleteWhere(chats, (c) => c.campRemoteId.equals(campId));
    });
  }

  /// Watch simplified member-to-chat data (userId, chatId, lastViewed only)
  Stream<List<model.MemberToChatData>> watchMemberToChatByChat(
    String chatRemoteId,
  ) {
    return (select(
      memberToChat,
    )..where((m) => m.chatRemoteId.equals(chatRemoteId))).watch().map((rows) {
      return rows.map((row) {
        return model.MemberToChatData(
          userId: row.userRemoteId,
          chatId: row.chatRemoteId,
          lastViewed: row.lastViewed,
        );
      }).toList();
    });
  }
}
