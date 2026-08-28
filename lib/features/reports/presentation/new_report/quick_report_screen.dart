import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/maps/municipality_map.dart';
import '../../../../core/presentation/widgets/app_toast.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/municipality_geo.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/data/auth_models.dart';
import '../../../auth/data/user_permissions.dart';
import '../../../auth/presentation/barangays_provider.dart';
import '../../../auth/presentation/auth_controller.dart';
import '../../../images/data/evidence_upload_queue.dart';
import '../../../images/data/evidence_upload_queue_provider.dart';
import '../../data/reports_repository.dart';
import '../../data/report_models.dart'
    hide LocationAccuracy, ReportCategory, ReportStatus;
import '../../domain/entities/report_enums.dart' hide LocationAccuracy;
import '../../reports_di.dart';
import '../reports_controller.dart';
import '../report_labels.dart';
import 'new_report_controller.dart';
import 'quick_report_geo.dart';

enum _QuickLocationInputMode { phone, manual }

enum _EmergencyFollowUpAction { details, photos, done }

/// Quick report flow: location + short description only.
class QuickReportScreen extends ConsumerStatefulWidget {
  const QuickReportScreen({
    super.key,
    this.locationOverride,
    this.showMapTiles = true,
    this.emergencyMode = false,
  });

  @visibleForTesting
  final Future<Position> Function()? locationOverride;

  @visibleForTesting
  final bool showMapTiles;

  @visibleForTesting
  final bool emergencyMode;

  @override
  ConsumerState<QuickReportScreen> createState() => _QuickReportScreenState();
}

class _QuickReportScreenState extends ConsumerState<QuickReportScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _descriptionController = TextEditingController();
  ReportCategoryOption? _selectedEmergencyCategory;
  List<ReportCategoryOption> _emergencyCategories = const [];
  bool _isLoadingEmergencyCategories = false;
  String? _emergencyCategoryError;
  late final String _emergencyIdempotencyKey =
      'emergency-${DateTime.now().microsecondsSinceEpoch}';
  MunicipalityModel _selectedMunicipality = bundledUrdanetaMunicipality;

  bool _isSubmitting = false;
  bool _isLoadingLocation = false;
  bool _isGettingPreciseLocation = false;
  bool _emergencyConfirmed = false;
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
      if (widget.emergencyMode) _loadEmergencyCategories();
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
    final l10n = AppLocalizations.of(context);
    if (!_contains(point)) {
      setState(() {
        _selectedPoint = null;
        _locationLabel = null;
        _locationError = l10n.incidentPinInside(_selectedMunicipality.name);
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

  Future<void> _loadEmergencyCategories() async {
    if (!mounted) return;
    setState(() {
      _isLoadingEmergencyCategories = true;
      _emergencyCategoryError = null;
    });
    try {
      final options = await ref
          .read(reportsRepositoryProvider)
          .getFormOptions();
      if (!mounted) return;
      setState(() {
        _emergencyCategories = options.categories
            .where((option) => option.active && option.key.isNotEmpty)
            .toList(growable: false);
        _isLoadingEmergencyCategories = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _emergencyCategories = offlineReportFormOptions.categories;
        _isLoadingEmergencyCategories = false;
        _emergencyCategoryError = AppLocalizations.of(context).error;
      });
    }
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
    final l10n = AppLocalizations.of(context);

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
              '${l10n.error}: ${l10n.refreshLocation} / ${l10n.manualPin}';
        });
      }
      return;
    }

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          _locationError = '${l10n.locationServicesDisabled} ${l10n.manualPin}';
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
                '${l10n.locationPermissionDenied}. ${l10n.manualPin}';
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _locationError =
              '${l10n.locationPermissionSettings} ${l10n.manualPin}';
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
            '${l10n.error}: ${l10n.refreshLocation} / ${l10n.manualPin}';
        _isLoadingLocation = false;
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
        _isLoadingLocation = false;
      });
      _updateLocationFromPosition(position);
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _isGettingPreciseLocation = false;
        _isLoadingLocation = false;
        if (_currentPosition == null) {
          _locationError = '${l10n.locationRequestTimedOut} ${l10n.manualPin}';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isGettingPreciseLocation = false;
        _isLoadingLocation = false;
        if (_currentPosition == null) {
          _locationError =
              '${l10n.error}: ${l10n.refreshLocation} / ${l10n.manualPin}';
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
    if (widget.emergencyMode) {
      await _submitEmergencyReport();
      return;
    }
    final l10n = AppLocalizations.of(context);

    final description = _descriptionController.text.trim();
    final descriptionError = quickReportDescriptionError(
      description,
      l10n: l10n,
    );
    if (descriptionError != null) {
      AppToast.warning(context, descriptionError);
      return;
    }

    final point = _selectedPoint;
    if (point == null) {
      AppToast.warning(context, l10n.waitingIncidentLocation);
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
            title: Text(l10n.reportsAlreadyNearby),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: nearby
                  .take(3)
                  .map(
                    (report) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.near_me_outlined),
                      title: Text(
                        localizedReportCategory(
                          ReportCategory.fromString(report.category),
                          l10n,
                          fallback: report.category,
                        ),
                      ),
                      subtitle: Text(
                        '${l10n.distanceAway(report.distanceMeters)} - '
                        '${localizedReportStatus(ReportStatus.fromString(report.status), l10n)}'
                        '${report.isGrouped ? ' - ${l10n.groupedIncident}' : ''}',
                      ),
                    ),
                  )
                  .toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(l10n.reviewMine),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(l10n.submitAnyway),
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

    final nearestBarangay = _resolveNearestBarangay(
      point.latitude,
      point.longitude,
    );
    late final String reportId;
    try {
      final report = await ref
          .read(newReportControllerProvider.notifier)
          .submitQuickReport(
            description: description,
            municipalityId: _selectedMunicipality.id,
            barangayId: nearestBarangay?.id,
            barangay: nearestBarangay?.name,
            cityMunicipality: _selectedMunicipality.name,
            province: _selectedMunicipality.province,
            latitude: point.latitude,
            longitude: point.longitude,
            // The quick flow has no editable landmark field; GPS text must not
            // be persisted as a landmark by the legacy serializer mapping.
            location: null,
          );
      reportId = report.id;
    } catch (e) {
      if (!mounted) return;
      final message = e is ReportSubmissionFailure
          ? e.message
          : l10n.unableSubmitReport;
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

    await _offerPhotoUpload(reportId);
    if (!mounted) return;
    AppToast.success(context, l10n.reportSubmitted);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _submitEmergencyReport() async {
    if (_isSubmitting) return;
    final l10n = AppLocalizations.of(context);
    final category = _selectedEmergencyCategory;
    if (category == null) {
      AppToast.warning(context, l10n.emergencyCategoryRequired);
      return;
    }
    if (!_emergencyConfirmed) {
      AppToast.warning(context, l10n.emergencyConfirmationRequired);
      return;
    }

    final point = _selectedPoint;
    if (point == null || !_contains(point)) {
      AppToast.warning(context, l10n.chooseIncidentLocation);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submissionError = null;
    });

    final nearestBarangay = _resolveNearestBarangay(
      point.latitude,
      point.longitude,
    );
    try {
      final report = await ref
          .read(newReportControllerProvider.notifier)
          .submitEmergencyReport(
            category: category.key,
            municipalityId: _selectedMunicipality.id,
            barangayId: nearestBarangay?.id,
            barangay: nearestBarangay?.name,
            cityMunicipality: _selectedMunicipality.name,
            province: _selectedMunicipality.province,
            latitude: point.latitude,
            longitude: point.longitude,
            idempotencyKey: _emergencyIdempotencyKey,
          );
      if (!mounted) return;
      ref.invalidate(reportsControllerProvider);
      ref.read(myReportsRefreshProvider.notifier).increment();
      setState(() => _isSubmitting = false);
      await _offerEmergencyFollowUp(report.id);
      if (!mounted) return;
      AppToast.success(context, l10n.reportSubmitted);
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      final message = e is ReportSubmissionFailure
          ? e.message
          : l10n.unableSubmitReport;
      setState(() {
        _isSubmitting = false;
        _submissionError = message;
      });
      AppToast.error(context, message);
    }
  }

  Future<void> _offerEmergencyFollowUp(String reportId) async {
    final l10n = AppLocalizations.of(context);
    final action = await showModalBottomSheet<_EmergencyFollowUpAction>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.notes_outlined),
              title: Text(l10n.addDetails),
              onTap: () =>
                  Navigator.pop(sheetContext, _EmergencyFollowUpAction.details),
            ),
            ListTile(
              leading: const Icon(Icons.add_a_photo_outlined),
              title: Text(l10n.addPhotos),
              onTap: () =>
                  Navigator.pop(sheetContext, _EmergencyFollowUpAction.photos),
            ),
            ListTile(
              leading: const Icon(Icons.check_outlined),
              title: Text(l10n.done),
              onTap: () =>
                  Navigator.pop(sheetContext, _EmergencyFollowUpAction.done),
            ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    switch (action) {
      case _EmergencyFollowUpAction.details:
        await _addEmergencyDetails(reportId);
      case _EmergencyFollowUpAction.photos:
        await _queuePhoto(reportId);
      case _EmergencyFollowUpAction.done:
        return;
    }
  }

  Future<void> _addEmergencyDetails(String reportId) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final details = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.addDetails),
        content: TextField(
          key: const Key('emergency-report-details'),
          controller: controller,
          autofocus: true,
          minLines: 3,
          maxLines: 6,
          maxLength: 2000,
          decoration: InputDecoration(
            hintText: l10n.emergencyDetailsHint,
            alignLabelWithHint: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) Navigator.pop(dialogContext, value);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    controller.dispose();
    if (!mounted || details == null) return;

    try {
      final result = await ref.read(updateReportUseCaseProvider)(
        id: reportId,
        description: details,
      );
      if (!mounted) return;
      result.when(
        success: (_) => AppToast.success(context, l10n.detailsSaved),
        failure: (failure) => AppToast.warning(context, failure.message),
      );
    } catch (_) {
      if (mounted) AppToast.warning(context, l10n.unableSubmitReport);
    }
  }

  Future<void> _offerPhotoUpload(String reportId) async {
    final l10n = AppLocalizations.of(context);
    final addPhoto = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.reportSubmitted),
        content: Text(l10n.addOptionalPhoto),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.done),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.add_a_photo_outlined),
            label: Text(l10n.addPhoto),
          ),
        ],
      ),
    );
    if (addPhoto != true || !mounted) return;

    await _queuePhoto(reportId);
  }

  Future<void> _queuePhoto(String reportId) async {
    final l10n = AppLocalizations.of(context);

    final picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 75,
    );
    if (picked == null || !mounted) return;
    final auth = ref.read(authControllerProvider);
    final userId = auth is AuthSuccess ? auth.user?.id : null;
    if (userId == null) {
      AppToast.warning(context, '${l10n.reportSubmitted} ${l10n.signInAgain}');
      return;
    }

    try {
      final queue = await ref.read(evidenceUploadQueueProvider.future);
      final intents = await queue.enqueue(
        userId: userId,
        reportId: reportId,
        files: [File(picked.path)],
      );
      if (intents.single.state == EvidenceUploadState.missingLocalFile) {
        if (mounted) {
          AppToast.warning(context, l10n.evidenceFileMissing);
        }
        return;
      }
      unawaited(queue.resume(userId));
      if (mounted) {
        AppToast.success(context, l10n.evidenceUploadsPending(1));
      }
    } catch (_) {
      if (!mounted) return;
      AppToast.warning(context, l10n.evidenceUploadFailed);
    }
  }

  String? _submitDisabledReason(String description) {
    final l10n = AppLocalizations.of(context);
    final point = _selectedPoint;
    if (point == null || !_contains(point)) {
      if (_deviceLocationOutside &&
          _locationInputMode == _QuickLocationInputMode.phone) {
        return '${l10n.switchManualPin} ${l10n.selectIncidentInside(_selectedMunicipality.name)}';
      }
      if (_isLoadingLocation || _isGettingPreciseLocation) {
        return l10n.waitingIncidentLocation;
      }
      return _locationInputMode == _QuickLocationInputMode.manual
          ? l10n.tapMapIncident
          : l10n.chooseIncidentLocation;
    }
    if (widget.emergencyMode) {
      if (_selectedEmergencyCategory == null) {
        return l10n.emergencyCategoryRequired;
      }
      if (!_emergencyConfirmed) {
        return l10n.emergencyConfirmationRequired;
      }
      return null;
    }
    return quickReportDescriptionError(description, l10n: l10n);
  }

  Widget _buildEmergencyNotice(ThemeData theme) {
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    return Container(
      key: const Key('emergency-report-notice'),
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.error.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: scheme.onErrorContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.emergencyReportNotice,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onErrorContainer,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyCategory(ThemeData theme) {
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: DropdownButtonFormField<String>(
        key: const Key('emergency-report-category'),
        initialValue: _selectedEmergencyCategory?.key,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: l10n.emergencyIncidentType,
          prefixIcon: const Icon(Icons.category_outlined),
          helperText: _isLoadingEmergencyCategories
              ? l10n.loading
              : _emergencyCategoryError,
          helperStyle: TextStyle(color: scheme.onSurfaceVariant),
        ),
        items: _emergencyCategories
            .map(
              (option) => DropdownMenuItem<String>(
                value: option.key,
                child: Text(option.label),
              ),
            )
            .toList(),
        onChanged: _isSubmitting || _isLoadingEmergencyCategories
            ? null
            : (value) {
                if (value == null) return;
                setState(() {
                  _selectedEmergencyCategory = _emergencyCategories.firstWhere(
                    (option) => option.key == value,
                  );
                  _submissionError = null;
                });
              },
      ),
    );
  }

  Widget _buildEmergencyConfirmation(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: CheckboxListTile(
        key: const Key('emergency-report-confirmation'),
        value: _emergencyConfirmed,
        onChanged: _isSubmitting
            ? null
            : (value) => setState(() => _emergencyConfirmed = value ?? false),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
        title: Text(
          l10n.emergencyConfirm,
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.3),
        ),
      ),
    );
  }

  Widget _buildVerificationNotice(
    UserPermissions permissions,
    ThemeData theme,
  ) {
    if (permissions.isVerified) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      container: true,
      label: l10n.verificationNotice,
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
                l10n.verificationNotice,
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
    final l10n = AppLocalizations.of(context);
    final error = _locationError;
    if (error != null) {
      return Semantics(
        container: true,
        liveRegion: true,
        label: '${l10n.error}. $error',
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
            ? l10n.incidentLocationSelected
            : l10n.locationOutsideCity(_selectedMunicipality.name),
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
                              ? l10n.incidentLocationSelected
                              : l10n.locationOutsideCity(
                                  _selectedMunicipality.name,
                                ),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: foreground,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          manualSelected
                              ? l10n.phoneOutsideBoundary
                              : l10n.selectIncidentInside(
                                  _selectedMunicipality.name,
                                ),
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
                  label: Text(l10n.switchManualPin),
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
        ? l10n.locating
        : _locationInputMode == _QuickLocationInputMode.manual
        ? hasLocation
              ? l10n.incidentLocationSelected
              : l10n.tapMapPlaceIncident
        : hasLocation
        ? l10n.gpsLocationFound
        : l10n.chooseIncidentLocationShort;
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
    final l10n = AppLocalizations.of(context);
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
                    label: l10n.submissionError(submitError),
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
                    label: l10n.submitDisabled(disabledReason),
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
                      ? (widget.emergencyMode
                            ? l10n.submittingEmergencyReport
                            : l10n.submittingQuickReport)
                      : (widget.emergencyMode
                            ? l10n.submitEmergencyReport
                            : l10n.submitQuickReport),
                  hint: disabledReason,
                  child: ElevatedButton(
                    key: Key(
                      widget.emergencyMode
                          ? 'emergency-report-submit'
                          : 'quick-report-submit',
                    ),
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
                              Flexible(
                                child: Text(
                                  widget.emergencyMode
                                      ? l10n.submittingEmergencyReport
                                      : l10n.submittingQuickReport,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            widget.emergencyMode
                                ? l10n.submitEmergencyReport
                                : l10n.submitQuickReport,
                          ),
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
    final l10n = AppLocalizations.of(context);
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
        title: Text(
          widget.emergencyMode ? l10n.emergencyReport : l10n.quickReport,
        ),
        leading: IconButton(
          tooltip: widget.emergencyMode
              ? l10n.closeEmergencyReport
              : l10n.closeQuickReport,
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
                    if (widget.emergencyMode) ...[
                      _buildEmergencyNotice(theme),
                      _buildEmergencyCategory(theme),
                    ],
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.reportLocation,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (municipalities.length == 1)
                            Semantics(
                              label:
                                  '${_selectedMunicipality.name} ${l10n.cityBoundary}',
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
                                      '${_selectedMunicipality.name}, ${_selectedMunicipality.province} · ${l10n.cityBoundary}',
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
                              decoration: InputDecoration(
                                labelText: l10n.cityBoundary,
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
                            label: l10n.incidentLocationMethod,
                            child: SegmentedButton<_QuickLocationInputMode>(
                              key: const Key('quick-report-location-mode'),
                              expandedInsets: EdgeInsets.zero,
                              showSelectedIcon: false,
                              segments: [
                                ButtonSegment(
                                  value: _QuickLocationInputMode.phone,
                                  label: Text(l10n.phoneGps),
                                ),
                                ButtonSegment(
                                  value: _QuickLocationInputMode.manual,
                                  label: Text(l10n.manualPin),
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
                                label: l10n.incidentLocationMap,
                                hint:
                                    _locationInputMode ==
                                        _QuickLocationInputMode.manual
                                    ? l10n.tapInsideBoundary
                                    : l10n.showsDeviceLocations,
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
                                                    l10n.refreshDeviceLocation,
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
                                                tooltip: l10n.recenterCity,
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
                                        TextSpan(text: ' ${l10n.phoneGps}'),
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
                                        TextSpan(
                                          text:
                                              ' ${l10n.incidentLocationSelected}',
                                        ),
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
                                        TextSpan(text: ' ${l10n.cityBoundary}'),
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
                    if (widget.emergencyMode)
                      _buildEmergencyConfirmation(theme)
                    else ...[
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.shortDescription,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.shortDescriptionHint,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurface.withValues(alpha: 0.72),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Semantics(
                              container: true,
                              label: l10n.shortDescription,
                              hint: l10n.shortDescriptionSemantics,
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
                                decoration: InputDecoration(
                                  hintText: l10n.whatIsHappening,
                                  alignLabelWithHint: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
