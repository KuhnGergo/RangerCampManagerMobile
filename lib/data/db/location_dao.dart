import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/schema/app_database.dart';
import '../../core/schema/tables/locations_table.dart';

part 'location_dao.g.dart';

final locationDaoProvider = Provider<LocationDao>(
  (ref) => LocationDao(ref.read(databaseProvider)),
);

@DriftAccessor(tables: [Locations])
class LocationDao extends DatabaseAccessor<AppDatabase>
    with _$LocationDaoMixin {
  LocationDao(super.db);

  LocationsCompanion toCompanion({
    required String userRemoteId,
    required String campRemoteId,
    required double longitude,
    required double latitude,
    DateTime? lastUpdated,
  }) {
    return LocationsCompanion(
      userRemoteId: Value(userRemoteId),
      campRemoteId: Value(campRemoteId),
      longitude: Value(longitude),
      latitude: Value(latitude),
      lastUpdated: Value(lastUpdated),
    );
  }

  /// Delete locations based on camp ID
  Future<int> deleteLocationsByCampId(String campRemoteId) {
    return (delete(
      locations,
    )..where((l) => l.campRemoteId.equals(campRemoteId))).go();
  }

  /// Upsert single location
  Future<void> upsertLocation(Location location) {
    return into(locations).insertOnConflictUpdate(location);
  }

  /// Upsert multiple locations by camp
  Future<void> upsertLocationsByCamp(List<Location> locationList) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(locations, locationList);
    });
  }

  /// Get all locations for a camp (one-shot query)
  Future<List<Location>> getLocationsByCamp(String campRemoteId) {
    return (select(
      locations,
    )..where((l) => l.campRemoteId.equals(campRemoteId))).get();
  }

  /// Watch locations by camp ID
  Stream<List<Location>> watchLocationsByCamp(String campRemoteId) {
    return (select(
      locations,
    )..where((l) => l.campRemoteId.equals(campRemoteId))).watch();
  }

  /// Get location by user and camp IDs
  Future<Location?> getLocationByUserAndCamp(
    String userRemoteId,
    String campRemoteId,
  ) {
    return (select(locations)
          ..where((l) => l.userRemoteId.equals(userRemoteId))
          ..where((l) => l.campRemoteId.equals(campRemoteId)))
        .getSingleOrNull();
  }

  Future<List<Location>> getLocationsByUserId(String userRemoteId) {
    return (select(
      locations,
    )..where((l) => l.userRemoteId.equals(userRemoteId))).get();
  }

  /// Watch location by user and camp IDs (reactive stream)
  Stream<Location?> watchLocationByUserAndCamp(
    String userRemoteId,
    String campRemoteId,
  ) {
    return (select(locations)
          ..where((l) => l.userRemoteId.equals(userRemoteId))
          ..where((l) => l.campRemoteId.equals(campRemoteId)))
        .watchSingleOrNull();
  }
}
