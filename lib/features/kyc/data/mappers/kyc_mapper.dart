import '../../domain/entities/kyc_enums.dart';
import '../../domain/entities/kyc_form_options.dart' as domain;
import '../../domain/entities/kyc_status.dart';
import '../kyc_models.dart' as dto;

/// Mapper for converting KYC DTOs to domain entities and vice versa.
class KycMapper {
  KycMapper._(); // Prevent instantiation

  // ==================== KYC STATUS MAPPING ====================

  /// Convert [dto.KycStatusResponse] DTO to [KycStatusEntity].
  static KycStatusEntity toKycStatusEntity(dto.KycStatusResponse dtoObj) {
    return KycStatusEntity(
      id: dtoObj.id,
      userId: dtoObj.userId,
      status: _mapKycStatus(dtoObj.kycStatus),
      fullName: dtoObj.fullName,
      firstName: dtoObj.firstName,
      middleName: dtoObj.middleName,
      lastName: dtoObj.lastName,
      dateOfBirth: _parseDateTime(dtoObj.dateOfBirth),
      sex: dtoObj.sex != null ? Sex.fromString(dtoObj.sex!.name) : null,
      nationality: dtoObj.nationality,
      civilStatus: dtoObj.civilStatus != null
          ? CivilStatus.fromString(dtoObj.civilStatus!.name)
          : null,
      email: dtoObj.email,
      mobileNumber: dtoObj.mobileNumber,
      streetBarangay: dtoObj.streetBarangay,
      cityMunicipality: dtoObj.cityMunicipality,
      province: dtoObj.province,
      zipCode: dtoObj.zipCode,
      idType: dtoObj.idType != null
          ? IdType.fromString(dtoObj.idType!.name)
          : null,
      idNumber: dtoObj.idNumber,
      idExpiryDate: _parseDateTime(dtoObj.idExpiryDate),
      idFrontImageUrl: dtoObj.idFrontImageUrl ?? dtoObj.idImageUrl,
      idBackImageUrl: dtoObj.idBackImageUrl,
      selfieImageUrl: dtoObj.selfieImageUrl,
      selfieWithIdImageUrl: dtoObj.selfieWithIdImageUrl,
      declarationAccepted: dtoObj.declarationAccepted,
      precheckStatus: dtoObj.precheckStatus != null
          ? PrecheckStatus.fromString(dtoObj.precheckStatus!.name)
          : null,
      precheckNotes: dtoObj.precheckNotes,
      rejectionReason: dtoObj.rejectionReason,
      adminNotes: dtoObj.adminNotes,
      verifiedBy: dtoObj.verifiedBy,
      verifiedByRole: dtoObj.verifiedByRole,
      resubmissionCount: dtoObj.resubmissionCount,
      submittedAt: _parseDateTime(dtoObj.submittedAt),
      verifiedAt: _parseDateTime(dtoObj.verifiedAt),
      createdAt: _parseDateTime(dtoObj.createdAt),
    );
  }

  static KycVerificationStatus _mapKycStatus(dto.KycStatus dtoStatus) {
    return switch (dtoStatus) {
      dto.KycStatus.unverified => KycVerificationStatus.unverified,
      dto.KycStatus.pending => KycVerificationStatus.pending,
      dto.KycStatus.verified => KycVerificationStatus.verified,
      dto.KycStatus.rejected => KycVerificationStatus.rejected,
      dto.KycStatus.resubmitRequested =>
        KycVerificationStatus.resubmitRequested,
      dto.KycStatus.suspended => KycVerificationStatus.suspended,
    };
  }

  // ==================== FORM OPTIONS MAPPING ====================

  /// Convert [dto.KycFormOptionsResponse] DTO to [domain.KycFormOptions].
  static domain.KycFormOptions toKycFormOptions(
    dto.KycFormOptionsResponse formDto,
  ) {
    return domain.KycFormOptions(
      idTypes: formDto.idTypes
          .where(
            (option) => dto.supportedCitizenIdApiValues.contains(option.value),
          )
          .map(_toKycOptionItem)
          .toList(),
      sexOptions: formDto.sexOptions.map(_toKycOptionItem).toList(),
      civilStatuses: formDto.civilStatuses.map(_toKycOptionItem).toList(),
    );
  }

  static domain.KycOptionItem _toKycOptionItem(dto.KycOptionItem optionDto) {
    return domain.KycOptionItem(value: optionDto.value, label: optionDto.label);
  }

  // ==================== HELPERS ====================

  static DateTime? _parseDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    return DateTime.tryParse(dateString);
  }
}
