import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/urdaneta_geo.dart';
import '../../../../core/network/error_mapper.dart';
import '../../../../core/presentation/widgets/app_toast.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/municipality_geo.dart';
import '../../../auth/data/auth_models.dart';
import '../../../auth/presentation/barangays_provider.dart';
import '../../../auth/data/user_permissions.dart';
import '../../../auth/presentation/verification_widgets.dart';
import '../../data/report_models.dart' hide LocationAccuracy;
import '../../data/reports_repository.dart';
import '../../../images/data/images_repository.dart';
import '../reports_controller.dart';
import 'quick_report_geo.dart';

enum _QuickLocationInputMode { phone, manual }

/// Quick report flow: location + short description only.
class QuickReportScreen extends ConsumerStatefulWidget {
  const QuickReportScreen({super.key});

  @override
  ConsumerState<QuickReportScreen> createState() => _QuickReportScreenState();
}

class _QuickReportScreenState extends ConsumerState<QuickReportScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _descriptionController = TextEditingController();
  MunicipalityModel _selectedMunicipality = bundledUrdanetaMunicipality;

  LatLngBounds get _serviceBounds {
    final bounds = _selectedMunicipality.bounds!;
    return LatLngBounds(
      LatLng(bounds.south, bounds.west),
      LatLng(bounds.north, bounds.east),
    );
  }

  List<LatLng> get _servicePolygon {
    if (_selectedMunicipality.id == defaultMunicipalityId) {
      return UrdanetaGeo.boundary
          .map((point) => LatLng(point.$1, point.$2))
          .toList(growable: false);
    }
    final bounds = _selectedMunicipality.bounds!;
    return [
      LatLng(bounds.south, bounds.west),
      LatLng(bounds.south, bounds.east),
      LatLng(bounds.north, bounds.east),
      LatLng(bounds.north, bounds.west),
    ];
  }

  bool _isSubmitting = false;
  bool _isLoadingLocation = false;
  bool _isGettingPreciseLocation = false;
  String? _error;
  Position? _currentPosition;
  LatLng? _selectedPoint;
  String? _locationLabel;
  _QuickLocationInputMode _locationInputMode = _QuickLocationInputMode.phone;

  @override
  void initState() {
    super.initState();
    _selectedPoint = const LatLng(
      UrdanetaGeo.defaultLat,
      UrdanetaGeo.defaultLng,
    );
    _locationLabel = UrdanetaGeo.defaultLocationLabel;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncSelectedPoint();
      _getCurrentLocation();
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _syncSelectedPoint() {
    final point = _selectedPoint;
    if (point == null) return;
    if (!_contains(point)) {
      setState(() {
        _error = municipalityUnavailableMessage(_selectedMunicipality);
      });
      return;
    }
  }

  bool _contains(LatLng point) => municipalityContains(
    _selectedMunicipality,
    point.latitude,
    point.longitude,
  );

  void _selectMunicipality(MunicipalityModel municipality) {
    if (municipality.id == _selectedMunicipality.id) return;
    final bounds = municipality.bounds;
    if (bounds == null || !bounds.isValid) {
      setState(() => _error = municipalityUnavailableMessage(municipality));
      return;
    }
    final center = LatLng(
      municipality.centerLat ?? (bounds.south + bounds.north) / 2,
      municipality.centerLng ?? (bounds.west + bounds.east) / 2,
    );
    setState(() {
      _selectedMunicipality = municipality;
      _selectedPoint = center;
      _locationLabel = '${municipality.name}, ${municipality.province}';
      _currentPosition = null;
      _error = null;
    });
    _mapController.move(center, 13);
    if (_locationInputMode == _QuickLocationInputMode.phone) {
      _getCurrentLocation();
    }
  }

  void _setSelectedPoint(LatLng point, {required String locationLabel}) {
    if (!_contains(point)) {
      setState(() {
        _error = municipalityUnavailableMessage(_selectedMunicipality);
      });
      return;
    }

    setState(() {
      _selectedPoint = point;
      _locationLabel = locationLabel;
      _error = null;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _mapController.move(point, 15);
    });
  }

  void _onMapTap(LatLng point) {
    if (_locationInputMode != _QuickLocationInputMode.manual) return;

    _setSelectedPoint(
      point,
      locationLabel:
          'Manual pin: ${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}',
    );
  }

  void _switchLocationMode(_QuickLocationInputMode mode) {
    if (_locationInputMode == mode) return;

    setState(() {
      _locationInputMode = mode;
      _error = null;
    });

    if (mode == _QuickLocationInputMode.phone) {
      _getCurrentLocation();
    } else {
      final point =
          _selectedPoint ??
          const LatLng(UrdanetaGeo.defaultLat, UrdanetaGeo.defaultLng);
      _setSelectedPoint(
        point,
        locationLabel:
            'Manual pin: ${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}',
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;

    setState(() {
      _isLoadingLocation = true;
      _error = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          _error = 'Location services are disabled. Please enable GPS.';
          _isLoadingLocation = false;
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
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _error =
              'Location permissions are permanently denied. Enable them in Settings.';
          _isLoadingLocation = false;
        });
        return;
      }

      final lastPosition = await Geolocator.getLastKnownPosition();
      if (lastPosition != null && mounted) {
        setState(() {
          _currentPosition = lastPosition;
          _isLoadingLocation = false;
          _isGettingPreciseLocation = true;
        });
        _updateLocationFromPosition(lastPosition);
      }

      await _getPreciseLocationInBackground(lastPosition);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to get location: ${e.toString()}';
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _getPreciseLocationInBackground(
    Position? fallbackPosition,
  ) async {
    try {
      final position =
          await Geolocator.getCurrentPosition(
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
        _isLoadingLocation = false;
      });
      _updateLocationFromPosition(position);
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _isGettingPreciseLocation = false;
        _isLoadingLocation = false;
        if (_currentPosition == null) {
          _error = 'Location request timed out. Please try again.';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isGettingPreciseLocation = false;
        _isLoadingLocation = false;
        if (_currentPosition == null) {
          _error = 'Failed to get precise location: ${e.toString()}';
        }
      });
    }
  }

  void _updateLocationFromPosition(Position position) {
    if (_locationInputMode != _QuickLocationInputMode.phone) {
      return;
    }

    final point = LatLng(position.latitude, position.longitude);
    if (!_contains(point)) {
      setState(() {
        _error = municipalityUnavailableMessage(_selectedMunicipality);
        _selectedPoint = null;
        _locationLabel = null;
      });
      return;
    }

    setState(() {
      _selectedPoint = point;
      _locationLabel =
          '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
      _error = null;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _mapController.move(point, 15);
    });
  }

  BarangayModel? _resolveNearestBarangay(double latitude, double longitude) {
    try {
      final barangays = ref
          .read(municipalityBarangaysProvider(_selectedMunicipality.id))
          .asData
          ?.value;
      if (barangays == null || barangays.isEmpty) {
        debugPrint(
          'QuickReport: barangay list unavailable; proceeding without derived barangay.',
        );
        return null;
      }

      return deriveNearestBarangay(
        barangays,
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      debugPrint('QuickReport: failed to derive barangay from geolocation: $e');
      return null;
    }
  }

  Future<void> _submitQuickReport() async {
    if (_isSubmitting) return;

    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      AppToast.warning(context, 'Please enter a short description.');
      return;
    }

    final point = _selectedPoint;
    if (point == null) {
      AppToast.warning(context, 'Please wait for your location to load.');
      return;
    }

    if (!_contains(point)) {
      AppToast.warning(
        context,
        municipalityUnavailableMessage(_selectedMunicipality),
      );
      return;
    }

    try {
      final nearby = await ref
          .read(reportsRepositoryProvider)
          .getNearbyReports(
            latitude: point.latitude,
            longitude: point.longitude,
            municipalityId: _selectedMunicipality.id,
          );
      if (nearby.isNotEmpty && mounted) {
        final submitAnyway = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Reports already nearby'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: nearby
                  .take(3)
                  .map(
                    (report) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.near_me_outlined),
                      title: Text(report.category),
                      subtitle: Text(
                        '${report.distanceMeters} m away - ${report.status.replaceAll('_', ' ')}'
                        '${report.isGrouped ? ' - grouped incident' : ''}',
                      ),
                    ),
                  )
                  .toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Review mine'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Submit anyway'),
              ),
            ],
          ),
        );
        if (submitAnyway != true) return;
      }
    } catch (e) {
      debugPrint('Nearby report check unavailable: $e');
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final reportsRepo = ref.read(reportsRepositoryProvider);
      final nearestBarangay = _resolveNearestBarangay(
        point.latitude,
        point.longitude,
      );
      final result = await reportsRepo.createReport(
        CreateReportRequest(
          description: description,
          isHappeningNow: true,
          zone: nearestBarangay?.name,
          municipalityId: _selectedMunicipality.id,
          barangayId: nearestBarangay?.id,
          barangay: nearestBarangay?.name,
          cityMunicipality: _selectedMunicipality.name,
          province: _selectedMunicipality.province,
          latitude: point.latitude.toStringAsFixed(10),
          longitude: point.longitude.toStringAsFixed(10),
          locationAccuracy: 'exact',
          location: _locationLabel,
          declarationConfirmed: true,
          dataProcessingConsent: true,
        ),
        isQuickReport: true,
      );

      ref.invalidate(reportsControllerProvider);
      ref.read(myReportsRefreshProvider.notifier).increment();

      if (!mounted) return;
      await _offerPhotoUpload(result.id);
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
      AppToast.success(context, 'Your quick report has been submitted.');
      debugPrint('Quick report submitted: ${result.id}');
    } catch (e) {
      if (!mounted) return;
      final message = ErrorMapper.userMessage(ErrorMapper.mapException(e));
      setState(() {
        _isSubmitting = false;
        _error = message;
      });
      AppToast.error(context, message);
    }
  }

  Future<void> _offerPhotoUpload(String reportId) async {
    final addPhoto = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Report submitted'),
        content: const Text('Add an optional photo as evidence?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Done'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.add_a_photo_outlined),
            label: const Text('Add photo'),
          ),
        ],
      ),
    );
    if (addPhoto != true || !mounted) return;

    final picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 75,
    );
    if (picked == null || !mounted) return;

    Object? lastError;
    for (var attempt = 1; attempt <= 3; attempt++) {
      try {
        await ref
            .read(imagesRepositoryProvider)
            .uploadImage(
              imageFile: File(picked.path),
              reportId: reportId,
              isPrimary: true,
            )
            .timeout(const Duration(seconds: 25));
        if (mounted) AppToast.success(context, 'Photo uploaded.');
        return;
      } catch (e) {
        lastError = e;
        if (attempt < 3) {
          await Future<void>.delayed(Duration(seconds: attempt * 2));
        }
      }
    }
    debugPrint('Quick report photo upload failed: $lastError');
    if (mounted) {
      AppToast.warning(
        context,
        'Report saved, but photo upload failed. You can add it later.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final permissions = ref.watch(userPermissionsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final municipalityBounds = _selectedMunicipality.bounds!;
    final point =
        _selectedPoint ??
        LatLng(
          _selectedMunicipality.centerLat ??
              (municipalityBounds.south + municipalityBounds.north) / 2,
          _selectedMunicipality.centerLng ??
              (municipalityBounds.west + municipalityBounds.east) / 2,
        );
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Report'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.only(bottom: bottomInset + 20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.sizeOf(context).height,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                VerificationBanner(permissions: permissions),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fast report',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Use your current location and a short description. The system will categorize and prioritize it automatically.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: ref
                      .watch(municipalitiesProvider)
                      .when(
                        data: (municipalities) =>
                            DropdownButtonFormField<String>(
                              initialValue: _selectedMunicipality.id,
                              decoration: const InputDecoration(
                                labelText: 'Municipality',
                                prefixIcon: Icon(Icons.location_city),
                                border: OutlineInputBorder(),
                              ),
                              items: municipalities
                                  .map(
                                    (item) => DropdownMenuItem(
                                      value: item.id,
                                      child: Text(
                                        '${item.name}, ${item.province}',
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: _isSubmitting
                                  ? null
                                  : (value) {
                                      if (value == null) return;
                                      _selectMunicipality(
                                        municipalities.firstWhere(
                                          (item) => item.id == value,
                                        ),
                                      );
                                    },
                            ),
                        loading: () => const LinearProgressIndicator(),
                        error: (error, stack) => Text(
                          'Municipality metadata unavailable.',
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Card(
                    elevation: 0,
                    color: isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.lightSurfaceVariant,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.my_location,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _locationInputMode ==
                                              _QuickLocationInputMode.manual
                                          ? 'Manual pin'
                                          : 'Current location',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _locationLabel ?? 'Getting location...',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: isDark
                                                ? AppColors.darkTextSecondary
                                                : AppColors.lightTextSecondary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SegmentedButton<_QuickLocationInputMode>(
                            segments: const [
                              ButtonSegment(
                                value: _QuickLocationInputMode.phone,
                                label: Text('Phone GPS'),
                                icon: Icon(Icons.gps_fixed),
                              ),
                              ButtonSegment(
                                value: _QuickLocationInputMode.manual,
                                label: Text('Manual pin'),
                                icon: Icon(Icons.add_location_alt_outlined),
                              ),
                            ],
                            selected: {_locationInputMode},
                            onSelectionChanged: (selection) {
                              _switchLocationMode(selection.first);
                            },
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Lat ${point.latitude.toStringAsFixed(6)}  •  Lng ${point.longitude.toStringAsFixed(6)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 220,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: FlutterMap(
                                mapController: _mapController,
                                options: MapOptions(
                                  initialCenter: point,
                                  initialZoom: 15,
                                  minZoom: 12,
                                  maxZoom: 18,
                                  cameraConstraint: CameraConstraint.contain(
                                    bounds: _serviceBounds,
                                  ),
                                  onTap: (_, tappedPoint) =>
                                      _onMapTap(tappedPoint),
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName:
                                        'com.example.bayantrack_mobile',
                                  ),
                                  PolygonLayer(
                                    polygons: [
                                      Polygon(
                                        points: _servicePolygon,
                                        color: AppColors.primary.withValues(
                                          alpha: 0.08,
                                        ),
                                        borderColor: AppColors.primary
                                            .withValues(alpha: 0.45),
                                        borderStrokeWidth: 2,
                                      ),
                                    ],
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: point,
                                        width: 44,
                                        height: 44,
                                        child: Icon(
                                          Icons.location_pin,
                                          size: 40,
                                          color:
                                              _locationInputMode ==
                                                  _QuickLocationInputMode.manual
                                              ? AppColors.primary
                                              : AppColors.alertHigh,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const RichAttributionWidget(
                                    attributions: [
                                      TextSourceAttribution(
                                        'OpenStreetMap contributors',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _locationInputMode == _QuickLocationInputMode.manual
                                ? 'Tap the map to place a manual pin within ${_selectedMunicipality.name}.'
                                : 'Your GPS location is used automatically. Switch to manual pin if needed.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                          if (_isLoadingLocation ||
                              _isGettingPreciseLocation) ...[
                            const SizedBox(height: 12),
                            const LinearProgressIndicator(),
                          ],
                          if (_error != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              _error!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.alertHigh,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: _isLoadingLocation
                                  ? null
                                  : _getCurrentLocation,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Refresh location'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    maxLength: 500,
                    textInputAction: TextInputAction.newline,
                    decoration: const InputDecoration(
                      labelText: 'Short description',
                      hintText: 'What is happening? Keep it short and clear.',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: FilledButton(
                    onPressed: _isSubmitting ? null : _submitQuickReport,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Submit Quick Report'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
