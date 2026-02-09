import '../../../core/domain/result.dart';
import 'entities/notification.dart';
import 'entities/notification_preferences.dart';
import 'entities/paginated_notifications.dart';

/// Repository interface for notifications operations.
///
/// All methods return [Result<T>] for explicit error handling.
abstract class NotificationsRepository {
  /// Get paginated list of notifications.
  Future<Result<PaginatedNotifications>> getNotifications({
    int page = 1,
    int pageSize = 20,
    bool? unreadOnly,
  });

  /// Get a single notification by ID.
  Future<Result<NotificationEntity>> getNotification(String id);

  /// Mark a single notification as read.
  Future<Result<void>> markAsRead(String id);

  /// Mark all notifications as read.
  Future<Result<void>> markAllAsRead();

  /// Get notification preferences.
  Future<Result<NotificationPreferences>> getPreferences();

  /// Update notification preferences.
  Future<Result<NotificationPreferences>> updatePreferences({
    bool? emailEnabled,
    bool? pushEnabled,
    bool? notifyOnStatusChange,
    bool? notifyOnComment,
    bool? notifyOnAssignment,
  });
}
