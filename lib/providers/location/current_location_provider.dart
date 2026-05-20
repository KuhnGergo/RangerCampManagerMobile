import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:mastercs_mobile/data/db/location_dao.dart';
import 'package:mastercs_mobile/providers/auth/auth_provider.dart';
import 'package:mastercs_mobile/providers/data/selected_camp_id_provider.dart';

/// Provides the current user's location by polling the local database.
///
/// Polling is required because the background service runs in a separate Dart
/// isolate with its own [AppDatabase] instance. Drift's reactive streams only
/// fire for writes made through the *same* connection, so cross-isolate
/// SQLite writes are invisible to watch-based streams on the main isolate.
final currentLocationProvider = StreamProvider<LatLng?>((ref) async* {
  // Watch auth so this stream is rebuilt once login completes.
  final isLoggedIn = ref.watch(authProvider).value ?? false;
  final userId = isLoggedIn ? ref.read(authProvider.notifier).getUserId : null;
  final selectedCampId = ref.watch(selectedCampIdProvider).value;

  if (userId == null || selectedCampId == null) {
    yield null;
    return;
  }

  final dao = ref.read(locationDaoProvider);
  while (true) {
    final location = await dao.getLocationByUserAndCamp(userId, selectedCampId);
    yield location != null
        ? LatLng(location.latitude, location.longitude)
        : null;
    await Future.delayed(const Duration(seconds: 3));
  }
});
