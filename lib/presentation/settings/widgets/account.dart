import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/presentation/components/profile/profile_picture_picker.dart';
import 'package:mastercs_mobile/presentation/components/user_profile/widgets/user_info_section.dart';
import 'package:mastercs_mobile/presentation/settings/edit_account_sheet.dart';
import 'package:mastercs_mobile/providers/actions/image_actions_provider.dart';
import 'package:mastercs_mobile/providers/data/account_provider.dart';
import 'package:mastercs_mobile/providers/data/image_url_provider.dart';

class AccountWidget extends ConsumerWidget {
  const AccountWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final account =
        ref.watch(accountProvider).whenData((user) => user).value ??
        User(remoteId: '', name: '', email: '', createdAt: DateTime.now());

    final imageUrl = ref.read(imageUrlProvider);
    String? profilePictureUrl;
    if (account.profilePicturePath != null &&
        account.profilePicturePath!.isNotEmpty) {
      profilePictureUrl = imageUrl.getProfilePictureUrl(
        account.profilePicturePath!,
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: Column(
        children: [
          ProfilePicturePicker(
            userName: account.name,
            initialImageUrl: profilePictureUrl,
            size: 96,
            onImageChanged: (newImage) async {
              if (newImage != null) {
                ref
                    .read(imageActionsProvider.notifier)
                    .uploadProfilePicture(newImage);
              } else {
                ref.read(imageActionsProvider.notifier).deleteProfilePicture();
              }
            },
          ),
          const SizedBox(height: 16),
          Text(
            account.name,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 12),
          UserInfoSection(user: account),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                showEditProfileSheet(
                  context,
                  actionRef: ref,
                  name: account.name,
                  phoneNumber: account.phoneNumber,
                  emergencyContact: account.emergencyContact,
                  imagePath: account.profilePicturePath,
                );
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onPrimary,
                ),
              ),
              child: const Text('Edit Profile'),
            ),
          ),
        ],
      ),
    );
  }
}
