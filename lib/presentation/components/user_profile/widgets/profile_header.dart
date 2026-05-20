import 'package:flutter/material.dart';
import 'package:mastercs_mobile/models/member.dart';
import 'package:mastercs_mobile/presentation/components/widgets/account_circle.dart';

import 'profile_online_badge.dart';
import 'profile_role_badge.dart';

/// Top section of the profile: avatar, name, role badge, and online status.
class ProfileHeader extends StatelessWidget {
  final Member member;

  const ProfileHeader({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        AccountCircle(
          radius: 56,
          name: member.name,
          userId: member.userRemoteId,
          fileName: member.profilePicture,
          isOnline: member.isOnline,
          showOnlineIndicator: true,
        ),
        const SizedBox(height: 16),
        Text(
          member.name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ProfileRoleBadge(role: member.role),
            const SizedBox(width: 8),
            ProfileOnlineBadge(
              isOnline: member.isOnline,
              lastSeenAt: member.lastSeenAt,
            ),
          ],
        ),
      ],
    );
  }
}
