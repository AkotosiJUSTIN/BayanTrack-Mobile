import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/domain/result.dart';
import '../../../../core/network/error_mapper.dart';
import '../../domain/entities/paginated_reports.dart';
import '../../domain/entities/report.dart';
import '../../domain/entities/report_stats.dart';
import '../../domain/reports_repository.dart';
import '../mappers/report_mapper.dart';
import '../report_models.dart' as dto;

/// Implementation of [ReportsRepository] using Dio.
///
/// All methods return [Result<T>] and use [ErrorMapper] for error handling.
class ReportsRepositoryImpl implements ReportsRepository {
  final Dio _dio;

  ReportsRepositoryImpl(this._dio);

  @override
  Future<Result<PaginatedReports>> getReports({
    int page = 1,
    int pageSize = 20,
    String? status,
    String? zone,
    String? category,
    String? severity,
    bool? isEmergency,
  }) async {
    try {
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
      final dtoResult = dto.PaginatedReports.fromJson(response.data);
      return Success(ReportMapper.paginatedFromDto(dtoResult));
    } catch (e, stack) {
      return Err(ErrorMapper.mapException(e, stack));
    }
  }

  @override
  Future<Result<PaginatedReports>> getMyReports({
    int page = 1,
    int pageSize = 20,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };
      if (status != null) queryParams['status'] = status;

      final response = await _dio.get(
        ApiConstants.myReports,
        queryParameters: queryParams,
      );
      final dtoResult = dto.PaginatedReports.fromJson(response.data);
      return Success(ReportMapper.paginatedFromDto(dtoResult));
    } catch (e, stack) {
      return Err(ErrorMapper.mapException(e, stack));
    }
  }

  @override
  Future<Result<Report>> getReport(String id) async {
    try {
      final response = await _dio.get(ApiConstants.reportById(id));
      final dtoReport = dto.Report.fromJson(response.data);
      return Success(ReportMapper.fromDto(dtoReport));
    } catch (e, stack) {
      return Err(ErrorMapper.mapException(e, stack));
    }
  }

  @override
  Future<Result<Report>> createReport({
    String? category,
    String? incidentType,
    String? title,
    required String description,
    String? incidentDatetime,
    bool isHappeningNow = false,
    String? zone,
    String? streetLandmark,
    String? cityMunicipality,
    String? province,
    String? latitude,
    String? longitude,
    String locationAccuracy = 'approximate',
    String? location,
    bool declarationConfirmed = true,
    bool dataProcessingConsent = true,
  }) async {
    try {
      final request = dto.CreateReportRequest(
        category: category,
        incidentType: incidentType,
        title: title,
        description: description,
        incidentDatetime: incidentDatetime,
        isHappeningNow: isHappeningNow,
        zone: zone,
        streetLandmark: streetLandmark,
        cityMunicipality: cityMunicipality,
        province: province,
        latitude: latitude,
        longitude: longitude,
        locationAccuracy: locationAccuracy,
        location: location,
        declarationConfirmed: declarationConfirmed,
        dataProcessingConsent: dataProcessingConsent,
      );

      final response = await _dio.post(
        ApiConstants.reports,
        data: request.toJson(),
      );

      // Backend returns {report: {...}, message: "..."}
      final data = response.data;
      final reportData = (data is Map && data.containsKey('report'))
          ? data['report']
          : data;
      final dtoReport = dto.Report.fromJson(reportData);
      return Success(ReportMapper.fromDto(dtoReport));
    } catch (e, stack) {
      return Err(ErrorMapper.mapException(e, stack));
    }
  }

  @override
  Future<Result<Report>> updateReport({
    required String id,
    String? title,
    String? description,
    String? category,
    String? incidentType,
    String? zone,
    String? streetLandmark,
    String? cityMunicipality,
    String? province,
    String? barangay,
  }) async {
    try {
      final request = dto.UpdateReportRequest(
        title: title,
        description: description,
        category: category,
        incidentType: incidentType,
        zone: zone,
        streetLandmark: streetLandmark,
        cityMunicipality: cityMunicipality,
        province: province,
        barangay: barangay,
      );

      final response = await _dio.patch(
        ApiConstants.reportById(id),
        data: request.toJson(),
      );
      final dtoReport = dto.Report.fromJson(response.data);
      return Success(ReportMapper.fromDto(dtoReport));
    } catch (e, stack) {
      return Err(ErrorMapper.mapException(e, stack));
    }
  }

  @override
  Future<Result<Report>> updateReportStatus({
    required String id,
    required String status,
    String? adminRemarks,
    String? assignedDepartment,
  }) async {
    try {
      final request = dto.ReportStatusUpdateRequest(
        status: status,
        adminRemarks: adminRemarks,
        assignedDepartment: assignedDepartment,
      );

      final response = await _dio.patch(
        '${ApiConstants.reportById(id)}status/',
        data: request.toJson(),
      );
      final dtoReport = dto.Report.fromJson(response.data);
      return Success(ReportMapper.fromDto(dtoReport));
    } catch (e, stack) {
      return Err(ErrorMapper.mapException(e, stack));
    }
  }

  @override
  Future<Result<void>> deleteReport(String id) async {
    try {
      await _dio.delete(ApiConstants.reportById(id));
      return const Success(null);
    } catch (e, stack) {
      return Err(ErrorMapper.mapException(e, stack));
    }
  }

  @override
  Future<Result<ReportStats>> getStats() async {
    try {
      final response = await _dio.get(ApiConstants.reportStats);
      final dtoStats = dto.ReportStats.fromJson(response.data);
      return Success(ReportMapper.statsFromDto(dtoStats));
    } catch (e, stack) {
      return Err(ErrorMapper.mapException(e, stack));
    }
  }
}
