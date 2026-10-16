import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/providers/session_content_cache.dart';
import '../../../core/widget/widget_bridge.dart';
import '../domain/entities/notification.dart';
import '../domain/entities/notification_preferences.dart';
import '../domain/entities/paginated_notifications.dart';
import '../notifications_di.dart';
part 'notifications_controller.g.dart';

@riverpod
class NotificationsController extends _$NotificationsController {
  Future<void>? _refreshing;
  bool _loadingMore = false;
  int _revision = 0;
  int _page = 1;

  @override
  Future<PaginatedNotifications> build() async {
    _revision++;
    _refreshing = null;
    _loadingMore = false;
    _page = 1;
    final cache = ref.watch(sessionContentCacheProvider);
    final cached = cache.read<PaginatedNotifications>('notifications:me');
    if (cached != null) {
      _page = cache.read<int>('notificationPage:me') ?? 1;
      Future.microtask(refresh);
      return cached;
    }
    final data = await _fetchNotifications();
    if (ref.mounted && !cache.isClosed) _publish(data, cache);
    return data;
  }

  Future<PaginatedNotifications> _fetchNotifications({int page = 1}) async {
    final result = await ref.read(getNotificationsUseCaseProvider)(
      page: page,
      pageSize: 20,
    );
    return result.when(
      success: (data) => data,
      failure: (failure) => throw Exception(failure.message),
    );
  }

  void _publish(PaginatedNotifications data, SessionContentCache cache) {
    cache.write('notifications:me', data);
    cache.write('notificationPage:me', _page);
    unawaited(ref.read(widgetBridgeProvider).syncUnreadCount(data.unreadCount));
  }

  Future<void> markAsRead(String id) => _markRead(id);
  Future<void> markAllAsRead() => _markRead(null);
  Future<void> _markRead(String? id) async {
    final cache = ref.read(sessionContentCacheProvider);
    final result = id == null
        ? await ref.read(markAllReadUseCaseProvider)()
        : await ref.read(markAsReadUseCaseProvider)(id);
    if (!ref.mounted || cache.isClosed) return;
    result.when(
      success: (_) {
        _revision++;
        final current = state.value;
        if (current != null) {
          final read = current.results
              .where((n) => !n.isRead && (id == null || n.id == id))
              .length;
          final data = PaginatedNotifications(
            results: current.results
                .map(
                  (n) => id == null || n.id == id
                      ? NotificationEntity(
                          id: n.id,
                          title: n.title,
                          message: n.message,
                          type: n.type,
                          isRead: true,
                          reportId: n.reportId,
                          createdAt: n.createdAt,
                        )
                      : n,
                )
                .toList(),
            count: current.count,
            unreadCount: id == null
                ? 0
                : (current.unreadCount - read).clamp(0, current.count),
            next: current.next,
            previous: current.previous,
          );
          _publish(data, cache);
          state = AsyncData(data);
        }
        _refreshing = null;
        unawaited(refresh());
      },
      failure: (failure) => throw Exception(failure.message),
    );
  }

  Future<void> refresh() {
    if (_refreshing != null) return _refreshing!;
    late final Future<void> task;
    task = _refresh().whenComplete(() {
      if (identical(_refreshing, task)) _refreshing = null;
    });
    _refreshing = task;
    return task;
  }

  Future<void> _refresh() async {
    final revision = ++_revision;
    final cache = ref.read(sessionContentCacheProvider);
    final freshness = ref.read(contentFreshnessProvider.notifier);
    freshness.set('notifications:me', ContentFreshness.refreshing);
    try {
      final first = await _fetchNotifications();
      if (!ref.mounted || cache.isClosed || revision != _revision) return;
      final old = state.value;
      final byId = {for (final n in first.results) n.id: n};
      if (_page > 1 && old != null) {
        for (final n in old.results) {
          byId.putIfAbsent(n.id, () => n);
        }
      }
      final data = PaginatedNotifications(
        results: byId.values.take(first.count).toList(),
        count: first.count,
        unreadCount: first.unreadCount,
        next: _page > 1 ? old?.next : first.next,
        previous: first.previous,
      );
      _publish(data, cache);
      freshness.set('notifications:me', ContentFreshness.current);
      state = AsyncData(data);
    } catch (error, stack) {
      if (!ref.mounted || cache.isClosed || revision != _revision) return;
      freshness.set('notifications:me', ContentFreshness.stale);
      if (!state.hasValue) {
        state = AsyncError<PaginatedNotifications>(error, stack);
      }
    }
  }

  Future<void> loadMore() async {
    if (_loadingMore || _refreshing != null || state.value?.hasNext != true) {
      return;
    }
    _loadingMore = true;
    final revision = _revision;
    final cache = ref.read(sessionContentCacheProvider);
    try {
      final next = await _fetchNotifications(page: _page + 1);
      if (!ref.mounted || cache.isClosed || revision != _revision) return;
      final current = state.value!;
      final byId = {for (final n in current.results) n.id: n};
      for (final n in next.results) {
        byId[n.id] = n;
      }
      final data = PaginatedNotifications(
        results: byId.values.toList(),
        count: next.count,
        unreadCount: next.unreadCount,
        next: next.next,
        previous: next.previous,
      );
      _page++;
      _publish(data, cache);
      state = AsyncData(data);
    } catch (error, stack) {
      if (ref.mounted && !cache.isClosed && revision == _revision) {
        if (!state.hasValue) {
          state = AsyncError<PaginatedNotifications>(error, stack);
        }
      }
    } finally {
      if (ref.mounted && !cache.isClosed && revision == _revision) {
        _loadingMore = false;
      }
    }
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
