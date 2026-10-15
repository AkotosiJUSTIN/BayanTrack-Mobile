import 'dart:math' as math;

import '../../../auth/data/auth_models.dart';
import '../../../../l10n/app_localizations.dart';

const quickReportDescriptionMaxLength = 500;
const barangayResolutionMaxDistanceMeters = 20000.0;
const nearbyLandmarkRadiusMeters = 250.0;
const strongNearbyLandmarkRadiusMeters = 150.0;
const nearbyLandmarkDebounceDuration = Duration(milliseconds: 250);
const noNearbyLandmarkFound = 'No nearby landmark found';
const chooseNearbyLandmark = 'Choose a nearby landmark';
const landmarkLookupUnavailable =
    'Nearby landmarks are temporarily unavailable';

String? quickReportDescriptionError(String value, {AppLocalizations? l10n}) {
  final description = value.trim();
  if (description.isEmpty) {
    return l10n?.shortDescriptionRequired ??
        'Add a short description to continue.';
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
  double maxDistanceMeters = barangayResolutionMaxDistanceMeters,
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
  if (nearestMeters == null || nearestMeters > maxDistanceMeters) return null;
  return nearest;
}

class NearbyLandmarkSuggestion {
  final String? prefill;
  final List<String> choices;

  const NearbyLandmarkSuggestion({this.prefill, this.choices = const []});

  bool get hasSuggestion => prefill != null || choices.isNotEmpty;
}

NearbyLandmarkSuggestion suggestNearbyLandmark(
  List<NearbyLandmarkModel> landmarks,
) {
  final candidates =
      landmarks
          .where(
            (landmark) =>
                landmark.name.trim().isNotEmpty &&
                landmark.distanceMeters.isFinite &&
                landmark.distanceMeters >= 0 &&
                landmark.distanceMeters <= nearbyLandmarkRadiusMeters,
          )
          .toList()
        ..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));

  final names = <String>{};
  final unique = candidates
      .where((landmark) => names.add(landmark.name.trim().toLowerCase()))
      .toList(growable: false);
  if (unique.isEmpty) return const NearbyLandmarkSuggestion();
  if (unique.length == 1 &&
      unique.first.distanceMeters <= strongNearbyLandmarkRadiusMeters) {
    return NearbyLandmarkSuggestion(prefill: unique.first.name.trim());
  }
  final choices = unique.take(5).toList();
  final streets = unique.where((landmark) => landmark.isStreet);
  if (streets.isNotEmpty && !choices.contains(streets.first)) {
    choices[choices.length - 1] = streets.first;
    choices.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
  }
  return NearbyLandmarkSuggestion(
    choices: choices.map((landmark) => landmark.name.trim()).toList(),
  );
}
