import 'package:freezed_annotation/freezed_annotation.dart';

part 'report_models.freezed.dart';
part 'report_models.g.dart';

// ==================== JSON CONVERTERS ====================

/// Converts a value that could be int, String, or null to int?
class NullableIntConverter implements JsonConverter<int?, dynamic> {
  const NullableIntConverter();

  @override
  int? fromJson(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value);
    }
    if (value is num) return value.toInt();
    return null;
  }

  @override
  dynamic toJson(int? value) => value;
}

// ==================== REPORT CATEGORIES ====================

/// Report categories aligned with Mangaldan Municipal Office routing (V23 XLM-RoBERTa)
enum ReportCategory {
  @JsonValue('Municipal Engineering & Infrastructure')
  engineeringInfrastructure,
  @JsonValue('Flood & Disaster Response')
  floodDisaster,
  @JsonValue('Solid Waste & Environmental Management')
  wasteEnvironment,
  @JsonValue('Public Safety & Order')
  publicSafety,
  @JsonValue('Public Utilities & Service')
  publicUtilities;

  String get displayName => switch (this) {
    engineeringInfrastructure => 'Municipal Engineering & Infrastructure',
    floodDisaster => 'Flood & Disaster Response',
    wasteEnvironment => 'Solid Waste & Environmental Management',
    publicSafety => 'Public Safety & Order',
    publicUtilities => 'Public Utilities & Service',
  };

  String get value => switch (this) {
    engineeringInfrastructure => 'Municipal Engineering & Infrastructure',
    floodDisaster => 'Flood & Disaster Response',
    wasteEnvironment => 'Solid Waste & Environmental Management',
    publicSafety => 'Public Safety & Order',
    publicUtilities => 'Public Utilities & Service',
  };
}

// ==================== REPORT STATUS ====================

enum ReportStatus {
  @JsonValue('submitted')
  submitted,
  @JsonValue('under_review')
  underReview,
  @JsonValue('verified')
  verified,
  @JsonValue('assigned')
  assigned,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('escalated')
  escalated,
  @JsonValue('endorsed')
  endorsed,
  @JsonValue('resolved')
  resolved,
  @JsonValue('closed')
  closed,
  @JsonValue('rejected')
  rejected;

  String get displayName => switch (this) {
    submitted => 'Submitted',
    underReview => 'Under Review',
    verified => 'Verified',
    assigned => 'Assigned',
    inProgress => 'In Progress',
    escalated => 'Escalated',
    endorsed => 'Endorsed',
    resolved => 'Resolved',
    closed => 'Closed',
    rejected => 'Rejected',
  };

  String get value => switch (this) {
    submitted => 'submitted',
    underReview => 'under_review',
    verified => 'verified',
    assigned => 'assigned',
    inProgress => 'in_progress',
    escalated => 'escalated',
    endorsed => 'endorsed',
    resolved => 'resolved',
    closed => 'closed',
    rejected => 'rejected',
  };
}

// ==================== SEVERITY LEVELS ====================

enum SeverityLevel {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('critical')
  critical;

  String get displayName => switch (this) {
    low => 'Low',
    medium => 'Medium',
    high => 'High',
    critical => 'Critical',
  };

  String get value => switch (this) {
    low => 'low',
    medium => 'medium',
    high => 'high',
    critical => 'critical',
  };
}

// ==================== LOCATION ACCURACY ====================

enum LocationAccuracy {
  @JsonValue('exact')
  exact,
  @JsonValue('approximate')
  approximate;

  String get displayName => switch (this) {
    exact => 'Exact',
    approximate => 'Approximate',
  };
}

// ==================== DUPLICATE STATE ====================

enum DuplicateState {
  @JsonValue('new')
  newReport,
  @JsonValue('potential_duplicate')
  potentialDuplicate,
  @JsonValue('confirmed_duplicate')
  confirmedDuplicate,
  @JsonValue('unique')
  unique,
}

// ==================== PRIORITY LEVEL ====================

enum PriorityLevel {
  @JsonValue('LOW')
  low,
  @JsonValue('MEDIUM')
  medium,
  @JsonValue('HIGH')
  high,
  @JsonValue('CRITICAL')
  critical;

  String get displayName => switch (this) {
    low => 'Low',
    medium => 'Medium',
    high => 'High',
    critical => 'Critical',
  };

  String get value => switch (this) {
    low => 'LOW',
    medium => 'MEDIUM',
    high => 'HIGH',
    critical => 'CRITICAL',
  };
}

// ==================== REPORT IMAGE ====================

@freezed
sealed class ReportImage with _$ReportImage {
  const factory ReportImage({
    required String id,
    @JsonKey(name: 'report_id') String? reportId,
    @JsonKey(name: 'user_id') String? userId,
    required String url,
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

    // Report Details
    String? category,
    @JsonKey(name: 'incident_type') String? incidentType,
    String? title,
    required String description,
    @JsonKey(name: 'incident_datetime') String? incidentDatetime,
    @JsonKey(name: 'is_happening_now') @Default(false) bool isHappeningNow,

    // Location Information
    String? zone,
    @JsonKey(name: 'street_landmark') String? streetLandmark,
    @JsonKey(name: 'city_municipality') String? cityMunicipality,
    String? province,
    String? latitude,
    String? longitude,
    @JsonKey(name: 'location_accuracy')
    @Default('approximate')
    String locationAccuracy,
    // Legacy fields
    String? location,
    String? barangay,

    // Severity & Impact
    @Default('medium') String severity,
    @JsonKey(name: 'people_affected')
    @NullableIntConverter()
    int? peopleAffected,
    @JsonKey(name: 'is_emergency') @Default(false) bool isEmergency,

    // System Fields
    @Default('submitted') String status,
    @JsonKey(name: 'assigned_department') String? assignedDepartment,
    @JsonKey(name: 'admin_remarks') String? adminRemarks,

    // AI Fields
    @JsonKey(name: 'category_confidence') double? categoryConfidence,
    String? priority,
    @JsonKey(name: 'priority_score')
    @NullableIntConverter()
    int? priorityScore,
    @JsonKey(name: 'priority_level') String? priorityLevel,
    @JsonKey(name: 'priority_reasons') List<String>? priorityReasons,
    @JsonKey(name: 'base_score') @NullableIntConverter() int? baseScore,
    @JsonKey(name: 'hotspot_score') @NullableIntConverter() int? hotspotScore,
    @JsonKey(name: 'urgency_score') double? urgencyScore,
    @JsonKey(name: 'duplicate_state') String? duplicateState,
    @JsonKey(name: 'related_report_id') String? relatedReportId,
    @JsonKey(name: 'duplicate_score') double? duplicateScore,
    @JsonKey(name: 'duplicate_confidence') String? duplicateConfidence,
    @JsonKey(name: 'duplicate_text_similarity') double? duplicateTextSimilarity,
    @JsonKey(name: 'duplicate_location_similarity')
    double? duplicateLocationSimilarity,
    @JsonKey(name: 'duplicate_explanation') String? duplicateExplanation,
    @JsonKey(name: 'related_issue_id') String? relatedIssueId,
    @JsonKey(name: 'sentiment_score') double? sentimentScore,
    @JsonKey(name: 'auto_category_suggestion') String? autoCategorySuggestion,

    // Images
    @Default([]) List<ReportImage> images,

    // Timestamps
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    @JsonKey(name: 'submitted_at') String? submittedAt,
    @JsonKey(name: 'verified_at') String? verifiedAt,
    @JsonKey(name: 'resolved_at') String? resolvedAt,

    // Citizen Closure
    @JsonKey(name: 'citizen_verified_at') String? citizenVerifiedAt,
    @JsonKey(name: 'citizen_satisfaction')
    @NullableIntConverter()
    int? citizenSatisfaction,
    @JsonKey(name: 'citizen_closure_note') String? citizenClosureNote,

    // Blockchain Integration
    @JsonKey(name: 'on_chain_id') @NullableIntConverter() int? onChainId,
    @JsonKey(name: 'on_chain_hash') String? onChainHash,
    @JsonKey(name: 'blockchain_txn_hash') String? blockchainTxnHash,
    @JsonKey(name: 'blockchain_synced') @Default(false) bool blockchainSynced,
  }) = _Report;

  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);
}

// ==================== CREATE REPORT REQUEST ====================

@freezed
sealed class CreateReportRequest with _$CreateReportRequest {
  const factory CreateReportRequest({
    // Report Details (Section A)
    String? category,
    @JsonKey(name: 'incident_type') String? incidentType,
    String? title,
    required String description,
    @JsonKey(name: 'incident_datetime') String? incidentDatetime,
    @JsonKey(name: 'is_happening_now') @Default(false) bool isHappeningNow,

    // Location Information (Section B)
    String? zone,
    @JsonKey(name: 'street_landmark') String? streetLandmark,
    @JsonKey(name: 'city_municipality') String? cityMunicipality,
    String? province,
    String? latitude,
    String? longitude,
    @JsonKey(name: 'location_accuracy')
    @Default('approximate')
    String locationAccuracy,
    // Legacy fields for backwards compatibility
    String? location,
    String? barangay,

    // Consent & Declaration
    @JsonKey(name: 'declaration_confirmed')
    @Default(true)
    bool declarationConfirmed,
    @JsonKey(name: 'data_processing_consent')
    @Default(true)
    bool dataProcessingConsent,
  }) = _CreateReportRequest;

  factory CreateReportRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateReportRequestFromJson(json);
}

// ==================== UPDATE REPORT REQUEST ====================

@freezed
sealed class UpdateReportRequest with _$UpdateReportRequest {
  const factory UpdateReportRequest({
    String? title,
    String? description,
    String? category,
    @JsonKey(name: 'incident_type') String? incidentType,
    String? zone,
    @JsonKey(name: 'street_landmark') String? streetLandmark,
    @JsonKey(name: 'city_municipality') String? cityMunicipality,
    String? province,
    // Legacy
    String? barangay,
  }) = _UpdateReportRequest;

  factory UpdateReportRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateReportRequestFromJson(json);
}

// ==================== STATUS UPDATE REQUEST ====================

@freezed
sealed class ReportStatusUpdateRequest with _$ReportStatusUpdateRequest {
  const factory ReportStatusUpdateRequest({
    required String status,
    @JsonKey(name: 'admin_remarks') String? adminRemarks,
    @JsonKey(name: 'assigned_department') String? assignedDepartment,
  }) = _ReportStatusUpdateRequest;

  factory ReportStatusUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$ReportStatusUpdateRequestFromJson(json);
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
    @JsonKey(name: 'by_status') Map<String, int>? byStatus,
    @JsonKey(name: 'by_category') Map<String, int>? byCategory,
    @JsonKey(name: 'by_severity') Map<String, int>? bySeverity,
    @Default(0) int emergencies,
    // Legacy flat fields
    @Default(0) int submitted,
    @JsonKey(name: 'under_review') @Default(0) int underReview,
    @Default(0) int verified,
    @Default(0) int assigned,
    @JsonKey(name: 'in_progress') @Default(0) int inProgress,
    @Default(0) int resolved,
    @Default(0) int rejected,
  }) = _ReportStats;

  factory ReportStats.fromJson(Map<String, dynamic> json) =>
      _$ReportStatsFromJson(json);
}

// ==================== FORM OPTIONS ====================

@freezed
sealed class ReportFormOptions with _$ReportFormOptions {
  const factory ReportFormOptions({
    required List<Map<String, dynamic>> categories,
    required List<Map<String, dynamic>> statuses,
    @JsonKey(name: 'severity_levels')
    required List<Map<String, dynamic>> severityLevels,
  }) = _ReportFormOptions;

  factory ReportFormOptions.fromJson(Map<String, dynamic> json) =>
      _$ReportFormOptionsFromJson(json);
}
