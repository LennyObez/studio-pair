import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Locale notifier with persistence via SharedPreferences.
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en')) {
    _loadSavedLocale();
  }

  static const _key = 'locale';
  static const _supportedLocales = ['en', 'fr', 'nl', 'de'];

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved != null && _supportedLocales.contains(saved)) {
      state = Locale(saved);
    }
  }

  /// Set the locale and persist.
  Future<void> setLocale(Locale locale) async {
    if (_supportedLocales.contains(locale.languageCode)) {
      state = locale;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, locale.languageCode);
    }
  }

  /// Set locale by language code and persist.
  Future<void> setLanguageCode(String code) async {
    if (_supportedLocales.contains(code)) {
      state = Locale(code);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, code);
    }
  }

  /// Check if a locale is supported.
  static bool isSupported(String languageCode) {
    return _supportedLocales.contains(languageCode);
  }

  /// Get supported locale list.
  static List<Locale> get supportedLocales =>
      _supportedLocales.map(Locale.new).toList();
}

/// Locale provider.
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

/// Convenience provider for the current language code.
final languageCodeProvider = Provider<String>((ref) {
  return ref.watch(localeProvider).languageCode;
});
