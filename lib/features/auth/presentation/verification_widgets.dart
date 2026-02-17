import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../kyc/domain/entities/kyc_enums.dart';
import '../../kyc/presentation/kyc_controller.dart';
import '../../kyc/presentation/kyc_form_screen.dart';
import '../../kyc/presentation/kyc_status_screen.dart';
import '../data/user_permissions.dart';

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
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.verified_user, color: AppColors.primary),
          SizedBox(width: 8),
          Text('Verification Required'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You need to verify your identity to $action.',
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
                  permissions.getStatusMessage(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            _navigateToKycAction(context, permissions, ref);
          },
          child: Text(permissions.getActionButtonText()),
        ),
      ],
    );
  }

  void _navigateToKycAction(BuildContext context, UserPermissions permissions, WidgetRef ref) async {
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
class VerificationBanner extends ConsumerWidget {
  final UserPermissions permissions;

  const VerificationBanner({super.key, required this.permissions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Don't show banner if verified
    if (permissions.isVerified) {
      return const SizedBox.shrink();
    }

    final statusColor = _getStatusColor(permissions.currentStatus);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        border: Border(bottom: BorderSide(color: statusColor.withValues(alpha: 0.3))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  _getStatusIcon(permissions.currentStatus),
                  color: statusColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  permissions.getStatusMessage(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: statusColor,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _navigateToKyc(context, permissions, ref),
              style: TextButton.styleFrom(
                backgroundColor: statusColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              child: Text(permissions.getActionButtonText()),
            ),
          ),
        ],
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

  void _navigateToKyc(BuildContext context, UserPermissions permissions, WidgetRef ref) async {
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.alertMedium.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.alertMedium.withValues(alpha: 0.3)),
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
            'Verify your identity to $feature',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            permissions.getStatusMessage(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _navigateToKyc(context, permissions, ref),
            icon: const Icon(Icons.verified_user),
            label: Text(permissions.getActionButtonText()),
          ),
        ],
      ),
    );
  }

  void _navigateToKyc(BuildContext context, UserPermissions permissions, WidgetRef ref) async {
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
