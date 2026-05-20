import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/models/chat_member.dart';
import 'package:mastercs_mobile/providers/data/camp_members_list_provider.dart';
import 'package:mastercs_mobile/providers/data/member_to_chat_provider.dart';

/// Combined provider that merges Member data with MemberToChat data
/// This is the main provider to use in UI for chat members
final chatMembersViewProvider = StreamProvider.family<List<ChatMember>, String>(
  (ref, chatId) {
    final controller = StreamController<List<ChatMember>>();

    // Watch both providers
    ref.listen(memberToChatProvider(chatId), (previous, next) {
      _updateChatMembers(ref, chatId, controller);
    });

    ref.listen(campMembersListProvider, (previous, next) {
      _updateChatMembers(ref, chatId, controller);
    });

    // Initial update
    _updateChatMembers(ref, chatId, controller);

    ref.onDispose(() {
      controller.close();
    });

    return controller.stream;
  },
);

void _updateChatMembers(
  Ref ref,
  String chatId,
  StreamController<List<ChatMember>> controller,
) {
  final memberToChatAsync = ref.read(memberToChatProvider(chatId));
  final campMembersAsync = ref.read(campMembersListProvider);

  memberToChatAsync.whenData((memberToChatList) {
    campMembersAsync.whenData((campMembers) {
      // Create a map of camp members for quick lookup
      final membersMap = {
        for (var member in campMembers) member.userRemoteId: member,
      };

      // Combine the data
      final chatMembers = memberToChatList
          .map((mtc) {
            final member = membersMap[mtc.userId];
            if (member == null) return null;

            return ChatMember(
              userRemoteId: member.userRemoteId,
              name: member.name,
              profilePicturePath: member.profilePicture,
              role: member.role,
              groupId: member.groupId,
              roomId: member.roomId,
              chatRemoteId: mtc.chatId,
              lastViewed: mtc.lastViewed,
            );
          })
          .whereType<ChatMember>()
          .toList();

      if (!controller.isClosed) {
        controller.add(chatMembers);
      }
    });
  });
}
