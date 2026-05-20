import 'package:geolocator/geolocator.dart';

enum TrackingMode { foreground, background }

enum TrackingStage {
  stationary,
  lowPowerMode,
  movementDetected,
  highAccuracyMode,
  fastVehicle,
  vehicleMode,
}

class TrackingProfile {
  final LocationAccuracy accuracy;
  final int distanceFilter;
  final Duration interval;
  final bool useSignificantChanges;
  final ActivityType iosActivityType;
  final bool pauseLocationUpdatesAutomatically;

  const TrackingProfile({
    required this.accuracy,
    required this.distanceFilter,
    required this.interval,
    required this.useSignificantChanges,
    required this.iosActivityType,
    required this.pauseLocationUpdatesAutomatically,
  });

  bool sameAs(TrackingProfile other) {
    return accuracy == other.accuracy &&
        distanceFilter == other.distanceFilter &&
        interval == other.interval &&
        useSignificantChanges == other.useSignificantChanges &&
        iosActivityType == other.iosActivityType &&
        pauseLocationUpdatesAutomatically ==
            other.pauseLocationUpdatesAutomatically;
  }
}

class TrackingProfiles {
  static TrackingProfile resolve({
    required TrackingMode mode,
    required TrackingStage stage,
  }) {
    if (mode == TrackingMode.background) {
      switch (stage) {
        case TrackingStage.stationary:
        case TrackingStage.lowPowerMode:
          return const TrackingProfile(
            accuracy: LocationAccuracy.low,
            distanceFilter: 250,
            interval: Duration(minutes: 2),
            useSignificantChanges: true,
            iosActivityType: ActivityType.other,
            pauseLocationUpdatesAutomatically: true,
          );
        case TrackingStage.movementDetected:
          return const TrackingProfile(
            accuracy: LocationAccuracy.medium,
            distanceFilter: 80,
            interval: Duration(seconds: 40),
            useSignificantChanges: false,
            iosActivityType: ActivityType.fitness,
            pauseLocationUpdatesAutomatically: false,
          );
        case TrackingStage.highAccuracyMode:
          return const TrackingProfile(
            accuracy: LocationAccuracy.high,
            distanceFilter: 35,
            interval: Duration(seconds: 15),
            useSignificantChanges: false,
            iosActivityType: ActivityType.fitness,
            pauseLocationUpdatesAutomatically: false,
          );
        case TrackingStage.fastVehicle:
        case TrackingStage.vehicleMode:
          return const TrackingProfile(
            accuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 120,
            interval: Duration(seconds: 6),
            useSignificantChanges: false,
            iosActivityType: ActivityType.automotiveNavigation,
            pauseLocationUpdatesAutomatically: false,
          );
      }
    }

    switch (stage) {
      case TrackingStage.stationary:
      case TrackingStage.lowPowerMode:
        return const TrackingProfile(
          accuracy: LocationAccuracy.medium,
          distanceFilter: 12,
          interval: Duration(seconds: 12),
          useSignificantChanges: false,
          iosActivityType: ActivityType.other,
          pauseLocationUpdatesAutomatically: true,
        );
      case TrackingStage.movementDetected:
      case TrackingStage.highAccuracyMode:
        return const TrackingProfile(
          accuracy: LocationAccuracy.best,
          distanceFilter: 5,
          interval: Duration(seconds: 3),
          useSignificantChanges: false,
          iosActivityType: ActivityType.fitness,
          pauseLocationUpdatesAutomatically: false,
        );
      case TrackingStage.fastVehicle:
      case TrackingStage.vehicleMode:
        return const TrackingProfile(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 20,
          interval: Duration(seconds: 2),
          useSignificantChanges: false,
          iosActivityType: ActivityType.automotiveNavigation,
          pauseLocationUpdatesAutomatically: false,
        );
    }
  }
}
