import '../../domain/entities/notification.dart';
import '../../../../core/utils/api_datetime.dart';
import '../../domain/entities/notification_preferences.dart'
    as domain_preferences;
import '../../domain/entities/notification_type.dart';
import '../../domain/entities/paginated_notifications.dart' as domain_paginated;
import '../notification_models.dart' as dto;

/// Mapper for converting Notification DTOs to domain entities.
class NotificationMapper {
  NotificationMapper._(); // Prevent instantiation

  // ==================== NOTIFICATION MAPPING ====================

  /// Convert [dto.AppNotification] DTO to [NotificationEntity].
  static NotificationEntity toNotificationEntity(dto.AppNotification dtoObj) {
    return NotificationEntity(
      id: dtoObj.id,
      title: dtoObj.title,
      message: dtoObj.message,
      type: _mapNotificationType(dtoObj.type),
      isRead: dtoObj.isRead,
      reportId: dtoObj.reportId,
      createdAt: parseApiDateTime(dtoObj.createdAt),
    );
  }

  static NotificationType _mapNotificationType(dto.NotificationType type) {
    const mapping = {
      dto.NotificationType.reportSubmitted: NotificationType.reportSubmitted,
      dto.NotificationType.statusChange: NotificationType.statusChange,
      dto.NotificationType.comment: NotificationType.comment,
      dto.NotificationType.assignment: NotificationType.assignment,
      dto.NotificationType.reportUpdated: NotificationType.reportUpdated,
      dto.NotificationType.kycUpdate: NotificationType.kycUpdate,
      dto.NotificationType.termsUpdated: NotificationType.termsUpdated,
      dto.NotificationType.system: NotificationType.system,
    };

    return mapping[type] ?? NotificationType.system;
  }

  // ==================== PAGINATED NOTIFICATIONS MAPPING ====================

  /// Convert [dto.PaginatedNotifications] DTO to [domain_paginated.PaginatedNotifications].
  static domain_paginated.PaginatedNotifications toPaginatedNotifications(
    dto.PaginatedNotifications dtoObj,
  ) {
    return domain_paginated.PaginatedNotifications(
      results: dtoObj.results.map(toNotificationEntity).toList(),
      count: dtoObj.total ?? dtoObj.count,
      unreadCount: dtoObj.unreadCount,
      next: dtoObj.next,
      previous: dtoObj.previous,
    );
  }

  // ==================== PREFERENCES MAPPING ====================

  /// Convert [dto.NotificationPreferences] DTO to [domain_preferences.NotificationPreferences].
  static domain_preferences.NotificationPreferences toNotificationPreferences(
    dto.NotificationPreferences dtoObj,
  ) {
    return domain_preferences.NotificationPreferences(
      emailEnabled: dtoObj.emailEnabled,
      pushEnabled: dtoObj.pushEnabled,
      notifyOnStatusChange: dtoObj.notifyOnStatusChange,
      notifyOnComment: dtoObj.notifyOnComment,
      notifyOnAssignment: dtoObj.notifyOnAssignment,
    );
  }
}
