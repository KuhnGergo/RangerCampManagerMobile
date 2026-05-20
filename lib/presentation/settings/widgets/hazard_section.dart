import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/presentation/components/dialogs/warning_dialog.dart';
import 'package:mastercs_mobile/presentation/components/user_profile/widgets/profile_section_card.dart';
import 'package:mastercs_mobile/presentation/settings/widgets/section_action_tile.dart';
import 'package:mastercs_mobile/providers/actions/account_actions_provider.dart';
import 'package:mastercs_mobile/providers/auth/session_flow.dart';

class HazardSection extends ConsumerWidget {
  const HazardSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return ProfileSectionCard(
      title: 'Hazard Zone',
      children: [
        SectionActionTile(
          icon: Icons.logout_rounded,
          label: 'Log Out',
          color: colorScheme.error,
          onTap: () async {
            await ref.read(sessionFlowProvider.notifier).logout();
            if (context.mounted) {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/', (route) => false);
            }
          },
        ),
        const SizedBox(height: 8),
        SectionActionTile(
          icon: Icons.delete_outline_rounded,
          label: 'Delete Account',
          color: colorScheme.error,
          onTap: () {
            showWarningDialog(
              context: context,
              title: 'Delete Account',
              secondThoughtLabel:
                  'Are you sure you want to delete your account?',
              message:
                  'This action cannot be undone. All your data will be permanently deleted.',
              confirmLabel: 'Delete',
              cancelLabel: 'Cancel',
              confirmAction: () async {
                await ref.read(accountActionsProvider.notifier).deleteAccount();
                await ref.read(sessionFlowProvider.notifier).logout();
              },
              onConfirmed: () {
                if (!context.mounted) return;
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/', (route) => false);
              },
              genericErrorMessage: 'Failed to delete account',
              titleColor: colorScheme.error,
              buttonColor: colorScheme.error,
              buttonForegroundColor: colorScheme.onError,
            );
          },
        ),
      ],
    );
  }
}
