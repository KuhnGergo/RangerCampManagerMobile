import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mastercs_mobile/presentation/components/join_code/join_code_card.dart';
import 'package:mastercs_mobile/presentation/components/dialogs/warning_dialog.dart';
import 'package:mastercs_mobile/presentation/components/widgets/three_dot_loading_indicator.dart';
import 'package:mastercs_mobile/providers/actions/camp_actions_provider.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/utils/camp_status_helper.dart';

class CampPreviewTile extends ConsumerWidget {
  final Camp camp;
  final bool isSelected;
  final Future<void> Function(String campId)? onSelectCamp;

  const CampPreviewTile({
    super.key,
    required this.camp,
    this.isSelected = false,
    this.onSelectCamp,
  });

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final campActionsNotifier = ref.read(campActionsProvider.notifier);

    final status = CampStatusHelper.getCampStatus(
      startDate: camp.startDate,
      endDate: camp.endDate,
      colorScheme: colorScheme,
    );

    return Card(
      elevation: isSelected ? 8 : 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected
            ? BorderSide(color: colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onSelectCamp == null ? null : () => onSelectCamp!(camp.remoteId),
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? status.color.withAlpha(51)
                              : status.color.withAlpha(51),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            status.distanceText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected ? Colors.white : status.color,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              camp.name,
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? colorScheme.primary : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            color: colorScheme.onPrimary,
                            size: 20,
                          ),
                        ),
                      ref.watch(campActionsProvider).isLoading == true
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: ThreeDotLoadingIndicator(
                                size: 20,
                                dotSize: 2.5,
                                orbitRadius: 6,
                                spinDuration: Duration(milliseconds: 600),
                              ),
                            )
                          : PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_vert,
                                color: colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                              onSelected: (value) async {
                                switch (value) {
                                  case 'leave':
                                    if (!context.mounted) return;

                                    showWarningDialog(
                                      context: context,
                                      title: 'Leave Camp',
                                      secondThoughtLabel:
                                          'Are you sure you want to leave "${camp.name}"?',
                                      message:
                                          'You will no longer have access to this camp unless you are invited again.',
                                      confirmLabel: 'Leave',
                                      cancelLabel: 'Cancel',
                                      confirmAction: () => campActionsNotifier
                                          .leaveCamp(camp.remoteId),

                                      genericErrorMessage:
                                          'Failed to leave camp',
                                      titleColor: colorScheme.error,
                                      buttonColor: colorScheme.error,
                                      buttonForegroundColor:
                                          colorScheme.onError,
                                    );
                                    break;
                                  case 'delete':
                                    if (!context.mounted) return;

                                    showWarningDialog(
                                      context: context,
                                      title: 'Delete Camp',
                                      secondThoughtLabel:
                                          'Are you sure you want to delete "${camp.name}"?',
                                      message:
                                          'This action cannot be undone and all camp data will be permanently removed.',
                                      confirmLabel: 'Delete',
                                      cancelLabel: 'Cancel',
                                      confirmAction: () => campActionsNotifier
                                          .deleteCamp(camp.remoteId),

                                      genericErrorMessage:
                                          'Failed to delete camp',
                                      titleColor: colorScheme.error,
                                      buttonColor: colorScheme.error,
                                      buttonForegroundColor:
                                          colorScheme.onError,
                                    );

                                    break;
                                }
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                              itemBuilder: (context) {
                                final isOwner =
                                    camp.myRole.toLowerCase() == 'owner';

                                return [
                                  PopupMenuItem(
                                    value: isOwner ? 'delete' : 'leave',
                                    child: Row(
                                      children: [
                                        Icon(
                                          isOwner
                                              ? Icons.delete
                                              : Icons.exit_to_app,
                                          size: 20,
                                          color: colorScheme.error,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          isOwner ? 'Delete' : 'Leave',
                                          style: TextStyle(
                                            color: colorScheme.error,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ];
                              },
                            ),
                    ],
                  ),
                  // * Role badge * //
                  const SizedBox(height: 12),

                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        switch (camp.myRole.toLowerCase()) {
                          'camper' => Icons.person,
                          'staff' => Icons.security,
                          'owner' => Icons.badge,
                          'pending' => Icons.hourglass_top,
                          _ => Icons.help_outline,
                        },
                        size: 14,
                        color: colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        camp.myRole.toUpperCase(),
                        style: textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),

                  if (camp.joinCode != null) ...[
                    const SizedBox(height: 12),
                    JoinCodeCard(
                      joinCode: camp.joinCode!,
                      hasCopyAction: true,
                      hasChangeAction: false,
                    ),
                  ],

                  const SizedBox(height: 16),
                  (camp.startDate != null && camp.endDate != null)
                      ? Row(
                          children: [
                            Expanded(
                              child: _buildInfoChip(
                                context,
                                Icons.calendar_today,
                                'Start',
                                _formatDate(camp.startDate!),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInfoChip(
                                context,
                                Icons.event,
                                'End',
                                _formatDate(camp.endDate!),
                              ),
                            ),
                          ],
                        )
                      : SizedBox.shrink(),
                  if (camp.minGroupSize != null) ...[
                    const SizedBox(height: 12),
                    _buildInfoChip(
                      context,
                      Icons.groups,
                      'Min Group Size',
                      camp.minGroupSize.toString(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
