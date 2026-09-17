import 'dart:io';

import 'package:bayantrack_mobile/core/domain/result.dart';
import 'package:bayantrack_mobile/features/reports/data/report_models.dart'
    as dto;
import 'package:bayantrack_mobile/features/auth/data/auth_models.dart';
import 'package:bayantrack_mobile/features/reports/domain/entities/report.dart';
import 'package:bayantrack_mobile/features/reports/domain/reports_repository.dart';
import 'package:bayantrack_mobile/features/reports/domain/usecases/create_report_usecase.dart';
import 'package:bayantrack_mobile/features/reports/presentation/new_report/new_report_controller.dart';
import 'package:bayantrack_mobile/features/reports/reports_di.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _UnusedReportsRepository extends Mock implements ReportsRepository {}

class _RecordingCreateReportUseCase extends CreateReportUseCase {
  _RecordingCreateReportUseCase()
    : super(repository: _UnusedReportsRepository());

  Map<String, Object?>? arguments;

  @override
  Future<Result<Report>> call({
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
    arguments = {
      'municipality_id': municipalityId,
      'barangay_id': barangayId,
      'barangay': barangay,
      'zone': zone,
      'city_municipality': cityMunicipality,
      'latitude': latitude,
      'longitude': longitude,
      'street_landmark': streetLandmark,
      'is_quick_report': isQuickReport,
    };
    return Success(Report(id: 'created', description: description));
  }
}

void main() {
  test('legacy report DTO defaults Urdaneta and derives barangay ID', () {
    final report = dto.Report.fromJson({
      'id': 'legacy-1',
      'description': 'Legacy report',
      'barangay': 'San Vicente',
    });

    expect(report.municipalityId, 'urdaneta');
    expect(report.barangayId, 'san_vicente');
  });

  test(
    'explicit report DTO preserves canonical municipality and barangay IDs',
    () {
      final report = dto.Report.fromJson({
        'id': 'new-1',
        'description': 'New report',
        'municipality_id': 'other_city',
        'barangay_id': 'other_city:barangay_a',
        'barangay': 'Barangay A',
      });

      expect(report.municipalityId, 'other_city');
      expect(report.barangayId, 'other_city:barangay_a');
    },
  );

  test('legacy create request parsing defaults canonical municipality ID', () {
    final request = dto.CreateReportRequest.fromJson({
      'description': 'Legacy request',
      'barangay': 'Poblacion',
    });

    expect(request.municipalityId, 'urdaneta');
  });

  test(
    'new report controller sends IDs plus legacy labels to use case',
    () async {
      final useCase = _RecordingCreateReportUseCase();
      final container = ProviderContainer(
        overrides: [createReportUseCaseProvider.overrideWithValue(useCase)],
      );
      addTearDown(container.dispose);
      final controller = container.read(newReportControllerProvider.notifier);

      controller
        ..setDescription('Scoped report')
        ..setMunicipality(
          id: 'other_city',
          name: 'Other City',
          province: 'Pangasinan',
        )
        ..setLocation(latitude: 15.9, longitude: 120.6)
        ..completeBarangayResolution(
          const BarangayModel(
            id: 'other_city:barangay_a',
            name: 'Barangay A',
            centerLat: 15.9,
            centerLng: 120.6,
            municipalityId: 'other_city',
          ),
        )
        ..setStreetLandmark('Barangay A Market')
        ..setDeclarationConfirmed(true)
        ..setDataProcessingConsent(true)
        ..addImage(File('unused-test-image.jpg'));

      await controller.submit();

      expect(useCase.arguments?['municipality_id'], 'other_city');
      expect(useCase.arguments?['barangay_id'], 'other_city:barangay_a');
      expect(useCase.arguments?['barangay'], 'Barangay A');
      expect(useCase.arguments?['city_municipality'], 'Other City');
      expect(useCase.arguments?['latitude'], '15.9000000000');
      expect(useCase.arguments?['longitude'], '120.6000000000');
      expect(useCase.arguments?['street_landmark'], 'Barangay A Market');
      expect(useCase.arguments?['is_quick_report'], isFalse);
    },
  );

  test('quick report sends the canonical Urdaneta location pair', () async {
    final useCase = _RecordingCreateReportUseCase();
    final container = ProviderContainer(
      overrides: [createReportUseCaseProvider.overrideWithValue(useCase)],
    );
    addTearDown(container.dispose);
    final controller = container.read(newReportControllerProvider.notifier);

    await controller.submitQuickReport(
      description: 'agik disgrasya',
      municipalityId: 'urdaneta',
      barangayId: 'bactad_east',
      barangay: 'Bactad East',
      streetLandmark: 'Bactad East Public Market',
      cityMunicipality: 'Urdaneta',
      province: 'Pangasinan',
      latitude: 15.981394,
      longitude: 120.628478,
    );

    expect(useCase.arguments?['municipality_id'], 'urdaneta');
    expect(useCase.arguments?['barangay_id'], 'bactad_east');
    expect(useCase.arguments?['barangay'], 'Bactad East');
    expect(useCase.arguments?['zone'], 'Bactad East');
    expect(useCase.arguments?['is_quick_report'], isTrue);
    expect(useCase.arguments?['street_landmark'], 'Bactad East Public Market');
  });

  test('clearLocation removes every stale location and barangay field', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(newReportControllerProvider.notifier);

    controller.setBarangay(id: 'nancayasan', name: 'Nancayasan');
    controller.setStreetLandmark('Public market');
    controller.setLocation(
      latitude: 15.95,
      longitude: 120.57,
      location: 'GPS pin',
    );
    controller.clearLocation();

    final state = container.read(newReportControllerProvider);
    expect(state.latitude, isNull);
    expect(state.longitude, isNull);
    expect(state.location, isNull);
    expect(state.streetLandmark, isNull);
    expect(state.zone, isNull);
    expect(state.barangayId, isNull);
    expect(state.barangay, isNull);
    expect(state.municipalityId, 'urdaneta');
  });
}
