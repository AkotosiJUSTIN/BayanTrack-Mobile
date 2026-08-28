import 'package:bayantrack_mobile/core/constants/api_constants.dart';
import 'package:bayantrack_mobile/features/notifications/data/notifications_repository_impl.dart';
import 'package:bayantrack_mobile/features/notifications/domain/entities/notification_type.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late NotificationsRepositoryImpl repository;

  setUp(() {
    dio = MockDio();
    repository = NotificationsRepositoryImpl(dio);
  });

  test('maps total pagination and tolerates new notification types', () async {
    when(
      () => dio.get(
        ApiConstants.notifications,
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: ApiConstants.notifications),
        data: {
          'notifications': [
            {
              'id': 'notification-1',
              'title': 'Review ready',
              'message': 'Duplicate suggestion needs review',
              'type': 'duplicate_suggestion',
              'related_report_id': 'report-1',
              'created_at': '2026-07-16T00:00:00Z',
            },
          ],
          'count': 1,
          'total': 21,
          'unread_count': 3,
          'next': '/api/notifications/?page=2',
          'previous': null,
        },
      ),
    );

    final result = await repository.getNotifications(unreadOnly: true);
    final page = result.dataOrNull!;

    expect(page.count, 21);
    expect(page.unreadCount, 3);
    expect(page.hasNext, isTrue);
    expect(page.results.single.type, NotificationType.system);
    expect(page.results.single.reportId, 'report-1');
  });

  test('uses canonical mark-all-read route', () async {
    when(() => dio.post(ApiConstants.notificationMarkAllRead)).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(
          path: ApiConstants.notificationMarkAllRead,
        ),
      ),
    );

    final result = await repository.markAllAsRead();

    expect(result.isSuccess, isTrue);
    verify(() => dio.post('/notifications/actions/mark-all-read/')).called(1);
  });

  test('unwraps preference update response and omits null fields', () async {
    when(
      () => dio.put(
        ApiConstants.notificationPreferences,
        data: any(named: 'data'),
      ),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(
          path: ApiConstants.notificationPreferences,
        ),
        data: {
          'message': 'Preferences updated successfully',
          'preferences': {
            'email_enabled': true,
            'push_enabled': false,
            'notify_on_status_change': true,
            'notify_on_comment': true,
            'notify_on_assignment': true,
          },
        },
      ),
    );

    final result = await repository.updatePreferences(pushEnabled: false);
    final captured =
        verify(
              () => dio.put(
                ApiConstants.notificationPreferences,
                data: captureAny(named: 'data'),
              ),
            ).captured.single
            as Map<String, dynamic>;

    expect(captured, {'push_enabled': false});
    expect(result.dataOrNull!.pushEnabled, isFalse);
  });
}
