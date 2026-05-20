import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/models/member.dart';
import 'package:mastercs_mobile/models/roles.dart';

import '../providers/user_profile_provider.dart';
import 'profile_section_card.dart';

/// Displays location info with role-based visibility.
/// Owner/Staff: full location details (or "not available").
/// Camper with group chat data (same group): distance & map.
/// Otherwise: shrink.
class LocationSection extends ConsumerWidget {
  final Member member;

  const LocationSection({super.key, required this.member});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myRole = ref.watch(myRoleProvider);
    final isPrivileged = myRole == Role.owner || myRole == Role.staff;

    if (member.role == Role.pending.toString()) {
      return SizedBox.shrink();
    }

    if (isPrivileged) return _LocationContent(member: member);

    // Campers: only show if they have chat data for this member's group
    if (member.groupId == null) return const SizedBox.shrink();

    final groupChat = ref.watch(memberGroupChatProvider(member.groupId!));
    if (groupChat == null) return const SizedBox.shrink();

    return _LocationContent(member: member);
  }
}

class _LocationContent extends ConsumerWidget {
  final Member member;

  const _LocationContent({required this.member});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return ProfileSectionCard(
      title: 'Location',
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              if (member.lastLocation != null) ...[
                Text(
                  member.distanceText ?? 'Location available',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
                Spacer(),
                Text(
                  _formatTime(member.lastLocation?.lastUpdated),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (member.lastLocation == null) ...[
                Text(
                  'Location not available',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  static String _formatTime(DateTime? time) {
    if (time == null) return 'Unknown';
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
