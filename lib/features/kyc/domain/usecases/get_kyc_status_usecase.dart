import '../../../../core/domain/result.dart';
import '../entities/kyc_status.dart';
import '../kyc_repository.dart';

/// Use case to fetch current KYC status for the authenticated user.
class GetKycStatusUseCase {
  final KycRepository _repository;

  const GetKycStatusUseCase({required KycRepository repository})
    : _repository = repository;

  /// Fetches the current KYC status.
  ///
  /// Returns [KycStatusEntity] on success, or a [Failure] on error.
  Future<Result<KycStatusEntity>> call() {
    return _repository.getKycStatus();
  }
}
