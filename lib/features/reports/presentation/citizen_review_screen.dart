import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/presentation/widgets/app_toast.dart';
import '../../../core/presentation/failure_message.dart';
import '../../../core/presentation/widgets/civic_components.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/string_utils.dart';
import '../../../l10n/app_localizations.dart';
import '../../images/data/images_repository.dart';
import '../domain/entities/report.dart';
import 'report_detail_controller.dart';
import 'widgets/shared_incident_section.dart';
import '../../auth/presentation/auth_controller.dart';

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

  String get _resolutionNote {
    final rawText = widget.report.adminRemarks?.isNotEmpty == true
        ? widget.report.adminRemarks!
        : AppLocalizations.of(context).resolvedDefaultNote;
    return StringUtils.unescapeHtml(rawText);
  }

  String get _userFullName {
    final authState = ref.read(authControllerProvider);
    if (authState is AuthSuccess) {
      return authState.user?.fullName ?? '';
    }
    return '';
  }

  bool get _nameValid {
    final inputName = _nameController.text.trim().toLowerCase();
    final expectedName = _userFullName.toLowerCase();
    return inputName.isNotEmpty && inputName == expectedName;
  }

  bool get _canvasValid => _signatureController.isNotEmpty;

  bool get _signatureValid => _nameValid && _canvasValid;

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<String?> _submit({
    required bool satisfied,
    String? disputeReason,
  }) async {
    final l10n = AppLocalizations.of(context);
    if (_isSubmitting) return l10n.disputeSubmitFailed;

    if (satisfied) {
      if (!_nameValid) {
        return '${l10n.registeredNameRequired} ($_userFullName)';
      }
      if (!_canvasValid) return l10n.signatureRequired;
    } else if (disputeReason?.trim().isNotEmpty != true) {
      return l10n.disputeReasonRequired;
    }

    setState(() => _isSubmitting = true);

    try {
      String? signatureImageId;

      if (satisfied) {
        // Confirmation keeps the existing drawn-signature requirement. A
        // failed upload is retryable; it must not silently become unsigned.
        final signatureBytes = await _signatureController.toPngBytes();
        if (signatureBytes == null || signatureBytes.isEmpty) {
          return l10n.signatureRequired;
        }
        File? tempFile;
        try {
          final tempDir = await getTemporaryDirectory();
          final fileName =
              'signature_${widget.report.reportId ?? widget.report.id}_${DateTime.now().millisecondsSinceEpoch}.png';
          final file = File('${tempDir.path}/$fileName');
          tempFile = file;
          await file.writeAsBytes(signatureBytes);

          final repo = ref.read(imagesRepositoryProvider);
          final uploaded = await repo.uploadImage(
            imageFile: file,
            reportId: widget.report.id,
            isPrimary: false,
            purpose: 'signature',
          );
          // Use the database record ID (not the S3 URL) so the backend can
          // resolve it to the closure_signature_image_id field.
          signatureImageId = uploaded.id;
        } catch (_) {
          throw Exception(l10n.disputeSubmitFailed);
        } finally {
          if (tempFile != null && await tempFile.exists()) {
            await tempFile.delete();
          }
        }
      }

      final note = satisfied ? _noteController.text.trim() : null;
      final fullName = satisfied ? _nameController.text.trim() : null;

      final controller = ref.read(
        reportDetailControllerProvider(widget.report.id).notifier,
      );
      await controller.citizenCloseReport(
        satisfied: satisfied,
        rating: _rating > 0 ? _rating : null,
        note: note?.isNotEmpty == true ? note : null,
        reason: disputeReason?.trim(),
        signatureImageId: signatureImageId,
        signatureName: fullName,
      );

      if (!mounted) return null;

      final message = satisfied
          ? l10n.reportConfirmedResolved
          : l10n.reportReopenedEscalated;

      AppToast.success(context, message);

      // Refresh the detail view and pop back
      ref.invalidate(reportDetailControllerProvider(widget.report.id));
      return null;
    } catch (e) {
      return localizedFailureMessage(
        e,
        l10n,
        fallback: l10n.disputeSubmitFailed,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final successColor = _successColor(theme);

    // Guard: already reviewed — show read-only confirmation, no form
    if (widget.report.hasCitizenConfirmedResolution) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.reviewResolution), centerTitle: true),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: successColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.verified_rounded,
                    color: successColor,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.reviewAlreadySubmitted,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.reviewNoFurtherAction,
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
                    child: Text(l10n.back),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reviewResolution), centerTitle: true),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(theme),
                const SizedBox(height: 24),
                _buildResolutionCard(theme),
                const SizedBox(height: 24),
                if (widget.report.incidentGroupId != null) ...[
                  CivicSurface(
                    padding: const EdgeInsets.all(16),
                    child: SharedIncidentSection(reportId: widget.report.id),
                  ),
                  const SizedBox(height: 24),
                ],
                if (widget.report.incidentGroupId == null ||
                    widget.report.resolvedProofImages.isNotEmpty)
                  _buildResponseEvidence(theme),
                const SizedBox(height: 24),
                _buildRatingSection(theme),
                const SizedBox(height: 24),
                _buildNoteSection(theme),
                const SizedBox(height: 24),
                _buildSignatureSection(theme),
                const SizedBox(height: 32),
                _buildActionButtons(theme),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Sub-widgets ────────────────────────────────────────────────────────────

  Widget _buildHeader(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    final successColor = _successColor(theme);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: successColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.task_alt_rounded,
                color: successColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.awaitingStaffConfirmation,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _reportTitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(l10n.resolvedReviewDescription, style: theme.textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildResolutionCard(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return CivicSurface(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                l10n.resolutionSummary,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(_resolutionNote, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildResponseEvidence(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    final evidence = widget.report.resolvedProofImages;
    return CivicSurface(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.photo_library_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.resolutionProof,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l10n.resolutionProofResolved,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (evidence.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: evidence.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final image = evidence[index];
                  final caption = image.caption?.trim();
                  return Semantics(
                    image: true,
                    label: l10n.resolutionProof,
                    child: SizedBox(
                      width: 148,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                ApiConstants.getImageUrl(image.url),
                                width: 148,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  width: 148,
                                  color:
                                      theme.colorScheme.surfaceContainerHighest,
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (caption?.isNotEmpty == true)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                caption!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                l10n.noImages,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRatingSection(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.rateResponse,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(5, (index) {
            final starIndex = index + 1;
            return Semantics(
              button: true,
              selected: starIndex == _rating,
              label: '${l10n.rateResponse}: $starIndex',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => setState(() {
                    // Tap same star again to deselect
                    _rating = _rating == starIndex ? 0 : starIndex;
                  }),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(
                      starIndex <= _rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 32,
                      color: starIndex <= _rating
                          ? Colors.amber.shade600
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        if (_rating > 0) ...[
          const SizedBox(height: 6),
          Text(
            _ratingLabel(_rating, l10n),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  String _ratingLabel(int rating, AppLocalizations l10n) => switch (rating) {
    1 => l10n.veryDissatisfied,
    2 => l10n.dissatisfied,
    3 => l10n.neutral,
    4 => l10n.satisfied,
    5 => l10n.verySatisfied,
    _ => '',
  };

  Widget _buildNoteSection(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.additionalComments,
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
            hintText: l10n.resolutionCommentsHint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest,
          ),
        ),
      ],
    );
  }

  Widget _buildSignatureSection(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    final successColor = _successColor(theme);
    final errorColor = _errorColor(theme);
    final canvasBorder = _canvasValid
        ? successColor
        : theme.colorScheme.outline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heading
        Row(
          children: [
            Icon(Icons.draw_outlined, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              l10n.digitalSignature,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_signatureValid) ...[
              const SizedBox(width: 8),
              Icon(Icons.verified_rounded, size: 18, color: successColor),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          l10n.signatureInstructions,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),

        // ── Canvas pad ──────────────────────────────────────────────────────
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: canvasBorder, width: 1.5),
            ),
            child: Stack(
              children: [
                Signature(
                  controller: _signatureController,
                  height: 160,
                  // Keep the pad light so the existing black pen stays visible
                  // in both themes and the exported signature remains legible.
                  backgroundColor: Colors.white,
                ),
                // Placeholder hint
                if (!_canvasValid)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Center(
                        child: Text(
                          l10n.signHere,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.lightTextSecondary,
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
                    child: IconButton(
                      tooltip: l10n.remove,
                      onPressed: () {
                        _signatureController.clear();
                        setState(() {});
                      },
                      icon: Icon(
                        Icons.refresh_rounded,
                        color: theme.colorScheme.onSurfaceVariant,
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
              l10n.signatureRequired,
              style: theme.textTheme.bodySmall?.copyWith(color: errorColor),
            ),
          ),

        const SizedBox(height: 14),

        // ── Full name field ─────────────────────────────────────────────────
        TextField(
          controller: _nameController,
          onChanged: (_) => setState(() {}),
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: l10n.fullName,
            hintText: l10n.fullNameHint,
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest,
            suffixIcon: _nameValid
                ? Icon(Icons.check_circle, color: successColor)
                : null,
          ),
        ),
        if (!_nameValid && _nameController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              l10n.registeredNameRequired,
              style: theme.textTheme.bodySmall?.copyWith(color: errorColor),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.disputeNotice,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),

        // Primary: Confirm Resolved
        FilledButton.icon(
          key: const ValueKey('citizen-review-confirm'),
          onPressed: _isSubmitting
              ? null
              : () async {
                  final error = await _submit(satisfied: true);
                  if (!mounted) return;
                  if (error != null) {
                    AppToast.error(context, error);
                  } else {
                    Navigator.of(context).pop(true);
                  }
                },
          icon: _isSubmitting
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.onPrimary,
                  ),
                )
              : const Icon(Icons.check_circle_outline),
          label: Text(l10n.confirmResolved),
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            minimumSize: const Size.fromHeight(52),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 12),

        // Secondary: Dispute / Reopen
        OutlinedButton.icon(
          key: const ValueKey('citizen-review-dispute'),
          onPressed: _isSubmitting ? null : _showDisputeSheet,
          icon: const Icon(Icons.chat_bubble_outline),
          label: Text(l10n.disputeUnresolved),
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.primary,
            side: BorderSide(color: theme.colorScheme.primary),
            minimumSize: const Size.fromHeight(52),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),

        const SizedBox(height: 12),
      ],
    );
  }

  Future<void> _showDisputeSheet() async {
    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _DisputeResolutionSheet(
        onSubmit: (reason) => _submit(satisfied: false, disputeReason: reason),
      ),
    );

    if (submitted == true && mounted) Navigator.of(context).pop(true);
  }

  Color _successColor(ThemeData theme) => theme.brightness == Brightness.dark
      ? AppColors.resolvedTextDark
      : AppColors.resolvedText;

  Color _errorColor(ThemeData theme) => theme.brightness == Brightness.dark
      ? AppColors.rejectedTextDark
      : AppColors.rejectedText;
}

class _DisputeResolutionSheet extends StatefulWidget {
  final Future<String?> Function(String reason) onSubmit;

  const _DisputeResolutionSheet({required this.onSubmit});

  @override
  State<_DisputeResolutionSheet> createState() =>
      _DisputeResolutionSheetState();
}

class _DisputeResolutionSheetState extends State<_DisputeResolutionSheet> {
  final _reasonController = TextEditingController();
  final _reasonFocusNode = FocusNode();
  String? _errorText;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    _reasonFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      setState(
        () => _errorText = AppLocalizations.of(context).disputeReasonRequired,
      );
      _reasonFocusNode.requestFocus();
      return;
    }
    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });
    final error = await widget.onSubmit(reason);
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _isSubmitting = false;
        _errorText = error;
      });
      _reasonFocusNode.requestFocus();
    } else {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              l10n.disputeResolution,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.disputeConfirmation,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            key: const ValueKey('citizen-review-dispute-reason'),
            controller: _reasonController,
            focusNode: _reasonFocusNode,
            autofocus: true,
            minLines: 4,
            maxLines: 7,
            maxLength: 1000,
            textInputAction: TextInputAction.newline,
            onChanged: (_) {
              if (_errorText != null) setState(() => _errorText = null);
            },
            decoration: InputDecoration(
              labelText: l10n.disputeReasonLabel,
              hintText: l10n.disputeReasonHint,
              errorText: _errorText,
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const ValueKey('citizen-review-dispute-submit'),
              onPressed: _isSubmitting ? null : _submit,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_outlined),
              label: Text(l10n.yesDispute),
            ),
          ),
        ],
      ),
    );
  }
}
