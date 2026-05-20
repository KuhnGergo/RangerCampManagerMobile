import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

final joinCampQrControllerProvider =
    NotifierProvider.autoDispose<JoinCampQrController, JoinCampQrState>(() {
      return JoinCampQrController();
    });

enum QrScanStatus { gettingPermission, permissionDenied, scanning, analyzing }

class JoinCampQrController extends Notifier<JoinCampQrState> {
  MobileScannerController? _cameraController;

  @override
  JoinCampQrState build() {
    ref.onDispose(() {
      _cameraController?.dispose();
    });

    _initializeCamera();
    return JoinCampQrState(
      status: QrScanStatus.gettingPermission,
      cameraController: null,
    );
  }

  Future<void> _initializeCamera() async {
    // Request camera permission
    final permissionStatus = await Permission.camera.request();

    if (permissionStatus.isGranted) {
      _cameraController = MobileScannerController();
      state = state.copyWith(
        status: QrScanStatus.scanning,
        cameraController: _cameraController,
      );
    } else {
      state = state.copyWith(status: QrScanStatus.permissionDenied);
    }
  }

  Future<void> retryPermission() async {
    state = state.copyWith(status: QrScanStatus.gettingPermission);
    await _initializeCamera();
  }

  void startAnalyzing(String qrCode) {
    if (state.status == QrScanStatus.analyzing) return;

    state = state.copyWith(
      status: QrScanStatus.analyzing,
      scannedValue: qrCode,
    );
  }

  void backToScanning() {
    state = state.copyWith(status: QrScanStatus.scanning, scannedValue: null);
  }
}

class JoinCampQrState {
  final QrScanStatus status;
  final MobileScannerController? cameraController;
  final String? scannedValue;

  const JoinCampQrState({
    required this.status,
    required this.cameraController,
    this.scannedValue,
  });

  JoinCampQrState copyWith({
    QrScanStatus? status,
    MobileScannerController? cameraController,
    String? scannedValue,
  }) {
    return JoinCampQrState(
      status: status ?? this.status,
      cameraController: cameraController ?? this.cameraController,
      scannedValue: scannedValue,
    );
  }
}
