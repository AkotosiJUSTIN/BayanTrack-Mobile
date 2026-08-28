import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../features/auth/data/auth_models.dart';
import 'municipality_boundary.dart';

class MunicipalityMapCamera {
  const MunicipalityMapCamera._();

  static LatLngBounds? boundsFor(MunicipalityModel municipality) {
    final source = municipality.boundary;
    final fallback = municipality.bounds;
    if (source != null) return _pad(_boundsFromBoundary(source));
    if (fallback == null || !fallback.isValid) return null;
    return _pad(
      LatLngBounds(
        LatLng(fallback.south, fallback.west),
        LatLng(fallback.north, fallback.east),
      ),
    );
  }

  static CameraFit? initialFit(MunicipalityModel municipality) {
    final bounds = boundsFor(municipality);
    return bounds == null
        ? null
        : CameraFit.bounds(
            bounds: bounds,
            padding: const EdgeInsets.all(28),
            maxZoom: 15,
          );
  }

  static CameraConstraint? constraintFor(MunicipalityModel municipality) {
    final bounds = boundsFor(municipality);
    // `contain` stops constraining when a viewport is wider than the city.
    // Keeping the camera center inside the padded city bounds works at every
    // zoom without fighting the initial fit or creating a correction loop.
    return bounds == null
        ? null
        : CameraConstraint.containCenter(bounds: bounds);
  }

  static void recenter(
    MapController controller,
    MunicipalityModel municipality,
  ) {
    final fit = initialFit(municipality);
    if (fit != null) controller.fitCamera(fit);
  }

  static LatLngBounds _pad(LatLngBounds bounds) {
    final latitudePadding = (bounds.north - bounds.south).abs() * 0.06;
    final longitudePadding = (bounds.east - bounds.west).abs() * 0.06;
    return LatLngBounds(
      LatLng(bounds.south - latitudePadding, bounds.west - longitudePadding),
      LatLng(bounds.north + latitudePadding, bounds.east + longitudePadding),
    );
  }

  static LatLngBounds _boundsFromBoundary(MunicipalityBoundary boundary) =>
      LatLngBounds.fromPoints(
        boundary.polygons
            .expand((polygon) => polygon.expand((ring) => ring))
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList(growable: false),
      );
}

/// Boundary layer is deliberately placed before report markers and pins.
class MunicipalityBoundaryLayer extends StatelessWidget {
  const MunicipalityBoundaryLayer({super.key, required this.boundary});

  final MunicipalityBoundary? boundary;

  @override
  Widget build(BuildContext context) {
    if (boundary == null) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return PolygonLayer(
      polygons: boundary!.polygons
          .map(
            (polygon) => Polygon(
              points: polygon.first
                  .map((point) => LatLng(point.latitude, point.longitude))
                  .toList(growable: false),
              holePointsList: polygon
                  .skip(1)
                  .map(
                    (ring) => ring
                        .map((point) => LatLng(point.latitude, point.longitude))
                        .toList(growable: false),
                  )
                  .toList(growable: false),
              color: scheme.primary.withValues(alpha: 0.10),
              borderColor: scheme.primary.withValues(alpha: 0.85),
              borderStrokeWidth: 2,
            ),
          )
          .toList(growable: false),
    );
  }
}
