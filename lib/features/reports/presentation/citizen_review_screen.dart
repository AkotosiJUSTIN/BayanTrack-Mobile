import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';

import '../../../core/theme/app_colors.dart';
import '../../images/data/images_repository.dart';
import '../domain/entities/report.dart';
import 'report_detail_controller.dart';

/// Screen shown to citizens so they can review a barangay-resolved report,
/// provide a star rating, an optional note, and a digital confirmation
/// before permanently closing the report or reopening it.
class CitizenReviewScreen extends ConsumerStatefulWidget {
  /// The report being reviewed (must be in `resolved` status).
  final Report report;

  const CitizenReviewScreen({super.key, required this.report});

  @override
  ConsumerState<CitizenReviewScreen> createState() =>
      _CitizenReviewScreenState();
}

class _CitizenReviewScreenState extends ConsumerState<CitizenReviewScreen> {
  int _rating = 0;
  final _noteController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isSubmitting = false;

  late final SignatureController _signatureController;

  @override
  void initState() {
    super.initState();
    _signatureController = SignatureController(
      penStrokeWidth: 2.5,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
      onDrawStart: () => setState(() {}),
      onDrawEnd: () => setState(() {}),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    _nameController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String get _reportTitle =>
      widget.report.title ??
      widget.report.reportId ??
      widget.report.id.substring(0, 8).toUpperCase();

  String get _resolutionNote =>
      widget.report.adminRemarks?.isNotEmpty == true
          ? widget.report.adminRemarks!
          : 'The barangay has marked this report as resolved.';

  bool get _nameValid =>
      _nameController.text.trim().split(' ').length >= 2;

  bool get _canvasValid => _signatureController.isNotEmpty;

  bool get _signatureValid => _nameValid && _canvasValid;

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _submit({required bool satisfied}) async {
    if (!_nameValid) {
      _showSnackBar('Please enter your full name.', error: true);
      return;
    }
    if (!_canvasValid) {
      _showSnackBar('Please draw your signature on the canvas.', error: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // 1. Export canvas as PNG bytes
      final signatureBytes = await _signatureController.toPngBytes();
      String? signatureImageId;

      // 2. Upload signature image to get a proper record ID
      if (signatureBytes != null && signatureBytes.isNotEmpty) {
        try {
          final tempDir = await getTemporaryDirectory();
          final fileName =
              'signature_${widget.report.reportId ?? widget.report.id}_${DateTime.now().millisecondsSinceEpoch}.png';
          final tempFile = File('${tempDir.path}/$fileName');
          await tempFile.writeAsBytes(signatureBytes);

          final repo = ref.read(imagesRepositoryProvider);
          final uploaded = await repo.uploadImage(
            imageFile: tempFile,
            reportId: widget.report.id,
            isPrimary: false,
            purpose: 'signature',
          );
          // Use the database record ID (not the S3 URL) so the backend can
          // resolve it to the closure_signature_image_id field.
          signatureImageId = uploaded.id;

          // Clean up temp file
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
        } catch (uploadError) {
          debugPrint('Signature upload failed: $uploadError');
          // Proceed without an image ID — backend will still store the name
        }
      }

      final note = _noteController.text.trim();
      final fullName = _nameController.text.trim();

      final controller = ref.read(
        reportDetailControllerProvider(widget.report.id).notifier,
      );
      final result = await controller.citizenCloseReport(
        satisfied: satisfied,
        rating: _rating > 0 ? _rating : null,
        note: note.isNotEmpty ? note : null,
        signatureImageId: signatureImageId,
        signatureName: fullName,
      );

      if (!mounted) return;

      final message = result['message'] as String? ??
          (satisfied
              ? 'Report confirmed as resolved.'
              : 'Report has been re-opened and escalated.');

      _showSnackBar(message);

      // Refresh the detail view and pop back
      ref.invalidate(reportDetailControllerProvider(widget.report.id));
      Navigator.of(context).pop(true); // true = action was taken
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''), error: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnackBar(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? AppColors.alertHigh : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Guard: already reviewed — show read-only confirmation, no form
    if (widget.report.citizenVerifiedAt != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Review Resolution'),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.verified_rounded,
                    color: AppColors.success,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Review Already Submitted',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'You have already submitted your review and digital signature for this report. No further action is needed.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Go Back'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Resolution'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme, isDark),
            const SizedBox(height: 24),
            _buildResolutionCard(theme, isDark),
            const SizedBox(height: 24),
            _buildRatingSection(theme),
            const SizedBox(height: 24),
            _buildNoteSection(theme, isDark),
            const SizedBox(height: 24),
            _buildSignatureSection(theme, isDark),
            const SizedBox(height: 32),
            _buildActionButtons(theme),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ── Sub-widgets ────────────────────────────────────────────────────────────

  Widget _buildHeader(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.task_alt_rounded,
                color: AppColors.success,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Report Resolved',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _reportTitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'The barangay has marked your report as resolved. '
          'Please review their action and confirm whether the issue '
          'was properly addressed.',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildResolutionCard(ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                size: 16,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                'Resolution Summary',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _resolutionNote,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rate the Response  (optional)',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(5, (index) {
            final starIndex = index + 1;
            return GestureDetector(
              onTap: () => setState(() {
                // Tap same star again to deselect
                _rating = _rating == starIndex ? 0 : starIndex;
              }),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  starIndex <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 36,
                  color: starIndex <= _rating
                      ? Colors.amber.shade600
                      : Colors.grey.shade400,
                ),
              ),
            );
          }),
        ),
        if (_rating > 0) ...[
          const SizedBox(height: 6),
          Text(
            _ratingLabel(_rating),
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.amber.shade700,
            ),
          ),
        ],
      ],
    );
  }

  String _ratingLabel(int rating) => switch (rating) {
        1 => 'Very Dissatisfied',
        2 => 'Dissatisfied',
        3 => 'Neutral',
        4 => 'Satisfied',
        5 => 'Very Satisfied',
        _ => '',
      };

  Widget _buildNoteSection(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Comments  (optional)',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _noteController,
          maxLines: 4,
          maxLength: 500,
          decoration: InputDecoration(
            hintText:
                'Describe how the issue was resolved or any remaining concerns…',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor:
                isDark ? AppColors.darkSurface : Colors.grey.shade50,
          ),
        ),
      ],
    );
  }

  Widget _buildSignatureSection(ThemeData theme, bool isDark) {
    final canvasBorder = _canvasValid
        ? AppColors.success
        : (isDark ? AppColors.darkBorder : Colors.grey.shade300);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heading
        Row(
          children: [
            Icon(Icons.draw_outlined, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              'Digital Signature',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            if (_signatureValid) ...[const SizedBox(width: 8), Icon(Icons.verified_rounded, size: 18, color: AppColors.success)],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Draw your signature in the box below, then type your full name '
          'to confirm your identity and authenticate this review.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 12),

        // ── Canvas pad ──────────────────────────────────────────────────────
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: canvasBorder, width: 1.5),
            ),
            child: Stack(
              children: [
                Signature(
                  controller: _signatureController,
                  height: 160,
                  backgroundColor:
                      isDark ? const Color(0xFF1E1E1E) : Colors.white,
                ),
                // Placeholder hint
                if (!_canvasValid)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Center(
                        child: Text(
                          'Sign here',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade400,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                  ),
                // Clear / reset button
                Positioned(
                  top: 6,
                  right: 6,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        _signatureController.clear();
                        setState(() {});
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(Icons.refresh_rounded,
                            size: 18, color: Colors.grey.shade500),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!_canvasValid)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Please draw your signature above.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: AppColors.alertHigh),
            ),
          ),

        const SizedBox(height: 14),

        // ── Full name field ─────────────────────────────────────────────────
        TextField(
          controller: _nameController,
          onChanged: (_) => setState(() {}),
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'Full Name',
            hintText: 'e.g. Juan dela Cruz',
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: isDark ? AppColors.darkSurface : Colors.grey.shade50,
            suffixIcon: _nameValid
                ? Icon(Icons.check_circle, color: AppColors.success)
                : null,
          ),
        ),
        if (!_nameValid && _nameController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Please enter your first and last name.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: AppColors.alertHigh),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Primary: Confirm Resolved
        FilledButton.icon(
          onPressed: _isSubmitting ? null : () => _submit(satisfied: true),
          icon: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.check_circle_outline),
          label: const Text('Confirm — Issue is Resolved'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.success,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 12),

        // Secondary: Dispute / Reopen
        OutlinedButton.icon(
          onPressed: _isSubmitting ? null : () => _confirmReopen(theme),
          icon: const Icon(Icons.report_problem_outlined),
          label: const Text('Dispute — Issue is Not Resolved'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.alertHigh,
            side: BorderSide(color: AppColors.alertHigh),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),

        const SizedBox(height: 12),
        Text(
          'Disputing will re-escalate the report to the municipal office '
          'for further action.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  Future<void> _confirmReopen(ThemeData theme) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dispute Resolution?'),
        content: const Text(
          'Are you sure you want to dispute this resolution? '
          'The report will be escalated back to the municipal office.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.alertHigh,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Yes, Dispute'),
          ),
        ],
      ),
    );
    if (confirm == true) _submit(satisfied: false);
  }
}
