import 'package:flutter/material.dart';

class CustomTrackShape extends SliderTrackShape {
  final Color activeColor;
  final Color inactiveColor;

  const CustomTrackShape({
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 4;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
  }) {
    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final Canvas canvas = context.canvas;
    final double trackHeight = sliderTheme.trackHeight ?? 4;
    final double radius = trackHeight / 2;

    // Draw the full track as one continuous piece
    final fullTrackRRect = RRect.fromRectAndRadius(
      trackRect,
      Radius.circular(radius),
    );

    // Draw inactive (entire track)
    canvas.drawRRect(fullTrackRRect, Paint()..color = inactiveColor);

    // Draw active track (from left to thumb) on top if needed
    // Since both are the same color, this is optional but kept for consistency
    final activeTrackRect = Rect.fromLTRB(
      trackRect.left,
      trackRect.top,
      thumbCenter.dx,
      trackRect.bottom,
    );

    final activeTrackRRect = RRect.fromRectAndRadius(
      activeTrackRect,
      Radius.circular(radius),
    );

    canvas.drawRRect(activeTrackRRect, Paint()..color = activeColor);
  }
}
