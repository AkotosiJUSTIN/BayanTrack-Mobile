import 'dart:math' as math;

import '../../../auth/data/auth_models.dart';
import '../../../../l10n/app_localizations.dart';

const quickReportDescriptionMaxLength = 500;

String? quickReportDescriptionError(
  String value, {
  AppLocalizations? l10n,
}) {
  final description = value.trim();
  if (description.isEmpty) {
    return l10n?.shortDescriptionRequired ?? 'Add a short description to continue.';
  }
  if (description.length > quickReportDescriptionMaxLength) {
    return l10n?.descriptionMaxLength(quickReportDescriptionMaxLength) ??
        'Description must be $quickReportDescriptionMaxLength characters or fewer.';
  }
  return null;
}

double _toRadians(double degrees) => degrees * (math.pi / 180.0);

double _haversineMeters(double lat1, double lon1, double lat2, double lon2) {
  const earthRadiusMeters = 6371000.0;
  final dLat = _toRadians(lat2 - lat1);
  final dLon = _toRadians(lon2 - lon1);
  final a =
      (math.sin(dLat / 2) * math.sin(dLat / 2)) +
      math.cos(_toRadians(lat1)) *
          math.cos(_toRadians(lat2)) *
          (math.sin(dLon / 2) * math.sin(dLon / 2));
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earthRadiusMeters * c;
}

BarangayModel? deriveNearestBarangay(
  List<BarangayModel> barangays, {
  required double latitude,
  required double longitude,
}) {
  if (barangays.isEmpty) return null;
  BarangayModel? nearest;
  double? nearestMeters;
  for (final b in barangays) {
    final meters = _haversineMeters(
      latitude,
      longitude,
      b.centerLat,
      b.centerLng,
    );
    if (nearestMeters == null || meters < nearestMeters) {
      nearestMeters = meters;
      nearest = b;
    }
  }
  return nearest;
}
