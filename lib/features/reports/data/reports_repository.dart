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
  ReportFormOptions? _cachedFormOptions;
  DateTime? _formOptionsCachedAt;

  static const Duration _formOptionsCacheTtl = Duration(hours: 24);

  ReportsRepository(this._dio);

  Future<List<NearbyReport>> getNearbyReports({
    required double latitude,
    required double longitude,
    String municipalityId = 'urdaneta',
    int radiusMeters = 500,
  }) async {
    final response = await _dio.get(
      ApiConstants.nearbyReports,
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'municipality_id': municipalityId,
        'radius_m': radiusMeters,
      },
    );
    final items = response.data['reports'] as List<dynamic>? ?? const [];
    return items
        .map((item) => NearbyReport.fromJson(item as Map<String, dynamic>))
        .toList();
  }

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
    final queryParams = <String, dynamic>{'page': page, 'page_size': pageSize};
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
    final queryParams = <String, dynamic>{'page': page, 'page_size': pageSize};
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
    final response = await _dio.post(ApiConstants.reports, data: jsonData);
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
  Future<Report> updateReportStatus(
    String id,
    ReportStatusUpdateRequest request,
  ) async {
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

    try {
      final response = await _dio.get(ApiConstants.reportFormOptions);
      final parsed = ReportFormOptions.fromJson(response.data);
      _cachedFormOptions = parsed;
      _formOptionsCachedAt = now;
      return parsed;
    } on DioException {
      // Offline compatibility only; the backend remains authoritative online.
      _cachedFormOptions = offlineReportFormOptions;
      _formOptionsCachedAt = now;
      return offlineReportFormOptions;
    }
  }
}

const offlineReportFormOptions = ReportFormOptions(
  taxonomyVersion: 'taxonomy_v1',
  categories: [
    ReportCategoryOption(
      key: 'engineering_infrastructure',
      label: 'Municipal Engineering & Infrastructure',
      taxonomyVersion: 'taxonomy_v1',
      active: true,
    ),
    ReportCategoryOption(
      key: 'flood_disaster',
      label: 'Flood & Disaster Response',
      taxonomyVersion: 'taxonomy_v1',
      active: true,
    ),
    ReportCategoryOption(
      key: 'waste_environment',
      label: 'Solid Waste & Environmental Management',
      taxonomyVersion: 'taxonomy_v1',
      active: true,
    ),
    ReportCategoryOption(
      key: 'public_safety',
      label: 'Public Safety & Order',
      taxonomyVersion: 'taxonomy_v1',
      active: true,
    ),
    ReportCategoryOption(
      key: 'public_utilities',
      label: 'Public Utilities & Service',
      taxonomyVersion: 'taxonomy_v1',
      active: true,
    ),
  ],
  statuses: [],
  severityLevels: [],
);

class NearbyReport {
  final String category;
  final String status;
  final int distanceMeters;
  final bool isGrouped;

  const NearbyReport({
    required this.category,
    required this.status,
    required this.distanceMeters,
    required this.isGrouped,
  });

  factory NearbyReport.fromJson(Map<String, dynamic> json) => NearbyReport(
    category: json['category']?.toString() ?? 'Uncategorized incident',
    status: json['status']?.toString() ?? 'submitted',
    distanceMeters: (json['distance_m'] as num?)?.round() ?? 0,
    isGrouped: json['incident_group_id'] != null,
  );
}
