import 'package:bayantrack_mobile/core/maps/municipality_map.dart';
import 'package:bayantrack_mobile/features/auth/presentation/barangays_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('municipality camera fits padded verified bounds and stays constrained', () {
    final cameraBounds = MunicipalityMapCamera.boundsFor(
      bundledUrdanetaMunicipality,
    );

    expect(cameraBounds, isNotNull);
    expect(cameraBounds!.south, lessThan(bundledUrdanetaMunicipality.bounds!.south));
    expect(cameraBounds.north, greaterThan(bundledUrdanetaMunicipality.bounds!.north));
    expect(
      MunicipalityMapCamera.constraintFor(bundledUrdanetaMunicipality),
      isNotNull,
    );
    expect(
      MunicipalityMapCamera.initialFit(bundledUrdanetaMunicipality),
      isNotNull,
    );
  });
}
