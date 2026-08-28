import 'dart:async';

import 'package:bayantrack_mobile/core/constants/urdaneta_barangays.dart';
import 'package:bayantrack_mobile/core/domain/result.dart';
import 'package:bayantrack_mobile/core/theme/app_theme.dart';
import 'package:bayantrack_mobile/features/auth/data/auth_models.dart';
import 'package:bayantrack_mobile/features/auth/data/user_permissions.dart';
import 'package:bayantrack_mobile/features/auth/presentation/barangays_provider.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  testWidgets(
    'emergency screen submits minimal confirmed report then offers enrichment',
    (tester) async {
      tester.view.physicalSize = const Size(360, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final reportsRepository = _ReportsRepositoryMock();
      final createUseCase = _TestCreateReportUseCase();
      when(
        () => reportsRepository.getFormOptions(),
      ).thenAnswer((_) async => data.offlineReportFormOptions);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
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
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('emergency-report-notice')), findsOneWidget);
      expect(
        find.text(
          'For immediate threats. BayanTrack does not replace emergency hotlines.',
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('quick-report-description')), findsNothing);

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
      expect(createUseCase.idempotencyKey, startsWith('emergency-'));
      expect(find.text('Add details'), findsOneWidget);
      expect(find.text('Add Photos'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
    },
  );
}
