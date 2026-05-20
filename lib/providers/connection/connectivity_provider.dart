import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mastercs_mobile/providers/connection/internet_probe.dart';
import 'package:mastercs_mobile/providers/connection/status_enum.dart';

/// Provides the current internet connectivity status.
/// ### Use in the widget tree as:
/// ```dart
/// final status = ref.watch(connectivityProvider);
///
/// return status.when(
///   loading: () => const CustomFloatingToast('Checking connection…'),
///   error: (_, __) => const CustomFloatingToast('Connection error'),
///   data: (data) => data.isOnline ? const SizedBox.shrink() : const CustomFloatingToast('No internet connection'),
/// );
/// ```
/// Possible values are:
/// - InternetStatus.offline
/// - InternetStatus.mobile
/// - InternetStatus.wifi
/// - InternetStatus.ethernet
final connectivityProvider =
    AsyncNotifierProvider<ConnectivityNotifier, InternetStatus>(
      ConnectivityNotifier.new,
    );

class ConnectivityNotifier extends AsyncNotifier<InternetStatus> {
  late final Connectivity _connectivity;
  final _probe = InternetProbe();
  StreamSubscription? _sub;

  @override
  Future<InternetStatus> build() async {
    _connectivity = Connectivity();

    final initial = await _evaluate();
    _listen();

    ref.onDispose(() {
      _sub?.cancel();
    });

    return initial;
  }

  void _listen() {
    _sub = _connectivity.onConnectivityChanged.listen((_) async {
      state = const AsyncLoading();
      state = AsyncData(await _evaluate());
    });
  }

  Future<InternetStatus> _evaluate() async {
    final results = await _connectivity.checkConnectivity();

    final internet = _mapToInternet(results);
    if (internet == InternetStatus.offline) {
      return InternetStatus.offline;
    }

    final online = await _probe.hasInternet();
    if (!online) {
      return InternetStatus.offline;
    }

    return internet;
  }

  InternetStatus _mapToInternet(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.wifi)) {
      return InternetStatus.wifi;
    } else if (results.contains(ConnectivityResult.ethernet)) {
      return InternetStatus.ethernet;
    } else if (results.contains(ConnectivityResult.mobile)) {
      return InternetStatus.mobile;
    } else {
      return InternetStatus.offline;
    }
  }
}
