import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/constants/urdaneta_geo.dart';
import '../../../../core/maps/municipality_map.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/municipality_geo.dart';
import '../../../auth/data/auth_models.dart';
import '../../../auth/presentation/barangays_provider.dart';
import '../../../../l10n/app_localizations.dart';
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
  MunicipalityModel _selectedMunicipality = bundledUrdanetaMunicipality;

  bool _isLoading = false;
  bool _isGettingPreciseLocation = false;
  bool _isOutsideServiceArea = false;
  String? _error;
  Position? _currentPosition;
  LatLng? _selectedPoint;
  String? _pendingMetadataId;
  _LocationInputMode _locationInputMode = _LocationInputMode.phone;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _applyDefaultLocationIfMissing();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncInitialSelectionToProvider();
      _getCurrentLocation();
    });
  }

  void _applyDefaultLocationIfMissing() {
    final state = ref.read(newReportControllerProvider);

    if (state.latitude != null && state.longitude != null) {
      _selectedPoint = LatLng(state.latitude!, state.longitude!);
      _isOutsideServiceArea = !municipalityContains(
        _selectedMunicipality,
        state.latitude!,
        state.longitude!,
      );
      return;
    }

    _selectedPoint = const LatLng(
      UrdanetaGeo.defaultLat,
      UrdanetaGeo.defaultLng,
    );
    _isOutsideServiceArea = false;
  }

  void _selectMunicipality(MunicipalityModel municipality) {
    if (municipality.id == _selectedMunicipality.id) return;
    final bounds = municipality.bounds;
    if (bounds == null || !municipality.hasUsableBoundary) {
      setState(() => _error = municipalityUnavailableMessage(municipality));
      return;
    }
    ref
        .read(newReportControllerProvider.notifier)
        .setMunicipality(
          id: municipality.id,
          name: municipality.name,
          province: municipality.province,
        );
    final center = LatLng(
      municipality.centerLat ?? (bounds.south + bounds.north) / 2,
      municipality.centerLng ?? (bounds.west + bounds.east) / 2,
    );
    setState(() {
      _selectedMunicipality = municipality;
      _selectedPoint = center;
      _currentPosition = null;
      _error = null;
      _isOutsideServiceArea = false;
    });
    _setSelectedPoint(
      center,
      locationLabel: '${municipality.name}, ${municipality.province}',
    );
    if (_locationInputMode == _LocationInputMode.phone) {
      _getCurrentLocation();
    }
  }

  void _restoreMunicipalityMetadata(MunicipalityModel municipality) {
    if (!mounted || municipality.id == _selectedMunicipality.id) return;
    final state = ref.read(newReportControllerProvider);
    final bounds = municipality.bounds;
    if (bounds == null || !municipality.hasUsableBoundary) return;
    final point = state.latitude != null && state.longitude != null
        ? LatLng(state.latitude!, state.longitude!)
        : LatLng(
            municipality.centerLat ?? (bounds.south + bounds.north) / 2,
            municipality.centerLng ?? (bounds.west + bounds.east) / 2,
          );
    setState(() {
      _selectedMunicipality = municipality;
      _selectedPoint = point;
      _isOutsideServiceArea = !municipalityContains(
        municipality,
        point.latitude,
        point.longitude,
      );
      _pendingMetadataId = null;
    });
    _moveCameraToSelection();
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
      locationLabel:
          '${_selectedMunicipality.name}, ${_selectedMunicipality.province}',
      moveCamera: false,
    );
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          _error = l10n.locationServicesDisabled;
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
            _error = l10n.locationPermissionDenied;
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _error = l10n.locationPermissionSettings;
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
        _error = '${l10n.error}: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _getPreciseLocationInBackground(
    Position? fallbackPosition,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      final position =
          await Geolocator.getCurrentPosition(
            locationSettings: AndroidSettings(
              accuracy: LocationAccuracy.medium,
              distanceFilter: 10,
              forceLocationManager: false,
              intervalDuration: const Duration(seconds: 5),
              foregroundNotificationConfig: ForegroundNotificationConfig(
                notificationTitle: l10n.gettingLocation,
                notificationText: l10n.gettingLocationNotification,
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
          _error = l10n.locationRequestTimedOut;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isGettingPreciseLocation = false;
        _isLoading = false;
        if (_currentPosition == null) {
          _error = '${l10n.error}: ${e.toString()}';
        }
      });
    }
  }

  void _updateLocationFromPosition(Position position) {
    if (_locationInputMode != _LocationInputMode.phone) {
      return;
    }

    final point = LatLng(position.latitude, position.longitude);
    if (!municipalityContains(
      _selectedMunicipality,
      point.latitude,
      point.longitude,
    )) {
      ref.read(newReportControllerProvider.notifier).clearLocation();
      setState(() {
        _isOutsideServiceArea = true;
        _selectedPoint = null;
        _error = municipalityUnavailableMessage(_selectedMunicipality);
      });
      return;
    }

    _setSelectedPoint(
      point,
      locationLabel:
          '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
    );
  }

  void _setSelectedPoint(
    LatLng point, {
    required String locationLabel,
    bool moveCamera = true,
  }) {
    final inMunicipality = municipalityContains(
      _selectedMunicipality,
      point.latitude,
      point.longitude,
    );

    if (!inMunicipality) {
      ref.read(newReportControllerProvider.notifier).clearLocation();
      setState(() {
        _isOutsideServiceArea = true;
        _error = municipalityUnavailableMessage(_selectedMunicipality);
      });
      return;
    }

    final controller = ref.read(newReportControllerProvider.notifier);
    controller.setLocation(
      latitude: point.latitude,
      longitude: point.longitude,
      location: locationLabel,
    );
    controller.setCityMunicipality(_selectedMunicipality.name);
    controller.setProvince(_selectedMunicipality.province);

    setState(() {
      _selectedPoint = point;
      _isOutsideServiceArea = false;
      _error = null;
    });

    if (moveCamera) _moveCameraToSelection();
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
    if (!municipalityContains(
      _selectedMunicipality,
      point.latitude,
      point.longitude,
    )) {
      setState(() {
        _isOutsideServiceArea = true;
        _error = municipalityUnavailableMessage(_selectedMunicipality);
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
    final bounds = _selectedMunicipality.bounds!;
    _setSelectedPoint(
      LatLng(
        _selectedMunicipality.centerLat ?? (bounds.south + bounds.north) / 2,
        _selectedMunicipality.centerLng ?? (bounds.west + bounds.east) / 2,
      ),
      locationLabel:
          '${_selectedMunicipality.name}, ${_selectedMunicipality.province}',
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
    final municipalitiesAsync = ref.watch(municipalitiesProvider);
    final municipality = municipalitiesAsync.asData == null
        ? null
        : findMunicipalityMetadata(
            municipalitiesAsync.asData!.value,
            state.municipalityId,
          );
    if (municipality != null &&
        municipality.id != _selectedMunicipality.id &&
        _pendingMetadataId != municipality.id) {
      _pendingMetadataId = municipality.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _restoreMunicipalityMetadata(municipality);
      });
    }
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bounds = _selectedMunicipality.bounds!;
    final selectedPoint =
        _selectedPoint ??
        LatLng(
          _selectedMunicipality.centerLat ?? (bounds.south + bounds.north) / 2,
          _selectedMunicipality.centerLng ?? (bounds.west + bounds.east) / 2,
        );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.newReport)),
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
                  l10n.stepOf(2, 4),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.reportLocation,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.selectLocationDescription,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                municipalitiesAsync.when(
                  data: (municipalities) => DropdownButtonFormField<String>(
                    initialValue:
                        municipalities.any(
                          (item) => item.id == state.municipalityId,
                        )
                        ? state.municipalityId
                        : _selectedMunicipality.id,
                    decoration: InputDecoration(
                      labelText: l10n.selectCity,
                      prefixIcon: Icon(Icons.location_city),
                      border: OutlineInputBorder(),
                    ),
                    items: municipalities
                        .map(
                          (item) => DropdownMenuItem(
                            value: item.id,
                            child: Text('${item.name}, ${item.province}'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      _selectMunicipality(
                        municipalities.firstWhere((item) => item.id == value),
                      );
                    },
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (error, stack) => Text(
                    l10n.cityMetadataUnavailable,
                    style: TextStyle(color: theme.colorScheme.error),
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
              child: Text(l10n.continueLabel),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: ChoiceChip(
            label: Text(l10n.usePhoneLocation),
            selected: _locationInputMode == _LocationInputMode.phone,
            onSelected: (_) => _switchMode(_LocationInputMode.phone),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ChoiceChip(
            label: Text(l10n.manualPin),
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
    final l10n = AppLocalizations.of(context);
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
              initialCameraFit: MunicipalityMapCamera.initialFit(
                _selectedMunicipality,
              ),
              cameraConstraint:
                  MunicipalityMapCamera.constraintFor(_selectedMunicipality) ??
                  const CameraConstraint.unconstrained(),
              onTap: (_, point) => _onMapTap(point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.bayantrack_mobile',
              ),
              MunicipalityBoundaryLayer(
                boundary: _selectedMunicipality.boundary,
              ),
              MarkerLayer(
                markers: _selectedPoint == null
                    ? const []
                    : [
                        Marker(
                          point: selectedPoint,
                          width: 40,
                          height: 40,
                          child: Icon(
                            Icons.location_on,
                            size: 36,
                            color:
                                _locationInputMode == _LocationInputMode.manual
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
          Positioned(
            right: 12,
            bottom: 12,
            child: IconButton.filledTonal(
              tooltip: l10n.recenterToCity,
              onPressed: () => MunicipalityMapCamera.recenter(
                _mapController,
                _selectedMunicipality,
              ),
              icon: const Icon(Icons.center_focus_strong_outlined),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationStatusCard(BuildContext context, NewReportState state) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

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
                          ? l10n.manualPin
                          : l10n.phoneLocation,
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
              tooltip: l10n.refreshLocation,
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.refresh),
            )
          else
            IconButton(
              tooltip: l10n.useCityCenter(_selectedMunicipality.name),
              onPressed: _useDefaultLocation,
              icon: const Icon(Icons.pin_drop_outlined),
            ),
        ],
      ),
    );
  }

  Widget _buildManualHint(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        l10n.tapMapWithin(_selectedMunicipality.name),
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
