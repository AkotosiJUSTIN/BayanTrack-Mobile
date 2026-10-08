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
import 'package:bayantrack_mobile/features/help/data/help_content.dart';
import 'package:bayantrack_mobile/features/reports/data/report_draft_store.dart';
import 'package:bayantrack_mobile/features/reports/data/reports_repository.dart'
    as data;
import 'package:bayantrack_mobile/features/reports/domain/entities/report.dart'
    as domain;
import 'package:bayantrack_mobile/features/reports/domain/reports_repository.dart'
    as domain_repository;
import 'package:bayantrack_mobile/features/reports/domain/usecases/create_report_usecase.dart';
import 'package:bayantrack_mobile/features/reports/presentation/new_report/quick_report_screen.dart';
import 'package:bayantrack_mobile/features/reports/reports_di.dart';
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
  String? idempotencyKey;

  @override
  Future<Result<domain.Report>> call({
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
  }) async {
    callCount++;
    this.category = category;
    this.description = description;
    this.isEmergency = isEmergency;
    this.idempotencyKey = idempotencyKey;
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'resumed emergency draft is not transmitted and needs fresh confirmation',
    (tester) async {
      tester.view.physicalSize = const Size(360, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final storage = _StorageMock();
      final values = <String, String>{};
      when(() => storage.read(key: any(named: 'key'))).thenAnswer(
        (invocation) async => values[invocation.namedArguments[#key]],
      );
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
          draftId: 'emergency-draft-1',
          ownerId: 'user-A',
          type: ReportDraftType.emergency,
          createdAt: now,
          updatedAt: now,
          resumeStep: 'form',
          payload: {
            'categoryKey': 'flood_disaster',
            'latitude': 15.979204,
            'longitude': 120.622210,
          },
          attachmentRefs: const [],
        ),
      );
      final reportsRepository = _ReportsRepositoryMock();
      final createUseCase = _TestCreateReportUseCase();
      when(
        () => reportsRepository.getFormOptions(),
      ).thenAnswer((_) async => data.offlineReportFormOptions);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageProvider.overrideWithValue(storage),
            authControllerProvider.overrideWithValue(
              AuthSuccess(
                'test',
                const User(
                  id: 'user-A',
                  email: 'citizen@example.test',
                  firstName: 'Test',
                  lastName: 'Citizen',
                  role: UserRole.citizen,
                ),
              ),
            ),
            userPermissionsProvider.overrideWithValue(UserPermissions(null)),
            municipalitiesProvider.overrideWith(_TestMunicipalities.new),
            municipalityBarangaysProvider.overrideWith(
              _TestMunicipalityBarangays.new,
            ),
            data.reportsRepositoryProvider.overrideWithValue(reportsRepository),
            createReportUseCaseProvider.overrideWithValue(createUseCase),
          ],
          child: MaterialApp(
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            theme: AppTheme.light,
            home: QuickReportScreen(
              emergencyMode: true,
              showMapTiles: false,
              locationOverride: () async => _position(),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.scrollUntilVisible(
        find.text('Resume'),
        180,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.text('Resume'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('NOT YET TRANSMITTED'), findsOneWidget);
      final checkbox = find.descendant(
        of: find.byKey(const Key('emergency-report-confirmation')),
        matching: find.byType(Checkbox),
      );
      expect(tester.widget<Checkbox>(checkbox).value, isFalse);
      expect(createUseCase.callCount, 0);
      final submit = tester.widget<ElevatedButton>(
        find.byKey(const Key('emergency-report-submit')),
      );
      expect(submit.onPressed, isNull);
    },
  );

  testWidgets(
    'emergency screen submits minimal confirmed report then offers enrichment',
    (tester) async {
      tester.view.physicalSize = const Size(360, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final reportsRepository = _ReportsRepositoryMock();
      final createUseCase = _TestCreateReportUseCase();
      final storage = _authenticatedStorage();
      final launched = <Uri>[];
      when(
        () => reportsRepository.getFormOptions(),
      ).thenAnswer((_) async => data.offlineReportFormOptions);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageProvider.overrideWithValue(storage),
            authControllerProvider.overrideWithValue(_signedInUser),
            backendReachabilityProvider.overrideWith(
              _TestBackendReachabilityNotifier.new,
            ),
            isOnlineProvider.overrideWith(
              () => _TestConnectivityNotifier(true),
            ),
            userPermissionsProvider.overrideWithValue(UserPermissions(null)),
            municipalitiesProvider.overrideWith(_TestMunicipalities.new),
            municipalityBarangaysProvider.overrideWith(
              _TestMunicipalityBarangays.new,
            ),
            data.reportsRepositoryProvider.overrideWithValue(reportsRepository),
            createReportUseCaseProvider.overrideWithValue(createUseCase),
          ],
          child: MaterialApp(
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            theme: AppTheme.light,
            home: QuickReportScreen(
              emergencyMode: true,
              showMapTiles: false,
              locationOverride: () async => _position(),
              launchCall: (uri) async {
                launched.add(uri);
                return true;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Step 1 of 1'), findsOneWidget);
      expect(find.byKey(const Key('emergency-report-notice')), findsOneWidget);
      expect(
        find.text(
          'For immediate response, call an emergency service using the hotline below. Submitting this report does not dispatch a team.',
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('quick-report-description')), findsNothing);
      expect(launched, isEmpty);
      for (final hotline in emergencyHotlines) {
        final tile = find.byKey(ValueKey('hotline-call-${hotline.number}'));
        await tester.ensureVisible(tile);
        await tester.tap(tile);
        await tester.pumpAndSettle();
      }
      expect(launched, emergencyHotlines.map((h) => hotlineCallUri(h.number)));

      await tester.ensureVisible(
        find.byKey(const Key('emergency-report-category')),
      );
      await tester.tap(find.byKey(const Key('emergency-report-category')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Flood & Disaster Response').last);
      await tester.ensureVisible(
        find.byKey(const Key('emergency-report-confirmation')),
      );
      final confirmation = find.descendant(
        of: find.byKey(const Key('emergency-report-confirmation')),
        matching: find.byType(Checkbox),
      );
      tester.widget<Checkbox>(confirmation).onChanged!(true);
      await tester.pump();

      final submit = tester.widget<ElevatedButton>(
        find.byKey(const Key('emergency-report-submit')),
      );
      expect(submit.onPressed, isNotNull);

      await tester.tap(find.byKey(const Key('emergency-report-submit')));
      await tester.pumpAndSettle();

      expect(createUseCase.callCount, 1);
      expect(createUseCase.category, 'flood_disaster');
      expect(createUseCase.description, isEmpty);
      expect(createUseCase.isEmergency, isTrue);
      expect(createUseCase.idempotencyKey, startsWith('report-key_'));
      expect(find.text('Add details'), findsOneWidget);
      expect(find.text('Add Photos'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
    },
  );

  testWidgets(
    'offline emergency says not transmitted and gives call guidance',
    (tester) async {
      tester.view.physicalSize = const Size(360, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final reportsRepository = _ReportsRepositoryMock();
      final createUseCase = _TestCreateReportUseCase();
      final launched = <Uri>[];
      when(
        () => reportsRepository.getFormOptions(),
      ).thenAnswer((_) async => data.offlineReportFormOptions);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageProvider.overrideWithValue(_authenticatedStorage()),
            authControllerProvider.overrideWithValue(_signedInUser),
            backendReachabilityProvider.overrideWith(
              _TestBackendReachabilityNotifier.new,
            ),
            isOnlineProvider.overrideWith(
              () => _TestConnectivityNotifier(false),
            ),
            userPermissionsProvider.overrideWithValue(UserPermissions(null)),
            municipalitiesProvider.overrideWith(_TestMunicipalities.new),
            municipalityBarangaysProvider.overrideWith(
              _TestMunicipalityBarangays.new,
            ),
            data.reportsRepositoryProvider.overrideWithValue(reportsRepository),
            createReportUseCaseProvider.overrideWithValue(createUseCase),
          ],
          child: MaterialApp(
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            theme: AppTheme.light,
            home: QuickReportScreen(
              emergencyMode: true,
              showMapTiles: false,
              locationOverride: () async => _position(),
              launchCall: (uri) async {
                launched.add(uri);
                return true;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('NOT YET TRANSMITTED'), findsOneWidget);
      await tester.ensureVisible(
        find.byKey(const Key('emergency-report-category')),
      );
      await tester.tap(find.byKey(const Key('emergency-report-category')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Flood & Disaster Response').last);
      final checkbox = find.descendant(
        of: find.byKey(const Key('emergency-report-confirmation')),
        matching: find.byType(Checkbox),
      );
      tester.widget<Checkbox>(checkbox).onChanged!(true);
      await tester.pump();
      await tester.tap(find.byKey(const Key('emergency-report-submit')));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('NOT YET TRANSMITTED'),
        ),
        findsOneWidget,
      );
      expect(
        find.textContaining('call local emergency services'),
        findsOneWidget,
      );
      expect(
        find.textContaining('BayanTrack has not confirmed receipt'),
        findsOneWidget,
      );
      expect(createUseCase.callCount, 0);
      expect(launched, isEmpty);
      final dialogCall = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byKey(const ValueKey('hotline-call-911')),
      );
      await tester.ensureVisible(dialogCall);
      await tester.tap(dialogCall);
      await tester.pumpAndSettle();
      expect(launched, [hotlineCallUri(emergencyHotlines.first.number)]);
      expect(createUseCase.callCount, 0);
      expect(tester.takeException(), isNull);
    },
  );
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
