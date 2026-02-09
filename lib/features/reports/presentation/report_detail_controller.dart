import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/entities/report.dart';
import '../reports_di.dart';

part 'report_detail_controller.g.dart';

/// Controller for fetching a single report by ID.
///
/// Uses [GetReportUseCase] for proper clean architecture layering.
/// Returns domain [Report] entity.
@riverpod
class ReportDetailController extends _$ReportDetailController {
  @override
  Future<Report> build(String reportId) async {
    return _fetchReport(reportId);
  }

  Future<Report> _fetchReport(String reportId) async {
    final getReport = ref.read(getReportUseCaseProvider);
    final result = await getReport(reportId);
    
    return result.when(
      success: (data) => data,
      failure: (failure) => throw Exception(failure.message),
    );
  }

  /// Refresh the report
  Future<void> refresh() async {
    final reportId = state.value?.id;
    if (reportId == null) return;
    
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchReport(reportId));
  }
}
