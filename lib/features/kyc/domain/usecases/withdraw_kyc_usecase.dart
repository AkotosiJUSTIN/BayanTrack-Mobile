import '../../../../core/domain/result.dart';
import '../entities/kyc_status.dart';
import '../kyc_repository.dart';

/// Use case for withdrawing a pending KYC submission.
class WithdrawKycUseCase {
  final KycRepository _repository;

  const WithdrawKycUseCase({required KycRepository repository})
    : _repository = repository;

  Future<Result<KycStatusEntity>> call() => _repository.withdrawKyc();
}
