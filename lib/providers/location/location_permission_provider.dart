import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationPermissionState {
  final bool isServiceEnabled;
  final bool isWhileInUseGranted;
  final bool isAlwaysGranted;
  final bool isBatteryOptimizationIgnored;
  final bool isActivityRecognitionGranted;

  const LocationPermissionState({
    this.isServiceEnabled = false,
    this.isWhileInUseGranted = false,
    this.isAlwaysGranted = false,
    this.isBatteryOptimizationIgnored = false,
    this.isActivityRecognitionGranted = true,
  });

  /// Foreground tracking requires location service + "while in use" or "always"
  bool get canTrackForeground =>
      isServiceEnabled && (isWhileInUseGranted || isAlwaysGranted);

  /// Background tracking requires all of:
  /// - Location service enabled
  /// - Location permission set to "always"
  ///
  /// Activity recognition and battery optimization are optional optimizations.
  bool get canTrackBackground => isServiceEnabled && isAlwaysGranted;

  /// Check if all required background permissions are satisfied.
  /// Returns false if any core requirement is missing.
  bool get hasAllBackgroundRequirements => isServiceEnabled && isAlwaysGranted;
}

final locationPermissionProvider =
    AsyncNotifierProvider<LocationPermissionNotifier, LocationPermissionState>(
      LocationPermissionNotifier.new,
    );

class LocationPermissionNotifier
    extends AsyncNotifier<LocationPermissionState> {
  bool _shouldOpenSettings(PermissionStatus status) {
    return status.isPermanentlyDenied || status.isRestricted;
  }

  @override
  Future<LocationPermissionState> build() async {
    return _checkPermissions();
  }

  Future<LocationPermissionState> _checkPermissions() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    final permission = await Geolocator.checkPermission();

    final isAlways = permission == LocationPermission.always;
    final isWhileInUse =
        permission == LocationPermission.whileInUse || isAlways;

    final batteryOptimization = Platform.isAndroid
        ? await Permission.ignoreBatteryOptimizations.isGranted
        : true;

    final activityRecognition = Platform.isAndroid
        ? await Permission.activityRecognition.isGranted
        : true;

    return LocationPermissionState(
      isServiceEnabled: serviceEnabled,
      isWhileInUseGranted: isWhileInUse,
      isAlwaysGranted: isAlways,
      isBatteryOptimizationIgnored: batteryOptimization,
      isActivityRecognitionGranted: activityRecognition,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _checkPermissions());
  }

  /// Request basic "while in use" location permission.
  Future<bool> requestWhileInUse() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await refresh();
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    await refresh();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Request "always" location permission (needed for background tracking).
  Future<bool> requestAlways() async {
    // Ensure "while in use" is granted first (required before requesting always)
    if (!await Permission.locationWhenInUse.isGranted) {
      final result = await Permission.locationWhenInUse.request();
      if (!result.isGranted) {
        if (_shouldOpenSettings(result)) {
          await openAppSettings();
        }
        await refresh();
        return false;
      }
    }

    final status = await Permission.locationAlways.request();
    if (!status.isGranted && _shouldOpenSettings(status)) {
      await openAppSettings();
    }

    await refresh();
    return status.isGranted;
  }

  /// Request battery optimization exemption (Android only).
  Future<bool> requestBatteryOptimization() async {
    if (!Platform.isAndroid) return true;

    final status = await Permission.ignoreBatteryOptimizations.request();

    await refresh();
    return status.isGranted;
  }

  /// Request activity recognition permission (Android only).
  Future<bool> requestActivityRecognition() async {
    if (!Platform.isAndroid) return true;

    final status = await Permission.activityRecognition.request();
    await refresh();
    return status.isGranted;
  }

  /// Request required permissions for background tracking.
  ///
  /// Required:
  /// 1. Location permission set to "always"
  ///
  /// Optional optimizations (requested elsewhere):
  /// - Activity recognition (Android)
  /// - Battery optimization exemption (Android)
  ///
  /// Returns true when required background permissions are granted.
  Future<bool> requestAllBackgroundPermissions() async {
    // Request only required permission: location "always".
    if (!await requestAlways()) {
      return false;
    }

    // Refresh and verify all permissions are granted
    await refresh();
    final currentState = state.value;
    return currentState?.hasAllBackgroundRequirements ?? false;
  }
}
