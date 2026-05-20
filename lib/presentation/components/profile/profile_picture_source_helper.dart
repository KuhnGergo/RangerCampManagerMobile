import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mastercs_mobile/presentation/components/crop_image/image_crop.dart';
import 'package:mastercs_mobile/presentation/components/dialogs/profile_picture_source_dialog.dart';

Future<File?> pickProfilePictureFromSource({
  required WidgetRef ref,
  required ProfilePictureSourceOption sourceOption,
  required ColorScheme colorScheme,
}) async {
  if (sourceOption == ProfilePictureSourceOption.remove) {
    return null;
  }

  final cropper = ref.read(imageCropProvider);
  final source = sourceOption == ProfilePictureSourceOption.camera
      ? ImageSource.camera
      : ImageSource.gallery;

  final file = await cropper.pickImage(source: source);
  if (file == null) {
    return null;
  }

  final croppedFile = await cropper.cropImage(
    file: file,
    colorScheme: colorScheme,
  );
  if (croppedFile == null) {
    return null;
  }

  return File(croppedFile.path);
}
