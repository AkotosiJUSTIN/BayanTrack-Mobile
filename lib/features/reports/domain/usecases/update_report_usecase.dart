import '../../../../core/domain/result.dart';
import '../entities/report.dart';
import '../reports_repository.dart';

/// Use case for citizen report enrichment after submission.
class UpdateReportUseCase {
  final ReportsRepository _repository;

  UpdateReportUseCase({required ReportsRepository repository})
    : _repository = repository;

  Future<Result<Report>> call({
    required String id,
    String? title,
    String? description,
  }) {
    return _repository.updateReport(
      id: id,
      title: title,
      description: description,
    );
  }
}
