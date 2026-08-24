import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme_provider.dart';

const appSupportedLocales = <Locale>[Locale('en'), Locale('fil')];
const _localeKey = 'app_locale';

final appLocaleProvider = NotifierProvider<AppLocaleNotifier, Locale>(
  AppLocaleNotifier.new,
);

class AppLocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final saved = ref.watch(sharedPrefsProvider).getString(_localeKey);
    return appSupportedLocales.firstWhere(
      (locale) => locale.languageCode == saved,
      orElse: () => appSupportedLocales.first,
    );
  }

  Future<void> setLocale(Locale locale) async {
    if (!appSupportedLocales.any(
      (supported) => supported.languageCode == locale.languageCode,
    )) {
      return;
    }

    final normalized = Locale(locale.languageCode);
    state = normalized;
    await ref.read(sharedPrefsProvider).setString(_localeKey, normalized.languageCode);
  }
}
