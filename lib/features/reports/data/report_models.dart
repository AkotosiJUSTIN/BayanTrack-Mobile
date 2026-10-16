import 'package:freezed_annotation/freezed_annotation.dart';

part 'report_models.freezed.dart';
part 'report_models.g.dart';

Object _readMunicipalityId(Map<dynamic, dynamic> json, String key) =>
    json[key]?.toString() ?? 'urdaneta';

Object? _readBarangayId(Map<dynamic, dynamic> json, String key) {
  final explicit = json[key] ?? json['assigned_barangay_id'];
  if (explicit != null && explicit.toString().trim().isNotEmpty) {
    return explicit.toString();
  }
  final legacy = json['barangay']?.toString().trim();
  if (legacy == null || legacy.isEmpty) return null;
  return legacy
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
}

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

/// Normalizes legacy numeric IDs at the API boundary without losing precision.
class StringValueConverter implements JsonConverter<String, dynamic> {
  const StringValueConverter();

  @override
  String fromJson(dynamic value) => value?.toString() ?? '';

  @override
  dynamic toJson(String value) => value;
}

/// Accepts legacy numeric IDs while exposing the stable string contract.
class NullableStringConverter implements JsonConverter<String?, dynamic> {
  const NullableStringConverter();

  @override
  String? fromJson(dynamic value) => value?.toString();

  @override
  dynamic toJson(String? value) => value;
}

// ==================== REPORT CATEGORIES ====================

/// Offline compatibility categories for the provisional taxonomy_v1 manifest.
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

  String get taxonomyKey => switch (this) {
    engineeringInfrastructure => 'engineering_infrastructure',
    floodDisaster => 'flood_disaster',
    wasteEnvironment => 'waste_environment',
    publicSafety => 'public_safety',
    publicUtilities => 'public_utilities',
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
    verified => 'Under Review',
    assigned => 'Under Review',
    inProgress => 'In Progress',
    escalated => 'Under Review',
    endorsed => 'Under Review',
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

// ==================== ROUTING / DEPARTMENT METADATA ====================

@freezed
sealed class DepartmentSuggestion with _$DepartmentSuggestion {
  const factory DepartmentSuggestion({
    required String key,
    required String label,
    double? probability,
  }) = _DepartmentSuggestion;

  factory DepartmentSuggestion.fromJson(Map<String, dynamic> json) =>
      _$DepartmentSuggestionFromJson(json);
}

// ==================== PRIORITY LEVEL ====================

enum PriorityLevel {
  @JsonValue('VERY_LOW')
  veryLow,
  @JsonValue('LOW')
  low,
  @JsonValue('MEDIUM')
  medium,
  @JsonValue('HIGH')
  high,
  @JsonValue('CRITICAL')
  critical;

  String get displayName => switch (this) {
    veryLow => 'Very Low',
    low => 'Low',
    medium => 'Medium',
    high => 'High',
    critical => 'Critical',
  };

  String get value => switch (this) {
    veryLow => 'VERY_LOW',
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
    String? caption,
    @JsonKey(name: 's3_key') String? s3Key,
    String? filename,
    @JsonKey(name: 'file_size') int? fileSize,
    @JsonKey(name: 'mime_type') String? mimeType,
    int? width,
    int? height,
    @JsonKey(name: 'is_primary') @Default(false) bool isPrimary,

    /// 'evidence' | 'signature' | 'document' — null means legacy/pre-field record.
    String? purpose,
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
    @JsonKey(name: 'protected_snapshot_token') String? protectedSnapshotToken,
    required String id,
    @JsonKey(name: 'report_id') String? reportId,
    @JsonKey(name: 'user_id') String? userId,

    // Report Details
    String? category,
    @JsonKey(name: 'category_key') String? categoryKey,
    @JsonKey(name: 'category_display') String? categoryDisplay,
    @JsonKey(name: 'category_label_snapshot') String? categoryLabelSnapshot,
    @JsonKey(name: 'taxonomy_version') String? taxonomyVersion,
    @JsonKey(name: 'incident_type') String? incidentType,
    String? title,
    @Default('') String description,
    @JsonKey(name: 'incident_datetime') String? incidentDatetime,
    @JsonKey(name: 'is_happening_now') @Default(false) bool isHappeningNow,

    // Location Information
    String? zone,
    @JsonKey(name: 'street_landmark') String? streetLandmark,
    @JsonKey(name: 'municipality_id', readValue: _readMunicipalityId)
    @Default('urdaneta')
    String municipalityId,
    @JsonKey(name: 'barangay_id', readValue: _readBarangayId)
    String? barangayId,
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
    @JsonKey(name: 'responding_agency') String? respondingAgency,
    @JsonKey(name: 'admin_remarks') String? adminRemarks,

    // AI Fields
    @JsonKey(name: 'category_confidence') double? categoryConfidence,
    @JsonKey(name: 'model_version') String? modelVersion,
    @JsonKey(name: 'category_source') String? categorySource,
    @JsonKey(name: 'model_probability') double? modelProbability,
    @JsonKey(name: 'top2_gap') double? top2Gap,
    @JsonKey(name: 'needs_category_review') bool? needsCategoryReview,
    @JsonKey(name: 'review_reasons') @Default([]) List<String> reviewReasons,
    @JsonKey(name: 'is_multi_issue') @Default(false) bool isMultiIssue,
    @JsonKey(name: 'rules_applied') @Default([]) List<String> rulesApplied,
    String? priority,
    @JsonKey(name: 'priority_rank') @NullableIntConverter() int? priorityRank,
    @JsonKey(name: 'priority_level') String? priorityLevel,
    @JsonKey(name: 'suggested_priority_rank')
    @NullableIntConverter()
    int? suggestedPriorityRank,
    @JsonKey(name: 'suggested_priority_level') String? suggestedPriorityLevel,
    @JsonKey(name: 'queue_priority_level') String? queuePriorityLevel,
    @JsonKey(name: 'queue_priority_rank')
    @NullableIntConverter()
    int? queuePriorityRank,
    @JsonKey(name: 'staff_priority_level') String? staffPriorityLevel,
    @JsonKey(name: 'priority_source') String? prioritySource,
    @JsonKey(name: 'priority_is_advisory')
    @Default(true)
    bool priorityIsAdvisory,
    @JsonKey(name: 'needs_priority_review')
    @Default(true)
    bool needsPriorityReview,
    @JsonKey(name: 'priority_review_reasons')
    @Default([])
    List<String> priorityReviewReasons,
    @JsonKey(name: 'linked_report_count') @Default(1) int linkedReportCount,
    @JsonKey(name: 'linked_urgency_boost') @Default(0) int linkedUrgencyBoost,
    @JsonKey(name: 'is_incident_representative')
    @Default(true)
    bool isIncidentRepresentative,
    @JsonKey(name: 'priority_model_version') String? priorityModelVersion,
    @JsonKey(name: 'priority_model_validated')
    @Default(false)
    bool priorityModelValidated,
    @JsonKey(name: 'priority_calibration_version')
    String? priorityCalibrationVersion,
    @JsonKey(name: 'emergency_probability') double? emergencyProbability,
    @JsonKey(name: 'priority_factors')
    @Default({})
    Map<String, String> priorityFactors,
    @JsonKey(name: 'priority_policy_version') String? priorityPolicyVersion,
    @JsonKey(name: 'priority_rules_applied')
    @Default([])
    List<String> priorityRulesApplied,
    @JsonKey(name: 'priority_reasons') List<String>? priorityReasons,
    @JsonKey(name: 'recommended_department') String? recommendedDepartment,
    @JsonKey(name: 'department_confidence') double? departmentConfidence,
    @JsonKey(name: 'routing_reasons') List<String>? routingReasons,
    @JsonKey(name: 'needs_department_review') bool? needsDepartmentReview,
    @JsonKey(name: 'department_key') String? departmentKey,
    @JsonKey(name: 'department_display') String? departmentDisplay,
    @JsonKey(name: 'department_probability') double? departmentProbability,
    @JsonKey(name: 'department_top2_gap') double? departmentTop2Gap,
    @JsonKey(name: 'suggested_departments')
    @Default([])
    List<DepartmentSuggestion> suggestedDepartments,
    @JsonKey(name: 'assigned_department_key') String? assignedDepartmentKey,
    @JsonKey(name: 'department_source') String? departmentSource,
    @JsonKey(name: 'department_is_advisory')
    @Default(true)
    bool departmentIsAdvisory,
    @JsonKey(name: 'department_review_reasons')
    @Default([])
    List<String> departmentReviewReasons,
    @JsonKey(name: 'department_model_version') String? departmentModelVersion,
    @JsonKey(name: 'department_model_validated')
    @Default(false)
    bool departmentModelValidated,
    @JsonKey(name: 'department_calibration_version')
    String? departmentCalibrationVersion,
    @JsonKey(name: 'department_registry_version')
    String? departmentRegistryVersion,
    @JsonKey(name: 'department_policy_version') String? departmentPolicyVersion,
    @JsonKey(name: 'department_rules_applied')
    @Default([])
    List<String> departmentRulesApplied,
    @JsonKey(name: 'credibility_score') double? credibilityScore,
    @JsonKey(name: 'incident_group_id') String? incidentGroupId,
    @JsonKey(name: 'sentiment_score') double? sentimentScore,
    @JsonKey(name: 'auto_category_suggestion') String? autoCategorySuggestion,

    // Images
    @Default([]) List<ReportImage> images,
    @JsonKey(name: 'resolved_proof_image_ids')
    @Default([])
    List<String> resolvedProofImageIds,
    @JsonKey(name: 'closure_signature_image_id')
    String? closureSignatureImageId,
    @JsonKey(name: 'closure_signature_document_ids')
    @Default([])
    List<String> closureSignatureDocumentIds,

    // Timestamps
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    @JsonKey(name: 'submitted_at') String? submittedAt,
    @JsonKey(name: 'verified_at') String? verifiedAt,
    @JsonKey(name: 'resolved_at') String? resolvedAt,

    // Citizen Closure
    @JsonKey(name: 'citizen_verified_at') String? citizenVerifiedAt,
    @JsonKey(name: 'citizen_confirmed_resolved') bool? citizenConfirmedResolved,
    @JsonKey(name: 'citizen_satisfaction')
    @NullableIntConverter()
    int? citizenSatisfaction,
    @JsonKey(name: 'citizen_closure_note') String? citizenClosureNote,

    // Blockchain Integration
    @JsonKey(name: 'on_chain_id') @NullableStringConverter() String? onChainId,
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
    @Default('') String description,
    @JsonKey(name: 'incident_datetime') String? incidentDatetime,
    @JsonKey(name: 'is_happening_now') @Default(false) bool isHappeningNow,

    // Location Information (Section B)
    String? zone,
    @JsonKey(name: 'street_landmark') String? streetLandmark,
    @JsonKey(name: 'municipality_id')
    @Default('urdaneta')
    String municipalityId,
    @JsonKey(name: 'barangay_id') String? barangayId,
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
    @JsonKey(name: 'is_emergency') @Default(false) bool isEmergency,
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
    @JsonKey(name: 'municipality_id') String? municipalityId,
    @JsonKey(name: 'barangay_id') String? barangayId,
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

class ReportCategoryOption {
  final String key;
  final String label;
  final String taxonomyVersion;
  final bool active;

  const ReportCategoryOption({
    required this.key,
    required this.label,
    required this.taxonomyVersion,
    required this.active,
  });

  factory ReportCategoryOption.fromJson(
    dynamic json, {
    String fallbackVersion = 'taxonomy_v1',
  }) {
    if (json is String) {
      final known = ReportCategory.values.where((item) => item.value == json);
      final category = known.isEmpty ? null : known.first;
      return ReportCategoryOption(
        key: category?.taxonomyKey ?? json,
        label: json,
        taxonomyVersion: fallbackVersion,
        active: true,
      );
    }
    final value = json as Map<String, dynamic>;
    return ReportCategoryOption(
      key: value['key']?.toString() ?? '',
      label: value['label']?.toString() ?? value['key']?.toString() ?? '',
      taxonomyVersion: value['taxonomy_version']?.toString() ?? fallbackVersion,
      active: value['active'] != false,
    );
  }
}

List<ReportCategoryOption> _categoryOptionsFromJson(List<dynamic> values) =>
    values.map(ReportCategoryOption.fromJson).toList();

List<Map<String, dynamic>> _categoryOptionsToJson(
  List<ReportCategoryOption> values,
) => values
    .map(
      (item) => {
        'key': item.key,
        'label': item.label,
        'taxonomy_version': item.taxonomyVersion,
        'active': item.active,
      },
    )
    .toList();

@freezed
sealed class ReportFormOptions with _$ReportFormOptions {
  const factory ReportFormOptions({
    @JsonKey(name: 'taxonomy_version')
    @Default('taxonomy_v1')
    String taxonomyVersion,
    @JsonKey(fromJson: _categoryOptionsFromJson, toJson: _categoryOptionsToJson)
    required List<ReportCategoryOption> categories,
    required List<Map<String, dynamic>> statuses,
    @JsonKey(name: 'severity_levels')
    required List<Map<String, dynamic>> severityLevels,
  }) = _ReportFormOptions;

  factory ReportFormOptions.fromJson(Map<String, dynamic> json) =>
      _$ReportFormOptionsFromJson(json);
}
