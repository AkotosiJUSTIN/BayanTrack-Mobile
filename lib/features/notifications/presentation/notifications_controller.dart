import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/widget/widget_bridge.dart';
import '../domain/entities/notification_preferences.dart';
import '../domain/entities/paginated_notifications.dart';
import '../notifications_di.dart';

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
    final getNotifications = ref.read(getNotificationsUseCaseProvider);
    final result = await getNotifications(
      page: page,
      pageSize: 20,
      unreadOnly: unreadOnly,
    );

    return result.when(
      success: (data) {
        unawaited(
          ref.read(widgetBridgeProvider).syncUnreadCount(data.unreadCount),
        );
        return data;
      },
      failure: (failure) => throw Exception(failure.message),
    );
  }

  /// Mark a single notification as read and refresh
  Future<void> markAsRead(String id) async {
    final markAsReadUseCase = ref.read(markAsReadUseCaseProvider);
    final result = await markAsReadUseCase(id);

    result.when(
      success: (_) => ref.invalidateSelf(),
      failure: (failure) => throw Exception(failure.message),
    );
  }

  /// Mark all notifications as read and refresh
  Future<void> markAllAsRead() async {
    final markAllReadUseCase = ref.read(markAllReadUseCaseProvider);
    final result = await markAllReadUseCase();

    result.when(
      success: (_) => ref.invalidateSelf(),
      failure: (failure) => throw Exception(failure.message),
    );
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
    final getPreferences = ref.read(getPreferencesUseCaseProvider);
    final result = await getPreferences();

    return result.when(
      success: (data) => data,
      failure: (failure) => throw Exception(failure.message),
    );
  }

  /// Update preferences
  Future<void> updatePreferences({
    bool? emailEnabled,
    bool? pushEnabled,
    bool? notifyOnStatusChange,
    bool? notifyOnComment,
    bool? notifyOnAssignment,
  }) async {
    final updatePreferencesUseCase = ref.read(updatePreferencesUseCaseProvider);
    final result = await updatePreferencesUseCase(
      emailEnabled: emailEnabled,
      pushEnabled: pushEnabled,
      notifyOnStatusChange: notifyOnStatusChange,
      notifyOnComment: notifyOnComment,
      notifyOnAssignment: notifyOnAssignment,
    );

    result.when(
      success: (preferences) => state = AsyncData(preferences),
      failure: (failure) => throw Exception(failure.message),
    );
  }
}
