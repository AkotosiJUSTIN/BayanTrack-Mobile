import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/result.dart';
import '../../../core/presentation/failure_message.dart';
import '../../../core/presentation/widgets/app_toast.dart';
import '../../../core/presentation/widgets/civic_components.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/entities/kyc_enums.dart';
import '../domain/entities/kyc_status.dart';
import 'kyc_controller.dart';
import 'kyc_form_screen.dart';

/// KYC Status Screen - shows current verification status
class KycStatusScreen extends ConsumerWidget {
  const KycStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final kycStatusAsync = ref.watch(kycStatusControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.userVerification),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.retry,
            onPressed: () =>
                ref.read(kycStatusControllerProvider.notifier).refresh(),
          ),
        ],
      ),
      body: kycStatusAsync.when(
        data: (kycStatus) => kycStatus == null
            ? _buildNoKycView(context, ref)
            : _buildStatusView(context, ref, kycStatus),
        loading: () => Semantics(
          container: true,
          liveRegion: true,
          label: l10n.loading,
          child: ExcludeSemantics(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const CivicSkeletonBlock(height: 104),
                const SizedBox(height: 24),
                const CivicSkeletonBlock(width: 120, height: 24),
                const SizedBox(height: 16),
                for (var i = 0; i < 3; i++) ...[
                  const CivicSkeletonBlock(height: 56),
                  const SizedBox(height: 16),
                ],
                const CivicSkeletonBlock(height: 52),
              ],
            ),
          ),
        ),
        error: (_, _) => _buildErrorState(context, ref),
      ),
    );
  }

  Widget _buildNoKycView(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPageIntro(
                context,
                icon: Icons.verified_user_outlined,
                title: l10n.kyc,
                description: l10n.kycUnverified,
              ),
              const SizedBox(height: 24),
              _buildNoVerificationSubmitted(context),
              const SizedBox(height: 24),
              _buildPrivacyNote(context),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const KycFormScreen(),
                      ),
                    );
                    if (result == true) {
                      ref.read(kycStatusControllerProvider.notifier).refresh();
                    }
                  },
                  icon: const Icon(Icons.assignment_outlined),
                  label: Text(l10n.verifyIdentity),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusView(
    BuildContext context,
    WidgetRef ref,
    KycStatusEntity kycStatus,
  ) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(context, kycStatus.status);

    return RefreshIndicator(
      onRefresh: () => ref.read(kycStatusControllerProvider.notifier).refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color.alphaBlend(
                      statusColor.withValues(alpha: 0.08),
                      theme.colorScheme.surface,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            _getStatusIcon(kycStatus.status),
                            color: statusColor,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _statusLabel(kycStatus.status, l10n),
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                if (kycStatus.submittedAt != null)
                                  Text(
                                    '${l10n.submitted}: ${_formatDateTime(kycStatus.submittedAt!)}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _getStatusMessage(kycStatus.status, l10n),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (kycStatus.rejectionReason != null &&
                    kycStatus.rejectionReason!.isNotEmpty) ...[
                  _buildCallout(
                    context,
                    icon: Icons.info_outline,
                    color: theme.colorScheme.error,
                    title: l10n.adminFeedback,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kycStatus.rejectionReason!,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.reviewAndResubmit,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (kycStatus.status != KycVerificationStatus.verified &&
                    kycStatus.precheckNotes != null &&
                    kycStatus.precheckNotes!.isNotEmpty) ...[
                  _buildCallout(
                    context,
                    icon: Icons.warning_amber_rounded,
                    color: AppColors.alertMedium,
                    title: l10n.qualityCheckNotes,
                    child: Text(
                      kycStatus.precheckNotes!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                if (kycStatus.status == KycVerificationStatus.unverified)
                  _buildNoVerificationSubmitted(context)
                else ...[
                  _buildSectionHeading(
                    context,
                    icon: Icons.fact_check_outlined,
                    title: l10n.submittedInformation,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: Material(
                      color: theme.colorScheme.surfaceContainerLow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (kycStatus.computedFullName.trim().isNotEmpty)
                              _buildInfoRow(
                                l10n.fullName,
                                kycStatus.computedFullName,
                                context,
                              ),
                            if (kycStatus.idType != null)
                              _buildInfoRow(
                                l10n.idType,
                                _idTypeLabel(kycStatus.idType!, l10n),
                                context,
                              ),
                            if (kycStatus.idNumber != null)
                              _buildInfoRow(
                                l10n.idNumber,
                                kycStatus.idNumber!,
                                context,
                              ),
                            if (kycStatus.dateOfBirth != null)
                              _buildInfoRow(
                                l10n.dateOfBirth,
                                _formatDateTime(kycStatus.dateOfBirth!),
                                context,
                              ),
                            if (kycStatus.resubmissionCount > 0)
                              _buildInfoRow(
                                l10n.resubmissions,
                                kycStatus.resubmissionCount.toString(),
                                context,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                if (kycStatus.status == KycVerificationStatus.pending) ...[
                  const SizedBox(height: 16),
                  _buildWithdrawAction(context, ref),
                ],
                if (kycStatus.status.canResubmit ||
                    kycStatus.status == KycVerificationStatus.unverified) ...[
                  const SizedBox(height: 24),
                  _buildStatusAction(context, ref, kycStatus),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_outlined,
                size: 56,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.verificationLoadFailed,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.requestNetworkError,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () =>
                    ref.read(kycStatusControllerProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageIntro(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 36),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyNote(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.termsAndPrivacy,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.declarationFullText,
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoVerificationSubmitted(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return _buildCallout(
      context,
      icon: Icons.assignment_late_outlined,
      color: theme.colorScheme.onSurfaceVariant,
      title: l10n.noVerificationSubmitted,
      child: Text(l10n.verificationNotice, style: theme.textTheme.bodyMedium),
    );
  }

  Widget _buildCallout(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeading(
    BuildContext context, {
    required IconData icon,
    required String title,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusAction(
    BuildContext context,
    WidgetRef ref,
    KycStatusEntity kycStatus,
  ) {
    final l10n = AppLocalizations.of(context);
    final isResubmit = kycStatus.status.canResubmit;
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => isResubmit
                  ? KycFormScreen(isResubmission: true, existingKyc: kycStatus)
                  : const KycFormScreen(),
            ),
          );
          if (result == true) {
            ref.read(kycStatusControllerProvider.notifier).refresh();
          }
        },
        icon: Icon(isResubmit ? Icons.refresh_rounded : Icons.verified_user),
        label: Text(
          isResubmit
              ? kycStatus.resubmissionCount > 0
                    ? '${l10n.resubmitDocuments} (${l10n.retry} ${kycStatus.resubmissionCount + 1})'
                    : l10n.resubmitDocuments
              : l10n.verifyIdentity,
        ),
      ),
    );
  }

  Widget _buildWithdrawAction(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _withdrawSubmission(context, ref),
        icon: const Icon(Icons.undo_outlined),
        label: Text(l10n.withdrawSubmission),
      ),
    );
  }

  Future<void> _withdrawSubmission(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    Result<KycStatusEntity>? withdrawalResult;
    final confirmed = await showDialog<bool>(
      barrierDismissible: false,
      barrierColor: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.46),
      context: context,
      builder: (dialogContext) {
        var isWithdrawing = false;

        return StatefulBuilder(
          builder: (context, setState) {
            final theme = Theme.of(context);
            final colors = theme.colorScheme;

            Future<void> withdraw() async {
              if (isWithdrawing) return;
              setState(() => isWithdrawing = true);
              withdrawalResult = await ref
                  .read(kycStatusControllerProvider.notifier)
                  .withdrawKyc();
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext, true);
              }
            }

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ),
              backgroundColor: colors.surfaceContainerHigh,
              surfaceTintColor: Colors.transparent,
              elevation: 8,
              shadowColor: colors.shadow.withValues(alpha: 0.18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.withdrawSubmissionTitle,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        l10n.withdrawSubmissionDescription,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colors.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      if (isWithdrawing) ...[
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primaryContainer.withValues(
                              alpha: 0.6,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  l10n.loading,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colors.onPrimaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: isWithdrawing ? null : withdraw,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(l10n.withdrawSubmission),
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: isWithdrawing
                              ? null
                              : () => Navigator.pop(dialogContext, false),
                          style: TextButton.styleFrom(
                            foregroundColor: colors.onSurfaceVariant,
                            minimumSize: const Size.fromHeight(48),
                          ),
                          child: Text(l10n.cancel),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
    if (confirmed != true || !context.mounted) return;

    final result = withdrawalResult;
    if (result == null || !context.mounted) return;

    final failure = result.failureOrNull;
    if (failure != null) {
      AppToast.error(
        context,
        localizedFailureMessage(failure, l10n, fallback: l10n.withdrawalFailed),
      );
      return;
    }

    await ref.read(kycStatusControllerProvider.notifier).refresh();
    if (context.mounted) {
      AppToast.success(context, l10n.withdrawalSucceeded);
    }
  }

  Widget _buildInfoRow(String label, String value, BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }

  Color _getStatusColor(BuildContext context, KycVerificationStatus status) {
    switch (status) {
      case KycVerificationStatus.verified:
        return AppColors.success;
      case KycVerificationStatus.pending:
        return AppColors.alertMedium;
      case KycVerificationStatus.rejected:
      case KycVerificationStatus.suspended:
        return AppColors.alertHigh;
      case KycVerificationStatus.resubmitRequested:
        return AppColors.alertMedium;
      case KycVerificationStatus.unverified:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  IconData _getStatusIcon(KycVerificationStatus status) {
    switch (status) {
      case KycVerificationStatus.verified:
        return Icons.check_circle;
      case KycVerificationStatus.pending:
        return Icons.hourglass_empty;
      case KycVerificationStatus.rejected:
        return Icons.cancel;
      case KycVerificationStatus.resubmitRequested:
        return Icons.refresh;
      case KycVerificationStatus.suspended:
        return Icons.block;
      case KycVerificationStatus.unverified:
        return Icons.help_outline;
    }
  }

  String _getStatusMessage(
    KycVerificationStatus status,
    AppLocalizations l10n,
  ) {
    switch (status) {
      case KycVerificationStatus.verified:
        return l10n.kycVerified;
      case KycVerificationStatus.pending:
        return l10n.kycPending;
      case KycVerificationStatus.rejected:
        return l10n.kycRejected;
      case KycVerificationStatus.resubmitRequested:
        return l10n.kycResubmitRequested;
      case KycVerificationStatus.suspended:
        return l10n.kycSuspended;
      case KycVerificationStatus.unverified:
        return l10n.kycUnverified;
    }
  }

  String _statusLabel(KycVerificationStatus status, AppLocalizations l10n) =>
      switch (status) {
        KycVerificationStatus.unverified => l10n.unverifiedLabel,
        KycVerificationStatus.pending => l10n.pendingReview,
        KycVerificationStatus.verified => l10n.kycVerified,
        KycVerificationStatus.rejected => l10n.rejected,
        KycVerificationStatus.resubmitRequested => l10n.resubmitRequestedLabel,
        KycVerificationStatus.suspended => l10n.suspendedLabel,
      };

  String _idTypeLabel(IdType value, AppLocalizations l10n) => switch (value) {
    IdType.passport => l10n.idPassport,
    IdType.nationalId => l10n.idNational,
    IdType.driversLicense => l10n.idDriversLicense,
    IdType.philsys => l10n.idPhilsys,
    IdType.sss => l10n.idSss,
    IdType.umid => l10n.idUmid,
    IdType.postal => l10n.idPostal,
    IdType.voters => l10n.idVoters,
    IdType.gsisECard => l10n.idGsisECard,
    IdType.philHealth => l10n.idPhilHealth,
    IdType.prcProfessionalId => l10n.idPrc,
  };

  String _formatDateTime(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
