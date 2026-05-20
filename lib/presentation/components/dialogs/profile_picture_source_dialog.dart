import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

enum ProfilePictureSourceOption { camera, gallery, remove }

Future<ProfilePictureSourceOption?> showProfilePictureSourceDialog({
  required BuildContext context,
  required bool canRemove,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  Future<void> handleSourceSelection({
    required BuildContext dialogContext,
    required Permission permission,
    required ProfilePictureSourceOption option,
  }) async {
    final currentStatus = await permission.status;

    // Try navigating early
    if (dialogContext.mounted) {
      // This is a context based future that pops this context, while giving the option value to the context above it.
      Navigator.of(dialogContext).pop(option);
    }
    // If navigation succeeded, the context is no longer valid, so we return early
    if (context.mounted) {
      return;
    }

    // If permission is permanently denied or restricted, open app settings
    if (currentStatus.isPermanentlyDenied || currentStatus.isRestricted) {
      await openAppSettings();
      return;
    }

    // If permission is denied, request it. If it's granted or limited, proceed
    final effectiveStatus = currentStatus.isDenied
        ? await permission.request()
        : currentStatus;

    // If permission is not granted or limited, do not proceed
    if (!effectiveStatus.isGranted && !effectiveStatus.isLimited) {
      return;
    }

    // Second attempt to navigate after permission is granted
    if (dialogContext.mounted) {
      Navigator.of(dialogContext).pop(option);
    }
  }

  return showDialog<ProfilePictureSourceOption>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text(
        'Options',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton.icon(
              onPressed: () => handleSourceSelection(
                dialogContext: dialogContext,
                permission: Permission.camera,
                option: ProfilePictureSourceOption.camera,
              ),
              icon: Icon(Icons.camera_alt, color: colorScheme.onPrimary),
              label: const Text('Camera'),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
              ),
            ),
            FilledButton.icon(
              onPressed: () => handleSourceSelection(
                dialogContext: dialogContext,
                permission: Permission.photos,
                option: ProfilePictureSourceOption.gallery,
              ),
              icon: Icon(Icons.photo_library, color: colorScheme.onPrimary),
              label: const Text('Gallery'),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
              ),
            ),
            if (canRemove)
              FilledButton.icon(
                onPressed: () => Navigator.of(
                  dialogContext,
                ).pop(ProfilePictureSourceOption.remove),
                icon: Icon(Icons.delete, color: colorScheme.onPrimary),
                label: const Text('Remove'),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                ),
              ),
          ],
        ),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 6),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}
