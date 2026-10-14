import '../blockchain_models.dart' as blockchain_dto;
import '../../../../core/utils/api_datetime.dart';
import '../../domain/entities/blockchain_verification.dart';
import '../../domain/entities/paginated_reports.dart';
import '../../domain/entities/report.dart';
import '../../domain/entities/report_enums.dart';
import '../../domain/entities/report_image.dart';
import '../../domain/entities/report_stats.dart';
import '../report_models.dart' as dto;

/// Mapper for converting between DTOs and domain entities.
class ReportMapper {
  ReportMapper._(); // Prevent instantiation

  /// Convert DTO Report to domain Report entity
  static Report fromDto(dto.Report dtoReport, {bool isStale = false}) {
    return Report(
      id: dtoReport.id,
      reportId: dtoReport.reportId,
      userId: dtoReport.userId,
      isStale: isStale,
      category: ReportCategory.fromString(dtoReport.category),
      categoryKey: dtoReport.categoryKey,
      categoryDisplay: dtoReport.categoryDisplay ?? dtoReport.category,
      taxonomyVersion: dtoReport.taxonomyVersion,
      incidentType: dtoReport.incidentType,
      title: dtoReport.title,
      description: dtoReport.description,
      incidentDatetime: parseApiDateTime(dtoReport.incidentDatetime),
      isHappeningNow: dtoReport.isHappeningNow,
      zone: dtoReport.zone,
      streetLandmark: dtoReport.streetLandmark,
      municipalityId: dtoReport.municipalityId,
      barangayId: dtoReport.barangayId,
      cityMunicipality: dtoReport.cityMunicipality,
      province: dtoReport.province,
      latitude: double.tryParse(dtoReport.latitude ?? ''),
      longitude: double.tryParse(dtoReport.longitude ?? ''),
      locationAccuracy: LocationAccuracy.fromString(dtoReport.locationAccuracy),
      location: dtoReport.location,
      barangay: dtoReport.barangay,
      severity: SeverityLevel.fromString(dtoReport.severity),
      peopleAffected: dtoReport.peopleAffected,
      isEmergency: dtoReport.isEmergency,
      status: ReportStatus.fromString(dtoReport.status),
      assignedDepartment: dtoReport.assignedDepartment,
      respondingAgency: dtoReport.respondingAgency?.trim().isNotEmpty == true
          ? dtoReport.respondingAgency
          : null,
      adminRemarks: dtoReport.adminRemarks,
      categoryConfidence: dtoReport.categoryConfidence,
      modelVersion: dtoReport.modelVersion,
      categorySource: dtoReport.categorySource,
      modelProbability: dtoReport.modelProbability,
      top2Gap: dtoReport.top2Gap,
      needsCategoryReview: dtoReport.needsCategoryReview ?? false,
      reviewReasons: dtoReport.reviewReasons,
      isMultiIssue: dtoReport.isMultiIssue,
      rulesApplied: dtoReport.rulesApplied,
      priority: dtoReport.priority,
      priorityRank: dtoReport.priorityRank,
      priorityLevel: PriorityLevel.fromString(dtoReport.priorityLevel),
      suggestedPriorityRank: dtoReport.suggestedPriorityRank,
      suggestedPriorityLevel: PriorityLevel.fromString(
        dtoReport.suggestedPriorityLevel,
      ),
      queuePriorityLevel: PriorityLevel.fromString(
        dtoReport.queuePriorityLevel,
      ),
      queuePriorityRank: dtoReport.queuePriorityRank ?? 0,
      staffPriorityLevel: PriorityLevel.fromString(
        dtoReport.staffPriorityLevel,
      ),
      prioritySource: dtoReport.prioritySource,
      priorityIsAdvisory: dtoReport.priorityIsAdvisory,
      needsPriorityReview: dtoReport.needsPriorityReview,
      priorityReviewReasons: dtoReport.priorityReviewReasons,
      linkedReportCount: dtoReport.linkedReportCount,
      linkedUrgencyBoost: dtoReport.linkedUrgencyBoost,
      isIncidentRepresentative: dtoReport.isIncidentRepresentative,
      priorityModelVersion: dtoReport.priorityModelVersion,
      priorityModelValidated: dtoReport.priorityModelValidated,
      priorityCalibrationVersion: dtoReport.priorityCalibrationVersion,
      emergencyProbability: dtoReport.emergencyProbability,
      priorityFactors: dtoReport.priorityFactors,
      priorityPolicyVersion: dtoReport.priorityPolicyVersion,
      priorityRulesApplied: dtoReport.priorityRulesApplied,
      priorityReasons: dtoReport.priorityReasons ?? [],
      recommendedDepartment: dtoReport.recommendedDepartment,
      departmentConfidence: dtoReport.departmentConfidence,
      routingReasons: dtoReport.routingReasons ?? [],
      needsDepartmentReview: dtoReport.needsDepartmentReview ?? false,
      departmentKey: dtoReport.departmentKey,
      departmentDisplay:
          dtoReport.departmentDisplay ?? dtoReport.recommendedDepartment,
      departmentProbability:
          dtoReport.departmentProbability ?? dtoReport.departmentConfidence,
      departmentTop2Gap: dtoReport.departmentTop2Gap,
      suggestedDepartments: dtoReport.suggestedDepartments
          .map(
            (suggestion) => DepartmentSuggestion(
              key: suggestion.key,
              label: suggestion.label,
              probability: suggestion.probability,
            ),
          )
          .toList(growable: false),
      assignedDepartmentKey: dtoReport.assignedDepartmentKey,
      departmentSource: dtoReport.departmentSource,
      departmentIsAdvisory: dtoReport.departmentIsAdvisory,
      departmentReviewReasons: dtoReport.departmentReviewReasons,
      departmentModelVersion: dtoReport.departmentModelVersion,
      departmentModelValidated: dtoReport.departmentModelValidated,
      departmentCalibrationVersion: dtoReport.departmentCalibrationVersion,
      departmentRegistryVersion: dtoReport.departmentRegistryVersion,
      departmentPolicyVersion: dtoReport.departmentPolicyVersion,
      departmentRulesApplied: dtoReport.departmentRulesApplied,
      credibilityScore: dtoReport.credibilityScore,
      incidentGroupId: dtoReport.incidentGroupId,
      sentimentScore: dtoReport.sentimentScore,
      autoCategorySuggestion: dtoReport.autoCategorySuggestion,
      images: dtoReport.images.map(imageFromDto).toList(),
      resolvedProofImageIds: dtoReport.resolvedProofImageIds,
      closureSignatureImageId: dtoReport.closureSignatureImageId,
      closureSignatureDocumentIds: dtoReport.closureSignatureDocumentIds,
      createdAt: parseApiDateTime(dtoReport.createdAt),
      updatedAt: parseApiDateTime(dtoReport.updatedAt),
      submittedAt: parseApiDateTime(dtoReport.submittedAt),
      verifiedAt: parseApiDateTime(dtoReport.verifiedAt),
      resolvedAt: parseApiDateTime(dtoReport.resolvedAt),
      citizenVerifiedAt: parseApiDateTime(dtoReport.citizenVerifiedAt),
      citizenConfirmedResolved: dtoReport.citizenConfirmedResolved,
      citizenSatisfaction: dtoReport.citizenSatisfaction,
      citizenClosureNote: dtoReport.citizenClosureNote,
      onChainId: dtoReport.onChainId,
      onChainHash: dtoReport.onChainHash,
      blockchainTxnHash: dtoReport.blockchainTxnHash,
      blockchainSynced: dtoReport.blockchainSynced,
    );
  }

  /// Convert DTO ReportImage to domain ReportImage entity
  static ReportImage imageFromDto(dto.ReportImage dtoImage) {
    return ReportImage(
      id: dtoImage.id,
      url: dtoImage.url,
      reportId: dtoImage.reportId,
      userId: dtoImage.userId,
      isPrimary: dtoImage.isPrimary,
      purpose: dtoImage.purpose,
      width: dtoImage.width,
      height: dtoImage.height,
      createdAt: parseApiDateTime(dtoImage.createdAt),
    );
  }

  /// Convert DTO PaginatedReports to domain entity
  static PaginatedReports paginatedFromDto(
    dto.PaginatedReports dtoPaginated, {
    bool isStale = false,
  }) {
    return PaginatedReports(
      results: dtoPaginated.results
          .map((report) => fromDto(report, isStale: isStale))
          .toList(),
      count: dtoPaginated.count,
      total: dtoPaginated.total,
      page: dtoPaginated.page,
      pageSize: dtoPaginated.pageSize,
      totalPages: dtoPaginated.totalPages,
      isStale: isStale,
    );
  }

  static ReportStats statsFromDto(dto.ReportStats dtoStats) {
    return ReportStats(
      total: dtoStats.total,
      byStatus: dtoStats.byStatus ?? {},
      byCategory: dtoStats.byCategory ?? {},
      bySeverity: dtoStats.bySeverity ?? {},
      emergencies: dtoStats.emergencies,
      submitted: dtoStats.submitted,
      underReview: dtoStats.underReview,
      verified: dtoStats.verified,
      assigned: dtoStats.assigned,
      inProgress: dtoStats.inProgress,
      resolved: dtoStats.resolved,
      rejected: dtoStats.rejected,
    );
  }

  static BlockchainVerificationResult blockchainVerificationFromDto(
    blockchain_dto.BlockchainVerificationResultDto result,
  ) {
    return BlockchainVerificationResult(
      reportId: result.reportId,
      onChainId: result.onChainId,
      verified: result.verified,
      statusVerified: result.statusVerified,
      blockchainData: result.blockchainData,
      auditHistory: result.auditHistory
          .map(
            (e) => BlockchainAuditEntry(
              reportId: e.reportId,
              actionType: e.actionType,
              actor: e.actor,
              timestamp: e.timestamp,
              detailsHash: e.detailsHash,
              oldStatus:
                  e.oldStatus >= 0 && e.oldStatus < ReportStatus.values.length
                  ? ReportStatus.values[e.oldStatus].displayName
                  : e.oldStatus.toString(),
              newStatus:
                  e.newStatus >= 0 && e.newStatus < ReportStatus.values.length
                  ? ReportStatus.values[e.newStatus].displayName
                  : e.newStatus.toString(),
            ),
          )
          .toList(),
      message: result.message,
      notFoundOnChain: result.notFoundOnChain,
      connectionError: result.connectionError,
      isAnchored: result.isAnchored,
    );
  }
}
