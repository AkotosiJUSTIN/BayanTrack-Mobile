// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kyc_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_KycStatusResponse _$KycStatusResponseFromJson(Map<String, dynamic> json) =>
    _KycStatusResponse(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      kycStatus: $enumDecode(_$KycStatusEnumMap, json['kyc_status']),
      fullName: json['full_name'] as String? ?? '',
      firstName: json['first_name'] as String?,
      middleName: json['middle_name'] as String?,
      lastName: json['last_name'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      sex: $enumDecodeNullable(_$SexEnumMap, json['sex']),
      nationality: json['nationality'] as String?,
      civilStatus: $enumDecodeNullable(
        _$CivilStatusEnumMap,
        json['civil_status'],
      ),
      email: json['email'] as String?,
      mobileNumber: json['mobile_number'] as String?,
      streetBarangay: json['street_barangay'] as String?,
      cityMunicipality: json['city_municipality'] as String?,
      province: json['province'] as String?,
      zipCode: json['zip_code'] as String?,
      idType: $enumDecodeNullable(_$IdTypeEnumMap, json['id_type']),
      idNumber: json['id_number'] as String?,
      idExpiryDate: json['id_expiry_date'] as String?,
      idFrontImageUrl: json['id_front_image_url'] as String?,
      idBackImageUrl: json['id_back_image_url'] as String?,
      idImageUrl: json['id_image_url'] as String?,
      selfieImageUrl: json['selfie_image_url'] as String?,
      selfieWithIdImageUrl: json['selfie_with_id_image_url'] as String?,
      declarationAccepted: json['declaration_accepted'] as bool? ?? false,
      precheckStatus: $enumDecodeNullable(
        _$PrecheckStatusEnumMap,
        json['precheck_status'],
      ),
      precheckNotes: json['precheck_notes'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      adminNotes: json['admin_notes'] as String?,
      verifiedBy: json['verified_by'] as String?,
      verifiedByRole: json['verified_by_role'] as String?,
      resubmissionCount: (json['resubmission_count'] as num?)?.toInt() ?? 0,
      submittedAt: json['submitted_at'] as String?,
      verifiedAt: json['verified_at'] as String?,
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$KycStatusResponseToJson(_KycStatusResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'kyc_status': _$KycStatusEnumMap[instance.kycStatus]!,
      'full_name': instance.fullName,
      'first_name': instance.firstName,
      'middle_name': instance.middleName,
      'last_name': instance.lastName,
      'date_of_birth': instance.dateOfBirth,
      'sex': _$SexEnumMap[instance.sex],
      'nationality': instance.nationality,
      'civil_status': _$CivilStatusEnumMap[instance.civilStatus],
      'email': instance.email,
      'mobile_number': instance.mobileNumber,
      'street_barangay': instance.streetBarangay,
      'city_municipality': instance.cityMunicipality,
      'province': instance.province,
      'zip_code': instance.zipCode,
      'id_type': _$IdTypeEnumMap[instance.idType],
      'id_number': instance.idNumber,
      'id_expiry_date': instance.idExpiryDate,
      'id_front_image_url': instance.idFrontImageUrl,
      'id_back_image_url': instance.idBackImageUrl,
      'id_image_url': instance.idImageUrl,
      'selfie_image_url': instance.selfieImageUrl,
      'selfie_with_id_image_url': instance.selfieWithIdImageUrl,
      'declaration_accepted': instance.declarationAccepted,
      'precheck_status': _$PrecheckStatusEnumMap[instance.precheckStatus],
      'precheck_notes': instance.precheckNotes,
      'rejection_reason': instance.rejectionReason,
      'admin_notes': instance.adminNotes,
      'verified_by': instance.verifiedBy,
      'verified_by_role': instance.verifiedByRole,
      'resubmission_count': instance.resubmissionCount,
      'submitted_at': instance.submittedAt,
      'verified_at': instance.verifiedAt,
      'created_at': instance.createdAt,
    };

const _$KycStatusEnumMap = {
  KycStatus.unverified: 'unverified',
  KycStatus.pending: 'pending',
  KycStatus.verified: 'verified',
  KycStatus.rejected: 'rejected',
  KycStatus.resubmitRequested: 'resubmit_requested',
  KycStatus.suspended: 'suspended',
};

const _$SexEnumMap = {Sex.male: 'male', Sex.female: 'female'};

const _$CivilStatusEnumMap = {
  CivilStatus.single: 'single',
  CivilStatus.married: 'married',
  CivilStatus.widowed: 'widowed',
  CivilStatus.separated: 'separated',
  CivilStatus.divorced: 'divorced',
};

const _$IdTypeEnumMap = {
  IdType.passport: 'passport',
  IdType.nationalId: 'national_id',
  IdType.driversLicense: 'drivers_license',
  IdType.philsys: 'philsys',
  IdType.sss: 'sss',
  IdType.umid: 'umid',
  IdType.postal: 'postal',
  IdType.voters: 'voters',
  IdType.gsisECard: 'gsis_ecard',
  IdType.philHealth: 'philhealth',
  IdType.prcProfessionalId: 'prc',
};

const _$PrecheckStatusEnumMap = {
  PrecheckStatus.passed: 'passed',
  PrecheckStatus.failed: 'failed',
  PrecheckStatus.pending: 'pending',
};

_IdTypesResponse _$IdTypesResponseFromJson(Map<String, dynamic> json) =>
    _IdTypesResponse(
      idTypes:
          (json['id_types'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$IdTypesResponseToJson(_IdTypesResponse instance) =>
    <String, dynamic>{'id_types': instance.idTypes};

_KycFormOptionsResponse _$KycFormOptionsResponseFromJson(
  Map<String, dynamic> json,
) => _KycFormOptionsResponse(
  idTypes:
      (json['id_types'] as List<dynamic>?)
          ?.map((e) => KycOptionItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  sexOptions:
      (json['sex_options'] as List<dynamic>?)
          ?.map((e) => KycOptionItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  civilStatuses:
      (json['civil_statuses'] as List<dynamic>?)
          ?.map((e) => KycOptionItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$KycFormOptionsResponseToJson(
  _KycFormOptionsResponse instance,
) => <String, dynamic>{
  'id_types': instance.idTypes,
  'sex_options': instance.sexOptions,
  'civil_statuses': instance.civilStatuses,
};

_KycOptionItem _$KycOptionItemFromJson(Map<String, dynamic> json) =>
    _KycOptionItem(
      value: json['value'] as String,
      label: json['label'] as String,
    );

Map<String, dynamic> _$KycOptionItemToJson(_KycOptionItem instance) =>
    <String, dynamic>{'value': instance.value, 'label': instance.label};

_KycErrorResponse _$KycErrorResponseFromJson(Map<String, dynamic> json) =>
    _KycErrorResponse(
      error: json['error'] as String,
      details: json['details'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$KycErrorResponseToJson(_KycErrorResponse instance) =>
    <String, dynamic>{'error': instance.error, 'details': instance.details};
