import 'package:flutter_test/flutter_test.dart';
import 'package:bayantrack_mobile/features/auth/data/auth_models.dart';
import 'package:bayantrack_mobile/features/reports/presentation/new_report/quick_report_geo.dart';

void main() {
  group('deriveNearestBarangayName', () {
    test('returns null when barangay list is empty', () {
      final result = deriveNearestBarangayName(
        const [],
        latitude: 15.98,
        longitude: 120.62,
      );
      expect(result, isNull);
    });

    test('returns nearest barangay by center coordinates', () {
      const barangays = [
        BarangayModel(
          id: '1',
          name: 'Barangay A',
          centerLat: 15.9900,
          centerLng: 120.6300,
        ),
        BarangayModel(
          id: '2',
          name: 'Barangay B',
          centerLat: 15.9792,
          centerLng: 120.6222,
        ),
      ];

      final result = deriveNearestBarangayName(
        barangays,
        latitude: 15.979204,
        longitude: 120.622210,
      );
      expect(result, 'Barangay B');
    });
  });
}
