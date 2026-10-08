import 'package:bayantrack_mobile/core/maps/municipality_boundary.dart';
import 'package:bayantrack_mobile/core/constants/urdaneta_geo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('bundled actual Urdaneta boundary supports offline proximity', () {
    final boundary = UrdanetaGeo.boundaryGeometry;
    final point = boundary.polygons.first.first.first;
    expect(
      boundary.distanceToBoundaryMeters(point.latitude, point.longitude),
      closeTo(0, 1),
    );
  });
  final boundary = MunicipalityBoundary.tryParse({
    'type': 'Polygon',
    'coordinates': [
      [
        [120.0, 15.0],
        [120.1, 15.0],
        [120.1, 15.1],
        [120.0, 15.1],
        [120.0, 15.0],
      ],
    ],
  })!;

  test(
    'boundary proximity is geometry based and does not change containment',
    () {
      expect(boundary.distanceToBoundaryMeters(15.0, 120.05), closeTo(0, 1));
      expect(
        boundary.distanceToBoundaryMeters(15.001, 120.05),
        inInclusiveRange(100, 120),
      );
      expect(
        boundary.distanceToBoundaryMeters(15.05, 120.05),
        greaterThan(5000),
      );
      expect(boundary.contains(14.999, 120.05), isFalse);
      expect(boundary.distanceToBoundaryMeters(14.999, 120.05), lessThan(500));
      expect(boundary.distanceToBoundaryMeters(double.nan, 120), isNull);
      expect(boundary.distanceToBoundaryMeters(91, 120), isNull);
    },
  );
}
