import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/models/roles.dart';
import 'package:mastercs_mobile/presentation/app/camp/camp_data/dialogs/double_date_update_dialog.dart';
import 'package:mastercs_mobile/presentation/components/dialogs/text_update_dialog.dart';
import 'package:mastercs_mobile/presentation/components/dialogs/warning_dialog.dart';
import 'package:mastercs_mobile/presentation/components/widgets/option_action.dart';
import 'package:mastercs_mobile/providers/actions/camp_actions_provider.dart';
import 'package:mastercs_mobile/providers/data/camp_provider.dart';
import 'package:mastercs_mobile/providers/data/camp_role_provider.dart';
import 'package:mastercs_mobile/providers/data/selected_camp_id_provider.dart';

void showManageCampBottomSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) =>
        ManageCampBottomSheet(actionRef: ref, sourceContext: context),
  );
}

class ManageCampBottomSheet extends ConsumerWidget {
  final WidgetRef actionRef;
  final BuildContext sourceContext;

  const ManageCampBottomSheet({
    super.key,
    required this.actionRef,
    required this.sourceContext,
  });

  void _changeCampName(BuildContext context) {
    final camp = actionRef.read(campProvider).value;
    if (camp == null) return;
    Navigator.pop(context);
    showTextUpdateDialog(
      context: sourceContext,
      errorContext: sourceContext,
      title: 'Change Camp Name',
      label: 'Camp Name',
      initialValue: camp.name,
      hintText: 'Enter camp name',
      genericErrorMessage: 'Failed to update camp name',
      maxLength: 100,
      validator: (value) {
        if (value.isEmpty) return 'Camp name cannot be empty';
        if (value.length < 3) return 'Camp name must be at least 3 characters';
        return null;
      },
      confirmAction: (newName) => actionRef
          .read(campActionsProvider.notifier)
          .updateCampDetails(name: newName),
    );
  }

  void _changeCampDates(BuildContext context) {
    final camp = actionRef.read(campProvider).value;
    if (camp == null || camp.startDate == null || camp.endDate == null) return;
    Navigator.pop(context);
    showDoubleDateUpdateDialog(
      sourceContext,
      initialStartDate: camp.startDate!,
      initialEndDate: camp.endDate!,
      confirmAction: (startDate, endDate) => actionRef
          .read(campActionsProvider.notifier)
          .updateCampDetails(startDate: startDate, endDate: endDate),
    );
  }

  void _changeJoinCode(BuildContext context) {
    final camp = actionRef.read(campProvider).value;
    if (camp == null) return;
    Navigator.pop(context);
    showTextUpdateDialog(
      context: sourceContext,
      errorContext: sourceContext,
      title: 'Change Join Code',
      label: 'Join Code',
      initialValue: camp.joinCode,
      hintText: 'Enter join code',
      maxLength: 12,
      validator: (value) {
        if (value.isEmpty) return 'Join code cannot be empty';
        if (value.length < 6) return 'Join code must be at least 6 characters';
        if (value.contains(' ')) return 'Join code cannot contain spaces';
        return null;
      },
      confirmAction: (newCode) => actionRef
          .read(campActionsProvider.notifier)
          .updateCampDetails(joinCode: newCode),
      genericErrorMessage: 'Failed to update join code',
    );
  }

  void _changeMinGroupSize(BuildContext context) {
    final camp = actionRef.read(campProvider).value;
    if (camp == null) return;
    Navigator.pop(context);
    showTextUpdateDialog(
      context: sourceContext,
      errorContext: sourceContext,
      title: 'Change Minimum Group Size',
      label: 'Minimum Group Size',
      initialValue: camp.minGroupSize?.toString() ?? '',
      hintText: 'Enter minimum group size',
      maxLength: 3,
      validator: (value) {
        if (value.isEmpty) return null; // Optional field
        final intValue = int.tryParse(value);
        if (intValue == null || intValue < 1) {
          return 'Minimum group size must be a positive integer';
        }
        return null;
      },
      confirmAction: (newSize) => actionRef
          .read(campActionsProvider.notifier)
          .updateCampDetails(
            minGroupSize: newSize.isEmpty ? null : int.parse(newSize),
          ),
      genericErrorMessage: 'Failed to update minimum group size',
    );
  }

  void _deleteCamp(BuildContext context, {required String? id}) {
    Navigator.pop(context);
    showWarningDialog(
      context: sourceContext,
      title: 'Delete Camp',
      secondThoughtLabel: 'Are you sure you want to delete this camp?',
      message:
          'This action cannot be undone and all camp data will be permanently lost.',
      confirmLabel: 'Delete',
      confirmAction: () =>
          actionRef.read(campActionsProvider.notifier).deleteCamp(id),
      genericErrorMessage: 'Failed to delete camp',
    );
  }

  void _leaveCamp(BuildContext context, {required String? campId}) {
    Navigator.pop(context);
    showWarningDialog(
      context: sourceContext,
      title: 'Leave Camp',
      secondThoughtLabel: 'Are you sure you want to leave this camp?',
      message:
          'You can rejoin later with the camp code, but you will lose access to camp data until then.',
      confirmLabel: 'Leave',
      confirmAction: () =>
          actionRef.read(campActionsProvider.notifier).leaveCamp(campId),
      genericErrorMessage: 'Failed to leave camp',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final role = Role.fromString(ref.watch(campRoleProvider).value ?? '');

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withAlpha(102),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.settings, color: colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      'Manage Camp',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (role == Role.owner) ...[
              OptionAction(
                onPressed: () => _changeCampName(context),
                icon: Icons.edit,
                label: "Change Camp Name",
              ),
              OptionAction(
                onPressed: () => _changeCampDates(context),
                icon: Icons.calendar_today,
                label: "Change Camp Dates",
              ),
              OptionAction(
                onPressed: () => _changeJoinCode(context),
                icon: Icons.vpn_key,
                label: "Change Join Code",
              ),
              OptionAction(
                onPressed: () => _changeMinGroupSize(context),
                icon: Icons.group,
                label: "Change Min Group Size",
              ),

              OptionAction(
                onPressed: () => _deleteCamp(
                  context,
                  id: actionRef.read(selectedCampIdProvider).value,
                ),
                icon: Icons.delete_forever,
                color: colorScheme.error,
                label: "Delete Camp",
              ),
            ],

            if (role != Role.owner) ...[
              OptionAction(
                onPressed: () => _leaveCamp(
                  context,
                  campId: actionRef.read(selectedCampIdProvider).value,
                ),
                color: colorScheme.error,
                icon: Icons.exit_to_app,
                label: "Leave Camp",
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
