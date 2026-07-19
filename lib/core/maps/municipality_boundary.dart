import 'package:latlong2/latlong.dart';

class GeoCoordinate {
  final double latitude;
  final double longitude;

  const GeoCoordinate(this.latitude, this.longitude);

  LatLng toLatLng() => LatLng(latitude, longitude);
}

/// Validated Polygon or MultiPolygon geometry. Points on a boundary are in.
class MunicipalityBoundary {
  final String type;
  final List<List<List<GeoCoordinate>>> polygons;

  const MunicipalityBoundary({required this.type, required this.polygons});

  static MunicipalityBoundary? tryParse(Object? raw) {
    if (raw is! Map || (raw['type'] != 'Polygon' && raw['type'] != 'MultiPolygon')) {
      return null;
    }
    final rawCoordinates = raw['coordinates'];
    if (rawCoordinates is! List) return null;
    final polygons = raw['type'] == 'Polygon'
        ? _parsePolygons([rawCoordinates])
        : _parsePolygons(rawCoordinates);
    if (polygons == null || polygons.isEmpty) return null;
    return MunicipalityBoundary(type: raw['type'] as String, polygons: polygons);
  }

  static List<List<List<GeoCoordinate>>>? _parsePolygons(List<dynamic> values) {
    final polygons = <List<List<GeoCoordinate>>>[];
    for (final rawPolygon in values) {
      if (rawPolygon is! List || rawPolygon.isEmpty) return null;
      final polygon = <List<GeoCoordinate>>[];
      for (final rawRing in rawPolygon) {
        if (rawRing is! List || rawRing.length < 4) return null;
        final ring = <GeoCoordinate>[];
        for (final rawPoint in rawRing) {
          if (rawPoint is! List || rawPoint.length < 2) return null;
          final longitude = rawPoint[0];
          final latitude = rawPoint[1];
          if (longitude is! num || latitude is! num ||
              !longitude.isFinite || !latitude.isFinite ||
              longitude < -180 || longitude > 180 ||
              latitude < -90 || latitude > 90) {
            return null;
          }
          ring.add(GeoCoordinate(latitude.toDouble(), longitude.toDouble()));
        }
        if (!_samePoint(ring.first, ring.last)) return null;
        polygon.add(List.unmodifiable(ring));
      }
      polygons.add(List.unmodifiable(polygon));
    }
    return List.unmodifiable(polygons);
  }

  static bool _samePoint(GeoCoordinate first, GeoCoordinate second) =>
      first.latitude == second.latitude && first.longitude == second.longitude;

  LatLngBounds get bounds => LatLngBounds.fromPoints(
    polygons.expand((polygon) => polygon.expand((ring) => ring.map((point) => point.toLatLng()))).toList(growable: false),
  );

  Map<String, dynamic> toGeoJson() => {
    'type': type,
    'coordinates': type == 'Polygon'
        ? _polygonToJson(polygons.single)
        : polygons.map(_polygonToJson).toList(growable: false),
  };

  List<List<List<double>>> _polygonToJson(List<List<GeoCoordinate>> polygon) =>
      polygon
          .map(
            (ring) => ring
                .map((point) => [point.longitude, point.latitude])
                .toList(growable: false),
          )
          .toList(growable: false);

  bool contains(double latitude, double longitude) {
    for (final polygon in polygons) {
      final exterior = _ringLocation(latitude, longitude, polygon.first);
      if (exterior == _PointLocation.outside) continue;
      if (exterior == _PointLocation.boundary) return true;
      var isInHole = false;
      for (final hole in polygon.skip(1)) {
        final holeLocation = _ringLocation(latitude, longitude, hole);
        if (holeLocation == _PointLocation.boundary) return true;
        if (holeLocation == _PointLocation.inside) {
          isInHole = true;
          break;
        }
      }
      if (!isInHole) return true;
    }
    return false;
  }

  _PointLocation _ringLocation(
    double latitude,
    double longitude,
    List<GeoCoordinate> ring,
  ) {
    var inside = false;
    for (var index = 1; index < ring.length; index++) {
      final start = ring[index - 1];
      final end = ring[index];
      if (_isOnSegment(latitude, longitude, start, end)) {
        return _PointLocation.boundary;
      }
      if ((start.latitude > latitude) != (end.latitude > latitude)) {
        final crossingLongitude =
            (end.longitude - start.longitude) *
                (latitude - start.latitude) /
                (end.latitude - start.latitude) +
            start.longitude;
        if (longitude < crossingLongitude) inside = !inside;
      }
    }
    return inside ? _PointLocation.inside : _PointLocation.outside;
  }

  bool _isOnSegment(
    double latitude,
    double longitude,
    GeoCoordinate start,
    GeoCoordinate end,
  ) {
    const epsilon = 1e-9;
    final cross = (longitude - start.longitude) * (end.latitude - start.latitude) -
        (latitude - start.latitude) * (end.longitude - start.longitude);
    if (cross.abs() > epsilon) return false;
    return longitude >= _min(start.longitude, end.longitude) - epsilon &&
        longitude <= _max(start.longitude, end.longitude) + epsilon &&
        latitude >= _min(start.latitude, end.latitude) - epsilon &&
        latitude <= _max(start.latitude, end.latitude) + epsilon;
  }

  double _min(double first, double second) => first < second ? first : second;
  double _max(double first, double second) => first > second ? first : second;
}

enum _PointLocation { inside, outside, boundary }
