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
import '../../../auth/auth_di.dart';
import '../../../auth/data/auth_models.dart';
import '../../../auth/presentation/barangays_provider.dart';
import '../../../../l10n/app_localizations.dart';
import 'new_report_controller.dart';
import 'new_report_details_screen.dart';
import 'quick_report_geo.dart';
import 'report_flow_widgets.dart';

enum _LocationInputMode { phone, manual }

/// Second step: choose location using phone GPS or manual map selection.
class NewReportLocationScreen extends ConsumerStatefulWidget {
  const NewReportLocationScreen({super.key, this.locationOverride});

  @visibleForTesting
  final Future<Position> Function()? locationOverride;

  @override
  ConsumerState<NewReportLocationScreen> createState() =>
      _NewReportLocationScreenState();
}

class _NewReportLocationScreenState
    extends ConsumerState<NewReportLocationScreen> {
  final MapController _mapController = MapController();
  final MunicipalityModel _selectedMunicipality = bundledUrdanetaMunicipality;

  bool _isLoading = false;
  bool _isGettingPreciseLocation = false;
  bool _isOutsideServiceArea = false;
  String? _error;
  Position? _currentPosition;
  LatLng? _selectedPoint;
  String? _lastBarangayResolutionKey;
  int _landmarkLookupVersion = 0;
  _LocationInputMode _locationInputMode = _LocationInputMode.phone;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    ref
        .read(newReportControllerProvider.notifier)
        .setMunicipality(
          id: defaultMunicipalityId,
          name: UrdanetaGeo.defaultCityMunicipality,
          province: UrdanetaGeo.defaultProvince,
        );
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

    final locationOverride = widget.locationOverride;
    if (locationOverride != null) {
      try {
        final position = await locationOverride();
        if (!mounted) return;
        setState(() => _isLoading = false);
        _updateLocationFromPosition(position);
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _error = '${l10n.error}: ${l10n.refreshLocation} / ${l10n.manualPin}';
        });
      }
      return;
    }

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
      _landmarkLookupVersion++;
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
      _landmarkLookupVersion++;
      setState(() {
        _isOutsideServiceArea = true;
        _selectedPoint = null;
        _error = municipalityUnavailableMessage(_selectedMunicipality);
      });
      return;
    }

    final controller = ref.read(newReportControllerProvider.notifier);
    _lastBarangayResolutionKey = null;
    controller.beginBarangayResolution();
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

    _lookupNearbyLandmarks(point);

    if (moveCamera) _moveCameraToSelection();
  }

  void _scheduleBarangayResolution(
    NewReportState state,
    AsyncValue<List<BarangayModel>> barangaysAsync,
  ) {
    final point = _selectedPoint;
    if (point == null || state.latitude == null || state.longitude == null) {
      return;
    }
    final barangays = barangaysAsync.asData?.value;
    if (barangays == null && !barangaysAsync.hasError) return;
    final sourceKey = barangaysAsync.hasError
        ? 'error'
        : barangays!
              .map((item) => '${item.id}:${item.centerLat}:${item.centerLng}')
              .join('|');
    final key =
        '${state.municipalityId}:${point.latitude}:${point.longitude}:$sourceKey';
    if (_lastBarangayResolutionKey == key) return;
    _lastBarangayResolutionKey = key;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final current = ref.read(newReportControllerProvider);
      if (current.latitude != point.latitude ||
          current.longitude != point.longitude ||
          current.municipalityId != state.municipalityId) {
        return;
      }
      final resolved = barangays == null
          ? null
          : deriveNearestBarangay(
              barangays,
              latitude: point.latitude,
              longitude: point.longitude,
            );
      ref
          .read(newReportControllerProvider.notifier)
          .completeBarangayResolution(resolved);
    });
  }

  Future<void> _lookupNearbyLandmarks(LatLng point) async {
    final requestVersion = ++_landmarkLookupVersion;
    final controller = ref.read(newReportControllerProvider.notifier);
    controller.beginLandmarkLookup(clearManual: true);
    final result = await (() async {
      try {
        return await ref
            .read(authRepositoryProvider)
            .getNearbyLandmarks(
              latitude: point.latitude,
              longitude: point.longitude,
            );
      } catch (_) {
        return null;
      }
    })();
    if (!mounted || requestVersion != _landmarkLookupVersion) return;
    if (result == null) {
      controller.failLandmarkLookup();
      return;
    }
    result.when(
      success: (landmarks) =>
          controller.completeLandmarkLookup(suggestNearbyLandmark(landmarks)),
      failure: (_) => controller.failLandmarkLookup(),
    );
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
    final barangaysAsync = ref.watch(
      municipalityBarangaysProvider(defaultMunicipalityId),
    );
    _scheduleBarangayResolution(state, barangaysAsync);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final bounds = _selectedMunicipality.bounds!;
    final selectedPoint =
        _selectedPoint ??
        LatLng(
          _selectedMunicipality.centerLat ?? (bounds.south + bounds.north) / 2,
          _selectedMunicipality.centerLng ?? (bounds.west + bounds.east) / 2,
        );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.newReport)),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ReportFlowProgress(step: 2, total: 4),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ReportFlowHeader(
                      title: l10n.reportLocation,
                      guidance: l10n.selectLocationDescription,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ReportReadOnlyLocationField(
                            key: const Key('full-report-city'),
                            label: l10n.city,
                            value: UrdanetaGeo.displayCityName,
                            icon: Icons.location_city_outlined,
                          ),
                          const SizedBox(height: 16),
                          _buildModeSelector(),
                          const SizedBox(height: 16),
                          _buildMapCard(
                            context: context,
                            selectedPoint: selectedPoint,
                            isDark: theme.brightness == Brightness.dark,
                            state: state,
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 12),
                            _buildErrorBanner(theme),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ReportFlowBottomBar(
              child: ElevatedButton(
                onPressed: state.hasLocation && !_isOutsideServiceArea
                    ? _navigateToDetails
                    : null,
                child: Text(l10n.continueLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSelector() {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      container: true,
      label: l10n.incidentLocationMethod,
      child: SegmentedButton<_LocationInputMode>(
        expandedInsets: EdgeInsets.zero,
        showSelectedIcon: false,
        segments: [
          ButtonSegment(
            value: _LocationInputMode.phone,
            label: Text(l10n.usePhoneLocation),
          ),
          ButtonSegment(
            value: _LocationInputMode.manual,
            label: Text(l10n.manualPin),
          ),
        ],
        selected: {_locationInputMode},
        onSelectionChanged: (selection) => _switchMode(selection.first),
      ),
    );
  }

  Widget _buildMapCard({
    required BuildContext context,
    required LatLng selectedPoint,
    required bool isDark,
    required NewReportState state,
  }) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: 320,
      child: Container(
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
                    MunicipalityMapCamera.constraintFor(
                      _selectedMunicipality,
                    ) ??
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
                                  _locationInputMode ==
                                      _LocationInputMode.manual
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
      ),
    );
  }

  Widget _buildLocationStatusCard(BuildContext context, NewReportState state) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final scheme = theme.colorScheme;
    final method = _locationInputMode == _LocationInputMode.manual
        ? l10n.manualPin
        : l10n.phoneLocation;
    final coordinates = state.latitude != null && state.longitude != null
        ? '${state.latitude!.toStringAsFixed(6)}, ${state.longitude!.toStringAsFixed(6)}'
        : null;
    final barangay = state.barangay == null
        ? null
        : '${l10n.barangay}: ${state.barangay}';
    final locationStatus = state.isResolvingBarangay
        ? l10n.gettingLocation
        : barangay;
    final semanticDetails = [
      method,
      coordinates,
      locationStatus,
    ].whereType<String>().join('. ');

    return Semantics(
      container: true,
      liveRegion: _isGettingPreciseLocation || state.isResolvingBarangay,
      label: semanticDetails,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.surface.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(
              _locationInputMode == _LocationInputMode.manual
                  ? Icons.touch_app_outlined
                  : Icons.my_location,
              color: scheme.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          method,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
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
                            color: scheme.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (coordinates != null)
                    Text(coordinates, style: theme.textTheme.bodySmall),
                  if (state.isResolvingBarangay)
                    Row(
                      children: [
                        SizedBox(
                          width: 11,
                          height: 11,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: scheme.primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.gettingLocation,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    )
                  else if (barangay != null)
                    Text(barangay, style: theme.textTheme.bodySmall)
                  else if (coordinates != null)
                    Text(
                      l10n.barangaysUnavailable,
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
      ),
    );
  }

  Widget _buildManualHint(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final scheme = theme.colorScheme;

    return Semantics(
      container: true,
      label: l10n.tapMapWithin(_selectedMunicipality.name),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: scheme.surface.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Text(
          l10n.tapMapWithin(_selectedMunicipality.name),
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildErrorBanner(ThemeData theme) {
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.error.withValues(alpha: 0.45)),
      ),
      child: Semantics(
        container: true,
        liveRegion: true,
        label: '${AppLocalizations.of(context).error}: $_error',
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, color: scheme.onErrorContainer),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _error!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
