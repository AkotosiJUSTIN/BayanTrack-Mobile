import 'dart:async';
import 'package:bayantrack_mobile/core/domain/result.dart';
import 'package:bayantrack_mobile/core/domain/failures.dart';
import 'package:bayantrack_mobile/core/providers/session_content_cache.dart';
import 'package:bayantrack_mobile/core/widget/widget_bridge.dart';
import 'package:bayantrack_mobile/features/notifications/domain/notifications_repository.dart';
import 'package:bayantrack_mobile/features/notifications/domain/entities/notification.dart';
import 'package:bayantrack_mobile/features/notifications/domain/entities/paginated_notifications.dart';
import 'package:bayantrack_mobile/features/notifications/notifications_di.dart';
import 'package:bayantrack_mobile/features/notifications/presentation/notifications_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class Repo extends Mock implements NotificationsRepository {}

class Bridge extends Mock implements WidgetBridge {}

NotificationEntity item(int id, {bool read = false}) => NotificationEntity(
  id: '$id',
  title: 'N$id',
  message: 'Update',
  isRead: read,
);
PaginatedNotifications page(
  int start,
  int end, {
  int unread = 3,
  String? next,
}) => PaginatedNotifications(
  results: List.generate(end - start, (i) => item(start + i)),
  count: 40,
  unreadCount: unread,
  next: next,
);
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('cached list survives failed background refresh', () async {
    final repo = Repo();
    final bridge = Bridge();
    final cache = SessionContentCache();
    cache.write('notifications:me', page(0, 20, next: 'next'));
    when(
      () => repo.getNotifications(page: 1, pageSize: 20, unreadOnly: null),
    ).thenAnswer((_) async => const Err(ServerFailure('offline')));
    final c = ProviderContainer(
      overrides: [
        sessionContentCacheProvider.overrideWithValue(cache),
        notificationsDomainRepositoryProvider.overrideWithValue(repo),
        widgetBridgeProvider.overrideWithValue(bridge),
      ],
    );
    addTearDown(c.dispose);
    final sub = c.listen(notificationsControllerProvider, (_, _) {});
    addTearDown(sub.close);
    expect(
      (await c.read(notificationsControllerProvider.future)).results.length,
      20,
    );
    await c.pump();
    await Future<void>.delayed(Duration.zero);
    expect(c.read(notificationsControllerProvider).value?.results.length, 20);
    expect(
      c.read(contentFreshnessProvider)['notifications:me'],
      ContentFreshness.stale,
    );
  });
  test(
    'pagination deduplicates and first-page refresh retains loaded pages and fresh unread count',
    () async {
      final repo = Repo();
      final bridge = Bridge();
      var unread = 3;
      when(() => bridge.syncUnreadCount(any())).thenAnswer((_) async {});
      when(
        () => repo.getNotifications(page: 1, pageSize: 20, unreadOnly: null),
      ).thenAnswer(
        (_) async => Success(page(0, 20, unread: unread, next: 'next')),
      );
      when(
        () => repo.getNotifications(page: 2, pageSize: 20, unreadOnly: null),
      ).thenAnswer((_) async => Success(page(19, 40)));
      final c = ProviderContainer(
        overrides: [
          sessionContentCacheProvider.overrideWithValue(SessionContentCache()),
          notificationsDomainRepositoryProvider.overrideWithValue(repo),
          widgetBridgeProvider.overrideWithValue(bridge),
        ],
      );
      addTearDown(c.dispose);
      final sub = c.listen(notificationsControllerProvider, (_, _) {});
      addTearDown(sub.close);
      await c.read(notificationsControllerProvider.future);
      final notifier = c.read(notificationsControllerProvider.notifier);
      await Future.wait([notifier.loadMore(), notifier.loadMore()]);
      expect(c.read(notificationsControllerProvider).value?.results.length, 40);
      verify(
        () => repo.getNotifications(page: 2, pageSize: 20, unreadOnly: null),
      ).called(1);
      unread = 1;
      await notifier.refresh();
      expect(c.read(notificationsControllerProvider).value?.results.length, 40);
      expect(c.read(notificationsControllerProvider).value?.unreadCount, 1);
      verify(() => bridge.syncUnreadCount(1)).called(1);
    },
  );
  test(
    'successful read updates local list and widget even when follow-up refresh fails',
    () async {
      final repo = Repo();
      final bridge = Bridge();
      var calls = 0;
      when(() => bridge.syncUnreadCount(any())).thenAnswer((_) async {});
      when(
        () => repo.getNotifications(page: 1, pageSize: 20, unreadOnly: null),
      ).thenAnswer(
        (_) async => ++calls == 1
            ? Success(page(0, 20))
            : const Err(ServerFailure('offline')),
      );
      when(
        () => repo.markAsRead('0'),
      ).thenAnswer((_) async => const Success(null));
      final c = ProviderContainer(
        overrides: [
          sessionContentCacheProvider.overrideWithValue(SessionContentCache()),
          notificationsDomainRepositoryProvider.overrideWithValue(repo),
          widgetBridgeProvider.overrideWithValue(bridge),
        ],
      );
      addTearDown(c.dispose);
      final sub = c.listen(notificationsControllerProvider, (_, _) {});
      addTearDown(sub.close);
      await c.read(notificationsControllerProvider.future);
      await c.read(notificationsControllerProvider.notifier).markAsRead('0');
      await c.pump();
      expect(
        c.read(notificationsControllerProvider).value?.results.first.isRead,
        isTrue,
      );
      expect(c.read(notificationsControllerProvider).value?.unreadCount, 2);
      verify(() => bridge.syncUnreadCount(2)).called(1);
    },
  );
  test(
    'late old-account refresh cannot publish unread count or content',
    () async {
      final repo = Repo();
      final bridge = Bridge();
      final late = Completer<Result<PaginatedNotifications>>();
      var calls = 0;
      when(() => bridge.syncUnreadCount(any())).thenAnswer((_) async {});
      when(
        () => repo.getNotifications(page: 1, pageSize: 20, unreadOnly: null),
      ).thenAnswer((_) async {
        calls++;
        if (calls == 2) return late.future;
        return Success(page(0, 20, unread: calls >= 3 ? 1 : 3));
      });
      final c = ProviderContainer(
        overrides: [
          notificationsDomainRepositoryProvider.overrideWithValue(repo),
          widgetBridgeProvider.overrideWithValue(bridge),
          sessionContentCacheProvider.overrideWith((ref) {
            final cache = SessionContentCache();
            ref.onDispose(cache.close);
            return cache;
          }),
        ],
      );
      addTearDown(c.dispose);
      final sub = c.listen(notificationsControllerProvider, (_, _) {});
      addTearDown(sub.close);
      await c.read(notificationsControllerProvider.future);
      final pending = c
          .read(notificationsControllerProvider.notifier)
          .refresh();
      c.invalidate(sessionContentCacheProvider);
      await c.pump();
      await c.read(notificationsControllerProvider.future);
      late.complete(Success(page(20, 40, unread: 9)));
      await pending;
      expect(c.read(notificationsControllerProvider).value?.unreadCount, 1);
      verifyNever(() => bridge.syncUnreadCount(9));
    },
  );
  test(
    'reopened pagination resumes saved page cursor even when pages deduplicate',
    () async {
      final repo = Repo();
      final bridge = Bridge();
      final cache = SessionContentCache();
      when(() => bridge.syncUnreadCount(any())).thenAnswer((_) async {});
      cache.write('notifications:me', page(0, 19, next: 'page3'));
      cache.write('notificationPage:me', 2);
      when(
        () => repo.getNotifications(page: 1, pageSize: 20, unreadOnly: null),
      ).thenAnswer((_) async => Success(page(0, 19, next: 'page2')));
      when(
        () => repo.getNotifications(page: 3, pageSize: 20, unreadOnly: null),
      ).thenAnswer((_) async => Success(page(19, 40)));
      final c = ProviderContainer(
        overrides: [
          notificationsDomainRepositoryProvider.overrideWithValue(repo),
          widgetBridgeProvider.overrideWithValue(bridge),
          sessionContentCacheProvider.overrideWithValue(cache),
        ],
      );
      addTearDown(c.dispose);
      final sub = c.listen(notificationsControllerProvider, (_, _) {});
      addTearDown(sub.close);
      await c.read(notificationsControllerProvider.future);
      await c.pump();
      await Future<void>.delayed(Duration.zero);
      await c.read(notificationsControllerProvider.notifier).loadMore();
      verify(
        () => repo.getNotifications(page: 3, pageSize: 20, unreadOnly: null),
      ).called(1);
      verifyNever(
        () => repo.getNotifications(page: 2, pageSize: 20, unreadOnly: null),
      );
    },
  );
}
