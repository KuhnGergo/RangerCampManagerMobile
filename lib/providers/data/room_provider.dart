import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/data/db/chats_dao.dart';
import 'package:mastercs_mobile/models/chat_types.dart';
import 'package:mastercs_mobile/providers/data/chats_list_provider.dart';
import 'package:mastercs_mobile/providers/auth/auth_provider.dart';
import 'package:mastercs_mobile/providers/data/camp_members_list_provider.dart';

/// Provider for watching the current user's room chat in the selected camp
final roomProvider = StreamProvider.autoDispose<Chat?>((ref) async* {
  // Get the current user's room chat ID from camp members
  final members = await ref.watch(campMembersListProvider.future);
  final chats = await ref.watch(chatsListProvider.future);
  final userId = ref.watch(authProvider.notifier).getUserId;

  if (userId == null) {
    yield null;
    return;
  }

  final currentMember = members.where((m) => m.userRemoteId == userId);
  if (currentMember.isEmpty) {
    yield null;
    return;
  }

  final roomChat = chats
      .where(
        (chat) =>
            chat.type == ChatType.room.toString() &&
            chat.typeId == currentMember.first.roomId,
      )
      .firstOrNull;
  if (roomChat == null) {
    yield null;
    return;
  }

  // Watch the room chat
  final chatStream = ref
      .watch(chatDaoProvider)
      .watchChatById(roomChat.remoteId);

  await for (final chat in chatStream) {
    yield chat;
  }
});
