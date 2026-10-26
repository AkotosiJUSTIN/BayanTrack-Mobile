import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/maps/municipality_map.dart';
import '../../../../core/presentation/failure_message.dart';
import '../../../../core/presentation/widgets/app_toast.dart';
import '../../../../core/providers/connectivity_provider.dart';
import '../../../../core/utils/municipality_geo.dart';
import '../../../../core/widget/widget_bridge.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/data/auth_models.dart';
import '../../../auth/data/user_permissions.dart';
import '../../../auth/presentation/barangays_provider.dart';
import '../../../auth/presentation/auth_controller.dart';
import '../../../images/data/evidence_file_stager.dart';
import '../../../images/presentation/evidence_photo_review.dart';
import '../../../images/data/evidence_upload_queue.dart';
import '../../../images/data/evidence_upload_queue_provider.dart';
import '../../../help/data/help_content.dart';
import '../../../help/presentation/help_screens.dart';
import '../../data/report_draft_store.dart';
import '../../data/report_create_outbox.dart';
import '../../data/reports_repository.dart';
import '../../reports_di.dart';
import '../reports_controller.dart';
import 'new_report_controller.dart';
import 'quick_report_geo.dart';
import 'report_draft_prompt.dart';
import 'report_flow_widgets.dart';

import '../../data/emergency_catalog.dart';

enum _QuickLocationInputMode { phone, manual }

enum _EmergencyFollowUpAction { details, photos, done }

/// One structured emergency flow for app navigation, governance, and widgets.
class EmergencyReportScreen extends ConsumerStatefulWidget {
  const EmergencyReportScreen({
    super.key,
    this.locationOverride,
    this.showMapTiles = true,
    this.pickImage,
    this.pickMultiImage,
    this.launchCall,
    this.resumeDraftType,
  });
  final Future<Position> Function()? locationOverride;
  final bool showMapTiles;
  final Future<XFile?> Function(ImageSource source)? pickImage;
  final Future<List<XFile>> Function()? pickMultiImage;
  final Future<bool> Function(Uri uri)? launchCall;
  final ReportDraftType? resumeDraftType;
  @override
  ConsumerState<EmergencyReportScreen> createState() =>
      _EmergencyReportScreenState();
}

/// Compatibility for existing callers. All modes now open Emergency Report.
@Deprecated('Use EmergencyReportScreen')
class QuickReportScreen extends EmergencyReportScreen {
  const QuickReportScreen({
    super.key,
    super.locationOverride,
    super.showMapTiles,
    super.pickImage,
    super.pickMultiImage,
    super.launchCall,
    bool emergencyMode = false,
    bool fastReportMode = false,
  });
}

class _EmergencyReportScreenState extends ConsumerState<EmergencyReportScreen>
    with WidgetsBindingObserver {
  final MapController _mapController = MapController();
  final TextEditingController _descriptionController = TextEditingController();
  String _lastDescription = '';
  EmergencyCatalog? _catalog;
  EmergencyType? _selectedType;
  EmergencySituation? _selectedSituation;
  String? _danger;
  String? _restoredTypeKey;
  String? _restoredSituationKey;
  bool _legacyDraft = false;
  bool _showLocationMap = false;
  bool _showNotes = false;
  final MunicipalityModel _selectedMunicipality = bundledUrdanetaMunicipality;
  bool _isSubmitting = false;
  bool _isLoadingLocation = false;
  bool _isGettingPreciseLocation = false;
  bool _deviceLocationOutside = false;
  String? _locationError;
  String? _submissionError;
  Position? _currentPosition;
  LatLng? _selectedPoint;
  BarangayModel? _resolvedBarangay;
  bool _isResolvingBarangay = false;
  int _locationResolutionVersion = 0;
  _QuickLocationInputMode _locationInputMode = _QuickLocationInputMode.phone;
  bool _draftReady = false;
  bool _draftRestored = false;
  bool _canPersistDraft = true;
  bool _persistDraft = true;
  String? _draftOwnerId;
  ReportDraft? _draftRecord;
  Timer? _draftSaveTimer;
  late final ReportDraftStore _draftStore;
  late final ProviderSubscription<AuthState> _authSubscription;
  Future<void> _draftWriteTail = Future<void>.value();
  ReportDraftType _draftStorageType = ReportDraftType.emergency;
  ReportDraftType get _draftType => _draftStorageType;
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
            _selectedType = null;
            _selectedSituation = null;
            _danger = null;
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
        : await _draftStore.read(
                ownerId,
                widget.resumeDraftType ?? _draftType,
              ) ??
              await _draftStore.read(ownerId, ReportDraftType.emergency) ??
              await _draftStore.read(ownerId, ReportDraftType.quick);
    if (!mounted) return;
    if (ownerId != null &&
        (!_canPersistDraft || _currentOwnerId() != ownerId)) {
      Navigator.of(context).pop();
      return;
    }
    if (draft != null) {
      // An explicitly resumed legacy slot must never overwrite another draft.
      _draftStorageType = draft.type;
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
        if (!await _discardSavedDraft(draft)) return;
        if (!mounted) return;
        if (!_canPersistDraft || _currentOwnerId() != ownerId) return;
        _draftRecord = null;
        _draftReady = true;
      } else if (action == ReportDraftAction.discard) {
        if (!await _discardSavedDraft(draft)) return;
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
    unawaited(_loadCatalog());
    if (_selectedPoint == null) {
      _getCurrentLocation();
    } else {
      _setSelectedPoint(_selectedPoint!);
    }
  }

  void _restoreDraftPayload(ReportDraft draft) {
    _legacyDraft =
        draft.payload['legacyDraft'] == true ||
        draft.payload['emergencyFormVersion'] != 1 &&
            draft.payload['emergencyContext'] == null;
    _draftStorageType = draft.type;
    final originalContext = draft.payload['emergencyContext'];
    final description = originalContext is Map
        ? originalContext['notes'] ?? ''
        : draft.payload['notes'] ?? draft.payload['description'];
    if (description is String) {
      _descriptionController.text = description;
    }
    if (draft.payload['legacyDescription'] is String &&
        _descriptionController.text.isEmpty) {
      _descriptionController.text =
          draft.payload['legacyDescription'] as String;
    }
    final latitude = _draftDouble(draft.payload['latitude']);
    final longitude = _draftDouble(draft.payload['longitude']);
    if (latitude != null &&
        longitude != null &&
        latitude.isFinite &&
        longitude.isFinite) {
      final point = LatLng(latitude, longitude);
      if (_contains(point)) {
        _selectedPoint = point;
        _locationInputMode = _QuickLocationInputMode.manual;
      }
    }
    if (!_legacyDraft) {
      final context = draft.payload['emergencyContext'];
      _restoredTypeKey =
          (context is Map ? context['type_key'] : draft.payload['typeKey'])
              as String?;
      _restoredSituationKey =
          (context is Map
                  ? context['situation_key']
                  : draft.payload['situationKey'])
              as String?;
      _danger =
          (context is Map
                  ? context['immediate_danger']
                  : draft.payload['danger'])
              as String?;
      if (!['yes', 'no', 'unknown'].contains(_danger)) _danger = null;
      if (context is Map && context['notes'] is String) {
        _descriptionController.text = context['notes'] as String;
      }
    }
    _showNotes = _descriptionController.text.isNotEmpty;
  }

  Future<bool> _discardSavedDraft(ReportDraft draft) async {
    try {
      await ref.read(reportCreateOutboxProvider).discardDraft(draft);
      return true;
    } catch (_) {
      if (mounted) {
        AppToast.warning(
          context,
          AppLocalizations.of(context).reportOutboxRetrying,
        );
        _persistDraft = false;
        Navigator.of(context).pop();
      }
      return false;
    }
  }

  Map<String, Object?> _captureDraftPayload() => {
    'emergencyFormVersion': 1,
    'legacyDraft': _legacyDraft,
    'notes': _descriptionController.text,
    'description': _descriptionController.text,
    'latitude': _selectedPoint?.latitude,
    'longitude': _selectedPoint?.longitude,
    'typeKey': _selectedType?.key ?? _restoredTypeKey,
    'situationKey': _selectedSituation?.key ?? _restoredSituationKey,
    'danger': _danger,
  };
  bool _hasDraftContent(Map<String, Object?> payload) =>
      (payload['notes'] as String? ?? '').trim().isNotEmpty ||
      payload['typeKey'] != null ||
      payload['legacyDraft'] == true;

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

  Map<String, Object?> _submissionPayload() {
    final type = _selectedType!;
    final situation = _selectedSituation!;
    final notes = _descriptionController.text.trim();
    final summary = emergencySummary(type, situation, _danger!, notes);
    return {
      // Local metadata is retained for the outbox. The API derives these fields.
      'category': type.categoryKey,
      'incidentType': type.key,
      'title': '${type.label}: ${situation.label}',
      'description': summary,
      'emergencyContext': emergencyContext(
        type: type,
        situation: situation,
        danger: _danger!,
        notes: notes,
      ),
      'isHappeningNow': true,
      'municipalityId': _selectedMunicipality.id,
      'barangayId': _resolvedBarangay?.id,
      'zone': _resolvedBarangay?.name,
      'barangay': _resolvedBarangay?.name,
      'cityMunicipality': _selectedMunicipality.name,
      'province': _selectedMunicipality.province,
      'latitude': _selectedPoint!.latitude.toStringAsFixed(10),
      'longitude': _selectedPoint!.longitude.toStringAsFixed(10),
      'locationAccuracy': 'exact',
      'declarationConfirmed': true,
      'dataProcessingConsent': true,
      'isQuickReport': true,
      'isEmergency': true,
    };
  }

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

  void _clearResolvedLocationMetadata() {
    _resolvedBarangay = null;
    _isResolvingBarangay = false;
  }

  void _syncWidgetStatus(QuickReportWidgetStatus status) {
    unawaited(ref.read(widgetBridgeProvider).syncQuickReportStatus(status));
  }

  void _onQuickReportDescriptionChanged() {
    if (_descriptionController.text == _lastDescription) return;
    _lastDescription = _descriptionController.text;
    setState(() => _submissionError = null);
    _scheduleDraftSave();
  }

  void _setSelectedPoint(LatLng point) {
    final l10n = AppLocalizations.of(context);
    final version = ++_locationResolutionVersion;
    setState(() {
      _selectedPoint = _contains(point) ? point : null;
      _clearResolvedLocationMetadata();
      _isResolvingBarangay = _selectedPoint != null;
      _locationError = _selectedPoint == null
          ? l10n.incidentPinInside(_selectedMunicipality.name)
          : null;
      _submissionError = null;
    });
    _scheduleDraftSave();
    _syncWidgetStatus(
      _selectedPoint == null
          ? QuickReportWidgetStatus.locationRequired
          : QuickReportWidgetStatus.ready,
    );
    if (_selectedPoint != null) unawaited(_resolveBarangay(point, version));
    if (_showLocationMap) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _showLocationMap) _mapController.move(point, 15);
      });
    }
  }

  Future<void> _loadCatalog() async {
    final bundled = await EmergencyCatalog.bundled();
    if (!mounted) return;
    _applyCatalog(bundled);
    try {
      final options = await ref
          .read(reportsRepositoryProvider)
          .getFormOptions();
      if (!mounted || options.emergencyCatalog == null) return;
      _applyCatalog(EmergencyCatalog.fromJson(options.emergencyCatalog!));
    } catch (_) {
      // The unchanged shared v1 asset supports offline reporting.
    }
  }

  void _applyCatalog(EmergencyCatalog catalog) {
    final typeKey = _selectedType?.key ?? _restoredTypeKey;
    final savedSituationKey = _selectedSituation?.key ?? _restoredSituationKey;
    final situationKey = savedSituationKey == 'not_sure'
        ? 'other_unknown'
        : savedSituationKey;
    setState(() {
      _catalog = catalog;
      _selectedType = null;
      _selectedSituation = null;
      for (final type in catalog.types) {
        if (type.key != typeKey) continue;
        _selectedType = type;
        for (final situation in type.situations) {
          if (situation.key == situationKey) _selectedSituation = situation;
        }
      }
    });
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
          _locationError = l10n.locationUnavailable;
        });
      }
      return;
    }

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          _locationError = l10n.locationServicesDisabled;
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
            _locationError = l10n.locationPermissionDenied;
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _locationError = l10n.locationPermissionSettings;
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
        _locationError = l10n.locationUnavailable;
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
          _locationError = l10n.locationRequestTimedOut;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isGettingPreciseLocation = false;
        _isLoadingLocation = false;
        if (_currentPosition == null) {
          _locationError = l10n.locationUnavailable;
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

  Future<void> _submitEmergencyReport() async {
    if (_isSubmitting) return;
    final l10n = AppLocalizations.of(context);
    if (_submitDisabledReason() != null) return;
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

    _syncWidgetStatus(QuickReportWidgetStatus.submitting);
    try {
      final item = await _submitOutboxSnapshot(_submissionPayload());
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
      _syncWidgetStatus(QuickReportWidgetStatus.submitted);
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
      _syncWidgetStatus(QuickReportWidgetStatus.failed);
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
    final current = await ref.read(getReportUseCaseProvider)(reportId);
    if (!mounted) return;
    String? original;
    current.when(
      success: (report) {
        if (!report.isStale) original = report.description;
      },
      failure: (_) {},
    );
    if (original == null) {
      AppToast.warning(context, l10n.unableSubmitReport);
      return;
    }
    final remaining = emergencyDetailsRemaining(original!);
    if (remaining == 0) {
      AppToast.info(context, l10n.emergencyDetailsFull);
      return;
    }
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
          maxLength: remaining,
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
    unawaited(
      Future<void>.delayed(kThemeAnimationDuration, controller.dispose),
    );
    if (!mounted || details == null) return;

    try {
      final result = await ref.read(updateReportUseCaseProvider)(
        id: reportId,
        description: appendEmergencyDetails(original!, details),
      );
      if (!mounted) return;
      result.when(
        success: (_) => AppToast.success(context, l10n.detailsSaved),
        failure: (failure) => AppToast.warning(
          context,
          localizedFailureMessage(
            failure,
            l10n,
            fallback: l10n.unableSubmitReport,
          ),
        ),
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
        sensitive: true,
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
        isEmergency: true,
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

  String? _submitDisabledReason() {
    final l10n = AppLocalizations.of(context);
    if (_selectedType == null ||
        _selectedSituation == null ||
        _danger == null) {
      return l10n.emergencySelectionsRequired;
    }
    if (_descriptionController.text.trim().runes.length > 300) {
      return l10n.emergencyNotesLimit;
    }
    final point = _selectedPoint;
    if (point == null || !_contains(point)) return l10n.chooseIncidentLocation;
    if (_isResolvingBarangay ||
        _isLoadingLocation ||
        _isGettingPreciseLocation) {
      return l10n.waitingIncidentLocation;
    }
    return null;
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

  Widget _choices(String label, List<Widget> children) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: children),
      ],
    ),
  );

  Widget _locationCard() {
    final l10n = AppLocalizations.of(context);
    final point = _selectedPoint;
    final center =
        point ??
        LatLng(
          _selectedMunicipality.centerLat!,
          _selectedMunicipality.centerLng!,
        );
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.reportLocation,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Semantics(
                liveRegion: true,
                child: Text(
                  _isLoadingLocation || _isGettingPreciseLocation
                      ? l10n.gettingLocation
                      : point == null
                      ? (_deviceLocationOutside
                            ? l10n.incidentPinInside(_selectedMunicipality.name)
                            : l10n.chooseIncidentLocation)
                      : '${_resolvedBarangay?.name ?? _selectedMunicipality.name} · ${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}',
                  key: const Key('emergency-location-summary'),
                ),
              ),
              if (_locationError != null)
                Text(
                  _locationError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              Wrap(
                spacing: 8,
                children: [
                  TextButton.icon(
                    key: const Key('emergency-change-location'),
                    onPressed: _isSubmitting
                        ? null
                        : () => setState(() {
                            _showLocationMap = !_showLocationMap;
                            _locationInputMode = _QuickLocationInputMode.manual;
                          }),
                    icon: const Icon(Icons.edit_location_alt_outlined),
                    label: Text(l10n.emergencyChangeLocation),
                  ),
                  TextButton.icon(
                    key: const Key('quick-report-refresh-location'),
                    onPressed: _isSubmitting || _isLoadingLocation
                        ? null
                        : () {
                            _locationInputMode = _QuickLocationInputMode.phone;
                            _getCurrentLocation();
                          },
                    icon: const Icon(Icons.my_location),
                    label: Text(l10n.phoneGps),
                  ),
                ],
              ),
              if (_showLocationMap) ...[
                Text(l10n.tapInsideBoundary),
                const SizedBox(height: 8),
                Semantics(
                  label: l10n.incidentLocationMap,
                  hint: l10n.tapInsideBoundary,
                  child: SizedBox(
                    height: 240,
                    child: FlutterMap(
                      key: const Key('quick-report-map'),
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: center,
                        initialZoom: 15,
                        minZoom: 12,
                        maxZoom: 18,
                        cameraConstraint:
                            MunicipalityMapCamera.constraintFor(
                              _selectedMunicipality,
                            ) ??
                            const CameraConstraint.unconstrained(),
                        onTap: (_, point) {
                          if (!_isSubmitting) _setSelectedPoint(point);
                        },
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
                          boundary: _selectedMunicipality.boundary,
                        ),
                        MarkerLayer(
                          markers: [
                            if (point != null)
                              Marker(
                                point: point,
                                width: 48,
                                height: 48,
                                child: Icon(
                                  Icons.location_pin,
                                  size: 44,
                                  color: Theme.of(context).colorScheme.error,
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
                  ),
                ),
                // Accessible map alternative: coordinates can be adjusted with a keyboard.
                OutlinedButton.icon(
                  onPressed: _isSubmitting ? null : _editCoordinates,
                  icon: const Icon(Icons.pin_drop_outlined),
                  label: Text(l10n.emergencyEnterCoordinates),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editCoordinates() async {
    final l10n = AppLocalizations.of(context);
    final latitude = TextEditingController(
      text: _selectedPoint?.latitude.toString() ?? '',
    );
    final longitude = TextEditingController(
      text: _selectedPoint?.longitude.toString() ?? '',
    );
    final point = await showDialog<LatLng>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.emergencyEnterCoordinates),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: const Key('emergency-latitude'),
                controller: latitude,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: InputDecoration(labelText: l10n.latitude),
              ),
              TextField(
                key: const Key('emergency-longitude'),
                controller: longitude,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: InputDecoration(labelText: l10n.longitude),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final lat = double.tryParse(latitude.text);
              final lng = double.tryParse(longitude.text);
              if (lat != null &&
                  lng != null &&
                  lat.isFinite &&
                  lng.isFinite &&
                  lat.abs() <= 90 &&
                  lng.abs() <= 180) {
                Navigator.pop(dialogContext, LatLng(lat, lng));
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    unawaited(
      Future<void>.delayed(kThemeAnimationDuration, () {
        latitude.dispose();
        longitude.dispose();
      }),
    );
    if (mounted && point != null) _setSelectedPoint(point);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final filipino = Localizations.localeOf(context).languageCode == 'fil';
    final reason = _submitDisabledReason();
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.emergencyReport),
        leading: IconButton(
          tooltip: l10n.closeEmergencyReport,
          icon: const Icon(Icons.close),
          onPressed: _isSubmitting
              ? null
              : () async {
                  await _flushDraftSave();
                  if (context.mounted) Navigator.pop(context);
                },
        ),
      ),
      body: !_draftReady
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              top: false,
              child: SingleChildScrollView(
                key: const Key('emergency-report-form'),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildVerificationNotice(
                      ref.watch(userPermissionsProvider),
                      theme,
                    ),
                    ReportFlowHeader(
                      title: l10n.emergencyReport,
                      guidance: l10n.emergencyStructuredGuidance,
                    ),
                    if (_draftRestored || !ref.watch(isOnlineProvider))
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          l10n.emergencyNotYetTransmitted,
                          key: const Key('emergency-draft-not-transmitted'),
                        ),
                      ),
                    if (_legacyDraft)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          l10n.emergencyLegacyDraftNotice,
                          key: const Key('emergency-legacy-draft-notice'),
                        ),
                      ),
                    _buildEmergencyNotice(theme),
                    if (_catalog == null)
                      const Center(child: CircularProgressIndicator())
                    else
                      _choices(l10n.emergencyIncidentType, [
                        for (final type in _catalog!.types)
                          ChoiceChip(
                            key: Key('emergency-type-${type.key}'),
                            label: Text(type.localized(filipino)),
                            selected: _selectedType?.key == type.key,
                            onSelected: _isSubmitting
                                ? null
                                : (_) {
                                    if (_selectedType?.key == type.key) return;
                                    setState(() {
                                      _selectedType = type;
                                      _restoredTypeKey = type.key;
                                      _selectedSituation = null;
                                      _restoredSituationKey = null;
                                      _submissionError = null;
                                    });
                                    _scheduleDraftSave();
                                  },
                          ),
                      ]),
                    if (_selectedType != null)
                      _choices(l10n.emergencySituation, [
                        for (final situation in _selectedType!.situations)
                          ChoiceChip(
                            key: Key('emergency-situation-${situation.key}'),
                            label: Text(situation.localized(filipino)),
                            selected: _selectedSituation?.key == situation.key,
                            onSelected: _isSubmitting
                                ? null
                                : (_) {
                                    setState(() {
                                      _selectedSituation = situation;
                                      _restoredSituationKey = situation.key;
                                      _submissionError = null;
                                    });
                                    _scheduleDraftSave();
                                  },
                          ),
                      ]),
                    _choices(l10n.emergencyDangerQuestion, [
                      for (final entry in {
                        'yes': l10n.yes,
                        'no': l10n.no,
                        'unknown': l10n.emergencyNotSure,
                      }.entries)
                        ChoiceChip(
                          key: Key('emergency-danger-${entry.key}'),
                          label: Text(entry.value),
                          selected: _danger == entry.key,
                          onSelected: _isSubmitting
                              ? null
                              : (_) {
                                  setState(() {
                                    _danger = entry.key;
                                    _submissionError = null;
                                  });
                                  _scheduleDraftSave();
                                },
                        ),
                    ]),
                    _locationCard(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          key: const Key('emergency-toggle-notes'),
                          onPressed: _isSubmitting
                              ? null
                              : () => setState(() => _showNotes = !_showNotes),
                          icon: Icon(
                            _showNotes ? Icons.expand_less : Icons.add,
                          ),
                          label: Text(l10n.emergencyOptionalNotes),
                        ),
                      ),
                    ),
                    if (_showNotes)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          key: const Key('emergency-report-notes'),
                          controller: _descriptionController,
                          enabled: !_isSubmitting,
                          minLines: _legacyDraft ? 4 : 2,
                          maxLines: _legacyDraft ? 8 : 4,
                          maxLength: 300,
                          maxLengthEnforcement: MaxLengthEnforcement.none,
                          decoration: InputDecoration(
                            labelText: l10n.emergencyOptionalNotes,
                            hintText: l10n.emergencyOptionalNotesHint,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_submissionError != null)
                            Semantics(
                              liveRegion: true,
                              child: Text(
                                _submissionError!,
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ),
                          if (!_isSubmitting && reason != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                reason,
                                key: const Key(
                                  'emergency-report-disabled-reason',
                                ),
                              ),
                            ),
                          Text(
                            l10n.emergencySendDeclaration,
                            key: const Key('emergency-send-declaration'),
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          FilledButton.icon(
                            key: const Key('emergency-report-submit'),
                            onPressed: _isSubmitting || reason != null
                                ? null
                                : _submitEmergencyReport,
                            icon: _isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.send_outlined),
                            label: Text(
                              _isSubmitting
                                  ? l10n.submittingEmergencyReport
                                  : l10n.submitEmergencyReport,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _emergencyHotlines(),
                  ],
                ),
              ),
            ),
    );
  }
}

class _QuickReportEvidenceDialog extends StatefulWidget {
  const _QuickReportEvidenceDialog({
    required this.pickImage,
    required this.pickMultiImage,
    this.sensitive = false,
  });

  final Future<XFile?> Function(ImageSource source) pickImage;
  final Future<List<XFile>> Function() pickMultiImage;
  final bool sensitive;

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
      final reviewed = await reviewEvidencePhoto(
        context,
        picked,
        sensitive: widget.sensitive,
      );
      if (!mounted || reviewed == null) return;
      setState(() => _selected.add(reviewed));
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
      for (final photo in picked) {
        if (!mounted) return;
        final reviewed = await reviewEvidencePhoto(
          context,
          photo,
          sensitive: widget.sensitive,
        );
        if (!mounted) return;
        if (reviewed != null) setState(() => _selected.add(reviewed));
      }
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
                              child: FutureBuilder(
                                future: photo.readAsBytes(),
                                builder: (context, snapshot) => snapshot.hasData
                                    ? Image.memory(
                                        snapshot.data!,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(Icons.photo_outlined),
                              ),
                            ),
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: IconButton.filledTonal(
                                tooltip: 'Edit',
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: _isPicking
                                    ? null
                                    : () async {
                                        setState(() => _isPicking = true);
                                        try {
                                          final reviewed =
                                              await reviewEvidencePhoto(
                                                context,
                                                photo,
                                                sensitive: widget.sensitive,
                                              );
                                          if (mounted && reviewed != null) {
                                            setState(
                                              () => _selected[index] = reviewed,
                                            );
                                          }
                                        } finally {
                                          if (mounted) {
                                            setState(() => _isPicking = false);
                                          }
                                        }
                                      },
                              ),
                            ),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: IconButton.filledTonal(
                                key: Key('quick-report-evidence-remove-$index'),
                                tooltip: l10n.removePhoto,
                                icon: const Icon(Icons.close),
                                onPressed: _isPicking
                                    ? null
                                    : () => setState(
                                        () => _selected.removeAt(index),
                                      ),
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
