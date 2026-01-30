import 'package:freezed_annotation/freezed_annotation.dart';

part 'report_models.freezed.dart';
part 'report_models.g.dart';

// ==================== REPORT STATUS ====================

enum ReportStatus {
  @JsonValue('Pending')
  pending,
  @JsonValue('In Progress')
  inProgress,
  @JsonValue('Resolved')
  resolved,
  @JsonValue('Rejected')
  rejected,
  @JsonValue('Verified')
  verified,
  @JsonValue('Assigned')
  assigned,
}

// ==================== REPORT IMAGE (embedded in report response) ====================

@freezed
sealed class ReportImage with _$ReportImage {
  const factory ReportImage({
    required String id,
    @JsonKey(name: 'report_id') String? reportId,
    @JsonKey(name: 'user_id') String? userId,
    required String url,  // Backend returns 'url' not 'image_url'
    @JsonKey(name: 's3_key') String? s3Key,
    String? filename,
    @JsonKey(name: 'file_size') int? fileSize,
    @JsonKey(name: 'mime_type') String? mimeType,
    int? width,
    int? height,
    @JsonKey(name: 'is_primary') @Default(false) bool isPrimary,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _ReportImage;

  factory ReportImage.fromJson(Map<String, dynamic> json) =>
      _$ReportImageFromJson(json);
}

// ==================== REPORT ====================

@freezed
sealed class Report with _$Report {
  const factory Report({
    required String id,
    @JsonKey(name: 'report_id') String? reportId,
    @JsonKey(name: 'user_id') String? userId,
    required String description,
    String? location,
    String? zone,
    String? latitude,   // Backend returns as string
    String? longitude,  // Backend returns as string
    @Default([]) List<ReportImage> images,  // List of image objects from backend
    @Default(ReportStatus.pending) ReportStatus status,
    String? category,
    @JsonKey(name: 'category_confidence') double? categoryConfidence,
    String? priority,
    @JsonKey(name: 'priority_score') int? priorityScore,
    @JsonKey(name: 'duplicate_state') @Default('New') String duplicateState,
    @JsonKey(name: 'related_issue_id') String? relatedIssueId,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _Report;

  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);
}

// ==================== CREATE REPORT REQUEST ====================
// Note: Images are uploaded separately via POST /api/images/upload/

@freezed
sealed class CreateReportRequest with _$CreateReportRequest {
  const factory CreateReportRequest({
    required String description,
    required String location,
    required String zone,
    String? latitude,  // Sent as string, backend accepts DecimalField
    String? longitude, // Sent as string, backend accepts DecimalField
    String? category,
  }) = _CreateReportRequest;

  factory CreateReportRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateReportRequestFromJson(json);
}

// ==================== UPDATE REPORT REQUEST ====================

@freezed
sealed class UpdateReportRequest with _$UpdateReportRequest {
  const factory UpdateReportRequest({
    ReportStatus? status,
    String? category,
    String? zone,
  }) = _UpdateReportRequest;

  factory UpdateReportRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateReportRequestFromJson(json);
}

// ==================== PAGINATED RESPONSE ====================

@freezed
sealed class PaginatedReports with _$PaginatedReports {
  const factory PaginatedReports({
    required List<Report> results,
    @Default(0) int count,
    @Default(0) int total,
    @Default(1) int page,
    @JsonKey(name: 'page_size') @Default(20) int pageSize,
    @JsonKey(name: 'total_pages') @Default(1) int totalPages,
  }) = _PaginatedReports;

  factory PaginatedReports.fromJson(Map<String, dynamic> json) =>
      _$PaginatedReportsFromJson(json);
}

// ==================== REPORT STATISTICS ====================

@freezed
sealed class ReportStats with _$ReportStats {
  const factory ReportStats({
    @Default(0) int total,
    @Default(0) int pending,
    @JsonKey(name: 'in_progress') @Default(0) int inProgress,
    @Default(0) int resolved,
    @Default(0) int rejected,
    @Default(0) int verified,
    @Default(0) int assigned,
  }) = _ReportStats;

  factory ReportStats.fromJson(Map<String, dynamic> json) =>
      _$ReportStatsFromJson(json);
}
