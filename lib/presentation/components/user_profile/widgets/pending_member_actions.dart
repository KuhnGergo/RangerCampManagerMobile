import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/models/member.dart';
import 'package:mastercs_mobile/providers/actions/camp_member_actions_provider.dart';
import 'package:mastercs_mobile/presentation/components/dialogs/warning_dialog.dart';
import 'package:mastercs_mobile/utils/progress_color_utils.dart';

/// Pending member actions: accept or decline. Owner-only.
class PendingMemberActions extends ConsumerWidget {
  final Member member;

  const PendingMemberActions({super.key, required this.member});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Pending Request',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: 8),
            Icon(Icons.hourglass_top_outlined, size: 18),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${member.name} has requested to join the camp.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _confirmAccept(context, ref),
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Accept'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ProgressColorUtils.toColor(1.0),
                  side: BorderSide(color: ProgressColorUtils.toColor(1.0)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 2,
                    horizontal: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _confirmDecline(context, ref),
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Decline'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.error,
                  side: BorderSide(color: colorScheme.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 2,
                    horizontal: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _confirmAccept(BuildContext context, WidgetRef ref) {
    final acceptColor = ProgressColorUtils.toColor(1.0);

    showWarningDialog(
      context: context,
      title: 'Accept Member',
      secondThoughtLabel: 'Accept this member?',
      message: 'Accept ${member.name} into the camp?',
      confirmLabel: 'Accept',
      genericErrorMessage: 'Failed to accept member.',
      confirmAction: () async {
        await ref.read(campMemberActionsProvider.notifier).acceptMember(member);
      },
      titleColor: acceptColor,
      buttonColor: acceptColor,
      buttonForegroundColor: Colors.white,
    );
  }

  void _confirmDecline(BuildContext context, WidgetRef ref) {
    showWarningDialog(
      context: context,
      title: 'Decline Member',
      secondThoughtLabel: 'Decline this request?',
      message: 'Decline ${member.name}\'s request to join?',
      confirmLabel: 'Decline',
      genericErrorMessage: 'Failed to decline member.',
      confirmAction: () async {
        await ref
            .read(campMemberActionsProvider.notifier)
            .declineMember(member);
      },
    );
  }
}
