import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/urdaneta_geo.dart';
import '../../../../core/maps/municipality_map.dart';
import '../../../../core/presentation/widgets/app_toast.dart';
import '../../../../core/providers/connectivity_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/municipality_geo.dart';
import '../../../../core/widget/widget_bridge.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/auth_di.dart';
import '../../../auth/data/auth_models.dart';
import '../../../auth/data/user_permissions.dart';
import '../../../auth/presentation/barangays_provider.dart';
import '../../../auth/presentation/auth_controller.dart';
import '../../../images/data/evidence_file_stager.dart';
import '../../../images/data/evidence_upload_queue.dart';
import '../../../images/data/evidence_upload_queue_provider.dart';
import '../../../help/data/help_content.dart';
import '../../../help/presentation/help_screens.dart';
import '../../data/report_draft_store.dart';
import '../../data/report_create_outbox.dart';
import '../../data/reports_repository.dart';
import '../../data/report_models.dart'
    hide LocationAccuracy, ReportCategory, ReportStatus;
import '../../domain/entities/report_enums.dart' hide LocationAccuracy;
import '../../reports_di.dart';
import '../reports_controller.dart';
import '../report_labels.dart';
import 'new_report_controller.dart';
import 'quick_report_geo.dart';
import 'report_draft_prompt.dart';
import 'report_flow_widgets.dart';

enum _QuickLocationInputMode { phone, manual }

enum _EmergencyFollowUpAction { details, photos, done }

/// Quick report flow: location + short description only.
class QuickReportScreen extends ConsumerStatefulWidget {
  const QuickReportScreen({
    super.key,
    this.locationOverride,
    this.showMapTiles = true,
    this.emergencyMode = false,
    this.fastReportMode = false,
    this.pickImage,
    this.pickMultiImage,
    this.launchCall,
  });

  @visibleForTesting
  final Future<Position> Function()? locationOverride;

  @visibleForTesting
  final bool showMapTiles;

  @visibleForTesting
  final bool emergencyMode;

  @visibleForTesting
  final bool fastReportMode;

  @visibleForTesting
  final Future<XFile?> Function(ImageSource source)? pickImage;

  @visibleForTesting
  final Future<List<XFile>> Function()? pickMultiImage;

  final Future<bool> Function(Uri uri)? launchCall;

  @override
  ConsumerState<QuickReportScreen> createState() => _QuickReportScreenState();
}

class _QuickReportScreenState extends ConsumerState<QuickReportScreen>
    with WidgetsBindingObserver {
  final MapController _mapController = MapController();
  final TextEditingController _descriptionController = TextEditingController();
  String _lastDescription = '';
  ReportCategoryOption? _selectedEmergencyCategory;
  List<ReportCategoryOption> _emergencyCategories = const [];
  bool _isLoadingEmergencyCategories = false;
  String? _emergencyCategoryError;
  final MunicipalityModel _selectedMunicipality = bundledUrdanetaMunicipality;

  bool _isSubmitting = false;
  bool _isLoadingLocation = false;
  bool _isGettingPreciseLocation = false;
  bool _emergencyConfirmed = false;
  bool _deviceLocationOutside = false;
  String? _locationError;
  String? _submissionError;
  Position? _currentPosition;
  LatLng? _selectedPoint;
  BarangayModel? _resolvedBarangay;
  bool _isResolvingBarangay = false;
  String? _resolvedLandmark;
  List<String> _nearbyLandmarkSuggestions = const [];
  bool _isResolvingLandmark = false;
  String? _landmarkLookupError;
  bool _landmarkLookupCompleted = false;
  int _locationResolutionVersion = 0;
  Timer? _landmarkLookupDebounce;
  _QuickLocationInputMode _locationInputMode = _QuickLocationInputMode.phone;
  bool _draftReady = false;
  bool _draftRestored = false;
  bool _canPersistDraft = true;
  bool _persistDraft = true;
  String? _draftOwnerId;
  String? _restoredEmergencyCategoryKey;
  ReportDraft? _draftRecord;
  Timer? _draftSaveTimer;
  late final ReportDraftStore _draftStore;
  late final ProviderSubscription<AuthState> _authSubscription;
  Future<void> _draftWriteTail = Future<void>.value();

  ReportDraftType get _draftType =>
      widget.emergencyMode ? ReportDraftType.emergency : ReportDraftType.quick;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _draftStore = ref.read(reportDraftStoreProvider);
    _draftOwnerId = _currentOwnerId();
    _authSubscription = ref.listenManual(authControllerProvider, (_, state) {
      final nextOwnerId = _ownerIdFor(state);
      if (_draftOwnerId != nextOwnerId) {
        _canPersistDraft = false;
        _draftSaveTimer?.cancel();
        if (_draftOwnerId != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _descriptionController.clear();
            _selectedPoint = null;
            _selectedEmergencyCategory = null;
            Navigator.of(context).popUntil((route) => route.isFirst);
          });
        }
      }
    });
    _descriptionController.addListener(_onQuickReportDescriptionChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_prepareDraft());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _draftSaveTimer?.cancel();
    _authSubscription.close();
    if (_draftReady && _persistDraft) {
      unawaited(_enqueueDraftSave(_captureDraftPayload()));
    }
    _landmarkLookupDebounce?.cancel();
    _descriptionController.removeListener(_onQuickReportDescriptionChanged);
    _mapController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      unawaited(_flushDraftSave());
    }
  }

  String? _currentOwnerId() => _ownerIdFor(ref.read(authControllerProvider));

  String? _ownerIdFor(AuthState state) =>
      state is AuthSuccess ? state.user?.id : null;

  Future<void> _prepareDraft() async {
    final ownerId = _draftOwnerId;
    final draft = ownerId == null
        ? null
        : await _draftStore.read(ownerId, _draftType);
    if (!mounted) return;
    if (ownerId != null &&
        (!_canPersistDraft || _currentOwnerId() != ownerId)) {
      Navigator.of(context).pop();
      return;
    }
    if (draft != null) {
      final action = await showReportDraftPrompt(context, draft: draft);
      if (!mounted) return;
      if (!_canPersistDraft || _currentOwnerId() != ownerId) {
        Navigator.of(context).pop();
        return;
      }
      if (action == ReportDraftAction.resume) {
        _draftRecord = draft;
        _restoreDraftPayload(draft);
        _draftRestored = true;
        _draftReady = true;
        await _enqueueDraftSave(_captureDraftPayload());
      } else if (action == ReportDraftAction.startNew) {
        await _draftStore.delete(ownerId!, _draftType);
        if (!mounted) return;
        if (!_canPersistDraft || _currentOwnerId() != ownerId) return;
        _draftRecord = null;
        _draftReady = true;
      } else if (action == ReportDraftAction.discard) {
        await _draftStore.delete(ownerId!, _draftType);
        if (!mounted) return;
        if (!_canPersistDraft || _currentOwnerId() != ownerId) return;
        _persistDraft = false;
        Navigator.of(context).pop();
        return;
      } else {
        _persistDraft = false;
        Navigator.of(context).pop();
        return;
      }
    } else {
      _draftReady = true;
    }

    if (!mounted) return;
    if (ownerId != null &&
        (!_canPersistDraft || _currentOwnerId() != ownerId)) {
      return;
    }
    setState(() {});
    if (widget.emergencyMode) _loadEmergencyCategories();
    if (_selectedPoint == null) _getCurrentLocation();
  }

  void _restoreDraftPayload(ReportDraft draft) {
    final description = draft.payload['description'];
    if (description is String) {
      _descriptionController.value = TextEditingValue(
        text: description,
        selection: TextSelection.collapsed(offset: description.length),
      );
    }
    final latitude = _draftDouble(draft.payload['latitude']);
    final longitude = _draftDouble(draft.payload['longitude']);
    if (latitude != null &&
        longitude != null &&
        latitude.isFinite &&
        longitude.isFinite) {
      final point = LatLng(latitude, longitude);
      if (_contains(point)) _selectedPoint = point;
    }
    final categoryKey = draft.payload['categoryKey'];
    _restoredEmergencyCategoryKey = categoryKey is String ? categoryKey : null;
    _emergencyConfirmed = false;
  }

  Map<String, Object?> _captureDraftPayload() => {
    'description': _descriptionController.text,
    'latitude': _selectedPoint?.latitude,
    'longitude': _selectedPoint?.longitude,
    if (widget.emergencyMode)
      'categoryKey':
          _selectedEmergencyCategory?.key ?? _restoredEmergencyCategoryKey,
  };

  bool _hasDraftContent(Map<String, Object?> payload) =>
      (payload['description'] as String? ?? '').trim().isNotEmpty ||
      payload['categoryKey'] != null;

  void _scheduleDraftSave() {
    if (!_draftReady || !_canPersistDraft || !_persistDraft) return;
    final payload = _captureDraftPayload();
    _draftSaveTimer?.cancel();
    _draftSaveTimer = Timer(
      const Duration(milliseconds: 300),
      () => unawaited(_enqueueDraftSave(payload)),
    );
  }

  Future<void> _flushDraftSave() async {
    _draftSaveTimer?.cancel();
    if (_draftReady) await _enqueueDraftSave(_captureDraftPayload());
  }

  Future<void> _enqueueDraftSave(Map<String, Object?> payload) {
    final operation = _draftWriteTail.then((_) => _writeDraftSnapshot(payload));
    _draftWriteTail = operation.catchError((_) {});
    return operation;
  }

  Future<void> _writeDraftSnapshot(Map<String, Object?> payload) async {
    final ownerId = _draftOwnerId;
    if (!_canPersistDraft || !_persistDraft || ownerId == null) return;
    final previous =
        await _draftStore.read(ownerId, _draftType) ?? _draftRecord;
    if (!_hasDraftContent(payload)) {
      if (previous != null) {
        await _draftStore.delete(ownerId, _draftType);
        _draftRecord = null;
      }
      return;
    }
    final now = DateTime.now().toUtc();
    final draft = ReportDraft(
      schemaVersion: ReportDraft.currentSchemaVersion,
      draftId: previous?.draftId ?? newReportLocalId(),
      ownerId: ownerId,
      type: _draftType,
      createdAt: previous?.createdAt ?? now,
      updatedAt: now,
      resumeStep: 'form',
      payload: payload,
      attachmentRefs: const [],
    );
    await _draftStore.write(draft);
    _draftRecord = draft;
  }

  Future<void> _completeDraft() async {
    _persistDraft = false;
    _draftSaveTimer?.cancel();
    final ownerId = _draftOwnerId;
    if (ownerId != null) {
      try {
        await _draftStore.delete(ownerId, _draftType);
      } catch (_) {
        // A successful server submit must not be reported as a failed submit.
      }
    }
    _draftRecord = null;
  }

  Future<ReportCreateOutboxItem> _submitOutboxSnapshot(
    Map<String, Object?> payload,
  ) async {
    await _flushDraftSave();
    final ownerId = _draftOwnerId ?? _currentOwnerId();
    if (ownerId == null || !_canPersistDraft || _currentOwnerId() != ownerId) {
      throw const ReportSubmissionFailure(
        'Sign in again to submit this report.',
      );
    }
    final draft = await _draftStore.read(ownerId, _draftType);
    return ref
        .read(reportCreateOutboxProvider)
        .submit(
          ownerId: ownerId,
          type: _draftType,
          payload: payload,
          sourceDraftId: draft?.draftId,
          sourceDraftUpdatedAt: draft?.updatedAt,
        );
  }

  Map<String, Object?> _quickSubmissionPayload({
    required String description,
    String? category,
    required bool emergency,
    bool includeLandmark = false,
  }) => {
    'category': category,
    'description': description,
    'isHappeningNow': true,
    'zone': _resolvedBarangay?.name,
    'streetLandmark': includeLandmark ? _resolvedLandmark : null,
    'municipalityId': _selectedMunicipality.id,
    'barangayId': _resolvedBarangay?.id,
    'cityMunicipality': _selectedMunicipality.name,
    'province': _selectedMunicipality.province,
    'latitude': _selectedPoint!.latitude.toStringAsFixed(10),
    'longitude': _selectedPoint!.longitude.toStringAsFixed(10),
    'locationAccuracy': 'exact',
    'location': null,
    'barangay': _resolvedBarangay?.name,
    'declarationConfirmed': true,
    'dataProcessingConsent': true,
    'isQuickReport': true,
    'isEmergency': emergency,
  };

  Future<void> _showPendingSync(
    ReportCreateOutboxItem item, {
    required bool emergency,
  }) async {
    _persistDraft = false;
    _draftSaveTimer?.cancel();
    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _submissionError = null;
    });
    ref.invalidate(reportCreateOutboxItemsProvider(item.ownerId));
    ref.read(myReportsRefreshProvider.notifier).increment();
    final l10n = AppLocalizations.of(context);
    if (emergency) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.emergencyNotYetTransmitted),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.emergencyCallGuidance),
                _emergencyHotlines(),
              ],
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.done),
            ),
          ],
        ),
      );
    } else {
      AppToast.info(context, l10n.reportPendingSync);
    }
    if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
  }

  double? _draftDouble(Object? value) => value is num
      ? value.toDouble()
      : double.tryParse(value?.toString() ?? '');

  bool _contains(LatLng point) => municipalityContains(
    _selectedMunicipality,
    point.latitude,
    point.longitude,
  );

  ThemeData _quickReportTheme(ThemeData theme) {
    final scheme = theme.colorScheme;
    final radius = BorderRadius.circular(16);
    final idleBorder = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide.none,
    );
    final focusBorder = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(
        color: scheme.primary.withValues(alpha: 0.72),
        width: 1.5,
      ),
    );
    final errorBorder = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: scheme.error.withValues(alpha: 0.78)),
    );
    return theme.copyWith(
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.62 : 0.76,
        ),
        border: idleBorder,
        enabledBorder: idleBorder,
        disabledBorder: idleBorder,
        focusedBorder: focusBorder,
        errorBorder: errorBorder,
        focusedErrorBorder: errorBorder,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  void _clearResolvedLocationMetadata() {
    _resolvedBarangay = null;
    _isResolvingBarangay = false;
    _resolvedLandmark = null;
    _nearbyLandmarkSuggestions = const [];
    _isResolvingLandmark = false;
    _landmarkLookupError = null;
    _landmarkLookupCompleted = false;
  }

  void _syncWidgetStatus(QuickReportWidgetStatus status) {
    if (!widget.emergencyMode) {
      unawaited(ref.read(widgetBridgeProvider).syncQuickReportStatus(status));
    }
  }

  void _onQuickReportDescriptionChanged() {
    final description = _descriptionController.text;
    if (description == _lastDescription) return;
    _lastDescription = description;
    _scheduleDraftSave();
  }

  void _setLandmarkLookupFailure() {
    setState(() {
      _isResolvingLandmark = false;
      _resolvedLandmark = null;
      _nearbyLandmarkSuggestions = const [];
      _landmarkLookupError = landmarkLookupUnavailable;
      _landmarkLookupCompleted = false;
    });
  }

  void _setSelectedPoint(LatLng point) {
    _landmarkLookupDebounce?.cancel();
    _landmarkLookupDebounce = null;
    final l10n = AppLocalizations.of(context);
    if (!_contains(point)) {
      _locationResolutionVersion++;
      setState(() {
        _selectedPoint = null;
        _clearResolvedLocationMetadata();
        _locationError = l10n.incidentPinInside(_selectedMunicipality.name);
      });
      _scheduleDraftSave();
      _syncWidgetStatus(QuickReportWidgetStatus.locationRequired);
      return;
    }

    final resolutionVersion = ++_locationResolutionVersion;
    final resolveLandmark = !widget.emergencyMode && !widget.fastReportMode;
    setState(() {
      _selectedPoint = point;
      _clearResolvedLocationMetadata();
      _isResolvingBarangay = true;
      _isResolvingLandmark = resolveLandmark;
      _locationError = null;
      _submissionError = null;
    });
    _scheduleDraftSave();
    _syncWidgetStatus(QuickReportWidgetStatus.ready);

    unawaited(_resolveBarangay(point, resolutionVersion));
    if (resolveLandmark) {
      _landmarkLookupDebounce = Timer(nearbyLandmarkDebounceDuration, () {
        _landmarkLookupDebounce = null;
        if (!_isCurrentResolution(point, resolutionVersion)) return;
        unawaited(_lookupNearbyLandmarks(point, resolutionVersion));
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _mapController.move(point, 15);
    });
  }

  void _onMapTap(LatLng point) {
    if (_locationInputMode != _QuickLocationInputMode.manual) return;

    _setSelectedPoint(point);
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
        _restoreEmergencyCategory();
        _isLoadingEmergencyCategories = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _emergencyCategories = offlineReportFormOptions.categories;
        _restoreEmergencyCategory();
        _isLoadingEmergencyCategories = false;
        _emergencyCategoryError = AppLocalizations.of(context).error;
      });
    }
  }

  void _restoreEmergencyCategory() {
    final key = _restoredEmergencyCategoryKey;
    if (key == null) return;
    for (final option in _emergencyCategories) {
      if (option.key == key) {
        _selectedEmergencyCategory = option;
        return;
      }
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
    if (_selectedPoint == null) {
      _syncWidgetStatus(QuickReportWidgetStatus.locationRequired);
    }

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
      final clearSelection =
          _locationInputMode == _QuickLocationInputMode.phone;
      if (clearSelection) _locationResolutionVersion++;
      setState(() {
        _currentPosition = position;
        _deviceLocationOutside = true;
        if (clearSelection) {
          _selectedPoint = null;
          _clearResolvedLocationMetadata();
        }
      });
      if (clearSelection) {
        _syncWidgetStatus(QuickReportWidgetStatus.locationRequired);
      }
      return;
    }

    if (_locationInputMode != _QuickLocationInputMode.phone) {
      setState(() {
        _currentPosition = position;
        _deviceLocationOutside = false;
      });
      return;
    }

    setState(() {
      _currentPosition = position;
      _deviceLocationOutside = false;
      _locationError = null;
    });

    _setSelectedPoint(point);
  }

  bool _isCurrentResolution(LatLng point, int version) {
    final selected = _selectedPoint;
    return mounted &&
        version == _locationResolutionVersion &&
        selected?.latitude == point.latitude &&
        selected?.longitude == point.longitude;
  }

  Future<void> _resolveBarangay(LatLng point, int version) async {
    BarangayModel? resolved;
    try {
      final barangays = await ref.read(
        municipalityBarangaysProvider(defaultMunicipalityId).future,
      );
      resolved = deriveNearestBarangay(
        barangays,
        latitude: point.latitude,
        longitude: point.longitude,
      );
    } catch (_) {
      resolved = null;
    }
    if (!_isCurrentResolution(point, version)) return;
    setState(() {
      _resolvedBarangay = resolved;
      _isResolvingBarangay = false;
    });
  }

  Future<void> _lookupNearbyLandmarks(LatLng point, int version) async {
    try {
      final result = await ref
          .read(authRepositoryProvider)
          .getNearbyLandmarks(
            latitude: point.latitude,
            longitude: point.longitude,
          );
      if (!_isCurrentResolution(point, version)) return;
      result.when(
        success: (landmarks) {
          final suggestion = suggestNearbyLandmark(landmarks);
          setState(() {
            _isResolvingLandmark = false;
            _resolvedLandmark = suggestion.prefill;
            _nearbyLandmarkSuggestions = suggestion.choices;
            _landmarkLookupError = null;
            _landmarkLookupCompleted = true;
          });
        },
        failure: (_) {
          _setLandmarkLookupFailure();
        },
      );
    } catch (_) {
      if (!_isCurrentResolution(point, version)) return;
      _setLandmarkLookupFailure();
    }
  }

  void _selectLandmarkSuggestion(String suggestion) {
    setState(() => _resolvedLandmark = suggestion);
  }

  Future<void> _submitQuickReport() async {
    if (_isSubmitting) return;
    if (widget.fastReportMode) {
      await _submitFastReport();
      return;
    }
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
      _syncWidgetStatus(QuickReportWidgetStatus.locationRequired);
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

    if (_isResolvingBarangay) {
      AppToast.warning(context, l10n.waitingIncidentLocation);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submissionError = null;
    });
    _syncWidgetStatus(QuickReportWidgetStatus.submitting);

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
          if (mounted) {
            setState(() => _isSubmitting = false);
            _syncWidgetStatus(QuickReportWidgetStatus.ready);
          }
          return;
        }
      }
    } catch (e) {
      debugPrint('Nearby report check unavailable: $e');
    }

    if (!mounted) return;

    late final String reportId;
    try {
      final item = await _submitOutboxSnapshot(
        _quickSubmissionPayload(
          description: description,
          emergency: false,
          includeLandmark: true,
        ),
      );
      if (item.status == ReportCreateOutboxStatus.rejected) {
        throw ReportSubmissionFailure(
          item.safeError ?? l10n.unableSubmitReport,
        );
      }
      if (item.status != ReportCreateOutboxStatus.synced) {
        _syncWidgetStatus(QuickReportWidgetStatus.networkUnavailable);
        await _showPendingSync(item, emergency: false);
        return;
      }
      final serverReportId = item.serverReportId;
      if (serverReportId == null) {
        throw ReportSubmissionFailure(l10n.unableSubmitReport);
      }
      reportId = serverReportId;
    } catch (e) {
      if (!mounted) return;
      final message = e is ReportSubmissionFailure
          ? e.message
          : l10n.unableSubmitReport;
      setState(() {
        _isSubmitting = false;
        _submissionError = message;
      });
      _syncWidgetStatus(
        ref.read(isOnlineProvider)
            ? QuickReportWidgetStatus.failed
            : QuickReportWidgetStatus.networkUnavailable,
      );
      AppToast.error(context, message);
      return;
    }

    if (!mounted) return;
    await _completeDraft();
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    _syncWidgetStatus(QuickReportWidgetStatus.submitted);
    ref.invalidate(reportsControllerProvider);
    ref.read(myReportsRefreshProvider.notifier).increment();

    await _offerPhotoUpload(reportId);
    if (!mounted) return;
    AppToast.success(context, l10n.reportSubmitted);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _submitFastReport() async {
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
    if (point == null || !_contains(point)) {
      _syncWidgetStatus(QuickReportWidgetStatus.locationRequired);
      AppToast.warning(context, l10n.chooseIncidentLocation);
      return;
    }
    if (_isResolvingBarangay) {
      AppToast.warning(context, l10n.waitingIncidentLocation);
      return;
    }
    setState(() {
      _isSubmitting = true;
      _submissionError = null;
    });
    _syncWidgetStatus(QuickReportWidgetStatus.submitting);

    try {
      final item = await _submitOutboxSnapshot(
        _quickSubmissionPayload(description: description, emergency: true),
      );
      if (item.status == ReportCreateOutboxStatus.rejected) {
        throw ReportSubmissionFailure(
          item.safeError ?? l10n.unableSubmitReport,
        );
      }
      if (item.status != ReportCreateOutboxStatus.synced) {
        _syncWidgetStatus(QuickReportWidgetStatus.networkUnavailable);
        await _showPendingSync(item, emergency: true);
        return;
      }
    } catch (error) {
      if (!mounted) return;
      final message = error is ReportSubmissionFailure
          ? error.message
          : l10n.unableSubmitReport;
      setState(() {
        _isSubmitting = false;
        _submissionError = message;
      });
      _syncWidgetStatus(
        ref.read(isOnlineProvider)
            ? QuickReportWidgetStatus.failed
            : QuickReportWidgetStatus.networkUnavailable,
      );
      AppToast.error(context, message);
      return;
    }

    if (!mounted) return;
    await _completeDraft();
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    _syncWidgetStatus(QuickReportWidgetStatus.submitted);
    ref.invalidate(reportsControllerProvider);
    ref.read(myReportsRefreshProvider.notifier).increment();
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

    if (_isResolvingBarangay) {
      AppToast.warning(context, l10n.waitingIncidentLocation);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submissionError = null;
    });

    try {
      final item = await _submitOutboxSnapshot(
        _quickSubmissionPayload(
          description: '',
          category: category.key,
          emergency: true,
        ),
      );
      if (item.status == ReportCreateOutboxStatus.rejected) {
        throw ReportSubmissionFailure(
          item.safeError ?? l10n.unableSubmitReport,
        );
      }
      if (item.status != ReportCreateOutboxStatus.synced) {
        await _showPendingSync(item, emergency: true);
        return;
      }
      final reportId = item.serverReportId;
      if (reportId == null) {
        throw ReportSubmissionFailure(l10n.unableSubmitReport);
      }
      if (!mounted) return;
      await _completeDraft();
      if (!mounted) return;
      ref.invalidate(reportsControllerProvider);
      ref.read(myReportsRefreshProvider.notifier).increment();
      setState(() => _isSubmitting = false);
      await _offerEmergencyFollowUp(reportId);
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _emergencyHotlines(),
              ListTile(
                leading: const Icon(Icons.notes_outlined),
                title: Text(l10n.addDetails),
                onTap: () => Navigator.pop(
                  sheetContext,
                  _EmergencyFollowUpAction.details,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.add_a_photo_outlined),
                title: Text(l10n.addPhotos),
                onTap: () => Navigator.pop(
                  sheetContext,
                  _EmergencyFollowUpAction.photos,
                ),
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
      ),
    );
    if (!mounted || action == null) return;
    switch (action) {
      case _EmergencyFollowUpAction.details:
        await _addEmergencyDetails(reportId);
      case _EmergencyFollowUpAction.photos:
        await _offerPhotoUpload(reportId);
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
    final selected = await showDialog<List<XFile>>(
      context: context,
      builder: (_) => _QuickReportEvidenceDialog(
        pickImage: _pickImage,
        pickMultiImage: _pickMultiImage,
      ),
    );
    if (!mounted || selected == null || selected.isEmpty) return;

    await _queuePhotos(reportId, selected);
  }

  Future<XFile?> _pickImage(ImageSource source) =>
      widget.pickImage?.call(source) ??
      ImagePicker().pickImage(source: source, imageQuality: 75);

  Future<List<XFile>> _pickMultiImage() =>
      widget.pickMultiImage?.call() ??
      ImagePicker().pickMultiImage(imageQuality: 75);

  Future<void> _queuePhotos(String reportId, List<XFile> picked) async {
    final l10n = AppLocalizations.of(context);
    final auth = ref.read(authControllerProvider);
    final userId = auth is AuthSuccess ? auth.user?.id : null;
    if (userId == null) {
      AppToast.warning(context, '${l10n.reportSubmitted} ${l10n.signInAgain}');
      return;
    }

    final staged = <File>[];
    var queueAccepted = false;
    try {
      for (final source in picked) {
        staged.add(await stageEvidenceFile(source));
      }
      if (!mounted) {
        await discardEvidenceDrafts(staged);
        return;
      }
      final queue = await ref.read(evidenceUploadQueueProvider.future);
      final intents = await queue.enqueue(
        userId: userId,
        reportId: reportId,
        files: staged,
      );
      if (intents.length != staged.length) {
        await discardEvidenceDrafts(staged);
        if (mounted) AppToast.warning(context, l10n.evidenceUploadFailed);
        return;
      }
      queueAccepted = true;
      if (intents.any(
        (intent) => intent.state == EvidenceUploadState.missingLocalFile,
      )) {
        if (mounted) {
          AppToast.warning(context, l10n.evidenceFileMissing);
        }
        return;
      }
      unawaited(queue.resume(userId));
      if (mounted) {
        AppToast.success(context, l10n.evidenceUploadsPending(picked.length));
      }
    } catch (_) {
      if (!queueAccepted) await discardEvidenceDrafts(staged);
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
    if (_isResolvingBarangay) {
      return l10n.waitingIncidentLocation;
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Material(
        key: const Key('emergency-report-notice'),
        color: scheme.errorContainer.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.42 : 0.78,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: scheme.error.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: scheme.onErrorContainer,
                  size: 20,
                ),
              ),
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
        ),
      ),
    );
  }

  Widget _emergencyHotlines() {
    final point = _selectedPoint;
    final distance = point == null
        ? null
        : _selectedMunicipality.boundary?.distanceToBoundaryMeters(
            point.latitude,
            point.longitude,
          );
    return Padding(
      padding: const EdgeInsets.all(16),
      child: EmergencyHotlineSection(
        hotlines: emergencyHotlines,
        launchCall: widget.launchCall,
        nearBoundary: distance != null && distance <= 500,
      ),
    );
  }

  Widget _buildEmergencyCategory(ThemeData theme) {
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Theme(
        data: _quickReportTheme(theme),
        child: DropdownButtonFormField<String>(
          key: const Key('emergency-report-category'),
          initialValue: _selectedEmergencyCategory?.key,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: l10n.emergencyIncidentType,
            prefixIcon: const Icon(Icons.category_outlined),
            helperText: _isLoadingEmergencyCategories
                ? l10n.loading
                : _emergencyCategoryError ?? l10n.requiredShort,
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
                    _selectedEmergencyCategory = _emergencyCategories
                        .firstWhere((option) => option.key == value);
                    _submissionError = null;
                  });
                  _scheduleDraftSave();
                },
        ),
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
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                l10n.emergencyConfirm,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.3),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              l10n.requiredShort,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Material(
          key: const Key('quick-report-verification-notice'),
          color: scheme.primary.withValues(
            alpha: theme.brightness == Brightness.dark ? 0.16 : 0.08,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.verified_user_outlined,
                    color: scheme.primary,
                    size: 20,
                  ),
                ),
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
        child: Material(
          key: const Key('quick-report-location-error'),
          color: scheme.errorContainer.withValues(
            alpha: theme.brightness == Brightness.dark ? 0.36 : 0.72,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: scheme.error.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    color: scheme.onErrorContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    error,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
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
        child: Material(
          key: const Key('quick-report-outside-location'),
          color: background.withValues(alpha: isDark ? 0.46 : 0.74),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: foreground.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.info_outline,
                        color: foreground,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
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
      elevation: theme.brightness == Brightness.dark ? 0 : 3,
      shadowColor: scheme.shadow.withValues(
        alpha: theme.brightness == Brightness.dark ? 0 : 0.12,
      ),
      surfaceTintColor: Colors.transparent,
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
                            : widget.fastReportMode
                            ? l10n.submittingFastReport
                            : l10n.submittingQuickReport)
                      : (widget.emergencyMode
                            ? l10n.submitEmergencyReport
                            : widget.fastReportMode
                            ? l10n.submitFastReport
                            : l10n.submitQuickReport),
                  hint: disabledReason,
                  child: ElevatedButton(
                    key: Key(
                      widget.emergencyMode
                          ? 'emergency-report-submit'
                          : widget.fastReportMode
                          ? 'fast-report-submit'
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
                                      : widget.fastReportMode
                                      ? l10n.submittingFastReport
                                      : l10n.submittingQuickReport,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            widget.emergencyMode
                                ? l10n.submitEmergencyReport
                                : widget.fastReportMode
                                ? l10n.submitFastReport
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

    if (!_draftReady) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.emergencyMode
                ? l10n.emergencyReport
                : widget.fastReportMode
                ? l10n.fastReport
                : l10n.quickReport,
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.emergencyMode
              ? l10n.emergencyReport
              : widget.fastReportMode
              ? l10n.fastReport
              : l10n.quickReport,
        ),
        leading: IconButton(
          tooltip: widget.emergencyMode
              ? l10n.closeEmergencyReport
              : widget.fastReportMode
              ? l10n.closeFastReport
              : l10n.closeQuickReport,
          icon: const Icon(Icons.close),
          onPressed: () async {
            await _flushDraftSave();
            if (context.mounted) Navigator.of(context).pop();
          },
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
                    ReportFlowProgress(step: 1, total: 1),
                    ReportFlowHeader(
                      title: widget.emergencyMode
                          ? l10n.emergencyReport
                          : widget.fastReportMode
                          ? l10n.fastReport
                          : l10n.quickReport,
                      guidance: widget.emergencyMode
                          ? l10n.chooseIncidentLocation
                          : widget.fastReportMode
                          ? l10n.fastReportGuidance
                          : l10n.selectLocationDescription,
                    ),
                    if (widget.emergencyMode) ...[
                      if (_draftRestored || !ref.watch(isOnlineProvider))
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: Text(
                            l10n.emergencyNotYetTransmitted,
                            key: const Key('emergency-draft-not-transmitted'),
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: scheme.error,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      _buildEmergencyNotice(theme),
                      _buildEmergencyCategory(theme),
                      _emergencyHotlines(),
                    ] else if (widget.fastReportMode) ...[
                      _buildEmergencyNotice(theme),
                      _emergencyHotlines(),
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
                          ReportReadOnlyLocationField(
                            key: const Key('quick-report-city'),
                            label: l10n.city,
                            value: UrdanetaGeo.displayCityName,
                            icon: Icons.location_city_outlined,
                          ),
                          const SizedBox(height: 10),
                          Semantics(
                            container: true,
                            label: l10n.incidentLocationMethod,
                            child: SegmentedButton<_QuickLocationInputMode>(
                              key: const Key('quick-report-location-mode'),
                              expandedInsets: EdgeInsets.zero,
                              showSelectedIcon: false,
                              style: ButtonStyle(
                                side: WidgetStateProperty.all(BorderSide.none),
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                backgroundColor:
                                    WidgetStateProperty.resolveWith((states) {
                                      if (states.contains(
                                        WidgetState.selected,
                                      )) {
                                        return scheme.primaryContainer;
                                      }
                                      return scheme.surfaceContainerHighest
                                          .withValues(
                                            alpha:
                                                theme.brightness ==
                                                    Brightness.dark
                                                ? 0.68
                                                : 0.72,
                                          );
                                    }),
                                foregroundColor:
                                    WidgetStateProperty.resolveWith((states) {
                                      if (states.contains(
                                        WidgetState.selected,
                                      )) {
                                        return scheme.onPrimaryContainer;
                                      }
                                      return scheme.onSurface;
                                    }),
                                padding: WidgetStateProperty.all(
                                  const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                ),
                              ),
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
                      child: Material(
                        key: const Key('quick-report-location-card'),
                        color: scheme.surfaceContainerLow,
                        elevation: theme.brightness == Brightness.dark ? 0 : 2,
                        shadowColor: scheme.shadow.withValues(
                          alpha: theme.brightness == Brightness.dark ? 0 : 0.12,
                        ),
                        surfaceTintColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
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
                                    borderRadius: BorderRadius.circular(16),
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
                              if (!widget.emergencyMode &&
                                  !widget.fastReportMode &&
                                  _selectedPoint != null) ...[
                                const SizedBox(height: 12),
                                ReportLocationSummary(
                                  city: UrdanetaGeo.displayCityName,
                                  showCity: false,
                                  barangay: _resolvedBarangay?.name,
                                  isResolvingBarangay: _isResolvingBarangay,
                                  landmark: _resolvedLandmark,
                                  isResolvingLandmark: _isResolvingLandmark,
                                  landmarkLookupError: _landmarkLookupError,
                                  landmarkLookupCompleted:
                                      _landmarkLookupCompleted,
                                  landmarkSuggestions:
                                      _nearbyLandmarkSuggestions,
                                  onLandmarkSelected: _selectLandmarkSuggestion,
                                  coordinates:
                                      '${_selectedPoint!.latitude.toStringAsFixed(6)}, ${_selectedPoint!.longitude.toStringAsFixed(6)}',
                                ),
                              ],
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
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    l10n.shortDescription,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                Text(
                                  l10n.requiredShort,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: scheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
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
                              child: Theme(
                                data: _quickReportTheme(theme),
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

class _QuickReportEvidenceDialog extends StatefulWidget {
  const _QuickReportEvidenceDialog({
    required this.pickImage,
    required this.pickMultiImage,
  });

  final Future<XFile?> Function(ImageSource source) pickImage;
  final Future<List<XFile>> Function() pickMultiImage;

  @override
  State<_QuickReportEvidenceDialog> createState() =>
      _QuickReportEvidenceDialogState();
}

class _QuickReportEvidenceDialogState
    extends State<_QuickReportEvidenceDialog> {
  final List<XFile> _selected = [];
  bool _isPicking = false;
  String? _error;

  Future<void> _addFromCamera() async {
    if (_isPicking) return;
    setState(() {
      _isPicking = true;
      _error = null;
    });
    try {
      final picked = await widget.pickImage(ImageSource.camera);
      if (!mounted || picked == null) return;
      setState(() => _selected.add(picked));
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = AppLocalizations.of(context).evidenceUploadFailed,
        );
      }
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  Future<void> _addFromGallery() async {
    if (_isPicking) return;
    setState(() {
      _isPicking = true;
      _error = null;
    });
    try {
      final picked = await widget.pickMultiImage();
      if (!mounted || picked.isEmpty) return;
      setState(() => _selected.addAll(picked));
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = AppLocalizations.of(context).evidenceUploadFailed,
        );
      }
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return AlertDialog(
      title: Text(l10n.reportSubmitted),
      content: SizedBox(
        width: 420,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 390),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.photoEvidenceSelectionHint),
                const SizedBox(height: 14),
                if (_selected.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest.withValues(
                        alpha: theme.brightness == Brightness.dark
                            ? 0.52
                            : 0.72,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(l10n.noPhotosYet)),
                      ],
                    ),
                  )
                else ...[
                  Text(
                    l10n.selectedPhotoCount(_selected.length),
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: _selected.length,
                    itemBuilder: (context, index) {
                      final photo = _selected[index];
                      return Semantics(
                        container: true,
                        image: true,
                        label: '${l10n.photos} ${index + 1}',
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(photo.path),
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => ColoredBox(
                                  color: scheme.surfaceContainerHighest,
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: IconButton.filledTonal(
                                key: Key('quick-report-evidence-remove-$index'),
                                tooltip: l10n.removePhoto,
                                icon: const Icon(Icons.close),
                                onPressed: () =>
                                    setState(() => _selected.removeAt(index)),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Semantics(
                    liveRegion: true,
                    child: Text(_error!, style: TextStyle(color: scheme.error)),
                  ),
                ],
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final buttonStyle = FilledButton.styleFrom(
                      minimumSize: const Size(0, 52),
                      padding: EdgeInsets.symmetric(
                        horizontal: constraints.maxWidth < 300 ? 8 : 12,
                        vertical: 14,
                      ),
                    );
                    final camera = FilledButton.tonalIcon(
                      key: const Key('quick-report-evidence-camera'),
                      onPressed: _isPicking ? null : _addFromCamera,
                      style: buttonStyle,
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: Text(l10n.camera, maxLines: 1),
                    );
                    final gallery = FilledButton.tonalIcon(
                      key: const Key('quick-report-evidence-gallery'),
                      onPressed: _isPicking ? null : _addFromGallery,
                      style: buttonStyle,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: Text(l10n.gallery, maxLines: 1),
                    );

                    if (constraints.maxWidth < 260) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [camera, const SizedBox(height: 8), gallery],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: camera),
                        const SizedBox(width: 8),
                        Expanded(child: gallery),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          key: const Key('quick-report-evidence-skip'),
          onPressed: _isPicking ? null : () => Navigator.pop(context),
          child: Text(l10n.skipPhotoEvidence),
        ),
        FilledButton.icon(
          key: const Key('quick-report-upload-evidence'),
          onPressed: _selected.isEmpty || _isPicking
              ? null
              : () =>
                    Navigator.pop(context, List<XFile>.unmodifiable(_selected)),
          icon: const Icon(Icons.cloud_upload_outlined),
          label: Text(l10n.uploadEvidence),
        ),
      ],
    );
  }
}
