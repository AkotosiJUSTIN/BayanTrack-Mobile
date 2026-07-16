import 'package:equatable/equatable.dart';
import 'report_enums.dart';
import 'report_image.dart';

/// Domain entity representing a citizen report.
///
/// This is a pure Dart class with no JSON annotations.
/// Mapping from DTOs is handled by mappers in the data layer.
class Report extends Equatable {
  final String id;
  final String? reportId;
  final String? userId;

  // Report Details
  final ReportCategory? category;
  final String? incidentType;
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

  // System Fields
  final ReportStatus status;
  final String? assignedDepartment;
  final String? adminRemarks;

  // AI Fields
  final double? categoryConfidence;
  final String? priority;
  final int? priorityScore;
  final PriorityLevel? priorityLevel;
  final List<String> priorityReasons;
  final int? baseScore;
  final int? hotspotScore;
  final double? urgencyScore;
  final double? credibilityScore;
  // Routing metadata (new)
  final String? recommendedDepartment;
  final double? departmentConfidence;
  final List<String> routingReasons;
  final bool needsDepartmentReview;
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
  final int? citizenSatisfaction;
  final String? citizenClosureNote;

  // Blockchain Integration
  final int? onChainId;
  final String? onChainHash;
  final String? blockchainTxnHash;
  final bool blockchainSynced;

  const Report({
    required this.id,
    this.reportId,
    this.userId,
    this.category,
    this.incidentType,
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
    this.status = ReportStatus.submitted,
    this.assignedDepartment,
    this.adminRemarks,
    this.categoryConfidence,
    this.priority,
    this.priorityScore,
    this.priorityLevel,
    this.priorityReasons = const [],
    this.baseScore,
    this.hotspotScore,
    this.urgencyScore,
    this.credibilityScore,
    this.recommendedDepartment,
    this.departmentConfidence,
    this.routingReasons = const [],
    this.needsDepartmentReview = false,
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
    this.citizenSatisfaction,
    this.citizenClosureNote,
    this.onChainId,
    this.onChainHash,
    this.blockchainTxnHash,
    this.blockchainSynced = false,
  });

  /// Human-readable location string
  String get displayLocation {
    final parts = <String>[
      if (streetLandmark != null) streetLandmark!,
      if (zone != null) zone!,
      if (cityMunicipality != null) cityMunicipality!,
    ];
    return parts.isNotEmpty ? parts.join(', ') : location ?? 'Unknown location';
  }

  /// Check if report has GPS coordinates
  bool get hasCoordinates => latitude != null && longitude != null;

  Set<String> get _supplementalImageIds => {
    ...resolvedProofImageIds,
    if (closureSignatureImageId != null) closureSignatureImageId!,
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
    category,
    title,
    description,
    status,
    severity,
    isEmergency,
    createdAt,
    citizenVerifiedAt,
    onChainId,
    onChainHash,
    blockchainSynced,
    credibilityScore,
    municipalityId,
    barangayId,
  ];

  @override
  String toString() =>
      'Report($id, ${category?.displayName ?? 'uncategorized'}, ${status.displayName})';
}
