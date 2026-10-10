import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../kyc/domain/entities/kyc_enums.dart';
import '../../kyc/presentation/kyc_controller.dart';
import '../../kyc/presentation/kyc_form_screen.dart';
import '../../kyc/presentation/kyc_status_screen.dart';
import '../data/user_permissions.dart';

String localizedVerificationStatusMessage(
  UserPermissions permissions,
  AppLocalizations l10n,
) {
  return switch (permissions.currentStatus) {
    null || KycVerificationStatus.unverified => l10n.kycUnverified,
    KycVerificationStatus.pending => l10n.kycPending,
    KycVerificationStatus.verified => l10n.kycVerified,
    KycVerificationStatus.rejected => l10n.kycRejected,
    KycVerificationStatus.resubmitRequested => l10n.kycResubmitRequested,
    KycVerificationStatus.suspended => l10n.kycSuspended,
  };
}

String localizedVerificationActionLabel(
  UserPermissions permissions,
  AppLocalizations l10n,
) {
  if (permissions.canSubmitKyc) return l10n.verifyIdentity;
  if (permissions.canResubmitKyc) return l10n.resubmitDocuments;
  if (permissions.isSuspended) return l10n.contactSupport;
  return l10n.viewStatus;
}

/// Show verification required dialog
Future<void> showVerificationRequiredDialog(
  BuildContext context,
  UserPermissions permissions,
  String action,
) async {
  return showDialog(
    context: context,
    builder: (context) =>
        VerificationRequiredDialog(permissions: permissions, action: action),
  );
}

/// Dialog shown when user tries to perform action requiring verification
class VerificationRequiredDialog extends ConsumerWidget {
  final UserPermissions permissions;
  final String action;

  const VerificationRequiredDialog({
    super.key,
    required this.permissions,
    required this.action,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final actionLabel = localizedVerificationActionLabel(permissions, l10n);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.verified_user, color: AppColors.primary),
          SizedBox(width: 8),
          Text(l10n.verificationRequired),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.verifyIdentityTo(action),
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.alertMedium.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizedVerificationStatusMessage(permissions, l10n),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _navigateToKycAction(context, permissions, ref);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.alertMedium,
                foregroundColor: Colors.white,
              ),
              child: Text(actionLabel),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
          ),
        ],
      ),
      actions: const [],
    );
  }

  void _navigateToKycAction(
    BuildContext context,
    UserPermissions permissions,
    WidgetRef ref,
  ) async {
    if (permissions.canSubmitKyc) {
      // Navigate to KYC form
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const KycFormScreen()),
      );
      if (result == true) {
        ref.read(kycStatusControllerProvider.notifier).refresh();
      }
    } else if (permissions.canResubmitKyc) {
      // Navigate to resubmit
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => KycFormScreen(
            isResubmission: true,
            existingKyc: permissions.kycStatus,
          ),
        ),
      );
      if (result == true) {
        ref.read(kycStatusControllerProvider.notifier).refresh();
      }
    } else {
      // Navigate to status screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const KycStatusScreen()),
      );
    }
  }
}

/// Banner widget to show at top of screens for unverified users
class VerificationBanner extends ConsumerStatefulWidget {
  final UserPermissions permissions;
  final bool compact;

  const VerificationBanner({
    super.key,
    required this.permissions,
    this.compact = false,
  });

  @override
  ConsumerState<VerificationBanner> createState() => _VerificationBannerState();
}

class _VerificationBannerState extends ConsumerState<VerificationBanner> {
  bool _isExpanded = false;

  UserPermissions get permissions => widget.permissions;

  @override
  Widget build(BuildContext context) {
    // Don't show banner if verified
    if (permissions.isVerified) {
      return const SizedBox.shrink();
    }

    final statusColor = _getStatusColor(permissions.currentStatus);

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final actionLabel = localizedVerificationActionLabel(permissions, l10n);

    final statusMessage = localizedVerificationStatusMessage(permissions, l10n);
    if (widget.compact) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
        child: Material(
          key: const Key('home-verification-banner'),
          color: Color.alphaBlend(
            statusColor.withValues(alpha: 0.08),
            theme.colorScheme.surface,
          ),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        key: const Key('home-verification-action'),
                        onPressed: () =>
                            _navigateToKyc(context, permissions, ref),
                        style: TextButton.styleFrom(
                          alignment: Alignment.centerLeft,
                          minimumSize: const Size(0, 48),
                        ),
                        icon: Icon(
                          _getStatusIcon(permissions.currentStatus),
                          color: statusColor,
                          size: 20,
                        ),
                        label: Text(actionLabel),
                      ),
                    ),
                    Semantics(
                      expanded: _isExpanded,
                      child: IconButton(
                        key: const Key('home-verification-toggle'),
                        tooltip: _isExpanded
                            ? MaterialLocalizations.of(
                                context,
                              ).expandedIconTapHint
                            : MaterialLocalizations.of(
                                context,
                              ).collapsedIconTapHint,
                        onPressed: () =>
                            setState(() => _isExpanded = !_isExpanded),
                        icon: Icon(
                          _isExpanded ? Icons.expand_less : Icons.expand_more,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_isExpanded)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.userVerification,
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          statusMessage,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    final action = TextButton.icon(
      onPressed: () => _navigateToKyc(context, permissions, ref),
      style: TextButton.styleFrom(
        foregroundColor: theme.colorScheme.primary,
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 10),
      ),
      icon: const Icon(Icons.arrow_forward, size: 18),
      label: Text(actionLabel),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Semantics(
        container: true,
        label: '${l10n.userVerification}: $statusMessage',
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
          decoration: BoxDecoration(
            color: Color.alphaBlend(
              statusColor.withValues(alpha: 0.08),
              theme.colorScheme.surface,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 420;
              final content = Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _getStatusIcon(permissions.currentStatus),
                    color: statusColor,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.userVerification,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          statusMessage,
                          maxLines: compact ? 3 : 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!compact) ...[const SizedBox(width: 8), action],
                ],
              );

              return compact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [content, action],
                    )
                  : content;
            },
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(KycVerificationStatus? status) {
    if (status == null) return AppColors.alertMedium;

    switch (status) {
      case KycVerificationStatus.unverified:
      case KycVerificationStatus.pending:
        return AppColors.alertMedium;
      case KycVerificationStatus.rejected:
      case KycVerificationStatus.resubmitRequested:
      case KycVerificationStatus.suspended:
        return AppColors.alertHigh;
      case KycVerificationStatus.verified:
        return AppColors.success;
    }
  }

  IconData _getStatusIcon(KycVerificationStatus? status) {
    if (status == null) return Icons.shield_outlined;

    switch (status) {
      case KycVerificationStatus.unverified:
        return Icons.shield_outlined;
      case KycVerificationStatus.pending:
        return Icons.hourglass_empty;
      case KycVerificationStatus.rejected:
        return Icons.cancel_outlined;
      case KycVerificationStatus.resubmitRequested:
        return Icons.refresh;
      case KycVerificationStatus.suspended:
        return Icons.block;
      case KycVerificationStatus.verified:
        return Icons.verified_user;
    }
  }

  void _navigateToKyc(
    BuildContext context,
    UserPermissions permissions,
    WidgetRef ref,
  ) async {
    if (permissions.canSubmitKyc) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const KycFormScreen()),
      );
      if (result == true) {
        ref.read(kycStatusControllerProvider.notifier).refresh();
      }
    } else if (permissions.canResubmitKyc) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => KycFormScreen(
            isResubmission: true,
            existingKyc: permissions.kycStatus,
          ),
        ),
      );
      if (result == true) {
        ref.read(kycStatusControllerProvider.notifier).refresh();
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const KycStatusScreen()),
      );
    }
  }
}

/// Compact inline verification prompt
class InlineVerificationPrompt extends ConsumerWidget {
  final UserPermissions permissions;
  final String feature;

  const InlineVerificationPrompt({
    super.key,
    required this.permissions,
    required this.feature,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          AppColors.alertMedium.withValues(alpha: 0.1),
          Theme.of(context).colorScheme.surface,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.lock_outline,
            size: 48,
            color: AppColors.alertMedium,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.verifyIdentityTo(feature),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            localizedVerificationStatusMessage(permissions, l10n),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _navigateToKyc(context, permissions, ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.alertMedium,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.verified_user),
            label: Text(localizedVerificationActionLabel(permissions, l10n)),
          ),
        ],
      ),
    );
  }

  void _navigateToKyc(
    BuildContext context,
    UserPermissions permissions,
    WidgetRef ref,
  ) async {
    if (permissions.canSubmitKyc) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const KycFormScreen()),
      );
      if (result == true) {
        ref.read(kycStatusControllerProvider.notifier).refresh();
      }
    } else if (permissions.canResubmitKyc) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => KycFormScreen(
            isResubmission: true,
            existingKyc: permissions.kycStatus,
          ),
        ),
      );
      if (result == true) {
        ref.read(kycStatusControllerProvider.notifier).refresh();
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const KycStatusScreen()),
      );
    }
  }
}
