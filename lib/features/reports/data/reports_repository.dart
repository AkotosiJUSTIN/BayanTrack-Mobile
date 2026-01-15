import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_provider.dart';
import 'report_models.dart';

part 'reports_repository.g.dart';

@riverpod
ReportsRepository reportsRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  return ReportsRepository(dio);
}

class ReportsRepository {
  final Dio _dio;

  ReportsRepository(this._dio);

  // ==================== LIST REPORTS ====================

  /// Get all reports (paginated, filtered by user's role on backend)
  Future<PaginatedReports> getReports({
    int page = 1,
    int limit = 10,
    ReportStatus? status,
    String? barangay,
  }) async {
    final queryParams = <String, dynamic>{'page': page, 'limit': limit};
    if (status != null) {
      queryParams['status'] = status.name;
    }
    if (barangay != null) {
      queryParams['barangay'] = barangay;
    }

    final response = await _dio.get(
      ApiConstants.reports,
      queryParameters: queryParams,
    );
    return PaginatedReports.fromJson(response.data);
  }

  /// Get current user's reports
  Future<PaginatedReports> getMyReports({int page = 1, int limit = 10}) async {
    final response = await _dio.get(
      ApiConstants.myReports,
      queryParameters: {'page': page, 'limit': limit},
    );
    return PaginatedReports.fromJson(response.data);
  }

  // ==================== SINGLE REPORT ====================

  Future<Report> getReport(String id) async {
    final response = await _dio.get(ApiConstants.reportById(id));
    return Report.fromJson(response.data);
  }

  // ==================== CREATE / UPDATE / DELETE ====================

  Future<Report> createReport(CreateReportRequest request) async {
    final response = await _dio.post(
      ApiConstants.reports,
      data: request.toJson(),
    );
    return Report.fromJson(response.data);
  }

  Future<Report> updateReport(String id, UpdateReportRequest request) async {
    final response = await _dio.patch(
      ApiConstants.reportById(id),
      data: request.toJson(),
    );
    return Report.fromJson(response.data);
  }

  Future<void> deleteReport(String id) async {
    await _dio.delete(ApiConstants.reportById(id));
  }

  // ==================== STATISTICS ====================

  Future<ReportStats> getStats() async {
    final response = await _dio.get(ApiConstants.reportStats);
    return ReportStats.fromJson(response.data);
  }
}
