import 'package:mastercs_mobile/background_service/components/background_activity_service.dart';
import 'package:mastercs_mobile/background_service/components/tracking_profiles.dart';

class AdaptiveTrackingController {
  TrackingStage _stage = TrackingStage.lowPowerMode;

  TrackingStage get stage => _stage;

  TrackingProfile currentProfile(TrackingMode mode) {
    return TrackingProfiles.resolve(mode: mode, stage: _stage);
  }

  bool updateWithActivity({
    required TrackingMode mode,
    required ActivitySnapshot activity,
  }) {
    final next = _nextStage(mode: mode, activity: activity);
    if (next == _stage) {
      return false;
    }
    _stage = next;
    return true;
  }

  TrackingStage _nextStage({
    required TrackingMode mode,
    required ActivitySnapshot activity,
  }) {
    switch (activity.activity) {
      case MotionActivity.stationary:
        return TrackingStage.lowPowerMode;
      case MotionActivity.moving:
        return mode == TrackingMode.foreground
            ? TrackingStage.highAccuracyMode
            : TrackingStage.movementDetected;
      case MotionActivity.fastVehicle:
        return TrackingStage.fastVehicle;
      case MotionActivity.vehicle:
        return TrackingStage.vehicleMode;
    }
  }
}
