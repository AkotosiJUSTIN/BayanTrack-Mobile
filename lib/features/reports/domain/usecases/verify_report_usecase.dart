import '../../../../core/domain/result.dart';
import '../entities/blockchain_verification.dart';
import '../reports_repository.dart';

class VerifyReportUseCase {
  final ReportsRepository repository;

  VerifyReportUseCase({required this.repository});

  Future<Result<BlockchainVerificationResult>> call(String reportId) async {
    return repository.verifyReport(reportId);
  }
}
