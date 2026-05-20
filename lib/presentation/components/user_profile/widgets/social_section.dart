import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/models/chat_types.dart';
import 'package:mastercs_mobile/models/member.dart';
import 'package:mastercs_mobile/models/roles.dart';
import 'package:mastercs_mobile/providers/data/group_provider.dart';
import 'package:mastercs_mobile/providers/data/room_provider.dart';
import 'package:mastercs_mobile/utils/chat_type_utils.dart';

import '../providers/user_profile_provider.dart';
import 'profile_section_card.dart';
import 'social_chat_card.dart';
import 'social_membership_card.dart';

/// A unified "Social" section shown on the user profile screen.
///
/// Displays both group and room sub-cards under one section header.
/// Rules per entry:
///   - chat data available  → [SocialChatCard] (full info + actions)
///   - id set but no chat   → [SocialMembershipCard] with hasMembership: true
///   - id is null           → [SocialMembershipCard] with hasMembership: false
class SocialSection extends ConsumerWidget {
  final Member member;
  const SocialSection({super.key, required this.member});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (member.role != Role.camper.toString()) {
      return SizedBox.shrink();
    }

    final groupChat = member.groupId != null
        ? ref.watch(memberGroupChatProvider(member.groupId!))
        : null;
    final roomChat = member.roomId != null
        ? ref.watch(memberRoomChatProvider(member.roomId!))
        : null;

    // The user's own group and room IDs NOT the profile user's group and room IDs
    final myGroupId = ref.watch(groupProvider.select((g) => g.value?.typeId));
    final myRoomId = ref.watch(roomProvider.select((r) => r.value?.typeId));

    return ProfileSectionCard(
      title: 'Social',
      children: [
        _buildEntry(
          id: member.groupId,
          chat: groupChat,
          label: 'Group',
          icon: ChatTypeUtils.getChatIcon(chatType: ChatType.group),
          myGroupId: myGroupId,
          myRoomId: myRoomId,
        ),
        const SizedBox(height: 8),
        _buildEntry(
          id: member.roomId,
          chat: roomChat,
          label: 'Room',
          icon: ChatTypeUtils.getChatIcon(chatType: ChatType.room),
          myGroupId: myGroupId,
          myRoomId: myRoomId,
        ),
      ],
    );
  }

  Widget _buildEntry({
    required String? id,
    required Chat? chat,
    required String label,
    required IconData icon,
    String? myGroupId,
    String? myRoomId,
  }) {
    if (chat != null) {
      final isSelected =
          (myGroupId != null &&
              chat.type == ChatType.group.toString() &&
              chat.typeId == myGroupId) ||
          (myRoomId != null &&
              chat.type == ChatType.room.toString() &&
              chat.typeId == myRoomId);

      return SocialChatCard(
        chat: chat,
        label: label,
        icon: icon,
        isSelected: isSelected,
      );
    }
    return SocialMembershipCard(
      hasMembership: id != null,
      label: label,
      icon: icon,
    );
  }
}
