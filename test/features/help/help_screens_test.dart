import 'package:bayantrack_mobile/features/help/data/help_content.dart';
import 'package:bayantrack_mobile/features/help/presentation/help_screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('FAQ remains available offline and expands answers', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HelpFaqScreen()));

    expect(find.text('Frequently Asked Questions'), findsOneWidget);
    expect(find.byKey(const ValueKey('help-faq-search')), findsOneWidget);

    await tester.tap(find.text('Getting Started'));
    await tester.pumpAndSettle();
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

    await tester.tap(find.text('Call 911'));
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

    expect(
      find.text('No verified hotline numbers are available.'),
      findsOneWidget,
    );
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
        find.textContaining('does not replace emergency services'),
        findsOneWidget,
      );
    },
  );

  test('searchable FAQ content is bundled without a backend provider', () {
    expect(helpFaqCategories, isNotEmpty);
    expect(filterHelpFaqCategories('resolution'), isNotEmpty);
  });
}
