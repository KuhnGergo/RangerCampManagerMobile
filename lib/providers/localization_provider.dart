import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localeProvider = NotifierProvider<LocaleController, Locale?>(
  () => LocaleController(),
);

class LocaleController extends Notifier<Locale?> {
  @override
  Locale? build() {
    _load();
    return null; // follow system by default
  }

  static const _key = 'app_locale';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code != null) {
      state = Locale(code);
    }
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;

    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_key); // follow system
    } else {
      await prefs.setString(_key, locale.languageCode);
    }
  }

  void toggleLocale() {
    if (state == null || state!.languageCode == 'en') {
      setLocale(const Locale('hu', 'HU'));
    } else if (state!.languageCode == 'hu') {
      setLocale(const Locale('en', 'US'));
    }
  }
}
