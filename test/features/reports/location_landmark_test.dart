import 'package:bayantrack_mobile/features/auth/data/auth_models.dart';
import 'package:bayantrack_mobile/features/reports/presentation/new_report/new_report_controller.dart';
import 'package:bayantrack_mobile/features/reports/presentation/new_report/quick_report_geo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _barangays = [
  BarangayModel(
    id: 'a',
    name: 'Barangay A',
    centerLat: 15.9800,
    centerLng: 120.6200,
  ),
  BarangayModel(
    id: 'b',
    name: 'Barangay B',
    centerLat: 15.9900,
    centerLng: 120.6300,
  ),
];

void main() {
  test('queued report incident timestamp carries explicit UTC timezone', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(newReportControllerProvider.notifier);
    controller.setIncidentDatetime(DateTime(2026, 10, 11, 12, 18));
    final value = controller.submissionSnapshot()['incidentDatetime'] as String;
    expect(value.endsWith('Z'), isTrue);
    expect(DateTime.parse(value), DateTime(2026, 10, 11, 12, 18).toUtc());
  });

  group('coordinate barangay resolution', () {
    test('selects the nearest center and rejects distant matches', () {
      expect(
        deriveNearestBarangay(
          _barangays,
          latitude: 15.9801,
          longitude: 120.6201,
        )?.id,
        'a',
      );
      expect(
        deriveNearestBarangay(_barangays, latitude: 16.5, longitude: 121.0),
        isNull,
      );
    });

    test('a changed map pin replaces the prior resolved barangay', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(newReportControllerProvider.notifier);

      controller
        ..beginBarangayResolution()
        ..completeBarangayResolution(_barangays.first);
      expect(
        container.read(newReportControllerProvider).barangay,
        'Barangay A',
      );

      controller
        ..beginBarangayResolution()
        ..completeBarangayResolution(_barangays[1]);
      final state = container.read(newReportControllerProvider);
      expect(state.barangayId, 'b');
      expect(state.zone, 'Barangay B');
      expect(state.isResolvingBarangay, isFalse);
    });

    test('failed barangay lookup keeps coordinates usable as the fallback', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(newReportControllerProvider.notifier);

      controller.setLocation(latitude: 15.98, longitude: 120.62);
      controller.beginBarangayResolution();
      controller.completeBarangayResolution(null);

      final state = container.read(newReportControllerProvider);
      expect(state.latitude, 15.98);
      expect(state.longitude, 120.62);
      expect(state.barangay, isNull);
      expect(state.isResolvingBarangay, isFalse);
      expect(state.hasLocation, isTrue);
    });

    test('changing coordinates clears stale derived location data', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(newReportControllerProvider.notifier);

      controller
        ..setLocation(latitude: 15.98, longitude: 120.62)
        ..completeBarangayResolution(_barangays.first)
        ..setStreetLandmark('Public Market')
        ..beginLandmarkLookup()
        ..completeLandmarkLookup(
          const NearbyLandmarkSuggestion(prefill: 'Public Market'),
        )
        ..setLocation(latitude: 15.99, longitude: 120.63);

      final state = container.read(newReportControllerProvider);
      expect(state.latitude, 15.99);
      expect(state.longitude, 120.63);
      expect(state.barangay, isNull);
      expect(state.barangayId, isNull);
      expect(state.zone, isNull);
      expect(state.streetLandmark, isNull);
      expect(state.nearbyLandmarkSuggestions, isEmpty);
      expect(state.landmarkLookupCompleted, isFalse);
    });
  });

  group('nearby landmark suggestions', () {
    test(
      'dense POIs keep a nearby street among the five selectable suggestions',
      () {
        final result = suggestNearbyLandmark([
          for (var i = 0; i < 7; i++)
            NearbyLandmarkModel(
              name: 'Place $i',
              distanceMeters: 10 + i.toDouble(),
            ),
          const NearbyLandmarkModel(
            name: 'Aruego Street',
            distanceMeters: 80,
            isStreet: true,
          ),
          const NearbyLandmarkModel(
            name: 'Distant Road',
            distanceMeters: 251,
            isStreet: true,
          ),
        ]);
        expect(result.prefill, isNull);
        expect(result.choices, [
          'Place 0',
          'Place 1',
          'Place 2',
          'Place 3',
          'Aruego Street',
        ]);
      },
    );

    test('prefills one strong nearby place', () {
      final result = suggestNearbyLandmark([
        const NearbyLandmarkModel(name: 'Public Market', distanceMeters: 40),
      ]);

      expect(result.prefill, 'Public Market');
      expect(result.choices, isEmpty);
    });

    test('keeps the field blank when every place is outside the radius', () {
      final result = suggestNearbyLandmark([
        const NearbyLandmarkModel(name: 'Distant Mall', distanceMeters: 251),
      ]);

      expect(result.hasSuggestion, isFalse);
    });

    test('returns several plausible places for user choice', () {
      final result = suggestNearbyLandmark([
        const NearbyLandmarkModel(name: 'Clinic', distanceMeters: 40),
        const NearbyLandmarkModel(name: 'Market', distanceMeters: 90),
      ]);

      expect(result.prefill, isNull);
      expect(result.choices, ['Clinic', 'Market']);
    });

    test('does not overwrite a manually entered landmark', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(newReportControllerProvider.notifier);

      controller.setStreetLandmark('My own description');
      controller.beginLandmarkLookup();
      controller.completeLandmarkLookup(
        const NearbyLandmarkSuggestion(prefill: 'Provider Place'),
      );

      final state = container.read(newReportControllerProvider);
      expect(state.streetLandmark, 'My own description');
      expect(state.landmarkManuallyEdited, isTrue);
    });

    test(
      'failed lookup preserves manual text and reports a non-blocking error',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final controller = container.read(newReportControllerProvider.notifier);

        controller.setStreetLandmark('Keep this text');
        controller.beginLandmarkLookup();
        controller.failLandmarkLookup();
        controller.completeBarangayResolution(_barangays.first);

        final state = container.read(newReportControllerProvider);
        expect(state.streetLandmark, 'Keep this text');
        expect(state.isResolvingLandmark, isFalse);
        expect(state.landmarkLookupError, isNotNull);
      },
    );

    test('completed empty lookup is represented as no nearby landmark', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(newReportControllerProvider.notifier);

      controller
        ..beginLandmarkLookup(clearManual: true)
        ..completeLandmarkLookup(const NearbyLandmarkSuggestion());

      final state = container.read(newReportControllerProvider);
      expect(state.landmarkLookupCompleted, isTrue);
      expect(state.landmarkLookupError, isNull);
      expect(state.streetLandmark, isNull);
    });

    test('failed lookup stays distinguishable from an empty result', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(newReportControllerProvider.notifier);

      controller
        ..beginLandmarkLookup(clearManual: true)
        ..failLandmarkLookup();

      final state = container.read(newReportControllerProvider);
      expect(state.landmarkLookupCompleted, isFalse);
      expect(state.landmarkLookupError, landmarkLookupUnavailable);
    });
  });
}
