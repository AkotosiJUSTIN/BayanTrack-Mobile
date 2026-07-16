import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/constants/urdaneta_geo.dart';
import '../../../core/constants/urdaneta_barangays.dart';
import '../../auth/auth_di.dart';
import '../data/auth_models.dart';

part 'barangays_provider.g.dart';

const defaultMunicipalityId = 'urdaneta';

const bundledUrdanetaMunicipality = MunicipalityModel(
  id: defaultMunicipalityId,
  name: UrdanetaGeo.defaultCityMunicipality,
  province: UrdanetaGeo.defaultProvince,
  centerLat: UrdanetaGeo.defaultLat,
  centerLng: UrdanetaGeo.defaultLng,
  bounds: MunicipalityBounds(
    south: UrdanetaGeo.south,
    west: UrdanetaGeo.west,
    north: UrdanetaGeo.north,
    east: UrdanetaGeo.east,
  ),
  isDefault: true,
);

class MunicipalityMetadataUnavailable implements Exception {
  final String municipalityId;
  const MunicipalityMetadataUnavailable(this.municipalityId);

  @override
  String toString() =>
      'Municipality metadata is unavailable for $municipalityId.';
}

List<MunicipalityModel>? validateMunicipalities(
  List<MunicipalityModel> values,
) {
  if (values.isEmpty) return null;
  final ids = <String>{};
  final validated = <MunicipalityModel>[];
  for (final municipality in values) {
    if (municipality.id.isEmpty ||
        municipality.name.isEmpty ||
        !municipality.isSupported ||
        !ids.add(municipality.id)) {
      return null;
    }
    if (municipality.id != defaultMunicipalityId &&
        !municipality.hasUsableBounds) {
      return null;
    }
    validated.add(
      municipality.id == defaultMunicipalityId
          ? MunicipalityModel(
              id: municipality.id,
              name: municipality.name,
              province: municipality.province,
              centerLat: bundledUrdanetaMunicipality.centerLat,
              centerLng: bundledUrdanetaMunicipality.centerLng,
              bounds: bundledUrdanetaMunicipality.bounds,
              isDefault: true,
              isSupported: municipality.isSupported,
            )
          : municipality,
    );
  }
  if (!ids.contains(defaultMunicipalityId)) return null;
  return List.unmodifiable(validated);
}

MunicipalityModel? findMunicipalityMetadata(
  List<MunicipalityModel> values,
  String municipalityId,
) {
  for (final municipality in values) {
    if (municipality.id == municipalityId) return municipality;
  }
  return null;
}

List<BarangayModel>? validateMunicipalityBarangays(
  String municipalityId,
  List<BarangayModel> values,
) {
  if (values.isEmpty) return null;
  final ids = <String>{};
  for (final barangay in values) {
    if (barangay.id.isEmpty ||
        barangay.name.isEmpty ||
        barangay.municipalityId != municipalityId ||
        !ids.add(barangay.id)) {
      return null;
    }
  }
  return List.unmodifiable(values);
}

@riverpod
class Municipalities extends _$Municipalities {
  @override
  FutureOr<List<MunicipalityModel>> build() {
    unawaited(_refreshFromApi());
    return const [bundledUrdanetaMunicipality];
  }

  Future<List<MunicipalityModel>?> _fetch() async {
    final result = await ref.read(authRepositoryProvider).getMunicipalities();
    return result.when(success: validateMunicipalities, failure: (_) => null);
  }

  Future<void> _refreshFromApi() async {
    final values = await _fetch();
    if (values != null) state = AsyncValue.data(values);
  }

  Future<void> refresh() => _refreshFromApi();
}

@riverpod
class MunicipalityBarangays extends _$MunicipalityBarangays {
  @override
  FutureOr<List<BarangayModel>> build(String municipalityId) async {
    if (municipalityId == defaultMunicipalityId) {
      unawaited(_refreshFromApi());
      return bundledUrdanetaBarangays;
    }
    final values = await _fetch();
    if (values == null) throw MunicipalityMetadataUnavailable(municipalityId);
    return values;
  }

  Future<List<BarangayModel>?> _fetch() async {
    final result = await ref
        .read(authRepositoryProvider)
        .getBarangays(municipalityId: municipalityId);
    return result.when(
      success: (values) =>
          validateMunicipalityBarangays(municipalityId, values),
      failure: (_) => null,
    );
  }

  Future<void> _refreshFromApi() async {
    final values = await _fetch();
    if (values != null) state = AsyncValue.data(values);
  }

  Future<void> refresh() async {
    final previous = state.asData?.value;
    final values = await _fetch();
    if (values != null) {
      state = AsyncValue.data(values);
    } else if (previous == null || previous.isEmpty) {
      state = AsyncValue.error(
        MunicipalityMetadataUnavailable(municipalityId),
        StackTrace.current,
      );
    }
  }
}

/// Provider that fetches and caches the list of barangays from the API.
/// Used by the new report screen for the location dropdown.
@riverpod
class Barangays extends _$Barangays {
  @override
  FutureOr<List<BarangayModel>> build() async {
    unawaited(_refreshFromApi());
    return bundledUrdanetaBarangays;
  }

  Future<List<BarangayModel>> _fetchFromApiOrBundle() async {
    final authRepo = ref.read(authRepositoryProvider);
    final result = await authRepo.getBarangays(
      municipalityId: defaultMunicipalityId,
    );

    return result.when(
      success: (barangays) =>
          validateMunicipalityBarangays(defaultMunicipalityId, barangays) ??
          bundledUrdanetaBarangays,
      failure: (_) => bundledUrdanetaBarangays,
    );
  }

  Future<void> _refreshFromApi() async {
    final barangays = await _fetchFromApiOrBundle();
    state = AsyncValue.data(barangays);
  }

  /// Refresh barangays list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchFromApiOrBundle);
  }
}
