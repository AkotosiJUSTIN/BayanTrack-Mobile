import 'dart:async';

import 'package:bayantrack_mobile/core/constants/urdaneta_barangays.dart';
import 'package:bayantrack_mobile/core/domain/failures.dart';
import 'package:bayantrack_mobile/core/domain/result.dart';
import 'package:bayantrack_mobile/core/theme/app_theme.dart';
import 'package:bayantrack_mobile/features/auth/data/auth_models.dart';
import 'package:bayantrack_mobile/features/auth/data/user_permissions.dart';
import 'package:bayantrack_mobile/features/auth/presentation/barangays_provider.dart';
import 'package:bayantrack_mobile/features/reports/data/reports_repository.dart';
import 'package:bayantrack_mobile/features/reports/domain/entities/report.dart'
    as domain_report;
import 'package:bayantrack_mobile/features/reports/domain/reports_repository.dart'
    as domain_repository;
import 'package:bayantrack_mobile/features/reports/domain/usecases/create_report_usecase.dart';
import 'package:bayantrack_mobile/features/reports/presentation/new_report/quick_report_screen.dart';
import 'package:bayantrack_mobile/features/reports/reports_di.dart';
import 'package:bayantrack_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';

class _TestMunicipalities extends Municipalities {
  @override
  FutureOr<List<MunicipalityModel>> build() => const [
    bundledUrdanetaMunicipality,
  ];
}

class _TestMunicipalityBarangays extends MunicipalityBarangays {
  @override
  FutureOr<List<BarangayModel>> build(String municipalityId) =>
      bundledUrdanetaBarangays;
}

class _ReportsRepositoryMock extends Mock implements ReportsRepository {}

class _UnusedDomainReportsRepository extends Mock
    implements domain_repository.ReportsRepository {}

class _TestCreateReportUseCase extends CreateReportUseCase {
  _TestCreateReportUseCase(this._submit)
    : super(repository: _UnusedDomainReportsRepository());

  final Future<Result<domain_report.Report>> Function(bool isQuickReport)
  _submit;
  int callCount = 0;
  bool? lastIsQuickReport;

  @override
  Future<Result<domain_report.Report>> call({
    String? category,
    String? incidentType,
    String? title,
    String description = '',
    String? incidentDatetime,
    bool isHappeningNow = false,
    String? zone,
    String? streetLandmark,
    String municipalityId = 'urdaneta',
    String? barangayId,
    String? cityMunicipality,
    String? province,
    String? latitude,
    String? longitude,
    String locationAccuracy = 'approximate',
    String? location,
    String? barangay,
    bool declarationConfirmed = true,
    bool dataProcessingConsent = true,
    bool isQuickReport = false,
    bool isEmergency = false,
    String? idempotencyKey,
  }) {
    callCount++;
    lastIsQuickReport = isQuickReport;
    return _submit(isQuickReport);
  }
}

class _CountingNavigatorObserver extends NavigatorObserver {
  int popCount = 0;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is PageRoute<void>) popCount++;
    super.didPop(route, previousRoute);
  }
}

Position _position(double latitude, double longitude) => Position(
  latitude: latitude,
  longitude: longitude,
  timestamp: DateTime(2026, 7, 19),
  accuracy: 5,
  altitude: 0,
  altitudeAccuracy: 0,
  heading: 0,
  headingAccuracy: 0,
  speed: 0,
  speedAccuracy: 0,
);

Future<void> _pumpQuickReport(
  WidgetTester tester, {
  required Future<Position> Function() locate,
  Size size = const Size(360, 800),
  double textScale = 1,
  ReportsRepository? reportsRepository,
  CreateReportUseCase? createReportUseCase,
  NavigatorObserver? navigatorObserver,
  bool pushFromRoot = false,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final navigatorKey = GlobalKey<NavigatorState>();
  Widget quickReport() => QuickReportScreen(
    key: UniqueKey(),
    locationOverride: locate,
    showMapTiles: false,
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        userPermissionsProvider.overrideWithValue(UserPermissions(null)),
        municipalitiesProvider.overrideWith(_TestMunicipalities.new),
        municipalityBarangaysProvider.overrideWith(
          _TestMunicipalityBarangays.new,
        ),
        if (reportsRepository != null)
          reportsRepositoryProvider.overrideWithValue(reportsRepository),
        if (createReportUseCase != null)
          createReportUseCaseProvider.overrideWithValue(createReportUseCase),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        navigatorObservers: [if (navigatorObserver != null) navigatorObserver],
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: pushFromRoot ? const Scaffold(body: Text('Home')) : quickReport(),
      ),
    ),
  );
  if (pushFromRoot) {
    unawaited(
      navigatorKey.currentState!.push(
        MaterialPageRoute<void>(builder: (_) => quickReport()),
      ),
    );
  }
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 1));
}

void main() {
  final inside = _position(15.979204, 120.622210);
  final outside = _position(14.5995, 120.9842);

  testWidgets('verification notice is compact and does not gate reporting', (
    tester,
  ) async {
    await _pumpQuickReport(tester, locate: () async => inside);

    expect(find.text('Step 1 of 1'), findsOneWidget);
    expect(
      find.text(
        'You can report now. Verification improves trust and unlocks account features.',
      ),
      findsOneWidget,
    );
    await tester.enterText(
      find.byKey(const Key('quick-report-description')),
      'Floodwater is rising near the public market.',
    );
    await tester.pump();

    final submit = tester.widget<ElevatedButton>(
      find.byKey(const Key('quick-report-submit')),
    );
    expect(submit.onPressed, isNotNull);
  });

  testWidgets('GPS loading, success, and failure stay near location controls', (
    tester,
  ) async {
    final pending = Completer<Position>();
    await _pumpQuickReport(tester, locate: () => pending.future);

    expect(find.text('Locating…'), findsOneWidget);
    expect(find.text('Waiting for an incident location…'), findsOneWidget);

    pending.complete(inside);
    await tester.pump();
    expect(find.text('GPS location found'), findsOneWidget);

    await _pumpQuickReport(
      tester,
      locate: () => Future<Position>.error(StateError('GPS unavailable')),
    );
    await tester.pump();
    expect(find.text('Error: Refresh location / Manual Pin'), findsOneWidget);
  });

  testWidgets('outside GPS explains manual selection without blocking access', (
    tester,
  ) async {
    await _pumpQuickReport(tester, locate: () async => outside);

    expect(find.text('Location is outside Urdaneta'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('quick-report-outside-location')),
        matching: find.text(
          'You do not need to be in the city. Select the incident inside Urdaneta.',
        ),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('quick-report-switch-manual')), findsOneWidget);

    final switchToManual = find.byKey(const Key('quick-report-switch-manual'));
    await tester.ensureVisible(switchToManual);
    await tester.pump();
    await tester.tap(switchToManual);
    await tester.pump();
    expect(find.text('Manual Pin'), findsOneWidget);
    expect(
      find.text('Tap the map to choose an incident location.'),
      findsOneWidget,
    );
  });

  testWidgets('manual pin accepts inside taps and rejects outside taps', (
    tester,
  ) async {
    await _pumpQuickReport(tester, locate: () async => inside);
    await tester.tap(find.text('Manual Pin'));
    await tester.pump();

    final mapFinder = find.byKey(const Key('quick-report-map'));
    await tester.ensureVisible(mapFinder);
    await tester.pump();
    final onMapTap = tester
        .widget<FlutterMap>(find.byType(FlutterMap))
        .options
        .onTap!;
    onMapTap(
      const TapPosition(Offset.zero, Offset.zero),
      const LatLng(15.95, 120.49),
    );
    await tester.pump();
    expect(find.text('Incident pin must be inside Urdaneta.'), findsOneWidget);

    onMapTap(
      const TapPosition(Offset.zero, Offset.zero),
      const LatLng(15.979204, 120.622210),
    );
    await tester.pump();
    expect(find.text('Incident location selected'), findsOneWidget);
  });

  testWidgets('submit is sticky, keyboard-safe, and explains disabled state', (
    tester,
  ) async {
    await _pumpQuickReport(tester, locate: () async => inside);

    expect(find.text('Add a short description to continue.'), findsOneWidget);
    final submitBar = find.byKey(const Key('quick-report-submit-bar'));
    final initialTop = tester.getTopLeft(submitBar).dy;

    await tester.dragFrom(const Offset(4, 600), const Offset(0, -250));
    await tester.pump();
    expect(tester.getTopLeft(submitBar).dy, initialTop);

    final description = find.byKey(const Key('quick-report-description'));
    await tester.ensureVisible(description);
    await tester.pump();
    await tester.tap(description);
    await tester.showKeyboard(description);
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pump();
    expect(tester.getRect(submitBar).bottom, lessThanOrEqualTo(500));
  });

  testWidgets('submit shows a readable loading state and prevents repeats', (
    tester,
  ) async {
    final reports = _ReportsRepositoryMock();
    final nearby = Completer<List<NearbyReport>>();
    when(
      () => reports.getNearbyReports(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
        municipalityId: any(named: 'municipalityId'),
      ),
    ).thenAnswer((_) => nearby.future);
    await _pumpQuickReport(
      tester,
      locate: () async => inside,
      reportsRepository: reports,
    );
    await tester.enterText(
      find.byKey(const Key('quick-report-description')),
      'A fallen tree is blocking both lanes.',
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('quick-report-submit')));
    await tester.pump();
    expect(find.text('Submitting Quick Report…'), findsOneWidget);
    expect(
      tester
          .widget<ElevatedButton>(find.byKey(const Key('quick-report-submit')))
          .onPressed,
      isNull,
    );

    nearby.complete([
      const NearbyReport(
        category: 'Infrastructure',
        status: 'submitted',
        distanceMeters: 20,
        isGrouped: false,
      ),
    ]);
    await tester.pump();
    expect(find.text('Reports already nearby'), findsOneWidget);
    await tester.tap(find.text('Review mine'));
    await tester.pump();
    expect(find.text('Submit Quick Report'), findsOneWidget);
  });

  for (final size in const [Size(360, 800), Size(390, 844), Size(412, 915)]) {
    testWidgets('layout has no overflow at ${size.width}×${size.height}', (
      tester,
    ) async {
      await _pumpQuickReport(tester, locate: () async => inside, size: size);
      expect(
        find.byKey(const Key('quick-report-submit')).hitTestable(),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('large text keeps controls and sticky submit unclipped', (
    tester,
  ) async {
    await _pumpQuickReport(tester, locate: () async => outside, textScale: 2);

    expect(find.text('Phone GPS'), findsOneWidget);
    expect(
      find.byKey(const Key('quick-report-submit')).hitTestable(),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('map controls and primary fields expose accessible labels', (
    tester,
  ) async {
    await _pumpQuickReport(tester, locate: () async => inside);

    expect(
      tester
          .widget<IconButton>(
            find.byKey(const Key('quick-report-refresh-location')),
          )
          .tooltip,
      'Refresh device location',
    );
    expect(
      tester
          .widget<IconButton>(
            find.byKey(const Key('quick-report-recenter-municipality')),
          )
          .tooltip,
      'Recenter city',
    );
    expect(
      find.ancestor(
        of: find.byKey(const Key('quick-report-description')),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == 'Short description',
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.ancestor(
        of: find.byKey(const Key('quick-report-submit')),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == 'Submit Quick Report',
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets('pending location completion is ignored after disposal', (
    tester,
  ) async {
    final pending = Completer<Position>();
    await _pumpQuickReport(tester, locate: () => pending.future);

    await tester.pumpWidget(const SizedBox.shrink());
    pending.complete(inside);
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('successful submission navigates once and submits once', (
    tester,
  ) async {
    final reports = _ReportsRepositoryMock();
    final createReport = _TestCreateReportUseCase(
      (_) async => const Success(
        domain_report.Report(
          id: 'quick-report-123',
          description: 'A fallen tree is blocking both lanes.',
        ),
      ),
    );
    final observer = _CountingNavigatorObserver();
    when(
      () => reports.getNearbyReports(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
        municipalityId: any(named: 'municipalityId'),
      ),
    ).thenAnswer((_) async => const []);
    await _pumpQuickReport(
      tester,
      locate: () async => inside,
      reportsRepository: reports,
      createReportUseCase: createReport,
      navigatorObserver: observer,
      pushFromRoot: true,
    );
    await tester.enterText(
      find.byKey(const Key('quick-report-description')),
      'A fallen tree is blocking both lanes.',
    );
    await tester.pump();

    final submit = tester
        .widget<ElevatedButton>(find.byKey(const Key('quick-report-submit')))
        .onPressed!;
    submit();
    submit();
    await tester.pump();
    await tester.pump();

    expect(find.text('Report submitted'), findsOneWidget);
    expect(createReport.callCount, 1);
    expect(createReport.lastIsQuickReport, isTrue);

    await tester.tap(find.text('Done'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(observer.popCount, 1);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Report submitted'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('submission completion after disposal is ignored', (
    tester,
  ) async {
    final reports = _ReportsRepositoryMock();
    final pending = Completer<Result<domain_report.Report>>();
    final createReport = _TestCreateReportUseCase((_) => pending.future);
    when(
      () => reports.getNearbyReports(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
        municipalityId: any(named: 'municipalityId'),
      ),
    ).thenAnswer((_) async => const []);
    await _pumpQuickReport(
      tester,
      locate: () async => inside,
      reportsRepository: reports,
      createReportUseCase: createReport,
    );
    await tester.enterText(
      find.byKey(const Key('quick-report-description')),
      'A fallen tree is blocking both lanes.',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('quick-report-submit')));
    await tester.pump();

    await tester.pumpWidget(const SizedBox.shrink());
    pending.complete(
      const Success(
        domain_report.Report(
          id: 'quick-report-123',
          description: 'A fallen tree is blocking both lanes.',
        ),
      ),
    );
    await tester.pump();

    expect(createReport.callCount, 1);
    expect(createReport.lastIsQuickReport, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('failed submission displays its error and allows retry', (
    tester,
  ) async {
    final reports = _ReportsRepositoryMock();
    final createReport = _TestCreateReportUseCase(
      (_) async => const Err(UnknownFailure('Submission failed')),
    );
    when(
      () => reports.getNearbyReports(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
        municipalityId: any(named: 'municipalityId'),
      ),
    ).thenAnswer((_) async => const []);
    await _pumpQuickReport(
      tester,
      locate: () async => inside,
      reportsRepository: reports,
      createReportUseCase: createReport,
    );
    await tester.enterText(
      find.byKey(const Key('quick-report-description')),
      'A fallen tree is blocking both lanes.',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('quick-report-submit')));
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('Submission failed'), findsAtLeastNWidgets(1));
    expect(find.byKey(const Key('quick-report-submit-error')), findsOneWidget);
    expect(
      tester
          .widget<ElevatedButton>(find.byKey(const Key('quick-report-submit')))
          .onPressed,
      isNotNull,
    );
    expect(tester.takeException(), isNull);
  });
}
