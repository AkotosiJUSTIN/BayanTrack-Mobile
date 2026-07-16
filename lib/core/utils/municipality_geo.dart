import '../../features/auth/data/auth_models.dart';
import '../constants/urdaneta_geo.dart';

/// Uses the exact bundled Urdaneta polygon and API bounds elsewhere.
bool municipalityContains(
  MunicipalityModel municipality,
  double latitude,
  double longitude,
) {
  if (!municipality.isSupported) return false;
  if (municipality.id == 'urdaneta') {
    return UrdanetaGeo.contains(latitude, longitude);
  }
  return municipality.bounds?.contains(latitude, longitude) == true;
}

String municipalityUnavailableMessage(MunicipalityModel municipality) =>
    municipality.id == 'urdaneta'
    ? 'Report creation is only available within Urdaneta, Pangasinan.'
    : municipality.hasUsableBounds
    ? 'The selected location is outside ${municipality.name}, ${municipality.province}.'
    : 'Location boundaries for ${municipality.name} are unavailable. Refresh municipality data before submitting.';
