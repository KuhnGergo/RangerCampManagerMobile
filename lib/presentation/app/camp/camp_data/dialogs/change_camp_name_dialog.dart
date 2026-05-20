import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/presentation/components/dialogs/text_update_dialog.dart';
import 'package:mastercs_mobile/providers/actions/camp_actions_provider.dart';

void showChangeCampNameDialog(
  BuildContext context,
  WidgetRef ref,
  String currentName,
) {
  showTextUpdateDialog(
    context: context,
    title: 'Change Camp Name',
    informationText: 'Enter a new name for your camp.',
    label: 'Camp Name',
    hintText: 'Enter camp name',
    initialValue: currentName,
    maxLength: 100,
    validator: (value) {
      if (value.isEmpty) {
        return 'Camp name cannot be empty';
      }
      if (value.length < 3) {
        return 'Camp name must be at least 3 characters';
      }
      return null;
    },
    confirmAction: (newName) async {
      await ref
          .read(campActionsProvider.notifier)
          .updateCampDetails(name: newName);
    },
    genericErrorMessage: 'Failed to update camp name.',
    errorContext: context,
  );
}
