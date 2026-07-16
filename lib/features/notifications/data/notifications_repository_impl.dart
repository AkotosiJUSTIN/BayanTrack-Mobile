import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/domain/result.dart';
import '../../../core/network/error_mapper.dart';
import '../domain/entities/notification.dart';
import '../domain/entities/notification_preferences.dart' as domain_prefs;
import '../domain/entities/paginated_notifications.dart' as domain_paginated;
import '../domain/notifications_repository.dart' as domain;
import 'notification_models.dart' as dto;
import 'mappers/notification_mapper.dart';

/// Canonical notification repository: transport, DTO mapping, and error mapping.
class NotificationsRepositoryImpl implements domain.NotificationsRepository {
  final Dio _dio;

  NotificationsRepositoryImpl(this._dio);

  @override
  Future<Result<domain_paginated.PaginatedNotifications>> getNotifications({
    int page = 1,
    int pageSize = 20,
    bool? unreadOnly,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
        if (unreadOnly == true) 'unread_only': 'true',
      };
      final response = await _dio.get(
        ApiConstants.notifications,
        queryParameters: queryParameters,
      );
      final dtoResult = dto.PaginatedNotifications.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
      return Success(NotificationMapper.toPaginatedNotifications(dtoResult));
    } catch (e, stack) {
      return Err(ErrorMapper.mapException(e, stack));
    }
  }

  @override
  Future<Result<NotificationEntity>> getNotification(String id) async {
    try {
      final response = await _dio.get(ApiConstants.notificationById(id));
      final dtoResult = dto.AppNotification.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
      return Success(NotificationMapper.toNotificationEntity(dtoResult));
    } catch (e, stack) {
      return Err(ErrorMapper.mapException(e, stack));
    }
  }

  @override
  Future<Result<void>> markAsRead(String id) async {
    try {
      await _dio.patch(ApiConstants.notificationById(id));
      return const Success(null);
    } catch (e, stack) {
      return Err(ErrorMapper.mapException(e, stack));
    }
  }

  @override
  Future<Result<void>> markAllAsRead() async {
    try {
      await _dio.post(ApiConstants.notificationMarkAllRead);
      return const Success(null);
    } catch (e, stack) {
      return Err(ErrorMapper.mapException(e, stack));
    }
  }

  @override
  Future<Result<domain_prefs.NotificationPreferences>> getPreferences() async {
    try {
      final response = await _dio.get(ApiConstants.notificationPreferences);
      final dtoResult = dto.NotificationPreferences.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
      return Success(NotificationMapper.toNotificationPreferences(dtoResult));
    } catch (e, stack) {
      return Err(ErrorMapper.mapException(e, stack));
    }
  }

  @override
  Future<Result<domain_prefs.NotificationPreferences>> updatePreferences({
    bool? emailEnabled,
    bool? pushEnabled,
    bool? notifyOnStatusChange,
    bool? notifyOnComment,
    bool? notifyOnAssignment,
  }) async {
    try {
      final response = await _dio.put(
        ApiConstants.notificationPreferences,
        data: <String, dynamic>{
          'email_enabled': ?emailEnabled,
          'push_enabled': ?pushEnabled,
          'notify_on_status_change': ?notifyOnStatusChange,
          'notify_on_comment': ?notifyOnComment,
          'notify_on_assignment': ?notifyOnAssignment,
        },
      );
      final body = Map<String, dynamic>.from(response.data as Map);
      final preferences = body['preferences'];
      final dtoResult = dto.NotificationPreferences.fromJson(
        preferences is Map ? Map<String, dynamic>.from(preferences) : body,
      );
      return Success(NotificationMapper.toNotificationPreferences(dtoResult));
    } catch (e, stack) {
      return Err(ErrorMapper.mapException(e, stack));
    }
  }
}
