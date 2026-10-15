import 'dart:async';
import 'package:bayantrack_mobile/features/system_governance/system_governance_models.dart';
import 'package:bayantrack_mobile/features/system_governance/system_governance_provider.dart';

import 'package:bayantrack_mobile/core/constants/urdaneta_barangays.dart';
import 'package:bayantrack_mobile/core/constants/api_constants.dart';
import 'package:bayantrack_mobile/core/domain/failures.dart';
import 'package:bayantrack_mobile/core/domain/result.dart';
import 'package:bayantrack_mobile/core/providers/connectivity_provider.dart';
import 'package:bayantrack_mobile/core/providers/backend_reachability_provider.dart';
import 'package:bayantrack_mobile/core/widget/widget_bridge.dart';
import 'package:bayantrack_mobile/core/theme/app_theme.dart';
import 'package:bayantrack_mobile/features/auth/auth_di.dart';
import 'package:bayantrack_mobile/features/auth/presentation/auth_controller.dart';
import 'package:bayantrack_mobile/features/auth/data/auth_models.dart';
import 'package:bayantrack_mobile/features/auth/data/user_permissions.dart';
import 'package:bayantrack_mobile/features/auth/domain/entities/user.dart';
import 'package:bayantrack_mobile/features/auth/domain/auth_repository.dart';
import 'package:bayantrack_mobile/features/auth/presentation/barangays_provider.dart';
import 'package:bayantrack_mobile/features/reports/data/reports_repository.dart';
import 'package:bayantrack_mobile/features/reports/data/report_draft_store.dart';
import 'package:bayantrack_mobile/features/reports/domain/entities/report.dart'
    as domain_report;
import 'package:bayantrack_mobile/features/reports/domain/reports_repository.dart'
    as domain_repository;
import 'package:bayantrack_mobile/features/reports/domain/usecases/create_report_usecase.dart';
import 'package:bayantrack_mobile/features/reports/presentation/new_report/quick_report_screen.dart';
import 'package:bayantrack_mobile/features/reports/presentation/new_report/quick_report_geo.dart';
import 'package:bayantrack_mobile/features/reports/presentation/new_report/report_flow_widgets.dart';
import 'package:bayantrack_mobile/features/reports/reports_di.dart';
import 'package:bayantrack_mobile/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;
import '../images/evidence_image_editor_test.dart' show evidenceFixture;
import '../images/evidence_photo_review_test.dart' show settlePhoto;

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

class _AuthRepositoryMock extends Mock implements AuthRepository {}

class _UnusedDomainReportsRepository extends Mock
    implements domain_repository.ReportsRepository {}

class _StorageMock extends Mock implements FlutterSecureStorage {}

class _MutableAuthController extends AuthController {
  _MutableAuthController(this.initialState);

  final AuthState initialState;

  @override
  AuthState build() => initialState;

  void update(AuthState value) => state = value;
}

class _TestCreateReportUseCase extends CreateReportUseCase {
  _TestCreateReportUseCase(this._submit)
    : super(repository: _UnusedDomainReportsRepository());

  final Future<Result<domain_report.Report>> Function(bool isQuickReport)
  _submit;
  int callCount = 0;
  final List<String?> idempotencyKeys = [];
  bool? lastIsQuickReport;
  bool? lastIsEmergency;
  String? lastMunicipalityId;
  String? lastBarangayId;
  String? lastBarangay;
  String? lastStreetLandmark;

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
    CancelToken? cancelToken,
  }) {
    callCount++;
    idempotencyKeys.add(idempotencyKey);
    lastIsQuickReport = isQuickReport;
    lastIsEmergency = isEmergency;
    lastMunicipalityId = municipalityId;
    lastBarangayId = barangayId;
    lastBarangay = barangay;
    lastStreetLandmark = streetLandmark;
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

class _TestConnectivityNotifier extends ConnectivityNotifier {
  _TestConnectivityNotifier(this.initialValue);

  final bool initialValue;

  @override
  bool build() => initialValue;
}

class _TestBackendReachabilityNotifier extends BackendReachabilityNotifier {
  @override
  BackendReachability build() => BackendReachability.reachable;
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

WidgetBridge _recordWidgetState(List<Map<String, Object>> states) =>
    WidgetBridge(
      invokeNative: (method, arguments) async {
        if (method == 'updateState') {
          states.add(Map<String, Object>.from(arguments! as Map));
        }
      },
    );

Future<void> _pumpQuickReport(
  WidgetTester tester, {
  required Future<Position> Function() locate,
  Size size = const Size(360, 800),
  double textScale = 1,
  ThemeData? theme,
  ReportsRepository? reportsRepository,
  AuthRepository? authRepository,
  CreateReportUseCase? createReportUseCase,
  Future<XFile?> Function(ImageSource source)? pickImage,
  Future<List<XFile>> Function()? pickMultiImage,
  NavigatorObserver? navigatorObserver,
  bool pushFromRoot = false,
  bool isOnline = true,
  WidgetBridge? widgetBridge,
  bool fastReportMode = false,
  FlutterSecureStorage? secureStorage,
  AuthState? authState,
  AuthController? authController,
}) async {
  final appTheme = theme ?? AppTheme.light;
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final navigatorKey = GlobalKey<NavigatorState>();
  final storage = secureStorage ?? _authenticatedStorage();
  Widget quickReport() => QuickReportScreen(
    key: UniqueKey(),
    locationOverride: locate,
    showMapTiles: false,
    fastReportMode: fastReportMode,
    pickImage: pickImage,
    pickMultiImage: pickMultiImage,
  );
  final auth = authRepository ?? _AuthRepositoryMock();
  if (authRepository == null) {
    when(
      () => auth.getNearbyLandmarks(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
      ),
    ).thenAnswer((_) async => const Success(<NearbyLandmarkModel>[]));
  }
  final overrides = <Override>[
    systemGovernanceProvider.overrideWithBuild(
      (_, _) => const SystemGovernanceState(
        maintenanceEnabled: false,
        maintenanceMessage: '',
        termsAcceptanceRequired: false,
      ),
    ),
    isOnlineProvider.overrideWith(() => _TestConnectivityNotifier(isOnline)),
    backendReachabilityProvider.overrideWith(
      _TestBackendReachabilityNotifier.new,
    ),
    userPermissionsProvider.overrideWithValue(UserPermissions(null)),
    authRepositoryProvider.overrideWithValue(auth),
    secureStorageProvider.overrideWithValue(storage),
    municipalitiesProvider.overrideWith(_TestMunicipalities.new),
    municipalityBarangaysProvider.overrideWith(_TestMunicipalityBarangays.new),
    if (authController != null)
      authControllerProvider.overrideWith(() => authController)
    else if (authState != null)
      authControllerProvider.overrideWithValue(authState),
    if (authController == null && authState == null)
      authControllerProvider.overrideWithValue(
        const AuthSuccess(
          'test',
          User(
            id: 'user-A',
            email: 'citizen@example.test',
            firstName: 'Test',
            lastName: 'Citizen',
            role: UserRole.citizen,
          ),
        ),
      ),
  ];
  if (reportsRepository != null) {
    overrides.add(
      reportsRepositoryProvider.overrideWithValue(reportsRepository),
    );
  }
  if (createReportUseCase != null) {
    overrides.add(
      createReportUseCaseProvider.overrideWithValue(createReportUseCase),
    );
  }
  if (widgetBridge != null) {
    await widgetBridge.syncAuthenticated(true);
    addTearDown(widgetBridge.dispose);
    overrides.add(widgetBridgeProvider.overrideWithValue(widgetBridge));
  }
  final navigatorObservers = <NavigatorObserver>[];
  if (navigatorObserver != null) navigatorObservers.add(navigatorObserver);

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        navigatorObservers: navigatorObservers,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: appTheme,
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
  await tester.pump(nearbyLandmarkDebounceDuration);
}

_StorageMock _authenticatedStorage() {
  final storage = _StorageMock();
  final values = <String, String>{ApiConstants.accessTokenKey: 'test-token'};
  when(
    () => storage.read(key: any(named: 'key')),
  ).thenAnswer((invocation) async => values[invocation.namedArguments[#key]]);
  when(
    () => storage.write(
      key: any(named: 'key'),
      value: any(named: 'value'),
    ),
  ).thenAnswer((invocation) async {
    values[invocation.namedArguments[#key] as String] =
        invocation.namedArguments[#value] as String;
  });
  when(() => storage.delete(key: any(named: 'key'))).thenAnswer((
    invocation,
  ) async {
    values.remove(invocation.namedArguments[#key]);
  });
  when(() => storage.readAll()).thenAnswer((_) async => values);
  return storage;
}

void main() {
  final inside = _position(15.979204, 120.622210);
  final outside = _position(14.5995, 120.9842);

  testWidgets('quick report restores saved fields and never auto-submits', (
    tester,
  ) async {
    final storage = _StorageMock();
    final values = <String, String>{};
    when(
      () => storage.read(key: any(named: 'key')),
    ).thenAnswer((invocation) async => values[invocation.namedArguments[#key]]);
    when(
      () => storage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((invocation) async {
      values[invocation.namedArguments[#key] as String] =
          invocation.namedArguments[#value] as String;
    });
    when(() => storage.delete(key: any(named: 'key'))).thenAnswer((
      invocation,
    ) async {
      values.remove(invocation.namedArguments[#key]);
    });
    when(() => storage.readAll()).thenAnswer((_) async => values);
    final now = DateTime.utc(2026, 9, 27);
    await ReportDraftStore(storage).write(
      ReportDraft(
        schemaVersion: ReportDraft.currentSchemaVersion,
        draftId: 'quick-draft-1',
        ownerId: 'user-A',
        type: ReportDraftType.quick,
        createdAt: now,
        updatedAt: now,
        resumeStep: 'form',
        payload: {
          'description': 'Floodwater near the public market',
          'latitude': 15.979204,
          'longitude': 120.622210,
        },
        attachmentRefs: const [],
      ),
    );
    final createUseCase = _TestCreateReportUseCase(
      (_) async => const Success(
        domain_report.Report(id: 'unused', description: 'unused'),
      ),
    );

    await _pumpQuickReport(
      tester,
      locate: () async => inside,
      secureStorage: storage,
      authState: const AuthSuccess(
        'test',
        User(
          id: 'user-A',
          email: 'citizen@example.test',
          firstName: 'Test',
          lastName: 'Citizen',
          role: UserRole.citizen,
        ),
      ),
      createReportUseCase: createUseCase,
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    await tester.tap(find.text('Resume'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    final description = tester.widget<TextField>(
      find.byKey(const Key('quick-report-description')),
    );
    expect(description.controller?.text, 'Floodwater near the public market');
    expect(createUseCase.callCount, 0);
  });

  testWidgets('automatic location alone does not create a blank draft', (
    tester,
  ) async {
    final storage = _StorageMock();
    final values = <String, String>{};
    when(
      () => storage.read(key: any(named: 'key')),
    ).thenAnswer((invocation) async => values[invocation.namedArguments[#key]]);
    when(
      () => storage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((invocation) async {
      values[invocation.namedArguments[#key] as String] =
          invocation.namedArguments[#value] as String;
    });
    when(() => storage.delete(key: any(named: 'key'))).thenAnswer((
      invocation,
    ) async {
      values.remove(invocation.namedArguments[#key]);
    });
    const owner = AuthSuccess(
      'test',
      User(
        id: 'user-A',
        email: 'citizen@example.test',
        firstName: 'Test',
        lastName: 'Citizen',
        role: UserRole.citizen,
      ),
    );

    await _pumpQuickReport(
      tester,
      locate: () async => inside,
      secureStorage: storage,
      authState: owner,
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(
      await ReportDraftStore(storage).read('user-A', ReportDraftType.quick),
      isNull,
    );
  });

  testWidgets('logout during a save keeps the draft scoped to its owner', (
    tester,
  ) async {
    final storage = _StorageMock();
    final values = <String, String>{};
    final writeStarted = Completer<void>();
    final allowWrite = Completer<void>();
    when(
      () => storage.read(key: any(named: 'key')),
    ).thenAnswer((invocation) async => values[invocation.namedArguments[#key]]);
    when(
      () => storage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((invocation) async {
      if (!writeStarted.isCompleted) writeStarted.complete();
      await allowWrite.future;
      values[invocation.namedArguments[#key] as String] =
          invocation.namedArguments[#value] as String;
    });
    when(() => storage.delete(key: any(named: 'key'))).thenAnswer((
      invocation,
    ) async {
      values.remove(invocation.namedArguments[#key]);
    });
    when(() => storage.readAll()).thenAnswer((_) async => values);
    final auth = _MutableAuthController(
      const AuthSuccess(
        'test',
        User(
          id: 'user-A',
          email: 'citizen@example.test',
          firstName: 'Test',
          lastName: 'Citizen',
          role: UserRole.citizen,
        ),
      ),
    );

    await _pumpQuickReport(
      tester,
      locate: () async => inside,
      secureStorage: storage,
      authController: auth,
    );
    await tester.enterText(
      find.byKey(const Key('quick-report-description')),
      'Private report for user A',
    );
    await tester.pump(const Duration(milliseconds: 400));
    await writeStarted.future;

    auth.update(const AuthIdle());
    await tester.pump();
    await tester.pump();
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('quick-report-description')))
          .controller
          ?.text,
      isEmpty,
    );
    allowWrite.complete();
    await tester.pump(const Duration(milliseconds: 20));

    final store = ReportDraftStore(storage);
    expect(
      (await store.read(
        'user-A',
        ReportDraftType.quick,
      ))?.payload['description'],
      'Private report for user A',
    );
    expect(await store.read('user-B', ReportDraftType.quick), isNull);
  });

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

  testWidgets('uses fixed Urdaneta city and resolves report metadata', (
    tester,
  ) async {
    final auth = _AuthRepositoryMock();
    when(
      () => auth.getNearbyLandmarks(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
      ),
    ).thenAnswer(
      (_) async => const Success([
        NearbyLandmarkModel(name: 'Public Market', distanceMeters: 40),
      ]),
    );

    await _pumpQuickReport(
      tester,
      locate: () async => inside,
      authRepository: auth,
    );
    await tester.pump();

    expect(find.byKey(const Key('quick-report-city')), findsOneWidget);
    expect(find.text('Urdaneta City'), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<String>), findsNothing);
    expect(find.text('Bactad East'), findsAtLeastNWidgets(1));
    expect(find.text('Public Market'), findsOneWidget);
  });

  testWidgets('dark location surfaces use tonal layers and pill suggestions', (
    tester,
  ) async {
    final auth = _AuthRepositoryMock();
    when(
      () => auth.getNearbyLandmarks(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
      ),
    ).thenAnswer(
      (_) async => const Success([
        NearbyLandmarkModel(name: 'Clinic', distanceMeters: 40),
        NearbyLandmarkModel(name: 'Market', distanceMeters: 90),
      ]),
    );

    await _pumpQuickReport(
      tester,
      locate: () async => inside,
      theme: AppTheme.dark,
      size: const Size(412, 915),
      authRepository: auth,
    );
    await tester.pump();

    final locationCard = tester.widget<Material>(
      find.byKey(const Key('quick-report-location-card')),
    );
    expect(locationCard.elevation, 0);
    expect(
      (locationCard.shape! as RoundedRectangleBorder).side,
      BorderSide.none,
    );

    final cityField = tester.widget<Material>(
      find.descendant(
        of: find.byKey(const Key('quick-report-city')),
        matching: find.byType(Material),
      ),
    );
    expect((cityField.shape! as RoundedRectangleBorder).side, BorderSide.none);

    final chips = tester.widgetList<FilterChip>(find.byType(FilterChip));
    expect(chips, hasLength(2));
    expect(chips.every((chip) => chip.side == BorderSide.none), isTrue);
    expect(chips.every((chip) => chip.shape is StadiumBorder), isTrue);
  });

  testWidgets('selected landmark icon uses the orange accent in light mode', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: ReportLandmarkSuggestionChips(
            suggestions: ['Clinic', 'Market'],
            selectedLandmark: 'Market',
          ),
        ),
      ),
    );
    await tester.pump();

    final chips = tester.widgetList<FilterChip>(find.byType(FilterChip));
    final selected = chips.singleWhere((chip) => chip.selected);
    expect(
      (selected.avatar! as Icon).color,
      AppTheme.light.colorScheme.secondary,
    );
  });

  testWidgets('selected landmark icon uses the orange accent in dark mode', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(
          body: ReportLandmarkSuggestionChips(
            suggestions: ['Clinic', 'Market'],
            selectedLandmark: 'Market',
          ),
        ),
      ),
    );
    await tester.pump();

    final chips = tester.widgetList<FilterChip>(find.byType(FilterChip));
    final selected = chips.singleWhere((chip) => chip.selected);
    expect(
      (selected.avatar! as Icon).color,
      AppTheme.dark.colorScheme.secondary,
    );
  });

  testWidgets('dark outside-city callout stays soft and borderless', (
    tester,
  ) async {
    await _pumpQuickReport(
      tester,
      locate: () async => outside,
      theme: AppTheme.dark,
    );
    await tester.pump();

    final callout = tester.widget<Material>(
      find.byKey(const Key('quick-report-outside-location')),
    );
    expect((callout.shape! as RoundedRectangleBorder).side, BorderSide.none);
    expect(find.text('Location is outside Urdaneta'), findsOneWidget);
    expect(find.byKey(const Key('quick-report-switch-manual')), findsOneWidget);
  });

  testWidgets('manual pin refreshes barangay and clears old landmark', (
    tester,
  ) async {
    final auth = _AuthRepositoryMock();
    final landmarkRequests = <LatLng>[];
    final secondLandmarkResponse =
        Completer<Result<List<NearbyLandmarkModel>>>();
    when(
      () => auth.getNearbyLandmarks(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
      ),
    ).thenAnswer((invocation) async {
      landmarkRequests.add(
        LatLng(
          invocation.namedArguments[#latitude] as double,
          invocation.namedArguments[#longitude] as double,
        ),
      );
      if (landmarkRequests.length == 1) {
        return const Success([
          NearbyLandmarkModel(name: 'Public Market', distanceMeters: 40),
        ]);
      }
      return secondLandmarkResponse.future;
    });

    await _pumpQuickReport(
      tester,
      locate: () async => inside,
      authRepository: auth,
    );
    await tester.pump();
    await tester.tap(find.text('Manual Pin'));
    await tester.pump();

    final onMapTap = tester
        .widget<FlutterMap>(find.byType(FlutterMap))
        .options
        .onTap!;
    onMapTap(
      const TapPosition(Offset.zero, Offset.zero),
      const LatLng(15.9763, 120.5776),
    );
    await tester.pump();
    await tester.pump(nearbyLandmarkDebounceDuration);
    expect(find.text('Public Market'), findsNothing);
    expect(find.text('Bactad East'), findsNothing);
    expect(find.text('Bayaoas'), findsAtLeastNWidgets(1));
    secondLandmarkResponse.complete(
      const Success([
        NearbyLandmarkModel(name: 'New Market', distanceMeters: 40),
      ]),
    );
    await tester.pump();
    expect(find.text('New Market'), findsOneWidget);
    expect(landmarkRequests.length, 2);
  });

  testWidgets('rapid manual pins debounce requests and ignore stale results', (
    tester,
  ) async {
    final auth = _AuthRepositoryMock();
    final requests = <LatLng>[];
    final firstResponse = Completer<Result<List<NearbyLandmarkModel>>>();
    when(
      () => auth.getNearbyLandmarks(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
      ),
    ).thenAnswer((invocation) async {
      requests.add(
        LatLng(
          invocation.namedArguments[#latitude] as double,
          invocation.namedArguments[#longitude] as double,
        ),
      );
      if (requests.length == 1) return firstResponse.future;
      return const Success([
        NearbyLandmarkModel(name: 'Latest Market', distanceMeters: 40),
      ]);
    });

    await _pumpQuickReport(
      tester,
      locate: () async => inside,
      authRepository: auth,
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Manual Pin'));
    await tester.pump();

    final onMapTap = tester
        .widget<FlutterMap>(find.byType(FlutterMap))
        .options
        .onTap!;
    onMapTap(
      const TapPosition(Offset.zero, Offset.zero),
      const LatLng(15.9763, 120.5776),
    );
    await tester.pump(const Duration(milliseconds: 100));
    onMapTap(
      const TapPosition(Offset.zero, Offset.zero),
      const LatLng(15.9530, 120.5772),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(requests.length, 2);
    expect(requests.first.latitude, inside.latitude);
    expect(requests.first.longitude, inside.longitude);
    expect(requests.last, const LatLng(15.9530, 120.5772));
    expect(find.text('Latest Market'), findsOneWidget);

    firstResponse.complete(
      const Success([
        NearbyLandmarkModel(name: 'Stale Market', distanceMeters: 40),
      ]),
    );
    await tester.pump();
    expect(find.text('Stale Market'), findsNothing);
    expect(find.text('Latest Market'), findsOneWidget);
  });

  testWidgets('landmark loading never disables quick report submission', (
    tester,
  ) async {
    final auth = _AuthRepositoryMock();
    final pending = Completer<Result<List<NearbyLandmarkModel>>>();
    when(
      () => auth.getNearbyLandmarks(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
      ),
    ).thenAnswer((_) => pending.future);

    await _pumpQuickReport(
      tester,
      locate: () async => inside,
      authRepository: auth,
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Getting location'), findsAtLeastNWidgets(1));
    await tester.enterText(
      find.byKey(const Key('quick-report-description')),
      'Blocked road',
    );
    await tester.pump();

    expect(
      tester
          .widget<ElevatedButton>(find.byKey(const Key('quick-report-submit')))
          .onPressed,
      isNotNull,
    );

    pending.complete(const Success([]));
    await tester.pump();
  });

  testWidgets('landmark lookup failure is distinct from no nearby landmark', (
    tester,
  ) async {
    final auth = _AuthRepositoryMock();
    when(
      () => auth.getNearbyLandmarks(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
      ),
    ).thenAnswer((_) async => const Err(ServerFailure('provider unavailable')));

    await _pumpQuickReport(
      tester,
      locate: () async => inside,
      authRepository: auth,
    );
    await tester.pump();

    expect(find.text(landmarkLookupUnavailable), findsOneWidget);
    expect(find.text(noNearbyLandmarkFound), findsNothing);
  });

  testWidgets('no nearby landmark result is shown explicitly', (tester) async {
    final auth = _AuthRepositoryMock();
    when(
      () => auth.getNearbyLandmarks(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
      ),
    ).thenAnswer((_) async => const Success([]));

    await _pumpQuickReport(
      tester,
      locate: () async => inside,
      authRepository: auth,
    );
    await tester.pump();

    expect(find.text(noNearbyLandmarkFound), findsOneWidget);
    expect(find.text(landmarkLookupUnavailable), findsNothing);
  });

  testWidgets('ambiguous nearby landmarks remain explicit choices', (
    tester,
  ) async {
    final auth = _AuthRepositoryMock();
    when(
      () => auth.getNearbyLandmarks(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
      ),
    ).thenAnswer(
      (_) async => const Success([
        NearbyLandmarkModel(name: 'Clinic', distanceMeters: 40),
        NearbyLandmarkModel(name: 'Market', distanceMeters: 90),
      ]),
    );

    await _pumpQuickReport(
      tester,
      locate: () async => inside,
      authRepository: auth,
    );
    await tester.pump();

    expect(find.text(chooseNearbyLandmark), findsOneWidget);
    expect(find.bySemanticsLabel('Street / Landmark: Clinic'), findsNothing);
    final clinic = find.text('Clinic');
    await tester.ensureVisible(clinic);
    await tester.pump();
    await tester.tap(clinic);
    await tester.pump();
    expect(find.text(chooseNearbyLandmark), findsNothing);
    expect(find.text('Clinic'), findsNWidgets(2));
  });

  testWidgets('quick payload keeps canonical city, barangay, and landmark', (
    tester,
  ) async {
    final auth = _AuthRepositoryMock();
    when(
      () => auth.getNearbyLandmarks(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
      ),
    ).thenAnswer(
      (_) async => const Success([
        NearbyLandmarkModel(name: 'Public Market', distanceMeters: 40),
      ]),
    );
    final reports = _ReportsRepositoryMock();
    when(
      () => reports.getNearbyReports(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
        municipalityId: any(named: 'municipalityId'),
      ),
    ).thenAnswer((_) async => const []);
    final createReport = _TestCreateReportUseCase(
      (_) async => const Success(
        domain_report.Report(id: 'quick-1', description: 'Blocked road'),
      ),
    );

    await _pumpQuickReport(
      tester,
      locate: () async => inside,
      authRepository: auth,
      reportsRepository: reports,
      createReportUseCase: createReport,
    );
    await tester.pump();
    await tester.enterText(
      find.byKey(const Key('quick-report-description')),
      'Blocked road',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('quick-report-submit')));
    await tester.pump();
    await tester.pump();

    expect(createReport.callCount, 1);
    expect(createReport.lastMunicipalityId, 'urdaneta');
    expect(createReport.lastBarangayId, 'bactad_east');
    expect(createReport.lastBarangay, 'Bactad East');
    expect(createReport.lastStreetLandmark, 'Public Market');
    if (find
        .byKey(const Key('quick-report-evidence-skip'))
        .evaluate()
        .isNotEmpty) {
      await tester.tap(find.byKey(const Key('quick-report-evidence-skip')));
      await tester.pump();
    }
  });

  testWidgets('post-report evidence reviews single and multiple photos', (
    tester,
  ) async {
    final photoBytes = (await tester.runAsync(() => evidenceFixture()))!;
    final reports = _ReportsRepositoryMock();
    when(
      () => reports.getNearbyReports(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
        municipalityId: any(named: 'municipalityId'),
      ),
    ).thenAnswer((_) async => const []);
    final createReport = _TestCreateReportUseCase(
      (_) async => const Success(
        domain_report.Report(id: 'quick-evidence', description: 'Blocked road'),
      ),
    );

    await _pumpQuickReport(
      tester,
      locate: () async => inside,
      reportsRepository: reports,
      createReportUseCase: createReport,
      pickImage: (source) async {
        expect(source, ImageSource.camera);
        return XFile.fromData(photoBytes, name: 'camera.jpg');
      },
      pickMultiImage: () async => [
        XFile.fromData(photoBytes, name: 'gallery-one.jpg'),
        XFile.fromData(photoBytes, name: 'gallery-two.jpg'),
      ],
    );
    await tester.enterText(
      find.byKey(const Key('quick-report-description')),
      'Blocked road',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('quick-report-submit')));
    await tester.pump();
    await tester.pump();

    expect(find.text('Submitting Quick Report…'), findsNothing);

    expect(
      find.byKey(const Key('quick-report-evidence-camera')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('quick-report-evidence-gallery')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('quick-report-upload-evidence')),
      findsOneWidget,
    );
    expect(tester.getSize(find.text('Camera')).height, lessThan(32));
    expect(tester.getSize(find.text('Gallery')).height, lessThan(32));

    await tester.tap(find.byKey(const Key('quick-report-evidence-camera')));
    await settlePhoto(tester);
    expect(find.text('Review evidence'), findsOneWidget);
    await tester.tap(find.byKey(const Key('evidence-confirm-photo')));
    await settlePhoto(tester);
    await tester.tap(find.byKey(const Key('quick-report-evidence-gallery')));
    await settlePhoto(tester);
    await tester.tap(find.byKey(const Key('evidence-confirm-photo')));
    await settlePhoto(tester);
    await tester.tap(find.byKey(const Key('evidence-confirm-photo')));
    await settlePhoto(tester);
    expect(find.text('3 photo(s) selected'), findsOneWidget);
    expect(
      find.byKey(const Key('quick-report-evidence-remove-0')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('quick-report-evidence-remove-1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('quick-report-evidence-remove-2')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('quick-report-evidence-remove-1')));
    await tester.pump();
    expect(find.text('2 photo(s) selected'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const Key('quick-report-upload-evidence')),
          )
          .onPressed,
      isNotNull,
    );

    await tester.tap(find.byKey(const Key('quick-report-evidence-camera')));
    await settlePhoto(tester);
    await tester.tap(find.byTooltip('Cancel'));
    await settlePhoto(tester);
    expect(find.text('2 photo(s) selected'), findsOneWidget);
    await tester.tap(find.byKey(const Key('quick-report-upload-evidence')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('quick-report-upload-evidence')), findsNothing);
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

  testWidgets('widget reports location required when GPS is unavailable', (
    tester,
  ) async {
    final states = <Map<String, Object>>[];
    await _pumpQuickReport(
      tester,
      locate: () => Future<Position>.error(StateError('GPS unavailable')),
      widgetBridge: _recordWidgetState(states),
    );

    expect(states.last['quickReportStatus'], 'locationRequired');
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
    final states = <Map<String, Object>>[];
    await _pumpQuickReport(
      tester,
      locate: () async => inside,
      reportsRepository: reports,
      widgetBridge: _recordWidgetState(states),
    );
    await tester.enterText(
      find.byKey(const Key('quick-report-description')),
      'A fallen tree is blocking both lanes.',
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('quick-report-submit')));
    await tester.pump();
    expect(find.text('Submitting Quick Report…'), findsOneWidget);
    expect(states.last['quickReportStatus'], 'submitting');
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
    expect(states.last['quickReportStatus'], 'ready');
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
    final states = <Map<String, Object>>[];
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
      widgetBridge: _recordWidgetState(states),
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
    expect(states.last['quickReportStatus'], 'submitted');
    expect(createReport.callCount, 1);
    expect(createReport.lastIsQuickReport, isTrue);

    await tester.tap(find.byKey(const Key('quick-report-evidence-skip')));
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
      (_) async =>
          const Err(UnknownFailure.withStatus('Submission failed', 422)),
    );
    final states = <Map<String, Object>>[];
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
      widgetBridge: _recordWidgetState(states),
    );
    await tester.enterText(
      find.byKey(const Key('quick-report-description')),
      'A fallen tree is blocking both lanes.',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('quick-report-submit')));
    await tester.pump();
    await tester.pump();

    expect(
      find.textContaining('Report was not accepted. Review it and try again.'),
      findsAtLeastNWidgets(1),
    );
    expect(find.byKey(const Key('quick-report-submit-error')), findsOneWidget);
    expect(states.last['quickReportStatus'], 'failed');
    expect(
      tester
          .widget<ElevatedButton>(find.byKey(const Key('quick-report-submit')))
          .onPressed,
      isNotNull,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('offline submission reports network unavailable to widget', (
    tester,
  ) async {
    final reports = _ReportsRepositoryMock();
    final createReport = _TestCreateReportUseCase(
      (_) async => const Err(NetworkFailure('Network unavailable')),
    );
    final states = <Map<String, Object>>[];
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
      isOnline: false,
      widgetBridge: _recordWidgetState(states),
    );
    await tester.enterText(
      find.byKey(const Key('quick-report-description')),
      'A fallen tree is blocking both lanes.',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('quick-report-submit')));
    await tester.pump();
    await tester.pump();

    expect(states.last['quickReportStatus'], 'networkUnavailable');
    expect(find.byKey(const Key('quick-report-submit-error')), findsNothing);
    expect(
      find.text('Saved on this device. Not yet transmitted to BayanTrack.'),
      findsOneWidget,
    );
  });

  testWidgets('transient failure moves quick report to durable Pending Sync', (
    tester,
  ) async {
    final reports = _ReportsRepositoryMock();
    final createReport = _TestCreateReportUseCase((_) async {
      return const Err(NetworkFailure('Request timed out'));
    });
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
      pushFromRoot: true,
    );
    await tester.enterText(
      find.byKey(const Key('quick-report-description')),
      'A fallen tree is blocking both lanes.',
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('quick-report-submit')));
    await tester.pumpAndSettle();

    expect(createReport.callCount, 1);
    expect(createReport.idempotencyKeys.single, startsWith('report-key_'));
    expect(find.text('Home'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Fast Report submits online with both emergency flags', (
    tester,
  ) async {
    final states = <Map<String, Object>>[];
    final createReport = _TestCreateReportUseCase(
      (_) async => const Success(
        domain_report.Report(
          id: 'fast-created',
          description: 'Emergency near the public market',
          isEmergency: true,
        ),
      ),
    );

    await _pumpQuickReport(
      tester,
      locate: () async => _position(15.976, 120.571),
      createReportUseCase: createReport,
      widgetBridge: _recordWidgetState(states),
      fastReportMode: true,
      pushFromRoot: true,
    );
    await tester.enterText(
      find.byKey(const Key('quick-report-description')),
      'Emergency near the public market',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('fast-report-submit')));
    await tester.pumpAndSettle();

    expect(createReport.callCount, 1);
    expect(createReport.lastIsQuickReport, isTrue);
    expect(createReport.lastIsEmergency, isTrue);
    expect(states.last['quickReportStatus'], 'submitted');
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets(
    'offline Fast Report stays not transmitted and shows call guidance',
    (tester) async {
      final states = <Map<String, Object>>[];
      final createReport = _TestCreateReportUseCase(
        (_) async => const Success(
          domain_report.Report(id: 'unused', description: 'unused'),
        ),
      );

      await _pumpQuickReport(
        tester,
        locate: () async => _position(15.976, 120.571),
        createReportUseCase: createReport,
        widgetBridge: _recordWidgetState(states),
        fastReportMode: true,
        isOnline: false,
      );
      const description = 'Emergency near the public market';
      await tester.enterText(
        find.byKey(const Key('quick-report-description')),
        description,
      );
      await tester.pump();
      await tester.tap(find.byKey(const Key('fast-report-submit')));
      await tester.pump();

      expect(createReport.callCount, 0);
      expect(find.text(description), findsOneWidget);
      expect(find.text('Not sent yet'), findsOneWidget);
      expect(
        find.textContaining('call local emergency services'),
        findsOneWidget,
      );
      expect(
        find.textContaining('BayanTrack has not confirmed receipt'),
        findsOneWidget,
      );
      expect(states.last['quickReportStatus'], 'networkUnavailable');
      expect(find.text('Submit Fast Report'), findsOneWidget);
    },
  );
}
