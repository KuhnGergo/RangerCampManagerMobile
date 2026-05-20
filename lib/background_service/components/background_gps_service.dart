import 'dart:async';
import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:mastercs_mobile/background_service/components/tracking_profiles.dart';

typedef PositionCallback = void Function(Position position);
typedef ErrorCallback = void Function(Object error);
typedef DoneCallback = void Function();

class BackgroundGpsService {
  StreamSubscription<Position>? _positionSub;
  TrackingProfile? _profile;

  bool get isRunning => _positionSub != null;

  Future<void> start({
    required TrackingProfile profile,
    required PositionCallback onPosition,
    required ErrorCallback onError,
    required DoneCallback onDone,
  }) async {
    if (_positionSub != null && _profile != null && _profile!.sameAs(profile)) {
      return;
    }

    await stop();

    final settings = _buildSettings(profile);
    _profile = profile;
    _positionSub = Geolocator.getPositionStream(
      locationSettings: settings,
    ).listen(onPosition, onError: (Object e) => onError(e), onDone: onDone);
  }

  Future<void> updateProfile({
    required TrackingProfile profile,
    required PositionCallback onPosition,
    required ErrorCallback onError,
    required DoneCallback onDone,
  }) {
    return start(
      profile: profile,
      onPosition: onPosition,
      onError: onError,
      onDone: onDone,
    );
  }

  Future<void> stop() async {
    await _positionSub?.cancel();
    _positionSub = null;
    _profile = null;
  }

  LocationSettings _buildSettings(TrackingProfile profile) {
    final effectiveDistanceFilter = profile.useSignificantChanges
        ? (profile.distanceFilter < 500 ? 500 : profile.distanceFilter)
        : profile.distanceFilter;
    final effectiveInterval = profile.useSignificantChanges
        ? const Duration(minutes: 5)
        : profile.interval;

    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: profile.accuracy,
        distanceFilter: effectiveDistanceFilter,
        intervalDuration: effectiveInterval,
      );
    }

    if (Platform.isIOS) {
      return AppleSettings(
        accuracy: profile.accuracy,
        distanceFilter: effectiveDistanceFilter,
        activityType: profile.iosActivityType,
        pauseLocationUpdatesAutomatically:
            profile.pauseLocationUpdatesAutomatically,
        allowBackgroundLocationUpdates: true,
        showBackgroundLocationIndicator: false,
      );
    }

    return LocationSettings(
      accuracy: profile.accuracy,
      distanceFilter: effectiveDistanceFilter,
    );
  }
}
