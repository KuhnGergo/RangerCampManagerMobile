import 'dart:io';

import 'package:mastercs_mobile/presentation/components/join_code/domain/join_code_exceptions.dart';
import 'package:permission_handler/permission_handler.dart';

class JoinCodePermissions {
  static Future<void> ensureGalleryAccess() async {
    if (Platform.isIOS) {
      final status = await Permission.photosAddOnly.request();
      if (status.isGranted || status.isLimited) {
        return;
      }
      if (status.isPermanentlyDenied || status.isRestricted) {
        await openAppSettings();
        throw const PermissionDeniedException(
          'Gallery permission is permanently denied. App settings was opened.',
        );
      }
      throw const PermissionDeniedException('Gallery permission denied.');
    }

    if (Platform.isAndroid) {
      final photosStatus = await Permission.photos.request();
      if (photosStatus.isGranted || photosStatus.isLimited) {
        return;
      }
      if (photosStatus.isPermanentlyDenied) {
        await openAppSettings();
        throw const PermissionDeniedException(
          'Gallery permission is permanently denied. App settings was opened.',
        );
      }

      final storageStatus = await Permission.storage.request();
      if (storageStatus.isGranted) {
        return;
      }
      if (storageStatus.isPermanentlyDenied) {
        await openAppSettings();
        throw const PermissionDeniedException(
          'Storage permission is permanently denied. App settings was opened.',
        );
      }

      final manageStatus = await Permission.manageExternalStorage.request();
      if (manageStatus.isGranted) {
        return;
      }
      if (manageStatus.isPermanentlyDenied) {
        await openAppSettings();
        throw const PermissionDeniedException(
          'Storage permission is permanently denied. App settings was opened.',
        );
      }

      throw const PermissionDeniedException(
        'Storage/gallery permission denied.',
      );
    }
  }
}
