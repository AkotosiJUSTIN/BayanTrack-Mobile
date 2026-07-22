import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/maps/municipality_map.dart';
import '../../../../core/network/error_mapper.dart';
import '../../../../core/presentation/widgets/app_toast.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/municipality_geo.dart';
import '../../../auth/data/auth_models.dart';
import '../../../auth/data/user_permissions.dart';
import '../../../auth/presentation/barangays_provider.dart';
import '../../data/report_models.dart' hide LocationAccuracy;
import '../../data/reports_repository.dart';
import '../../../images/data/images_repository.dart';
import '../reports_controller.dart';
import 'quick_report_geo.dart';

enum _QuickLocationInputMode { phone, manual }

/// Quick report flow: location + short description only.
class QuickReportScreen extends ConsumerStatefulWidget {
  const QuickReportScreen({
    super.key,
    this.locationOverride,
    this.showMapTiles = true,
  });

  @visibleForTesting
  final Future<Position> Function()? locationOverride;

  @visibleForTesting
  final bool showMapTiles;

  @override
  ConsumerState<QuickReportScreen> createState() => _QuickReportScreenState();
}

class _QuickReportScreenState extends ConsumerState<QuickReportScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _descriptionController = TextEditingController();
  MunicipalityModel _selectedMunicipality = bundledUrdanetaMunicipality;

  bool _isSubmitting = false;
  bool _isLoadingLocation = false;
  bool _isGettingPreciseLocation = false;
  bool _deviceLocationOutside = false;
  String? _locationError;
  String? _submissionError;
  Position? _currentPosition;
  LatLng? _selectedPoint;
  String? _locationLabel;
  _QuickLocationInputMode _locationInputMode = _QuickLocationInputMode.phone;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool _contains(LatLng point) => municipalityContains(
    _selectedMunicipality,
    point.latitude,
    point.longitude,
  );

  void _selectMunicipality(MunicipalityModel municipality) {
    if (municipality.id == _selectedMunicipality.id) return;
    final bounds = municipality.bounds;
    if (bounds == null || !municipality.hasUsableBoundary) {
      setState(
        () => _locationError = municipalityUnavailableMessage(municipality),
      );
      return;
    }
    final center = LatLng(
      municipality.centerLat ?? (bounds.south + bounds.north) / 2,
      municipality.centerLng ?? (bounds.west + bounds.east) / 2,
    );
    setState(() {
      _selectedMunicipality = municipality;
      _selectedPoint = null;
      _locationLabel = null;
      _currentPosition = null;
      _deviceLocationOutside = false;
      _locationError = null;
      _submissionError = null;
    });
    _mapController.move(center, 13);
    if (_locationInputMode == _QuickLocationInputMode.phone) {
      _getCurrentLocation();
    }
  }

  void _setSelectedPoint(LatLng point, {required String locationLabel}) {
    if (!_contains(point)) {
      setState(() {
        _selectedPoint = null;
        _locationLabel = null;
        _locationError =
            'Incident pin must be inside ${_selectedMunicipality.name}.';
      });
      return;
    }

    setState(() {
      _selectedPoint = point;
      _locationLabel = locationLabel;
      _locationError = null;
      _submissionError = null;
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
      _locationError = null;
      _submissionError = null;
    });

    if (mode == _QuickLocationInputMode.phone) {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;

    setState(() {
      _isLoadingLocation = true;
      _isGettingPreciseLocation = false;
      _locationError = null;
      _submissionError = null;
    });

    final locationOverride = widget.locationOverride;
    if (locationOverride != null) {
      try {
        final position = await locationOverride();
        if (!mounted) return;
        setState(() => _isLoadingLocation = false);
        _updateLocationFromPosition(position);
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _isLoadingLocation = false;
          _locationError =
              'Could not get device location. Refresh or use Manual Pin.';
        });
      }
      return;
    }

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          _locationError =
              'Device location is off. Enable GPS or use Manual Pin.';
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
            _locationError =
                'Location permission denied. Allow access or use Manual Pin.';
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _locationError =
              'Location permission is blocked. Enable it in Settings or use Manual Pin.';
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
        _locationError =
            'Could not get device location. Refresh or use Manual Pin.';
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
          _locationError =
              'Location request timed out. Refresh or use Manual Pin.';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isGettingPreciseLocation = false;
        _isLoadingLocation = false;
        if (_currentPosition == null) {
          _locationError =
              'Could not get precise location. Refresh or use Manual Pin.';
        }
      });
    }
  }

  void _updateLocationFromPosition(Position position) {
    final point = LatLng(position.latitude, position.longitude);
    if (!_contains(point)) {
      setState(() {
        _currentPosition = position;
        _deviceLocationOutside = true;
        if (_locationInputMode == _QuickLocationInputMode.phone) {
          _selectedPoint = null;
          _locationLabel = null;
        }
      });
      return;
    }

    setState(() {
      _currentPosition = position;
      _deviceLocationOutside = false;
      if (_locationInputMode == _QuickLocationInputMode.phone) {
        _selectedPoint = point;
        _locationLabel =
            '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
        _locationError = null;
      }
    });

    if (_locationInputMode != _QuickLocationInputMode.phone) return;

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
    final descriptionError = quickReportDescriptionError(description);
    if (descriptionError != null) {
      AppToast.warning(context, descriptionError);
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

    setState(() {
      _isSubmitting = true;
      _submissionError = null;
    });

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
        if (submitAnyway != true) {
          if (mounted) setState(() => _isSubmitting = false);
          return;
        }
      }
    } catch (e) {
      debugPrint('Nearby report check unavailable: $e');
    }

    if (!mounted) return;

    final reportsRepo = ref.read(reportsRepositoryProvider);
    final nearestBarangay = _resolveNearestBarangay(
      point.latitude,
      point.longitude,
    );
    late final Report result;
    try {
      result = await reportsRepo.createReport(
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
    } catch (e) {
      if (!mounted) return;
      final message = ErrorMapper.userMessage(ErrorMapper.mapException(e));
      setState(() {
        _isSubmitting = false;
        _submissionError = message;
      });
      AppToast.error(context, message);
      return;
    }

    if (!mounted) return;
    ref.invalidate(reportsControllerProvider);
    ref.read(myReportsRefreshProvider.notifier).increment();

    await _offerPhotoUpload(result.id);
    if (!mounted) return;
    AppToast.success(context, 'Your quick report has been submitted.');
    debugPrint('Quick report submitted: ${result.id}');
    Navigator.of(context).popUntil((route) => route.isFirst);
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
    final imagesRepository = ref.read(imagesRepositoryProvider);

    Object? lastError;
    for (var attempt = 1; attempt <= 3; attempt++) {
      try {
        await imagesRepository
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
          if (!mounted) return;
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

  String? _submitDisabledReason(String description) {
    final point = _selectedPoint;
    if (point == null || !_contains(point)) {
      if (_deviceLocationOutside &&
          _locationInputMode == _QuickLocationInputMode.phone) {
        return 'Switch to Manual Pin and choose an incident location inside ${_selectedMunicipality.name}.';
      }
      if (_isLoadingLocation || _isGettingPreciseLocation) {
        return 'Waiting for an incident location…';
      }
      return _locationInputMode == _QuickLocationInputMode.manual
          ? 'Tap the map to choose an incident location.'
          : 'Choose an incident location to continue.';
    }
    return quickReportDescriptionError(description);
  }

  Widget _buildVerificationNotice(
    UserPermissions permissions,
    ThemeData theme,
  ) {
    if (permissions.isVerified) return const SizedBox.shrink();
    final scheme = theme.colorScheme;
    return Semantics(
      container: true,
      label:
          'Verification notice. You can report now. Verification improves trust and unlocks account features.',
      child: Container(
        key: const Key('quick-report-verification-notice'),
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.primary.withValues(alpha: 0.18)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.verified_user_outlined, color: scheme.primary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'You can report now. Verification improves trust and unlocks account features.',
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationFeedback(ThemeData theme) {
    final scheme = theme.colorScheme;
    final error = _locationError;
    if (error != null) {
      return Semantics(
        container: true,
        liveRegion: true,
        label: 'Location error. $error',
        child: Container(
          key: const Key('quick-report-location-error'),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.error.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.error_outline, color: scheme.error, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  error,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_deviceLocationOutside) {
      final isDark = theme.brightness == Brightness.dark;
      final background = isDark ? AppColors.pendingBgDark : AppColors.pendingBg;
      final foreground = isDark
          ? AppColors.pendingTextDark
          : AppColors.pendingText;
      final manualSelected =
          _locationInputMode == _QuickLocationInputMode.manual &&
          _selectedPoint != null;
      return Semantics(
        container: true,
        liveRegion: true,
        label: manualSelected
            ? 'Incident location selected inside Urdaneta. Device location is outside Urdaneta.'
            : 'Device location is outside Urdaneta. You can still select an incident inside Urdaneta.',
        child: Container(
          key: const Key('quick-report-outside-location'),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: foreground, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          manualSelected
                              ? 'Incident location selected'
                              : 'Location is outside ${_selectedMunicipality.name}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: foreground,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          manualSelected
                              ? 'Your phone may be outside the city; the incident pin is inside the boundary.'
                              : 'You do not need to be in the city. Select the incident inside ${_selectedMunicipality.name}.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: foreground,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_locationInputMode == _QuickLocationInputMode.phone) ...[
                const SizedBox(height: 4),
                TextButton.icon(
                  key: const Key('quick-report-switch-manual'),
                  onPressed: () =>
                      _switchLocationMode(_QuickLocationInputMode.manual),
                  icon: const Icon(Icons.add_location_alt_outlined),
                  label: const Text('Switch to Manual Pin'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    final isLoading = _isLoadingLocation || _isGettingPreciseLocation;
    final hasLocation = _selectedPoint != null;
    final status = isLoading
        ? 'Locating…'
        : _locationInputMode == _QuickLocationInputMode.manual
        ? hasLocation
              ? 'Incident location selected'
              : 'Tap the map to place the incident pin'
        : hasLocation
        ? 'GPS location found'
        : 'Choose an incident location';
    return Semantics(
      liveRegion: true,
      label: status,
      child: Row(
        key: const Key('quick-report-location-status'),
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isLoading)
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: scheme.primary,
              ),
            )
          else
            Icon(
              hasLocation ? Icons.check_circle_outline : Icons.info_outline,
              color: hasLocation ? AppColors.success : scheme.primary,
              size: 20,
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              status,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitBar(ThemeData theme) {
    final scheme = theme.colorScheme;
    return Material(
      key: const Key('quick-report-submit-bar'),
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _descriptionController,
          builder: (context, value, _) {
            final disabledReason = _submitDisabledReason(value.text);
            final canSubmit = !_isSubmitting && disabledReason == null;
            final submitError = _submissionError;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (submitError != null) ...[
                  Semantics(
                    liveRegion: true,
                    label: 'Submission error. $submitError',
                    child: Text(
                      submitError,
                      key: const Key('quick-report-submit-error'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                ] else if (!_isSubmitting && disabledReason != null) ...[
                  Semantics(
                    liveRegion: true,
                    label: 'Submit disabled. $disabledReason',
                    child: Text(
                      disabledReason,
                      key: const Key('quick-report-disabled-reason'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.72),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                Semantics(
                  button: true,
                  enabled: canSubmit,
                  liveRegion: _isSubmitting,
                  label: _isSubmitting
                      ? 'Submitting Quick Report'
                      : 'Submit Quick Report',
                  hint: disabledReason,
                  child: ElevatedButton(
                    key: const Key('quick-report-submit'),
                    onPressed: canSubmit ? _submitQuickReport : null,
                    style: _isSubmitting
                        ? ElevatedButton.styleFrom(
                            disabledBackgroundColor: scheme.primary,
                            disabledForegroundColor: scheme.onPrimary,
                          )
                        : null,
                    child: _isSubmitting
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: scheme.onPrimary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Flexible(
                                child: Text('Submitting Quick Report…'),
                              ),
                            ],
                          )
                        : const Text('Submit Quick Report'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final permissions = ref.watch(userPermissionsProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final municipalityBounds = _selectedMunicipality.bounds!;
    final mapCenter =
        _selectedPoint ??
        LatLng(
          _selectedMunicipality.centerLat ??
              (municipalityBounds.south + municipalityBounds.north) / 2,
          _selectedMunicipality.centerLng ??
              (municipalityBounds.west + municipalityBounds.east) / 2,
        );
    final devicePoint = _currentPosition == null
        ? null
        : LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    final municipalities =
        ref.watch(municipalitiesProvider).asData?.value ??
        const [bundledUrdanetaMunicipality];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Report'),
        leading: IconButton(
          tooltip: 'Close Quick Report',
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildVerificationNotice(permissions, theme),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Location',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (municipalities.length == 1)
                            Semantics(
                              label:
                                  '${_selectedMunicipality.name} municipality boundary',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.crop_square,
                                    size: 18,
                                    color: scheme.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      '${_selectedMunicipality.name}, ${_selectedMunicipality.province} boundary',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: scheme.onSurface.withValues(
                                              alpha: 0.72,
                                            ),
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            DropdownButtonFormField<String>(
                              initialValue: _selectedMunicipality.id,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Municipality boundary',
                                prefixIcon: Icon(Icons.location_city_outlined),
                                isDense: true,
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
                          const SizedBox(height: 10),
                          Semantics(
                            container: true,
                            label: 'Incident location method',
                            child: SegmentedButton<_QuickLocationInputMode>(
                              key: const Key('quick-report-location-mode'),
                              expandedInsets: EdgeInsets.zero,
                              showSelectedIcon: false,
                              segments: const [
                                ButtonSegment(
                                  value: _QuickLocationInputMode.phone,
                                  label: Text('Phone GPS'),
                                ),
                                ButtonSegment(
                                  value: _QuickLocationInputMode.manual,
                                  label: Text('Manual Pin'),
                                ),
                              ],
                              selected: {_locationInputMode},
                              onSelectionChanged: _isSubmitting
                                  ? null
                                  : (selection) =>
                                        _switchLocationMode(selection.first),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Card(
                        margin: EdgeInsets.zero,
                        elevation: 0,
                        color: scheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: scheme.outline),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Semantics(
                                container: true,
                                label:
                                    '${_selectedMunicipality.name} incident location map',
                                hint:
                                    _locationInputMode ==
                                        _QuickLocationInputMode.manual
                                    ? 'Tap inside the boundary to place the incident pin.'
                                    : 'Shows device and selected incident locations.',
                                child: SizedBox(
                                  key: const Key('quick-report-map'),
                                  height: 210,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Stack(
                                      children: [
                                        FlutterMap(
                                          mapController: _mapController,
                                          options: MapOptions(
                                            initialCenter: mapCenter,
                                            initialZoom: 15,
                                            minZoom: 12,
                                            maxZoom: 18,
                                            initialCameraFit:
                                                MunicipalityMapCamera.initialFit(
                                                  _selectedMunicipality,
                                                ),
                                            cameraConstraint:
                                                MunicipalityMapCamera.constraintFor(
                                                  _selectedMunicipality,
                                                ) ??
                                                const CameraConstraint.unconstrained(),
                                            onTap: (_, tappedPoint) =>
                                                _onMapTap(tappedPoint),
                                          ),
                                          children: [
                                            if (widget.showMapTiles)
                                              TileLayer(
                                                urlTemplate:
                                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                                userAgentPackageName:
                                                    'com.example.bayantrack_mobile',
                                              ),
                                            MunicipalityBoundaryLayer(
                                              boundary: _selectedMunicipality
                                                  .boundary,
                                            ),
                                            MarkerLayer(
                                              markers: [
                                                if (_selectedPoint != null)
                                                  Marker(
                                                    point: _selectedPoint!,
                                                    width: 46,
                                                    height: 46,
                                                    child: Icon(
                                                      Icons.location_pin,
                                                      size: 42,
                                                      color: scheme.secondary,
                                                    ),
                                                  ),
                                                if (devicePoint != null &&
                                                    _contains(devicePoint))
                                                  Marker(
                                                    point: devicePoint,
                                                    width: 28,
                                                    height: 28,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: scheme.primary,
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color:
                                                              scheme.onPrimary,
                                                          width: 3,
                                                        ),
                                                      ),
                                                      child: Icon(
                                                        Icons.my_location,
                                                        size: 14,
                                                        color: scheme.onPrimary,
                                                      ),
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
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Column(
                                            children: [
                                              IconButton.filledTonal(
                                                key: const Key(
                                                  'quick-report-refresh-location',
                                                ),
                                                tooltip:
                                                    'Refresh device location',
                                                constraints:
                                                    const BoxConstraints.tightFor(
                                                      width: 48,
                                                      height: 48,
                                                    ),
                                                onPressed:
                                                    _isSubmitting ||
                                                        _isLoadingLocation
                                                    ? null
                                                    : _getCurrentLocation,
                                                icon: const Icon(
                                                  Icons.gps_fixed,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              IconButton.filledTonal(
                                                key: const Key(
                                                  'quick-report-recenter-municipality',
                                                ),
                                                tooltip:
                                                    'Recenter municipality',
                                                constraints:
                                                    const BoxConstraints.tightFor(
                                                      width: 48,
                                                      height: 48,
                                                    ),
                                                onPressed: _isSubmitting
                                                    ? null
                                                    : () => MunicipalityMapCamera.recenter(
                                                        _mapController,
                                                        _selectedMunicipality,
                                                      ),
                                                icon: const Icon(
                                                  Icons
                                                      .center_focus_strong_outlined,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 12,
                                runSpacing: 4,
                                children: [
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        WidgetSpan(
                                          alignment:
                                              PlaceholderAlignment.middle,
                                          child: Icon(
                                            Icons.my_location,
                                            size: 15,
                                            color: scheme.primary,
                                          ),
                                        ),
                                        const TextSpan(text: ' Device GPS'),
                                      ],
                                    ),
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        WidgetSpan(
                                          alignment:
                                              PlaceholderAlignment.middle,
                                          child: Icon(
                                            Icons.location_pin,
                                            size: 17,
                                            color: scheme.secondary,
                                          ),
                                        ),
                                        const TextSpan(text: ' Incident pin'),
                                      ],
                                    ),
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        WidgetSpan(
                                          alignment:
                                              PlaceholderAlignment.middle,
                                          child: Icon(
                                            Icons.crop_square,
                                            size: 15,
                                            color: scheme.primary,
                                          ),
                                        ),
                                        const TextSpan(text: ' City boundary'),
                                      ],
                                    ),
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildLocationFeedback(theme),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Short description',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Describe what is happening. 500 characters maximum.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.72),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Semantics(
                            container: true,
                            label: 'Short description',
                            hint:
                                'Describe what is happening in 500 characters or fewer.',
                            child: TextField(
                              key: const Key('quick-report-description'),
                              controller: _descriptionController,
                              minLines: 2,
                              maxLines: 4,
                              maxLength: quickReportDescriptionMaxLength,
                              textInputAction: TextInputAction.newline,
                              onChanged: (_) {
                                if (_submissionError != null) {
                                  setState(() => _submissionError = null);
                                }
                              },
                              decoration: const InputDecoration(
                                hintText: 'What is happening?',
                                alignLabelWithHint: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildSubmitBar(theme),
          ],
        ),
      ),
    );
  }
}
