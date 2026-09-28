import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/presentation/widgets/app_toast.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/auth_controller.dart';
import '../../../auth/data/user_permissions.dart';
import '../../../auth/presentation/verification_widgets.dart';
import '../../../images/data/evidence_file_stager.dart';
import '../../../images/data/evidence_upload_queue_provider.dart';
import '../../data/report_draft_store.dart';
import 'new_report_details_screen.dart';
import 'new_report_controller.dart';
import 'new_report_location_screen.dart';
import 'new_report_review_screen.dart';
import 'report_draft_prompt.dart';
import 'report_flow_widgets.dart';

/// First step: Select photos from camera or gallery
class NewReportPhotosScreen extends ConsumerStatefulWidget {
  const NewReportPhotosScreen({super.key});

  @override
  ConsumerState<NewReportPhotosScreen> createState() =>
      _NewReportPhotosScreenState();
}

class _NewReportPhotosScreenState extends ConsumerState<NewReportPhotosScreen>
    with WidgetsBindingObserver {
  final ImagePicker _picker = ImagePicker();
  bool _isPicking = false;
  bool _draftFlowReady = false;
  bool _canPersistDraft = true;
  bool _persistDraft = true;
  Timer? _draftSaveTimer;
  String? _draftOwnerId;
  ReportDraft? _draftRecord;
  NewReportState? _latestState;
  late final ReportDraftStore _draftStore;
  late final ProviderSubscription<NewReportState> _draftSubscription;
  late final ProviderSubscription<AuthState> _authSubscription;
  Future<void> _draftWriteTail = Future<void>.value();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _draftStore = ref.read(reportDraftStoreProvider);
    _draftOwnerId = _currentOwnerId();
    _latestState = ref.read(newReportControllerProvider);
    _draftSubscription = ref.listenManual(newReportControllerProvider, (
      _,
      state,
    ) {
      _latestState = state;
      if (_draftFlowReady && !state.draftCompleted) {
        _scheduleDraftSave(state);
      }
    });
    _authSubscription = ref.listenManual(authControllerProvider, (_, state) {
      final nextOwnerId = _ownerIdFor(state);
      if (_draftOwnerId != nextOwnerId) {
        _canPersistDraft = false;
        _draftSaveTimer?.cancel();
        if (_draftOwnerId != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            ref.read(newReportControllerProvider.notifier).reset();
            Navigator.of(context).popUntil((route) => route.isFirst);
          });
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_prepareDraft());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      unawaited(_flushDraftSave());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _draftSaveTimer?.cancel();
    _draftSubscription.close();
    _authSubscription.close();
    if (_draftFlowReady && _persistDraft && _latestState != null) {
      unawaited(_enqueueDraftSave(_latestState!));
    }
    super.dispose();
  }

  String? _currentOwnerId() => _ownerIdFor(ref.read(authControllerProvider));

  String? _ownerIdFor(AuthState state) =>
      state is AuthSuccess ? state.user?.id : null;

  Future<void> _prepareDraft() async {
    final ownerId = _draftOwnerId;
    if (ownerId == null) {
      if (mounted) setState(() => _draftFlowReady = true);
      return;
    }

    final draft = await _draftStore.read(ownerId, ReportDraftType.full);
    if (!mounted) return;
    if (!_canPersistDraft || _currentOwnerId() != ownerId) {
      Navigator.of(context).pop();
      return;
    }
    if (draft == null) {
      setState(() => _draftFlowReady = true);
      return;
    }

    final action = await showReportDraftPrompt(context, draft: draft);
    if (!mounted) return;
    if (!_canPersistDraft || _currentOwnerId() != ownerId) {
      Navigator.of(context).pop();
      return;
    }
    if (action == ReportDraftAction.resume) {
      final attachments = <File>[];
      for (final path in draft.attachmentRefs) {
        final file = await resolveEvidenceDraftReference(path);
        if (file != null &&
            !attachments.any((item) => item.path == file.path)) {
          attachments.add(file);
        }
      }
      if (!mounted) return;
      if (!_canPersistDraft || _currentOwnerId() != ownerId) {
        Navigator.of(context).pop();
        return;
      }
      ref
          .read(newReportControllerProvider.notifier)
          .restoreDraft(draft, attachments: attachments);
      _draftRecord = draft;
      _latestState = ref.read(newReportControllerProvider);
      setState(() => _draftFlowReady = true);
      await _enqueueDraftSave(_latestState!);
      if (!mounted) return;
      if (!_canPersistDraft || _currentOwnerId() != ownerId) return;
      _openResumeStep(_latestState!.resumeStep);
      return;
    }

    if (action == ReportDraftAction.discard ||
        action == ReportDraftAction.startNew) {
      await _discardSavedDraft(draft);
      if (!mounted) return;
      if (!_canPersistDraft || _currentOwnerId() != ownerId) return;
      _draftRecord = null;
      ref.read(newReportControllerProvider.notifier).reset();
      if (action == ReportDraftAction.discard) {
        _persistDraft = false;
        Navigator.of(context).pop();
        return;
      }
    } else {
      _persistDraft = false;
      Navigator.of(context).pop();
      return;
    }
    setState(() => _draftFlowReady = true);
  }

  void _openResumeStep(String step) {
    final pages = switch (step) {
      'location' => <Widget>[const NewReportLocationScreen()],
      'details' => <Widget>[
        const NewReportLocationScreen(),
        const NewReportDetailsScreen(),
      ],
      'review' => <Widget>[
        const NewReportLocationScreen(),
        const NewReportDetailsScreen(),
        const NewReportReviewScreen(),
      ],
      _ => const <Widget>[],
    };
    final navigator = Navigator.of(context);
    for (final page in pages) {
      unawaited(
        navigator.push<void>(MaterialPageRoute<void>(builder: (_) => page)),
      );
    }
  }

  void _scheduleDraftSave(NewReportState state) {
    if (!_canPersistDraft || !_persistDraft || state.draftCompleted) return;
    _draftSaveTimer?.cancel();
    _draftSaveTimer = Timer(
      const Duration(milliseconds: 300),
      () => unawaited(_enqueueDraftSave(state)),
    );
  }

  Future<void> _flushDraftSave() async {
    _draftSaveTimer?.cancel();
    final state = _latestState;
    if (state != null && _draftFlowReady) await _enqueueDraftSave(state);
  }

  Future<void> _enqueueDraftSave(NewReportState state) {
    final operation = _draftWriteTail.then((_) => _writeDraftSnapshot(state));
    _draftWriteTail = operation.catchError((_) {});
    return operation;
  }

  Future<void> _writeDraftSnapshot(NewReportState state) async {
    final ownerId = _draftOwnerId;
    if (!_canPersistDraft ||
        !_persistDraft ||
        ownerId == null ||
        state.draftCompleted) {
      return;
    }
    final previous =
        await _draftStore.read(ownerId, ReportDraftType.full) ?? _draftRecord;
    final attachments = <String>[];
    for (final image in state.selectedImages) {
      if (await resolveEvidenceDraftReference(image.path) != null) {
        attachments.add(image.absolute.path);
      }
    }
    final hasContent =
        attachments.isNotEmpty ||
        state.category != null ||
        state.title?.trim().isNotEmpty == true ||
        state.description.trim().isNotEmpty ||
        state.incidentDatetime != null ||
        state.isHappeningNow ||
        state.zone?.trim().isNotEmpty == true ||
        state.streetLandmark?.trim().isNotEmpty == true ||
        state.latitude != null ||
        state.longitude != null;
    if (!hasContent) {
      if (previous == null) return;
      await _draftStore.delete(ownerId, ReportDraftType.full);
      _draftRecord = null;
      await _discardUnreferenced(previous.attachmentRefs);
      return;
    }

    final now = DateTime.now().toUtc();
    final draft = ReportDraft(
      schemaVersion: ReportDraft.currentSchemaVersion,
      draftId: previous?.draftId ?? newReportLocalId(),
      ownerId: ownerId,
      type: ReportDraftType.full,
      createdAt: previous?.createdAt ?? now,
      updatedAt: now,
      resumeStep: state.resumeStep,
      payload: {
        'category': state.category?.value,
        'title': state.title,
        'description': state.description,
        'incidentDatetime': state.incidentDatetime?.toIso8601String(),
        'isHappeningNow': state.isHappeningNow,
        'zone': state.zone,
        'streetLandmark': state.streetLandmark,
        'municipalityId': state.municipalityId,
        'barangay': state.barangay,
        'cityMunicipality': state.cityMunicipality,
        'province': state.province,
        'latitude': state.latitude,
        'longitude': state.longitude,
        'locationAccuracy': state.locationAccuracy.name,
        'location': state.location,
      },
      attachmentRefs: attachments,
    );
    await _draftStore.write(draft);
    _draftRecord = draft;
    if (previous != null) {
      final retained = attachments.toSet();
      await _discardUnreferenced(
        previous.attachmentRefs.where((path) => !retained.contains(path)),
      );
    }
  }

  Future<void> _discardSavedDraft(ReportDraft draft) async {
    await _draftStore.delete(draft.ownerId, draft.type);
    await _discardUnreferenced(draft.attachmentRefs);
  }

  Future<void> _discardUnreferenced(Iterable<String> paths) async {
    if (!mounted) return;
    try {
      final retained = (await _draftStore.readAllAttachmentReferences())
          .map((path) => File(path).absolute.path)
          .toSet();
      final queue = await ref.read(evidenceUploadQueueProvider.future);
      if (!mounted) return;
      retained.addAll(queue.referencedFilePaths);
      for (final path in paths) {
        final file = File(path).absolute;
        if (!retained.contains(file.path)) await discardEvidenceDraft(file);
      }
    } catch (_) {
      // Keep staged files when durable ownership cannot be verified.
    }
  }

  Future<void> _closeAndKeepDraft() async {
    await _flushDraftSave();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _pickFromCamera() async {
    if (_isPicking) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _isPicking = true);
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (photo != null && mounted) {
        final staged = await stageEvidenceFile(photo);
        if (!mounted) return;
        ref.read(newReportControllerProvider.notifier).addImage(staged);
      }
    } catch (_) {
      if (mounted) AppToast.error(context, l10n.imageAccessError);
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isPicking) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _isPicking = true);
    try {
      final List<XFile> photos = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (photos.isNotEmpty && mounted) {
        final staged = <File>[];
        for (final photo in photos) {
          staged.add(await stageEvidenceFile(photo));
        }
        if (!mounted) return;
        ref.read(newReportControllerProvider.notifier).addImages(staged);
      }
    } catch (_) {
      if (mounted) AppToast.error(context, l10n.imageAccessError);
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  void _removeImage(int index) {
    ref.read(newReportControllerProvider.notifier).removeImage(index);
  }

  void _navigateToLocation() {
    ref.read(newReportControllerProvider.notifier).setResumeStep('location');
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const NewReportLocationScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newReportControllerProvider);
    final permissions = ref.watch(userPermissionsProvider);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (!_draftFlowReady) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.newReport)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.newReport),
        leading: IconButton(
          tooltip: l10n.close,
          icon: const Icon(Icons.close),
          onPressed: _closeAndKeepDraft,
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VerificationBanner(permissions: permissions),
            ReportFlowProgress(step: 1, total: 4),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ReportFlowHeader(
                      title: l10n.addPhotos,
                      guidance: l10n.photosOptional,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ReportFlowSection(
                        title: l10n.photos,
                        trailing: l10n.optionalShort,
                        icon: Icons.photo_library_outlined,
                        child: state.selectedImages.isEmpty
                            ? _buildEmptyState(theme, scheme, l10n)
                            : _buildImageGrid(
                                state.selectedImages,
                                scheme,
                                l10n,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ReportFlowBottomBar(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isPicking ? null : _pickFromCamera,
                          icon: _isPicking
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.camera_alt_outlined),
                          label: Text(l10n.camera),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isPicking ? null : _pickFromGallery,
                          icon: const Icon(Icons.photo_library_outlined),
                          label: Text(l10n.gallery),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _isPicking ? null : _navigateToLocation,
                    child: Text(l10n.continueLabel),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    ThemeData theme,
    ColorScheme scheme,
    AppLocalizations l10n,
  ) {
    return SizedBox(
      height: 180,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo_outlined,
              size: 40,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(l10n.noPhotosYet, style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              l10n.useButtonsAddPhotos,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid(
    List<File> images,
    ColorScheme scheme,
    AppLocalizations l10n,
  ) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 140,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return Semantics(
          container: true,
          image: true,
          label: l10n.photoCount(index + 1),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  images[index],
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Icon(
                    Icons.broken_image_outlined,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  tooltip: l10n.removePhoto,
                  constraints: const BoxConstraints.tightFor(
                    width: 48,
                    height: 48,
                  ),
                  padding: EdgeInsets.zero,
                  iconSize: 20,
                  style: IconButton.styleFrom(
                    backgroundColor: scheme.error,
                    foregroundColor: scheme.onError,
                  ),
                  onPressed: () => _removeImage(index),
                  icon: const Icon(Icons.close),
                ),
              ),
              if (index == 0)
                Positioned(
                  bottom: 4,
                  left: 4,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      child: Text(
                        l10n.primaryPhoto,
                        style: TextStyle(
                          color: scheme.onPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
