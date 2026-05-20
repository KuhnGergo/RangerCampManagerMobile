import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

final imageCropProvider = Provider<ImageCrop>((ref) {
  return ImageCrop();
});

class ImageCrop {
  final ImageCropper _imageCropper;
  ImageCrop({ImageCropper? imageCropper})
    : _imageCropper = imageCropper ?? ImageCropper();

  Future<XFile?> pickImage({
    ImageSource source = ImageSource.gallery,
    int imageQuality = 100,
  }) async {
    final file = await ImagePicker().pickImage(
      source: source,
      imageQuality: imageQuality,
    );
    return file;
  }

  /// Currently unused, but can be used for future multi-image picking for chat attachments or other features.
  Future<List<XFile>> pickImages({
    ImageSource source = ImageSource.gallery,
    int imageQuality = 100,
  }) async {
    return await ImagePicker().pickMultiImage(imageQuality: imageQuality);
  }

  Future<CroppedFile?> cropImage({
    required XFile file,
    CropStyle cropStyle = CropStyle.circle,
    required ColorScheme colorScheme,
  }) async {
    final croppedFile = await _imageCropper.cropImage(
      sourcePath: file.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 90,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          lockAspectRatio: true,
          hideBottomControls: false,
          backgroundColor: colorScheme.surfaceContainer,
          toolbarWidgetColor: colorScheme.onSurface,
          toolbarColor: colorScheme.surface,
          activeControlsWidgetColor: colorScheme.primary,
          navBarLight: colorScheme.brightness == Brightness.light,
          statusBarLight: colorScheme.brightness == Brightness.light,
          cropStyle: cropStyle,
          cropFrameStrokeWidth: 3,
          cropGridStrokeWidth: 2,
        ),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
          aspectRatioPickerButtonHidden: true,
          rotateButtonsHidden: false,
          rotateClockwiseButtonHidden: false,
          hidesNavigationBar: false,
          aspectRatioLockDimensionSwapEnabled: true,
          cropStyle: cropStyle,
          cancelButtonTitle: 'Cancel',
          doneButtonTitle: 'Done',
          resetButtonHidden: false,
        ),
      ],
    );

    // Rename the cropped file to preserve original name with "_accpic" suffix
    if (croppedFile != null) {
      final renamedFile = await newFilename(file, croppedFile);
      return renamedFile;
    }

    return croppedFile;
  }

  Future<CroppedFile?> newFilename(
    XFile originalFile,
    CroppedFile croppedFile,
  ) async {
    final originalFileName = path.basenameWithoutExtension(originalFile.path);
    final extension = path.extension(originalFile.path);
    final directory = path.dirname(croppedFile.path);
    final newFileName = '${originalFileName}_acc$extension';
    final newPath = path.join(directory, newFileName);

    try {
      final renamedFile = await File(croppedFile.path).copy(newPath);
      await File(croppedFile.path).delete();
      return CroppedFile(renamedFile.path);
    } catch (e) {
      // If renaming fails, return the original cropped file
      return croppedFile;
    }
  }
}
