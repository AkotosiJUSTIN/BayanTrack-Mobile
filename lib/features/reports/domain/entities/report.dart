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
  final DuplicateState? duplicateState;
  final String? relatedReportId;
  final String? relatedIssueId;
  final double? sentimentScore;
  final String? autoCategorySuggestion;

  // Images
  final List<ReportImage> images;

  // Timestamps
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? submittedAt;
  final DateTime? verifiedAt;
  final DateTime? resolvedAt;

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
    this.duplicateState,
    this.relatedReportId,
    this.relatedIssueId,
    this.sentimentScore,
    this.autoCategorySuggestion,
    this.images = const [],
    this.createdAt,
    this.updatedAt,
    this.submittedAt,
    this.verifiedAt,
    this.resolvedAt,
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
    onChainId,
    onChainHash,
    blockchainSynced,
  ];

  @override
  String toString() =>
      'Report($id, ${category?.displayName ?? 'uncategorized'}, ${status.displayName})';
}
