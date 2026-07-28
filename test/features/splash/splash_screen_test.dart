import 'package:bayantrack_mobile/core/theme/app_theme.dart';
import 'package:bayantrack_mobile/features/onboarding/presentation/onboarding_screen.dart';
import 'package:bayantrack_mobile/features/splash/presentation/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _deepBlue = Color(0xFF064BEE);
const _darkModeBlue = Color(0xFF3B82F6);
const _richOrange = Color(0xFFF86A05);
const _logoAsset = 'assets/images/BayanTrack-Logo-NoTxt.png';

void main() {
  testWidgets('shows the branded light-mode startup content', (tester) async {
    await _pumpSplash(tester, brightness: Brightness.light);

    _expectBranding(tester, expectedBlue: _deepBlue);
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      const Color(0xFFF8FAFC),
    );
    await _finishSplash(tester);
  });

  testWidgets('shows accessible dark-mode startup content', (tester) async {
    await _pumpSplash(tester, brightness: Brightness.dark);

    _expectBranding(tester, expectedBlue: _darkModeBlue);
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      const Color(0xFF0F172A),
    );
    await _finishSplash(tester);
  });

  testWidgets('animates in and continues to onboarding', (tester) async {
    await _pumpSplash(tester, brightness: Brightness.light);

    final fade = tester.widget<FadeTransition>(
      find.byKey(const ValueKey('splash-entrance')),
    );
    expect(fade.opacity.value, 0);

    await tester.pump(const Duration(milliseconds: 400));
    expect(fade.opacity.value, greaterThan(0));

    await tester.pump(const Duration(milliseconds: 1100));
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsOneWidget);
  });

  testWidgets('uses a static loader when reduced motion is enabled', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    await _pumpSplash(tester, brightness: Brightness.light);

    final loader = tester.widget<CircularProgressIndicator>(
      find.byKey(const ValueKey('splash-loader')),
    );
    expect(loader.value, isNotNull);
    await _finishSplash(tester);
  });

  for (final brightness in [Brightness.light, Brightness.dark]) {
    for (final size in [const Size(320, 568), const Size(390, 844)]) {
      for (final textScale in [1.0, 2.0]) {
        testWidgets('has no overflow at ${size.width.toInt()}x'
            '${size.height.toInt()}, ${textScale}x, ${brightness.name}', (
          tester,
        ) async {
          await _pumpSplash(
            tester,
            brightness: brightness,
            size: size,
            textScale: textScale,
          );
          await tester.pump(const Duration(milliseconds: 700));

          expect(tester.takeException(), isNull);
          _expectBranding(
            tester,
            expectedBlue: brightness == Brightness.dark
                ? _darkModeBlue
                : _deepBlue,
          );
          await _finishSplash(
            tester,
            elapsed: const Duration(milliseconds: 700),
          );
        });
      }
    }
  }
}

void _expectBranding(WidgetTester tester, {required Color expectedBlue}) {
  final logo = tester.widget<Image>(find.byKey(const ValueKey('splash-logo')));
  expect((logo.image as AssetImage).assetName, _logoAsset);
  expect(logo.fit, BoxFit.contain);
  expect(logo.excludeFromSemantics, isTrue);

  final wordmark = tester.widget<Text>(
    find.byKey(const ValueKey('splash-wordmark')),
  );
  final spans = (wordmark.textSpan! as TextSpan).children!.cast<TextSpan>();
  expect(spans[0].text, 'Bayan');
  expect(spans[0].style?.color, expectedBlue);
  expect(spans[1].text, 'Track');
  expect(spans[1].style?.color, _richOrange);

  expect(find.text('Report. Track. Resolve.'), findsOneWidget);

  final loader = tester.widget<CircularProgressIndicator>(
    find.byKey(const ValueKey('splash-loader')),
  );
  expect(loader.color, expectedBlue);
  expect(loader.semanticsLabel, 'Loading BayanTrack');
}

Future<void> _finishSplash(
  WidgetTester tester, {
  Duration elapsed = Duration.zero,
}) async {
  await tester.pump(const Duration(milliseconds: 1500) - elapsed);
  await tester.pumpAndSettle();
}

Future<void> _pumpSplash(
  WidgetTester tester, {
  required Brightness brightness,
  Size size = const Size(390, 844),
  double textScale = 1,
}) async {
  SharedPreferences.setMockInitialValues({'onboarding_complete': false});
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: brightness == Brightness.dark
            ? ThemeMode.dark
            : ThemeMode.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const SplashScreen(),
      ),
    ),
  );
}
