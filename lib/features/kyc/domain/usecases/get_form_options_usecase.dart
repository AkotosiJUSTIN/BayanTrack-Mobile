import '../../../../core/domain/result.dart';
import '../entities/kyc_form_options.dart';
import '../kyc_repository.dart';

/// Use case to fetch KYC form dropdown options.
class GetFormOptionsUseCase {
  final KycRepository _repository;

  const GetFormOptionsUseCase({required KycRepository repository})
    : _repository = repository;

  /// Fetches available form options for KYC dropdowns.
  ///
  /// Returns [KycFormOptions] on success, or a [Failure] on error.
  Future<Result<KycFormOptions>> call() {
    return _repository.getFormOptions();
  }
}
