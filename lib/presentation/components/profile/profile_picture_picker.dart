import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/presentation/components/dialogs/profile_picture_source_dialog.dart';
import 'package:mastercs_mobile/presentation/components/profile/profile_picture_source_helper.dart';

/// Reusable profile picture picker with camera and gallery options
class ProfilePicturePicker extends ConsumerStatefulWidget {
  final File? initialImage;
  final String? initialImagePath;
  final String? initialImageUrl;
  final Function(File?) onImageChanged;
  final double size;
  final bool showEditIcon;
  final String userName;

  const ProfilePicturePicker({
    super.key,
    this.initialImage,
    this.initialImagePath,
    this.initialImageUrl,
    required this.onImageChanged,
    this.size = 140,
    this.showEditIcon = true,
    required this.userName,
  });

  @override
  ConsumerState<ProfilePicturePicker> createState() =>
      _ProfilePicturePickerState();
}

class _ProfilePicturePickerState extends ConsumerState<ProfilePicturePicker> {
  File? _image;

  @override
  void initState() {
    super.initState();
    _image =
        widget.initialImage ??
        (widget.initialImagePath != null && widget.initialImagePath!.isNotEmpty
            ? File(widget.initialImagePath!)
            : null);
  }

  @override
  void didUpdateWidget(ProfilePicturePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialImagePath != oldWidget.initialImagePath ||
        widget.initialImage != oldWidget.initialImage ||
        widget.initialImageUrl != oldWidget.initialImageUrl) {
      // If initialImageUrl changed (upload completed), clear local file
      // so network image can be displayed
      if (widget.initialImageUrl != oldWidget.initialImageUrl &&
          widget.initialImageUrl != null &&
          widget.initialImageUrl!.isNotEmpty) {
        _image = null;
      } else {
        _image =
            widget.initialImage ??
            (widget.initialImagePath != null &&
                    widget.initialImagePath!.isNotEmpty
                ? File(widget.initialImagePath!)
                : null);
      }
    }
  }

  Future<void> _showImageSourceDialog() async {
    final hasAnyImage =
        _image != null ||
        (widget.initialImageUrl != null && widget.initialImageUrl!.isNotEmpty);
    final sourceOption = await showProfilePictureSourceDialog(
      context: context,
      canRemove: hasAnyImage,
    );

    if (sourceOption == null || !mounted) {
      return;
    }

    if (sourceOption == ProfilePictureSourceOption.remove) {
      _removeImage();
      return;
    }

    final pickedFile = await pickProfilePictureFromSource(
      ref: ref,
      sourceOption: sourceOption,
      colorScheme: Theme.of(context).colorScheme,
    );
    if (pickedFile == null || !mounted) {
      return;
    }

    setState(() {
      _image = pickedFile;
    });
    widget.onImageChanged(_image);
  }

  void _removeImage() {
    setState(() {
      _image = null;
    });
    widget.onImageChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final bool hasLocalImage = _image != null;
    final bool hasNetworkImage =
        !hasLocalImage &&
        widget.initialImageUrl != null &&
        widget.initialImageUrl!.isNotEmpty;

    Widget imageContent;
    if (hasLocalImage) {
      imageContent = Image.file(
        _image!,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.cover,
      );
    } else if (hasNetworkImage) {
      imageContent = CachedNetworkImage(
        imageUrl: widget.initialImageUrl!,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.cover,
        placeholder: (context, url) => SizedBox(
          width: widget.size,
          height: widget.size,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.surfaceContainerLow,
            ),
          ),
        ),
        errorWidget: (context, url, error) {
          return Icon(
            Icons.broken_image,
            size: widget.size * 0.5,
            color: colorScheme.onSurfaceVariant,
          );
        },
      );
    } else {
      imageContent = Icon(
        Icons.add_a_photo,
        size: widget.size * 0.3,
        color: colorScheme.onSurfaceVariant,
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: _showImageSourceDialog,
          child: CircleAvatar(
            radius: widget.size / 2,
            backgroundColor: colorScheme.surfaceContainerHighest,
            child: ClipOval(
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: imageContent,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
