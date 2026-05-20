import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/models/member.dart';
import 'package:mastercs_mobile/presentation/app/chats/utils/chat_color_helper.dart';
import 'package:mastercs_mobile/presentation/app/map/map_controller.dart';
import 'package:mastercs_mobile/presentation/components/user_profile/providers/user_profile_provider.dart';
import 'package:mastercs_mobile/presentation/components/user_profile/user_profile_screen.dart';
import 'package:mastercs_mobile/presentation/components/widgets/account_circle.dart';
import 'package:mastercs_mobile/providers/auth/auth_provider.dart';
import 'package:mastercs_mobile/utils/time_utils.dart';

class SmallLocationMemberListItem extends ConsumerWidget {
  final Member member;

  const SmallLocationMemberListItem({super.key, required this.member});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final myUserId = ref.watch(authProvider.notifier).getUserId;
    final isSelf = myUserId != null && member.userRemoteId == myUserId;
    final distance = member.distanceText;
    final badgeTitle = isSelf ? "It's you" : distance;
    final timeAgo = formatTimeAgoCompact(member.lastLocation?.lastUpdated);
    final groupChat = member.groupId != null
        ? ref.watch(memberGroupChatProvider(member.groupId!))
        : null;
    final badgeColor = groupChat?.color != null
        ? Color.alphaBlend(
            ChatColorHelper.getBackgroundColor(groupChat!.color),
            colorScheme.surface,
          )
        : colorScheme.surfaceContainer;
    final badgeBorderColor = groupChat?.color != null
        ? ChatColorHelper.getFullColor(groupChat!.color)
        : colorScheme.onSurfaceVariant.withAlpha(150);

    return GestureDetector(
      onTap: () {
        ref.read(mapControllerProvider.notifier).setFollowedMember(member);

        if (member.position != null) {
          return;
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  UserProfileScreen(userId: member.userRemoteId),
            ),
          );
        }
      },
      child: SizedBox(
        width: 56,
        height: 56,
        child: Stack(
          children: [
            // Avatar circle
            AccountCircle(
              name: member.name,
              fileName: member.profilePicture,
              backgroundColor: colorScheme.surface,
              textColor: colorScheme.onSurface,
              isOnline: member.isOnline,
              role: member.role,
              radius: 28,
              userId: member.userRemoteId,
            ),

            // Distance and time badge
            if (badgeTitle != null && !isSelf)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: FractionalTranslation(
                  translation: const Offset(0, -1.1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: badgeBorderColor, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(30),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          badgeTitle,
                          style: TextStyle(
                            color: colorScheme.onPrimaryContainer,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (timeAgo.isNotEmpty)
                          Text(
                            timeAgo,
                            style: TextStyle(
                              color: colorScheme.onPrimaryContainer.withAlpha(
                                180,
                              ),
                              fontSize: 7,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
