import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Provider that monitors internet connectivity status (for listening to changes)
final connectivityStreamProvider = StreamProvider<ConnectionType>((ref) {
  final connectivity = Connectivity();

  return connectivity.onConnectivityChanged.asyncMap((results) async {
    final type = _determineConnectionType(results);

    if (type == ConnectionType.noConnection) {
      return type;
    }

    final online = await _hasInternet();

    return online ? type : ConnectionType.noInternet;
  });
});

/// Provider to get current connection type once (for one-time checks)
final currentConnectionTypeProvider = FutureProvider<ConnectionType>((
  ref,
) async {
  final connectivity = Connectivity();

  final result = await connectivity.checkConnectivity();

  final type = _determineConnectionType(result);

  if (type == ConnectionType.noConnection) {
    return type;
  }

  final hasInternet = await _hasInternet();

  return hasInternet ? type : ConnectionType.noInternet;
});

/// Simple provider for checking if device is online
final isOnlineProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityStreamProvider);

  return connectivity.when(
    data: (status) =>
        status != ConnectionType.noConnection &&
        status != ConnectionType.noInternet,
    loading: () => true, // Assume connected while checking
    error: (_, __) => false,
  );
});

/// Helper function to check actual internet access
Future<bool> _hasInternet() async {
  try {
    final result = await InternetAddress.lookup(
      "google.com",
    ).timeout(const Duration(seconds: 1));
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } catch (_) {
    return false;
  }
}

/// Helper function to determine connection type from connectivity results
ConnectionType _determineConnectionType(List<ConnectivityResult> results) {
  // Check connection types in priority order
  if (results.contains(ConnectivityResult.wifi)) {
    return ConnectionType.wifi;
  } else if (results.contains(ConnectivityResult.ethernet)) {
    return ConnectionType.ethernet;
  } else if (results.contains(ConnectivityResult.mobile)) {
    return ConnectionType.mobile;
  } else {
    return ConnectionType.noConnection;
  }
}

enum ConnectionType {
  noConnection, // No internet connection
  noInternet, // Connected to a network but no internet access
  mobile, // Connected via mobile data
  wifi, // Connected via WiFi
  ethernet, // Connected via Ethernet
}
