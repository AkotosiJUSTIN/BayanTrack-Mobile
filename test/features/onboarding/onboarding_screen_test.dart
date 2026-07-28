import 'package:bayantrack_mobile/features/auth/presentation/auth_wrapper.dart';
import 'package:bayantrack_mobile/features/onboarding/presentation/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _deepBlue = Color(0xFF064BEE);
const _richOrange = Color(0xFFF86A05);
const _tagline = 'Watching over communities, supporting local action.';
const _titles = [
  'Report Issues in Your Community',
  'Track Your Report’s Progress',
  'Stay Informed',
];
const _descriptions = [
  'Quickly report floods, potholes, broken streetlights, garbage, and other local concerns directly to the LGU.',
  'Follow your report’s status and receive updates as it moves toward resolution.',
  'Receive important updates and safety alerts for your community.',
];
const _artwork = [
  'assets/onboarding/Mascot1_thumbs_up_full.png',
  'assets/onboarding/Mascot2_headset_full.png',
  'assets/onboarding/Mascot3_megaphone_full.png',
];

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('preserves three-page navigation and completes onboarding once', (
    tester,
  ) async {
    final observer = _CountingNavigatorObserver();
    await _pumpOnboarding(
      tester,
      const Size(390, 844),
      navigatorObserver: observer,
    );

    _expectPage(tester, pageIndex: 0);
    _expectOnboardingColors(tester, pageIndex: 0, activeIndicator: 0);
    _expectSharedTypography(tester, pageIndex: 0);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);

    final pageOneSemantics = tester.ensureSemantics();
    expect(find.bySemanticsLabel('Skip'), findsOneWidget);
    expect(find.bySemanticsLabel('Continue'), findsOneWidget);
    pageOneSemantics.dispose();

    await _tapAndFinishPageAnimation(tester, 'Continue');
    _expectPage(tester, pageIndex: 1);
    _expectOnboardingColors(tester, pageIndex: 1, activeIndicator: 1);
    _expectSharedTypography(tester, pageIndex: 1);

    await _tapAndFinishPageAnimation(tester, 'Back');
    expect(find.text(_titles[0]).hitTestable(), findsOneWidget);

    await _tapAndFinishPageAnimation(tester, 'Continue');
    await _tapAndFinishPageAnimation(tester, 'Continue');
    _expectPage(tester, pageIndex: 2);
    _expectOnboardingColors(tester, pageIndex: 2, activeIndicator: 2);
    _expectSharedTypography(tester, pageIndex: 2);
    expect(find.text('Back'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);

    final pageThreeSemantics = tester.ensureSemantics();
    expect(find.bySemanticsLabel('Back'), findsOneWidget);
    expect(find.bySemanticsLabel('Get Started'), findsOneWidget);
    pageThreeSemantics.dispose();

    await _tapAndFinishPageAnimation(tester, 'Back');
    expect(find.text(_titles[1]).hitTestable(), findsOneWidget);
    await _tapAndFinishPageAnimation(tester, 'Continue');

    final primaryButton = find.byKey(
      const ValueKey('onboarding-primary-button'),
    );
    final onGetStarted = tester
        .widget<ElevatedButton>(primaryButton)
        .onPressed!;
    onGetStarted();
    onGetStarted();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool('onboarding_complete'), isTrue);
    expect(observer.replacementCount, 1);
    expect(find.byType(OnboardingScreen).hitTestable(), findsNothing);
    expect(find.byType(AuthWrapper, skipOffstage: false), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('centers every main group between shared header and footer', (
    tester,
  ) async {
    await _pumpOnboarding(tester, const Size(390, 844));

    for (var pageIndex = 0; pageIndex < _titles.length; pageIndex++) {
      if (pageIndex > 0) {
        await _tapAndFinishPageAnimation(tester, 'Continue');
      }

      _expectBalancedLayout(tester, pageIndex: pageIndex, viewportWidth: 390);
    }
  });

  testWidgets('keeps the shared header stationary while page bodies swipe', (
    tester,
  ) async {
    await _pumpOnboarding(tester, const Size(390, 844));

    final header = find.byKey(const ValueKey('onboarding-header'));
    expect(header, findsOneWidget);

    final headerElement = tester.element(header);
    final headerRect = tester.getRect(header);

    expect(
      find.descendant(of: find.byType(PageView), matching: header),
      findsNothing,
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(PageView)),
    );
    await gesture.moveBy(const Offset(-140, 0));
    await tester.pump();

    expect(tester.element(header), same(headerElement));
    expect(tester.getRect(header), headerRect);
    expect(find.text(_tagline), findsOneWidget);

    await gesture.up();
    await tester.pumpAndSettle();

    expect(tester.element(header), same(headerElement));
    expect(tester.getRect(header), headerRect);

    await _tapAndFinishPageAnimation(tester, 'Continue');

    expect(tester.element(header), same(headerElement));
    expect(tester.getRect(header), headerRect);
  });

  for (var pageIndex = 0; pageIndex < _titles.length; pageIndex++) {
    for (final configuration in [
      for (final size in [
        const Size(320, 568),
        const Size(360, 800),
        const Size(390, 844),
      ])
        for (final textScale in [1.0, 1.5, 2.0])
          (size: size, textScale: textScale),
    ]) {
      testWidgets('Page ${pageIndex + 1} has no overflow at '
          '${configuration.size.width.toInt()}x'
          '${configuration.size.height.toInt()} with '
          '${configuration.textScale}x text', (tester) async {
        await _pumpOnboarding(
          tester,
          configuration.size,
          textScale: configuration.textScale,
        );
        await _goToPage(tester, pageIndex);

        _expectPage(tester, pageIndex: pageIndex);
        _expectOnboardingColors(
          tester,
          pageIndex: pageIndex,
          activeIndicator: pageIndex,
        );
        _expectCenteredBody(
          tester,
          pageIndex: pageIndex,
          viewportWidth: configuration.size.width,
        );
        _expectMinimumTouchTargets(tester);
        expect(tester.takeException(), isNull);

        await tester.ensureVisible(find.text(_descriptions[pageIndex]));
        await tester.pump();
        expect(tester.takeException(), isNull);
      });
    }
  }
}

void _expectPage(WidgetTester tester, {required int pageIndex}) {
  expect(find.text(_titles[pageIndex]), findsOneWidget);
  expect(find.text(_descriptions[pageIndex]), findsOneWidget);
  expect(find.text(_tagline), findsOneWidget);
  _expectArtwork(tester, pageIndex: pageIndex, assetName: _artwork[pageIndex]);
}

void _expectBalancedLayout(
  WidgetTester tester, {
  required int pageIndex,
  required double viewportWidth,
}) {
  final mainViewportRect = tester.getRect(
    find.byKey(ValueKey('onboarding-scroll-$pageIndex')),
  );
  final headerRect = tester.getRect(
    find.byKey(const ValueKey('onboarding-header')),
  );
  final mainRect = tester.getRect(
    find.byKey(ValueKey('onboarding-main-$pageIndex')),
  );
  final indicatorGroupRect = tester.getRect(
    find.byKey(const ValueKey('onboarding-indicator-group')),
  );
  final topGap = mainRect.top - mainViewportRect.top;
  final bottomGap = mainViewportRect.bottom - mainRect.bottom;

  expect(
    find.descendant(
      of: find.byKey(ValueKey('onboarding-page-$pageIndex')),
      matching: find.byType(SingleChildScrollView),
    ),
    findsOneWidget,
  );
  expect(headerRect.bottom, lessThanOrEqualTo(mainViewportRect.top));
  expect(topGap, greaterThanOrEqualTo(0));
  expect(indicatorGroupRect.center.dx, closeTo(viewportWidth / 2, 0.01));
  if (bottomGap >= 0) {
    expect((topGap - bottomGap).abs(), lessThanOrEqualTo(12));
    expect(indicatorGroupRect.top - mainRect.bottom, lessThanOrEqualTo(110));
  }
}

void _expectCenteredBody(
  WidgetTester tester, {
  required int pageIndex,
  required double viewportWidth,
}) {
  final body = find.byKey(ValueKey('onboarding-body-$pageIndex'));
  final title = find.byKey(ValueKey('onboarding-title-$pageIndex'));
  final underline = find.byKey(
    ValueKey('onboarding-title-underline-$pageIndex'),
  );
  final description = find.byKey(ValueKey('onboarding-description-$pageIndex'));
  final indicator = find.byKey(const ValueKey('onboarding-indicator-group'));
  final centerX = viewportWidth / 2;

  expect(tester.getCenter(body).dx, closeTo(centerX, 0.01));
  expect(tester.getCenter(title).dx, closeTo(centerX, 0.01));
  expect(tester.getCenter(underline).dx, closeTo(centerX, 0.01));
  expect(tester.getCenter(description).dx, closeTo(centerX, 0.01));
  expect(tester.getCenter(indicator).dx, closeTo(centerX, 0.01));
  expect(tester.getSize(body).width, lessThanOrEqualTo(340));
  expect(tester.widget<Text>(title).textAlign, TextAlign.center);
  expect(tester.widget<Text>(description).textAlign, TextAlign.center);
}

void _expectArtwork(
  WidgetTester tester, {
  required int pageIndex,
  required String assetName,
}) {
  final page = find.byKey(ValueKey('onboarding-page-$pageIndex'));
  final imageFinder = find.descendant(of: page, matching: find.byType(Image));
  final image = tester.widget<Image>(imageFinder);

  expect((image.image as AssetImage).assetName, assetName);
  expect(image.fit, BoxFit.contain);
  expect(image.excludeFromSemantics, isTrue);
  expect(
    find.descendant(of: page, matching: find.byType(SvgPicture)),
    findsOneWidget,
  );
}

void _expectOnboardingColors(
  WidgetTester tester, {
  required int pageIndex,
  required int activeIndicator,
}) {
  final wordmark = tester.widget<Text>(
    find.byKey(const ValueKey('onboarding-wordmark')),
  );
  final wordmarkSpan = wordmark.textSpan! as TextSpan;
  final wordmarkChildren = wordmarkSpan.children!.cast<TextSpan>();
  expect(wordmarkChildren[0].style?.color, _deepBlue);
  expect(wordmarkChildren[1].style?.color, _richOrange);

  final title = tester.widget<Text>(
    find.byKey(ValueKey('onboarding-title-$pageIndex')),
  );
  expect(title.style?.color, _deepBlue);

  final underline = tester.widget<SvgPicture>(
    find.descendant(
      of: find.byKey(ValueKey('onboarding-title-underline-$pageIndex')),
      matching: find.byType(SvgPicture),
    ),
  );
  expect(
    underline.colorFilter,
    const ColorFilter.mode(_richOrange, BlendMode.srcIn),
  );

  final secondaryButton = tester.widget<TextButton>(
    find.byKey(const ValueKey('onboarding-secondary-button')),
  );
  expect(secondaryButton.style?.foregroundColor?.resolve({}), _richOrange);

  final primaryButton = tester.widget<ElevatedButton>(
    find.byKey(const ValueKey('onboarding-primary-button')),
  );
  expect(primaryButton.style?.backgroundColor?.resolve({}), _deepBlue);
  expect(primaryButton.style?.foregroundColor?.resolve({}), Colors.white);

  final indicator = tester.widget<AnimatedContainer>(
    find.byKey(ValueKey('onboarding-indicator-$activeIndicator')),
  );
  expect((indicator.decoration as BoxDecoration).color, _deepBlue);
}

void _expectSharedTypography(WidgetTester tester, {required int pageIndex}) {
  final title = tester.widget<Text>(
    find.byKey(ValueKey('onboarding-title-$pageIndex')),
  );
  final description = tester.widget<Text>(
    find.byKey(ValueKey('onboarding-description-$pageIndex')),
  );

  expect(title.style?.fontSize, 30);
  expect(title.style?.fontWeight, FontWeight.w800);
  expect(description.style?.fontSize, 17);
  expect(description.style?.fontWeight, FontWeight.w500);
  expect(description.style?.height, 1.42);
}

void _expectMinimumTouchTargets(WidgetTester tester) {
  expect(
    tester
        .getSize(find.byKey(const ValueKey('onboarding-secondary-button')))
        .height,
    greaterThanOrEqualTo(44),
  );
  expect(
    tester
        .getSize(find.byKey(const ValueKey('onboarding-primary-button')))
        .height,
    greaterThanOrEqualTo(44),
  );
}

Future<void> _pumpOnboarding(
  WidgetTester tester,
  Size size, {
  double textScale = 1,
  NavigatorObserver? navigatorObserver,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        navigatorObservers: [?navigatorObserver],
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

Future<void> _goToPage(WidgetTester tester, int pageIndex) async {
  for (var index = 0; index < pageIndex; index++) {
    await _tapAndFinishPageAnimation(tester, 'Continue');
  }
}

Future<void> _tapAndFinishPageAnimation(
  WidgetTester tester,
  String label,
) async {
  await tester.tap(find.text(label));
  await tester.pump();
  await tester.pumpAndSettle();
}

class _CountingNavigatorObserver extends NavigatorObserver {
  int replacementCount = 0;

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    replacementCount++;
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}
