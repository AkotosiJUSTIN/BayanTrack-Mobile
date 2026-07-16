import '../blockchain_models.dart' as blockchain_dto;
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
  static Report fromDto(dto.Report dtoReport) {
    return Report(
      id: dtoReport.id,
      reportId: dtoReport.reportId,
      userId: dtoReport.userId,
      category: ReportCategory.fromString(dtoReport.category),
      incidentType: dtoReport.incidentType,
      title: dtoReport.title,
      description: dtoReport.description,
      incidentDatetime: dtoReport.incidentDatetime != null
          ? DateTime.tryParse(dtoReport.incidentDatetime!)
          : null,
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
      adminRemarks: dtoReport.adminRemarks,
      categoryConfidence: dtoReport.categoryConfidence,
      priority: dtoReport.priority,
      priorityScore: dtoReport.priorityScore,
      priorityLevel: PriorityLevel.fromString(dtoReport.priorityLevel),
      priorityReasons: dtoReport.priorityReasons ?? [],
      baseScore: dtoReport.baseScore,
      hotspotScore: dtoReport.hotspotScore,
      urgencyScore: dtoReport.urgencyScore,
      recommendedDepartment: dtoReport.recommendedDepartment,
      departmentConfidence: dtoReport.departmentConfidence,
      routingReasons: dtoReport.routingReasons ?? [],
      needsDepartmentReview: dtoReport.needsDepartmentReview ?? false,
      credibilityScore: dtoReport.credibilityScore,
      relatedIssueId: dtoReport.relatedIssueId,
      sentimentScore: dtoReport.sentimentScore,
      autoCategorySuggestion: dtoReport.autoCategorySuggestion,
      images: dtoReport.images.map(imageFromDto).toList(),
      resolvedProofImageIds: dtoReport.resolvedProofImageIds,
      closureSignatureImageId: dtoReport.closureSignatureImageId,
      closureSignatureDocumentIds: dtoReport.closureSignatureDocumentIds,
      createdAt: dtoReport.createdAt != null
          ? DateTime.tryParse(dtoReport.createdAt!)
          : null,
      updatedAt: dtoReport.updatedAt != null
          ? DateTime.tryParse(dtoReport.updatedAt!)
          : null,
      submittedAt: dtoReport.submittedAt != null
          ? DateTime.tryParse(dtoReport.submittedAt!)
          : null,
      verifiedAt: dtoReport.verifiedAt != null
          ? DateTime.tryParse(dtoReport.verifiedAt!)
          : null,
      resolvedAt: dtoReport.resolvedAt != null
          ? DateTime.tryParse(dtoReport.resolvedAt!)
          : null,
      citizenVerifiedAt: dtoReport.citizenVerifiedAt != null
          ? DateTime.tryParse(dtoReport.citizenVerifiedAt!)
          : null,
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
      createdAt: dtoImage.createdAt != null
          ? DateTime.tryParse(dtoImage.createdAt!)
          : null,
    );
  }

  /// Convert DTO PaginatedReports to domain entity
  static PaginatedReports paginatedFromDto(dto.PaginatedReports dtoPaginated) {
    return PaginatedReports(
      results: dtoPaginated.results.map(fromDto).toList(),
      count: dtoPaginated.count,
      total: dtoPaginated.total,
      page: dtoPaginated.page,
      pageSize: dtoPaginated.pageSize,
      totalPages: dtoPaginated.totalPages,
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
