// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppNotification _$AppNotificationFromJson(Map<String, dynamic> json) =>
    _AppNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type:
          $enumDecodeNullable(
            _$NotificationTypeEnumMap,
            json['type'],
            unknownValue: NotificationType.system,
          ) ??
          NotificationType.system,
      isRead: json['is_read'] as bool? ?? false,
      reportId: json['related_report_id'] as String?,
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$AppNotificationToJson(_AppNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'message': instance.message,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'is_read': instance.isRead,
      'related_report_id': instance.reportId,
      'created_at': instance.createdAt,
    };

const _$NotificationTypeEnumMap = {
  NotificationType.reportSubmitted: 'report_submitted',
  NotificationType.statusChange: 'status_change',
  NotificationType.comment: 'comment',
  NotificationType.assignment: 'assignment',
  NotificationType.reportUpdated: 'report_updated',
  NotificationType.kycUpdate: 'kyc_update',
  NotificationType.system: 'system',
};

_PaginatedNotifications _$PaginatedNotificationsFromJson(
  Map<String, dynamic> json,
) => _PaginatedNotifications(
  results: (json['notifications'] as List<dynamic>)
      .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
      .toList(),
  count: (json['count'] as num?)?.toInt() ?? 0,
  unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
  next: json['next'] as String?,
  previous: json['previous'] as String?,
);

Map<String, dynamic> _$PaginatedNotificationsToJson(
  _PaginatedNotifications instance,
) => <String, dynamic>{
  'notifications': instance.results,
  'count': instance.count,
  'unread_count': instance.unreadCount,
  'next': instance.next,
  'previous': instance.previous,
};

_NotificationPreferences _$NotificationPreferencesFromJson(
  Map<String, dynamic> json,
) => _NotificationPreferences(
  emailEnabled: json['email_enabled'] as bool? ?? true,
  pushEnabled: json['push_enabled'] as bool? ?? true,
  notifyOnStatusChange: json['notify_on_status_change'] as bool? ?? true,
  notifyOnComment: json['notify_on_comment'] as bool? ?? true,
  notifyOnAssignment: json['notify_on_assignment'] as bool? ?? true,
);

Map<String, dynamic> _$NotificationPreferencesToJson(
  _NotificationPreferences instance,
) => <String, dynamic>{
  'email_enabled': instance.emailEnabled,
  'push_enabled': instance.pushEnabled,
  'notify_on_status_change': instance.notifyOnStatusChange,
  'notify_on_comment': instance.notifyOnComment,
  'notify_on_assignment': instance.notifyOnAssignment,
};

_UpdatePreferencesRequest _$UpdatePreferencesRequestFromJson(
  Map<String, dynamic> json,
) => _UpdatePreferencesRequest(
  emailEnabled: json['email_enabled'] as bool?,
  pushEnabled: json['push_enabled'] as bool?,
  notifyOnStatusChange: json['notify_on_status_change'] as bool?,
  notifyOnComment: json['notify_on_comment'] as bool?,
  notifyOnAssignment: json['notify_on_assignment'] as bool?,
);

Map<String, dynamic> _$UpdatePreferencesRequestToJson(
  _UpdatePreferencesRequest instance,
) => <String, dynamic>{
  'email_enabled': instance.emailEnabled,
  'push_enabled': instance.pushEnabled,
  'notify_on_status_change': instance.notifyOnStatusChange,
  'notify_on_comment': instance.notifyOnComment,
  'notify_on_assignment': instance.notifyOnAssignment,
};
