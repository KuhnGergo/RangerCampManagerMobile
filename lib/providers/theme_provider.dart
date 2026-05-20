import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mastercs_mobile/providers/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends StateNotifier<ThemeMode> {
  static const String _themeKey = 'theme_key';

  static String get themeKey => _themeKey;

  final SharedPreferences _prefs;

  ThemeProvider(this._prefs, super.initialMode);

  void update(ThemeMode mode) {
    state = mode;
    _prefs.setInt(_themeKey, mode.index);
  }

  Future<void> toggleTheme() async {
    state.index == ThemeMode.light.index
        ? update(ThemeMode.dark)
        : update(ThemeMode.light);
  }
}

final themeProvider = StateNotifierProvider<ThemeProvider, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final initial = ref.watch(initialThemeModeProvider);
  return ThemeProvider(prefs, initial);
});

final initialThemeModeProvider = Provider<ThemeMode>((_) {
  return ThemeMode.system; // fallback, overridden at startup
});
