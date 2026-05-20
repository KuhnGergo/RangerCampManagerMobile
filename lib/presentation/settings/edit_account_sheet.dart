import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/presentation/components/dialogs/text_update_dialog.dart';
import 'package:mastercs_mobile/presentation/components/widgets/option_action.dart';
import 'package:mastercs_mobile/presentation/settings/dialogs/edit_profile_picture_dialog.dart';
import 'package:mastercs_mobile/presentation/settings/dialogs/phone_number_update_dialog.dart';
import 'package:mastercs_mobile/providers/actions/account_actions_provider.dart';
import 'package:mastercs_mobile/providers/data/account_provider.dart';
import 'package:mastercs_mobile/providers/data/image_url_provider.dart';
import 'package:mastercs_mobile/utils/validators.dart';

class EditAccountSheet extends StatelessWidget {
  final WidgetRef actionRef;
  final String initialName;
  final String? initialPhoneNumber;
  final String? initialEmergencyContact;
  final String? initialImagePath;
  final BuildContext sourceContext;

  const EditAccountSheet({
    super.key,
    required this.actionRef,
    required this.initialName,
    this.initialPhoneNumber,
    this.initialEmergencyContact,
    this.initialImagePath,
    required this.sourceContext,
  });

  Future<void> _updateAccount({
    String? name,
    String? email,
    String? phoneNumber,
    String? emergencyContact,
  }) async {
    final currentAccount = actionRef.read(accountProvider).value;
    if (currentAccount == null) return;

    await actionRef
        .read(accountActionsProvider.notifier)
        .updateAccount(
          name: name ?? currentAccount.name,
          email: email ?? currentAccount.email,
          phoneNumber: phoneNumber ?? currentAccount.phoneNumber,
          profilePicture: currentAccount.profilePicturePath,
          emergencyContact: emergencyContact ?? currentAccount.emergencyContact,
        );
  }

  void _changeName(BuildContext context) {
    Navigator.pop(context);
    showTextUpdateDialog(
      context: sourceContext,
      errorContext: sourceContext,
      title: 'Change Name',
      label: 'Name',
      initialValue: initialName,
      hintText: 'Enter your name',
      genericErrorMessage: 'Failed to update name',
      maxLength: 50,
      validator: Validators.username,
      confirmAction: (newName) => _updateAccount(name: newName),
    );
  }

  void _changePhoneNumber(BuildContext context) {
    Navigator.pop(context);
    showPhoneNumberUpdateDialog(
      context: sourceContext,
      errorContext: sourceContext,
      initialValue: initialPhoneNumber,
      confirmAction: (newPhone) => _updateAccount(phoneNumber: newPhone),
    );
  }

  void _changeEmergencyContact(BuildContext context) {
    Navigator.pop(context);
    showTextUpdateDialog(
      context: sourceContext,
      errorContext: sourceContext,
      title: 'Change Emergency Contact',
      label: 'Emergency Contact',
      initialValue: initialEmergencyContact,
      hintText: 'Enter emergency contact',
      informationText:
          'Expected to contain the real person\'s name and phone number. This contact will be notified in case of emergencies.',
      genericErrorMessage: 'Failed to update emergency contact',
      maxLength: 120,
      confirmAction: (value) => _updateAccount(
        emergencyContact: value.trim().isEmpty ? null : value.trim(),
      ),
    );
  }

  void _editProfilePicture(BuildContext context) {
    Navigator.pop(context);

    String? imageUrl;
    if (initialImagePath != null && initialImagePath!.isNotEmpty) {
      imageUrl = actionRef
          .read(imageUrlProvider)
          .getProfilePictureUrl(initialImagePath);
    }

    showEditProfilePictureDialog(context: sourceContext, imageUrl: imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withAlpha(102),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
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
                    Icon(Icons.person, color: colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      'Edit Profile',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            OptionAction(
              onPressed: () => _editProfilePicture(context),
              icon: Icons.image,
              label: 'Edit Profile Picture',
            ),
            OptionAction(
              onPressed: () => _changeName(context),
              icon: Icons.person,
              label: 'Change Name',
            ),
            OptionAction(
              onPressed: () => _changePhoneNumber(context),
              icon: Icons.phone,
              label: 'Change Phone Number',
            ),
            OptionAction(
              onPressed: () => _changeEmergencyContact(context),
              icon: Icons.contact_phone,
              label: 'Change Emergency Contact',
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

void showEditProfileSheet(
  BuildContext context, {
  required WidgetRef actionRef,
  required String name,
  String? phoneNumber,
  String? emergencyContact,
  String? imagePath,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => EditAccountSheet(
      actionRef: actionRef,
      initialName: name,
      initialPhoneNumber: phoneNumber,
      initialEmergencyContact: emergencyContact,
      initialImagePath: imagePath,
      sourceContext: context,
    ),
  );
}
