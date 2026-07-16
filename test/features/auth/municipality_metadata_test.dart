import 'package:bayantrack_mobile/core/utils/municipality_geo.dart';
import 'package:bayantrack_mobile/features/auth/data/auth_models.dart';
import 'package:bayantrack_mobile/features/auth/presentation/barangays_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const otherBounds = MunicipalityBounds(
    south: 14,
    west: 120,
    north: 15,
    east: 121,
  );
  const other = MunicipalityModel(
    id: 'other_city',
    name: 'Other City',
    province: 'Pangasinan',
    centerLat: 14.5,
    centerLng: 120.5,
    bounds: otherBounds,
  );

  test('parses canonical municipality metadata and bounds', () {
    final response = MunicipalitiesResponse.fromJson({
      'municipalities': [
        {
          'id': 'urdaneta',
          'name': 'Urdaneta',
          'province': 'Pangasinan',
          'center_lat': 15.97,
          'center_lng': 120.57,
          'bounds': {
            'south': 15.9,
            'west': 120.4,
            'north': 16.1,
            'east': 120.7,
          },
          'is_default': true,
          'is_supported': true,
        },
      ],
      'count': 1,
      'default_municipality_id': 'urdaneta',
    });

    expect(response.defaultMunicipalityId, 'urdaneta');
    expect(response.municipalities.single.bounds?.isValid, isTrue);
  });

  test('rejects empty, duplicate, or unusable municipality refreshes', () {
    expect(validateMunicipalities(const []), isNull);
    expect(
      validateMunicipalities(const [
        bundledUrdanetaMunicipality,
        bundledUrdanetaMunicipality,
      ]),
      isNull,
    );
    expect(
      validateMunicipalities(const [
        bundledUrdanetaMunicipality,
        MunicipalityModel(
          id: 'missing_bounds',
          name: 'Missing Bounds',
          province: 'Pangasinan',
        ),
      ]),
      isNull,
    );
    expect(
      validateMunicipalities(const [bundledUrdanetaMunicipality, other]),
      hasLength(2),
    );
  });

  test('API refresh cannot shrink bundled Urdaneta map bounds', () {
    final values = validateMunicipalities(const [
      MunicipalityModel(
        id: defaultMunicipalityId,
        name: 'Urdaneta City',
        province: 'Pangasinan',
        centerLat: 15.98,
        centerLng: 120.58,
        bounds: MunicipalityBounds(
          south: 15.97,
          west: 120.57,
          north: 15.99,
          east: 120.59,
        ),
        isDefault: true,
      ),
    ]);

    expect(values, isNotNull);
    expect(values!.single.bounds, same(bundledUrdanetaMunicipality.bounds));
    expect(values.single.centerLat, bundledUrdanetaMunicipality.centerLat);
    expect(values.single.centerLng, bundledUrdanetaMunicipality.centerLng);
    expect(values.single.name, 'Urdaneta City');
  });

  test('rejects empty and cross-municipality barangay refreshes', () {
    expect(validateMunicipalityBarangays('other_city', const []), isNull);
    expect(
      validateMunicipalityBarangays('other_city', const [
        BarangayModel(
          id: 'urdaneta_only',
          name: 'Wrong Barangay',
          centerLat: 15.9,
          centerLng: 120.5,
        ),
      ]),
      isNull,
    );
    expect(
      validateMunicipalityBarangays('other_city', const [
        BarangayModel(
          id: 'other_city:barangay_a',
          name: 'Barangay A',
          centerLat: 14.5,
          centerLng: 120.5,
          municipalityId: 'other_city',
        ),
      ]),
      hasLength(1),
    );
  });

  test('restores metadata by stable municipality ID', () {
    expect(
      findMunicipalityMetadata(const [
        bundledUrdanetaMunicipality,
        other,
      ], 'other_city'),
      same(other),
    );
  });

  test('uses exact Urdaneta polygon and bounds for other municipalities', () {
    expect(municipalityContains(other, 14.5, 120.5), isTrue);
    expect(municipalityContains(other, 16, 120.5), isFalse);
    expect(
      municipalityContains(
        bundledUrdanetaMunicipality,
        bundledUrdanetaMunicipality.bounds!.north,
        bundledUrdanetaMunicipality.bounds!.east,
      ),
      isFalse,
    );
  });
}
