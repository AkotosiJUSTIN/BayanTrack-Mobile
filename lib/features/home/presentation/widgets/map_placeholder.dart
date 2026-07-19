import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/maps/municipality_map.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/data/auth_models.dart';
import '../../../reports/domain/entities/report.dart';
import '../../../reports/domain/entities/report_enums.dart';

/// OpenStreetMap widget that renders report pins from fetched coordinates.
class MapPlaceholder extends StatefulWidget {
  const MapPlaceholder({
    super.key,
    required this.reports,
    required this.municipality,
    this.onMarkerTap,
  });

  final List<Report> reports;
  final MunicipalityModel municipality;
  final ValueChanged<Report>? onMarkerTap;

  @override
  State<MapPlaceholder> createState() => _MapPlaceholderState();
}

class _MapPlaceholderState extends State<MapPlaceholder> {
  final MapController _mapController = MapController();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reportsWithCoordinates = _reportsWithCoordinates(widget.reports);
    final initialCenter = _initialCenterFor(reportsWithCoordinates);
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
                onTap: widget.onMarkerTap == null
                    ? null
                    : () => widget.onMarkerTap!(report),
                child: _buildMarker(_colorForStatus(report.status)),
              ),
            ),
          ),
        )
        .toList();

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: initialCenter,
            initialZoom: 13,
            initialCameraFit: MunicipalityMapCamera.initialFit(
              widget.municipality,
            ),
            cameraConstraint:
                MunicipalityMapCamera.constraintFor(widget.municipality) ??
                const CameraConstraint.unconstrained(),
            minZoom: 4,
            maxZoom: 18,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.bayantrack_mobile',
            ),
            MunicipalityBoundaryLayer(boundary: widget.municipality.boundary),
            MarkerLayer(markers: markers),
            const RichAttributionWidget(
              attributions: [
                TextSourceAttribution('OpenStreetMap contributors'),
              ],
            ),
          ],
        ),
        Positioned(
          right: 12,
          top: markers.isEmpty ? 76 : 12,
          child: IconButton.filledTonal(
            constraints: const BoxConstraints.tightFor(width: 48, height: 48),
            tooltip: 'Recenter to ${widget.municipality.name}',
            onPressed: () => MunicipalityMapCamera.recenter(
              _mapController,
              widget.municipality,
            ),
            icon: const Icon(Icons.center_focus_strong_outlined),
          ),
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
      return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
    }).toList();
  }

  LatLng _initialCenterFor(List<Report> reportsWithCoordinates) {
    if (reportsWithCoordinates.isEmpty) {
      final bounds = widget.municipality.bounds;
      return LatLng(
        widget.municipality.centerLat ??
            (bounds == null ? 15.9530 : (bounds.south + bounds.north) / 2),
        widget.municipality.centerLng ??
            (bounds == null ? 120.5772 : (bounds.west + bounds.east) / 2),
      );
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
              'No report coordinates available yet.',
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
      ReportStatus.verified => AppColors.alertMedium,
      ReportStatus.assigned => AppColors.alertMedium,
      ReportStatus.inProgress => const Color(0xFF3B82F6), // Blue
      ReportStatus.escalated => AppColors.alertMedium,
      ReportStatus.endorsed => AppColors.alertMedium,
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
