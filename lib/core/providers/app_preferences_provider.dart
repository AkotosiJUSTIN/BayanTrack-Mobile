import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appPreferencesProvider = AsyncNotifierProvider<AppPreferences, void>(
  AppPreferences.new,
);

class AppPreferences extends AsyncNotifier<void> {
  static const _keyOnboardingComplete = 'onboarding_complete';

  @override
  Future<void> build() async {}

  Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingComplete) ?? false;
  }

  Future<void> setOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingComplete, true);
  }
}
