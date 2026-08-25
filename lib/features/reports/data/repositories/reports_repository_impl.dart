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
import '../blockchain_models.dart' as blockchain_dto;
import '../../domain/entities/blockchain_verification.dart';

/// Implementation of [ReportsRepository] using Dio.
///
/// All methods return [Result<T>] and use [ErrorMapper] for error handling.
class ReportsRepositoryImpl implements ReportsRepository {
  final Dio _dio;

  ReportsRepositoryImpl(this._dio);

  String? _legacyStatusFallback(String status) {
    return switch (status) {
      'submitted' => 'Pending',
      'under_review' => 'Under Review',
      'verified' => 'Verified',
      'assigned' => 'Assigned',
      'in_progress' => 'In Progress',
      'resolved' => 'Resolved',
      'closed' => 'Closed',
      'rejected' => 'Rejected',
      'escalated' => 'Escalated',
      'endorsed' => 'Endorsed',
      _ => null,
    };
  }

  @override
  Future<Result<PaginatedReports>> getReports({
    int page = 1,
    int pageSize = 20,
    String? status,
    String? zone,
    String? category,
    String? severity,
    bool? isEmergency,
    String? sortBy,
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
      if (sortBy != null) queryParams['sort_by'] = sortBy;

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
    String? sortBy,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };
      if (status != null) queryParams['status'] = status;
      if (sortBy != null) queryParams['sort_by'] = sortBy;

      final response = await _dio.get(
        ApiConstants.myReports,
        queryParameters: queryParams,
      );
      var dtoResult = dto.PaginatedReports.fromJson(response.data);

      // Some older records store status labels capitalized (e.g. "Closed").
      // Retry once with the legacy label if the strict status lookup is empty.
      if (status != null && dtoResult.results.isEmpty) {
        final legacyStatus = _legacyStatusFallback(status);
        if (legacyStatus != null && legacyStatus != status) {
          final fallbackQuery = <String, dynamic>{
            'page': page,
            'page_size': pageSize,
            'status': legacyStatus,
          };
          if (sortBy != null) fallbackQuery['sort_by'] = sortBy;

          final fallbackResponse = await _dio.get(
            ApiConstants.myReports,
            queryParameters: fallbackQuery,
          );
          final fallbackResult = dto.PaginatedReports.fromJson(
            fallbackResponse.data,
          );

          if (fallbackResult.results.isNotEmpty) {
            dtoResult = fallbackResult;
          }
        }
      }

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
    String municipalityId = 'urdaneta',
    String? barangayId,
    String? cityMunicipality,
    String? province,
    String? latitude,
    String? longitude,
    String locationAccuracy = 'approximate',
    String? location,
    String? barangay,
    bool declarationConfirmed = true,
    bool dataProcessingConsent = true,
    bool isQuickReport = false,
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
        municipalityId: municipalityId,
        barangayId: barangayId,
        cityMunicipality: cityMunicipality,
        province: province,
        latitude: latitude,
        longitude: longitude,
        locationAccuracy: locationAccuracy,
        location: location,
        barangay: barangay,
        declarationConfirmed: declarationConfirmed,
        dataProcessingConsent: dataProcessingConsent,
      );

      final response = await _dio.post(
        ApiConstants.reports,
        data: {...request.toJson(), if (isQuickReport) 'is_quick_report': true},
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
    String? municipalityId,
    String? barangayId,
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
        municipalityId: municipalityId,
        barangayId: barangayId,
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

  @override
  Future<Result<BlockchainVerificationResult>> verifyReport(String id) async {
    try {
      final response = await _dio.get(ApiConstants.reportVerify(id));
      final dtoResult = blockchain_dto.BlockchainVerificationResultDto.fromJson(
        response.data,
      );
      return Success(ReportMapper.blockchainVerificationFromDto(dtoResult));
    } catch (e, stack) {
      return Err(ErrorMapper.mapException(e, stack));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> citizenCloseReport({
    required String id,
    required bool satisfied,
    int? rating,
    String? note,
    String? reason,
    String? signatureImageId,
    String? signatureName,
  }) async {
    try {
      final body = <String, dynamic>{'satisfied': satisfied};
      if (rating != null) body['rating'] = rating;
      if (note != null && note.isNotEmpty) body['note'] = note;
      if (reason != null && reason.isNotEmpty) body['reason'] = reason;
      if (signatureImageId != null && signatureImageId.isNotEmpty) {
        body['signature_image_id'] = signatureImageId;
      }
      if (signatureName != null && signatureName.isNotEmpty) {
        body['signature_name'] = signatureName;
      }

      final response = await _dio.patch(
        ApiConstants.reportCitizenClose(id),
        data: body,
      );
      // Backend returns { message, satisfied, report_status }
      return Success(Map<String, dynamic>.from(response.data as Map));
    } catch (e, stack) {
      return Err(ErrorMapper.mapException(e, stack));
    }
  }
}
