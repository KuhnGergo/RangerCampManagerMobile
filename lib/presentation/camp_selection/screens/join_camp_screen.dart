import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mastercs_mobile/presentation/camp_selection/controllers/join_camp_screen_controller.dart';
import 'package:mastercs_mobile/presentation/auth/utils/form_field_style.dart';
import 'package:mastercs_mobile/providers/connection/connectivity_provider.dart';
import 'package:mastercs_mobile/providers/connection/status_enum.dart';

class JoinCampScreen extends ConsumerStatefulWidget {
  const JoinCampScreen({super.key});

  @override
  ConsumerState<JoinCampScreen> createState() => _JoinCampScreenState();
}

class _JoinCampScreenState extends ConsumerState<JoinCampScreen> {
  late final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final stateController = ref.read(joinCampScreenControllerProvider.notifier);
    final state = ref.watch(joinCampScreenControllerProvider);
    final connectivityStatus = ref.watch(connectivityProvider);

    // Sync controller text with state
    if (_codeController.text != state.code) {
      _codeController.value = TextEditingValue(
        text: state.code,
        selection: TextSelection.collapsed(offset: state.code.length),
      );
    }

    // Get connectivity error message
    String? connectivityError;
    connectivityStatus.whenData((status) {
      if (status == InternetStatus.offline) {
        connectivityError = 'No internet connection';
      }
    });

    // Only show errors from state (submitted validation) or connectivity
    final displayError = connectivityError ?? state.error;

    // Handle success
    ref.listen(joinCampScreenControllerProvider, (previous, next) {
      if (next.success && !previous!.success) {
        // Delay navigation to allow provider updates to complete
        Future.microtask(() {
          if (context.mounted) {
            Navigator.of(context).pop();
            stateController.resetState(); // Reset state for next time
          }
        });
      }
    });

    final isEnabled =
        !state.isJoining &&
        connectivityStatus.maybeWhen(
          data: (status) => status != InternetStatus.offline,
          orElse: () => false,
        );

    return Scaffold(
      appBar: AppBar(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Icon(
                  Icons.landscape_rounded,
                  size: 80,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Join a Camp',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the camp code or scan QR code to join',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Code Input Field
                TextField(
                  controller: _codeController,
                  enabled: isEnabled,
                  maxLength: 12,
                  onChanged: stateController.updateCode,
                  onSubmitted: isEnabled
                      ? (_) => stateController.joinCamp()
                      : null,
                  decoration: getFormFieldDecoration(
                    themeData: Theme.of(context),
                    labelText: 'Camp Code',
                    hintText: 'e.g., CAMP1234',
                    errorText: displayError,
                    enabled: isEnabled,
                    prefixIcon: const Icon(Icons.qr_code),
                  ),
                ),
                const SizedBox(height: 24),

                // Join Button
                FilledButton(
                  onPressed: isEnabled && state.code.length >= 6
                      ? stateController.joinCamp
                      : null,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: colorScheme.primary,
                    disabledBackgroundColor: colorScheme.primary.withAlpha(150),
                    disabledForegroundColor: colorScheme.onPrimary.withAlpha(
                      200,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: state.isJoining
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : Text(
                          'Join Camp',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                ),
                const SizedBox(height: 16),

                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: colorScheme.outline)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: colorScheme.outline)),
                  ],
                ),
                const SizedBox(height: 16),

                // QR Scanner Button
                OutlinedButton.icon(
                  onPressed: isEnabled
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QRScannerScreen(
                                onCodeScanned: (code) {
                                  stateController.setCodeFromQR(code);
                                  stateController.joinCamp();
                                },
                              ),
                            ),
                          );
                        }
                      : null,
                  icon: Icon(Icons.qr_code_scanner, color: colorScheme.primary),
                  label: Text(
                    'Scan QR Code',
                    style: TextStyle(fontSize: 16, color: colorScheme.primary),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: colorScheme.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class QRScannerScreen extends StatefulWidget {
  final Function(String) onCodeScanned;

  const QRScannerScreen({super.key, required this.onCodeScanned});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _hasScanned = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (_hasScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() {
      _hasScanned = true;
    });

    // Go back and pass the scanned code
    Navigator.pop(context);
    widget.onCodeScanned(code);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: cameraController.torchEnabled
                ? const Icon(Icons.flash_off, color: Colors.white)
                : const Icon(Icons.flash_on, color: Colors.amber),

            onPressed: () => cameraController.toggleTorch(),
          ),
          // IconButton(
          //   icon: ValueListenableBuilder(
          //     valueListenable: cameraController.cameraFacingState,
          //     builder: (context, state, child) {
          //       return const Icon(Icons.cameraswitch, color: Colors.white);
          //     },
          //   ),
          //   onPressed: () => cameraController.switchCamera(),
          // ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: cameraController, onDetect: _handleBarcode),
          // Overlay with cutout
          CustomPaint(
            painter: ScannerOverlayPainter(
              borderColor: colorScheme.primary,
              overlayColor: Colors.black.withAlpha(128),
            ),
            child: const SizedBox.expand(),
          ),
          // Instructions
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(179),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Position QR code within the frame',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final Color borderColor;
  final Color overlayColor;

  ScannerOverlayPainter({
    required this.borderColor,
    required this.overlayColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double scanAreaSize = size.width * 0.7;
    final double left = (size.width - scanAreaSize) / 2;
    final double top = (size.height - scanAreaSize) / 2;

    final Rect scanArea = Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize);

    // Draw overlay
    final Paint overlayPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRRect(
          RRect.fromRectAndRadius(scanArea, const Radius.circular(12)),
        ),
      ),
      overlayPaint,
    );

    // Draw corners
    final Paint cornerPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    const double cornerLength = 30;

    // Top-left corner
    canvas.drawPath(
      Path()
        ..moveTo(left, top + cornerLength)
        ..lineTo(left, top)
        ..lineTo(left + cornerLength, top),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawPath(
      Path()
        ..moveTo(left + scanAreaSize - cornerLength, top)
        ..lineTo(left + scanAreaSize, top)
        ..lineTo(left + scanAreaSize, top + cornerLength),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawPath(
      Path()
        ..moveTo(left, top + scanAreaSize - cornerLength)
        ..lineTo(left, top + scanAreaSize)
        ..lineTo(left + cornerLength, top + scanAreaSize),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawPath(
      Path()
        ..moveTo(left + scanAreaSize - cornerLength, top + scanAreaSize)
        ..lineTo(left + scanAreaSize, top + scanAreaSize)
        ..lineTo(left + scanAreaSize, top + scanAreaSize - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
