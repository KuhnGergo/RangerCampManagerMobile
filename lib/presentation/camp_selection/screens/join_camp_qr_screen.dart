import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/presentation/camp_selection/widgets/join_camp_qr_analyzing_view.dart';
import 'package:mastercs_mobile/presentation/components/widgets/three_dot_loading_indicator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mastercs_mobile/presentation/camp_selection/controllers/join_camp_qr_controller.dart';
import 'package:permission_handler/permission_handler.dart';

class JoinCampQrScreen extends ConsumerWidget {
  const JoinCampQrScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final controller = ref.read(joinCampQrControllerProvider.notifier);
    final state = ref.watch(joinCampQrControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Join camp with QR Code',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: _buildBody(context, state, controller, colorScheme, textTheme),
    );
  }

  Widget _buildBody(
    BuildContext context,
    JoinCampQrState state,
    JoinCampQrController controller,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    switch (state.status) {
      case QrScanStatus.gettingPermission:
        return _buildLoadingView('Requesting camera permission...');

      case QrScanStatus.permissionDenied:
        return _buildPermissionDeniedView(context, controller, colorScheme);

      case QrScanStatus.scanning:
        return _buildScannerView(state, controller, colorScheme, textTheme);

      case QrScanStatus.analyzing:
        return _buildAnalyzingView(context, state, controller);
    }
  }

  Widget _buildLoadingView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const ThreeDotLoadingIndicator(
            color: Colors.blueGrey,
            size: 24,
            dotSize: 6,
            orbitRadius: 15,
          ),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }

  Widget _buildPermissionDeniedView(
    BuildContext context,
    JoinCampQrController controller,
    ColorScheme colorScheme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.errorContainer.withAlpha(128),
              ),
              child: Icon(
                Icons.camera_alt_outlined,
                size: 80,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Camera Permission Required',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 22,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Please allow camera access to scan QR codes.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () async => await openAppSettings(),
              icon: const Icon(Icons.settings),
              label: const Text('Open Settings'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => controller.retryPermission(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerView(
    JoinCampQrState state,
    JoinCampQrController controller,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    if (state.cameraController == null) {
      return _buildLoadingView('Initializing camera...');
    }

    return Stack(
      children: [
        MobileScanner(
          controller: state.cameraController,
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            if (barcodes.isNotEmpty) {
              final String? code = barcodes.first.rawValue;
              if (code != null && code.isNotEmpty) {
                controller.startAnalyzing(code);
              }
            }
          },
        ),
        // Overlay with scanning guide
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.primary, width: 3),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        // Instructions at top
        Positioned(
          top: 32,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surface.withAlpha(179),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              'Position the QR code within the frame',
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyzingView(
    BuildContext context,
    JoinCampQrState state,
    JoinCampQrController controller,
  ) {
    return JoinCampQrAnalyzingView(
      qrValue: state.scannedValue ?? '',
      onBackToScanning: controller.backToScanning,
      onJoinSuccess: () {
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
    );
  }
}
