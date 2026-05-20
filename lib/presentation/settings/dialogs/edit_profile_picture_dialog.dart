import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/presentation/components/dialogs/profile_picture_source_dialog.dart';
import 'package:mastercs_mobile/presentation/components/error/error_snackbar.dart';
import 'package:mastercs_mobile/presentation/components/profile/profile_picture_source_helper.dart';
import 'package:mastercs_mobile/presentation/components/widgets/three_dot_loading_indicator.dart';
import 'package:mastercs_mobile/providers/actions/image_actions_provider.dart';

void showEditProfilePictureDialog({
  required BuildContext context,
  String? imageUrl,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => _EditProfilePictureDialog(imageUrl: imageUrl),
  );
}

class _EditProfilePictureDialog extends ConsumerStatefulWidget {
  final String? imageUrl;

  const _EditProfilePictureDialog({required this.imageUrl});

  @override
  ConsumerState<_EditProfilePictureDialog> createState() =>
      _EditProfilePictureDialogState();
}

class _EditProfilePictureDialogState
    extends ConsumerState<_EditProfilePictureDialog> {
  bool _isUpdating = false;

  bool get _hasImage => widget.imageUrl != null && widget.imageUrl!.isNotEmpty;

  Future<void> _onChooseSource() async {
    final selected = await showProfilePictureSourceDialog(
      context: context,
      canRemove: _hasImage,
    );

    if (selected == null || !mounted) {
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      if (selected == ProfilePictureSourceOption.remove) {
        await ref.read(imageActionsProvider.notifier).deleteProfilePicture();
      } else {
        final pickedFile = await pickProfilePictureFromSource(
          ref: ref,
          sourceOption: selected,
          colorScheme: Theme.of(context).colorScheme,
        );

        if (pickedFile == null) {
          if (mounted) {
            setState(() => _isUpdating = false);
          }
          return;
        }

        await ref
            .read(imageActionsProvider.notifier)
            .uploadProfilePicture(File(pickedFile.path));
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUpdating = false);
        showError(
          context,
          'Failed to update profile picture',
          extendedText: e.toString().replaceAll('Exception: ', ''),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text(
        'Edit Profile Picture',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_hasImage)
            Text(
              'No profile picture set',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurface.withAlpha(160),
                fontSize: 14,
              ),
            ),
          const SizedBox(height: 16),
          CircleAvatar(
            radius: 44,
            backgroundColor: colorScheme.surfaceContainerHighest,
            child: ClipOval(
              child: SizedBox(
                width: 88,
                height: 88,
                child: _hasImage
                    ? CachedNetworkImage(
                        imageUrl: widget.imageUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Icon(
                          Icons.broken_image,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      )
                    : Icon(
                        Icons.account_circle,
                        size: 56,
                        color: colorScheme.onSurfaceVariant,
                      ),
              ),
            ),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: _isUpdating ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _isUpdating ? null : _onChooseSource,
          icon: _isUpdating
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: ThreeDotLoadingIndicator(
                    dotSize: 2.2,
                    orbitRadius: 6,
                    spinDuration: Duration(seconds: 1),
                    color: colorScheme.onPrimary,
                  ),
                )
              : null,
          label: Text(_isUpdating ? 'Updating...' : 'Change'),
        ),
      ],
    );
  }
}
