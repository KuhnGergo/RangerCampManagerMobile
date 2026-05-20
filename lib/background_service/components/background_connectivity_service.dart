import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

class BackgroundConnectivityService {
  final Connectivity _connectivity;

  DateTime? _lastProbeAt;
  bool _lastProbeResult = false;

  BackgroundConnectivityService({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  Future<bool> hasInternet() async {
    final transports = await _connectivity.checkConnectivity();
    if (transports.isEmpty ||
        transports.contains(ConnectivityResult.none) &&
            transports.length == 1) {
      return false;
    }

    if (_lastProbeAt != null &&
        DateTime.now().difference(_lastProbeAt!) < const Duration(seconds: 3)) {
      return _lastProbeResult;
    }

    _lastProbeAt = DateTime.now();

    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 1));
      _lastProbeResult =
          result.isNotEmpty && result.first.rawAddress.isNotEmpty;
      return _lastProbeResult;
    } catch (_) {
      _lastProbeResult = false;
      return false;
    }
  }
}
