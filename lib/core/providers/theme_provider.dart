import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Key used to store the theme mode preference.
const _kThemeModeKey = 'theme_mode';

/// Holds the pre-loaded SharedPreferences instance.
/// Must be overridden in main() via ProviderScope.overrides.
final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'SharedPreferences not initialized. Override in main().',
  );
});

/// Provider for the current theme mode.
/// Defaults to ThemeMode.system (follows OS setting).
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

/// Manages the app's theme mode (light, dark, system).
/// Persists the user's preference to SharedPreferences.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // Read synchronously from the pre-loaded SharedPreferences
    final prefs = ref.watch(sharedPrefsProvider);
    final themeModeString = prefs.getString(_kThemeModeKey);
    if (themeModeString != null) {
      return ThemeMode.values.firstWhere(
        (e) => e.name == themeModeString,
        orElse: () => ThemeMode.system,
      );
    }
    return ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = ref.read(sharedPrefsProvider);
    await prefs.setString(_kThemeModeKey, mode.name);
  }

  Future<void> toggleTheme() async {
    switch (state) {
      case ThemeMode.system:
        await setThemeMode(ThemeMode.light);
        break;
      case ThemeMode.light:
        await setThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        await setThemeMode(ThemeMode.system);
        break;
    }
  }
}
