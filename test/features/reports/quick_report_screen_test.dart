<<<<<<< Updated upstream
import 'dart:async';
import 'package:bayantrack_mobile/features/reports/presentation/widgets/incident_choice_field.dart';
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
    String? incidentTypeKey,
    String? incidentCatalogVersion,
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
    incidentChoicesProvider.overrideWith(
      (ref) async => (version: null, items: <Map<String, dynamic>>[]),
    ),
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
=======
import 'package:bayantrack_mobile/features/reports/data/emergency_catalog.dart';
import 'package:bayantrack_mobile/features/reports/data/report_models.dart'
    as dto;
import 'package:bayantrack_mobile/features/reports/data/mappers/report_mapper.dart';
import 'package:flutter_test/flutter_test.dart';
>>>>>>> Stashed changes

// Mode-specific Quick/Fast screen cases are covered by the unified emergency suite.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

<<<<<<< Updated upstream
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
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
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
=======
  test(
    'offline catalog provides localized types and exact situation keys',
    () async {
      final catalog = await EmergencyCatalog.bundled();
      expect(catalog.types, hasLength(9));
      expect(catalog.types.first.key, 'fire_smoke');
      expect(catalog.types.first.localized(true), 'Sunog o usok');
      expect(catalog.types.first.situations.first.key, 'building_fire');
      expect(
        catalog.types.first.situations.first.localized(true),
        'Sunog sa gusali',
>>>>>>> Stashed changes
      );
      expect(catalog.types.last.categoryKey, isNull);
      expect(catalog.types.last.situations.map((s) => s.key), [
        'rescue_needed',
        'assistance_needed',
        'not_sure',
        'other_unknown',
      ]);
    },
  );

  test(
    'context omits blank notes and canonical summary uses English labels',
    () async {
      final catalog = await EmergencyCatalog.bundled();
      final type = catalog.types.first;
      final situation = type.situations.first;
      expect(
        emergencyContext(
          type: type,
          situation: situation,
          danger: 'unknown',
          notes: '  ',
        ),
        {
          'version': 1,
          'type_key': 'fire_smoke',
          'situation_key': 'building_fire',
          'immediate_danger': 'unknown',
        },
      );
      expect(
        emergencySummary(type, situation, 'no', '  Keep clear  '),
        'Fire or smoke: Building fire.\nInjury or immediate danger: No.\nNotes: Keep clear',
      );
    },
  );

  test(
    'DTOs preserve context/catalog and omit absent optional legacy fields',
    () {
      const context = {
        'version': 1,
        'type_key': 'fire_smoke',
        'situation_key': 'building_fire',
        'immediate_danger': 'yes',
      };
      final report = dto.Report.fromJson({
        'id': 'e1',
        'is_emergency': true,
        'emergency_context': context,
      });
      expect(report.emergencyContext, context);
      expect(report.toJson()['emergency_context'], context);
      expect(ReportMapper.fromDto(report).emergencyContext, context);
      expect(
        const dto.Report(
          id: 'legacy',
        ).toJson().containsKey('emergency_context'),
        isFalse,
      );
      expect(
        const dto.CreateReportRequest().toJson().containsKey(
          'emergency_context',
        ),
        isFalse,
      );
      final options = dto.ReportFormOptions.fromJson({
        'categories': [],
        'statuses': [],
        'severity_levels': [],
        'emergency_catalog': {'version': 1, 'types': []},
      });
      expect(options.emergencyCatalog!['version'], 1);
      expect(options.toJson()['emergency_catalog'], {
        'version': 1,
        'types': [],
      });
    },
  );

  test(
    'enrichment preserves sanitized server prefix and caps appended budget',
    () {
      const original = 'Original notes: A &amp; B';
      expect(
        appendEmergencyDetails(original, ' More help '),
        '$original\n\nAdditional details:\nMore help',
      );
      expect(
        emergencyDetailsRemaining(original),
        500 - original.length - emergencyDetailsPrefix.length,
      );
      expect(emergencyDetailsRemaining('x' * 500), 0);
      expect(
        appendEmergencyDetails(
          original,
          'x' * emergencyDetailsRemaining(original),
        ).length,
        500,
      );
    },
  );
}
