// BayanTrack app smoke test.
//
// This test verifies that the app can start without crashing.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bayantrack_mobile/core/providers/theme_provider.dart';
import 'package:bayantrack_mobile/features/splash/presentation/splash_screen.dart';
import 'package:bayantrack_mobile/main.dart';

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Build our app wrapped with ProviderScope and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
        child: const MyApp(),
      ),
    );

    expect(find.byType(SplashScreen), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();

    // Verify that the app renders and completes its startup transition.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
