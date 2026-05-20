import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/data/db/location_dao.dart';
import 'package:mastercs_mobile/providers/data/selected_camp_id_provider.dart';

/// Provider that polls user locations for the selected camp.
///
/// Polling is required because the background service runs in a separate Dart
/// isolate with its own [AppDatabase] instance. Drift's reactive streams only
/// fire for writes made through the *same* connection, so cross-isolate
/// SQLite writes are invisible to watch-based streams on the main isolate.
final userLocationsProvider = StreamProvider.autoDispose<List<Location>>((
  ref,
) async* {
  final campId = ref
      .watch(selectedCampIdProvider)
      .maybeWhen(data: (id) => id, orElse: () => null);

  if (campId == null) {
    yield [];
    return;
  }

  final dao = ref.read(locationDaoProvider);
  while (true) {
    final locations = await dao.getLocationsByCamp(campId);
    yield locations;
    await Future.delayed(const Duration(seconds: 3));
  }
});
