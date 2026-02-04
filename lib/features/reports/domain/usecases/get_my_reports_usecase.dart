import '../../../../core/domain/result.dart';
import '../entities/paginated_reports.dart';
import '../reports_repository.dart';

/// Use case for fetching the current user's reports.
class GetMyReportsUseCase {
  final ReportsRepository _repository;

  GetMyReportsUseCase({required ReportsRepository repository})
    : _repository = repository;

  Future<Result<PaginatedReports>> call({
    int page = 1,
    int pageSize = 20,
    String? status,
  }) {
    return _repository.getMyReports(
      page: page,
      pageSize: pageSize,
      status: status,
    );
  }
}
