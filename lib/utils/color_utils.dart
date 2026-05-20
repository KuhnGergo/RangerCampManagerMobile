import 'package:flutter/material.dart';

/// Utility functions for converting between Color objects and hex color strings
class ColorUtils {
  /// Parses a hex color string to a Color object.
  ///
  /// Supports formats:
  /// - RGB: "FF0000", "#FF0000"
  /// - ARGB: "FFFF0000", "#FFFF0000"
  ///
  /// Returns [fallback] if parsing fails or string is null/empty.
  /// If no fallback is provided, returns Colors.grey.
  static Color parseColor(String? colorString, {Color? fallback}) {
    final defaultColor = fallback ?? Colors.grey;

    if (colorString == null || colorString.isEmpty) {
      return defaultColor;
    }

    try {
      // Remove # if present
      final hex = colorString.replaceAll('#', '');

      // Add alpha channel if not present (assume fully opaque)
      final hexColor = hex.length == 6 ? 'FF$hex' : hex;

      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return defaultColor;
    }
  }

  /// Parses a hex color string to a Color object or returns null if parsing fails.
  ///
  /// Supports formats:
  /// - RGB: "FF0000", "#FF0000"
  /// - ARGB: "FFFF0000", "#FFFF0000"
  ///
  /// Returns null if the string is null, empty, or cannot be parsed.
  static Color? parseColorOrNull(String? colorString) {
    if (colorString == null || colorString.isEmpty) {
      return null;
    }

    try {
      // Remove # if present
      final hex = colorString.replaceAll('#', '');

      // Add alpha channel if not present (assume fully opaque)
      final hexColor = hex.length == 6 ? 'FF$hex' : hex;

      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return null;
    }
  }

  /// Converts a Color object to a hex string format.
  ///
  /// [includeAlpha] determines whether to include the alpha channel in the output.
  /// [includeHash] determines whether to prefix the result with '#'.
  ///
  /// Examples:
  /// - colorToHex(Colors.red) -> "FF0000"
  /// - colorToHex(Colors.red, includeAlpha: true) -> "FFFF0000"
  /// - colorToHex(Colors.red, includeHash: true) -> "#FF0000"
  /// - colorToHex(Colors.red, includeAlpha: true, includeHash: true) -> "#FFFF0000"
  static String colorToHex(
    Color color, {
    bool includeAlpha = false,
    bool includeHash = false,
  }) {
    final alpha = (color.a * 255.0)
        .round()
        .clamp(0, 255)
        .toRadixString(16)
        .padLeft(2, '0')
        .toUpperCase();
    final red = (color.r * 255.0)
        .round()
        .clamp(0, 255)
        .toRadixString(16)
        .padLeft(2, '0')
        .toUpperCase();
    final green = (color.g * 255.0)
        .round()
        .clamp(0, 255)
        .toRadixString(16)
        .padLeft(2, '0')
        .toUpperCase();
    final blue = (color.b * 255.0)
        .round()
        .clamp(0, 255)
        .toRadixString(16)
        .padLeft(2, '0')
        .toUpperCase();

    final hex = includeAlpha ? '$alpha$red$green$blue' : '$red$green$blue';
    return includeHash ? '#$hex' : hex;
  }
}
