import 'package:bayantrack_mobile/features/auth/data/user_permissions.dart';
import 'package:bayantrack_mobile/features/kyc/domain/entities/kyc_enums.dart';
import 'package:bayantrack_mobile/features/kyc/domain/entities/kyc_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  UserPermissions permissions(KycVerificationStatus status) =>
      UserPermissions(KycStatusEntity(status: status));

  test('unverified citizens can create, edit, and add report evidence', () {
    final unverified = permissions(KycVerificationStatus.unverified);

    expect(unverified.hasPermission(UserPermission.createReports), isTrue);
    expect(unverified.hasPermission(UserPermission.updateOwnReports), isTrue);
    expect(unverified.hasPermission(UserPermission.deleteOwnReports), isTrue);
    expect(unverified.hasPermission(UserPermission.uploadImages), isTrue);
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
}
