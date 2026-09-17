import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/urdaneta_geo.dart';
import '../../../../core/presentation/widgets/app_toast.dart';
import '../../../../core/utils/municipality_geo.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/barangays_provider.dart';
import '../../../auth/presentation/auth_controller.dart';
import '../../../images/data/evidence_upload_queue.dart';
import '../../../images/data/evidence_upload_queue_provider.dart';
import '../reports_controller.dart';
import 'new_report_controller.dart';
import 'report_flow_widgets.dart';

/// Fourth step: Review, consent, and submit the report
class NewReportReviewScreen extends ConsumerStatefulWidget {
  const NewReportReviewScreen({super.key});

  @override
  ConsumerState<NewReportReviewScreen> createState() =>
      _NewReportReviewScreenState();
}

class _NewReportReviewScreenState extends ConsumerState<NewReportReviewScreen> {
  bool _isSubmitting = false;
  String _statusMessage = '';

  Future<void> _submitReport() async {
    if (_isSubmitting) {
      return;
    }

    final l10n = AppLocalizations.of(context);
    final state = ref.read(newReportControllerProvider);
    final municipalities =
        ref.read(municipalitiesProvider).asData?.value ??
        const [bundledUrdanetaMunicipality];
    final matchingMunicipalities = municipalities.where(
      (item) => item.id == state.municipalityId,
    );
    final municipality = matchingMunicipalities.isEmpty
        ? null
        : matchingMunicipalities.first;

    if (municipality == null ||
        (municipality.id != defaultMunicipalityId &&
            !municipality.hasUsableBounds)) {
      AppToast.warning(context, l10n.cityMetadataUnavailable);
      return;
    }

    if (state.latitude != null &&
        state.longitude != null &&
        !municipalityContains(
          municipality,
          state.latitude!,
          state.longitude!,
        )) {
      AppToast.warning(context, municipalityUnavailableMessage(municipality));
      return;
    }

    if (!state.canSubmit) {
      AppToast.warning(context, l10n.consentRequired);
      return;
    }

    final auth = ref.read(authControllerProvider);
    final userId = auth is AuthSuccess ? auth.user?.id : null;
    if (userId == null) {
      AppToast.warning(context, l10n.signInAgain);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _statusMessage = l10n.submittingReport;
    });

    late final EvidenceUploadQueue uploadQueue;
    late final String createdReportId;
    try {
      uploadQueue = await ref.read(evidenceUploadQueueProvider.future);
      if (!mounted) return;
      final report = await ref
          .read(newReportControllerProvider.notifier)
          .submit();
      createdReportId = report.id;
    } catch (e) {
      final message = e is ReportSubmissionFailure
          ? e.message
          : l10n.unableSubmitReport;
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _statusMessage = '';
        });
        AppToast.error(context, message);
      }
      return;
    }

    var evidenceState = EvidenceUploadState.pending;
    var evidenceHandedOff = false;
    try {
      final intents = await uploadQueue.enqueue(
        userId: userId,
        reportId: createdReportId,
        files: state.selectedImages,
      );
      if (intents.length != state.selectedImages.length) {
        throw StateError('Evidence queue did not accept every selected image');
      }
      evidenceHandedOff = true;
      if (intents.any(
        (intent) => intent.state == EvidenceUploadState.missingLocalFile,
      )) {
        evidenceState = EvidenceUploadState.missingLocalFile;
      } else {
        unawaited(uploadQueue.resume(userId));
      }
    } catch (_) {
      evidenceState = EvidenceUploadState.failed;
    }

    if (!mounted) return;
    final controller = ref.read(newReportControllerProvider.notifier);
    if (evidenceHandedOff) {
      controller.resetAfterEvidenceHandoff();
    } else {
      controller.reset();
    }
    ref.invalidate(reportsControllerProvider);
    ref.read(myReportsRefreshProvider.notifier).increment();
    if (evidenceState == EvidenceUploadState.pending) {
      AppToast.success(
        context,
        l10n.evidenceUploadsPending(state.selectedImages.length),
      );
    } else {
      AppToast.warning(context, l10n.evidenceUploadFailed);
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newReportControllerProvider);
    final controller = ref.read(newReportControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.newReport)),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ReportFlowProgress(step: 4, total: 4),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ReportFlowHeader(
                      title: l10n.reviewSubmit,
                      guidance: l10n.reviewSubmissionDescription,
                    ),

                    // ===== IMAGES PREVIEW =====
                    _buildSection(
                      icon: Icons.photo_library,
                      title: l10n.photos,
                      trailing: l10n.photoCount(state.selectedImages.length),
                      content: SizedBox(
                        height: 80,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.selectedImages.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            return Semantics(
                              container: true,
                              image: true,
                              label: l10n.photoCount(index + 1),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  state.selectedImages[index],
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Icon(
                                    Icons.broken_image_outlined,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ===== TITLE (IF PROVIDED) =====
                    if (state.title != null && state.title!.isNotEmpty)
                      _buildSection(
                        icon: Icons.title,
                        title: l10n.reportTitle,
                        trailing: null,
                        content: _buildInfoRow(l10n.reportTitle, state.title!),
                      ),
                    if (state.title != null && state.title!.isNotEmpty)
                      const SizedBox(height: 16),

                    // ===== LOCATION PREVIEW =====
                    _buildSection(
                      icon: Icons.location_on,
                      title: l10n.reportLocation,
                      trailing: state.hasLocation
                          ? l10n.locationSet
                          : l10n.locationNotSet,
                      content: ReportLocationSummary(
                        city: UrdanetaGeo.displayCityName,
                        location: state.location,
                        barangay: state.barangay,
                        isResolvingBarangay: state.isResolvingBarangay,
                        landmark: state.streetLandmark,
                        isResolvingLandmark: state.isResolvingLandmark,
                        landmarkLookupError: state.landmarkLookupError,
                        landmarkLookupCompleted: state.landmarkLookupCompleted,
                        landmarkSuggestions: state.nearbyLandmarkSuggestions,
                        coordinates:
                            state.latitude != null && state.longitude != null
                            ? '${state.latitude!.toStringAsFixed(6)}, ${state.longitude!.toStringAsFixed(6)}'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ===== REPORT TIMING =====
                    _buildSection(
                      icon: Icons.schedule,
                      title: l10n.reportTiming,
                      trailing: null,
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(
                            l10n.isHappeningNow,
                            state.isHappeningNow ? l10n.yes : l10n.no,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ===== DESCRIPTION PREVIEW =====
                    _buildSection(
                      icon: Icons.description,
                      title: l10n.reportDescription,
                      trailing: null,
                      content: Text(
                        state.description,
                        style: theme.textTheme.bodyMedium,
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 24),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ReportFlowSection(
                        title: l10n.declarationConsent,
                        trailing: l10n.requiredShort,
                        icon: Icons.fact_check_outlined,
                        child: Column(
                          children: [
                            CheckboxListTile(
                              value: state.declarationConfirmed,
                              onChanged: (v) => controller
                                  .setDeclarationConfirmed(v ?? false),
                              title: Text(l10n.confirmAccurate),
                              subtitle: Text(
                                l10n.declarationText,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                            ),
                            CheckboxListTile(
                              value: state.dataProcessingConsent,
                              onChanged: (v) => controller
                                  .setDataProcessingConsent(v ?? false),
                              title: Text(l10n.consentDataProcessing),
                              subtitle: Text(
                                l10n.consentText,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                            ),
                            if (!state.hasConsent)
                              Semantics(
                                liveRegion: true,
                                label: l10n.consentRequired,
                                child: Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.errorContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color:
                                            theme.colorScheme.onErrorContainer,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          l10n.consentRequired,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onErrorContainer,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            ReportFlowBottomBar(
              child: _isSubmitting
                  ? Semantics(
                      liveRegion: true,
                      label: _statusMessage,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          if (_statusMessage.isNotEmpty) ...[
                            const SizedBox(width: 12),
                            Flexible(child: Text(_statusMessage)),
                          ],
                        ],
                      ),
                    )
                  : ElevatedButton(
                      onPressed: state.canSubmit ? _submitReport : null,
                      child: Text(l10n.submitReport),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    String? trailing,
    Widget? content,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ReportFlowSection(
        title: title,
        icon: icon,
        trailing: trailing,
        child: content ?? const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final theme = Theme.of(context);
    return Semantics(
      container: true,
      label: '$label: $value',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(value, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
