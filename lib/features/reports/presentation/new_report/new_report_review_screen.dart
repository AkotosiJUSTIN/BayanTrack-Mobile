import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../../../core/constants/urdaneta_geo.dart';
import '../../../../core/presentation/widgets/app_toast.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../images/data/images_repository.dart';
import '../../data/report_models.dart';
import '../../data/reports_repository.dart';
import '../reports_controller.dart';
import 'new_report_controller.dart';
import 'dart:io';
import '../../../../core/utils/image_utils.dart';

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

    if (state.latitude != null &&
        state.longitude != null &&
        !UrdanetaGeo.contains(state.latitude!, state.longitude!)) {
      AppToast.warning(
        context,
        'Report creation is only available within Urdaneta, Pangasinan.',
      );
      return;
    }

    if (!state.canSubmit) {
      AppToast.warning(
        context,
        'Please complete all required fields and accept the declaration',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _statusMessage = 'Submitting your report...';
    });

    try {
      // Step 1: Compress photos up-front with bounded parallelism.
      List<File> filesForUpload = state.selectedImages;
      if (state.selectedImages.isNotEmpty) {
        setState(() => _statusMessage = 'Preparing your photos...');
        filesForUpload = await _compressFilesInParallel(state.selectedImages);
      }

      // Step 2: Create the report using the new comprehensive request
      final reportsRepo = ref.read(reportsRepositoryProvider);
      final request = state.toCreateRequest();

      final createStopwatch = Stopwatch()..start();
      final createdReport = await reportsRepo.createReport(request);
      createStopwatch.stop();
      debugPrint('Create report took ${createStopwatch.elapsedMilliseconds} ms');


      // Step 3: Upload images (if any)
      if (filesForUpload.isNotEmpty) {
        setState(() => _statusMessage = 'Uploading your photos...');

        final imagesRepo = ref.read(imagesRepositoryProvider);

        // Try bulk upload first (single request, fewer round-trips)
        try {
          final stopwatch = Stopwatch()..start();
          setState(() => _statusMessage = 'Uploading ${filesForUpload.length} photos...');

          // Use bulk-upload endpoint
          final uploaded = await imagesRepo.bulkUploadImages(
            imageFiles: filesForUpload,
            reportId: createdReport.id,
            onSendProgress: _onBulkUploadProgress,
          ).timeout(
            const Duration(seconds: 25),
            onTimeout: () => throw TimeoutException('Bulk upload timed out'),
          );

          stopwatch.stop();
          debugPrint('Bulk upload of ${uploaded.length} images took ${stopwatch.elapsedMilliseconds} ms');

          // If backend uploaded fewer than expected, fall back to parallel individual uploads
          if (uploaded.length < filesForUpload.length) {
            debugPrint('Bulk upload incomplete, falling back to parallel uploads');
            await _parallelUploadFallback(imagesRepo, filesForUpload, createdReport.id);
          }
        } catch (e) {
          debugPrint('Bulk upload failed: $e');
          // Fallback: upload in parallel with limited concurrency
          try {
            await _parallelUploadFallback(imagesRepo, filesForUpload, createdReport.id);
          } catch (e2) {
            debugPrint('Parallel upload fallback failed: $e2');
            if (mounted) {
              AppToast.warning(
                context,
                'Your report was submitted, but we could not upload photos. You can add them later.',
              );
            }
          }
        }
      }

      // Reset the form and navigate back
      ref.read(newReportControllerProvider.notifier).reset();

      // Invalidate reports to refresh the Home screen list
      ref.invalidate(reportsControllerProvider);

      // Increment the refresh trigger so MyReportsScreen auto-reloads
      // its local list without requiring a manual pull-to-refresh.
      ref.read(myReportsRefreshProvider.notifier).increment();

      if (mounted) {
        // Pop all the way back to the main navigation
        Navigator.of(context).popUntil((route) => route.isFirst);

      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _statusMessage = '';
      });
      if (mounted) {
        AppToast.error(
          context,
          'Unable to submit your report. Please check your internet connection and try again.',
        );
      }
    }
  }

  /// Try to compress the file on-device; returns new File or null to indicate no change
  Future<File?> _maybeCompressFile(File original) async {
    try {
      final compressed = await ImageUtils.maybeCompressFile(original);
      return compressed;
    } catch (e) {
      debugPrint('Compression failed for ${original.path}: $e');
      return null;
    }
  }

  Future<List<File>> _compressFilesInParallel(List<File> files) async {
    const concurrency = 3;
    final compressed = List<File?>.filled(files.length, null);
    final stopwatch = Stopwatch()..start();

    for (var i = 0; i < files.length; i += concurrency) {
      final batchFutures = <Future<void>>[];
      final slice = files.skip(i).take(concurrency).toList();
      for (var j = 0; j < slice.length; j++) {
        final idx = i + j;
        final file = slice[j];
        batchFutures.add(_maybeCompressFile(file).then((value) {
          compressed[idx] = value ?? file;
          if (mounted) {
            setState(() {
              _statusMessage = 'Preparing photos ${idx + 1} of ${files.length}...';
            });
          }
        }));
      }
      await Future.wait(batchFutures);
    }

    stopwatch.stop();
    debugPrint('Compression for ${files.length} images took ${stopwatch.elapsedMilliseconds} ms');
    return compressed.map((file) => file!).toList();
  }

  void _onBulkUploadProgress(int sent, int total) {
    if (!mounted || total <= 0) {
      return;
    }
    final pct = ((sent / total) * 100).clamp(0, 100).toStringAsFixed(0);
    setState(() {
      _statusMessage = 'Uploading photos... $pct%';
    });
  }

  /// Parallel upload with limited concurrency (3)
  Future<void> _parallelUploadFallback(ImagesRepository imagesRepo, List<File> files, String reportId) async {
    const concurrency = 3;
    final stopwatch = Stopwatch()..start();

    for (var i = 0; i < files.length; i += concurrency) {
      final batch = <Future<void>>[];
      final slice = files.skip(i).take(concurrency).toList();
      for (var j = 0; j < slice.length; j++) {
        final fileIndex = i + j;
        final file = slice[j];
        if (mounted) setState(() => _statusMessage = 'Uploading photo ${fileIndex + 1} of ${files.length}...');
        final future = imagesRepo
            .uploadImage(
              imageFile: file,
              reportId: reportId,
              isPrimary: fileIndex == 0,
              onSendProgress: (sent, total) {
                if (!mounted || total <= 0) {
                  return;
                }
                final pct = ((sent / total) * 100).clamp(0, 100).toStringAsFixed(0);
                setState(() {
                  _statusMessage = 'Uploading photo ${fileIndex + 1}/${files.length}... $pct%';
                });
              },
            )
            .then((_) {})
            .catchError((e) {
          debugPrint('Upload failed for ${file.path}: $e');
        });
        batch.add(future);
      }
      await Future.wait(batch);
    }

    stopwatch.stop();
    debugPrint('Parallel upload of ${files.length} images took ${stopwatch.elapsedMilliseconds} ms');
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
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
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
                        color: AppColors.alertMedium.withOpacity(0.1),
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
