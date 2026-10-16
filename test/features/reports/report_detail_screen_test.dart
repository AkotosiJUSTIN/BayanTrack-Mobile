import 'dart:async';

import 'package:bayantrack_mobile/core/presentation/widgets/offline_stale_banner.dart';
import 'package:bayantrack_mobile/core/providers/backend_reachability_provider.dart';
import 'package:bayantrack_mobile/core/theme/app_theme.dart';
import 'package:bayantrack_mobile/core/domain/failures.dart';
import 'package:bayantrack_mobile/core/domain/result.dart';
import 'package:bayantrack_mobile/features/auth/data/auth_models.dart';
import 'package:bayantrack_mobile/features/auth/presentation/barangays_provider.dart';
import 'package:bayantrack_mobile/features/reports/domain/entities/report.dart';
import 'package:bayantrack_mobile/features/reports/domain/entities/report_enums.dart';
import 'package:bayantrack_mobile/features/reports/domain/entities/report_image.dart';
import 'package:bayantrack_mobile/features/reports/domain/entities/shared_incident.dart';
import 'package:bayantrack_mobile/features/reports/domain/entities/blockchain_verification.dart';
import 'package:bayantrack_mobile/features/reports/domain/reports_repository.dart';
import 'package:bayantrack_mobile/features/reports/reports_di.dart';
import 'package:bayantrack_mobile/features/reports/presentation/report_detail_controller.dart';
import 'package:bayantrack_mobile/features/reports/presentation/report_detail_screen.dart';
import 'package:bayantrack_mobile/features/reports/presentation/shared_incident_provider.dart';
import 'package:bayantrack_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _ReportsMock extends Mock implements ReportsRepository {}

class _TestDetailController extends ReportDetailController {
  _TestDetailController(this.report);
  final Report report;
  @override
  Future<Report> build(String reportId) async {
    isFresh = !report.isStale;
    return report;
  }
}

class _TestMunicipalities extends Municipalities {
  @override
  FutureOr<List<MunicipalityModel>> build() => const [
    bundledUrdanetaMunicipality,
  ];
}

class _TestReachability extends BackendReachabilityNotifier {
  @override
  BackendReachability build() => BackendReachability.reachable;
}

Report _report({
  ReportStatus status = ReportStatus.inProgress,
  bool withProof = false,
  bool isStale = false,
  DateTime? citizenVerifiedAt,
  bool? citizenConfirmedResolved,
  String? incidentGroupId,
}) => Report(
  id: 'RPT-DETAIL-UI-1',
  protectedSnapshotToken: status.name,
  isStale: isStale,
  title: 'Blocked drainage near the market',
  description: 'Water is collecting beside the public market.',
  status: status,
  category: ReportCategory.floodDisaster,
  queuePriorityLevel: PriorityLevel.high,
  streetLandmark: 'Market Road gate',
  barangay: 'Poblacion',
  cityMunicipality: 'Urdaneta City',
  zone: 'Zone 3',
  assignedDepartment: 'City Engineering Office',
  images: withProof
      ? const [ReportImage(id: 'proof-1', url: 'https://example.com/proof.jpg')]
      : const [],
  resolvedProofImageIds: withProof ? const ['proof-1'] : const [],
  createdAt: DateTime(2026, 8, 27, 9, 30),
  verifiedAt: DateTime(2026, 8, 27, 11),
  citizenVerifiedAt: citizenVerifiedAt,
  citizenConfirmedResolved: citizenConfirmedResolved,
  incidentGroupId: incidentGroupId,
  linkedReportCount: incidentGroupId == null ? 1 : 3,
);

Future<void> _pumpDetail(
  WidgetTester tester, {
  ThemeData? theme,
  Report? report,
  ReportsRepository? repository,
}) async {
  if (repository == null) {
    final mock = _ReportsMock();
    when(
      () => mock.verifyReport('RPT-DETAIL-UI-1', cachedOnly: true),
    ).thenAnswer((_) async => const Err(ServerFailure('No saved proof')));
    repository = mock;
  }
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        reportsRepositoryDomainProvider.overrideWithValue(repository),
        municipalitiesProvider.overrideWith(_TestMunicipalities.new),
        backendReachabilityProvider.overrideWith(_TestReachability.new),
        reportDetailControllerProvider(
          'RPT-DETAIL-UI-1',
        ).overrideWith(() => _TestDetailController(report ?? _report())),
        sharedIncidentProvider('RPT-DETAIL-UI-1').overrideWith(
          (_) async => const SharedIncident(
            groupId: 'group-1',
            status: 'in_progress',
            reportCount: 3,
          ),
        ),
      ],
      child: MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: theme ?? AppTheme.light,
        home: const ReportDetailScreen(reportId: 'RPT-DETAIL-UI-1'),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  testWidgets(
    'automatic cached lookup and manual taps do not duplicate checks',
    (tester) async {
      final repository = _ReportsMock();
      final saved = Completer<Result<BlockchainVerificationResult>>();
      when(
        () => repository.verifyReport('RPT-DETAIL-UI-1', cachedOnly: true),
      ).thenAnswer((_) => saved.future);
      when(() => repository.verifyReport('RPT-DETAIL-UI-1')).thenAnswer(
        (_) async => const Success(
          BlockchainVerificationResult(
            reportId: 'RPT-DETAIL-UI-1',
            verified: true,
            currentContentVerified: true,
            originalSnapshotVerified: true,
            protectedSnapshotToken: 'inProgress',
            blockchainData: {},
            auditHistory: [],
            message: 'proof',
          ),
        ),
      );
      await _pumpDetail(tester, repository: repository);
      await tester.scrollUntilVisible(find.text('Report record check'), 400);
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      verifyNever(() => repository.verifyReport('RPT-DETAIL-UI-1'));
      saved.complete(const Err(ServerFailure('No saved proof')));
      await tester.pumpAndSettle();
      expect(
        find.text('The report details match the protected record.'),
        findsOneWidget,
      );
      verify(() => repository.verifyReport('RPT-DETAIL-UI-1')).called(1);
    },
  );

  testWidgets('report snapshot update rejects an older in-flight check', (
    tester,
  ) async {
    final repository = _ReportsMock();
    final pending = Completer<Result<BlockchainVerificationResult>>();
    var calls = 0;
    when(
      () => repository.verifyReport('RPT-DETAIL-UI-1', cachedOnly: true),
    ).thenAnswer((_) async => const Err(ServerFailure('No proof')));
    when(() => repository.verifyReport('RPT-DETAIL-UI-1')).thenAnswer(
      (_) => ++calls == 1
          ? pending.future
          : Future.value(
              const Success(
                BlockchainVerificationResult(
                  reportId: 'RPT-DETAIL-UI-1',
                  verified: false,
                  connectionError: true,
                  protectedSnapshotToken: 'resolved',
                  blockchainData: {},
                  auditHistory: [],
                  message: 'unavailable',
                ),
              ),
            ),
    );
    when(
      () => repository.getReport('RPT-DETAIL-UI-1'),
    ).thenAnswer((_) async => Success(_report(status: ReportStatus.resolved)));
    await _pumpDetail(tester, repository: repository);
    await tester.scrollUntilVisible(find.text('Report record check'), 400);
    await tester.pump();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ReportDetailScreen)),
    );
    await container
        .read(reportDetailControllerProvider('RPT-DETAIL-UI-1').notifier)
        .refresh();
    await tester.pumpAndSettle();
    pending.complete(
      const Success(
        BlockchainVerificationResult(
          reportId: 'RPT-DETAIL-UI-1',
          verified: true,
          currentContentVerified: true,
          originalSnapshotVerified: true,
          protectedSnapshotToken: 'inProgress',
          blockchainData: {},
          auditHistory: [],
          message: 'obsolete',
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('The report details match the protected record.'),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'loads shared verified and anchored proof without tapping verify',
    (tester) async {
      final repository = _ReportsMock();
      when(
        () => repository.verifyReport('RPT-DETAIL-UI-1', cachedOnly: true),
      ).thenAnswer(
        (_) async => const Success(
          BlockchainVerificationResult(
            reportId: 'RPT-DETAIL-UI-1',
            verified: true,
            currentContentVerified: true,
            originalSnapshotVerified: true,
            protectedSnapshotToken: 'inProgress',
            isAnchored: true,
            blockchainData: {},
            auditHistory: [],
            message: 'Previously verified and anchored',
          ),
        ),
      );
      await _pumpDetail(tester, repository: repository);
      await tester.scrollUntilVisible(find.text('Report details match'), 400);
      expect(
        find.text('The report details match the protected record.'),
        findsOneWidget,
      );
      expect(find.text('Previously verified and anchored'), findsNothing);
      verify(
        () => repository.verifyReport('RPT-DETAIL-UI-1', cachedOnly: true),
      ).called(1);
      verifyNever(() => repository.verifyReport('RPT-DETAIL-UI-1'));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'unexpected verification exception clears spinner and permits retry',
    (tester) async {
      final repository = _ReportsMock();
      when(
        () => repository.verifyReport('RPT-DETAIL-UI-1', cachedOnly: true),
      ).thenAnswer((_) async => const Err(ServerFailure('No saved proof')));
      when(
        () => repository.verifyReport('RPT-DETAIL-UI-1'),
      ).thenThrow(StateError('Unexpected failure'));
      await _pumpDetail(tester, repository: repository);
      await tester.scrollUntilVisible(find.text('Check record'), 400);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Check record'));
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      await tester.ensureVisible(find.text('Check record'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Check record'));
      await tester.pumpAndSettle();
      verify(() => repository.verifyReport('RPT-DETAIL-UI-1')).called(3);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'pending checkpoint never displays a mismatch or a verified claim',
    (tester) async {
      final repository = _ReportsMock();
      when(
        () => repository.verifyReport('RPT-DETAIL-UI-1', cachedOnly: true),
      ).thenAnswer((_) async => const Err(ServerFailure('No proof')));
      when(() => repository.verifyReport('RPT-DETAIL-UI-1')).thenAnswer(
        (_) async => const Success(
          BlockchainVerificationResult(
            reportId: 'RPT-DETAIL-UI-1',
            verified: false,
            verificationPending: true,
            reason: 'checkpoint_pending',
            verificationState: 'UNVERIFIED',
            currentContentVerified: null,
            protectedSnapshotToken: 'inProgress',
            blockchainData: {},
            auditHistory: [],
            message: 'pending',
          ),
        ),
      );
      await _pumpDetail(tester, repository: repository);
      await tester.scrollUntilVisible(
        find.text('Protected record update pending'),
        400,
      );
      await tester.pump();
      expect(find.text('Protected record update pending'), findsOneWidget);
      expect(find.text("Report details don't match"), findsNothing);
      expect(
        find.text('The report details match the protected record.'),
        findsNothing,
      );
    },
  );

  testWidgets('marks cached report details as stale', (tester) async {
    await _pumpDetail(tester, report: _report(isStale: true));

    expect(find.byType(OfflineStaleBanner), findsOneWidget);
    expect(
      find.textContaining("We're having trouble connecting. Saved reports"),
      findsOneWidget,
    );
  });

  testWidgets('keeps report details scannable on a narrow phone', (
    tester,
  ) async {
    await _pumpDetail(tester);

    expect(find.text('Blocked drainage near the market'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Market Road gate'), findsOneWidget);
    expect(find.text('Team handling this report'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp(r'^Review priority: High')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the citizen close action for a resolved report', (
    tester,
  ) async {
    await _pumpDetail(tester, report: _report(status: ReportStatus.resolved));

    expect(find.text('Review the response'), findsOneWidget);
  });

  testWidgets('group member keeps independent citizen review and status', (
    tester,
  ) async {
    await _pumpDetail(
      tester,
      report: _report(
        status: ReportStatus.resolved,
        incidentGroupId: 'group-1',
      ),
    );

    expect(find.text('Linked to a shared incident'), findsOneWidget);
    expect(find.text('Incident status: In Progress'), findsOneWidget);
    expect(find.text('Review the response'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'restores review action after a disputed report is resolved again',
    (tester) async {
      await _pumpDetail(
        tester,
        report: _report(
          status: ReportStatus.resolved,
          citizenVerifiedAt: DateTime(2026, 10, 12),
          citizenConfirmedResolved: false,
        ),
      );

      expect(find.text('Review the response'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  for (final confirmed in [true, null]) {
    testWidgets(
      'confirmed or legacy reviewed report hides review action ($confirmed)',
      (tester) async {
        await _pumpDetail(
          tester,
          report: _report(
            status: ReportStatus.resolved,
            citizenVerifiedAt: DateTime(2026, 10, 12),
            citizenConfirmedResolved: confirmed,
          ),
        );

        expect(find.text('Review the response'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('opens resolved response evidence in a zoomable gallery', (
    tester,
  ) async {
    await _pumpDetail(
      tester,
      report: _report(status: ReportStatus.resolved, withProof: true),
    );

    await tester.ensureVisible(
      find
          .byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                widget.properties.label == 'Response evidence 1',
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.bySemanticsLabel(RegExp(r'^Response evidence 1$')).first,
    );
    await tester.pumpAndSettle();

    expect(find.byType(InteractiveViewer), findsOneWidget);
    expect(
      find.ancestor(
        of: find.byType(InteractiveViewer),
        matching: find.byType(PageView),
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'changed content shows original snapshot proof without current success',
    (tester) async {
      final repository = _ReportsMock();
      when(
        () => repository.verifyReport('RPT-DETAIL-UI-1', cachedOnly: true),
      ).thenAnswer((_) async => const Err(ServerFailure('No saved proof')));
      when(() => repository.verifyReport('RPT-DETAIL-UI-1')).thenAnswer(
        (_) async => const Success(
          BlockchainVerificationResult(
            reportId: 'RPT-DETAIL-UI-1',
            verified: false,
            originalSnapshotVerified: true,
            currentContentVerified: false,
            blockchainData: {},
            auditHistory: [],
            message: 'Changed content',
          ),
        ),
      );
      await _pumpDetail(tester, repository: repository);
      final l10n = AppLocalizations.of(
        tester.element(find.byType(ReportDetailScreen)),
      );
      final button = find.text(l10n.verifyNow);
      await tester.scrollUntilVisible(button, 400);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.text(l10n.originalSnapshotVerified), findsOneWidget);
      expect(find.text(l10n.currentContentChanged), findsOneWidget);
      expect(find.text(l10n.integrityVerified), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('keeps the same hierarchy in dark mode', (tester) async {
    await _pumpDetail(tester, theme: AppTheme.dark);

    expect(find.text('Blocked drainage near the market'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
