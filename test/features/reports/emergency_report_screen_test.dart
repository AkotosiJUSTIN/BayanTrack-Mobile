import 'package:bayantrack_mobile/features/reports/domain/usecases/get_report_usecase.dart';
import 'package:bayantrack_mobile/features/reports/domain/usecases/update_report_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;
import 'dart:async';

import 'package:bayantrack_mobile/core/constants/api_constants.dart';
import 'package:bayantrack_mobile/core/constants/urdaneta_barangays.dart';
import 'package:bayantrack_mobile/core/providers/backend_reachability_provider.dart';
import 'package:bayantrack_mobile/core/providers/connectivity_provider.dart';
import 'package:bayantrack_mobile/core/domain/result.dart';
import 'package:bayantrack_mobile/core/theme/app_theme.dart';
import 'package:bayantrack_mobile/features/auth/data/auth_models.dart';
import 'package:bayantrack_mobile/features/auth/data/user_permissions.dart';
import 'package:bayantrack_mobile/features/auth/auth_di.dart';
import 'package:bayantrack_mobile/features/auth/domain/entities/user.dart';
import 'package:bayantrack_mobile/features/auth/presentation/auth_controller.dart';
import 'package:bayantrack_mobile/features/auth/presentation/barangays_provider.dart';
import 'package:bayantrack_mobile/features/reports/data/report_draft_store.dart';
import 'package:bayantrack_mobile/features/reports/data/report_create_outbox.dart';
import 'package:bayantrack_mobile/features/reports/data/reports_repository.dart'
    as data;
import 'package:bayantrack_mobile/features/reports/domain/entities/report.dart'
    as domain;
import 'package:bayantrack_mobile/features/reports/domain/reports_repository.dart'
    as domain_repository;
import 'package:bayantrack_mobile/features/reports/domain/usecases/create_report_usecase.dart';
import 'package:bayantrack_mobile/features/reports/presentation/new_report/quick_report_screen.dart';
import 'package:bayantrack_mobile/features/reports/reports_di.dart';
import 'package:bayantrack_mobile/features/system_governance/system_governance_models.dart';
import 'package:bayantrack_mobile/features/system_governance/system_governance_provider.dart';
import 'package:bayantrack_mobile/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
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

class _ReportsRepositoryMock extends Mock implements data.ReportsRepository {}

class _TestGovernance extends SystemGovernanceController {
  @override
  Future<SystemGovernanceState> build() async => const SystemGovernanceState(
    maintenanceEnabled: false,
    maintenanceMessage: '',
    termsAcceptanceRequired: false,
  );
}

class _UnusedDomainReportsRepository extends Mock
    implements domain_repository.ReportsRepository {}

class _StorageMock extends Mock implements FlutterSecureStorage {}

class _TestConnectivityNotifier extends ConnectivityNotifier {
  _TestConnectivityNotifier(this.isOnline);

  final bool isOnline;

  @override
  bool build() => isOnline;
}

class _TestBackendReachabilityNotifier extends BackendReachabilityNotifier {
  @override
  BackendReachability build() => BackendReachability.reachable;
}

class _TestCreateReportUseCase extends CreateReportUseCase {
  _TestCreateReportUseCase()
    : super(repository: _UnusedDomainReportsRepository());

  int callCount = 0;
  String? category;
  String? description;
  bool? isEmergency;
  bool? isQuickReport;
  String? idempotencyKey;
  Map<String, dynamic>? context;
  bool? declaration;
  bool? consent;
  Completer<Result<domain.Report>>? pending;

  @override
  Future<Result<domain.Report>> call({
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
    Map<String, dynamic>? emergencyContext,
    String? idempotencyKey,
    CancelToken? cancelToken,
  }) async {
    callCount++;
    this.category = category;
    this.description = description;
    this.isEmergency = isEmergency;
    this.isQuickReport = isQuickReport;
    this.idempotencyKey = idempotencyKey;
    context = emergencyContext;
    declaration = declarationConfirmed;
    consent = dataProcessingConsent;
    if (pending != null) return pending!.future;
    return Success(
      domain.Report(id: 'emergency-1', description: '', isEmergency: true),
    );
  }
}

Position _position() => Position(
  latitude: 15.979204,
  longitude: 120.622210,
  timestamp: DateTime(2026, 7, 19),
  accuracy: 5,
  altitude: 0,
  altitudeAccuracy: 0,
  heading: 0,
  headingAccuracy: 0,
  speed: 0,
  speedAccuracy: 0,
);

Future<void> _tap(WidgetTester tester, String key) async {
  if (key.startsWith('emergency-type-') ||
      key.startsWith('emergency-situation-')) {
    final fields = find.byType(DropdownButtonFormField<String>);
    final field = key.startsWith('emergency-type-')
        ? fields.first
        : fields.last;
    await tester.ensureVisible(field);
    await tester.tap(field);
    await tester.pumpAndSettle();
    final option = find.byKey(Key(key)).last;
    await tester.scrollUntilVisible(
      option,
      160,
      scrollable: find.byType(Scrollable).last,
    );
    await Scrollable.ensureVisible(tester.element(option), alignment: 0.5);
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(of: option, matching: find.byType(Text)).hitTestable(),
    );
    await tester.pumpAndSettle();
    return;
  }
  final finder = find.byKey(Key(key));
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _choose(
  WidgetTester tester, {
  String type = 'fire_smoke',
  String situation = 'building_fire',
  String danger = 'yes',
}) async {
  await _tap(tester, 'emergency-type-$type');
  await _tap(tester, 'emergency-situation-$situation');
  await _tap(tester, 'emergency-danger-$danger');
}

Future<void> _pump(
  WidgetTester tester,
  _ReportsRepositoryMock repository,
  _TestCreateReportUseCase create, {
  bool online = true,
  FlutterSecureStorage? storage,
  Future<Position> Function()? location,
  Locale locale = const Locale('en'),
  double textScale = 1,
  Widget? screen,
  List<Override> extraOverrides = const [],
}) async {
  when(
    () => repository.getFormOptions(),
  ).thenAnswer((_) async => data.offlineReportFormOptions);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        secureStorageProvider.overrideWithValue(
          storage ?? _authenticatedStorage(),
        ),
        authControllerProvider.overrideWithValue(_signedInUser),
        backendReachabilityProvider.overrideWith(
          _TestBackendReachabilityNotifier.new,
        ),
        isOnlineProvider.overrideWith(() => _TestConnectivityNotifier(online)),
        userPermissionsProvider.overrideWithValue(UserPermissions(null)),
        municipalitiesProvider.overrideWith(_TestMunicipalities.new),
        municipalityBarangaysProvider.overrideWith(
          _TestMunicipalityBarangays.new,
        ),
        data.reportsRepositoryProvider.overrideWithValue(repository),
        createReportUseCaseProvider.overrideWithValue(create),
        systemGovernanceProvider.overrideWith(_TestGovernance.new),
        ...extraOverrides,
      ],
      child: MaterialApp(
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home:
            screen ??
            EmergencyReportScreen(
              showMapTiles: false,
              locationOverride: location ?? () async => _position(),
            ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
  if (find.text('Resume').evaluate().isEmpty) await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'zero typing requires type situation danger and explicit Send with declarations',
    (tester) async {
      final repository = _ReportsRepositoryMock();
      final create = _TestCreateReportUseCase();
      await _pump(tester, repository, create);
      expect(find.byType(Checkbox), findsNothing);
      expect(find.byKey(const Key('quick-report-map')), findsNothing);
      expect(find.byKey(const Key('emergency-report-notes')), findsNothing);
      expect(
        tester
            .widget<FilledButton>(
              find.byKey(const Key('emergency-report-submit')),
            )
            .onPressed,
        isNull,
      );
      await _choose(tester);
      expect(
        tester.getTopLeft(find.byKey(const Key('emergency-report-submit'))).dy,
        lessThan(tester.getTopLeft(find.text('Emergency Help')).dy),
        reason: 'Sending must not require scrolling through the hotline list.',
      );
      expect(
        find.textContaining('declare the information is true'),
        findsOneWidget,
      );
      expect(find.textContaining('consent to data processing'), findsOneWidget);
      await _tap(tester, 'emergency-report-submit');
      expect(create.callCount, 1);
      expect(create.context, {
        'version': 1,
        'type_key': 'fire_smoke',
        'situation_key': 'building_fire',
        'immediate_danger': 'yes',
      });
      expect(
        create.description,
        'Fire or smoke: Building fire.\nInjury or immediate danger: Yes.',
      );
      expect(create.isQuickReport, isTrue);
      expect(create.isEmergency, isTrue);
      expect(create.declaration, isTrue);
      expect(create.consent, isTrue);
      expect(create.idempotencyKey, startsWith('report-key_'));
      expect(find.text('Add details'), findsOneWidget);
      expect(find.text('Add Photos'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
      verifyNever(
        () => repository.getNearbyReports(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
          municipalityId: any(named: 'municipalityId'),
        ),
      );
      await tester.ensureVisible(find.text('Done'));
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('changing type clears situation and trims optional notes', (
    tester,
  ) async {
    final create = _TestCreateReportUseCase();
    await _pump(tester, _ReportsRepositoryMock(), create);
    await _choose(tester);
    await _tap(tester, 'emergency-type-fire_smoke');
    expect(
      tester
          .widget<DropdownButtonFormField<String>>(
            find.byType(DropdownButtonFormField<String>).last,
          )
          .initialValue,
      'building_fire',
    );
    await _tap(tester, 'emergency-type-flood_disaster');
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const Key('emergency-report-submit')),
          )
          .onPressed,
      isNull,
    );
    await _tap(tester, 'emergency-situation-street_flooding');
    await _tap(tester, 'emergency-toggle-notes');
    await tester.ensureVisible(find.byKey(const Key('emergency-report-notes')));
    await tester.enterText(
      find.byKey(const Key('emergency-report-notes')),
      '  Water reaching homes  ',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await _tap(tester, 'emergency-report-submit');
    expect(create.context!['notes'], 'Water reaching homes');
    expect(create.context!['type_key'], 'flood_disaster');
    expect(create.context!['situation_key'], 'street_flooding');
    expect(create.category, 'flood_disaster');
  });

  testWidgets(
    'legacy quick draft preserves text and pin and requires new choices',
    (tester) async {
      final storage = _authenticatedStorage();
      final now = DateTime.utc(2026, 10, 18);
      await ReportDraftStore(storage).write(
        ReportDraft(
          schemaVersion: 1,
          draftId: 'legacy-quick',
          ownerId: 'user-A',
          type: ReportDraftType.quick,
          createdAt: now,
          updatedAt: now,
          resumeStep: 'form',
          payload: {
            'description': 'Saved rising water',
            'latitude': 15.979204,
            'longitude': 120.622210,
          },
          attachmentRefs: const [],
        ),
      );
      final create = _TestCreateReportUseCase();
      await _pump(tester, _ReportsRepositoryMock(), create, storage: storage);
      await tester.tap(find.text('Resume'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('emergency-legacy-draft-notice')),
        findsOneWidget,
      );
      expect(
        find.textContaining('Your saved text and location are kept'),
        findsOneWidget,
      );
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('emergency-report-notes')))
            .controller!
            .text,
        'Saved rising water',
      );
      expect(find.textContaining('15.97920, 120.62221'), findsOneWidget);
      expect(create.callCount, 0);
      expect(
        tester
            .widget<FilledButton>(
              find.byKey(const Key('emergency-report-submit')),
            )
            .onPressed,
        isNull,
      );
      final migrated = await ReportDraftStore(
        storage,
      ).read('user-A', ReportDraftType.quick);
      expect(migrated!.payload['description'], 'Saved rising water');
      expect(
        await ReportDraftStore(
          storage,
        ).read('user-A', ReportDraftType.emergency),
        isNull,
      );
    },
  );

  for (final startNew in [false, true]) {
    testWidgets(
      'dual drafts preserve other slot when legacy ${startNew ? 'starts new' : 'resumes'}',
      (tester) async {
        final storage = _authenticatedStorage();
        final now = DateTime.utc(2026, 10, 19);
        for (final type in [ReportDraftType.quick, ReportDraftType.emergency]) {
          await ReportDraftStore(storage).write(
            ReportDraft(
              schemaVersion: 1,
              draftId: 'saved-${type.name}',
              ownerId: 'user-A',
              type: type,
              createdAt: now,
              updatedAt: now,
              resumeStep: 'form',
              payload: {
                'description': 'Original ${type.name}',
                'latitude': 15.979204,
                'longitude': 120.622210,
              },
              attachmentRefs: const [],
            ),
          );
        }
        final before = await ReportDraftStore(
          storage,
        ).read('user-A', ReportDraftType.emergency);
        await _pump(
          tester,
          _ReportsRepositoryMock(),
          _TestCreateReportUseCase(),
          storage: storage,
          screen: EmergencyReportScreen(
            resumeDraftType: ReportDraftType.quick,
            showMapTiles: false,
            locationOverride: () async => _position(),
          ),
        );
        if (startNew) {
          await tester.ensureVisible(find.text('Start New'));
          await tester.tap(find.text('Start New'));
          await tester.pump(const Duration(milliseconds: 400));
          await tester.pump(const Duration(milliseconds: 400));
          await tester.tap(find.text('Discard Draft').last);
        } else {
          await tester.tap(find.text('Resume'));
        }
        await tester.pumpAndSettle();
        await _choose(tester);
        await tester.pump(const Duration(milliseconds: 400));
        final preserved = await ReportDraftStore(
          storage,
        ).read('user-A', ReportDraftType.emergency);
        expect(preserved!.toJson(), before!.toJson());
        final quick = await ReportDraftStore(
          storage,
        ).read('user-A', ReportDraftType.quick);
        expect(quick, isNotNull);
        if (!startNew) expect(quick!.draftId, 'saved-quick');
        expect(quick!.payload['typeKey'], 'fire_smoke');
      },
    );
  }

  testWidgets(
    'long legacy draft text remains available without exceeding notes limit',
    (tester) async {
      final storage = _authenticatedStorage();
      final now = DateTime.utc(2026, 10, 18);
      final original = 'long saved draft ' * 30;
      await ReportDraftStore(storage).write(
        ReportDraft(
          schemaVersion: 1,
          draftId: 'legacy-long',
          ownerId: 'user-A',
          type: ReportDraftType.emergency,
          createdAt: now,
          updatedAt: now,
          resumeStep: 'form',
          payload: {
            'description': original,
            'latitude': 15.979204,
            'longitude': 120.622210,
          },
          attachmentRefs: const [],
        ),
      );
      await _pump(
        tester,
        _ReportsRepositoryMock(),
        _TestCreateReportUseCase(),
        storage: storage,
      );
      await tester.tap(find.text('Resume'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('emergency-report-notes')))
            .controller!
            .text,
        original,
      );
      await _choose(tester);
      expect(
        tester
            .widget<FilledButton>(
              find.byKey(const Key('emergency-report-submit')),
            )
            .onPressed,
        isNull,
      );
      expect(find.text('Keep notes within 300 characters.'), findsOneWidget);
      final draft = await ReportDraftStore(
        storage,
      ).read('user-A', ReportDraftType.emergency);
      expect(draft!.payload['notes'], original);
      await tester.ensureVisible(
        find.byKey(const Key('emergency-report-notes')),
      );
      await tester.enterText(
        find.byKey(const Key('emergency-report-notes')),
        'Citizen shortened notes',
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<FilledButton>(
              find.byKey(const Key('emergency-report-submit')),
            )
            .onPressed,
        isNotNull,
      );
    },
  );

  testWidgets(
    'offline emergency queues unchanged context and resumes only once',
    (tester) async {
      final create = _TestCreateReportUseCase();
      await _pump(tester, _ReportsRepositoryMock(), create, online: false);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(EmergencyReportScreen)),
      );
      await _choose(
        tester,
        type: 'other_emergency',
        situation: 'rescue_needed',
        danger: 'unknown',
      );
      await _tap(tester, 'emergency-report-submit');
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Not sent yet'),
        ),
        findsOneWidget,
      );
      expect(
        find.textContaining('BayanTrack has not confirmed receipt'),
        findsOneWidget,
      );
      expect(create.callCount, 0);
      final queued = await container
          .read(reportCreateOutboxStoreProvider)
          .readAll('user-A');
      expect(queued, hasLength(1));
      expect(queued.single.type, ReportDraftType.emergency);
      expect(queued.single.payload['isEmergency'], isTrue);
      expect(queued.single.payload['isQuickReport'], isTrue);
      expect(queued.single.payload['category'], isNull);
      expect(queued.single.payload['emergencyContext'], {
        'version': 1,
        'type_key': 'other_emergency',
        'situation_key': 'rescue_needed',
        'immediate_danger': 'unknown',
      });
      final immutablePayload = queued.single.toJson()['payload'];
      container.read(isOnlineProvider.notifier).setOnline(true);
      expect(
        await container.read(reportCreateOutboxProvider).resume('user-A'),
        1,
      );
      expect(create.callCount, 1);
      expect(create.idempotencyKey, queued.single.idempotencyKey);
      expect(create.context, (immutablePayload as Map)['emergencyContext']);
      await container.read(reportCreateOutboxProvider).resume('user-A');
      expect(create.callCount, 1);
    },
  );

  testWidgets(
    'location failure keeps Send disabled and map is opened by Change location',
    (tester) async {
      await _pump(
        tester,
        _ReportsRepositoryMock(),
        _TestCreateReportUseCase(),
        location: () async => throw Exception('GPS unavailable'),
      );
      await _choose(tester);
      expect(
        tester
            .widget<FilledButton>(
              find.byKey(const Key('emergency-report-submit')),
            )
            .onPressed,
        isNull,
      );
      await _tap(tester, 'emergency-change-location');
      expect(find.byKey(const Key('quick-report-map')), findsOneWidget);
      await tester.ensureVisible(find.text('Enter coordinates'));
      await tester.tap(find.text('Enter coordinates'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('emergency-latitude')),
        '15.979204',
      );
      await tester.enterText(
        find.byKey(const Key('emergency-longitude')),
        '120.622210',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<FilledButton>(
              find.byKey(const Key('emergency-report-submit')),
            )
            .onPressed,
        isNotNull,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('automatic location alone does not save an empty draft', (
    tester,
  ) async {
    final storage = _authenticatedStorage();
    await _pump(
      tester,
      _ReportsRepositoryMock(),
      _TestCreateReportUseCase(),
      storage: storage,
    );
    await tester.pump(const Duration(milliseconds: 400));
    expect(
      await ReportDraftStore(storage).read('user-A', ReportDraftType.emergency),
      isNull,
    );
  });

  testWidgets('Send is guarded synchronously against repeated taps', (
    tester,
  ) async {
    final create = _TestCreateReportUseCase()
      ..pending = Completer<Result<domain.Report>>();
    await _pump(tester, _ReportsRepositoryMock(), create);
    await _choose(tester);
    final send = tester
        .widget<FilledButton>(find.byKey(const Key('emergency-report-submit')))
        .onPressed!;
    send();
    send();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(create.callCount, 1);
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const Key('emergency-report-submit')),
          )
          .onPressed,
      isNull,
    );
    create.pending!.complete(
      Success(
        domain.Report(id: 'emergency-1', description: '', isEmergency: true),
      ),
    );
    await tester.pumpAndSettle();
    expect(create.callCount, 1);
  });

  testWidgets(
    'enrichment appends latest server description within remaining budget',
    (tester) async {
      final repository = _UnusedDomainReportsRepository();
      const original =
          'Fire or smoke: Building fire.\nInjury or immediate danger: Yes.\nNotes: A &amp; B';
      when(() => repository.getReport('emergency-1')).thenAnswer(
        (_) async => Success(
          domain.Report(
            id: 'emergency-1',
            description: original,
            isEmergency: true,
          ),
        ),
      );
      String? updated;
      when(
        () => repository.updateReport(
          id: 'emergency-1',
          title: null,
          description: any(named: 'description'),
        ),
      ).thenAnswer((invocation) async {
        updated = invocation.namedArguments[#description] as String?;
        return Success(domain.Report(id: 'emergency-1', description: updated!));
      });
      await _pump(
        tester,
        _ReportsRepositoryMock(),
        _TestCreateReportUseCase(),
        extraOverrides: [
          getReportUseCaseProvider.overrideWithValue(
            GetReportUseCase(repository: repository),
          ),
          updateReportUseCaseProvider.overrideWithValue(
            UpdateReportUseCase(repository: repository),
          ),
        ],
      );
      await _choose(tester);
      await _tap(tester, 'emergency-report-submit');
      await tester.ensureVisible(find.text('Add details'));
      await tester.tap(find.text('Add details'));
      await tester.pumpAndSettle();
      final field = tester.widget<TextField>(
        find.byKey(const Key('emergency-report-details')),
      );
      expect(
        field.maxLength,
        500 - original.runes.length - '\n\nAdditional details:\n'.length,
      );
      await tester.enterText(
        find.byKey(const Key('emergency-report-details')),
        'People are outside',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(updated, '$original\n\nAdditional details:\nPeople are outside');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'compatibility Quick caller opens same structured emergency flow',
    (tester) async {
      await _pump(
        tester,
        _ReportsRepositoryMock(),
        _TestCreateReportUseCase(),
        // ignore: deprecated_member_use_from_same_package
        screen: QuickReportScreen(
          showMapTiles: false,
          locationOverride: () async => _position(),
        ),
      );
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
      expect(find.byKey(const Key('emergency-report-submit')), findsOneWidget);
      expect(find.byKey(const Key('quick-report-description')), findsNothing);
    },
  );

  for (final size in [const Size(320, 640), const Size(360, 800)]) {
    testWidgets(
      'Filipino large text fits ${size.width} screen and dropdowns preserve selection',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final semantics = tester.ensureSemantics();

        await _pump(
          tester,
          _ReportsRepositoryMock(),
          _TestCreateReportUseCase(),
          locale: const Locale('fil'),
          textScale: 1.8,
        );
        expect(find.text('Uri ng insidente'), findsOneWidget);
        await _tap(tester, 'emergency-type-infrastructure_hazard');
        await _tap(tester, 'emergency-situation-unsafe_structure');
        expect(tester.takeException(), isNull);
        await _choose(tester);
        expect(
          tester
              .widget<DropdownButtonFormField<String>>(
                find.byType(DropdownButtonFormField<String>).first,
              )
              .initialValue,
          'fire_smoke',
        );
        await _tap(tester, 'emergency-report-submit');
        expect(find.text('Add details'), findsNothing);
        expect(find.byType(BottomSheet), findsOneWidget);
        expect(tester.takeException(), isNull);
        semantics.dispose();
      },
    );
  }
}

const _signedInUser = AuthSuccess(
  'test',
  User(
    id: 'user-A',
    email: 'citizen@example.test',
    firstName: 'Test',
    lastName: 'Citizen',
    role: UserRole.citizen,
  ),
);

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
