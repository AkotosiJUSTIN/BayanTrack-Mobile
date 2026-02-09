import '../../../../core/domain/result.dart';
import '../entities/kyc_status.dart';
import '../kyc_repository.dart';

/// Parameters for submitting KYC documents.
class SubmitKycParams {
  final String firstName;
  final String? middleName;
  final String lastName;
  final String? dateOfBirth;
  final String? sex;
  final String nationality;
  final String? civilStatus;
  final String email;
  final String mobileNumber;
  final String streetBarangay;
  final String cityMunicipality;
  final String province;
  final String? zipCode;
  final String idType;
  final String idNumber;
  final String? idExpiryDate;
  final String idFrontImagePath;
  final String? idBackImagePath;
  final String selfieImagePath;
  final String? selfieWithIdImagePath;
  final bool declarationAccepted;

  const SubmitKycParams({
    required this.firstName,
    this.middleName,
    required this.lastName,
    this.dateOfBirth,
    this.sex,
    required this.nationality,
    this.civilStatus,
    required this.email,
    required this.mobileNumber,
    required this.streetBarangay,
    required this.cityMunicipality,
    required this.province,
    this.zipCode,
    required this.idType,
    required this.idNumber,
    this.idExpiryDate,
    required this.idFrontImagePath,
    this.idBackImagePath,
    required this.selfieImagePath,
    this.selfieWithIdImagePath,
    this.declarationAccepted = true,
  });
}

/// Use case for initial KYC document submission.
class SubmitKycUseCase {
  final KycRepository _repository;

  const SubmitKycUseCase({required KycRepository repository})
    : _repository = repository;

  /// Submits KYC documents for verification.
  ///
  /// Returns [KycStatusEntity] on success, or a [Failure] on error.
  Future<Result<KycStatusEntity>> call(SubmitKycParams params) {
    return _repository.submitKyc(
      firstName: params.firstName,
      middleName: params.middleName,
      lastName: params.lastName,
      dateOfBirth: params.dateOfBirth,
      sex: params.sex,
      nationality: params.nationality,
      civilStatus: params.civilStatus,
      email: params.email,
      mobileNumber: params.mobileNumber,
      streetBarangay: params.streetBarangay,
      cityMunicipality: params.cityMunicipality,
      province: params.province,
      zipCode: params.zipCode,
      idType: params.idType,
      idNumber: params.idNumber,
      idExpiryDate: params.idExpiryDate,
      idFrontImagePath: params.idFrontImagePath,
      idBackImagePath: params.idBackImagePath,
      selfieImagePath: params.selfieImagePath,
      selfieWithIdImagePath: params.selfieWithIdImagePath,
      declarationAccepted: params.declarationAccepted,
    );
  }
}
