import '../../../../core/domain/result.dart';
import '../entities/paginated_reports.dart';
import '../reports_repository.dart';

/// Use case for fetching paginated reports list.
class GetReportsUseCase {
  final ReportsRepository _repository;

  GetReportsUseCase({required ReportsRepository repository})
    : _repository = repository;

  Future<Result<PaginatedReports>> call({
    int page = 1,
    int pageSize = 20,
    String? status,
    String? zone,
    String? category,
    String? severity,
    bool? isEmergency,
  }) {
    return _repository.getReports(
      page: page,
      pageSize: pageSize,
      status: status,
      zone: zone,
      category: category,
      severity: severity,
      isEmergency: isEmergency,
    );
  }
}
