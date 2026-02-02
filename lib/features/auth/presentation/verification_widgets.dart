import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../kyc/data/kyc_models.dart';
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
    builder: (context) => VerificationRequiredDialog(
      permissions: permissions,
      action: action,
    ),
  );
}

/// Dialog shown when user tries to perform action requiring verification
class VerificationRequiredDialog extends StatelessWidget {
  final UserPermissions permissions;
  final String action;

  const VerificationRequiredDialog({
    super.key,
    required this.permissions,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
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
              color: AppColors.alertMedium.withOpacity(0.1),
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
            _navigateToKycAction(context, permissions);
          },
          child: Text(permissions.getActionButtonText()),
        ),
      ],
    );
  }

  void _navigateToKycAction(BuildContext context, UserPermissions permissions) {
    if (permissions.canSubmitKyc) {
      // Navigate to KYC form
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const KycFormScreen(),
        ),
      );
    } else if (permissions.canResubmitKyc) {
      // Navigate to resubmit
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => KycFormScreen(
            isResubmission: true,
            existingKyc: permissions.kycStatus,
          ),
        ),
      );
    } else {
      // Navigate to status screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const KycStatusScreen(),
        ),
      );
    }
  }
}

/// Banner widget to show at top of screens for unverified users
class VerificationBanner extends StatelessWidget {
  final UserPermissions permissions;

  const VerificationBanner({
    super.key,
    required this.permissions,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show banner if verified
    if (permissions.isVerified) {
      return const SizedBox.shrink();
    }

    final statusColor = _getStatusColor(permissions.currentStatus);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: statusColor.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: statusColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  permissions.getStatusMessage(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _navigateToKyc(context, permissions),
            style: TextButton.styleFrom(
              backgroundColor: statusColor,
              foregroundColor: Colors.white,
            ),
            child: Text(permissions.getActionButtonText()),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(KycStatus? status) {
    if (status == null) return AppColors.alertMedium;

    switch (status) {
      case KycStatus.unverified:
      case KycStatus.pending:
        return AppColors.alertMedium;
      case KycStatus.rejected:
      case KycStatus.resubmitRequested:
      case KycStatus.suspended:
        return AppColors.alertHigh;
      case KycStatus.verified:
        return AppColors.success;
    }
  }

  void _navigateToKyc(BuildContext context, UserPermissions permissions) {
    if (permissions.canSubmitKyc) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const KycFormScreen(),
        ),
      );
    } else if (permissions.canResubmitKyc) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => KycFormScreen(
            isResubmission: true,
            existingKyc: permissions.kycStatus,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const KycStatusScreen(),
        ),
      );
    }
  }
}

/// Compact inline verification prompt
class InlineVerificationPrompt extends StatelessWidget {
  final UserPermissions permissions;
  final String feature;

  const InlineVerificationPrompt({
    super.key,
    required this.permissions,
    required this.feature,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.alertMedium.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.alertMedium.withOpacity(0.3),
        ),
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
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
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
            onPressed: () => _navigateToKyc(context, permissions),
            icon: const Icon(Icons.verified_user),
            label: Text(permissions.getActionButtonText()),
          ),
        ],
      ),
    );
  }

  void _navigateToKyc(BuildContext context, UserPermissions permissions) {
    if (permissions.canSubmitKyc) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const KycFormScreen(),
        ),
      );
    } else if (permissions.canResubmitKyc) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => KycFormScreen(
            isResubmission: true,
            existingKyc: permissions.kycStatus,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const KycStatusScreen(),
        ),
      );
    }
  }
}
