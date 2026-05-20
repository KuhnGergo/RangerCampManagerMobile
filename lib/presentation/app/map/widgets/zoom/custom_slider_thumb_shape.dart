import 'package:flutter/material.dart';

class CustomThumbShape extends SliderComponentShape {
  final double thumbHeight;
  final double thumbWidth;
  final Color color;
  final Color shadowColor;

  const CustomThumbShape({
    required this.thumbHeight,
    required this.thumbWidth,
    required this.color,
    required this.shadowColor,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(thumbHeight, thumbWidth);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    // Draw shadow
    final shadowPath = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center.translate(0, 2),
        width: thumbHeight,
        height: thumbWidth,
      ),
      const Radius.circular(16),
    );
    canvas.drawRRect(
      shadowPath,
      Paint()
        ..color = shadowColor.withAlpha(50)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Draw thumb
    final thumbPath = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: thumbHeight, height: thumbWidth),
      const Radius.circular(16),
    );
    canvas.drawRRect(thumbPath, Paint()..color = color);
  }
}
