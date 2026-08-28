import '../../features/auth/data/auth_models.dart';

/// Bounds constrain the camera; only a verified polygon validates a pin.
bool municipalityContains(
  MunicipalityModel municipality,
  double latitude,
  double longitude,
) {
  return municipality.isSupported &&
      municipality.boundary?.contains(latitude, longitude) == true;
}

String municipalityUnavailableMessage(MunicipalityModel municipality) =>
    municipality.hasUsableBoundary
    ? 'The selected location is outside ${municipality.name}, ${municipality.province}.'
    : 'Verified boundaries for ${municipality.name} are unavailable. Refresh city data before submitting.';
