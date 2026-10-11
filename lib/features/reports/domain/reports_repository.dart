import '../../../core/domain/result.dart';
import 'package:dio/dio.dart';
import 'entities/paginated_reports.dart';
import 'entities/report.dart';
import 'entities/report_stats.dart';
import 'entities/blockchain_verification.dart';

/// Repository interface for report operations.
///
/// Implemented by [ReportsRepositoryImpl] in the data layer.
/// All methods return [Result<T>] for explicit error handling.
abstract interface class ReportsRepository {
  /// Get all reports (paginated, filtered by user's role on backend)
  Future<Result<PaginatedReports>> getReports({
    int page = 1,
    int pageSize = 20,
    String? status,
    String? zone,
    String? category,
    String? sortBy, // 'date', 'severity', 'priority'
  });

  /// Get current user's reports
  Future<Result<PaginatedReports>> getMyReports({
    int page = 1,
    int pageSize = 20,
    String? status,
    String? sortBy, // 'date', 'severity', 'priority'
  });

  /// Get a single report by ID
  Future<Result<Report>> getReport(String id);

  /// Create a new report
  Future<Result<Report>> createReport({
    String? category,
    String? incidentType,
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
  });

  /// Update a report
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
  });

  /// Update report status (admin only)
  Future<Result<Report>> updateReportStatus({
    required String id,
    required String status,
    String? adminRemarks,
    String? assignedDepartment,
  });

  /// Delete a report
  Future<Result<void>> deleteReport(String id);

  /// Get report statistics
  Future<Result<ReportStats>> getStats();

  /// Verify report on blockchain
  Future<Result<BlockchainVerificationResult>> verifyReport(
    String id, {
    bool cachedOnly = false,
  });

  /// Submit citizen closure review for a resolved report.
  ///
  /// [satisfied]         — true if the citizen confirms resolution, false to reopen.
  /// [rating]            — optional 1–5 star rating.
  /// [note]              — optional free-text feedback.
  /// [reason]            — required when disputing a resolution.
  /// [signatureImageId]  — uploaded image ID of the drawn signature.
  /// [signatureName]     — full name typed by the citizen for identity confirmation.
  Future<Result<Map<String, dynamic>>> citizenCloseReport({
    required String id,
    required bool satisfied,
    int? rating,
    String? note,
    String? reason,
    String? signatureImageId,
    String? signatureName,
  });
}
