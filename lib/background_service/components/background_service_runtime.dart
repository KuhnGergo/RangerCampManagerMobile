import 'dart:async';
import 'dart:developer' as dev;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mastercs_mobile/background_service/components/background_credentials.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/data/db/location_dao.dart';
import 'package:mastercs_mobile/background_service/components/background_adaptive_tracking_controller.dart';
import 'package:mastercs_mobile/background_service/components/background_activity_service.dart';
import 'package:mastercs_mobile/background_service/components/background_connectivity_service.dart';
import 'package:mastercs_mobile/background_service/components/background_gps_service.dart';
import 'package:mastercs_mobile/background_service/components/background_http_service.dart';
import 'package:mastercs_mobile/background_service/components/background_local_database_service.dart';
import 'package:mastercs_mobile/background_service/components/background_permission_service.dart';
import 'package:mastercs_mobile/background_service/components/tracking_profiles.dart';

/// Create the Android notification channel that the background service
/// foreground notification will be posted to. Must be called before
/// [initializeBackgroundLocationService] so the channel exists when Android
/// binds to the service on restart.
Future<void> initializeNotificationChannels() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'background_location',
    'Background Location',
    description: 'Used for location tracking',
    importance: Importance.low,
    showBadge: false,
  );
  await FlutterLocalNotificationsPlugin()
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);
}

/// Initialize and configure the background location service.
/// Call once during app startup.
Future<void> initializeBackgroundLocationService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onBackgroundServiceStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: 'background_location',
      initialNotificationTitle: 'Location Tracking',
      initialNotificationContent: 'Tracking location in background',
      foregroundServiceNotificationId: 888,
      foregroundServiceTypes: [AndroidForegroundType.location],
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onBackgroundServiceStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

final _runtime = _BackgroundServiceRuntime();

@pragma('vm:entry-point')
void onBackgroundServiceStart(ServiceInstance service) async {
  // Avoid plugin auto-registration in Android background isolate because
  // flutter_background_service_android is main-isolate only.
  if (service is! AndroidServiceInstance) {
    DartPluginRegistrant.ensureInitialized();
  }
  await _runtime.start(service);
}

class _BackgroundServiceRuntime {
  final _httpService = BackgroundHttpService();
  final _permissionService = BackgroundPermissionService();
  final _connectivityService = BackgroundConnectivityService();
  final _gpsService = BackgroundGpsService();
  final _activityService = BackgroundActivityService();
  final _adaptiveController = AdaptiveTrackingController();

  late final BackgroundLocalDatabaseService _localDatabaseService;

  Credentials? _creds;
  bool _isForeground = false;
  Timer? _watchdog;
  Timer? _retryTimer;
  bool _initialized = false;
  bool _handlersBound = false;
  int _retryAttempt = 0;
  String? _lastPauseReason;
  DateTime? _lastPauseLogAt;

  Future<void> start(ServiceInstance service) async {
    if (!_initialized) {
      _localDatabaseService = BackgroundLocalDatabaseService(
        LocationDao(AppDatabase.instance),
      );
      await _loadCredentials();
      _initialized = true;
    }

    if (!_handlersBound) {
      _bindServiceEvents(service);
      _handlersBound = true;
    }
    await _startOrUpdateTracking();
  }

  Future<void> _loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    _creds = Credentials(
      userId: prefs.getString(kUserIdKey) ?? '',
      campId: prefs.getString(kCampIdKey) ?? '',
      token: prefs.getString(kTokenKey) ?? '',
      serverUrl: prefs.getString(kServerUrlKey) ?? '',
    );

    _httpService.updateCredentials(
      baseUrl: _creds!.serverUrl,
      token: _creds!.token,
    );
  }

  void _bindServiceEvents(ServiceInstance service) {
    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((_) {
        service.setAsForegroundService();
      });
      service.on('setAsBackground').listen((_) {
        service.setAsBackgroundService();
      });
    }

    service.on('stopService').listen((_) async {
      await _stopTracking(cancelRetry: true);
      _httpService.dispose();
      service.stopSelf();
    });

    service.on('updateCredentials').listen((event) async {
      if (event == null || _creds == null) return;
      final prefs = await SharedPreferences.getInstance();

      if (event['userId'] != null) {
        _creds!.userId = event['userId'] as String;
        await prefs.setString(kUserIdKey, _creds!.userId);
      }
      if (event['campId'] != null) {
        _creds!.campId = event['campId'] as String;
        await prefs.setString(kCampIdKey, _creds!.campId);
      }
      if (event['token'] != null) {
        _creds!.token = event['token'] as String;
        await prefs.setString(kTokenKey, _creds!.token);
      }
      if (event['serverUrl'] != null) {
        _creds!.serverUrl = event['serverUrl'] as String;
        await prefs.setString(kServerUrlKey, _creds!.serverUrl);
      }

      _httpService.updateCredentials(
        baseUrl: _creds!.serverUrl,
        token: _creds!.token,
      );

      await _startOrUpdateTracking();
    });

    service.on('setProfile').listen((event) async {
      final wasForeground = _isForeground;
      _isForeground = event?['isForeground'] as bool? ?? false;
      dev.log(
        'Background service: profile -> ${_isForeground ? "foreground" : "background"}',
        name: 'BgLocationService',
      );

      if (wasForeground != _isForeground) {
        await _startOrUpdateTracking();
      }
    });
  }

  TrackingMode get _mode =>
      _isForeground ? TrackingMode.foreground : TrackingMode.background;

  Future<void> _startOrUpdateTracking() async {
    final creds = _creds;
    if (creds == null || !creds.canTrack) {
      await _stopTracking(cancelRetry: true);
      return;
    }

    final mode = _mode;
    final serviceEnabled = await _permissionService.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await _pauseAndRetry(
        reason: 'Location service is disabled on device',
        minDelay: const Duration(seconds: 30),
      );
      return;
    }

    final canTrack = await _permissionService.canTrack(mode);
    if (!canTrack) {
      await _pauseAndRetry(
        reason: 'Tracking paused due to missing permission for mode $mode',
        minDelay: const Duration(seconds: 30),
      );
      return;
    }

    _retryTimer?.cancel();
    _retryTimer = null;
    _retryAttempt = 0;

    final profile = _adaptiveController.currentProfile(mode);
    await _gpsService.updateProfile(
      profile: profile,
      onPosition: _onPosition,
      onError: _onStreamError,
      onDone: _onStreamDone,
    );

    _startWatchdog();
  }

  Future<void> _pauseAndRetry({
    required String reason,
    required Duration minDelay,
  }) async {
    await _stopTracking();
    _logPaused(reason);
    _scheduleRetry(minDelay: minDelay);
  }

  void _scheduleRetry({required Duration minDelay}) {
    if (_retryTimer != null) return;

    const maxDelaySeconds = 120;
    final exponentialSeconds = 30 * (1 << _retryAttempt.clamp(0, 3));
    final delay = Duration(
      seconds: exponentialSeconds > maxDelaySeconds
          ? maxDelaySeconds
          : exponentialSeconds,
    );
    final effectiveDelay = delay < minDelay ? minDelay : delay;

    _retryAttempt = (_retryAttempt + 1).clamp(0, 10);
    _retryTimer = Timer(effectiveDelay, () async {
      _retryTimer = null;
      await _startOrUpdateTracking();
    });
  }

  void _logPaused(String reason) {
    final now = DateTime.now();
    final shouldLog =
        _lastPauseReason != reason ||
        _lastPauseLogAt == null ||
        now.difference(_lastPauseLogAt!) > const Duration(seconds: 30);

    if (!shouldLog) return;

    _lastPauseReason = reason;
    _lastPauseLogAt = now;
    dev.log(reason, name: 'BgLocationService');
  }

  void _startWatchdog() {
    _watchdog?.cancel();
    // Use one-shot timer instead of periodic to reduce CPU usage.
    // Timer only fires if no position update arrives within threshold.
    _watchdog = Timer(const Duration(minutes: kWatchdogThresholdMinutes), () {
      dev.log(
        'Watchdog fired - restarting GPS stream',
        name: 'BgLocationService',
      );
      _restartTrackingFromFailure('Watchdog timeout without new position');
    });
  }

  Future<void> _restartTrackingFromFailure(String reason) async {
    await _gpsService.stop();
    await _pauseAndRetry(reason: reason, minDelay: const Duration(seconds: 8));
  }

  bool _looksLikeLocationDisabledError(String message) {
    final value = message.toLowerCase();
    return value.contains('location service on the device is disabled') ||
        value.contains('location services are disabled') ||
        value.contains('service disabled');
  }

  bool _looksLikeMultipleEngineError(String message) {
    final value = message.toLowerCase();
    return value.contains('another flutter engine connected') ||
        value.contains('only be used in the main isolate');
  }

  Future<void> _stopTracking({bool cancelRetry = false}) async {
    _watchdog?.cancel();
    _watchdog = null;
    if (cancelRetry) {
      _retryTimer?.cancel();
      _retryTimer = null;
      _retryAttempt = 0;
    }
    await _gpsService.stop();
  }

  Future<void> _onPosition(Position position) async {
    // Reset watchdog timer on each position update
    _watchdog?.cancel();
    _watchdog = Timer(const Duration(minutes: kWatchdogThresholdMinutes), () {
      dev.log(
        'Watchdog fired - restarting GPS stream',
        name: 'BgLocationService',
      );
      _restartTrackingFromFailure('Watchdog timeout without new position');
    });

    final activity = _activityService.detect(position);
    if (_adaptiveController.updateWithActivity(
      mode: _mode,
      activity: activity,
    )) {
      await _gpsService.updateProfile(
        profile: _adaptiveController.currentProfile(_mode),
        onPosition: _onPosition,
        onError: _onStreamError,
        onDone: _onStreamDone,
      );
    }

    final creds = _creds;
    if (creds == null || !creds.canTrack) return;

    try {
      if (_mode == TrackingMode.foreground) {
        await _localDatabaseService.saveLocation(
          userId: creds.userId,
          campId: creds.campId,
          latitude: position.latitude,
          longitude: position.longitude,
        );

        await _httpService.sendLocation(
          campId: creds.campId,
          latitude: position.latitude,
          longitude: position.longitude,
        );
      } else {
        final online = await _connectivityService.hasInternet();
        if (!online) {
          dev.log(
            'Background mode: offline, skipping location send',
            name: 'BgLocationService',
          );
          return;
        }

        await _httpService.sendLocation(
          campId: creds.campId,
          latitude: position.latitude,
          longitude: position.longitude,
        );
      }
    } catch (e) {
      dev.log('Position handling error: $e', name: 'BgLocationService');
    }
  }

  void _onStreamError(Object error) {
    final message = error.toString();

    if (_looksLikeLocationDisabledError(message)) {
      _handleDisabledLocationError(message);
      return;
    }

    if (_looksLikeMultipleEngineError(message)) {
      _pauseAndRetry(
        reason: 'Engine state mismatch detected: $message',
        minDelay: const Duration(seconds: 45),
      );
      return;
    }

    _restartTrackingFromFailure('Position stream error: $message');
  }

  void _onStreamDone() {
    _restartTrackingFromFailure('Position stream closed');
  }

  Future<void> _handleDisabledLocationError(String originalMessage) async {
    final enabled = await _permissionService.isLocationServiceEnabled();
    if (!enabled) {
      await _pauseAndRetry(
        reason: 'Location service is disabled on device',
        minDelay: const Duration(seconds: 60),
      );
      return;
    }

    await _pauseAndRetry(
      reason:
          'Geolocator reported disabled while system says enabled: $originalMessage',
      minDelay: const Duration(seconds: 45),
    );
  }
}
