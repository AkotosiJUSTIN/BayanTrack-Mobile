// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kyc_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_KycStatusResponse _$KycStatusResponseFromJson(Map<String, dynamic> json) =>
    _KycStatusResponse(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      kycStatus: $enumDecode(_$KycStatusEnumMap, json['kyc_status']),
      idType: $enumDecode(_$IdTypeEnumMap, json['id_type']),
      idNumber: json['id_number'] as String?,
      fullName: json['full_name'] as String,
      dateOfBirth: json['date_of_birth'] as String?,
      idImageUrl: json['id_image_url'] as String?,
      idBackImageUrl: json['id_back_image_url'] as String?,
      selfieImageUrl: json['selfie_image_url'] as String?,
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
      'id_type': _$IdTypeEnumMap[instance.idType]!,
      'id_number': instance.idNumber,
      'full_name': instance.fullName,
      'date_of_birth': instance.dateOfBirth,
      'id_image_url': instance.idImageUrl,
      'id_back_image_url': instance.idBackImageUrl,
      'selfie_image_url': instance.selfieImageUrl,
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

const _$IdTypeEnumMap = {
  IdType.passport: 'passport',
  IdType.nationalId: 'national_id',
  IdType.driversLicense: 'drivers_license',
  IdType.philsys: 'philsys',
  IdType.sss: 'sss',
  IdType.umid: 'umid',
  IdType.postal: 'postal',
  IdType.voters: 'voters',
};

const _$PrecheckStatusEnumMap = {
  PrecheckStatus.passed: 'passed',
  PrecheckStatus.failed: 'failed',
  PrecheckStatus.pending: 'pending',
};

_IdTypesResponse _$IdTypesResponseFromJson(Map<String, dynamic> json) =>
    _IdTypesResponse(
      idTypes:
          (json['idTypes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$IdTypesResponseToJson(_IdTypesResponse instance) =>
    <String, dynamic>{'idTypes': instance.idTypes};

_KycErrorResponse _$KycErrorResponseFromJson(Map<String, dynamic> json) =>
    _KycErrorResponse(
      error: json['error'] as String,
      message: json['message'] as String,
    );

Map<String, dynamic> _$KycErrorResponseToJson(_KycErrorResponse instance) =>
    <String, dynamic>{'error': instance.error, 'message': instance.message};
