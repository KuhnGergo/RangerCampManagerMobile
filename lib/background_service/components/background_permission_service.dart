import 'package:geolocator/geolocator.dart';
import 'package:mastercs_mobile/background_service/components/tracking_profiles.dart';

class BackgroundPermissionService {
  Future<bool> isLocationServiceEnabled() {
    return Geolocator.isLocationServiceEnabled();
  }

  Future<bool> canTrack(TrackingMode mode) async {
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }

    if (mode == TrackingMode.background) {
      return permission == LocationPermission.always;
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }
}
