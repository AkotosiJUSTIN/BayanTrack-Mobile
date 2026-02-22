import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/entities/paginated_reports.dart';
import '../reports_di.dart';

part 'reports_controller.g.dart';

/// Controller for fetching reports from backend.
///
/// Uses [GetReportsUseCase] for proper clean architecture layering.
/// Returns domain [PaginatedReports] entity.
@riverpod
class ReportsController extends _$ReportsController {
  @override
  Future<PaginatedReports> build({int page = 1, String? status}) async {
    return _fetchReports(page: page, status: status);
  }

  Future<PaginatedReports> _fetchReports({int page = 1, String? status}) async {
    final getReports = ref.read(getReportsUseCaseProvider);
    final result = await getReports(page: page, status: status);

    return result.when(
      success: (data) => data,
      failure: (failure) => throw Exception(failure.message),
    );
  }

  /// Refresh reports
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchReports());
  }
}

/// Controller for fetching user's own reports.
///
/// Uses [GetMyReportsUseCase] for proper clean architecture layering.
/// Returns domain [PaginatedReports] entity.
@riverpod
class MyReportsController extends _$MyReportsController {
  @override
  Future<PaginatedReports> build({int page = 1, String? status}) async {
    return _fetchMyReports(page: page, status: status);
  }

  Future<PaginatedReports> _fetchMyReports({
    int page = 1,
    String? status,
  }) async {
    final getMyReports = ref.read(getMyReportsUseCaseProvider);
    final result = await getMyReports(page: page, status: status);

    return result.when(
      success: (data) => data,
      failure: (failure) => throw Exception(failure.message),
    );
  }

  /// Refresh my reports
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchMyReports());
  }
}
