import 'dart:async';

import 'package:bayantrack_mobile/core/domain/failures.dart';
import 'package:bayantrack_mobile/core/domain/result.dart';
import 'package:bayantrack_mobile/core/theme/app_theme.dart';
import 'package:bayantrack_mobile/features/reports/data/mappers/report_mapper.dart';
import 'package:bayantrack_mobile/features/reports/data/report_models.dart'
    as dto;
import 'package:bayantrack_mobile/features/reports/domain/entities/report.dart';
import 'package:bayantrack_mobile/features/reports/domain/entities/report_enums.dart';
import 'package:bayantrack_mobile/features/reports/domain/reports_repository.dart';
import 'package:bayantrack_mobile/features/reports/presentation/citizen_review_screen.dart';
import 'package:bayantrack_mobile/features/reports/presentation/report_detail_controller.dart';
import 'package:bayantrack_mobile/features/reports/reports_di.dart';
import 'package:bayantrack_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _ReportsMock extends Mock implements ReportsRepository {}

const _report = Report(
  id: 'RPT-DISPUTE-1',
  description: 'Synthetic resolved report',
  status: ReportStatus.resolved,
  adminRemarks: 'The Department repaired the issue.',
);

const _success = Success<Map<String, dynamic>>({
  'message': 'The report was reopened.',
  'satisfied': false,
  'report_status': 'escalated',
});

const _reasonKey = ValueKey('citizen-review-dispute-reason');
const _submitKey = ValueKey('citizen-review-dispute-submit');

Future<void> _pumpReview(
  WidgetTester tester,
  ReportsRepository repository, {
  Report report = _report,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        reportsRepositoryDomainProvider.overrideWithValue(repository),
        reportDetailControllerProvider.overrideWithBuild(
          (_, _) async => report,
        ),
      ],
      child: MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => CitizenReviewScreen(report: report),
                ),
              ),
              child: const Text('Open review'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Open review'));
  await tester.pumpAndSettle();
}

Future<void> _openDispute(WidgetTester tester) async {
  final button = find.byKey(const ValueKey('citizen-review-dispute'));
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void _stubDispute(
  _ReportsMock repository,
  Future<Result<Map<String, dynamic>>> Function(Invocation) respond,
) {
  when(
    () => repository.citizenCloseReport(
      id: _report.id,
      satisfied: false,
      rating: any(named: 'rating'),
      note: any(named: 'note'),
      reason: any(named: 'reason'),
      signatureImageId: any(named: 'signatureImageId'),
      signatureName: any(named: 'signatureName'),
    ),
  ).thenAnswer(respond);
}

void main() {
  testWidgets(
    'successful dispute closes both routes without lifecycle errors',
    (tester) async {
      final repository = _ReportsMock();
      final calls = <Invocation>[];
      _stubDispute(repository, (call) async {
        calls.add(call);
        return _success;
      });
      await _pumpReview(tester, repository);
      await _openDispute(tester);
      await tester.enterText(
        find.byKey(_reasonKey),
        '  The repair failed after rain.  ',
      );
      await tester.tap(find.byKey(_submitKey));
      await tester.pumpAndSettle();

      expect(calls, hasLength(1));
      expect(
        calls.single.namedArguments[#reason],
        'The repair failed after rain.',
      );
      expect(calls.single.namedArguments[#signatureImageId], isNull);
      expect(calls.single.namedArguments[#signatureName], isNull);
      expect(find.byType(CitizenReviewScreen), findsNothing);
      expect(find.text('Open review'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('failed dispute preserves its reason and can succeed on retry', (
    tester,
  ) async {
    final repository = _ReportsMock();
    var calls = 0;
    _stubDispute(repository, (_) async {
      calls++;
      if (calls == 1) return const Err(NetworkFailure('Connection lost.'));
      return _success;
    });
    await _pumpReview(tester, repository);
    await _openDispute(tester);
    await tester.enterText(
      find.byKey(_reasonKey),
      'The drain is still blocked.',
    );
    await tester.tap(find.byKey(_submitKey));
    await tester.pumpAndSettle();

    expect(calls, 1);
    expect(find.text('Connection lost.'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byKey(_reasonKey)).controller!.text,
      'The drain is still blocked.',
    );
    await tester.tap(find.byKey(_submitKey));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.byType(CitizenReviewScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('canceling a focused dispute sheet safely returns to review', (
    tester,
  ) async {
    await _pumpReview(tester, _ReportsMock());
    await _openDispute(tester);
    final reason = find.byKey(_reasonKey);
    await tester.enterText(reason, 'Still unresolved.');
    Navigator.of(tester.element(reason)).pop();
    await tester.pumpAndSettle();

    expect(find.byKey(_reasonKey), findsNothing);
    expect(find.byType(CitizenReviewScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _openDispute(tester);
    expect(
      tester.widget<TextField>(find.byKey(_reasonKey)).controller!.text,
      isEmpty,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('pending dispute prevents duplicate submissions', (tester) async {
    final repository = _ReportsMock();
    final pending = Completer<Result<Map<String, dynamic>>>();
    var calls = 0;
    _stubDispute(repository, (_) {
      calls++;
      return pending.future;
    });
    await _pumpReview(tester, repository);
    await _openDispute(tester);
    await tester.enterText(find.byKey(_reasonKey), 'Still unresolved.');
    await tester.tap(find.byKey(_submitKey));
    await tester.pump();
    expect(
      tester.widget<FilledButton>(find.byKey(_submitKey)).onPressed,
      isNull,
    );
    await tester.tap(find.byKey(_submitKey));
    await tester.pump();
    expect(calls, 1);
    pending.complete(_success);
    await tester.pumpAndSettle();
    expect(find.byType(CitizenReviewScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('new resolution after dispute permits confirmation and dispute', (
    tester,
  ) async {
    final report = ReportMapper.fromDto(
      dto.Report.fromJson({
        'id': _report.id,
        'description': _report.description,
        'status': 'resolved',
        'citizen_verified_at': '2026-10-12T08:00:00Z',
        'citizen_confirmed_resolved': false,
        'citizen_closure_note': 'The drain is still blocked.',
        'resolved_at': '2026-10-14T08:00:00Z',
      }),
    );
    await _pumpReview(tester, _ReportsMock(), report: report);
    expect(
      find.byKey(const ValueKey('citizen-review-dispute')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('citizen-review-confirm')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
