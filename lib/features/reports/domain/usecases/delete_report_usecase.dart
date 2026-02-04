import '../../../../core/domain/result.dart';
import '../reports_repository.dart';

/// Use case for deleting a report.
class DeleteReportUseCase {
  final ReportsRepository _repository;

  DeleteReportUseCase({required ReportsRepository repository})
    : _repository = repository;

  Future<Result<void>> call(String id) {
    return _repository.deleteReport(id);
  }
}
