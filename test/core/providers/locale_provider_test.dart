import 'package:bayantrack_mobile/core/providers/locale_provider.dart';
import 'package:bayantrack_mobile/core/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('defaults to English and persists a supported locale', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    expect(container.read(appLocaleProvider), const Locale('en'));

    await container
        .read(appLocaleProvider.notifier)
        .setLocale(const Locale('fil'));

    expect(container.read(appLocaleProvider), const Locale('fil'));
    expect(prefs.getString('app_locale'), 'fil');
  });

  test('restores a saved locale and falls back for unsupported values', () async {
    SharedPreferences.setMockInitialValues({'app_locale': 'fil'});
    final filPrefs = await SharedPreferences.getInstance();
    final filContainer = ProviderContainer(
      overrides: [sharedPrefsProvider.overrideWithValue(filPrefs)],
    );
    addTearDown(filContainer.dispose);
    expect(filContainer.read(appLocaleProvider), const Locale('fil'));

    SharedPreferences.setMockInitialValues({'app_locale': 'es'});
    final fallbackPrefs = await SharedPreferences.getInstance();
    final fallbackContainer = ProviderContainer(
      overrides: [sharedPrefsProvider.overrideWithValue(fallbackPrefs)],
    );
    addTearDown(fallbackContainer.dispose);
    expect(fallbackContainer.read(appLocaleProvider), const Locale('en'));
  });
}
