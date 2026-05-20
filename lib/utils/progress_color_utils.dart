import 'package:flutter/material.dart';

class ProgressColorUtils {
  /// Converts a progress value (0.0 to 1.0) to a color that transitions
  /// from red → yellow → green.
  ///
  /// - 0.0 - 0.5: Transitions from red to yellow
  /// - 0.5 - 1.0: Transitions from yellow to green
  ///
  /// Returns red for values <= 0, green for values >= 1.
  static Color toColor(double progress) {
    // Clamp progress between 0 and 1
    final clampedProgress = progress.clamp(0.0, 1.0);

    if (clampedProgress <= 0.5) {
      // Red to Yellow (0.0 to 0.5)
      // Red: (255, 0, 0) -> Yellow: (255, 255, 0)
      final t = clampedProgress * 2; // Scale to 0-1
      return Color.lerp(
        const Color.fromARGB(255, 139, 31, 29), // Red
        const Color.fromARGB(255, 210, 146, 51), // Orange-Yellow
        t,
      )!;
    } else {
      // Yellow to Green (0.5 to 1.0)
      // Yellow: (255, 255, 0) -> Green: (0, 255, 0)
      final t = (clampedProgress - 0.5) * 2; // Scale to 0-1
      return Color.lerp(
        const Color.fromARGB(255, 210, 146, 51), // Orange-Yellow
        const Color.fromARGB(255, 54, 134, 58), // Green
        t,
      )!;
    }
  }
}
