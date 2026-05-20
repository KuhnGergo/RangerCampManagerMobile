import 'dart:math';
import 'package:flutter/material.dart';

/// A custom loading indicator that displays three dots rotating in a circular path.
///
/// This widget has two modes:
/// 1. **Charging mode** (when `value` is provided): Shows a progress circle with
///    three dots positioned according to the progress value (0.0 to 1.0). Used for
///    tracking progress like pull-to-refresh gestures.
/// 2. **Spinning mode** (when `value` is null): Continuously spins three dots
///    around a circle. Used for general loading states.
class ThreeDotLoadingIndicator extends StatefulWidget {
  final double size;
  final Color? color;
  final double dotSize;

  /// Radius of the circular path the dots follow.
  ///
  /// Larger values move dots farther from the center (and each other).
  /// When null, radius is derived from [size] and [dotSize].
  final double? orbitRadius;

  /// Progress value between 0.0 and 1.0 for charging mode.
  final double? value;

  /// Duration for one complete rotation in spinning mode
  final Duration spinDuration;

  /// When true, triggers a fadeout animation in the last cycle
  final bool isCompleting;

  /// Callback when the fadeout animation completes
  final VoidCallback? onCompleted;

  const ThreeDotLoadingIndicator({
    super.key,
    this.size = 40,
    this.color,
    this.dotSize = 6,
    this.orbitRadius,
    this.value,
    this.spinDuration = const Duration(milliseconds: 500),
    this.isCompleting = false,
    this.onCompleted,
  });

  @override
  State<ThreeDotLoadingIndicator> createState() =>
      _ThreeDotLoadingIndicatorState();
}

class _ThreeDotLoadingIndicatorState extends State<ThreeDotLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isFadingOut = false;
  double _fadeoutStartValue = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.spinDuration,
      vsync: this,
    );
    // Start spinning animation if in spinning mode
    if (widget.value == null) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(ThreeDotLoadingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update spin duration if it changed
    if (widget.spinDuration != oldWidget.spinDuration) {
      _controller.duration = widget.spinDuration;
    }

    // Handle fadeout when isCompleting becomes true
    if (widget.isCompleting && !oldWidget.isCompleting && !_isFadingOut) {
      _startFadeout();
    }

    // Switch between determinate and indeterminate modes
    if (widget.value == null && oldWidget.value != null) {
      if (!_isFadingOut) {
        _controller.repeat();
      }
    } else if (widget.value != null && oldWidget.value == null) {
      _controller.stop();
      _isFadingOut = false;
    }
  }

  void _startFadeout() {
    _isFadingOut = true;
    _fadeoutStartValue = _controller.value;
    _controller.stop();

    // Animate to complete one full cycle from current position
    _controller
        .animateTo(
          1.0,
          duration: widget.spinDuration * (1.0 - _fadeoutStartValue),
        )
        .then((_) {
          if (mounted) {
            widget.onCompleted?.call();
          }
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.secondary;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: widget.value == null
          ? // Spinning mode: animated spinning
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                // Calculate opacity for fadeout effect
                double opacity = 1.0;
                if (_isFadingOut) {
                  // Fade from 1.0 to 0.0 during the last cycle
                  final fadeProgress =
                      (_controller.value - _fadeoutStartValue) /
                      (1.0 - _fadeoutStartValue);
                  opacity = 1.0 - fadeProgress.clamp(0.0, 1.0);
                }

                return CustomPaint(
                  painter: _ThreeDotPainter(
                    color: color,
                    dotSize: widget.dotSize,
                    orbitRadius: widget.orbitRadius,
                    progress: _controller.value,
                    isChargingMode: false,
                    size: widget.size,
                    opacity: opacity,
                  ),
                );
              },
            )
          : // Charging mode: fixed position based on value
            CustomPaint(
              painter: _ThreeDotPainter(
                color: color,
                dotSize: widget.dotSize,
                orbitRadius: widget.orbitRadius,
                progress: widget.value!,
                isChargingMode: true,
                size: widget.size,
                opacity: 1.0,
              ),
            ),
    );
  }
}

/// Custom painter that draws three dots rotating around a circular path.
///
/// The painter calculates dot positions using polar coordinates:
/// - Each dot is positioned at an angle around a circle
/// - The angle is determined by the progress value (0.0 to 1.0 maps to 0° to 360°)
/// - Three dots are evenly spaced 120° apart (2π/3 radians)
class _ThreeDotPainter extends CustomPainter {
  final Color color;
  final double dotSize;
  final double? orbitRadius;
  final double progress;
  final bool isChargingMode;
  final double size;
  final double opacity;

  _ThreeDotPainter({
    required this.color,
    required this.dotSize,
    required this.orbitRadius,
    required this.progress,
    required this.isChargingMode,
    required this.size,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    // Calculate the center point of the canvas
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);

    // Radius of the circular path the dots follow.
    final radius =
        orbitRadius ?? max(0.0, (canvasSize.width / 2) - dotSize - 2);

    // Paint for drawing dots with opacity
    final dotPaint = Paint()
      ..color = color.withAlpha((opacity * 255).round())
      ..style = PaintingStyle.fill;

    // Draw three dots evenly spaced around the circle
    for (int i = 0; i < 3; i++) {
      // Calculate angle for this dot:
      // - progress * 2π: current rotation (0 to 360°)
      // - i * 2π/3: spacing between dots (120° apart)
      // - Subtract π/2 to start at top instead of right
      final angle = (progress * 2 * pi) + (i * 2 * pi / 3) - (pi / 2);

      // Convert polar coordinates (angle, radius) to cartesian (x, y)
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);

      // Draw the dot at calculated position
      canvas.drawCircle(Offset(x, y), dotSize, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_ThreeDotPainter oldDelegate) {
    // Repaint when progress, color, size, or opacity changes
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.size != size ||
        oldDelegate.dotSize != dotSize ||
        oldDelegate.orbitRadius != orbitRadius ||
        oldDelegate.isChargingMode != isChargingMode ||
        oldDelegate.opacity != opacity;
  }
}
