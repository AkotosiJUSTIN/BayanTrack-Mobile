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
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

_Report _$ReportFromJson(Map<String, dynamic> json) => _Report(
  id: json['id'] as String,
  reportId: json['report_id'] as String?,
  userId: json['user_id'] as String?,
  description: json['description'] as String,
  location: json['location'] as String?,
  zone: json['zone'] as String?,
  latitude: json['latitude'] as String?,
  longitude: json['longitude'] as String?,
  images:
      (json['images'] as List<dynamic>?)
          ?.map((e) => ReportImage.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  status:
      $enumDecodeNullable(_$ReportStatusEnumMap, json['status']) ??
      ReportStatus.pending,
  category: json['category'] as String?,
  categoryConfidence: (json['category_confidence'] as num?)?.toDouble(),
  priority: json['priority'] as String?,
  priorityScore: (json['priority_score'] as num?)?.toInt(),
  duplicateState: json['duplicate_state'] as String? ?? 'New',
  relatedIssueId: json['related_issue_id'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$ReportToJson(_Report instance) => <String, dynamic>{
  'id': instance.id,
  'report_id': instance.reportId,
  'user_id': instance.userId,
  'description': instance.description,
  'location': instance.location,
  'zone': instance.zone,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'images': instance.images,
  'status': _$ReportStatusEnumMap[instance.status]!,
  'category': instance.category,
  'category_confidence': instance.categoryConfidence,
  'priority': instance.priority,
  'priority_score': instance.priorityScore,
  'duplicate_state': instance.duplicateState,
  'related_issue_id': instance.relatedIssueId,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

const _$ReportStatusEnumMap = {
  ReportStatus.pending: 'Pending',
  ReportStatus.inProgress: 'In Progress',
  ReportStatus.resolved: 'Resolved',
  ReportStatus.rejected: 'Rejected',
  ReportStatus.verified: 'Verified',
  ReportStatus.assigned: 'Assigned',
};

_CreateReportRequest _$CreateReportRequestFromJson(Map<String, dynamic> json) =>
    _CreateReportRequest(
      description: json['description'] as String,
      location: json['location'] as String,
      zone: json['zone'] as String,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      category: json['category'] as String?,
    );

Map<String, dynamic> _$CreateReportRequestToJson(
  _CreateReportRequest instance,
) => <String, dynamic>{
  'description': instance.description,
  'location': instance.location,
  'zone': instance.zone,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'category': instance.category,
};

_UpdateReportRequest _$UpdateReportRequestFromJson(Map<String, dynamic> json) =>
    _UpdateReportRequest(
      status: $enumDecodeNullable(_$ReportStatusEnumMap, json['status']),
      category: json['category'] as String?,
      zone: json['zone'] as String?,
    );

Map<String, dynamic> _$UpdateReportRequestToJson(
  _UpdateReportRequest instance,
) => <String, dynamic>{
  'status': _$ReportStatusEnumMap[instance.status],
  'category': instance.category,
  'zone': instance.zone,
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
  pending: (json['pending'] as num?)?.toInt() ?? 0,
  inProgress: (json['in_progress'] as num?)?.toInt() ?? 0,
  resolved: (json['resolved'] as num?)?.toInt() ?? 0,
  rejected: (json['rejected'] as num?)?.toInt() ?? 0,
  verified: (json['verified'] as num?)?.toInt() ?? 0,
  assigned: (json['assigned'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ReportStatsToJson(_ReportStats instance) =>
    <String, dynamic>{
      'total': instance.total,
      'pending': instance.pending,
      'in_progress': instance.inProgress,
      'resolved': instance.resolved,
      'rejected': instance.rejected,
      'verified': instance.verified,
      'assigned': instance.assigned,
    };
