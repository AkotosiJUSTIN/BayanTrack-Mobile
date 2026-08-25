import 'package:bayantrack_mobile/core/theme/app_theme.dart';
import 'package:bayantrack_mobile/features/reports/domain/entities/report.dart';
import 'package:bayantrack_mobile/features/reports/presentation/citizen_review_screen.dart';
import 'package:bayantrack_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Report _resolvedReport() => const Report(
      id: 'RPT-UI-1',
      reportId: 'RPT-UI-1',
      description: 'Synthetic resolved report',
      status: ReportStatus.resolved,
      adminRemarks: 'The Department repaired the reported issue.',
    );

Future<void> _pumpReview(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
}) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.light,
        home: CitizenReviewScreen(report: _resolvedReport()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows awaiting confirmation hierarchy and collapsed dispute form',
      (tester) async {
    await _pumpReview(tester);

    expect(find.text('Awaiting your confirmation'), findsOneWidget);
    expect(find.text('Department resolution summary'), findsOneWidget);
    expect(find.text('Response evidence'), findsOneWidget);
    expect(find.byKey(const ValueKey('citizen-review-dispute-reason')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('citizen-review-dispute')));
    await tester.pumpAndSettle();

    expect(find.text('Reason for dispute'), findsOneWidget);
    await tester.tap(
      find.byKey(const ValueKey('citizen-review-dispute-submit')),
    );
    await tester.pump();
    expect(find.text('Please explain what remains unresolved.'), findsOneWidget);
  });

  testWidgets('renders the citizen review hierarchy in Filipino', (tester) async {
    await _pumpReview(tester, locale: const Locale('fil'));

    expect(find.text('Hinihintay ang iyong kumpirmasyon'), findsOneWidget);
    expect(find.text('Buod ng resolusyon ng Departamento'), findsOneWidget);
    expect(find.bySemanticsLabel('I-rate ang Tugon (opsyonal): 1'), findsOneWidget);
  });
}
