import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mastercs_mobile/presentation/components/widgets/three_dot_loading_indicator.dart';
import 'package:open_filex/open_filex.dart';
import 'package:mastercs_mobile/presentation/components/error/error_snackbar.dart';
import 'package:mastercs_mobile/presentation/components/join_code/domain/join_code_exceptions.dart';
import 'package:mastercs_mobile/presentation/components/join_code/domain/join_qr_download_service.dart';

class JoinQrCodeDialog extends StatefulWidget {
  final File qrCodeFile;

  const JoinQrCodeDialog({super.key, required this.qrCodeFile});

  @override
  State<JoinQrCodeDialog> createState() => _JoinQrCodeDialogState();
}

class _JoinQrCodeDialogState extends State<JoinQrCodeDialog> {
  bool _isSaving = false;
  String? _savedImagePath;
  final JoinQrDownloadService _downloadService = const JoinQrDownloadService();

  Future<void> _saveToGallery() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);
    try {
      final savedPath = await _downloadService.saveToGallery(widget.qrCodeFile);

      if (!mounted) return;
      setState(() => _savedImagePath = savedPath);
    } on PermissionDeniedException catch (e) {
      if (!mounted) return;
      showError(
        context,
        'Gallery permission is required',
        extendedText: e.message,
      );
    } catch (e) {
      if (!mounted) return;
      showError(
        context,
        'Failed to save QR code image',
        extendedText: e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _openInGallery() async {
    final savedPath = _savedImagePath;
    if (savedPath == null) return;

    try {
      final result = await OpenFilex.open(savedPath);
      if (result.type != ResultType.done) {
        throw Exception(result.message);
      }
    } catch (e) {
      if (!mounted) return;
      showError(
        context,
        'Failed to open image in gallery',
        extendedText: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text(
        'Camp Join QR Code',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.file(
            widget.qrCodeFile,
            fit: BoxFit.contain,
            width: 220,
            height: 220,
            errorBuilder: (context, error, stackTrace) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  showError(
                    context,
                    'Failed to render QR code preview',
                    extendedText: error.toString(),
                  );
                  Navigator.of(context).pop();
                }
              });
              return SizedBox(
                width: 220,
                height: 220,
                child: Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: colorScheme.error,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _isSaving ? null : _saveToGallery,
            icon: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: ThreeDotLoadingIndicator(
                      dotSize: 2.5,
                      orbitRadius: 5,
                    ),
                  )
                : const Icon(Icons.download_outlined),
            label: const Text('Download to gallery'),
          ),
          if (_savedImagePath != null) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _openInGallery,
              icon: Icon(
                Icons.photo_library_outlined,
                color: colorScheme.onSurfaceVariant,
              ),
              label: Text(
                'Open in gallery',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
