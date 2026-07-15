import 'package:bayantrack_mobile/features/auth/data/user_permissions.dart';
import 'package:bayantrack_mobile/core/constants/api_constants.dart';
import 'package:bayantrack_mobile/features/kyc/domain/entities/kyc_enums.dart';
import 'package:bayantrack_mobile/features/kyc/domain/entities/kyc_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  UserPermissions permissions(KycVerificationStatus status) =>
      UserPermissions(KycStatusEntity(status: status));

  test('all non-suspended verification states retain report actions', () {
    const allowedStatuses = [
      KycVerificationStatus.unverified,
      KycVerificationStatus.pending,
      KycVerificationStatus.verified,
      KycVerificationStatus.rejected,
      KycVerificationStatus.resubmitRequested,
    ];

    for (final status in allowedStatuses) {
      final current = permissions(status);
      expect(current.hasPermission(UserPermission.createReports), isTrue);
      expect(current.hasPermission(UserPermission.updateOwnReports), isTrue);
      expect(current.hasPermission(UserPermission.deleteOwnReports), isTrue);
      expect(current.hasPermission(UserPermission.uploadImages), isTrue);
      expect(current.hasPermission(UserPermission.viewProfile), isTrue);
      expect(current.hasPermission(UserPermission.updateProfile), isTrue);
    }
  });

  test('suspended citizens cannot mutate reports', () {
    final suspended = permissions(KycVerificationStatus.suspended);

    expect(suspended.hasPermission(UserPermission.createReports), isFalse);
    expect(suspended.hasPermission(UserPermission.updateOwnReports), isFalse);
    expect(suspended.hasPermission(UserPermission.deleteOwnReports), isFalse);
    expect(suspended.hasPermission(UserPermission.uploadImages), isFalse);
  });

  test('comments stay verification-gated and export stays staff-only', () {
    final unverified = permissions(KycVerificationStatus.unverified);
    final verified = permissions(KycVerificationStatus.verified);

    expect(unverified.hasPermission(UserPermission.addComments), isFalse);
    expect(verified.hasPermission(UserPermission.addComments), isTrue);
    expect(verified.hasPermission(UserPermission.exportReports), isFalse);
  });

  test(
    'mobile uses preferred verification routes and retains legacy aliases',
    () {
      expect(ApiConstants.verificationSubmit, '/auth/verification/submit/');
      expect(ApiConstants.verificationStatus, '/auth/verification/status/');
      expect(ApiConstants.verificationResubmit, '/auth/verification/resubmit/');
      expect(ApiConstants.kycSubmit, '/auth/kyc/submit/');
      expect(ApiConstants.kycStatus, '/auth/kyc/status/');
      expect(ApiConstants.kycResubmit, '/auth/kyc/resubmit/');
    },
  );
}
