import 'dart:io';
import 'dart:ui' as ui;

import 'package:bayantrack_mobile/core/domain/failures.dart';
import 'package:bayantrack_mobile/core/domain/result.dart';
import 'package:bayantrack_mobile/core/presentation/widgets/offline_stale_banner.dart';
import 'package:bayantrack_mobile/core/providers/backend_reachability_provider.dart';
import 'package:bayantrack_mobile/core/theme/app_colors.dart';
import 'package:bayantrack_mobile/core/theme/app_theme.dart';
import 'package:bayantrack_mobile/features/auth/data/user_permissions.dart';
import 'package:bayantrack_mobile/features/auth/domain/entities/user.dart';
import 'package:bayantrack_mobile/features/auth/presentation/auth_controller.dart';
import 'package:bayantrack_mobile/features/auth/presentation/barangays_provider.dart';
import 'package:bayantrack_mobile/features/home/presentation/home_screen.dart';
import 'package:bayantrack_mobile/core/providers/theme_provider.dart';
import 'package:bayantrack_mobile/features/app_updates/presentation/app_update_controller.dart';
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
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_updates/app_update_fakes.dart';

class _ReportsRepositoryMock extends Mock implements ReportsRepository {}

class _TestMunicipalities extends Municipalities {
  @override
  build() => const [bundledUrdanetaMunicipality];
}

class _TestReachability extends BackendReachabilityNotifier {
  @override
  BackendReachability build() => BackendReachability.reachable;

  void setReachability(BackendReachability value) => state = value;
}

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
  BackendReachabilityNotifier Function()? reachabilityBuilder,
  ThemeData? theme,
  Locale? locale,
  double textScale = 1,
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
      backendReachabilityProvider.overrideWith(
        reachabilityBuilder ?? _TestReachability.new,
      ),
      userPermissionsProvider.overrideWithValue(UserPermissions(null)),
      municipalitiesProvider.overrideWith(_TestMunicipalities.new),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      locale: locale,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
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
  testWidgets('Home header checks versions and reports current installation', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = _ReportsRepositoryMock();
    _stubReports(repository, () async => const Success(PaginatedReports.empty));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPrefsProvider.overrideWithValue(preferences),
          appUpdateRepositoryProvider.overrideWithValue(
            FakeAppUpdateRepository(),
          ),
        ],
        child: _app(repository),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byTooltip('Check app version'), findsOneWidget);
    await tester.tap(find.byKey(const Key('app-version-check')));
    await tester.pumpAndSettle();
    expect(find.text('Your app is up to date.'), findsOneWidget);
    expect(find.text('Installed: 1.0.0+1004'), findsOneWidget);
  });

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (_) async => Directory.systemTemp.path,
        );
  });

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

    expect(find.text('Verify Identity'), findsOneWidget);
    expect(find.text('No reports found'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home verification starts compact and details toggle', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repository = _ReportsRepositoryMock();
    _stubReports(repository, () async => const Success(PaginatedReports.empty));

    await tester.pumpWidget(_app(repository, withNavigation: true));
    await tester.pumpAndSettle();
    final banner = find.byKey(const Key('home-verification-banner'));
    final compactHeight = tester.getSize(banner).height;
    expect(compactHeight, lessThanOrEqualTo(56));
    expect(find.text('Verify Identity'), findsOneWidget);
    expect(find.text('User Verification'), findsNothing);

    await tester.tap(find.byKey(const Key('home-verification-toggle')));
    await tester.pumpAndSettle();
    expect(find.text('User Verification'), findsOneWidget);
    expect(
      find.text('Complete identity verification to unlock all features.'),
      findsOneWidget,
    );
    expect(tester.getSize(banner).height, greaterThan(compactHeight));

    await tester.tap(find.byKey(const Key('home-verification-toggle')));
    await tester.pumpAndSettle();
    expect(tester.getSize(banner).height, compactHeight);
    expect(find.text('User Verification'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home legend starts compact and retains filters when collapsed', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repository = _ReportsRepositoryMock();
    _stubReports(
      repository,
      () async => const Success(
        PaginatedReports(results: [_submittedReport, _resolvedReport]),
      ),
    );
    await tester.pumpWidget(_app(repository, withNavigation: true));
    await tester.pumpAndSettle();
    final toggle = find.byKey(const Key('home-map-legend-toggle'));
    final resolved = find.byKey(const Key('home-map-status-resolved'));
    expect(toggle, findsOneWidget);
    expect(resolved, findsNothing);
    expect(find.byIcon(Icons.location_on), findsNWidgets(2));

    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(resolved, findsOneWidget);
    await tester.ensureVisible(resolved);
    await tester.tap(resolved);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.location_on), findsOneWidget);

    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(resolved, findsNothing);
    expect(find.byIcon(Icons.location_on), findsOneWidget);

    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(tester.widget<FilterChip>(resolved).selected, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home compact controls fit Filipino and enlarged phone text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repository = _ReportsRepositoryMock();
    _stubReports(
      repository,
      () async => const Success(
        PaginatedReports(results: [_submittedReport, _resolvedReport]),
      ),
    );
    await tester.pumpWidget(
      _app(
        repository,
        withNavigation: true,
        locale: const Locale('fil'),
        textScale: 1.5,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home-verification-toggle')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home-map-legend-toggle')));
    await tester.pumpAndSettle();
    expect(find.text('Mga kulay ng pin'), findsOneWidget);
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

    await tester.tap(find.byKey(const Key('home-map-legend-toggle')));
    await tester.pumpAndSettle();

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
    await tester.tap(find.byKey(const Key('home-map-legend-toggle')));
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

  testWidgets('Home marks cached public reports as stale', (tester) async {
    final repository = _ReportsRepositoryMock();
    _stubReports(
      repository,
      () async => const Success(
        PaginatedReports(results: [_submittedReport], total: 1, isStale: true),
      ),
    );

    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    expect(find.byType(OfflineStaleBanner), findsOneWidget);
    expect(
      find.textContaining('Backend unavailable. Showing saved reports'),
      findsOneWidget,
    );
  });

  testWidgets('Home keeps reports visible when refresh fails', (tester) async {
    final repository = _ReportsRepositoryMock();
    var calls = 0;
    _stubReports(repository, () async {
      calls++;
      return calls == 1
          ? const Success(PaginatedReports(results: [_submittedReport]))
          : const Err(NetworkFailure('offline'));
    });

    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.location_on), findsOneWidget);

    await tester.tap(find.byTooltip('Retry').first);
    await tester.pumpAndSettle();

    expect(calls, 2);
    expect(find.byIcon(Icons.location_on), findsOneWidget);
    expect(find.byType(OfflineStaleBanner), findsOneWidget);
  });

  testWidgets('Home refreshes after Backend reachability returns', (
    tester,
  ) async {
    final repository = _ReportsRepositoryMock();
    var calls = 0;
    _stubReports(repository, () async {
      calls++;
      return calls == 1
          ? const Success(PaginatedReports(results: [_submittedReport]))
          : const Success(PaginatedReports(results: [_inProgressReport]));
    });

    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();
    expect(find.byType(OfflineStaleBanner), findsNothing);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(HomeScreen)),
    );
    (container.read(backendReachabilityProvider.notifier) as _TestReachability)
        .setReachability(BackendReachability.unreachable);
    await tester.pump();
    expect(find.byType(OfflineStaleBanner), findsOneWidget);
    (container.read(backendReachabilityProvider.notifier) as _TestReachability)
        .setReachability(BackendReachability.reachable);
    await tester.pumpAndSettle();

    expect(calls, 2);
    expect(find.byType(OfflineStaleBanner), findsNothing);
  });

  const previewDirectory = String.fromEnvironment('HOME_UI_PREVIEW_DIR');
  if (previewDirectory.isNotEmpty) {
    testWidgets('renders mobile home previews', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.runAsync(() async {
        for (final family in ['Roboto', 'HomePreview']) {
          final font = FontLoader(family)
            ..addFont(
              File(
                'C:/Windows/Fonts/segoeui.ttf',
              ).readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
            );
          await font.load();
        }
        final icons = FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
        await icons.load();
      });
      final repository = _ReportsRepositoryMock();
      _stubReports(
        repository,
        () async => const Success(
          PaginatedReports(
            results: [_submittedReport, _inProgressReport, _resolvedReport],
            isStale: true,
          ),
        ),
      );
      const previewKey = Key('home-ui-preview');
      final baseTheme = AppTheme.dark;
      final previewTheme = baseTheme.copyWith(
        textTheme: baseTheme.textTheme.apply(fontFamily: 'HomePreview'),
        primaryTextTheme: baseTheme.primaryTextTheme.apply(
          fontFamily: 'HomePreview',
        ),
        appBarTheme: baseTheme.appBarTheme.copyWith(
          titleTextStyle: baseTheme.appBarTheme.titleTextStyle?.copyWith(
            fontFamily: 'HomePreview',
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: baseTheme.textButtonTheme.style?.copyWith(
            textStyle: WidgetStatePropertyAll(
              baseTheme.textButtonTheme.style?.textStyle
                  ?.resolve({})
                  ?.copyWith(fontFamily: 'HomePreview'),
            ),
          ),
        ),
        segmentedButtonTheme: SegmentedButtonThemeData(
          style: baseTheme.segmentedButtonTheme.style?.copyWith(
            textStyle: WidgetStatePropertyAll(
              baseTheme.segmentedButtonTheme.style?.textStyle
                  ?.resolve({})
                  ?.copyWith(fontFamily: 'HomePreview'),
            ),
          ),
        ),
        chipTheme: baseTheme.chipTheme.copyWith(
          labelStyle: baseTheme.chipTheme.labelStyle?.copyWith(
            fontFamily: 'HomePreview',
          ),
          secondaryLabelStyle: baseTheme.chipTheme.secondaryLabelStyle
              ?.copyWith(fontFamily: 'HomePreview'),
        ),
      );
      await tester.pumpWidget(
        RepaintBoundary(
          key: previewKey,
          child: _app(repository, withNavigation: true, theme: previewTheme),
        ),
      );
      await tester.pumpAndSettle();

      Future<void> capture(String name) async {
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(previewKey),
        );
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 2);
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File('$previewDirectory/$name.png');
          await file.parent.create(recursive: true);
          await file.writeAsBytes(data!.buffer.asUint8List());
          image.dispose();
        });
      }

      await capture('home-compact');
      await tester.tap(find.byKey(const Key('home-verification-toggle')));
      await tester.tap(find.byKey(const Key('home-map-legend-toggle')));
      await tester.pumpAndSettle();
      await capture('home-expanded');
      expect(tester.takeException(), isNull);
    });
  }
}
