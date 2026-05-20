import 'dart:io';

import 'package:mastercs_mobile/presentation/components/join_code/domain/join_code_permissions.dart';
import 'package:saver_gallery/saver_gallery.dart';

class JoinQrDownloadService {
  const JoinQrDownloadService();

  Future<String> saveToGallery(File qrCodeFile) async {
    await JoinCodePermissions.ensureGalleryAccess();

    final imageBytes = await qrCodeFile.readAsBytes();
    final fileName =
        'camp_join_qr_${DateTime.now().millisecondsSinceEpoch}.png';

    final result = await SaverGallery.saveImage(
      imageBytes,
      quality: 100,
      fileName: fileName,
      skipIfExists: false,
    );

    if (!result.isSuccess) {
      throw Exception(result.errorMessage ?? 'Failed to save image to gallery');
    }

    // saver_gallery does not currently provide the final media-store path.
    return qrCodeFile.path;
  }
}
