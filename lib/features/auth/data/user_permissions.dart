import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../kyc/domain/entities/kyc_enums.dart';
import '../../kyc/domain/entities/kyc_status.dart';
import '../../kyc/presentation/kyc_controller.dart';

/// KYC-based permissions service
/// Determines what actions a user can perform based on their KYC verification status
///
/// IMPORTANT: Suspended users should be blocked at login by the backend.
/// If a suspended user somehow has an active session, they will have read-only access
/// like other unverified users, but ideally they should not be able to login at all.

// ==================== PERMISSION ENUMS ====================

enum UserPermission {
  // Basic permissions (always allowed)
  viewProfile,
  updateProfile,
  changePassword,
  resetPassword,
  viewReports,
  viewReportDetails,
  searchReports,

  // KYC related
  submitKyc,
  resubmitKyc,
  viewKycStatus,

  // Verified user only
  createReports,
  updateOwnReports,
  deleteOwnReports,
  uploadImages,
  addComments,
  exportReports,
}

// ==================== PERMISSIONS PROVIDER ====================

final userPermissionsProvider = Provider<UserPermissions>((ref) {
  final kycStatusAsync = ref.watch(kycStatusControllerProvider);

  return kycStatusAsync.when(
    data: (kycStatus) => UserPermissions(kycStatus),
    loading: () => UserPermissions(null),
    error: (_, __) => UserPermissions(null),
  );
});

// ==================== USER PERMISSIONS CLASS ====================

class UserPermissions {
  final KycStatusEntity? kycStatus;

  UserPermissions(this.kycStatus);

  /// Check if user is verified
  bool get isVerified => kycStatus?.status == KycVerificationStatus.verified;

  /// Check if user is unverified, pending, rejected, or suspended
  /// Note: All these statuses have the same limited permissions (read-only)
  /// Suspended users should be prevented from logging in at the auth level
  bool get isUnverified =>
      kycStatus == null ||
      kycStatus!.status == KycVerificationStatus.unverified ||
      kycStatus!.status == KycVerificationStatus.pending ||
      kycStatus!.status == KycVerificationStatus.rejected ||
      kycStatus!.status == KycVerificationStatus.resubmitRequested ||
      kycStatus!.status == KycVerificationStatus.suspended;

  /// Check if user is suspended (should not be logged in)
  bool get isSuspended => kycStatus?.status == KycVerificationStatus.suspended;

  /// Check if user can resubmit KYC
  bool get canResubmitKyc => kycStatus?.status.canResubmit ?? false;

  /// Check if user can submit KYC for the first time
  bool get canSubmitKyc =>
      kycStatus == null ||
      kycStatus!.status == KycVerificationStatus.unverified;

  /// Get user's KYC status
  KycVerificationStatus? get currentStatus => kycStatus?.status;

  // ==================== PERMISSION CHECKS ====================

  /// Check if user has a specific permission
  bool hasPermission(UserPermission permission) {
    switch (permission) {
      // Always allowed - basic permissions
      case UserPermission.viewProfile:
      case UserPermission.updateProfile:
      case UserPermission.changePassword:
      case UserPermission.resetPassword:
      case UserPermission.viewReports:
      case UserPermission.viewReportDetails:
      case UserPermission.searchReports:
      case UserPermission.viewKycStatus:
        return true;

      // KYC submission (only if not verified)
      case UserPermission.submitKyc:
        return canSubmitKyc;

      case UserPermission.resubmitKyc:
        return canResubmitKyc;

      // All authenticated (non-suspended) users
      case UserPermission.createReports:
      case UserPermission.updateOwnReports:
      case UserPermission.deleteOwnReports:
      case UserPermission.uploadImages:
      case UserPermission.addComments:
      case UserPermission.exportReports:
        return !isSuspended;
    }
  }

  /// Get reason why permission is denied
  String getDenialReason(UserPermission permission) {
    if (!isVerified) {
      switch (permission) {
        case UserPermission.createReports:
          return 'You must verify your identity to create reports';
        case UserPermission.updateOwnReports:
          return 'You must verify your identity to update reports';
        case UserPermission.deleteOwnReports:
          return 'You must verify your identity to delete reports';
        case UserPermission.uploadImages:
          return 'You must verify your identity to upload images';
        case UserPermission.addComments:
          return 'You must verify your identity to add comments';
        case UserPermission.exportReports:
          return 'You must verify your identity to export reports';
        default:
          return 'You must verify your identity to perform this action';
      }
    }
    return 'You do not have permission to perform this action';
  }

  /// Get a user-friendly message about current KYC status
  String getStatusMessage() {
    if (kycStatus == null) {
      return 'Complete identity verification to unlock all features';
    }

    switch (kycStatus!.status) {
      case KycVerificationStatus.unverified:
        return 'Complete identity verification to unlock all features';
      case KycVerificationStatus.pending:
        return 'Your verification is pending review. You\'ll have full access once approved.';
      case KycVerificationStatus.verified:
        return 'Your identity is verified. You have full access!';
      case KycVerificationStatus.rejected:
        final count = kycStatus!.resubmissionCount;
        if (count > 0) {
          return 'Your verification was rejected. Please resubmit your documents. (Attempt ${count + 1})';
        }
        return 'Your verification was rejected. Please resubmit your documents.';
      case KycVerificationStatus.resubmitRequested:
        final count = kycStatus!.resubmissionCount;
        if (count > 0) {
          return 'Additional information is required. Please resubmit your documents. (Attempt ${count + 1})';
        }
        return 'Additional information is required. Please resubmit your documents.';
      case KycVerificationStatus.suspended:
        return 'Your account verification is suspended. Please contact support.';
    }
  }

  /// Get action button text for KYC status
  String getActionButtonText() {
    if (kycStatus == null ||
        kycStatus!.status == KycVerificationStatus.unverified) {
      return 'Verify Identity';
    }

    switch (kycStatus!.status) {
      case KycVerificationStatus.pending:
        return 'View Status';
      case KycVerificationStatus.verified:
        return 'View Verification';
      case KycVerificationStatus.rejected:
      case KycVerificationStatus.resubmitRequested:
        return 'Resubmit Documents';
      case KycVerificationStatus.suspended:
        return 'Contact Support';
      case KycVerificationStatus.unverified:
        return 'Verify Identity';
    }
  }

  /// Check if feature should be shown (but may be disabled)
  bool shouldShowFeature(UserPermission permission) {
    // Show KYC submission only for unverified users
    if (permission == UserPermission.submitKyc) {
      return !isVerified;
    }

    // Show resubmit only if can resubmit
    if (permission == UserPermission.resubmitKyc) {
      return canResubmitKyc;
    }

    // Always show other features (they may be disabled)
    return true;
  }
}

// ==================== PERMISSION RESULT ====================

class PermissionCheckResult {
  final bool allowed;
  final String? denialReason;

  const PermissionCheckResult.allowed() : allowed = true, denialReason = null;

  const PermissionCheckResult.denied(this.denialReason) : allowed = false;

  bool get isDenied => !allowed;
}

// ==================== HELPER EXTENSION ====================

extension UserPermissionsExtension on UserPermissions {
  /// Check permission and return result with reason
  PermissionCheckResult check(UserPermission permission) {
    if (hasPermission(permission)) {
      return const PermissionCheckResult.allowed();
    }
    return PermissionCheckResult.denied(getDenialReason(permission));
  }
}
