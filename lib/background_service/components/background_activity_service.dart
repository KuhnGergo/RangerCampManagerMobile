import 'package:geolocator/geolocator.dart';

enum MotionActivity { stationary, moving, fastVehicle, vehicle }

class ActivitySnapshot {
  final MotionActivity activity;
  final double speedMps;

  const ActivitySnapshot({required this.activity, required this.speedMps});
}

/// Lightweight activity inference based on speed from GPS samples.
class BackgroundActivityService {
  ActivitySnapshot detect(Position position) {
    final speed = position.speed.isFinite && position.speed > 0
        ? position.speed
        : 0.0;

    if (speed < 0.7) {
      return const ActivitySnapshot(
        activity: MotionActivity.stationary,
        speedMps: 0,
      );
    }
    if (speed < 7.5) {
      return ActivitySnapshot(activity: MotionActivity.moving, speedMps: speed);
    }
    if (speed < 16.0) {
      return ActivitySnapshot(
        activity: MotionActivity.fastVehicle,
        speedMps: speed,
      );
    }
    return ActivitySnapshot(activity: MotionActivity.vehicle, speedMps: speed);
  }
}
