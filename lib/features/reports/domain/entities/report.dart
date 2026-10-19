import 'package:equatable/equatable.dart';
import 'report_enums.dart';
import 'report_image.dart';

class DepartmentSuggestion extends Equatable {
  final String key;
  final String label;
  final double? probability;

  const DepartmentSuggestion({
    required this.key,
    required this.label,
    this.probability,
  });

  @override
  List<Object?> get props => [key, label, probability];
}

class SupportTask extends Equatable {
  final String? taskId;
  final String departmentKey;
  final String department;
  final String task;
  final bool required;
  final String state;
  final String? note;
  final DateTime? assignedAt;
  final DateTime? acknowledgedAt;
  final DateTime? inProgressAt;
  final DateTime? completedAt;
  final DateTime? waivedAt;
  final DateTime? updatedAt;
  final String? updatedBy;

  const SupportTask({
    this.taskId,
    required this.departmentKey,
    required this.department,
    required this.task,
    this.required = false,
    this.state = 'pending',
    this.note,
    this.assignedAt,
    this.acknowledgedAt,
    this.inProgressAt,
    this.completedAt,
    this.waivedAt,
    this.updatedAt,
    this.updatedBy,
  });

  @override
  List<Object?> get props => [
    taskId,
    departmentKey,
    department,
    task,
    required,
    state,
    note,
    assignedAt,
    acknowledgedAt,
    inProgressAt,
    completedAt,
    waivedAt,
    updatedAt,
    updatedBy,
  ];
}

/// Domain entity representing a citizen report.
///
/// This is a pure Dart class with no JSON annotations.
/// Mapping from DTOs is handled by mappers in the data layer.
class Report extends Equatable {
  final String id;
  final String? reportId;
  final String? userId;
  final bool isStale;
  final String? protectedSnapshotToken;

  // Report Details
  final ReportCategory? category;
  final String? categoryKey;
  final String? categoryDisplay;
  final String? taxonomyVersion;
  final String? incidentType;
  final String? incidentTypeKey;
  final String? incidentTypeDisplay;
  final String? incidentCatalogVersion;
  final String? title;
  final String description;
  final DateTime? incidentDatetime;
  final bool isHappeningNow;

  // Location Information
  final String? zone;
  final String? streetLandmark;
  final String municipalityId;
  final String? barangayId;
  final String? cityMunicipality;
  final String? province;
  final double? latitude;
  final double? longitude;
  final LocationAccuracy locationAccuracy;
  final String? location;
  final String? barangay;

  // Severity & Impact
  final SeverityLevel severity;
  final int? peopleAffected;
  final bool isEmergency;
  final Map<String, dynamic>? emergencyContext;

  // System Fields
  final ReportStatus status;
  final String? assignedDepartment;
  final List<SupportTask> supportDepartments;
  final String? routingStatus;
  final List<String> routingReviewReasons;
  final String? respondingAgency;
  final String? adminRemarks;

  // AI Fields
  final double? categoryConfidence;
  final String? modelVersion;
  final String? categorySource;
  final double? modelProbability;
  final double? top2Gap;
  final bool needsCategoryReview;
  final List<String> reviewReasons;
  final bool isMultiIssue;
  final List<String> rulesApplied;
  final String? priority;
  final int? priorityRank;
  final PriorityLevel? priorityLevel;
  final int? suggestedPriorityRank;
  final PriorityLevel? suggestedPriorityLevel;
  final PriorityLevel? queuePriorityLevel;
  final int queuePriorityRank;
  final PriorityLevel? staffPriorityLevel;
  final String? prioritySource;
  final bool priorityIsAdvisory;
  final bool needsPriorityReview;
  final List<String> priorityReviewReasons;
  final int linkedReportCount;
  final int linkedUrgencyBoost;
  final bool isIncidentRepresentative;
  final String? priorityModelVersion;
  final bool priorityModelValidated;
  final String? priorityCalibrationVersion;
  final double? emergencyProbability;
  final Map<String, String> priorityFactors;
  final String? priorityPolicyVersion;
  final List<String> priorityRulesApplied;
  final List<String> priorityReasons;
  final double? credibilityScore;
  // Routing metadata (new)
  final String? recommendedDepartment;
  final double? departmentConfidence;
  final List<String> routingReasons;
  final bool needsDepartmentReview;
  final String? departmentKey;
  final String? departmentDisplay;
  final double? departmentProbability;
  final double? departmentTop2Gap;
  final List<DepartmentSuggestion> suggestedDepartments;
  final String? assignedDepartmentKey;
  final String? departmentSource;
  final bool departmentIsAdvisory;
  final List<String> departmentReviewReasons;
  final String? departmentModelVersion;
  final bool departmentModelValidated;
  final String? departmentCalibrationVersion;
  final String? departmentRegistryVersion;
  final String? departmentPolicyVersion;
  final List<String> departmentRulesApplied;
  final String? incidentGroupId;
  final double? sentimentScore;
  final String? autoCategorySuggestion;

  // Images
  final List<ReportImage> images;
  final List<String> resolvedProofImageIds;
  final String? closureSignatureImageId;
  final List<String> closureSignatureDocumentIds;

  // Timestamps
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? submittedAt;
  final DateTime? verifiedAt;
  final DateTime? resolvedAt;

  // Citizen Closure
  final DateTime? citizenVerifiedAt;
  final bool? citizenConfirmedResolved;
  final int? citizenSatisfaction;
  final String? citizenClosureNote;

  // Blockchain Integration
  final String? onChainId;
  final String? onChainHash;
  final String? blockchainTxnHash;
  final bool blockchainSynced;

  const Report({
    required this.id,
    this.reportId,
    this.userId,
    this.isStale = false,
    this.protectedSnapshotToken,
    this.category,
    this.categoryKey,
    this.categoryDisplay,
    this.taxonomyVersion,
    this.incidentType,
    this.incidentTypeKey,
    this.incidentTypeDisplay,
    this.incidentCatalogVersion,
    this.title,
    required this.description,
    this.incidentDatetime,
    this.isHappeningNow = false,
    this.zone,
    this.streetLandmark,
    this.municipalityId = 'urdaneta',
    this.barangayId,
    this.cityMunicipality,
    this.province,
    this.latitude,
    this.longitude,
    this.locationAccuracy = LocationAccuracy.approximate,
    this.location,
    this.barangay,
    this.severity = SeverityLevel.medium,
    this.peopleAffected,
    this.isEmergency = false,
    this.emergencyContext,
    this.status = ReportStatus.submitted,
    this.assignedDepartment,
    this.supportDepartments = const [],
    this.routingStatus,
    this.routingReviewReasons = const [],
    this.respondingAgency,
    this.adminRemarks,
    this.categoryConfidence,
    this.modelVersion,
    this.categorySource,
    this.modelProbability,
    this.top2Gap,
    this.needsCategoryReview = false,
    this.reviewReasons = const [],
    this.isMultiIssue = false,
    this.rulesApplied = const [],
    this.priority,
    this.priorityRank,
    this.priorityLevel,
    this.suggestedPriorityRank,
    this.suggestedPriorityLevel,
    this.queuePriorityLevel,
    this.queuePriorityRank = 0,
    this.staffPriorityLevel,
    this.prioritySource,
    this.priorityIsAdvisory = true,
    this.needsPriorityReview = true,
    this.priorityReviewReasons = const [],
    this.linkedReportCount = 1,
    this.linkedUrgencyBoost = 0,
    this.isIncidentRepresentative = true,
    this.priorityModelVersion,
    this.priorityModelValidated = false,
    this.priorityCalibrationVersion,
    this.emergencyProbability,
    this.priorityFactors = const {},
    this.priorityPolicyVersion,
    this.priorityRulesApplied = const [],
    this.priorityReasons = const [],
    this.credibilityScore,
    this.recommendedDepartment,
    this.departmentConfidence,
    this.routingReasons = const [],
    this.needsDepartmentReview = false,
    this.departmentKey,
    this.departmentDisplay,
    this.departmentProbability,
    this.departmentTop2Gap,
    this.suggestedDepartments = const [],
    this.assignedDepartmentKey,
    this.departmentSource,
    this.departmentIsAdvisory = true,
    this.departmentReviewReasons = const [],
    this.departmentModelVersion,
    this.departmentModelValidated = false,
    this.departmentCalibrationVersion,
    this.departmentRegistryVersion,
    this.departmentPolicyVersion,
    this.departmentRulesApplied = const [],
    this.incidentGroupId,
    this.sentimentScore,
    this.autoCategorySuggestion,
    this.images = const [],
    this.resolvedProofImageIds = const [],
    this.closureSignatureImageId,
    this.closureSignatureDocumentIds = const [],
    this.createdAt,
    this.updatedAt,
    this.submittedAt,
    this.verifiedAt,
    this.resolvedAt,
    this.citizenVerifiedAt,
    this.citizenConfirmedResolved,
    this.citizenSatisfaction,
    this.citizenClosureNote,
    this.onChainId,
    this.onChainHash,
    this.blockchainTxnHash,
    this.blockchainSynced = false,
  });

  /// Human-readable location string
  String get displayLocation {
    final parts = <String>[?streetLandmark, ?zone, ?cityMunicipality];
    return parts.isNotEmpty ? parts.join(', ') : location ?? 'Unknown location';
  }

  /// Check if report has GPS coordinates
  bool get hasCoordinates => latitude != null && longitude != null;

  // Legacy responses use only the timestamp; an explicit rejection allows review again.
  bool get hasCitizenConfirmedResolution =>
      citizenVerifiedAt != null && citizenConfirmedResolved != false;

  bool get needsCitizenReview =>
      status == ReportStatus.resolved && !hasCitizenConfirmedResolution;

  PriorityLevel? get displayPriorityLevel =>
      queuePriorityLevel ?? suggestedPriorityLevel ?? priorityLevel;

  /// Quick Reports are marked by the backend's central priority policy.
  /// Include the legacy reason so older records remain recognizable.
  bool get isQuickReport =>
      priorityRulesApplied.contains('quick_report_flag_set') ||
      priorityReasons.contains('quick_report_flag_set');

  Set<String> get _supplementalImageIds => {
    ...resolvedProofImageIds,
    ?closureSignatureImageId,
    ...closureSignatureDocumentIds,
  };

  /// Report evidence photos, excluding signatures and proof-of-resolution images.
  ///
  /// Filtering is done on two axes so that both new and legacy records work:
  /// 1. **By ID** — excludes any image whose ID is in [_supplementalImageIds].
  ///    Reliable when [closureSignatureImageId] is populated.
  /// 2. **By purpose tag** — excludes any image explicitly tagged `'signature'`.
  ///    Catches older records where [closureSignatureImageId] was null but the
  ///    image was uploaded with `purpose=signature` via the updated mobile app.
  List<ReportImage> get coreImages {
    final filtered = images
        .where((img) => !_supplementalImageIds.contains(img.id))
        .where((img) => !img.isSignature)
        .toList();
    return filtered.isNotEmpty
        ? filtered
        : images.where((img) => !img.isSignature).toList();
  }

  List<ReportImage> get resolvedProofImages => images
      .where((image) => resolvedProofImageIds.contains(image.id))
      .toList();

  /// Check if report is still open (not resolved or rejected)
  bool get isOpen =>
      status != ReportStatus.resolved && status != ReportStatus.rejected;

  @override
  List<Object?> get props => [
    id,
    reportId,
    userId,
    isStale,
    protectedSnapshotToken,
    updatedAt,
    category,
    categoryKey,
    incidentType,
    incidentTypeKey,
    incidentTypeDisplay,
    incidentCatalogVersion,
    categoryDisplay,
    taxonomyVersion,
    title,
    description,
    status,
    severity,
    isEmergency,
    emergencyContext,
    createdAt,
    citizenVerifiedAt,
    citizenConfirmedResolved,
    onChainId,
    onChainHash,
    blockchainSynced,
    credibilityScore,
    municipalityId,
    barangayId,
    supportDepartments,
    routingStatus,
    routingReviewReasons,
  ];

  @override
  String toString() =>
      'Report($id, ${categoryDisplay ?? category?.displayName ?? 'uncategorized'}, ${status.displayName})';
}
