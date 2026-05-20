import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/presentation/components/error/error_snackbar.dart';
import 'package:mastercs_mobile/presentation/components/join_code/dialogs/join_qr_code_dialog.dart';
import 'package:mastercs_mobile/presentation/components/widgets/three_dot_loading_indicator.dart';
import 'package:mastercs_mobile/repositories/camp_repository.dart';

class ShowQRCodeButton extends ConsumerStatefulWidget {
  final String campId;

  const ShowQRCodeButton({super.key, required this.campId});

  @override
  ConsumerState<ShowQRCodeButton> createState() => _ShowQRCodeButtonState();
}

class _ShowQRCodeButtonState extends ConsumerState<ShowQRCodeButton> {
  bool _isLoading = false;

  Future<void> _showQrCodeDialog() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    try {
      final qrPngFile = await ref
          .read(campRepositoryProvider)
          .downloadJoinQrCodePng(widget.campId);

      if (!mounted) return;

      setState(() => _isLoading = false);

      await showDialog<void>(
        context: context,
        builder: (context) => JoinQrCodeDialog(qrCodeFile: qrPngFile),
      );
    } catch (e) {
      if (!mounted) return;
      showError(
        context,
        'Failed to load QR code',
        extendedText: e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      if (mounted && _isLoading) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        style: TextButton.styleFrom(
          visualDensity: VisualDensity.compact,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          backgroundColor: colorScheme.surfaceContainer,
          foregroundColor: colorScheme.onSurfaceVariant,
        ),
        onPressed: _isLoading ? null : _showQrCodeDialog,
        icon: _isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: ThreeDotLoadingIndicator(
                  dotSize: 2,
                  orbitRadius: 5,
                  color: colorScheme.primary,
                ),
              )
            : Icon(Icons.qr_code_2_outlined, size: 18),
        label: Text('Show QR code'),
      ),
    );
  }
}
