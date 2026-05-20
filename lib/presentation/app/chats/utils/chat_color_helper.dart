import 'package:flutter/material.dart';
import 'package:mastercs_mobile/utils/color_utils.dart';

/// Helper class for consistent chat color usage across chat UI components
class ChatColorHelper {
  /// Alpha value for light backgrounds (20% opacity)
  static const int backgroundAlpha = 84;

  /// Alpha value for medium opacity elements (33% opacity)
  static const int mediumAlpha = 150;

  /// Alpha value for accent elements (78% opacity)
  static const int accentAlpha = 200;

  /// Parse chat color string and return with background alpha
  static Color getBackgroundColor(
    String? colorString, {
    Color? fallback,
    Color? asColor,
  }) {
    final color =
        asColor ?? ColorUtils.parseColor(colorString, fallback: fallback);
    return color.withAlpha(backgroundAlpha);
  }

  /// Parse chat color string and return with medium alpha
  static Color getMediumColor(
    String? colorString, {
    Color? fallback,
    Color? asColor,
  }) {
    final color =
        asColor ?? ColorUtils.parseColor(colorString, fallback: fallback);
    return color.withAlpha(mediumAlpha);
  }

  /// Parse chat color string and return with accent alpha
  static Color getAccentColor(
    String? colorString, {
    Color? fallback,
    Color? asColor,
  }) {
    final color =
        asColor ?? ColorUtils.parseColor(colorString, fallback: fallback);
    return color.withAlpha(accentAlpha);
  }

  /// Parse chat color string (full opacity)
  static Color getFullColor(
    String? colorString, {
    Color? fallback,
    Color? asColor,
  }) {
    return asColor ?? ColorUtils.parseColor(colorString, fallback: fallback);
  }
}
