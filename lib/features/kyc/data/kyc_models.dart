import 'package:freezed_annotation/freezed_annotation.dart';

part 'kyc_models.freezed.dart';
part 'kyc_models.g.dart';

// ==================== KYC STATUS ENUM ====================

enum KycStatus {
  @JsonValue('unverified')
  unverified,
  @JsonValue('pending')
  pending,
  @JsonValue('verified')
  verified,
  @JsonValue('rejected')
  rejected,
  @JsonValue('resubmit_requested')
  resubmitRequested,
  @JsonValue('suspended')
  suspended,
}

extension KycStatusExtension on KycStatus {
  String get displayName {
    switch (this) {
      case KycStatus.unverified:
        return 'Unverified';
      case KycStatus.pending:
        return 'Pending Review';
      case KycStatus.verified:
        return 'Verified';
      case KycStatus.rejected:
        return 'Rejected';
      case KycStatus.resubmitRequested:
        return 'Resubmit Requested';
      case KycStatus.suspended:
        return 'Suspended';
    }
  }

  bool get canResubmit =>
      this == KycStatus.rejected || this == KycStatus.resubmitRequested;
}

// ==================== PRECHECK STATUS ====================

enum PrecheckStatus {
  @JsonValue('passed')
  passed,
  @JsonValue('failed')
  failed,
  @JsonValue('pending')
  pending,
}

// ==================== ID TYPE ====================

enum IdType {
  @JsonValue('passport')
  passport,
  @JsonValue('national_id')
  nationalId,
  @JsonValue('drivers_license')
  driversLicense,
  @JsonValue('philsys')
  philsys,
  @JsonValue('sss')
  sss,
  @JsonValue('umid')
  umid,
  @JsonValue('postal')
  postal,
  @JsonValue('voters')
  voters,
}

extension IdTypeExtension on IdType {
  String get displayName {
    switch (this) {
      case IdType.passport:
        return 'Passport';
      case IdType.nationalId:
        return 'National ID';
      case IdType.driversLicense:
        return "Driver's License";
      case IdType.philsys:
        return 'PhilSys ID';
      case IdType.sss:
        return 'SSS ID';
      case IdType.umid:
        return 'UMID';
      case IdType.postal:
        return 'Postal ID';
      case IdType.voters:
        return "Voter's ID";
    }
  }

  bool get requiresBackImage {
    return this == IdType.nationalId ||
        this == IdType.driversLicense ||
        this == IdType.philsys ||
        this == IdType.umid;
  }
}

// ==================== KYC STATUS RESPONSE ====================

@freezed
sealed class KycStatusResponse with _$KycStatusResponse {
  const factory KycStatusResponse({
    String? id,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'kyc_status') required KycStatus kycStatus,
    @JsonKey(name: 'id_type') IdType? idType,
    @JsonKey(name: 'id_number') String? idNumber,
    @JsonKey(name: 'full_name') required String fullName,
    @JsonKey(name: 'date_of_birth') String? dateOfBirth,
    @JsonKey(name: 'id_image_url') String? idImageUrl,
    @JsonKey(name: 'id_back_image_url') String? idBackImageUrl,
    @JsonKey(name: 'selfie_image_url') String? selfieImageUrl,
    @JsonKey(name: 'precheck_status') PrecheckStatus? precheckStatus,
    @JsonKey(name: 'precheck_notes') String? precheckNotes,
    @JsonKey(name: 'rejection_reason') String? rejectionReason,
    @JsonKey(name: 'admin_notes') String? adminNotes,
    @JsonKey(name: 'verified_by') String? verifiedBy,
    @JsonKey(name: 'verified_by_role') String? verifiedByRole,
    @JsonKey(name: 'resubmission_count') @Default(0) int resubmissionCount,
    @JsonKey(name: 'submitted_at') String? submittedAt,
    @JsonKey(name: 'verified_at') String? verifiedAt,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _KycStatusResponse;

  factory KycStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$KycStatusResponseFromJson(json);
}

// ==================== ID TYPES RESPONSE ====================

@freezed
sealed class IdTypesResponse with _$IdTypesResponse {
  const factory IdTypesResponse({
    @Default([]) List<String> idTypes,
  }) = _IdTypesResponse;

  factory IdTypesResponse.fromJson(Map<String, dynamic> json) =>
      _$IdTypesResponseFromJson(json);
}

// ==================== KYC SUBMIT/RESUBMIT REQUEST ====================
// Note: This is used for form data structure, not JSON serialization
// Actual API call uses multipart/form-data

class KycSubmitRequest {
  final IdType idType;
  final String? idNumber;
  final String fullName;
  final String? dateOfBirth;
  final String idImagePath;
  final String? idBackImagePath;
  final String selfieImagePath;

  const KycSubmitRequest({
    required this.idType,
    this.idNumber,
    required this.fullName,
    this.dateOfBirth,
    required this.idImagePath,
    this.idBackImagePath,
    required this.selfieImagePath,
  });

  String get idTypeValue {
    switch (idType) {
      case IdType.passport:
        return 'passport';
      case IdType.nationalId:
        return 'national_id';
      case IdType.driversLicense:
        return 'drivers_license';
      case IdType.philsys:
        return 'philsys';
      case IdType.sss:
        return 'sss';
      case IdType.umid:
        return 'umid';
      case IdType.postal:
        return 'postal';
      case IdType.voters:
        return 'voters';
    }
  }
}

// ==================== KYC ERROR RESPONSE ====================

@freezed
sealed class KycErrorResponse with _$KycErrorResponse {
  const factory KycErrorResponse({
    required String error,
    required String message,
  }) = _KycErrorResponse;

  factory KycErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$KycErrorResponseFromJson(json);
}
