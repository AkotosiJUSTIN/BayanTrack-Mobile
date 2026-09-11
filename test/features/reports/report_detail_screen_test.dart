import 'dart:async';

import 'package:bayantrack_mobile/core/theme/app_theme.dart';
import 'package:bayantrack_mobile/features/auth/data/auth_models.dart';
import 'package:bayantrack_mobile/features/auth/presentation/barangays_provider.dart';
import 'package:bayantrack_mobile/features/reports/domain/entities/report.dart';
import 'package:bayantrack_mobile/features/reports/domain/entities/report_enums.dart';
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

Report _report({ReportStatus status = ReportStatus.inProgress}) => Report(
  id: 'RPT-DETAIL-UI-1',
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

  testWidgets('keeps the same hierarchy in dark mode', (tester) async {
    await _pumpDetail(tester, theme: AppTheme.dark);

    expect(find.text('Blocked drainage near the market'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
