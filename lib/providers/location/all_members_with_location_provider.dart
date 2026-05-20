import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mastercs_mobile/models/member.dart';
import 'package:mastercs_mobile/models/roles.dart';
import 'package:mastercs_mobile/providers/auth/auth_provider.dart';
import 'package:mastercs_mobile/providers/data/camp_members_list_provider.dart';
import 'package:mastercs_mobile/providers/location/user_locations_provider.dart';

/// Joins camp members with their location data,
/// and calculates distance from the current user's position.
/// Returns sorted by distance ascending (members without location at the end).
final allMembersWithLocationProvider =
    Provider.autoDispose<AsyncValue<List<Member>>>((ref) {
      final membersAsync = ref.watch(campMembersListProvider);
      final locationsAsync = ref.watch(userLocationsProvider);

      return membersAsync.when(
        loading: () => const AsyncValue.loading(),
        error: (e, s) => AsyncValue.error(e, s),
        data: (members) => locationsAsync.when(
          loading: () => const AsyncValue.loading(),
          error: (e, s) => AsyncValue.error(e, s),
          data: (locations) {
            final userId = ref.read(authProvider.notifier).getUserId;

            final locationMap = {
              for (final loc in locations) loc.userRemoteId: loc,
            };
            final currentUserLocation = userId != null
                ? locationMap[userId]
                : null;

            final result = members
                .where((member) => member.role != Role.pending.stringName)
                .map((member) {
                  final location = locationMap[member.userRemoteId];
                  double? distanceInMeters;
                  if (currentUserLocation != null && location != null) {
                    distanceInMeters = Geolocator.distanceBetween(
                      currentUserLocation.latitude,
                      currentUserLocation.longitude,
                      location.latitude,
                      location.longitude,
                    );
                  }
                  return member.copyWith(
                    lastLocation: location,
                    distanceInMeters: distanceInMeters,
                  );
                })
                .toList();

            result.sort((a, b) {
              if (a.distanceInMeters == null && b.distanceInMeters == null) {
                return 0;
              }
              if (a.distanceInMeters == null) return 1;
              if (b.distanceInMeters == null) return -1;
              return a.distanceInMeters!.compareTo(b.distanceInMeters!);
            });

            return AsyncValue.data(result);
          },
        ),
      );
    });
