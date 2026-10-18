import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/domain/failures.dart';
import '../../../../core/domain/result.dart';
import '../../../../core/network/error_mapper.dart';
import '../../domain/entities/paginated_reports.dart';
import '../../domain/entities/report.dart';
import '../../domain/entities/report_stats.dart';
import '../../domain/reports_repository.dart';
import '../mappers/report_mapper.dart';
import '../report_cache_store.dart';
import '../report_models.dart' as dto;
import '../blockchain_models.dart' as blockchain_dto;
import '../../domain/entities/blockchain_verification.dart';

/// Implementation of [ReportsRepository] using Dio.
///
/// All methods return [Result<T>] and use [ErrorMapper] for error handling.
class ReportsRepositoryImpl implements ReportsRepository {
  final Dio _dio;
  final ReportCacheStore? _cache;
  final String? Function()? _currentOwnerId;

  ReportsRepositoryImpl(
    this._dio, {
    ReportCacheStore? cache,
    String? Function()? currentOwnerId,
  }) : _cache = cache,
       _currentOwnerId = currentOwnerId;

  String? _ownerId() {
    final ownerId = _currentOwnerId?.call()?.trim();
    return ownerId == null || ownerId.isEmpty ? null : ownerId;
  }

  bool _canUseCacheFor(String? ownerId) =>
      ownerId != null && ownerId == _ownerId();

  bool _mayUseStaleCache(Failure failure) =>
      failure is NetworkFailure || failure is ServerFailure;

  Future<void> _cacheReports(
    String? ownerId,
    String scope,
    Map<String, dynamic> query,
    dto.PaginatedReports reports,
  ) async {
    if (_cache == null || !_canUseCacheFor(ownerId)) return;
    try {
      await _cache.writeReports(
        ownerId: ownerId!,
        scope: scope,
        query: query,
        reports: reports,
      );
    } catch (_) {
      // A cache failure must not turn a successful Backend read into an error.
    }
  }

  Future<dto.PaginatedReports?> _readCachedReports(
    String? ownerId,
    String scope,
    Map<String, dynamic> query,
  ) async {
    if (_cache == null || !_canUseCacheFor(ownerId)) return null;
    return _cache.readReports(ownerId: ownerId!, scope: scope, query: query);
  }

  Future<void> _cacheReport(
    String? ownerId,
    String reportId,
    dto.Report report,
  ) async {
    if (_cache == null || !_canUseCacheFor(ownerId)) return;
    try {
      await _cache.writeReport(
        ownerId: ownerId!,
        reportId: reportId,
        report: report,
      );
    } catch (_) {
      // A cache failure must not turn a successful Backend read into an error.
    }
  }

  Future<dto.Report?> _readCachedReport(String? ownerId, String reportId) {
    if (_cache == null || !_canUseCacheFor(ownerId)) {
      return Future.value(null);
    }
    return _cache.readReport(ownerId: ownerId!, reportId: reportId);
  }

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
    final ownerId = _ownerId();
    final queryParams = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
      'status': ?status,
      'zone': ?zone,
      'category': ?category,
      'severity': ?severity,
      'is_emergency': ?isEmergency,
      'sort_by': ?sortBy,
    };
    try {
      final response = await _dio.get(
        ApiConstants.reports,
        queryParameters: queryParams,
      );
      final dtoResult = dto.PaginatedReports.fromJson(response.data);
      await _cacheReports(ownerId, 'public', queryParams, dtoResult);
      return Success(ReportMapper.paginatedFromDto(dtoResult));
    } catch (e, stack) {
      final failure = ErrorMapper.mapException(e, stack);
      if (_mayUseStaleCache(failure)) {
        final cached = await _readCachedReports(ownerId, 'public', queryParams);
        if (cached != null) {
          return Success(ReportMapper.paginatedFromDto(cached, isStale: true));
        }
      }
      return Err(failure);
    }
  }

  @override
  Future<Result<PaginatedReports>> getMyReports({
    int page = 1,
    int pageSize = 20,
    String? status,
    String? sortBy,
  }) async {
    final ownerId = _ownerId();
    final queryParams = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
      'status': ?status,
      'sort_by': ?sortBy,
    };
    try {
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

      await _cacheReports(ownerId, 'mine', queryParams, dtoResult);
      return Success(ReportMapper.paginatedFromDto(dtoResult));
    } catch (e, stack) {
      final failure = ErrorMapper.mapException(e, stack);
      if (_mayUseStaleCache(failure)) {
        final cached = await _readCachedReports(ownerId, 'mine', queryParams);
        if (cached != null) {
          return Success(ReportMapper.paginatedFromDto(cached, isStale: true));
        }
      }
      return Err(failure);
    }
  }

  @override
  Future<Result<Report>> getReport(String id) async {
    final ownerId = _ownerId();
    try {
      final response = await _dio.get(ApiConstants.reportById(id));
      final dtoReport = dto.Report.fromJson(response.data);
      await _cacheReport(ownerId, id, dtoReport);
      return Success(ReportMapper.fromDto(dtoReport));
    } catch (e, stack) {
      final failure = ErrorMapper.mapException(e, stack);
      if (_mayUseStaleCache(failure)) {
        final cached = await _readCachedReport(ownerId, id);
        if (cached != null) {
          return Success(ReportMapper.fromDto(cached, isStale: true));
        }
      }
      return Err(failure);
    }
  }

  @override
  Future<Result<Report>> createReport({
    String? category,
    String? incidentType,
    String? incidentTypeKey,
    String? incidentCatalogVersion,
    String? title,
    String description = '',
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
    bool isEmergency = false,
    String? idempotencyKey,
    CancelToken? cancelToken,
  }) async {
    try {
      final request = dto.CreateReportRequest(
        category: category,
        incidentType: incidentType,
        incidentTypeKey: incidentTypeKey,
        incidentCatalogVersion: incidentCatalogVersion,
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
        isEmergency: isEmergency,
      );

      final requestData = {
        ...request.toJson(),
        'is_quick_report': isQuickReport,
      };
      final response = await _dio.post(
        ApiConstants.reports,
        data: requestData,
        options: idempotencyKey == null
            ? null
            : Options(headers: {'Idempotency-Key': idempotencyKey}),
        cancelToken: cancelToken,
      );

      // Backend returns {report: {...}, message: "..."}
      final responseData = response.data;
      final reportData =
          (responseData is Map && responseData.containsKey('report'))
          ? responseData['report']
          : responseData;
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
    String? incidentTypeKey,
    String? incidentCatalogVersion,
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
        incidentTypeKey: incidentTypeKey,
        incidentCatalogVersion: incidentCatalogVersion,
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
      final responseData = response.data;
      final reportData = responseData is Map && responseData['report'] is Map
          ? responseData['report']
          : responseData;
      final dtoReport = dto.Report.fromJson(reportData);
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
      final responseData = response.data;
      final reportData = responseData is Map && responseData['report'] is Map
          ? responseData['report']
          : responseData;
      final dtoReport = dto.Report.fromJson(reportData);
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
  Future<Result<BlockchainVerificationResult>> verifyReport(
    String id, {
    bool cachedOnly = false,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.reportVerify(id),
        queryParameters: cachedOnly ? {'cached_only': 'true'} : null,
      );
      final dtoResult = blockchain_dto.BlockchainVerificationResultDto.fromJson(
        response.data,
      );
      return Success(ReportMapper.blockchainVerificationFromDto(dtoResult));
    } on DioException catch (e, stack) {
      final body = e.response?.data;
      if (e.response?.statusCode == 503 &&
          body is Map<String, dynamic> &&
          body['scan_incomplete'] == true &&
          body['connection_error'] == true) {
        try {
          final pending =
              blockchain_dto.BlockchainVerificationResultDto.fromJson({
                ...body,
                'verified': false,
                'verification_pending': true,
                'verify_status_reason':
                    body['verify_status_reason'] ?? 'chain_scan_incomplete',
                'original_snapshot_verified': null,
                'current_content_verified': null,
                'status_verified': null,
              });
          return Success(ReportMapper.blockchainVerificationFromDto(pending));
        } catch (_) {
          // Malformed service errors remain failures, never verification proof.
        }
      }
      return Err(ErrorMapper.mapException(e, stack));
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
