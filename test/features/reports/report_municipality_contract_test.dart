import 'package:bayantrack_mobile/features/reports/data/report_models.dart'
    as dto;
import 'package:bayantrack_mobile/features/reports/presentation/new_report/new_report_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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

  test('new report state sends IDs plus legacy labels', () {
    const state = NewReportState(
      description: 'Scoped report',
      municipalityId: 'other_city',
      barangayId: 'other_city:barangay_a',
      barangay: 'Barangay A',
      zone: 'Barangay A',
      cityMunicipality: 'Other City',
      province: 'Pangasinan',
    );

    final json = state.toCreateRequest().toJson();
    expect(json['municipality_id'], 'other_city');
    expect(json['barangay_id'], 'other_city:barangay_a');
    expect(json['barangay'], 'Barangay A');
    expect(json['city_municipality'], 'Other City');
  });

  test('Bactad East report sends the canonical Urdaneta location pair', () {
    const state = NewReportState(
      description: 'agik disgrasya',
      municipalityId: 'urdaneta',
      barangayId: 'bactad_east',
      barangay: 'Bactad East',
      zone: 'Bactad East',
      cityMunicipality: 'Urdaneta',
      province: 'Pangasinan',
      latitude: 15.981394,
      longitude: 120.628478,
    );

    final json = state.toCreateRequest().toJson();
    expect(json['municipality_id'], 'urdaneta');
    expect(json['barangay_id'], 'bactad_east');
    expect(json['barangay'], 'Bactad East');
    expect(json['zone'], 'Bactad East');
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
