import '../../../../core/domain/result.dart';
import '../entities/kyc_status.dart';
import '../kyc_repository.dart';
import 'submit_kyc_usecase.dart';

/// Use case for resubmitting KYC documents after rejection.
class ResubmitKycUseCase {
  final KycRepository _repository;

  const ResubmitKycUseCase({required KycRepository repository})
    : _repository = repository;

  /// Resubmits KYC documents after rejection.
  ///
  /// Returns [KycStatusEntity] on success, or a [Failure] on error.
  Future<Result<KycStatusEntity>> call(SubmitKycParams params) {
    return _repository.resubmitKyc(
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
