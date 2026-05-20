import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:mastercs_mobile/models/member.dart';
import 'package:mastercs_mobile/providers/auth/auth_provider.dart';
import 'package:mastercs_mobile/providers/location/current_location_provider.dart';
import 'package:mastercs_mobile/providers/location/filtered_members_with_location_provider.dart';
import 'package:mastercs_mobile/providers/location/layer_provider.dart';
import 'package:flutter_map/flutter_map.dart' as map;
import 'dart:async';

final mapControllerProvider = NotifierProvider<MapController, MapState>(
  () => MapController(),
);

class MapController extends Notifier<MapState> {
  map.MapController? _controller;
  Timer? _cameraAnimationTimer;
  Timer? _rotationAnimationTimer;

  @override
  MapState build() {
    initializeLocation();

    // Watch current location for real-time updates
    ref.listen(currentLocationProvider, (previous, next) {
      next.whenData((location) {
        if (location == null) return;

        state = state.copyWith(currentLocation: location);

        // When following self, use the fast current-location stream.
        if (state.isFollowMode && _controller != null && _isFollowingSelf()) {
          _animateCameraTo(location, zoom: _controller!.camera.zoom);
        }
      });
    });

    // Keep followed member data fresh and default to current user when possible.
    ref.listen(filteredMembersWithLocationProvider, (previous, next) {
      next.whenData((members) {
        final userId = ref.read(authProvider.notifier).getUserId;
        final currentFollowedId = state.followedMember?.userRemoteId;
        Member? resolvedFollowed;

        if (currentFollowedId != null) {
          resolvedFollowed = members
              .where((m) => m.userRemoteId == currentFollowedId)
              .firstOrNull;
        }

        resolvedFollowed ??= userId != null
            ? members.where((m) => m.userRemoteId == userId).firstOrNull
            : null;

        final wasUnset = state.followedMember == null;
        final idChanged =
            state.followedMember?.userRemoteId !=
            resolvedFollowed?.userRemoteId;
        final positionChanged =
            state.followedMember?.position != resolvedFollowed?.position;

        if (wasUnset || idChanged || positionChanged) {
          state = state.copyWith(followedMember: resolvedFollowed);
        }

        if (state.isFollowMode && resolvedFollowed?.position != null) {
          _animateCameraTo(resolvedFollowed!.position!, zoom: state.zoom);
        }
      });
    });

    // Listen for layer changes and clamp zoom to new layer's boundaries
    ref.listen(layerProvider, (previous, next) {
      final maxZoom = next.maxZoom;
      if (state.zoom > maxZoom) {
        if (_controller != null) {
          final clampedZoom = state.zoom.clamp(6.0, maxZoom);
          _controller!.move(_controller!.camera.center, clampedZoom);
          state = state.copyWith(zoom: clampedZoom);
        }
      }
    });

    ref.onDispose(() {
      _cameraAnimationTimer?.cancel();
      _rotationAnimationTimer?.cancel();
    });

    // Get initial layer to clamp default zoom to its boundaries
    final initialLayer = ref.read(layerProvider);
    final initialZoom = 15.0.clamp(6.0, initialLayer.maxZoom);

    return MapState(zoom: initialZoom);
  }

  bool _isFollowingSelf() {
    final myUserId = ref.read(authProvider.notifier).getUserId;
    return myUserId != null && state.followedMember?.userRemoteId == myUserId;
  }

  map.MapController get mapController {
    _controller ??= map.MapController();
    return _controller!;
  }

  Future<void> initializeLocation() async {
    // Get initial location from tracking service
    final location = await ref.read(currentLocationProvider.future);

    state = state.copyWith(isLoading: false, currentLocation: location);

    // Only move camera if controller is initialized and ready
    if (state.currentLocation != null && _controller != null) {
      try {
        _controller?.move(state.currentLocation!, 15.0);
      } catch (e) {
        // MapController not ready yet, will be centered when map renders
      }
    }
  }

  void zoomIn() {
    if (_controller != null) {
      final maxZoom = ref.read(layerProvider).maxZoom;
      final newZoom = (state.zoom + 1).clamp(6.0, maxZoom);
      _controller!.move(_controller!.camera.center, newZoom);
      state = state.copyWith(zoom: newZoom);
    }
  }

  void zoomOut() {
    if (_controller != null) {
      final maxZoom = ref.read(layerProvider).maxZoom;
      final newZoom = (state.zoom - 1).clamp(6.0, maxZoom);
      _controller!.move(_controller!.camera.center, newZoom);
      state = state.copyWith(zoom: newZoom);
    }
  }

  void setZoom(double zoom) {
    if (_controller != null) {
      final maxZoom = ref.read(layerProvider).maxZoom;
      final clampedZoom = zoom.clamp(6.0, maxZoom);
      _controller!.move(_controller!.camera.center, clampedZoom);
      state = state.copyWith(zoom: clampedZoom);
    }
  }

  void toggleFollowMode() {
    final nextMode = !state.isFollowMode;
    state = state.copyWith(isFollowMode: nextMode);

    if (nextMode) {
      focusOnFollowedMember(animated: true);
    }
  }

  void setFollowMode(bool isFollowMode) {
    if (state.isFollowMode == isFollowMode) return;

    state = state.copyWith(isFollowMode: isFollowMode);
    if (isFollowMode) {
      focusOnFollowedMember(animated: true);
    }
  }

  void setFollowedMember(Member member, {bool animated = true}) {
    state = state.copyWith(followedMember: member, isFollowMode: true);

    if (animated) {
      focusOnFollowedMember(animated: true);
    }
  }

  void clearFollowedMember() {
    state = state.copyWith(isFollowMode: false, followedMember: null);
  }

  void followMyUser({bool animated = true}) {
    final myUserId = ref.read(authProvider.notifier).getUserId;
    if (myUserId == null) return;

    final members =
        ref.read(filteredMembersWithLocationProvider).value ?? const <Member>[];
    final myMember = members
        .where((m) => m.userRemoteId == myUserId)
        .firstOrNull;
    if (myMember == null) return;

    setFollowedMember(myMember, animated: animated);
  }

  void focusOnFollowedMember({bool animated = false}) {
    final target = state.followedMember?.position;
    if (_controller == null || target == null) return;

    if (animated) {
      _animateCameraTo(target, zoom: state.zoom);
    } else {
      _controller!.move(target, state.zoom);
    }
  }

  void focusOnCurrentLocation({bool animated = false}) {
    if (_controller == null || state.currentLocation == null) return;

    if (animated) {
      _animateCameraTo(state.currentLocation!, zoom: state.zoom);
    } else {
      _controller!.move(state.currentLocation!, state.zoom);
    }
  }

  void resetRotation() {
    final controller = _controller;
    if (controller == null) return;

    _rotationAnimationTimer?.cancel();

    final from = controller.camera.rotation;
    final delta = _shortestAngleDelta(from, 0.0);
    if (delta.abs() < 0.1) {
      controller.rotate(0.0);
      state = state.copyWith(rotation: 0.0);
      return;
    }

    const steps = 14;
    var currentStep = 0;

    _rotationAnimationTimer = Timer.periodic(const Duration(milliseconds: 16), (
      timer,
    ) {
      currentStep++;
      final t = (currentStep / steps).clamp(0.0, 1.0);
      final eased = Curves.easeOut.transform(t);
      final nextRotation = from + (delta * eased);

      try {
        controller.rotate(nextRotation);
        state = state.copyWith(rotation: nextRotation);
      } catch (_) {
        timer.cancel();
      }

      if (currentStep >= steps) {
        controller.rotate(0.0);
        state = state.copyWith(rotation: 0.0);
        timer.cancel();
      }
    });
  }

  double _shortestAngleDelta(double from, double to) {
    var delta = (to - from) % 360.0;
    if (delta > 180.0) delta -= 360.0;
    if (delta < -180.0) delta += 360.0;
    return delta;
  }

  void updateZoomFromCamera() {
    if (_controller != null) {
      state = state.copyWith(zoom: _controller!.camera.zoom);
    }
  }

  void updateRotationFromCamera() {
    if (_controller != null) {
      state = state.copyWith(rotation: _controller!.camera.rotation);
    }
  }

  void animateToPosition(LatLng position, {double? zoom}) {
    if (_controller == null) return;
    _animateCameraTo(position, zoom: zoom ?? state.zoom);
  }

  void _animateCameraTo(LatLng target, {required double zoom}) {
    final controller = _controller;
    if (controller == null) return;

    _cameraAnimationTimer?.cancel();

    final from = controller.camera.center;
    final fromZoom = controller.camera.zoom;
    final steps = 14;
    var currentStep = 0;

    _cameraAnimationTimer = Timer.periodic(const Duration(milliseconds: 16), (
      timer,
    ) {
      currentStep++;
      final t = (currentStep / steps).clamp(0.0, 1.0);
      final eased = Curves.easeOut.transform(t);
      final nextCenter = LatLng(
        from.latitude + (target.latitude - from.latitude) * eased,
        from.longitude + (target.longitude - from.longitude) * eased,
      );
      final nextZoom = fromZoom + (zoom - fromZoom) * eased;

      try {
        controller.move(nextCenter, nextZoom);
      } catch (_) {
        timer.cancel();
      }

      if (currentStep >= steps) {
        timer.cancel();
      }
    });
  }
}

class MapState {
  final bool isLoading;
  final LatLng? currentLocation;
  final double zoom;
  final double rotation;
  final bool isFollowMode;
  final Member? followedMember;

  const MapState({
    this.isLoading = true,
    this.currentLocation,
    this.zoom = 15.0,
    this.rotation = 0.0,
    this.isFollowMode = false,
    this.followedMember,
  });

  static const _followedMemberUnchanged = Object();

  MapState copyWith({
    bool? isLoading,
    LatLng? currentLocation,
    double? zoom,
    double? rotation,
    bool? isFollowMode,
    Object? followedMember = _followedMemberUnchanged,
  }) {
    return MapState(
      isLoading: isLoading ?? this.isLoading,
      currentLocation: currentLocation ?? this.currentLocation,
      zoom: zoom ?? this.zoom,
      rotation: rotation ?? this.rotation,
      isFollowMode: isFollowMode ?? this.isFollowMode,
      followedMember: identical(followedMember, _followedMemberUnchanged)
          ? this.followedMember
          : followedMember as Member?,
    );
  }
}
