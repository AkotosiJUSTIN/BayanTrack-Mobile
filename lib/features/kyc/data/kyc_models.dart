import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/utils/kyc_validators.dart';

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
  @JsonValue('gsis_ecard')
  gsisECard,
  @JsonValue('philhealth')
  philHealth,
  @JsonValue('prc')
  prcProfessionalId,
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
      case IdType.gsisECard:
        return 'GSIS eCard';
      case IdType.philHealth:
        return 'PhilHealth ID';
      case IdType.prcProfessionalId:
        return 'PRC Professional ID';
    }
  }

  String get apiValue {
    switch (this) {
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
      case IdType.gsisECard:
        return 'gsis_ecard';
      case IdType.philHealth:
        return 'philhealth';
      case IdType.prcProfessionalId:
        return 'prc';
    }
  }

  bool get requiresBackImage {
    return this == IdType.nationalId ||
        this == IdType.driversLicense ||
        this == IdType.philsys ||
        this == IdType.umid;
  }
}

// ==================== SEX ENUM ====================

enum Sex {
  @JsonValue('male')
  male,
  @JsonValue('female')
  female,
}

extension SexExtension on Sex {
  String get displayName {
    switch (this) {
      case Sex.male:
        return 'Male';
      case Sex.female:
        return 'Female';
    }
  }

  String get apiValue {
    switch (this) {
      case Sex.male:
        return 'male';
      case Sex.female:
        return 'female';
    }
  }
}

// ==================== CIVIL STATUS ENUM ====================

enum CivilStatus {
  @JsonValue('single')
  single,
  @JsonValue('married')
  married,
  @JsonValue('widowed')
  widowed,
  @JsonValue('separated')
  separated,
  @JsonValue('divorced')
  divorced,
}

extension CivilStatusExtension on CivilStatus {
  String get displayName {
    switch (this) {
      case CivilStatus.single:
        return 'Single';
      case CivilStatus.married:
        return 'Married';
      case CivilStatus.widowed:
        return 'Widowed';
      case CivilStatus.separated:
        return 'Separated';
      case CivilStatus.divorced:
        return 'Divorced';
    }
  }

  String get apiValue {
    switch (this) {
      case CivilStatus.single:
        return 'single';
      case CivilStatus.married:
        return 'married';
      case CivilStatus.widowed:
        return 'widowed';
      case CivilStatus.separated:
        return 'separated';
      case CivilStatus.divorced:
        return 'divorced';
    }
  }
}

// ==================== KYC STATUS RESPONSE ====================

@freezed
sealed class KycStatusResponse with _$KycStatusResponse {
  const factory KycStatusResponse({
    String? id,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'kyc_status') required KycStatus kycStatus,

    // Basic Identity Information
    @JsonKey(name: 'full_name') @Default('') String fullName,
    @JsonKey(name: 'first_name') String? firstName,
    @JsonKey(name: 'middle_name') String? middleName,
    @JsonKey(name: 'last_name') String? lastName,
    @JsonKey(name: 'date_of_birth') String? dateOfBirth,
    Sex? sex,
    String? nationality,
    @JsonKey(name: 'civil_status') CivilStatus? civilStatus,

    // Contact Information
    String? email,
    @JsonKey(name: 'mobile_number') String? mobileNumber,

    // Address Information
    @JsonKey(name: 'street_barangay') String? streetBarangay,
    @JsonKey(name: 'city_municipality') String? cityMunicipality,
    String? province,
    @JsonKey(name: 'zip_code') String? zipCode,

    // Government ID Details
    @JsonKey(name: 'id_type') IdType? idType,
    @JsonKey(name: 'id_number') String? idNumber,
    @JsonKey(name: 'id_expiry_date') String? idExpiryDate,

    // ID Images
    @JsonKey(name: 'id_front_image_url') String? idFrontImageUrl,
    @JsonKey(name: 'id_back_image_url') String? idBackImageUrl,
    @JsonKey(name: 'id_image_url') String? idImageUrl, // Legacy
    // Selfie Images
    @JsonKey(name: 'selfie_image_url') String? selfieImageUrl,
    @JsonKey(name: 'selfie_with_id_image_url') String? selfieWithIdImageUrl,

    // Declaration
    @JsonKey(name: 'declaration_accepted')
    @Default(false)
    bool declarationAccepted,

    // Verification Status
    @JsonKey(name: 'precheck_status') PrecheckStatus? precheckStatus,
    @JsonKey(name: 'precheck_notes') String? precheckNotes,
    @JsonKey(name: 'rejection_reason') String? rejectionReason,
    @JsonKey(name: 'admin_notes') String? adminNotes,
    @JsonKey(name: 'verified_by') String? verifiedBy,
    @JsonKey(name: 'verified_by_role') String? verifiedByRole,
    @JsonKey(name: 'resubmission_count') @Default(0) int resubmissionCount,

    // Timestamps
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
    @JsonKey(name: 'id_types') @Default([]) List<String> idTypes,
  }) = _IdTypesResponse;

  factory IdTypesResponse.fromJson(Map<String, dynamic> json) =>
      _$IdTypesResponseFromJson(json);
}

// ==================== KYC FORM OPTIONS RESPONSE ====================

@freezed
sealed class KycFormOptionsResponse with _$KycFormOptionsResponse {
  const factory KycFormOptionsResponse({
    @JsonKey(name: 'id_types') @Default([]) List<KycOptionItem> idTypes,
    @JsonKey(name: 'sex_options') @Default([]) List<KycOptionItem> sexOptions,
    @JsonKey(name: 'civil_statuses')
    @Default([])
    List<KycOptionItem> civilStatuses,
  }) = _KycFormOptionsResponse;

  factory KycFormOptionsResponse.fromJson(Map<String, dynamic> json) =>
      _$KycFormOptionsResponseFromJson(json);
}

@freezed
sealed class KycOptionItem with _$KycOptionItem {
  const factory KycOptionItem({required String value, required String label}) =
      _KycOptionItem;

  factory KycOptionItem.fromJson(Map<String, dynamic> json) =>
      _$KycOptionItemFromJson(json);
}

// ==================== KYC SUBMIT REQUEST ====================
// Used for form data structure - actual API call uses multipart/form-data

class KycSubmitRequest {
  // A. Basic Identity Information
  final String firstName;
  final String? middleName;
  final String lastName;
  final String? dateOfBirth;
  final Sex? sex;
  final String nationality;
  final CivilStatus? civilStatus;

  // B. Contact Information
  final String email;
  final String mobileNumber;

  // C. Address Information
  final String streetBarangay;
  final String cityMunicipality;
  final String province;
  final String? zipCode;

  // D. Government ID Details
  final IdType idType;
  final String idNumber;
  final String? idExpiryDate;

  // E. ID Upload Images
  final String idFrontImagePath;
  final String? idBackImagePath;

  // F. Selfie Verification
  final String selfieImagePath;
  final String? selfieWithIdImagePath;

  // G. Declaration
  final bool declarationAccepted;

  const KycSubmitRequest({
    // Basic Identity
    required this.firstName,
    this.middleName,
    required this.lastName,
    this.dateOfBirth,
    this.sex,
    required this.nationality,
    this.civilStatus,
    // Contact
    required this.email,
    required this.mobileNumber,
    // Address
    required this.streetBarangay,
    required this.cityMunicipality,
    required this.province,
    this.zipCode,
    // ID Details
    required this.idType,
    required this.idNumber,
    this.idExpiryDate,
    // Images
    required this.idFrontImagePath,
    this.idBackImagePath,
    required this.selfieImagePath,
    this.selfieWithIdImagePath,
    // Declaration
    this.declarationAccepted = true,
  });

  /// Computed full name for display
  String get fullName {
    final parts = [
      firstName,
      middleName,
      lastName,
    ].where((p) => p != null && p.isNotEmpty).toList();
    return parts.join(' ');
  }

  /// Convert to form data map for API submission
  Map<String, String> toFormDataMap() {
    return {
      // Basic Identity
      'first_name': firstName,
      if (middleName != null && middleName!.isNotEmpty)
        'middle_name': middleName!,
      'last_name': lastName,
      ...(dateOfBirth == null
          ? const <String, String>{}
          : {'date_of_birth': dateOfBirth!}),
      if (sex != null) 'sex': sex!.apiValue,
      'nationality': nationality,
      if (civilStatus != null) 'civil_status': civilStatus!.apiValue,
      // Contact
      'email': email,
      'mobile_number': KycValidators.normalizeMobileNumber(mobileNumber),
      // Address
      'street_barangay': streetBarangay,
      'city_municipality': cityMunicipality,
      'province': province,
      if (zipCode != null && zipCode!.isNotEmpty) 'zip_code': zipCode!,
      // ID Details
      'id_type': idType.apiValue,
      'id_number': idNumber,
      ...(idExpiryDate == null
          ? const <String, String>{}
          : {'id_expiry_date': idExpiryDate!}),
      // Declaration
      'declaration_accepted': declarationAccepted.toString(),
    };
  }
}

// ==================== KYC ERROR RESPONSE ====================

@freezed
sealed class KycErrorResponse with _$KycErrorResponse {
  const factory KycErrorResponse({
    required String error,
    Map<String, dynamic>? details,
  }) = _KycErrorResponse;

  factory KycErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$KycErrorResponseFromJson(json);
}
