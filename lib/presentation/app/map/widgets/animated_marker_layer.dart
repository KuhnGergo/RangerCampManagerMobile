import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AnimatedMarkerEntry {
  final String id;
  final LatLng point;
  final double width;
  final double height;
  final Alignment alignment;
  final Widget child;

  const AnimatedMarkerEntry({
    required this.id,
    required this.point,
    required this.child,
    this.width = 80,
    this.height = 90,
    this.alignment = Alignment.bottomCenter,
  });
}

class AnimatedMarkerLayer extends StatefulWidget {
  final List<AnimatedMarkerEntry> markers;
  final Duration duration;

  const AnimatedMarkerLayer({
    super.key,
    required this.markers,
    this.duration = const Duration(milliseconds: 700),
  });

  @override
  State<AnimatedMarkerLayer> createState() => _AnimatedMarkerLayerState();
}

class _AnimatedMarkerLayerState extends State<AnimatedMarkerLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  final Map<String, AnimatedMarkerEntry> _entries = {};
  final Map<String, LatLng> _displayPoints = {};
  final Map<String, _PointTransition> _transitions = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..addListener(_onTick)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _finalizeTransitions();
        }
      });

    _seedInitialState(widget.markers);
  }

  @override
  void didUpdateWidget(covariant AnimatedMarkerLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    _syncMarkers(widget.markers);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onTick)
      ..dispose();
    super.dispose();
  }

  void _seedInitialState(List<AnimatedMarkerEntry> markers) {
    for (final marker in markers) {
      _entries[marker.id] = marker;
      _displayPoints[marker.id] = marker.point;
    }
  }

  void _syncMarkers(List<AnimatedMarkerEntry> markers) {
    final incoming = {for (final marker in markers) marker.id: marker};
    final incomingIds = incoming.keys.toSet();
    final existingIds = _entries.keys.toSet();

    // Remove markers that no longer exist.
    for (final removedId in existingIds.difference(incomingIds)) {
      _entries.remove(removedId);
      _displayPoints.remove(removedId);
      _transitions.remove(removedId);
    }

    bool needsAnimation = false;

    for (final entry in incoming.entries) {
      final id = entry.key;
      final marker = entry.value;
      final previousPoint = _displayPoints[id] ?? _entries[id]?.point;

      _entries[id] = marker;

      if (previousPoint == null) {
        _displayPoints[id] = marker.point;
        _transitions.remove(id);
        continue;
      }

      if (_samePoint(previousPoint, marker.point)) {
        _displayPoints[id] = marker.point;
        _transitions.remove(id);
        continue;
      }

      _transitions[id] = _PointTransition(
        from: previousPoint,
        to: marker.point,
      );
      needsAnimation = true;
    }

    if (needsAnimation) {
      _controller
        ..stop()
        ..reset()
        ..forward();
      setState(() {});
      return;
    }

    setState(() {});
  }

  void _onTick() {
    if (_transitions.isEmpty) return;

    final t = Curves.easeOut.transform(_controller.value);
    for (final entry in _transitions.entries) {
      _displayPoints[entry.key] = _lerpLatLng(
        entry.value.from,
        entry.value.to,
        t,
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _finalizeTransitions() {
    if (_transitions.isEmpty) return;

    for (final entry in _transitions.entries) {
      _displayPoints[entry.key] = entry.value.to;
    }
    _transitions.clear();
    if (mounted) {
      setState(() {});
    }
  }

  bool _samePoint(LatLng a, LatLng b) {
    return a.latitude == b.latitude && a.longitude == b.longitude;
  }

  LatLng _lerpLatLng(LatLng from, LatLng to, double t) {
    return LatLng(
      from.latitude + (to.latitude - from.latitude) * t,
      from.longitude + (to.longitude - from.longitude) * t,
    );
  }

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>[];

    for (final markerEntry in widget.markers) {
      final id = markerEntry.id;
      final point = _displayPoints[id] ?? markerEntry.point;

      markers.add(
        Marker(
          point: point,
          width: markerEntry.width,
          height: markerEntry.height,
          alignment: markerEntry.alignment,
          child: KeyedSubtree(
            key: ValueKey('animated-marker-$id'),
            child: markerEntry.child,
          ),
        ),
      );
    }

    return MarkerLayer(markers: markers);
  }
}

class _PointTransition {
  final LatLng from;
  final LatLng to;

  const _PointTransition({required this.from, required this.to});
}
