import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/presentation/widgets/app_toast.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/data/user_permissions.dart';
import '../../../auth/presentation/verification_widgets.dart';
import '../../../images/data/evidence_file_stager.dart';
import 'new_report_controller.dart';
import 'new_report_location_screen.dart';
import 'report_flow_widgets.dart';

/// First step: Select photos from camera or gallery
class NewReportPhotosScreen extends ConsumerStatefulWidget {
  const NewReportPhotosScreen({super.key});

  @override
  ConsumerState<NewReportPhotosScreen> createState() =>
      _NewReportPhotosScreenState();
}

class _NewReportPhotosScreenState extends ConsumerState<NewReportPhotosScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isPicking = false;

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
        final remaining =
            NewReportController.maxImages -
            ref.read(newReportControllerProvider).selectedImages.length;
        final staged = <File>[];
        for (final photo in photos.take(remaining)) {
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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.newReport),
        leading: IconButton(
          tooltip: l10n.close,
          icon: const Icon(Icons.close),
          onPressed: () {
            ref.read(newReportControllerProvider.notifier).reset();
            Navigator.of(context).pop();
          },
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
                      guidance: l10n.photosOfIssue(
                        NewReportController.maxImages,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ReportFlowSection(
                        title: l10n.photos,
                        trailing: l10n.requiredShort,
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
                          onPressed:
                              _isPicking ||
                                  state.selectedImages.length >=
                                      NewReportController.maxImages
                              ? null
                              : _pickFromGallery,
                          icon: const Icon(Icons.photo_library_outlined),
                          label: Text(l10n.gallery),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: state.hasPhotos && !_isPicking
                        ? _navigateToLocation
                        : null,
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
