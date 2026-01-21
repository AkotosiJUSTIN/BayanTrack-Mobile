import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import 'new_report_controller.dart';
import 'new_report_location_screen.dart';

/// First step: Select photos from camera or gallery
class NewReportPhotosScreen extends ConsumerStatefulWidget {
  const NewReportPhotosScreen({super.key});

  @override
  ConsumerState<NewReportPhotosScreen> createState() =>
      _NewReportPhotosScreenState();
}

class _NewReportPhotosScreenState extends ConsumerState<NewReportPhotosScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickFromCamera() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (photo != null) {
      ref.read(newReportControllerProvider.notifier).addImage(File(photo.path));
    }
  }

  Future<void> _pickFromGallery() async {
    final List<XFile> photos = await _picker.pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (photos.isNotEmpty) {
      ref
          .read(newReportControllerProvider.notifier)
          .addImages(photos.map((x) => File(x.path)).toList());
    }
  }

  void _removeImage(int index) {
    ref.read(newReportControllerProvider.notifier).removeImage(index);
  }

  void _navigateToLocation() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const NewReportLocationScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newReportControllerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Report'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            ref.read(newReportControllerProvider.notifier).reset();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: 0.25,
            backgroundColor: isDark
                ? AppColors.darkBorder
                : AppColors.lightBorder,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),

          // Step title
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step 1 of 4',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add Photos',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Take or select up to ${NewReportController.maxImages} photos of the issue',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Image grid or empty state
          Expanded(
            child: state.selectedImages.isEmpty
                ? _buildEmptyState(theme, isDark)
                : _buildImageGrid(state.selectedImages, isDark),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickFromCamera,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        state.selectedImages.length >=
                            NewReportController.maxImages
                        ? null
                        : _pickFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                ),
              ],
            ),
          ),

          // Continue button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: ElevatedButton(
              onPressed: state.hasPhotos ? _navigateToLocation : null,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.lightSurfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.add_a_photo_outlined,
              size: 48,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Text('No photos yet', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Use the buttons below to add photos',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid(List<File> images, bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(images[index], fit: BoxFit.cover),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.alertHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
            if (index == 0)
              Positioned(
                bottom: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Primary',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
