// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReportImage _$ReportImageFromJson(Map<String, dynamic> json) => _ReportImage(
  id: json['id'] as String,
  reportId: json['report_id'] as String?,
  userId: json['user_id'] as String?,
  url: json['url'] as String,
  s3Key: json['s3_key'] as String?,
  filename: json['filename'] as String?,
  fileSize: (json['file_size'] as num?)?.toInt(),
  mimeType: json['mime_type'] as String?,
  width: (json['width'] as num?)?.toInt(),
  height: (json['height'] as num?)?.toInt(),
  isPrimary: json['is_primary'] as bool? ?? false,
  purpose: json['purpose'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$ReportImageToJson(_ReportImage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'report_id': instance.reportId,
      'user_id': instance.userId,
      'url': instance.url,
      's3_key': instance.s3Key,
      'filename': instance.filename,
      'file_size': instance.fileSize,
      'mime_type': instance.mimeType,
      'width': instance.width,
      'height': instance.height,
      'is_primary': instance.isPrimary,
      'purpose': instance.purpose,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

_Report _$ReportFromJson(Map<String, dynamic> json) => _Report(
  id: json['id'] as String,
  reportId: json['report_id'] as String?,
  userId: json['user_id'] as String?,
  category: json['category'] as String?,
  incidentType: json['incident_type'] as String?,
  title: json['title'] as String?,
  description: json['description'] as String,
  incidentDatetime: json['incident_datetime'] as String?,
  isHappeningNow: json['is_happening_now'] as bool? ?? false,
  zone: json['zone'] as String?,
  streetLandmark: json['street_landmark'] as String?,
  cityMunicipality: json['city_municipality'] as String?,
  province: json['province'] as String?,
  latitude: json['latitude'] as String?,
  longitude: json['longitude'] as String?,
  locationAccuracy: json['location_accuracy'] as String? ?? 'approximate',
  location: json['location'] as String?,
  barangay: json['barangay'] as String?,
  severity: json['severity'] as String? ?? 'medium',
  peopleAffected: const NullableIntConverter().fromJson(
    json['people_affected'],
  ),
  isEmergency: json['is_emergency'] as bool? ?? false,
  status: json['status'] as String? ?? 'submitted',
  assignedDepartment: json['assigned_department'] as String?,
  adminRemarks: json['admin_remarks'] as String?,
  categoryConfidence: (json['category_confidence'] as num?)?.toDouble(),
  priority: json['priority'] as String?,
  priorityScore: const NullableIntConverter().fromJson(json['priority_score']),
  priorityLevel: json['priority_level'] as String?,
  priorityReasons: (json['priority_reasons'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  baseScore: const NullableIntConverter().fromJson(json['base_score']),
  hotspotScore: const NullableIntConverter().fromJson(json['hotspot_score']),
  urgencyScore: (json['urgency_score'] as num?)?.toDouble(),
  recommendedDepartment: json['recommended_department'] as String?,
  departmentConfidence: (json['department_confidence'] as num?)?.toDouble(),
  routingReasons: (json['routing_reasons'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  needsDepartmentReview: json['needs_department_review'] as bool?,
  credibilityScore: (json['credibility_score'] as num?)?.toDouble(),
  relatedIssueId: json['related_issue_id'] as String?,
  sentimentScore: (json['sentiment_score'] as num?)?.toDouble(),
  autoCategorySuggestion: json['auto_category_suggestion'] as String?,
  images:
      (json['images'] as List<dynamic>?)
          ?.map((e) => ReportImage.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  resolvedProofImageIds:
      (json['resolved_proof_image_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  closureSignatureImageId: json['closure_signature_image_id'] as String?,
  closureSignatureDocumentIds:
      (json['closure_signature_document_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
  submittedAt: json['submitted_at'] as String?,
  verifiedAt: json['verified_at'] as String?,
  resolvedAt: json['resolved_at'] as String?,
  citizenVerifiedAt: json['citizen_verified_at'] as String?,
  citizenSatisfaction: const NullableIntConverter().fromJson(
    json['citizen_satisfaction'],
  ),
  citizenClosureNote: json['citizen_closure_note'] as String?,
  onChainId: const NullableIntConverter().fromJson(json['on_chain_id']),
  onChainHash: json['on_chain_hash'] as String?,
  blockchainTxnHash: json['blockchain_txn_hash'] as String?,
  blockchainSynced: json['blockchain_synced'] as bool? ?? false,
);

Map<String, dynamic> _$ReportToJson(_Report instance) => <String, dynamic>{
  'id': instance.id,
  'report_id': instance.reportId,
  'user_id': instance.userId,
  'category': instance.category,
  'incident_type': instance.incidentType,
  'title': instance.title,
  'description': instance.description,
  'incident_datetime': instance.incidentDatetime,
  'is_happening_now': instance.isHappeningNow,
  'zone': instance.zone,
  'street_landmark': instance.streetLandmark,
  'city_municipality': instance.cityMunicipality,
  'province': instance.province,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'location_accuracy': instance.locationAccuracy,
  'location': instance.location,
  'barangay': instance.barangay,
  'severity': instance.severity,
  'people_affected': const NullableIntConverter().toJson(
    instance.peopleAffected,
  ),
  'is_emergency': instance.isEmergency,
  'status': instance.status,
  'assigned_department': instance.assignedDepartment,
  'admin_remarks': instance.adminRemarks,
  'category_confidence': instance.categoryConfidence,
  'priority': instance.priority,
  'priority_score': const NullableIntConverter().toJson(instance.priorityScore),
  'priority_level': instance.priorityLevel,
  'priority_reasons': instance.priorityReasons,
  'base_score': const NullableIntConverter().toJson(instance.baseScore),
  'hotspot_score': const NullableIntConverter().toJson(instance.hotspotScore),
  'urgency_score': instance.urgencyScore,
  'recommended_department': instance.recommendedDepartment,
  'department_confidence': instance.departmentConfidence,
  'routing_reasons': instance.routingReasons,
  'needs_department_review': instance.needsDepartmentReview,
  'credibility_score': instance.credibilityScore,
  'related_issue_id': instance.relatedIssueId,
  'sentiment_score': instance.sentimentScore,
  'auto_category_suggestion': instance.autoCategorySuggestion,
  'images': instance.images,
  'resolved_proof_image_ids': instance.resolvedProofImageIds,
  'closure_signature_image_id': instance.closureSignatureImageId,
  'closure_signature_document_ids': instance.closureSignatureDocumentIds,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'submitted_at': instance.submittedAt,
  'verified_at': instance.verifiedAt,
  'resolved_at': instance.resolvedAt,
  'citizen_verified_at': instance.citizenVerifiedAt,
  'citizen_satisfaction': const NullableIntConverter().toJson(
    instance.citizenSatisfaction,
  ),
  'citizen_closure_note': instance.citizenClosureNote,
  'on_chain_id': const NullableIntConverter().toJson(instance.onChainId),
  'on_chain_hash': instance.onChainHash,
  'blockchain_txn_hash': instance.blockchainTxnHash,
  'blockchain_synced': instance.blockchainSynced,
};

_CreateReportRequest _$CreateReportRequestFromJson(Map<String, dynamic> json) =>
    _CreateReportRequest(
      category: json['category'] as String?,
      incidentType: json['incident_type'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String,
      incidentDatetime: json['incident_datetime'] as String?,
      isHappeningNow: json['is_happening_now'] as bool? ?? false,
      zone: json['zone'] as String?,
      streetLandmark: json['street_landmark'] as String?,
      cityMunicipality: json['city_municipality'] as String?,
      province: json['province'] as String?,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      locationAccuracy: json['location_accuracy'] as String? ?? 'approximate',
      location: json['location'] as String?,
      barangay: json['barangay'] as String?,
      declarationConfirmed: json['declaration_confirmed'] as bool? ?? true,
      dataProcessingConsent: json['data_processing_consent'] as bool? ?? true,
    );

Map<String, dynamic> _$CreateReportRequestToJson(
  _CreateReportRequest instance,
) => <String, dynamic>{
  'category': instance.category,
  'incident_type': instance.incidentType,
  'title': instance.title,
  'description': instance.description,
  'incident_datetime': instance.incidentDatetime,
  'is_happening_now': instance.isHappeningNow,
  'zone': instance.zone,
  'street_landmark': instance.streetLandmark,
  'city_municipality': instance.cityMunicipality,
  'province': instance.province,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'location_accuracy': instance.locationAccuracy,
  'location': instance.location,
  'barangay': instance.barangay,
  'declaration_confirmed': instance.declarationConfirmed,
  'data_processing_consent': instance.dataProcessingConsent,
};

_UpdateReportRequest _$UpdateReportRequestFromJson(Map<String, dynamic> json) =>
    _UpdateReportRequest(
      title: json['title'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String?,
      incidentType: json['incident_type'] as String?,
      zone: json['zone'] as String?,
      streetLandmark: json['street_landmark'] as String?,
      cityMunicipality: json['city_municipality'] as String?,
      province: json['province'] as String?,
      barangay: json['barangay'] as String?,
    );

Map<String, dynamic> _$UpdateReportRequestToJson(
  _UpdateReportRequest instance,
) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'category': instance.category,
  'incident_type': instance.incidentType,
  'zone': instance.zone,
  'street_landmark': instance.streetLandmark,
  'city_municipality': instance.cityMunicipality,
  'province': instance.province,
  'barangay': instance.barangay,
};

_ReportStatusUpdateRequest _$ReportStatusUpdateRequestFromJson(
  Map<String, dynamic> json,
) => _ReportStatusUpdateRequest(
  status: json['status'] as String,
  adminRemarks: json['admin_remarks'] as String?,
  assignedDepartment: json['assigned_department'] as String?,
);

Map<String, dynamic> _$ReportStatusUpdateRequestToJson(
  _ReportStatusUpdateRequest instance,
) => <String, dynamic>{
  'status': instance.status,
  'admin_remarks': instance.adminRemarks,
  'assigned_department': instance.assignedDepartment,
};

_PaginatedReports _$PaginatedReportsFromJson(Map<String, dynamic> json) =>
    _PaginatedReports(
      results: (json['results'] as List<dynamic>)
          .map((e) => Report.fromJson(e as Map<String, dynamic>))
          .toList(),
      count: (json['count'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['page_size'] as num?)?.toInt() ?? 20,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$PaginatedReportsToJson(_PaginatedReports instance) =>
    <String, dynamic>{
      'results': instance.results,
      'count': instance.count,
      'total': instance.total,
      'page': instance.page,
      'page_size': instance.pageSize,
      'total_pages': instance.totalPages,
    };

_ReportStats _$ReportStatsFromJson(Map<String, dynamic> json) => _ReportStats(
  total: (json['total'] as num?)?.toInt() ?? 0,
  byStatus: (json['by_status'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toInt()),
  ),
  byCategory: (json['by_category'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toInt()),
  ),
  bySeverity: (json['by_severity'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toInt()),
  ),
  emergencies: (json['emergencies'] as num?)?.toInt() ?? 0,
  submitted: (json['submitted'] as num?)?.toInt() ?? 0,
  underReview: (json['under_review'] as num?)?.toInt() ?? 0,
  verified: (json['verified'] as num?)?.toInt() ?? 0,
  assigned: (json['assigned'] as num?)?.toInt() ?? 0,
  inProgress: (json['in_progress'] as num?)?.toInt() ?? 0,
  resolved: (json['resolved'] as num?)?.toInt() ?? 0,
  rejected: (json['rejected'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ReportStatsToJson(_ReportStats instance) =>
    <String, dynamic>{
      'total': instance.total,
      'by_status': instance.byStatus,
      'by_category': instance.byCategory,
      'by_severity': instance.bySeverity,
      'emergencies': instance.emergencies,
      'submitted': instance.submitted,
      'under_review': instance.underReview,
      'verified': instance.verified,
      'assigned': instance.assigned,
      'in_progress': instance.inProgress,
      'resolved': instance.resolved,
      'rejected': instance.rejected,
    };

_ReportFormOptions _$ReportFormOptionsFromJson(Map<String, dynamic> json) =>
    _ReportFormOptions(
      categories: (json['categories'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      statuses: (json['statuses'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      severityLevels: (json['severity_levels'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
    );

Map<String, dynamic> _$ReportFormOptionsToJson(_ReportFormOptions instance) =>
    <String, dynamic>{
      'categories': instance.categories,
      'statuses': instance.statuses,
      'severity_levels': instance.severityLevels,
    };
