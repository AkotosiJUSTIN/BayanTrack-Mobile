import 'package:equatable/equatable.dart';

import 'kyc_enums.dart';

/// Domain entity representing a user's KYC verification status and details.
///
/// This is a pure Dart entity with no JSON annotations.
/// Use [KycMapper] to convert to/from DTOs.
class KycStatusEntity extends Equatable {
  final String? id;
  final String? userId;
  final KycVerificationStatus status;

  // Basic Identity Information
  final String fullName;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final DateTime? dateOfBirth;
  final Sex? sex;
  final String? nationality;
  final CivilStatus? civilStatus;

  // Contact Information
  final String? email;
  final String? mobileNumber;

  // Address Information
  final String? streetBarangay;
  final String? cityMunicipality;
  final String? province;
  final String? zipCode;

  // Government ID Details
  final IdType? idType;
  final String? idNumber;
  final DateTime? idExpiryDate;

  // ID Images
  final String? idFrontImageUrl;
  final String? idBackImageUrl;

  // Selfie Images
  final String? selfieImageUrl;
  final String? selfieWithIdImageUrl;

  // Declaration
  final bool declarationAccepted;

  // Verification Status
  final PrecheckStatus? precheckStatus;
  final String? precheckNotes;
  final String? rejectionReason;
  final String? adminNotes;
  final String? verifiedBy;
  final String? verifiedByRole;
  final int resubmissionCount;

  // Timestamps
  final DateTime? submittedAt;
  final DateTime? verifiedAt;
  final DateTime? createdAt;

  const KycStatusEntity({
    this.id,
    this.userId,
    required this.status,
    this.fullName = '',
    this.firstName,
    this.middleName,
    this.lastName,
    this.dateOfBirth,
    this.sex,
    this.nationality,
    this.civilStatus,
    this.email,
    this.mobileNumber,
    this.streetBarangay,
    this.cityMunicipality,
    this.province,
    this.zipCode,
    this.idType,
    this.idNumber,
    this.idExpiryDate,
    this.idFrontImageUrl,
    this.idBackImageUrl,
    this.selfieImageUrl,
    this.selfieWithIdImageUrl,
    this.declarationAccepted = false,
    this.precheckStatus,
    this.precheckNotes,
    this.rejectionReason,
    this.adminNotes,
    this.verifiedBy,
    this.verifiedByRole,
    this.resubmissionCount = 0,
    this.submittedAt,
    this.verifiedAt,
    this.createdAt,
  });

  /// Returns true if the user can resubmit their KYC.
  bool get canResubmit => status.canResubmit;

  /// Returns true if the user is verified.
  bool get isVerified => status.isVerified;

  /// Returns true if KYC is pending review.
  bool get isPending => status.isPending;

  /// Returns true if the user has never submitted KYC.
  bool get isUnverified => status == KycVerificationStatus.unverified;

  /// Returns the computed full name from parts.
  String get computedFullName {
    final parts = [
      firstName,
      middleName,
      lastName,
    ].where((p) => p != null && p.isNotEmpty).toList();
    return parts.isEmpty ? fullName : parts.join(' ');
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    status,
    fullName,
    firstName,
    middleName,
    lastName,
    dateOfBirth,
    sex,
    nationality,
    civilStatus,
    email,
    mobileNumber,
    streetBarangay,
    cityMunicipality,
    province,
    zipCode,
    idType,
    idNumber,
    idExpiryDate,
    idFrontImageUrl,
    idBackImageUrl,
    selfieImageUrl,
    selfieWithIdImageUrl,
    declarationAccepted,
    precheckStatus,
    precheckNotes,
    rejectionReason,
    adminNotes,
    verifiedBy,
    verifiedByRole,
    resubmissionCount,
    submittedAt,
    verifiedAt,
    createdAt,
  ];
}
