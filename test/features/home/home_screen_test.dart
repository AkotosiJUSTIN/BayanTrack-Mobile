import 'package:bayantrack_mobile/core/domain/failures.dart';
import 'package:bayantrack_mobile/core/domain/result.dart';
import 'package:bayantrack_mobile/core/theme/app_colors.dart';
import 'package:bayantrack_mobile/core/theme/app_theme.dart';
import 'package:bayantrack_mobile/features/auth/data/user_permissions.dart';
import 'package:bayantrack_mobile/features/auth/domain/entities/user.dart';
import 'package:bayantrack_mobile/features/auth/presentation/auth_controller.dart';
import 'package:bayantrack_mobile/features/home/presentation/home_screen.dart';
import 'package:bayantrack_mobile/features/navigation/main_navigation_shell.dart';
import 'package:bayantrack_mobile/features/reports/domain/entities/paginated_reports.dart';
import 'package:bayantrack_mobile/features/reports/domain/entities/report.dart';
import 'package:bayantrack_mobile/features/reports/domain/entities/report_enums.dart';
import 'package:bayantrack_mobile/features/reports/domain/reports_repository.dart';
import 'package:bayantrack_mobile/features/reports/domain/usecases/get_reports_usecase.dart';
import 'package:bayantrack_mobile/features/reports/domain/usecases/get_my_reports_usecase.dart';
import 'package:bayantrack_mobile/features/reports/domain/usecases/update_report_usecase.dart';
import 'package:bayantrack_mobile/features/reports/presentation/report_labels.dart';
import 'package:bayantrack_mobile/features/reports/presentation/reports_controller.dart';
import 'package:bayantrack_mobile/features/reports/reports_di.dart';
import 'package:bayantrack_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

const _submittedReport = Report(
  id: 'submitted-1',
  title: 'Submitted report',
  description: 'Submitted report description',
  status: ReportStatus.submitted,
  latitude: 15.971,
  longitude: 120.571,
);

const _inProgressReport = Report(
  id: 'in-progress-1',
  title: 'In progress report',
  description: 'In progress report description',
  status: ReportStatus.inProgress,
  latitude: 15.972,
  longitude: 120.572,
);

const _fastReport = Report(
  id: 'fast-report-1',
  description: 'Floodwater is rising near the public market',
  isEmergency: true,
  priorityRulesApplied: ['quick_report_flag_set'],
  createdAt: null,
);

const _citizen = User(
  id: 'citizen-1',
  email: 'citizen@example.com',
  firstName: 'Test',
  lastName: 'Citizen',
  role: UserRole.citizen,
);

Widget _app(
  _ReportsRepositoryMock repository, {
  bool withNavigation = false,
  AuthState authState = const AuthInitial(),
  HomeScreen home = const HomeScreen(),
}) {
  return ProviderScope(
    retry: (_, _) => null,
    overrides: [
      getReportsUseCaseProvider.overrideWithValue(
        GetReportsUseCase(repository: repository),
      ),
      getMyReportsUseCaseProvider.overrideWithValue(
        GetMyReportsUseCase(repository: repository),
      ),
      updateReportUseCaseProvider.overrideWithValue(
        UpdateReportUseCase(repository: repository),
      ),
      authControllerProvider.overrideWithValue(authState),
      userPermissionsProvider.overrideWithValue(UserPermissions(null)),
    ],
    child: MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: withNavigation ? MainNavigationShell(screens: [home]) : home,
    ),
  );
}

void _stubMyReports(
  _ReportsRepositoryMock repository, {
  List<Report> reports = const [_fastReport],
}) {
  when(
    () => repository.getMyReports(
      page: 1,
      pageSize: 20,
      status: null,
      sortBy: 'date',
    ),
  ).thenAnswer((_) async => Success(PaginatedReports(results: reports)));
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
  test('resolved and closed share final green status colors', () {
    expect(reportMapStatusColor(ReportStatus.resolved), AppColors.success);
    expect(reportMapStatusColor(ReportStatus.closed), AppColors.success);
    expect(
      reportStatusForegroundColor(ReportStatus.resolved, AppTheme.light),
      AppColors.resolvedText,
    );
    expect(
      reportStatusForegroundColor(ReportStatus.closed, AppTheme.light),
      AppColors.resolvedText,
    );
  });

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

  testWidgets('map status chips filter loaded reports locally and toggle', (
    tester,
  ) async {
    final repository = _ReportsRepositoryMock();
    var calls = 0;
    _stubReports(repository, () async {
      calls++;
      return const Success(
        PaginatedReports(
          results: [_submittedReport, _inProgressReport, _resolvedReport],
          total: 3,
        ),
      );
    });

    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.location_on), findsNWidgets(3));
    expect(calls, 1);

    await tester.tap(find.byKey(const Key('home-map-status-resolved')));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.location_on), findsOneWidget);
    expect(calls, 1);

    await tester.tap(find.byKey(const Key('home-map-status-submitted')));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.location_on), findsNWidgets(2));

    await tester.tap(find.byKey(const Key('home-map-status-resolved')));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.location_on), findsOneWidget);

    await tester.tap(find.byKey(const Key('home-map-status-submitted')));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.location_on), findsNWidgets(3));
  });

  testWidgets('refresh preserves active local status filter', (tester) async {
    final repository = _ReportsRepositoryMock();
    var calls = 0;
    _stubReports(repository, () async {
      calls++;
      return calls == 1
          ? const Success(
              PaginatedReports(
                results: [_submittedReport, _resolvedReport],
                total: 2,
              ),
            )
          : const Success(
              PaginatedReports(
                results: [_resolvedReport, _inProgressReport],
                total: 2,
              ),
            );
    });

    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home-map-status-resolved')));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(HomeScreen)),
    );
    container.read(myReportsRefreshProvider.notifier).increment();
    await tester.pumpAndSettle();

    expect(calls, 2);
    expect(find.byIcon(Icons.location_on), findsOneWidget);
  });

  testWidgets('Fast Report follow-up can be dismissed per report', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final repository = _ReportsRepositoryMock();
    _stubReports(repository, () async => const Success(PaginatedReports.empty));
    _stubMyReports(repository);

    await tester.pumpWidget(
      _app(repository, authState: const AuthSuccess('ready', _citizen)),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('fast-report-follow-up-card')), findsOneWidget);
    await tester.tap(find.byKey(const Key('fast-report-dismiss')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('fast-report-follow-up-card')), findsNothing);
    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getString('fast_report_follow_up_v1_fast-report-1'),
      'dismissed',
    );
  });

  testWidgets('Fast Report details update completes the follow-up', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final repository = _ReportsRepositoryMock();
    _stubReports(repository, () async => const Success(PaginatedReports.empty));
    _stubMyReports(repository);
    when(
      () => repository.updateReport(
        id: _fastReport.id,
        title: null,
        description: any(named: 'description'),
      ),
    ).thenAnswer((_) async => const Success(_fastReport));

    await tester.pumpWidget(
      _app(repository, authState: const AuthSuccess('ready', _citizen)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('fast-report-add-details')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('fast-report-follow-up-details')),
      'Two homes are already affected',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final captured =
        verify(
              () => repository.updateReport(
                id: _fastReport.id,
                title: null,
                description: captureAny(named: 'description'),
              ),
            ).captured.single
            as String;
    expect(captured, contains(_fastReport.description));
    expect(captured, contains('Two homes are already affected'));
    expect(find.byKey(const Key('fast-report-follow-up-card')), findsNothing);
  });

  testWidgets('Fast Report image failure remains retryable', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final repository = _ReportsRepositoryMock();
    _stubReports(repository, () async => const Success(PaginatedReports.empty));
    _stubMyReports(repository);
    var attempts = 0;
    final home = HomeScreen(
      addFollowUpImageOverride: (_, source) async {
        expect(source, ImageSource.camera);
        attempts++;
        return attempts > 1;
      },
    );

    await tester.pumpWidget(
      _app(
        repository,
        authState: const AuthSuccess('ready', _citizen),
        home: home,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('fast-report-add-image')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Take Photo'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('fast-report-follow-up-error')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('fast-report-follow-up-card')), findsOneWidget);

    await tester.tap(find.byKey(const Key('fast-report-add-image')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Take Photo'));
    await tester.pumpAndSettle();
    expect(attempts, 2);
    expect(find.byKey(const Key('fast-report-follow-up-card')), findsNothing);
  });
}
