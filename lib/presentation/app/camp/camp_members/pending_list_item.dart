import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/models/member.dart';
import 'package:mastercs_mobile/presentation/components/error/error_snackbar.dart';
import 'package:mastercs_mobile/presentation/components/widgets/account_circle.dart';
import 'package:mastercs_mobile/presentation/components/user_profile/user_profile_screen.dart';
import 'package:mastercs_mobile/providers/actions/camp_member_actions_provider.dart';

class PendingListItem extends ConsumerWidget {
  final Member member;

  const PendingListItem({super.key, required this.member});

  Future<void> _handleAccept(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(campMemberActionsProvider.notifier).acceptMember(member);
    } catch (e) {
      if (context.mounted) {
        showError(context, 'Failed to accept member');
      }
    }
  }

  Future<void> _handleReject(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(campMemberActionsProvider.notifier).declineMember(member);
    } catch (e) {
      if (context.mounted) {
        showError(context, 'Failed to decline member');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                UserProfileScreen(userId: member.userRemoteId),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colorScheme.surface, width: 4),
                    color: colorScheme.surface,
                  ),
                  child: AccountCircle(
                    name: member.name,
                    userId: member.userRemoteId,
                    fileName: member.profilePicture,
                    radius: 24,
                  ),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      member.name,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton.icon(
                      onPressed: () => _handleAccept(context, ref),
                      icon: Icon(Icons.add, color: colorScheme.onSurface),
                      label: Text('Accept'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 3,
                        ),
                        backgroundColor: colorScheme.surface,
                        foregroundColor: colorScheme.onSurface,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                onPressed: () => _handleReject(context, ref),
                icon: Icon(
                  Icons.close,
                  color: colorScheme.onSurfaceVariant,
                  size: 18,
                ),
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                  ),
                  minimumSize: WidgetStateProperty.all(Size.zero),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                tooltip: 'Reject',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
