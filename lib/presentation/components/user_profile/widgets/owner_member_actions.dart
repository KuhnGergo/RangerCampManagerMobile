import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/models/member.dart';
import 'package:mastercs_mobile/models/roles.dart';
import 'package:mastercs_mobile/providers/actions/camp_member_actions_provider.dart';
import 'package:mastercs_mobile/presentation/components/dialogs/warning_dialog.dart';

/// Owner-only actions: promote/demote and kick members.
class OwnerMemberActions extends ConsumerWidget {
  final Member member;

  const OwnerMemberActions({super.key, required this.member});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final Role targetRole;
    try {
      targetRole = Role.fromString(member.role);
    } catch (_) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        // Promote / Demote button
        if (targetRole == Role.camper)
          _ActionButton(
            icon: Icons.arrow_upward,
            label: 'Promote to Staff',
            color: colorScheme.primary,
            onPressed: () => _confirmPromote(context, ref),
          ),
        if (targetRole == Role.staff)
          _ActionButton(
            icon: Icons.arrow_downward,
            label: 'Demote to Camper',
            color: Colors.orange,
            onPressed: () => _confirmDemote(context, ref),
          ),
        const SizedBox(width: 8),
        // Kick button
        _ActionButton(
          icon: Icons.person_remove_outlined,
          label: 'Kick from Camp',
          color: colorScheme.error,
          onPressed: () => _confirmKick(context, ref),
        ),
      ],
    );
  }

  void _confirmPromote(BuildContext context, WidgetRef ref) {
    showWarningDialog(
      context: context,
      title: 'Promote Member',
      secondThoughtLabel: 'This will give ${member.name} staff privileges',
      message: 'Promote ${member.name} from Camper to Staff?',
      confirmLabel: 'Promote',
      genericErrorMessage: 'Failed to promote member',
      titleColor: Theme.of(context).colorScheme.primary,
      buttonColor: Theme.of(context).colorScheme.primary,
      buttonForegroundColor: Theme.of(context).colorScheme.onPrimary,
      confirmAction: () async {
        ref.read(campMemberActionsProvider.notifier).promoteMember(member);
      },
    );
  }

  void _confirmDemote(BuildContext context, WidgetRef ref) {
    showWarningDialog(
      context: context,
      title: 'Demote Member',
      secondThoughtLabel:
          'This will remove staff privileges from ${member.name}',
      message: 'Demote ${member.name} from Staff to Camper?',
      confirmLabel: 'Demote',
      genericErrorMessage: 'Failed to demote member',
      confirmAction: () async {
        ref.read(campMemberActionsProvider.notifier).demoteMember(member);
      },
    );
  }

  void _confirmKick(BuildContext context, WidgetRef ref) {
    showWarningDialog(
      context: context,
      title: 'Kick Member',
      secondThoughtLabel: '${member.name} will no longer be part of the camp',
      message:
          'Are you sure you want to kick ${member.name} from the camp? This cannot be undone.',
      confirmLabel: 'Kick',
      genericErrorMessage: 'Failed to kick member',
      confirmAction: () async {
        ref.read(campMemberActionsProvider.notifier).kickMember(member);
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withAlpha(120)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
    );
  }
}
