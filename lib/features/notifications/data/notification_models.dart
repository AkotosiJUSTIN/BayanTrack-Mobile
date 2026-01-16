import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_models.freezed.dart';
part 'notification_models.g.dart';

// ==================== NOTIFICATION TYPE ====================

enum NotificationType {
  @JsonValue('status_change')
  statusChange,
  @JsonValue('comment')
  comment,
  @JsonValue('assignment')
  assignment,
  @JsonValue('system')
  system,
}

// ==================== NOTIFICATION ====================

@freezed
sealed class AppNotification with _$AppNotification {
  const factory AppNotification({
    @JsonKey(name: '_id') required String id,
    required String title,
    required String message,
    @Default(NotificationType.system) NotificationType type,
    @JsonKey(name: 'is_read') @Default(false) bool isRead,
    @JsonKey(name: 'report_id') String? reportId,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
}

// ==================== PAGINATED NOTIFICATIONS ====================

@freezed
sealed class PaginatedNotifications with _$PaginatedNotifications {
  const factory PaginatedNotifications({
    required List<AppNotification> results,
    @Default(0) int count,
    @JsonKey(name: 'unread_count') @Default(0) int unreadCount,
    String? next,
    String? previous,
  }) = _PaginatedNotifications;

  factory PaginatedNotifications.fromJson(Map<String, dynamic> json) =>
      _$PaginatedNotificationsFromJson(json);
}

// ==================== NOTIFICATION PREFERENCES ====================

@freezed
sealed class NotificationPreferences with _$NotificationPreferences {
  const factory NotificationPreferences({
    @JsonKey(name: 'email_enabled') @Default(true) bool emailEnabled,
    @JsonKey(name: 'push_enabled') @Default(true) bool pushEnabled,
    @JsonKey(name: 'notify_on_status_change')
    @Default(true)
    bool notifyOnStatusChange,
    @JsonKey(name: 'notify_on_comment') @Default(true) bool notifyOnComment,
    @JsonKey(name: 'notify_on_assignment')
    @Default(true)
    bool notifyOnAssignment,
  }) = _NotificationPreferences;

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesFromJson(json);
}

// ==================== UPDATE PREFERENCES REQUEST ====================

@freezed
sealed class UpdatePreferencesRequest with _$UpdatePreferencesRequest {
  const factory UpdatePreferencesRequest({
    @JsonKey(name: 'email_enabled') bool? emailEnabled,
    @JsonKey(name: 'push_enabled') bool? pushEnabled,
    @JsonKey(name: 'notify_on_status_change') bool? notifyOnStatusChange,
    @JsonKey(name: 'notify_on_comment') bool? notifyOnComment,
    @JsonKey(name: 'notify_on_assignment') bool? notifyOnAssignment,
  }) = _UpdatePreferencesRequest;

  factory UpdatePreferencesRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdatePreferencesRequestFromJson(json);
}
