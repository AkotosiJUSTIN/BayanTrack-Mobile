import '../../../core/domain/result.dart';
import '../../../core/network/error_mapper.dart';
import '../domain/entities/notification.dart';
import '../domain/entities/notification_preferences.dart' as domain_prefs;
import '../domain/entities/paginated_notifications.dart' as domain_paginated;
import '../domain/notifications_repository.dart' as domain;
import 'notification_models.dart' as dto;
import 'notifications_repository.dart' as legacy;
import 'mappers/notification_mapper.dart';

/// Implementation of [domain.NotificationsRepository] using the legacy data repository.
///
/// This wraps all operations with [Result] for explicit error handling.
class NotificationsRepositoryImpl implements domain.NotificationsRepository {
  final legacy.NotificationsRepository _legacyRepo;

  NotificationsRepositoryImpl(this._legacyRepo);

  @override
  Future<Result<domain_paginated.PaginatedNotifications>> getNotifications({
    int page = 1,
    int pageSize = 20,
    bool? unreadOnly,
  }) async {
    try {
      final dtoResult = await _legacyRepo.getNotifications(
        page: page,
        pageSize: pageSize,
        unreadOnly: unreadOnly,
      );
      return Success(NotificationMapper.toPaginatedNotifications(dtoResult));
    } catch (e, stack) {
      return Err(ErrorMapper.mapException(e, stack));
    }
  }

  @override
  Future<Result<NotificationEntity>> getNotification(String id) async {
    try {
      final dtoResult = await _legacyRepo.getNotification(id);
      return Success(NotificationMapper.toNotificationEntity(dtoResult));
    } catch (e, stack) {
      return Err(ErrorMapper.mapException(e, stack));
    }
  }

  @override
  Future<Result<void>> markAsRead(String id) async {
    try {
      await _legacyRepo.markAsRead(id);
      return const Success(null);
    } catch (e, stack) {
      return Err(ErrorMapper.mapException(e, stack));
    }
  }

  @override
  Future<Result<void>> markAllAsRead() async {
    try {
      await _legacyRepo.markAllAsRead();
      return const Success(null);
    } catch (e, stack) {
      return Err(ErrorMapper.mapException(e, stack));
    }
  }

  @override
  Future<Result<domain_prefs.NotificationPreferences>> getPreferences() async {
    try {
      final dtoResult = await _legacyRepo.getPreferences();
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
      final request = dto.UpdatePreferencesRequest(
        emailEnabled: emailEnabled,
        pushEnabled: pushEnabled,
        notifyOnStatusChange: notifyOnStatusChange,
        notifyOnComment: notifyOnComment,
        notifyOnAssignment: notifyOnAssignment,
      );
      final dtoResult = await _legacyRepo.updatePreferences(request);
      return Success(NotificationMapper.toNotificationPreferences(dtoResult));
    } catch (e, stack) {
      return Err(ErrorMapper.mapException(e, stack));
    }
  }
}
