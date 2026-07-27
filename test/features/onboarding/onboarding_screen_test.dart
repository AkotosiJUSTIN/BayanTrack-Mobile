import 'package:bayantrack_mobile/features/onboarding/presentation/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows Bantay content and preserves pager controls', (
    tester,
  ) async {
    await _pumpOnboarding(tester, const Size(390, 844));

    expect(find.text('Submit Reports').hitTestable(), findsOneWidget);
    expect(
      find
          .text(
            'Report local issues quickly with location tagging and photo uploads.',
          )
          .hitTestable(),
      findsOneWidget,
    );
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    final firstMascot = tester.widget<Image>(
      find.descendant(
        of: find.byKey(const ValueKey('onboarding-page-0')),
        matching: find.byType(Image),
      ),
    );
    expect(
      (firstMascot.image as AssetImage).assetName,
      'assets/onboarding/Mascot1_thumbs_up_full.png',
    );
    expect(
      tester
          .getSize(find.byKey(const ValueKey('onboarding-primary-button')))
          .height,
      greaterThanOrEqualTo(48),
    );

    await _tapAndFinishPageAnimation(tester, 'Next');
    expect(find.text('Track Progress').hitTestable(), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    await _tapAndFinishPageAnimation(tester, 'Next');
    expect(find.text('Stay Informed').hitTestable(), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);

    await _tapAndFinishPageAnimation(tester, 'Back');
    expect(find.text('Track Progress').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final configuration in [
    (size: const Size(320, 568), textScale: 2.0),
    (size: const Size(430, 932), textScale: 1.0),
  ]) {
    testWidgets('has no overflow at ${configuration.size.width.toInt()}x'
        '${configuration.size.height.toInt()} with '
        '${configuration.textScale}x text', (tester) async {
      await _pumpOnboarding(
        tester,
        configuration.size,
        textScale: configuration.textScale,
      );

      expect(
        find.byKey(const ValueKey('onboarding-primary-button')).hitTestable(),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);

      await _tapAndFinishPageAnimation(tester, 'Next');
      expect(tester.takeException(), isNull);
      await _tapAndFinishPageAnimation(tester, 'Next');
      expect(find.text('Get Started'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

Future<void> _pumpOnboarding(
  WidgetTester tester,
  Size size, {
  double textScale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          );
        },
        home: const OnboardingScreen(),
      ),
    ),
  );
  await tester.pump();
}

Future<void> _tapAndFinishPageAnimation(
  WidgetTester tester,
  String label,
) async {
  await tester.tap(find.text(label));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
}
