import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/report_models.dart';
import '../data/reports_repository.dart';

part 'reports_controller.g.dart';

/// Controller for fetching reports from backend
@riverpod
class ReportsController extends _$ReportsController {
  @override
  Future<PaginatedReports> build({int page = 1, String? status}) async {
    return _fetchReports(page: page, status: status);
  }

  Future<PaginatedReports> _fetchReports({
    int page = 1,
    String? status,
  }) async {
    final repository = ref.read(reportsRepositoryProvider);
    return repository.getReports(page: page, status: status);
  }

  /// Refresh reports
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchReports());
  }
}

/// Controller for fetching user's own reports
@riverpod
class MyReportsController extends _$MyReportsController {
  @override
  Future<PaginatedReports> build({int page = 1}) async {
    return _fetchMyReports(page: page);
  }

  Future<PaginatedReports> _fetchMyReports({int page = 1}) async {
    final repository = ref.read(reportsRepositoryProvider);
    return repository.getMyReports(page: page);
  }

  /// Refresh my reports
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchMyReports());
  }
}

/// Helper extension to extract error messages
extension DioExceptionX on DioException {
  String get userFriendlyMessage {
    if (response?.data != null) {
      final data = response!.data;
      if (data is Map<String, dynamic>) {
        if (data.containsKey('detail')) return data['detail'].toString();
        if (data.containsKey('message')) return data['message'].toString();
      }
    }

    switch (type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout';
      case DioExceptionType.connectionError:
        return 'Unable to connect. Check your internet.';
      case DioExceptionType.badResponse:
        final statusCode = response?.statusCode;
        if (statusCode == 401) return 'Please login again';
        if (statusCode == 403) return 'Access denied';
        if (statusCode != null && statusCode >= 500) {
          return 'Server error. Try again later.';
        }
        return 'Request failed';
      default:
        return 'An error occurred';
    }
  }
}
