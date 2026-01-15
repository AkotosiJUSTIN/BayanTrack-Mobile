// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Report _$ReportFromJson(Map<String, dynamic> json) => _Report(
  id: json['_id'] as String,
  description: json['description'] as String,
  status:
      $enumDecodeNullable(_$ReportStatusEnumMap, json['status']) ??
      ReportStatus.pending,
  category: json['category'] as String?,
  barangay: json['barangay'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  images:
      (json['images'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  createdBy: json['created_by'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
  aiCategory: json['ai_category'] as String?,
  aiPriority: (json['ai_priority'] as num?)?.toInt(),
  aiConfidence: (json['ai_confidence'] as num?)?.toDouble(),
);

Map<String, dynamic> _$ReportToJson(_Report instance) => <String, dynamic>{
  '_id': instance.id,
  'description': instance.description,
  'status': _$ReportStatusEnumMap[instance.status]!,
  'category': instance.category,
  'barangay': instance.barangay,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'images': instance.images,
  'created_by': instance.createdBy,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'ai_category': instance.aiCategory,
  'ai_priority': instance.aiPriority,
  'ai_confidence': instance.aiConfidence,
};

const _$ReportStatusEnumMap = {
  ReportStatus.pending: 'pending',
  ReportStatus.inProgress: 'in_progress',
  ReportStatus.resolved: 'resolved',
  ReportStatus.closed: 'closed',
};

_CreateReportRequest _$CreateReportRequestFromJson(Map<String, dynamic> json) =>
    _CreateReportRequest(
      description: json['description'] as String,
      category: json['category'] as String?,
      barangay: json['barangay'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$CreateReportRequestToJson(
  _CreateReportRequest instance,
) => <String, dynamic>{
  'description': instance.description,
  'category': instance.category,
  'barangay': instance.barangay,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
};

_UpdateReportRequest _$UpdateReportRequestFromJson(Map<String, dynamic> json) =>
    _UpdateReportRequest(
      status: $enumDecodeNullable(_$ReportStatusEnumMap, json['status']),
      category: json['category'] as String?,
      barangay: json['barangay'] as String?,
    );

Map<String, dynamic> _$UpdateReportRequestToJson(
  _UpdateReportRequest instance,
) => <String, dynamic>{
  'status': _$ReportStatusEnumMap[instance.status],
  'category': instance.category,
  'barangay': instance.barangay,
};

_PaginatedReports _$PaginatedReportsFromJson(Map<String, dynamic> json) =>
    _PaginatedReports(
      results: (json['results'] as List<dynamic>)
          .map((e) => Report.fromJson(e as Map<String, dynamic>))
          .toList(),
      count: (json['count'] as num?)?.toInt() ?? 0,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
    );

Map<String, dynamic> _$PaginatedReportsToJson(_PaginatedReports instance) =>
    <String, dynamic>{
      'results': instance.results,
      'count': instance.count,
      'next': instance.next,
      'previous': instance.previous,
    };

_ReportStats _$ReportStatsFromJson(Map<String, dynamic> json) => _ReportStats(
  total: (json['total'] as num?)?.toInt() ?? 0,
  pending: (json['pending'] as num?)?.toInt() ?? 0,
  inProgress: (json['in_progress'] as num?)?.toInt() ?? 0,
  resolved: (json['resolved'] as num?)?.toInt() ?? 0,
  closed: (json['closed'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ReportStatsToJson(_ReportStats instance) =>
    <String, dynamic>{
      'total': instance.total,
      'pending': instance.pending,
      'in_progress': instance.inProgress,
      'resolved': instance.resolved,
      'closed': instance.closed,
    };
