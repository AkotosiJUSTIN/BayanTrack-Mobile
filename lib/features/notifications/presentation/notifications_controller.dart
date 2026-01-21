import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/notification_models.dart';
import '../data/notifications_repository.dart';

part 'notifications_controller.g.dart';

/// Controller for notifications list - auto-fetches on first access
@riverpod
class NotificationsController extends _$NotificationsController {
  @override
  Future<PaginatedNotifications> build() async {
    return _fetchNotifications();
  }

  Future<PaginatedNotifications> _fetchNotifications({
    int page = 1,
    bool? unreadOnly,
  }) async {
    final repository = ref.read(notificationsRepositoryProvider);
    return repository.getNotifications(
      page: page,
      pageSize: 20,
      unreadOnly: unreadOnly,
    );
  }

  /// Mark a single notification as read and refresh
  Future<void> markAsRead(String id) async {
    final repository = ref.read(notificationsRepositoryProvider);
    await repository.markAsRead(id);
    ref.invalidateSelf();
  }

  /// Mark all notifications as read and refresh
  Future<void> markAllAsRead() async {
    final repository = ref.read(notificationsRepositoryProvider);
    await repository.markAllAsRead();
    ref.invalidateSelf();
  }

  /// Refresh notifications
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

/// Controller for notification preferences
@riverpod
class NotificationPreferencesController
    extends _$NotificationPreferencesController {
  @override
  Future<NotificationPreferences> build() async {
    final repository = ref.read(notificationsRepositoryProvider);
    return repository.getPreferences();
  }

  /// Update preferences
  Future<void> updatePreferences(UpdatePreferencesRequest request) async {
    final repository = ref.read(notificationsRepositoryProvider);
    await repository.updatePreferences(request);
    ref.invalidateSelf();
  }
}
