import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_provider.dart';
import 'notification_models.dart';

part 'notifications_repository.g.dart';

@riverpod
NotificationsRepository notificationsRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  return NotificationsRepository(dio);
}

class NotificationsRepository {
  final Dio _dio;

  NotificationsRepository(this._dio);

  // ==================== LIST NOTIFICATIONS ====================

  /// Get paginated list of notifications
  Future<PaginatedNotifications> getNotifications({
    int page = 1,
    int pageSize = 20,
    bool? unreadOnly,
  }) async {
    final queryParams = <String, dynamic>{'page': page, 'page_size': pageSize};
    if (unreadOnly == true) {
      queryParams['unread_only'] = 'true';
    }

    final response = await _dio.get(
      ApiConstants.notifications,
      queryParameters: queryParams,
    );
    return PaginatedNotifications.fromJson(response.data);
  }

  // ==================== GET SINGLE ====================

  /// Get a single notification by ID
  Future<AppNotification> getNotification(String id) async {
    final response = await _dio.get(ApiConstants.notificationById(id));
    return AppNotification.fromJson(response.data);
  }

  // ==================== MARK AS READ ====================

  /// Mark a single notification as read
  Future<void> markAsRead(String id) async {
    await _dio.patch(ApiConstants.notificationById(id));
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    await _dio.post(ApiConstants.notificationMarkAllRead);
  }

  // ==================== PREFERENCES ====================

  /// Get notification preferences
  Future<NotificationPreferences> getPreferences() async {
    final response = await _dio.get(ApiConstants.notificationPreferences);
    return NotificationPreferences.fromJson(response.data);
  }

  /// Update notification preferences
  Future<NotificationPreferences> updatePreferences(
    UpdatePreferencesRequest request,
  ) async {
    final response = await _dio.put(
      ApiConstants.notificationPreferences,
      data: request.toJson(),
    );
    return NotificationPreferences.fromJson(response.data);
  }
}
