import 'dart:ui';

import 'package:bayantrack_mobile/core/maps/municipality_map.dart';
import 'package:bayantrack_mobile/features/auth/data/auth_models.dart';
import 'package:bayantrack_mobile/features/auth/presentation/barangays_provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';

class _MapControllerMock extends Mock implements MapController {}

class _CameraFitFake extends Fake implements CameraFit {}

void main() {
  setUpAll(() => registerFallbackValue(_CameraFitFake()));

  test(
    'municipality camera uses canonical geometry for fit, constraint, and recenter',
    () {
      final municipality = MunicipalityModel(
        id: bundledUrdanetaMunicipality.id,
        name: bundledUrdanetaMunicipality.name,
        province: bundledUrdanetaMunicipality.province,
        boundary: bundledUrdanetaMunicipality.boundary,
        bounds: const MunicipalityBounds(
          south: -10,
          west: -10,
          north: 10,
          east: 10,
        ),
      );
      final cameraBounds = MunicipalityMapCamera.boundsFor(municipality)!;
      final canonicalBounds = MunicipalityMapCamera.boundsFor(
        bundledUrdanetaMunicipality,
      )!;

      expect(cameraBounds, canonicalBounds);
      final fit = MunicipalityMapCamera.initialFit(municipality)! as FitBounds;
      final constraint = MunicipalityMapCamera.constraintFor(municipality)!;

      expect(fit.bounds, cameraBounds);
      expect(constraint, isA<ContainCameraCenter>());
      expect((constraint as ContainCameraCenter).bounds, cameraBounds);
      final corrected = constraint.constrain(
        MapCamera(
          crs: const Epsg3857(),
          center: LatLng(cameraBounds.north + 1, cameraBounds.east + 1),
          zoom: 12,
          rotation: 0,
          nonRotatedSize: const Size(375, 300),
        ),
      );
      expect(corrected, isNotNull);
      expect(corrected.center.latitude, cameraBounds.north);
      expect(corrected.center.longitude, cameraBounds.east);

      final controller = _MapControllerMock();
      when(() => controller.fitCamera(any())).thenReturn(true);
      MunicipalityMapCamera.recenter(controller, municipality);
      final recenterFit =
          verify(() => controller.fitCamera(captureAny())).captured.single
              as FitBounds;
      expect(recenterFit.bounds, cameraBounds);
    },
  );

  test('map controller disposal closes its event stream', () async {
    final controller = MapController();
    final done = expectLater(controller.mapEventStream, emitsDone);
    controller.dispose();
    await done;
  });
}
