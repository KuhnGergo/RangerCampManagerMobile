import 'dart:developer' as dev;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/data/db/location_dao.dart';
import 'package:mastercs_mobile/core/socket/socket_service.dart';
import 'package:mastercs_mobile/models/socket/socket_connection_models.dart';
import 'package:mastercs_mobile/models/socket/location_models.dart';
import 'package:mastercs_mobile/providers/socket/socket_provider.dart';

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  final locationDao = ref.watch(locationDaoProvider);
  final socketService = ref.watch(socketServiceProvider);
  return LocationRepository(locationDao, socketService);
});

/// Repository that handles location operations with socket synchronization
class LocationRepository {
  final LocationDao _dao;
  final SocketService _socketService;

  LocationRepository(this._dao, this._socketService) {
    _listenToLocationUpdates();
    _listenToAuthenticatedLocations();
  }

  /// Start listening to locationUpdated socket events and upsert to database
  void _listenToLocationUpdates() {
    _socketService.locationUpdatedStream.listen((locationData) async {
      await _handleLocationUpdated(locationData);
    });
  }

  /// Listen to authenticated payload for initial location seeding
  void _listenToAuthenticatedLocations() {
    _socketService.authenticatedStream.listen((authenticatedData) async {
      await upsertLocationsFromAuthenticated(authenticatedData);
    });
  }

  /// Update location - saves to DAO and emits to socket
  Future<void> updateLocation({
    required String userId,
    required String campId,
    required String groupId,
    required double latitude,
    required double longitude,
  }) async {
    // Save to local database first
    final location = Location(
      userRemoteId: userId,
      campRemoteId: campId,
      latitude: latitude,
      longitude: longitude,
      lastUpdated: DateTime.now(),
    );
    await _dao.upsertLocation(location);

    // Then emit to socket for others
    _socketService.updateLocation(
      campId: campId,
      groupId: groupId,
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Handle location updated from socket - upsert to database
  Future<void> _handleLocationUpdated(LocationUpdatedData data) async {
    try {
      final updatedLocation = Location(
        userRemoteId: data.userId,
        campRemoteId: data.campId,
        latitude: data.latitude,
        longitude: data.longitude,
        lastUpdated: data.lastUpdated,
      );

      await _dao.upsertLocation(updatedLocation);
    } catch (e) {
      // Log error but don't rethrow to prevent breaking the stream
      dev.log('Error handling location update: $e', name: 'LocationRepository');
    }
  }

  /// Upsert initial location snapshot received during socket authentication.
  Future<void> upsertLocationsFromAuthenticated(
    AuthenticatedData authenticatedData,
  ) async {
    try {
      final locations = <Location>[];

      for (final campLocations in authenticatedData.locations) {
        for (final userLocation in campLocations.users) {
          locations.add(
            Location(
              userRemoteId: userLocation.userId,
              // FIXME: Temporary fix to handle cases where campId might be missing from the payload
              campRemoteId: userLocation.campId,
              latitude: userLocation.latitude,
              longitude: userLocation.longitude,
              lastUpdated: userLocation.lastUpdated,
            ),
          );
        }
      }

      if (locations.isNotEmpty) {
        await _dao.upsertLocationsByCamp(locations);
      }
    } catch (e) {
      dev.log('Error upserting authenticated locations: $e');
    }
  }

  /// Upsert locations for a specific camp
  Future<void> upsertLocationsByCamp(
    String campId,
    List<Location> locations,
  ) async {
    await _dao.upsertLocationsByCamp(locations);
  }

  /// Delete all locations for a camp
  Future<void> deleteLocationsByCamp(String campId) async {
    await _dao.deleteLocationsByCampId(campId);
  }

  /// Watch locations for a specific camp
  Stream<List<Location>> watchLocationsByCamp(String campId) {
    return _dao.watchLocationsByCamp(campId);
  }
}
