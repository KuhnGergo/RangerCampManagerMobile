import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/presentation/components/dialogs/text_update_dialog.dart';
import 'package:mastercs_mobile/providers/actions/camp_actions_provider.dart';
import 'package:mastercs_mobile/utils/validators.dart';

void showChangeJoinCodeDialog(
  BuildContext context,
  WidgetRef ref,
  String? currentJoinCode,
) {
  showTextUpdateDialog(
    context: context,
    title: 'Change Join Code',
    informationText:
        'Enter a new join code for your camp. Make it easy to remember!',
    label: 'Join Code',
    hintText: 'Enter join code',
    initialValue: currentJoinCode,
    maxLength: 20,
    validator: (value) => Validators.joinCode(value),
    confirmAction: (newJoinCode) async {
      await ref
          .read(campActionsProvider.notifier)
          .updateCampDetails(joinCode: newJoinCode);
    },
    genericErrorMessage: 'Failed to update join code.',
    errorContext: context,
  );
}
