import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/data/db/chats_dao.dart';
import 'package:mastercs_mobile/models/chat_types.dart';
import 'package:mastercs_mobile/providers/data/chats_list_provider.dart';
import 'package:mastercs_mobile/providers/auth/auth_provider.dart';
import 'package:mastercs_mobile/providers/data/camp_members_list_provider.dart';

/// Provider for watching the current user's group chat in the selected camp
final groupProvider = StreamProvider.autoDispose<Chat?>((ref) async* {
  // Get the current user's group chat ID from camp members
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

  final groupChat = chats
      .where(
        (chat) =>
            chat.type == ChatType.group.toString() &&
            chat.typeId == currentMember.first.groupId,
      )
      .firstOrNull;
  if (groupChat == null) {
    yield null;
    return;
  }

  // Watch the group chat
  final chatStream = ref
      .watch(chatDaoProvider)
      .watchChatById(groupChat.remoteId);

  await for (final chat in chatStream) {
    yield chat;
  }
});
