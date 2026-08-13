import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/app_toast.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/municipality_geo.dart';
import '../../../auth/presentation/barangays_provider.dart';
import '../../../auth/presentation/auth_controller.dart';
import '../../../images/data/evidence_upload_queue.dart';
import '../../../images/data/evidence_upload_queue_provider.dart';
import '../reports_controller.dart';
import 'new_report_controller.dart';

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
      AppToast.warning(
        context,
        'City metadata is unavailable. Refresh it before submitting.',
      );
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
      AppToast.warning(
        context,
        'Please complete all required fields and accept the declaration',
      );
      return;
    }

    final auth = ref.read(authControllerProvider);
    final userId = auth is AuthSuccess ? auth.user?.id : null;
    if (userId == null) {
      AppToast.warning(context, 'Please sign in again before submitting.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _statusMessage = 'Submitting your report...';
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
          : 'Unable to submit the report. Please try again.';
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
    try {
      final intents = await uploadQueue.enqueue(
        userId: userId,
        reportId: createdReportId,
        files: state.selectedImages,
      );
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
    ref.read(newReportControllerProvider.notifier).reset();
    ref.invalidate(reportsControllerProvider);
    ref.read(myReportsRefreshProvider.notifier).increment();
    if (evidenceState == EvidenceUploadState.pending) {
      AppToast.success(context, 'Report submitted. Evidence upload pending.');
    } else {
      AppToast.warning(
        context,
        'Report submitted, but evidence upload needs attention.',
      );
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newReportControllerProvider);
    final controller = ref.read(newReportControllerProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('New Report')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: 1.0,
            backgroundColor: isDark
                ? AppColors.darkBorder
                : AppColors.lightBorder,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step title
                  Text(
                    'Step 4 of 4',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Review & Submit',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Review your report and confirm submission',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ===== IMAGES PREVIEW =====
                  _buildSection(
                    theme: theme,
                    isDark: isDark,
                    icon: Icons.photo_library,
                    title: 'Photos',
                    trailing: '${state.selectedImages.length} photo(s)',
                    content: SizedBox(
                      height: 80,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.selectedImages.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              state.selectedImages[index],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
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
                      theme: theme,
                      isDark: isDark,
                      icon: Icons.title,
                      title: 'Title',
                      trailing: null,
                      content: _buildInfoRow('Title', state.title!),
                    ),
                  if (state.title != null && state.title!.isNotEmpty)
                    const SizedBox(height: 16),

                  // ===== LOCATION PREVIEW =====
                  _buildSection(
                    theme: theme,
                    isDark: isDark,
                    icon: Icons.location_on,
                    title: 'Location',
                    trailing: state.hasLocation ? 'Set' : 'Not set',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (state.zone != null && state.zone!.isNotEmpty)
                          _buildInfoRow('Zone', state.zone!),
                        if (state.streetLandmark != null &&
                            state.streetLandmark!.isNotEmpty)
                          _buildInfoRow(
                            'Street/Landmark',
                            state.streetLandmark!,
                          ),
                        if (state.location != null &&
                            state.location!.isNotEmpty)
                          _buildInfoRow('Address', state.location!),
                        if (state.latitude != null && state.longitude != null)
                          _buildInfoRow(
                            'GPS',
                            '${state.latitude!.toStringAsFixed(6)}, ${state.longitude!.toStringAsFixed(6)}',
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ===== REPORT TIMING =====
                  _buildSection(
                    theme: theme,
                    isDark: isDark,
                    icon: Icons.schedule,
                    title: 'Report Timing',
                    trailing: null,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          'Is Happening Now',
                          state.isHappeningNow ? 'Yes' : 'No',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ===== AI INFO =====
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'AI will automatically detect category, severity, and urgency',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ===== DESCRIPTION PREVIEW =====
                  _buildSection(
                    theme: theme,
                    isDark: isDark,
                    icon: Icons.description,
                    title: 'Description',
                    trailing: null,
                    content: Text(
                      state.description,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 6,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ===== CONSENT SECTION =====
                  Text(
                    'Declaration & Consent',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Declaration checkbox
                  CheckboxListTile(
                    value: state.declarationConfirmed,
                    onChanged: (v) =>
                        controller.setDeclarationConfirmed(v ?? false),
                    title: const Text('I confirm the information is accurate'),
                    subtitle: Text(
                      'I declare that all information provided is true and accurate to the best of my knowledge.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.primary,
                  ),

                  // Data processing consent
                  CheckboxListTile(
                    value: state.dataProcessingConsent,
                    onChanged: (v) =>
                        controller.setDataProcessingConsent(v ?? false),
                    title: const Text('I consent to data processing'),
                    subtitle: Text(
                      'I consent to the processing of my personal data for the purpose of handling this report.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.primary,
                  ),

                  if (!state.hasConsent)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.alertMedium.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.alertMedium,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'You must confirm the declaration and consent to submit',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.alertMedium,
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

          // Submit button
          Padding(
            padding: const EdgeInsets.all(16),
            child: _isSubmitting
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      if (_statusMessage.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          _statusMessage,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ],
                  )
                : ElevatedButton(
                    onPressed: state.canSubmit ? _submitReport : null,
                    child: const Text('Submit Report'),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required ThemeData theme,
    required bool isDark,
    required IconData icon,
    required String title,
    String? trailing,
    Widget? content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (trailing != null) ...[
                const Spacer(),
                Text(
                  trailing,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ],
          ),
          if (content != null) ...[const SizedBox(height: 12), content],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
