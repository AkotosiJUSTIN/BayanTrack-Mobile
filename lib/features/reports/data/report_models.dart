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

// ==================== REPORT ====================

@freezed
sealed class Report with _$Report {
  const factory Report({
    @JsonKey(name: 'id') required String id,
    required String description,
    @Default(ReportStatus.pending) ReportStatus status,
    String? category,
    String? barangay,
    double? latitude,
    double? longitude,
    @Default([]) List<String> images,
    @JsonKey(name: 'created_by') String? createdBy,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    // AI fields (optional, from backend)
    @JsonKey(name: 'ai_category') String? aiCategory,
    @JsonKey(name: 'ai_priority') int? aiPriority,
    @JsonKey(name: 'ai_confidence') double? aiConfidence,
  }) = _Report;

  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);
}

// ==================== CREATE REPORT REQUEST ====================

@freezed
sealed class CreateReportRequest with _$CreateReportRequest {
  const factory CreateReportRequest({
    required String description,
    String? category,
    String? barangay,
    double? latitude,
    double? longitude,
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
    String? barangay,
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
    String? next,
    String? previous,
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
