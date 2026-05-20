import 'package:flutter/material.dart';
import 'dart:math' as math;

class ProgressCapsule extends StatelessWidget {
  final double progress;
  final Color backgroundColor;
  final List<Color> gradientColors;
  final double width;

  const ProgressCapsule({
    super.key,
    required this.progress,
    required this.backgroundColor,
    required this.gradientColors,
    this.width = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(width / 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(width / 2),
        child: CustomPaint(
          painter: _WavePainter(
            progress: progress,
            gradientColors: gradientColors,
          ),
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double progress;
  final List<Color> gradientColors;

  _WavePainter({required this.progress, required this.gradientColors});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final fillHeight = size.height * progress;
    final waveAmplitude = 2.0;
    final waveFrequency = 1.0;

    // Create gradient
    final gradient = LinearGradient(
      colors: gradientColors,
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    );

    final rect = Rect.fromLTWH(
      0,
      size.height - fillHeight - waveAmplitude,
      size.width,
      fillHeight + waveAmplitude,
    );
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    // Create wave path
    final path = Path();
    path.moveTo(0, size.height);

    // Draw left edge
    path.lineTo(0, size.height - fillHeight + waveAmplitude);

    // Draw wave at the top
    for (double x = 0; x <= size.width; x += 1) {
      final normalizedX = x / size.width;
      final wave =
          math.sin(normalizedX * waveFrequency * math.pi * 2) * waveAmplitude;
      path.lineTo(x, size.height - fillHeight + wave);
    }

    // Draw right edge
    path.lineTo(size.width, size.height - fillHeight + waveAmplitude);
    path.lineTo(size.width, size.height);

    // Close path at bottom
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.gradientColors != gradientColors;
  }
}
