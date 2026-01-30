import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../images/data/images_repository.dart';
import '../../data/report_models.dart';
import '../../data/reports_repository.dart';
import '../reports_controller.dart';
import 'new_report_controller.dart';

/// Fourth step: Review and submit the report
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
    final state = ref.read(newReportControllerProvider);

    if (!state.canSubmit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _statusMessage = 'Creating report...';
    });

    try {
      // Step 1: Create the report (fast - just JSON)
      final reportsRepo = ref.read(reportsRepositoryProvider);
      final request = CreateReportRequest(
        description: state.description,
        location: state.location!,
        zone: state.zone,
        latitude: state.latitude?.toStringAsFixed(6),
        longitude: state.longitude?.toStringAsFixed(6),
        category: state.category,
      );

      final createdReport = await reportsRepo.createReport(request);
      
      // Step 2: Upload images (if any) - upload one at a time for reliability
      if (state.selectedImages.isNotEmpty) {
        setState(() => _statusMessage = 'Uploading images...');
        
        final imagesRepo = ref.read(imagesRepositoryProvider);
        try {
          for (int i = 0; i < state.selectedImages.length; i++) {
            setState(() => _statusMessage = 'Uploading image ${i + 1}/${state.selectedImages.length}...');
            await imagesRepo.uploadImage(
              imageFile: state.selectedImages[i],
              reportId: createdReport.id,
              isPrimary: i == 0, // First image is primary
            );
          }
        } catch (e) {
          // Log but don't fail - report was already created
          debugPrint('Image upload failed: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Report created, but image upload failed'),
                backgroundColor: AppColors.alertMedium,
              ),
            );
          }
        }
      }

      // Reset the form and navigate back
      ref.read(newReportControllerProvider.notifier).reset();

      // Invalidate reports to refresh the list
      ref.invalidate(reportsControllerProvider);

      if (mounted) {
        // Pop all the way back to the main navigation
        Navigator.of(context).popUntil((route) => route.isFirst);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Report submitted successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _statusMessage = '';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit: ${e.toString()}'),
            backgroundColor: AppColors.alertHigh,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newReportControllerProvider);
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
                    'Review',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Review your report before submitting',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Images preview
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
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
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

                  // Location preview
                  _buildSection(
                    theme: theme,
                    isDark: isDark,
                    icon: Icons.location_on,
                    title: 'Location',
                    trailing: state.hasLocation ? 'Set' : 'Not set',
                    content: Text(
                      state.location ?? 'Location coordinates saved',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Zone preview
                  _buildSection(
                    theme: theme,
                    isDark: isDark,
                    icon: Icons.location_city,
                    title: 'Zone',
                    trailing: state.zone.isNotEmpty ? 'Set' : 'Not set',
                    content: Text(
                      state.zone.isNotEmpty ? state.zone : 'Not specified',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category preview
                  _buildSection(
                    theme: theme,
                    isDark: isDark,
                    icon: Icons.category,
                    title: 'Category',
                    trailing: state.category ?? 'Not set',
                    content: null,
                  ),
                  const SizedBox(height: 16),

                  // Description preview
                  _buildSection(
                    theme: theme,
                    isDark: isDark,
                    icon: Icons.description,
                    title: 'Description',
                    trailing: null,
                    content: Text(
                      state.description,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
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
}
