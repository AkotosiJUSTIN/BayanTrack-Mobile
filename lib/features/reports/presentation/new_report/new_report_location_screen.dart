import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/constants/urdaneta_geo.dart';
import '../../../../core/theme/app_colors.dart';
import 'new_report_controller.dart';
import 'new_report_details_screen.dart';

enum _LocationInputMode { phone, manual }

/// Second step: choose location using phone GPS or manual map selection.
class NewReportLocationScreen extends ConsumerStatefulWidget {
  const NewReportLocationScreen({super.key});

  @override
  ConsumerState<NewReportLocationScreen> createState() =>
      _NewReportLocationScreenState();
}

class _NewReportLocationScreenState
    extends ConsumerState<NewReportLocationScreen> {
  final MapController _mapController = MapController();
  final LatLngBounds _mangaldanBounds = LatLngBounds(
    const LatLng(UrdanetaGeo.south, UrdanetaGeo.west),
    const LatLng(UrdanetaGeo.north, UrdanetaGeo.east),
  );
  final List<LatLng> _mangaldanPolygon = UrdanetaGeo.boundary
      .map((point) => LatLng(point.$1, point.$2))
      .toList(growable: false);

  bool _isLoading = false;
  bool _isGettingPreciseLocation = false;
  bool _isOutsideServiceArea = false;
  String? _error;
  Position? _currentPosition;
  LatLng? _selectedPoint;
  _LocationInputMode _locationInputMode = _LocationInputMode.phone;

  @override
  void initState() {
    super.initState();
    _applyDefaultLocationIfMissing();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncInitialSelectionToProvider();
      _moveCameraToSelection();
      _getCurrentLocation();
    });
  }

  void _applyDefaultLocationIfMissing() {
    final state = ref.read(newReportControllerProvider);

    if (state.latitude != null && state.longitude != null) {
      _selectedPoint = LatLng(state.latitude!, state.longitude!);
      _isOutsideServiceArea = !UrdanetaGeo.contains(
        state.latitude!,
        state.longitude!,
      );
      return;
    }

    _selectedPoint = const LatLng(UrdanetaGeo.defaultLat, UrdanetaGeo.defaultLng);
    _isOutsideServiceArea = false;
  }

  void _syncInitialSelectionToProvider() {
    final state = ref.read(newReportControllerProvider);
    if (state.latitude != null && state.longitude != null) {
      return;
    }

    final point = _selectedPoint;
    if (point == null) return;

    _setSelectedPoint(
      point,
      locationLabel: UrdanetaGeo.defaultLocationLabel,
    );
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          _error = 'Location services are disabled. Please enable GPS.';
          _isLoading = false;
        });
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          setState(() {
            _error = 'Location permission denied';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _error =
              'Location permissions are permanently denied. Enable them in Settings.';
          _isLoading = false;
        });
        return;
      }

      final lastPosition = await Geolocator.getLastKnownPosition();
      if (lastPosition != null && mounted) {
        setState(() {
          _currentPosition = lastPosition;
          _isLoading = false;
          _isGettingPreciseLocation = true;
        });
        _updateLocationFromPosition(lastPosition);
      }

      _getPreciseLocationInBackground(lastPosition);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to get location: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _getPreciseLocationInBackground(Position? fallbackPosition) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: AndroidSettings(
          accuracy: LocationAccuracy.medium,
          distanceFilter: 10,
          forceLocationManager: false,
          intervalDuration: const Duration(seconds: 5),
          foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationTitle: 'Getting location',
            notificationText: 'BayanTrack is getting your location',
            enableWakeLock: false,
          ),
        ),
      ).timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          if (fallbackPosition != null) return fallbackPosition;
          throw TimeoutException('Location request timed out');
        },
      );

      if (!mounted) return;
      setState(() {
        _currentPosition = position;
        _isGettingPreciseLocation = false;
        _isLoading = false;
      });
      _updateLocationFromPosition(position);
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _isGettingPreciseLocation = false;
        _isLoading = false;
        if (_currentPosition == null) {
          _error = 'Location request timed out. Please try again.';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isGettingPreciseLocation = false;
        _isLoading = false;
        if (_currentPosition == null) {
          _error = 'Failed to get precise location: ${e.toString()}';
        }
      });
    }
  }

  void _updateLocationFromPosition(Position position) {
    if (_locationInputMode != _LocationInputMode.phone) {
      return;
    }

    final point = LatLng(position.latitude, position.longitude);
    if (!UrdanetaGeo.contains(point.latitude, point.longitude)) {
      ref.read(newReportControllerProvider.notifier).clearLocation();
      setState(() {
        _isOutsideServiceArea = true;
        _error =
          'Report creation is only available within Urdaneta, Pangasinan.';
      });
      return;
    }

    _setSelectedPoint(
      point,
      locationLabel:
          '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
    );
  }

  void _setSelectedPoint(LatLng point, {required String locationLabel}) {
    final inMangaldan = UrdanetaGeo.contains(point.latitude, point.longitude);

    if (!inMangaldan) {
      ref.read(newReportControllerProvider.notifier).clearLocation();
      setState(() {
        _isOutsideServiceArea = true;
        _error =
          'Report creation is only available within Urdaneta, Pangasinan.';
      });
      return;
    }

    final controller = ref.read(newReportControllerProvider.notifier);
    controller.setLocation(
      latitude: point.latitude,
      longitude: point.longitude,
      location: locationLabel,
    );
    controller.setCityMunicipality(UrdanetaGeo.defaultCityMunicipality);
    controller.setProvince(UrdanetaGeo.defaultProvince);

    setState(() {
      _selectedPoint = point;
      _isOutsideServiceArea = false;
      _error = null;
    });

    _moveCameraToSelection();
  }

  void _moveCameraToSelection() {
    final point = _selectedPoint;
    if (point == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _mapController.move(point, 15);
    });
  }

  void _onMapTap(LatLng point) {
    if (_locationInputMode != _LocationInputMode.manual) return;
    if (!UrdanetaGeo.contains(point.latitude, point.longitude)) {
      setState(() {
        _isOutsideServiceArea = true;
        _error =
          'You can only place a manual pin within Urdaneta, Pangasinan.';
      });
      return;
    }

    _setSelectedPoint(
      point,
      locationLabel:
          'Manual selection: ${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}',
    );
  }

  void _switchMode(_LocationInputMode mode) {
    if (_locationInputMode == mode) return;

    setState(() {
      _locationInputMode = mode;
      _error = null;
      _isOutsideServiceArea = false;
    });

    if (mode == _LocationInputMode.phone) {
      _getCurrentLocation();
    }
  }

  void _useDefaultLocation() {
    _setSelectedPoint(
      const LatLng(UrdanetaGeo.defaultLat, UrdanetaGeo.defaultLng),
      locationLabel: UrdanetaGeo.defaultLocationLabel,
    );
  }

  void _navigateToDetails() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const NewReportDetailsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newReportControllerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedPoint = _selectedPoint ??
        const LatLng(UrdanetaGeo.defaultLat, UrdanetaGeo.defaultLng);

    return Scaffold(
      appBar: AppBar(title: const Text('New Report')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LinearProgressIndicator(
            value: 0.5,
            backgroundColor: isDark
                ? AppColors.darkBorder
                : AppColors.lightBorder,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step 2 of 4',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Location',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose location source: phone GPS or manual pin in Urdaneta only.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildModeSelector(theme),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildMapCard(
                context: context,
                selectedPoint: selectedPoint,
                isDark: isDark,
                state: state,
              ),
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _buildErrorBanner(theme),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: state.hasLocation && !_isOutsideServiceArea
                  ? _navigateToDetails
                  : null,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: ChoiceChip(
            label: const Text('Use Phone Location'),
            selected: _locationInputMode == _LocationInputMode.phone,
            onSelected: (_) => _switchMode(_LocationInputMode.phone),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ChoiceChip(
            label: const Text('Manual Pin'),
            selected: _locationInputMode == _LocationInputMode.manual,
            onSelected: (_) => _switchMode(_LocationInputMode.manual),
          ),
        ),
      ],
    );
  }

  Widget _buildMapCard({
    required BuildContext context,
    required LatLng selectedPoint,
    required bool isDark,
    required NewReportState state,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: selectedPoint,
              initialZoom: 15,
              minZoom: 12,
              maxZoom: 18,
              cameraConstraint: CameraConstraint.contain(bounds: _mangaldanBounds),
              onTap: (_, point) => _onMapTap(point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.bayantrack_mobile',
              ),
              PolygonLayer(
                polygons: [
                  Polygon(
                    points: _mangaldanPolygon,
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderColor: AppColors.alertHigh,
                    borderStrokeWidth: 2,
                    pattern: const StrokePattern.dotted(spacingFactor: 1.2),
                  ),
                ],
                invertedFill: Colors.black.withValues(alpha: 0.55),
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: selectedPoint,
                    width: 40,
                    height: 40,
                    child: Icon(
                      Icons.location_on,
                      size: 36,
                      color: _locationInputMode == _LocationInputMode.manual
                          ? AppColors.primary
                          : AppColors.alertHigh,
                    ),
                  ),
                ],
              ),
              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('OpenStreetMap contributors'),
                ],
              ),
            ],
          ),
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: _buildLocationStatusCard(context, state),
          ),
          if (_locationInputMode == _LocationInputMode.manual)
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: _buildManualHint(context),
            ),
          if (_locationInputMode == _LocationInputMode.phone && _isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildLocationStatusCard(BuildContext context, NewReportState state) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            _locationInputMode == _LocationInputMode.manual
                ? Icons.touch_app
                : Icons.my_location,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      _locationInputMode == _LocationInputMode.manual
                          ? 'Manual Pin'
                          : 'Phone Location',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_locationInputMode == _LocationInputMode.phone &&
                        _isGettingPreciseLocation) ...[
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ],
                ),
                if (state.latitude != null && state.longitude != null)
                  Text(
                    '${state.latitude!.toStringAsFixed(6)}, ${state.longitude!.toStringAsFixed(6)}',
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          if (_locationInputMode == _LocationInputMode.phone)
            IconButton(
              tooltip: 'Refresh location',
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.refresh),
            )
          else
            IconButton(
              tooltip: 'Use default Urdaneta location',
              onPressed: _useDefaultLocation,
              icon: const Icon(Icons.pin_drop_outlined),
            ),
        ],
      ),
    );
  }

  Widget _buildManualHint(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Tap the map to place your pin. Selection is limited to Urdaneta.',
        style: theme.textTheme.bodySmall,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildErrorBanner(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.alertHigh.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.alertHigh.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.alertHigh),
          const SizedBox(width: 8),
          Expanded(child: Text(_error!, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }
}
