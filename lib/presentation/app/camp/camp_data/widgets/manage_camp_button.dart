import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/presentation/app/camp/camp_data/views/manage_camp_bottom_sheet.dart';

class ManageCampButton extends ConsumerWidget {
  const ManageCampButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    void showManageCampSheet(BuildContext context) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) =>
            ManageCampBottomSheet(actionRef: ref, sourceContext: context),
      );
    }

    return OutlinedButton.icon(
      onPressed: () => showManageCampSheet(context),
      icon: Icon(Icons.settings, size: 18),
      label: Text('Manage Camp'),
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.onSurfaceVariant,
        side: BorderSide(color: colorScheme.outlineVariant, width: 1.5),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
