import 'package:bayantrack_mobile/core/domain/failures.dart';
import 'package:bayantrack_mobile/core/domain/result.dart';
import 'package:bayantrack_mobile/features/auth/data/user_permissions.dart';
import 'package:bayantrack_mobile/features/home/presentation/home_screen.dart';
import 'package:bayantrack_mobile/features/navigation/main_navigation_shell.dart';
import 'package:bayantrack_mobile/features/reports/domain/entities/paginated_reports.dart';
import 'package:bayantrack_mobile/features/reports/domain/entities/report.dart';
import 'package:bayantrack_mobile/features/reports/domain/entities/report_enums.dart';
import 'package:bayantrack_mobile/features/reports/domain/reports_repository.dart';
import 'package:bayantrack_mobile/features/reports/domain/usecases/get_reports_usecase.dart';
import 'package:bayantrack_mobile/features/reports/presentation/reports_controller.dart';
import 'package:bayantrack_mobile/features/reports/reports_di.dart';
import 'package:bayantrack_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _ReportsRepositoryMock extends Mock implements ReportsRepository {}

const _resolvedReport = Report(
  id: 'resolved-1',
  title: 'Resolved report',
  description: 'Resolved report description',
  status: ReportStatus.resolved,
  latitude: 15.97,
  longitude: 120.57,
);

const _closedReport = Report(
  id: 'closed-1',
  title: 'Closed report',
  description: 'Closed report description',
  status: ReportStatus.closed,
  latitude: 15.97,
  longitude: 120.57,
);

Widget _app(_ReportsRepositoryMock repository, {bool withNavigation = false}) {
  return ProviderScope(
    retry: (_, _) => null,
    overrides: [
      getReportsUseCaseProvider.overrideWithValue(
        GetReportsUseCase(repository: repository),
      ),
      userPermissionsProvider.overrideWithValue(UserPermissions(null)),
    ],
    child: MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: withNavigation
          ? const MainNavigationShell(screens: [HomeScreen()])
          : const HomeScreen(),
    ),
  );
}

void _stubReports(
  _ReportsRepositoryMock repository,
  Future<Result<PaginatedReports>> Function() load,
) {
  when(
    () => repository.getReports(
      page: 1,
      pageSize: 20,
      status: null,
      zone: null,
      category: null,
      sortBy: 'date',
    ),
  ).thenAnswer((_) => load());
}

void main() {
  test(
    'Home policy keeps resolved reports but removes final/duplicate entries',
    () {
      final active = const Report(
        id: 'active-1',
        description: 'Active report',
        status: ReportStatus.inProgress,
      );
      final replacement = const Report(
        id: 'active-1',
        description: 'Updated active report',
        status: ReportStatus.assigned,
      );

      expect(isHomeReportVisible(_resolvedReport), isTrue);
      expect(isHomeReportVisible(_closedReport), isFalse);
      expect(mergeHomeReports([active], [replacement]), [replacement]);
      expect(
        mergeHomeReports(
          [active],
          [
            const Report(
              id: 'active-1',
              description: 'Closed replacement',
              status: ReportStatus.closed,
            ),
          ],
        ),
        isEmpty,
      );
    },
  );

  testWidgets('Home initializes public reports provider on first build', (
    tester,
  ) async {
    final repository = _ReportsRepositoryMock();
    var calls = 0;
    _stubReports(repository, () async {
      calls++;
      return const Success(PaginatedReports(results: [], total: 0));
    });

    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    expect(calls, 1);
  });

  testWidgets('Home retry emits a fresh public reports request after failure', (
    tester,
  ) async {
    final repository = _ReportsRepositoryMock();
    var calls = 0;
    _stubReports(repository, () async {
      calls++;
      if (calls == 1) return const Err(NetworkFailure('offline'));
      return const Success(PaginatedReports(results: [], total: 0));
    });

    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsWidgets);

    await tester.tap(find.widgetWithText(FilledButton, 'Retry'));
    await tester.pumpAndSettle();

    expect(calls, 2);
  });

  testWidgets('Home empty state scrolls with verification banner and nav', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final repository = _ReportsRepositoryMock();
    _stubReports(
      repository,
      () async => const Success(PaginatedReports(results: [], total: 0)),
    );

    await tester.pumpWidget(_app(repository, withNavigation: true));
    await tester.pumpAndSettle();

    expect(find.text('User Verification'), findsOneWidget);
    expect(find.text('No reports found'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Home removes a closed marker after report refresh invalidation',
    (tester) async {
      final repository = _ReportsRepositoryMock();
      var calls = 0;
      _stubReports(repository, () async {
        calls++;
        return calls == 1
            ? const Success(
                PaginatedReports(results: [_resolvedReport], total: 1),
              )
            : const Success(
                PaginatedReports(results: [_closedReport], total: 1),
              );
      });

      await tester.pumpWidget(_app(repository));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.location_on), findsOneWidget);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(HomeScreen)),
      );
      container.read(myReportsRefreshProvider.notifier).increment();
      await tester.pumpAndSettle();

      expect(calls, 2);
      expect(find.byIcon(Icons.location_on), findsNothing);
    },
  );
}
