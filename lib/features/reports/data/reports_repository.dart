import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
  ReportFormOptions? _cachedFormOptions;
  DateTime? _formOptionsCachedAt;

  static const Duration _formOptionsCacheTtl = Duration(hours: 24);

  ReportsRepository(this._dio);

  // ==================== LIST REPORTS ====================

  /// Get all reports (paginated, filtered by user's role on backend)
  Future<PaginatedReports> getReports({
    int page = 1,
    int pageSize = 20,
    String? status,
    String? zone,
    String? category,
    String? severity,
    bool? isEmergency,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page, 
      'page_size': pageSize,
    };
    if (status != null) queryParams['status'] = status;
    if (zone != null) queryParams['zone'] = zone;
    if (category != null) queryParams['category'] = category;
    if (severity != null) queryParams['severity'] = severity;
    if (isEmergency != null) queryParams['is_emergency'] = isEmergency;

    final response = await _dio.get(
      ApiConstants.reports,
      queryParameters: queryParams,
    );
    return PaginatedReports.fromJson(response.data);
  }

  /// Get current user's reports
  Future<PaginatedReports> getMyReports({
    int page = 1, 
    int pageSize = 20,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page, 
      'page_size': pageSize,
    };
    if (status != null) queryParams['status'] = status;
    
    final response = await _dio.get(
      ApiConstants.myReports,
      queryParameters: queryParams,
    );
    return PaginatedReports.fromJson(response.data);
  }

  // ==================== SINGLE REPORT ====================

  Future<Report> getReport(String id) async {
    final response = await _dio.get(ApiConstants.reportById(id));
    return Report.fromJson(response.data);
  }

  // ==================== CREATE / UPDATE / DELETE ====================

  /// Create a report with all new fields
  Future<Report> createReport(
    CreateReportRequest request, {
    bool isQuickReport = false,
  }) async {
    final jsonData = {
      ...request.toJson(),
      if (isQuickReport) 'is_quick_report': true,
    };
    // Debug: Print the request payload
    debugPrint('CreateReport request payload: $jsonData');
    
    final response = await _dio.post(
      ApiConstants.reports,
      data: jsonData,
    );
    // Backend returns {report: {...}, message: "..."}
    final data = response.data;
    if (data is Map && data.containsKey('report')) {
      return Report.fromJson(data['report']);
    }
    return Report.fromJson(data);
  }

  /// Update a report
  Future<Report> updateReport(String id, UpdateReportRequest request) async {
    final response = await _dio.patch(
      ApiConstants.reportById(id),
      data: request.toJson(),
    );
    return Report.fromJson(response.data);
  }

  /// Update report status (admin only)
  Future<Report> updateReportStatus(String id, ReportStatusUpdateRequest request) async {
    final response = await _dio.patch(
      '${ApiConstants.reportById(id)}status/',
      data: request.toJson(),
    );
    return Report.fromJson(response.data);
  }

  /// Delete a report
  Future<void> deleteReport(String id) async {
    await _dio.delete(ApiConstants.reportById(id));
  }

  // ==================== STATISTICS ====================

  Future<ReportStats> getStats() async {
    final response = await _dio.get(ApiConstants.reportStats);
    return ReportStats.fromJson(response.data);
  }

  // ==================== FORM OPTIONS ====================

  Future<ReportFormOptions> getFormOptions() async {
    final now = DateTime.now();
    if (_cachedFormOptions != null &&
        _formOptionsCachedAt != null &&
        now.difference(_formOptionsCachedAt!) < _formOptionsCacheTtl) {
      return _cachedFormOptions!;
    }

    final response = await _dio.get(ApiConstants.reportFormOptions);
    final parsed = ReportFormOptions.fromJson(response.data);
    _cachedFormOptions = parsed;
    _formOptionsCachedAt = now;
    return parsed;
  }
}
