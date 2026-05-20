import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:mastercs_mobile/providers/auth/auth_provider.dart';
import 'package:mastercs_mobile/providers/location/cached_tile_provider.dart';
import 'package:mastercs_mobile/presentation/app/map/map_controller.dart';
import 'package:mastercs_mobile/providers/location/filtered_members_with_location_provider.dart';
import 'package:mastercs_mobile/providers/location/layer_provider.dart';
import 'package:mastercs_mobile/presentation/app/map/widgets/user_map_marker.dart';
import 'package:mastercs_mobile/presentation/app/map/widgets/animated_marker_layer.dart';
import 'package:mastercs_mobile/presentation/app/map/widgets/connection_error_indicator.dart';
import 'package:mastercs_mobile/presentation/app/map/widgets/location_permission_indicator.dart';
import 'package:mastercs_mobile/presentation/app/map/widgets/map_controls_column.dart';
import 'package:mastercs_mobile/presentation/app/map/widgets/zoom/zoom_slider_indicator.dart';
import 'package:mastercs_mobile/presentation/app/map/widgets/bottom_member_list/bottom_member_list.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(mapControllerProvider.notifier);
    final state = ref.watch(mapControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final membersAsync = ref.watch(filteredMembersWithLocationProvider);
    final myUserId = ref.watch(authProvider.notifier).getUserId;
    final layerUrl = ref.watch(currentLayerUrlProvider);
    final currentLayer = ref.watch(layerProvider);

    return Stack(
      children: [
        // Map
        FlutterMap(
          mapController: controller.mapController,
          options: MapOptions(
            initialCenter:
                state.currentLocation ??
                LatLng(47.49313781003843, 19.048471842660113),
            initialZoom: state.zoom,
            initialRotation: state.rotation,
            minZoom: 6.0,
            maxZoom: currentLayer.maxZoom,
            backgroundColor: colorScheme.surface,
            onPositionChanged: (position, hasGesture) {
              if (hasGesture) {
                controller.setFollowMode(false);
                controller.updateZoomFromCamera();
                controller.updateRotationFromCamera();
              }
            },
          ),
          children: [
            // Base tiles
            TileLayer(
              userAgentPackageName: 'mastercs_mobile_app',
              urlTemplate: layerUrl,
              tileProvider: CachedTileProvider(),
            ),

            // Other users' locations
            membersAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (e, st) => const SizedBox.shrink(),
              data: (members) {
                final followedId = state.followedMember?.userRemoteId;
                final normalEntries = <AnimatedMarkerEntry>[];
                AnimatedMarkerEntry? followedEntry;

                for (final member in members.where((m) => m.position != null)) {
                  final isFollowed =
                      followedId != null && member.userRemoteId == followedId;

                  final entry = AnimatedMarkerEntry(
                    id: member.userRemoteId,
                    point: member.position!,
                    width: isFollowed
                        ? UserMapMarker.recommendedMarkerWidth * 1.12
                        : UserMapMarker.recommendedMarkerWidth,
                    height: isFollowed
                        ? UserMapMarker.recommendedMarkerHeight * 1.12
                        : UserMapMarker.recommendedMarkerHeight,
                    alignment: Alignment.bottomCenter,
                    child: UserMapMarker(
                      member: member,
                      self: myUserId != null && member.userRemoteId == myUserId,
                      highlighted: isFollowed,
                    ),
                  );

                  if (isFollowed) {
                    followedEntry = entry;
                  } else {
                    normalEntries.add(entry);
                  }
                }

                if (followedEntry != null) {
                  normalEntries.add(followedEntry);
                }

                return AnimatedMarkerLayer(markers: normalEntries);
              },
            ),
          ],
        ),

        // Vignette overlay
        Theme.of(context).brightness == Brightness.light
            ? const SizedBox.shrink()
            : Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.8,
                        colors: [
                          Colors.transparent,
                          Colors.black.withAlpha(70),
                        ],
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

        // Status indicators (connection and permission)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConnectionErrorIndicator(),
                  const SizedBox(height: 8),
                  LocationPermissionIndicator(),
                ],
              ),
            ),
          ),
        ),

        // Map controls column (right side)
        Positioned(
          right: 8,
          top: 0,
          bottom: 120,
          child: const MapControlsColumn(),
        ),

        // Zoom slider indicator (left side, above bottom member list)
        Positioned(
          left: 8,
          bottom: 110,
          top: 10,
          child: SafeArea(child: const ZoomSliderIndicator()),
        ),

        // Bottom member list (quick list)
        Positioned(left: 0, right: 0, bottom: 0, child: const MapQuickList()),
      ],
    );
  }
}
