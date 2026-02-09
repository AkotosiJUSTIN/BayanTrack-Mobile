import '../../../../core/domain/result.dart';
import '../entities/report.dart';
import '../reports_repository.dart';

/// Use case for fetching a single report by ID.
class GetReportUseCase {
  final ReportsRepository _repository;

  GetReportUseCase({required ReportsRepository repository})
    : _repository = repository;

  Future<Result<Report>> call(String id) {
    return _repository.getReport(id);
  }
}
