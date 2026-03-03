import '../../../../core/domain/result.dart';
import '../reports_repository.dart';

/// Use case for a citizen to confirm or dispute a resolved report.
///
/// When [satisfied] is true the report is permanently closed.
/// When [satisfied] is false the report is re-escalated to the municipal queue.
class CitizenCloseReportUseCase {
  final ReportsRepository repository;

  CitizenCloseReportUseCase({required this.repository});

  Future<Result<Map<String, dynamic>>> call({
    required String reportId,
    required bool satisfied,
    int? rating,
    String? note,
  }) {
    return repository.citizenCloseReport(
      id: reportId,
      satisfied: satisfied,
      rating: rating,
      note: note,
    );
  }
}
