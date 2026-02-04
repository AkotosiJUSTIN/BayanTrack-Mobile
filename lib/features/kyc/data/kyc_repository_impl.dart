import 'dart:io';

import '../../../core/domain/result.dart';
import '../../../core/network/error_mapper.dart';
import '../domain/entities/kyc_form_options.dart';
import '../domain/entities/kyc_status.dart';
import '../domain/kyc_repository.dart' as domain;
import 'kyc_models.dart';
import 'kyc_repository.dart' as legacy;
import 'mappers/kyc_mapper.dart';

/// Implementation of [domain.KycRepository] using the legacy data repository.
///
/// This wraps all operations with [Result] for explicit error handling.
class KycRepositoryImpl implements domain.KycRepository {
  final legacy.KycRepository _legacyRepo;

  KycRepositoryImpl(this._legacyRepo);

  @override
  Future<Result<List<String>>> getIdTypes() async {
    try {
      final idTypes = await _legacyRepo.getIdTypes();
      return Success(idTypes);
    } catch (e, stack) {
      return Err(ErrorMapper.mapException(e, stack));
    }
  }

  @override
  Future<Result<KycFormOptions>> getFormOptions() async {
    try {
      final dto = await _legacyRepo.getFormOptions();
      return Success(KycMapper.toKycFormOptions(dto));
    } catch (e, stack) {
      return Err(ErrorMapper.mapException(e, stack));
    }
  }

  @override
  Future<Result<KycStatusEntity>> getKycStatus() async {
    try {
      final dto = await _legacyRepo.getKycStatus();
      return Success(KycMapper.toKycStatusEntity(dto));
    } catch (e, stack) {
      return Err(ErrorMapper.mapException(e, stack));
    }
  }

  @override
  Future<Result<KycStatusEntity>> submitKyc({
    required String firstName,
    String? middleName,
    required String lastName,
    String? dateOfBirth,
    String? sex,
    required String nationality,
    String? civilStatus,
    required String email,
    required String mobileNumber,
    required String streetBarangay,
    required String cityMunicipality,
    required String province,
    String? zipCode,
    required String idType,
    required String idNumber,
    String? idExpiryDate,
    required String idFrontImagePath,
    String? idBackImagePath,
    required String selfieImagePath,
    String? selfieWithIdImagePath,
    bool declarationAccepted = true,
  }) async {
    try {
      final request = KycSubmitRequest(
        firstName: firstName,
        middleName: middleName,
        lastName: lastName,
        dateOfBirth: dateOfBirth,
        sex: _parseSex(sex),
        nationality: nationality,
        civilStatus: _parseCivilStatus(civilStatus),
        email: email,
        mobileNumber: mobileNumber,
        streetBarangay: streetBarangay,
        cityMunicipality: cityMunicipality,
        province: province,
        zipCode: zipCode,
        idType: _parseIdType(idType),
        idNumber: idNumber,
        idExpiryDate: idExpiryDate,
        idFrontImagePath: idFrontImagePath,
        idBackImagePath: idBackImagePath,
        selfieImagePath: selfieImagePath,
        selfieWithIdImagePath: selfieWithIdImagePath,
        declarationAccepted: declarationAccepted,
      );

      final dto = await _legacyRepo.submitKyc(request);
      return Success(KycMapper.toKycStatusEntity(dto));
    } catch (e, stack) {
      return Err(ErrorMapper.mapException(e, stack));
    }
  }

  @override
  Future<Result<KycStatusEntity>> resubmitKyc({
    required String firstName,
    String? middleName,
    required String lastName,
    String? dateOfBirth,
    String? sex,
    required String nationality,
    String? civilStatus,
    required String email,
    required String mobileNumber,
    required String streetBarangay,
    required String cityMunicipality,
    required String province,
    String? zipCode,
    required String idType,
    required String idNumber,
    String? idExpiryDate,
    required String idFrontImagePath,
    String? idBackImagePath,
    required String selfieImagePath,
    String? selfieWithIdImagePath,
    bool declarationAccepted = true,
  }) async {
    try {
      final request = KycSubmitRequest(
        firstName: firstName,
        middleName: middleName,
        lastName: lastName,
        dateOfBirth: dateOfBirth,
        sex: _parseSex(sex),
        nationality: nationality,
        civilStatus: _parseCivilStatus(civilStatus),
        email: email,
        mobileNumber: mobileNumber,
        streetBarangay: streetBarangay,
        cityMunicipality: cityMunicipality,
        province: province,
        zipCode: zipCode,
        idType: _parseIdType(idType),
        idNumber: idNumber,
        idExpiryDate: idExpiryDate,
        idFrontImagePath: idFrontImagePath,
        idBackImagePath: idBackImagePath,
        selfieImagePath: selfieImagePath,
        selfieWithIdImagePath: selfieWithIdImagePath,
        declarationAccepted: declarationAccepted,
      );

      final dto = await _legacyRepo.resubmitKyc(request);
      return Success(KycMapper.toKycStatusEntity(dto));
    } catch (e, stack) {
      return Err(ErrorMapper.mapException(e, stack));
    }
  }

  @override
  List<String> validateImages({
    required String idFrontImagePath,
    String? idBackImagePath,
    required String selfieImagePath,
    String? selfieWithIdImagePath,
  }) {
    final errors = <String>[];

    if (!_isValidImageSize(idFrontImagePath)) {
      errors.add('ID front image must be less than 10MB');
    }

    if (idBackImagePath != null &&
        idBackImagePath.isNotEmpty &&
        !_isValidImageSize(idBackImagePath)) {
      errors.add('ID back image must be less than 10MB');
    }

    if (!_isValidImageSize(selfieImagePath)) {
      errors.add('Selfie image must be less than 10MB');
    }

    if (selfieWithIdImagePath != null &&
        selfieWithIdImagePath.isNotEmpty &&
        !_isValidImageSize(selfieWithIdImagePath)) {
      errors.add('Selfie with ID image must be less than 10MB');
    }

    return errors;
  }

  bool _isValidImageSize(String filePath) {
    final file = File(filePath);
    final fileSizeInBytes = file.lengthSync();
    final fileSizeInMB = fileSizeInBytes / (1024 * 1024);
    return fileSizeInMB <= 10;
  }

  // ==================== ENUM PARSING HELPERS ====================

  Sex? _parseSex(String? value) {
    if (value == null) return null;
    return switch (value.toLowerCase()) {
      'male' => Sex.male,
      'female' => Sex.female,
      _ => null,
    };
  }

  CivilStatus? _parseCivilStatus(String? value) {
    if (value == null) return null;
    return switch (value.toLowerCase()) {
      'single' => CivilStatus.single,
      'married' => CivilStatus.married,
      'widowed' => CivilStatus.widowed,
      'separated' => CivilStatus.separated,
      'divorced' => CivilStatus.divorced,
      _ => null,
    };
  }

  IdType _parseIdType(String value) {
    return switch (value.toLowerCase()) {
      'passport' => IdType.passport,
      'national_id' => IdType.nationalId,
      'drivers_license' => IdType.driversLicense,
      'philsys' => IdType.philsys,
      'sss' => IdType.sss,
      'umid' => IdType.umid,
      'postal' => IdType.postal,
      'voters' => IdType.voters,
      _ => IdType.nationalId,
    };
  }
}
