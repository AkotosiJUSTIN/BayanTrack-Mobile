import 'package:bayantrack_mobile/features/reports/data/report_draft_store.dart';
import 'package:bayantrack_mobile/features/reports/presentation/new_report/report_draft_prompt.dart';
import 'package:bayantrack_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('start new replaces only after clear confirmation', (
    tester,
  ) async {
    final draft = _draft();
    Future<ReportDraftAction?>? result;
    await tester.pumpWidget(
      _app(() {
        result = showReportDraftPrompt(
          tester.element(find.byKey(const Key('open'))),
          draft: draft,
        );
      }),
    );

    await tester.tap(find.byKey(const Key('open')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start New'));
    await tester.pumpAndSettle();
    expect(
      find.text('The saved report will be replaced with a new draft.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Discard Draft'));
    await tester.pumpAndSettle();

    expect(await result, ReportDraftAction.startNew);
  });

  testWidgets('discard can be canceled to keep the existing draft', (
    tester,
  ) async {
    Future<ReportDraftAction?>? result;
    await tester.pumpWidget(
      _app(() {
        result = showReportDraftPrompt(
          tester.element(find.byKey(const Key('open'))),
          draft: _draft(),
        );
      }),
    );

    await tester.tap(find.byKey(const Key('open')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard Draft'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keep Draft'));
    await tester.pumpAndSettle();

    expect(await result, isNull);
  });
}

Widget _app(VoidCallback open) => MaterialApp(
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  home: Builder(
    builder: (context) => Scaffold(
      body: ElevatedButton(
        key: const Key('open'),
        onPressed: open,
        child: const Text('Open'),
      ),
    ),
  ),
);

ReportDraft _draft() {
  final now = DateTime.utc(2026, 9, 27);
  return ReportDraft(
    schemaVersion: ReportDraft.currentSchemaVersion,
    draftId: 'draft-1',
    ownerId: 'user-A',
    type: ReportDraftType.full,
    createdAt: now,
    updatedAt: now,
    resumeStep: 'details',
    payload: const {},
    attachmentRefs: const [],
  );
}
