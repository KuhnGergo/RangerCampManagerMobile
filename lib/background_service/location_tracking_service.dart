import 'dart:developer' as dev;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/background_service/components/background_location_manager.dart';
import 'package:mastercs_mobile/core/api/api_config.dart';
import 'package:mastercs_mobile/providers/auth/auth_provider.dart';
import 'package:mastercs_mobile/providers/data/selected_camp_id_provider.dart';
import 'package:mastercs_mobile/providers/location/location_permission_provider.dart';

final locationTrackingServiceProvider =
    NotifierProvider<LocationTrackingService, LocationTrackingState>(
      LocationTrackingService.new,
    );

class LocationTrackingState {
  final bool isRunning;

  const LocationTrackingState({this.isRunning = false});

  LocationTrackingState copyWith({bool? isRunning}) =>
      LocationTrackingState(isRunning: isRunning ?? this.isRunning);
}

/// Orchestrates GPS tracking by owning the background service lifecycle.
/// Switches between foreground and background GPS profiles when the app
/// moves between foreground and background — all actual GPS work, DB writes
/// and socket sends happen inside the background service isolate.
class LocationTrackingService extends Notifier<LocationTrackingState>
    with WidgetsBindingObserver {
  String? _currentCampId;
  bool _isAuthenticated = false;
  bool _syncScheduled = false;

  @override
  LocationTrackingState build() {
    // Seed current values because listeners fire only on change.
    _currentCampId = ref.read(selectedCampIdProvider).value;
    _isAuthenticated = ref.read(authProvider).value ?? false;

    ref.listen(selectedCampIdProvider, (_, next) {
      next.whenData((campId) {
        _currentCampId = campId;
        if (campId != null && state.isRunning) {
          BackgroundLocationManager.updateCredentials(campId: campId);
        }
        _scheduleSync();
      });
    });

    ref.listen(authProvider, (_, next) {
      next.whenData((loggedIn) {
        _isAuthenticated = loggedIn;

        if (loggedIn && state.isRunning) {
          final userId = ref.read(authProvider.notifier).getUserId;
          final token = ref.read(authProvider.notifier).getToken;
          if (userId != null && token != null) {
            BackgroundLocationManager.updateCredentials(
              userId: userId,
              token: token,
            );
          }
        }

        _scheduleSync();
      });
    });

    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
      stop();
    });

    _scheduleSync();

    return const LocationTrackingState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!this.state.isRunning) return;

    if (state == AppLifecycleState.resumed) {
      ref.read(locationPermissionProvider.notifier).refresh();
      BackgroundLocationManager.setProfile(isForeground: true);
    } else if (state == AppLifecycleState.paused) {
      BackgroundLocationManager.setProfile(isForeground: false);
    }
  }

  void _scheduleSync() {
    if (_syncScheduled) return;
    _syncScheduled = true;

    Future.microtask(() async {
      _syncScheduled = false;
      await _syncTracking();
    });
  }

  Future<void> _syncTracking() async {
    final campId = _currentCampId;
    if (!_isAuthenticated || campId == null || campId.isEmpty) {
      await stop();
      return;
    }

    final userId = ref.read(authProvider.notifier).getUserId;
    final token = ref.read(authProvider.notifier).getToken;
    if (userId == null || token == null) {
      await stop();
      return;
    }

    final serverUrl = ApiConfig.fromEnvironment().baseUrl;
    await BackgroundLocationManager.start(
      userId: userId,
      campId: campId,
      token: token,
      serverUrl: serverUrl,
    );

    final lifecycle = WidgetsBinding.instance.lifecycleState;
    final isForeground =
        lifecycle == null ||
        lifecycle == AppLifecycleState.resumed ||
        lifecycle == AppLifecycleState.inactive;
    BackgroundLocationManager.setProfile(isForeground: isForeground);

    if (!state.isRunning) {
      state = state.copyWith(isRunning: true);
    }
  }

  /// Ensures background tracking is running only when auth+camp are valid.
  Future<void> start() async {
    await _syncTracking();
  }

  Future<void> stop() async {
    await BackgroundLocationManager.stop();
    if (state.isRunning) {
      state = const LocationTrackingState();
    }
    dev.log('Location tracking stopped', name: 'LocationTracking');
  }
}
