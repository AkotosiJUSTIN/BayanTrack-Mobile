import 'dart:async';

import 'package:bayantrack_mobile/core/presentation/widgets/offline_stale_banner.dart';
import 'package:bayantrack_mobile/core/providers/backend_reachability_provider.dart';
import 'package:bayantrack_mobile/core/theme/app_theme.dart';
import 'package:bayantrack_mobile/features/auth/data/auth_models.dart';
import 'package:bayantrack_mobile/features/auth/presentation/barangays_provider.dart';
import 'package:bayantrack_mobile/features/reports/domain/entities/report.dart';
import 'package:bayantrack_mobile/features/reports/domain/entities/report_enums.dart';
import 'package:bayantrack_mobile/features/reports/domain/entities/report_image.dart';
import 'package:bayantrack_mobile/features/reports/presentation/report_detail_controller.dart';
import 'package:bayantrack_mobile/features/reports/presentation/report_detail_screen.dart';
import 'package:bayantrack_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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
}) => Report(
  id: 'RPT-DETAIL-UI-1',
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
);

Future<void> _pumpDetail(
  WidgetTester tester, {
  ThemeData? theme,
  Report? report,
}) async {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        municipalitiesProvider.overrideWith(_TestMunicipalities.new),
        backendReachabilityProvider.overrideWith(_TestReachability.new),
        reportDetailControllerProvider.overrideWithBuild(
          (_, _) async => report ?? _report(),
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
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('marks cached report details as stale', (tester) async {
    await _pumpDetail(tester, report: _report(isStale: true));

    expect(find.byType(OfflineStaleBanner), findsOneWidget);
    expect(
      find.textContaining('Backend unavailable. Showing saved reports'),
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
    expect(find.text('Current handler'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp(r'^Operational priority: High')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the citizen close action for a resolved report', (
    tester,
  ) async {
    await _pumpDetail(tester, report: _report(status: ReportStatus.resolved));

    expect(find.text('Review & Sign Off'), findsOneWidget);
  });

  testWidgets('opens resolved response evidence in a zoomable gallery', (
    tester,
  ) async {
    await _pumpDetail(
      tester,
      report: _report(status: ReportStatus.resolved, withProof: true),
    );

    await tester.tap(
      find.bySemanticsLabel(RegExp(r'^Resolution proof 1$')).first,
    );
    await tester.pumpAndSettle();

    expect(find.byType(InteractiveViewer), findsOneWidget);
    expect(find.byType(PageView), findsOneWidget);
  });

  testWidgets('keeps the same hierarchy in dark mode', (tester) async {
    await _pumpDetail(tester, theme: AppTheme.dark);

    expect(find.text('Blocked drainage near the market'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
