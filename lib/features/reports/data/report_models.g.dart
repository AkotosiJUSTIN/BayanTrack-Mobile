// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DepartmentSuggestion _$DepartmentSuggestionFromJson(
  Map<String, dynamic> json,
) => _DepartmentSuggestion(
  key: json['key'] as String,
  label: json['label'] as String,
  probability: (json['probability'] as num?)?.toDouble(),
);

Map<String, dynamic> _$DepartmentSuggestionToJson(
  _DepartmentSuggestion instance,
) => <String, dynamic>{
  'key': instance.key,
  'label': instance.label,
  'probability': instance.probability,
};

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
  categoryKey: json['category_key'] as String?,
  categoryDisplay: json['category_display'] as String?,
  categoryLabelSnapshot: json['category_label_snapshot'] as String?,
  taxonomyVersion: json['taxonomy_version'] as String?,
  incidentType: json['incident_type'] as String?,
  title: json['title'] as String?,
  description: json['description'] as String? ?? '',
  incidentDatetime: json['incident_datetime'] as String?,
  isHappeningNow: json['is_happening_now'] as bool? ?? false,
  zone: json['zone'] as String?,
  streetLandmark: json['street_landmark'] as String?,
  municipalityId:
      _readMunicipalityId(json, 'municipality_id') as String? ?? 'urdaneta',
  barangayId: _readBarangayId(json, 'barangay_id') as String?,
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
  modelVersion: json['model_version'] as String?,
  categorySource: json['category_source'] as String?,
  modelProbability: (json['model_probability'] as num?)?.toDouble(),
  top2Gap: (json['top2_gap'] as num?)?.toDouble(),
  needsCategoryReview: json['needs_category_review'] as bool?,
  reviewReasons:
      (json['review_reasons'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  isMultiIssue: json['is_multi_issue'] as bool? ?? false,
  rulesApplied:
      (json['rules_applied'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  priority: json['priority'] as String?,
  priorityScore: const NullableIntConverter().fromJson(json['priority_score']),
  priorityLevel: json['priority_level'] as String?,
  suggestedPriorityScore: (json['suggested_priority_score'] as num?)
      ?.toDouble(),
  suggestedPriorityLevel: json['suggested_priority_level'] as String?,
  queuePriorityScore: (json['queue_priority_score'] as num?)?.toDouble(),
  queuePriorityLevel: json['queue_priority_level'] as String?,
  queuePriorityRank: const NullableIntConverter().fromJson(
    json['queue_priority_rank'],
  ),
  staffPriorityLevel: json['staff_priority_level'] as String?,
  prioritySource: json['priority_source'] as String?,
  priorityIsAdvisory: json['priority_is_advisory'] as bool? ?? true,
  needsPriorityReview: json['needs_priority_review'] as bool? ?? true,
  priorityReviewReasons:
      (json['priority_review_reasons'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  linkedReportCount: (json['linked_report_count'] as num?)?.toInt() ?? 1,
  linkedUrgencyBoost: (json['linked_urgency_boost'] as num?)?.toInt() ?? 0,
  isIncidentRepresentative: json['is_incident_representative'] as bool? ?? true,
  priorityModelVersion: json['priority_model_version'] as String?,
  priorityModelValidated: json['priority_model_validated'] as bool? ?? false,
  priorityCalibrationVersion: json['priority_calibration_version'] as String?,
  emergencyProbability: (json['emergency_probability'] as num?)?.toDouble(),
  priorityComponents:
      (json['priority_components'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ) ??
      const {},
  priorityPolicyVersion: json['priority_policy_version'] as String?,
  priorityRulesApplied:
      (json['priority_rules_applied'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
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
  departmentKey: json['department_key'] as String?,
  departmentDisplay: json['department_display'] as String?,
  departmentProbability: (json['department_probability'] as num?)?.toDouble(),
  departmentTop2Gap: (json['department_top2_gap'] as num?)?.toDouble(),
  suggestedDepartments:
      (json['suggested_departments'] as List<dynamic>?)
          ?.map((e) => DepartmentSuggestion.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  assignedDepartmentKey: json['assigned_department_key'] as String?,
  departmentSource: json['department_source'] as String?,
  departmentIsAdvisory: json['department_is_advisory'] as bool? ?? true,
  departmentReviewReasons:
      (json['department_review_reasons'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  departmentModelVersion: json['department_model_version'] as String?,
  departmentModelValidated:
      json['department_model_validated'] as bool? ?? false,
  departmentCalibrationVersion:
      json['department_calibration_version'] as String?,
  departmentRegistryVersion: json['department_registry_version'] as String?,
  departmentPolicyVersion: json['department_policy_version'] as String?,
  departmentRulesApplied:
      (json['department_rules_applied'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  credibilityScore: (json['credibility_score'] as num?)?.toDouble(),
  incidentGroupId: json['incident_group_id'] as String?,
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
  onChainId: const NullableStringConverter().fromJson(json['on_chain_id']),
  onChainHash: json['on_chain_hash'] as String?,
  blockchainTxnHash: json['blockchain_txn_hash'] as String?,
  blockchainSynced: json['blockchain_synced'] as bool? ?? false,
);

Map<String, dynamic> _$ReportToJson(_Report instance) => <String, dynamic>{
  'id': instance.id,
  'report_id': instance.reportId,
  'user_id': instance.userId,
  'category': instance.category,
  'category_key': instance.categoryKey,
  'category_display': instance.categoryDisplay,
  'category_label_snapshot': instance.categoryLabelSnapshot,
  'taxonomy_version': instance.taxonomyVersion,
  'incident_type': instance.incidentType,
  'title': instance.title,
  'description': instance.description,
  'incident_datetime': instance.incidentDatetime,
  'is_happening_now': instance.isHappeningNow,
  'zone': instance.zone,
  'street_landmark': instance.streetLandmark,
  'municipality_id': instance.municipalityId,
  'barangay_id': instance.barangayId,
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
  'model_version': instance.modelVersion,
  'category_source': instance.categorySource,
  'model_probability': instance.modelProbability,
  'top2_gap': instance.top2Gap,
  'needs_category_review': instance.needsCategoryReview,
  'review_reasons': instance.reviewReasons,
  'is_multi_issue': instance.isMultiIssue,
  'rules_applied': instance.rulesApplied,
  'priority': instance.priority,
  'priority_score': const NullableIntConverter().toJson(instance.priorityScore),
  'priority_level': instance.priorityLevel,
  'suggested_priority_score': instance.suggestedPriorityScore,
  'suggested_priority_level': instance.suggestedPriorityLevel,
  'queue_priority_score': instance.queuePriorityScore,
  'queue_priority_level': instance.queuePriorityLevel,
  'queue_priority_rank': const NullableIntConverter().toJson(
    instance.queuePriorityRank,
  ),
  'staff_priority_level': instance.staffPriorityLevel,
  'priority_source': instance.prioritySource,
  'priority_is_advisory': instance.priorityIsAdvisory,
  'needs_priority_review': instance.needsPriorityReview,
  'priority_review_reasons': instance.priorityReviewReasons,
  'linked_report_count': instance.linkedReportCount,
  'linked_urgency_boost': instance.linkedUrgencyBoost,
  'is_incident_representative': instance.isIncidentRepresentative,
  'priority_model_version': instance.priorityModelVersion,
  'priority_model_validated': instance.priorityModelValidated,
  'priority_calibration_version': instance.priorityCalibrationVersion,
  'emergency_probability': instance.emergencyProbability,
  'priority_components': instance.priorityComponents,
  'priority_policy_version': instance.priorityPolicyVersion,
  'priority_rules_applied': instance.priorityRulesApplied,
  'priority_reasons': instance.priorityReasons,
  'base_score': const NullableIntConverter().toJson(instance.baseScore),
  'hotspot_score': const NullableIntConverter().toJson(instance.hotspotScore),
  'urgency_score': instance.urgencyScore,
  'recommended_department': instance.recommendedDepartment,
  'department_confidence': instance.departmentConfidence,
  'routing_reasons': instance.routingReasons,
  'needs_department_review': instance.needsDepartmentReview,
  'department_key': instance.departmentKey,
  'department_display': instance.departmentDisplay,
  'department_probability': instance.departmentProbability,
  'department_top2_gap': instance.departmentTop2Gap,
  'suggested_departments': instance.suggestedDepartments,
  'assigned_department_key': instance.assignedDepartmentKey,
  'department_source': instance.departmentSource,
  'department_is_advisory': instance.departmentIsAdvisory,
  'department_review_reasons': instance.departmentReviewReasons,
  'department_model_version': instance.departmentModelVersion,
  'department_model_validated': instance.departmentModelValidated,
  'department_calibration_version': instance.departmentCalibrationVersion,
  'department_registry_version': instance.departmentRegistryVersion,
  'department_policy_version': instance.departmentPolicyVersion,
  'department_rules_applied': instance.departmentRulesApplied,
  'credibility_score': instance.credibilityScore,
  'incident_group_id': instance.incidentGroupId,
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
  'on_chain_id': const NullableStringConverter().toJson(instance.onChainId),
  'on_chain_hash': instance.onChainHash,
  'blockchain_txn_hash': instance.blockchainTxnHash,
  'blockchain_synced': instance.blockchainSynced,
};

_CreateReportRequest _$CreateReportRequestFromJson(Map<String, dynamic> json) =>
    _CreateReportRequest(
      category: json['category'] as String?,
      incidentType: json['incident_type'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String? ?? '',
      incidentDatetime: json['incident_datetime'] as String?,
      isHappeningNow: json['is_happening_now'] as bool? ?? false,
      zone: json['zone'] as String?,
      streetLandmark: json['street_landmark'] as String?,
      municipalityId: json['municipality_id'] as String? ?? 'urdaneta',
      barangayId: json['barangay_id'] as String?,
      cityMunicipality: json['city_municipality'] as String?,
      province: json['province'] as String?,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      locationAccuracy: json['location_accuracy'] as String? ?? 'approximate',
      location: json['location'] as String?,
      barangay: json['barangay'] as String?,
      declarationConfirmed: json['declaration_confirmed'] as bool? ?? true,
      dataProcessingConsent: json['data_processing_consent'] as bool? ?? true,
      isEmergency: json['is_emergency'] as bool? ?? false,
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
  'municipality_id': instance.municipalityId,
  'barangay_id': instance.barangayId,
  'city_municipality': instance.cityMunicipality,
  'province': instance.province,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'location_accuracy': instance.locationAccuracy,
  'location': instance.location,
  'barangay': instance.barangay,
  'declaration_confirmed': instance.declarationConfirmed,
  'data_processing_consent': instance.dataProcessingConsent,
  'is_emergency': instance.isEmergency,
};

_UpdateReportRequest _$UpdateReportRequestFromJson(Map<String, dynamic> json) =>
    _UpdateReportRequest(
      title: json['title'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String?,
      incidentType: json['incident_type'] as String?,
      zone: json['zone'] as String?,
      streetLandmark: json['street_landmark'] as String?,
      municipalityId: json['municipality_id'] as String?,
      barangayId: json['barangay_id'] as String?,
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
  'municipality_id': instance.municipalityId,
  'barangay_id': instance.barangayId,
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
      taxonomyVersion: json['taxonomy_version'] as String? ?? 'taxonomy_v1',
      categories: _categoryOptionsFromJson(json['categories'] as List),
      statuses: (json['statuses'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      severityLevels: (json['severity_levels'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
    );

Map<String, dynamic> _$ReportFormOptionsToJson(_ReportFormOptions instance) =>
    <String, dynamic>{
      'taxonomy_version': instance.taxonomyVersion,
      'categories': _categoryOptionsToJson(instance.categories),
      'statuses': instance.statuses,
      'severity_levels': instance.severityLevels,
    };
