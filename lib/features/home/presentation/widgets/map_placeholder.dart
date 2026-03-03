import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/constants/mangaldan_geo.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../reports/domain/entities/report.dart';
import '../../../reports/domain/entities/report_enums.dart';

/// OpenStreetMap widget that renders report pins from fetched coordinates.
class MapPlaceholder extends StatelessWidget {
  const MapPlaceholder({super.key, required this.reports, this.onMarkerTap});

  final List<Report> reports;
  final ValueChanged<Report>? onMarkerTap;

  @override
  Widget build(BuildContext context) {
    final reportsWithCoordinates = _reportsWithCoordinates(reports);
    final initialCenter = _initialCenterFor(reportsWithCoordinates);
    final mangaldanPolygon = MangaldanGeo.boundary
        .map((point) => LatLng(point.$1, point.$2))
        .toList(growable: false);
    final mangaldanBounds = LatLngBounds(
      LatLng(MangaldanGeo.south, MangaldanGeo.west),
      LatLng(MangaldanGeo.north, MangaldanGeo.east),
    );
    final markers = reportsWithCoordinates
        .map(
          (report) => Marker(
            point: LatLng(report.latitude!, report.longitude!),
            width: 40,
            height: 40,
            child: Tooltip(
              message: _buildTooltipMessage(report),
              waitDuration: const Duration(milliseconds: 150),
              showDuration: const Duration(seconds: 3),
              preferBelow: false,
              verticalOffset: 18,
              child: GestureDetector(
                onTap: onMarkerTap == null ? null : () => onMarkerTap!(report),
                child: _buildMarker(_colorForStatus(report.status)),
              ),
            ),
          ),
        )
        .toList();

    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: initialCenter,
            initialZoom: 13,
            minZoom: 12,
            maxZoom: 18,
            cameraConstraint: CameraConstraint.contain(bounds: mangaldanBounds),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.bayantrack_mobile',
            ),
            PolygonLayer(
              polygons: [
                Polygon(
                  points: mangaldanPolygon,
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderColor: AppColors.alertHigh,
                  borderStrokeWidth: 2,
                  pattern: const StrokePattern.dotted(spacingFactor: 1.2),
                ),
              ],
              invertedFill: Colors.black.withValues(alpha: 0.55),
            ),
            MarkerLayer(markers: markers),
            const RichAttributionWidget(
              attributions: [
                TextSourceAttribution('OpenStreetMap contributors'),
              ],
            ),
          ],
        ),
        if (markers.isEmpty)
          Positioned(
            top: 12,
            right: 12,
            left: 12,
            child: _buildNoCoordinatesBanner(context),
          ),
      ],
    );
  }

  List<Report> _reportsWithCoordinates(List<Report> input) {
    return input.where((report) {
      final lat = report.latitude;
      final lng = report.longitude;
      if (lat == null || lng == null) return false;
      if (lat < -90 || lat > 90 || lng < -180 || lng > 180) return false;
      return MangaldanGeo.contains(lat, lng);
    }).toList();
  }

  LatLng _initialCenterFor(List<Report> reportsWithCoordinates) {
    if (reportsWithCoordinates.isEmpty) {
      return const LatLng(MangaldanGeo.defaultLat, MangaldanGeo.defaultLng);
    }

    final latitudeTotal = reportsWithCoordinates.fold<double>(
      0,
      (total, report) => total + report.latitude!,
    );
    final longitudeTotal = reportsWithCoordinates.fold<double>(
      0,
      (total, report) => total + report.longitude!,
    );

    return LatLng(
      latitudeTotal / reportsWithCoordinates.length,
      longitudeTotal / reportsWithCoordinates.length,
    );
  }

  Widget _buildNoCoordinatesBanner(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'No report coordinates available in Mangaldan yet.',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Color _colorForStatus(ReportStatus status) {
    return switch (status) {
      ReportStatus.submitted => AppColors.alertMedium,
      ReportStatus.underReview => AppColors.alertMedium,
      ReportStatus.verified => AppColors.primary,
      ReportStatus.assigned => AppColors.primary,
      ReportStatus.inProgress => const Color(0xFF3B82F6), // Blue
      ReportStatus.escalated => AppColors.alertHigh,
      ReportStatus.endorsed => const Color(0xFF8B5CF6), // Purple
      ReportStatus.resolved => AppColors.success,
      ReportStatus.closed => AppColors.success,
      ReportStatus.rejected => AppColors.alertHigh,
    };
  }

  String _buildTooltipMessage(Report report) {
    final title = (report.title?.trim().isNotEmpty ?? false)
        ? report.title!.trim()
        : 'Untitled report';
    final location = report.displayLocation;

    return '$title\n'
        '${report.status.displayName} - ${report.severity.displayName}\n'
        '$location';
  }

  Widget _buildMarker(Color color) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(Icons.location_on, color: Colors.white, size: 14),
    );
  }
}
