import '../../../../core/domain/result.dart';
import '../entities/report_stats.dart';
import '../reports_repository.dart';

/// Use case for fetching report statistics.
class GetReportStatsUseCase {
  final ReportsRepository _repository;

  GetReportStatsUseCase({required ReportsRepository repository})
    : _repository = repository;

  Future<Result<ReportStats>> call() {
    return _repository.getStats();
  }
}
