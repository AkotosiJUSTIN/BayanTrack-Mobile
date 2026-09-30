import 'package:bayantrack_mobile/features/help/data/help_content.dart';
import 'package:bayantrack_mobile/features/help/presentation/help_screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('FAQ remains available offline and expands answers', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HelpFaqScreen()));
    await tester.scrollUntilVisible(find.text('Getting Started'), 250);
    await tester.ensureVisible(find.text('Getting Started'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Getting Started'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('What is BayanTrack?'));
    await tester.tap(find.text('What is BayanTrack?'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('residents report local issues'),
      findsOneWidget,
    );
  });

  testWidgets('FAQ search filters groups and questions immediately', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HelpFaqScreen()));
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('help-faq-search')),
      250,
    );
    await tester.ensureVisible(find.byKey(const ValueKey('help-faq-search')));

    await tester.enterText(
      find.byKey(const ValueKey('help-faq-search')),
      'location',
    );
    await tester.pumpAndSettle();

    expect(find.text('How is report location set?'), findsOneWidget);
    expect(find.text('What is BayanTrack?'), findsNothing);
  });

  testWidgets('Call action launches the configured tel URI', (tester) async {
    final launched = <Uri>[];
    await tester.pumpWidget(
      MaterialApp(
        home: EmergencyHotlinesScreen(
          launchCall: (uri) async {
            launched.add(uri);
            return true;
          },
        ),
      ),
    );

    expect(launched, isEmpty);
    await tester.tap(find.byKey(const ValueKey('hotline-call-911')));
    await tester.pumpAndSettle();

    expect(launched, [Uri(scheme: 'tel', path: '911')]);
  });

  testWidgets('missing and invalid hotline data cannot trigger a call', (
    tester,
  ) async {
    final launched = <Uri>[];
    await tester.pumpWidget(
      MaterialApp(
        home: EmergencyHotlinesScreen(
          hotlines: const [
            EmergencyHotline(
              name: 'Unverified contact',
              number: 'not-a-number',
            ),
          ],
          launchCall: (uri) async {
            launched.add(uri);
            return true;
          },
        ),
      ),
    );

    expect(find.text('Call'), findsNothing);
    expect(find.textContaining('number is unavailable'), findsOneWidget);
    expect(find.text('not-a-number'), findsNothing);
    expect(launched, isEmpty);
    expect(hotlineCallUri(null), isNull);
  });

  testWidgets('empty hotline configuration shows no fabricated number', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: EmergencyHotlinesScreen(hotlines: [])),
    );

    expect(find.text('No hotline numbers are configured.'), findsOneWidget);
    expect(find.textContaining('Call '), findsNothing);
  });

  testWidgets(
    'emergency page adapts to dark theme and keeps call target large',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const EmergencyHotlinesScreen(),
        ),
      );

      final callButton = find.byKey(const ValueKey('hotline-call-911'));
      expect(callButton, findsOneWidget);
      expect(tester.getSize(callButton).height, greaterThanOrEqualTo(48));
      expect(
        find.textContaining('does not replace emergency response services'),
        findsOneWidget,
      );
    },
  );

  test('searchable FAQ content is bundled without a backend provider', () {
    expect(helpFaqCategories, isNotEmpty);
    expect(filterHelpFaqCategories('resolution'), isNotEmpty);
  });

  for (final throwsError in [false, true]) {
    testWidgets('missing dialer handled, exception=$throwsError', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EmergencyHotlinesScreen(
            launchCall: (_) async {
              if (throwsError) throw StateError('No dialer');
              return false;
            },
          ),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('hotline-call-911')));
      await tester.pumpAndSettle();
      expect(find.textContaining('using another phone'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('FAQ renders every shared contact and only launches after tap', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final launched = <Uri>[];
    await tester.pumpWidget(
      MaterialApp(
        home: HelpFaqScreen(
          launchCall: (uri) async {
            launched.add(uri);
            return true;
          },
        ),
      ),
    );
    expect(launched, isEmpty);
    for (final hotline in emergencyHotlines) {
      final tile = find.byKey(ValueKey('hotline-call-${hotline.number}'));
      await tester.ensureVisible(tile);
      expect(
        find.descendant(of: tile, matching: find.text(hotline.name)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: tile, matching: find.text(hotline.number)),
        findsOneWidget,
      );
      await tester.tap(tile);
      await tester.pumpAndSettle();
    }
    expect(launched, emergencyHotlines.map((h) => hotlineCallUri(h.number)));
  });

  testWidgets('large text fits hotline rows on narrow screen', (tester) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: const EmergencyHotlinesScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('boundary guidance does not fabricate neighboring contacts', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: EmergencyHotlineSection(nearBoundary: true),
          ),
        ),
      ),
    );
    expect(
      find.textContaining('No neighboring LGU dispatch is confirmed'),
      findsOneWidget,
    );
    expect(find.byType(ListTile), findsNWidgets(emergencyHotlines.length));
  });
}
