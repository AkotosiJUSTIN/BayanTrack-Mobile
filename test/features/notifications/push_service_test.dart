import 'dart:async';

import 'package:bayantrack_mobile/core/constants/api_constants.dart';
import 'package:bayantrack_mobile/features/notifications/push_service.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _DioMock extends Mock implements Dio {}

class _MessagingMock extends Mock implements FirebaseMessaging {}

class _PushService extends PushService {
  _PushService(FirebaseMessaging messaging) : super(messaging: messaging);

  @override
  Future<void> requestPermission() async {}
}

void _stubRegistration(_DioMock dio, String token) {
  when(
    () => dio.post(
      ApiConstants.notificationPushToken,
      data: {'token': token, 'device_type': 'android'},
    ),
  ).thenAnswer(
    (_) async => Response<dynamic>(
      statusCode: 201,
      requestOptions: RequestOptions(path: ApiConstants.notificationPushToken),
    ),
  );
}

void main() {
  test('re-registers the same token to recover server-side deletion', () async {
    SharedPreferences.setMockInitialValues({});
    final dio = _DioMock();
    when(
      () => dio.post(
        ApiConstants.notificationPushToken,
        data: {'token': 'token-1', 'device_type': 'android'},
      ),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        data: const {},
        statusCode: 201,
        requestOptions: RequestOptions(
          path: ApiConstants.notificationPushToken,
        ),
      ),
    );

    final service = PushService();
    await service.registerToken('token-1', 'android', dio, userId: 'user-1');
    await service.registerToken('token-1', 'android', dio, userId: 'user-1');

    verify(
      () => dio.post(
        ApiConstants.notificationPushToken,
        data: {'token': 'token-1', 'device_type': 'android'},
      ),
    ).called(2);
  });

  test('registers the same device token after account switch', () async {
    SharedPreferences.setMockInitialValues({});
    final dio = _DioMock();
    when(
      () => dio.post(
        ApiConstants.notificationPushToken,
        data: {'token': 'token-1', 'device_type': 'android'},
      ),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        data: const {},
        statusCode: 201,
        requestOptions: RequestOptions(
          path: ApiConstants.notificationPushToken,
        ),
      ),
    );

    final service = PushService();
    await service.registerToken('token-1', 'android', dio, userId: 'user-1');
    await service.registerToken('token-1', 'android', dio, userId: 'user-2');

    verify(
      () => dio.post(
        ApiConstants.notificationPushToken,
        data: {'token': 'token-1', 'device_type': 'android'},
      ),
    ).called(2);
  });

  test(
    'ignores stale registration cache and obtains the current FCM token',
    () async {
      SharedPreferences.setMockInitialValues({
        'push_token': 'old-token',
        'push_token_registered': true,
        'push_token_registered_user': 'user-1',
        'push_token_registered_device': 'android',
      });
      final messaging = _MessagingMock();
      when(() => messaging.getToken()).thenAnswer((_) async => 'current-token');
      final dio = _DioMock();
      _stubRegistration(dio, 'current-token');
      final service = _PushService(messaging);
      await service.ensureRegistered('android', dio, userId: 'user-1');
      await service.ensureRegistered('android', dio, userId: 'user-1');
      verify(() => messaging.getToken()).called(2);
      verify(
        () => dio.post(
          ApiConstants.notificationPushToken,
          data: {'token': 'current-token', 'device_type': 'android'},
        ),
      ).called(2);
    },
  );

  test('concurrent resume and reconnect share one registration', () async {
    final messaging = _MessagingMock();
    final token = Completer<String?>();
    when(() => messaging.getToken()).thenAnswer((_) => token.future);
    final dio = _DioMock();
    _stubRegistration(dio, 'current-token');
    final service = _PushService(messaging);
    final first = service.ensureRegistered('android', dio, userId: 'user-1');
    final second = service.ensureRegistered('android', dio, userId: 'user-1');
    token.complete('current-token');
    await Future.wait([first, second]);
    verify(() => messaging.getToken()).called(1);
    verify(
      () => dio.post(
        ApiConstants.notificationPushToken,
        data: {'token': 'current-token', 'device_type': 'android'},
      ),
    ).called(1);
  });

  testWidgets('missing FCM token never reuses a stale saved token', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'push_token': 'stale-token',
      'push_token_registered': true,
    });
    final messaging = _MessagingMock();
    when(() => messaging.getToken()).thenAnswer((_) async => null);
    final dio = _DioMock();
    final service = _PushService(messaging);
    addTearDown(service.dispose);
    final registration = service.ensureRegistered(
      'android',
      dio,
      userId: 'user-1',
    );
    final failed = expectLater(registration, throwsStateError);
    await tester.pump();
    for (var attempt = 0; attempt < 5; attempt++) {
      await tester.pump(const Duration(seconds: 5));
    }
    await failed;
    verify(() => messaging.getToken()).called(5);
    verifyZeroInteractions(dio);
    service.dispose();
  });

  testWidgets('registration retries backend failure with backoff', (
    tester,
  ) async {
    final messaging = _MessagingMock();
    when(() => messaging.getToken()).thenAnswer((_) async => 'current-token');
    final dio = _DioMock();
    var attempts = 0;
    when(
      () => dio.post(
        ApiConstants.notificationPushToken,
        data: {'token': 'current-token', 'device_type': 'android'},
      ),
    ).thenAnswer((_) async {
      if (++attempts == 1) throw StateError('Backend unavailable');
      return Response<dynamic>(
        statusCode: 201,
        requestOptions: RequestOptions(
          path: ApiConstants.notificationPushToken,
        ),
      );
    });
    final registration = _PushService(
      messaging,
    ).ensureRegistered('android', dio, userId: 'user-1');
    await tester.pump();
    expect(attempts, 1);
    await tester.pump(const Duration(seconds: 2));
    await registration;
    expect(attempts, 2);
  });

  testWidgets('token lookup failure retries while the app stays open', (
    tester,
  ) async {
    final messaging = _MessagingMock();
    when(() => messaging.getToken()).thenThrow(StateError('FCM unavailable'));
    final dio = _DioMock();
    _stubRegistration(dio, 'current-token');
    final service = _PushService(messaging);
    addTearDown(service.dispose);
    final failed = expectLater(
      service.ensureRegistered('android', dio, userId: 'user-1'),
      throwsStateError,
    );
    await tester.pump();
    for (final seconds in [1, 2, 3, 4]) {
      await tester.pump(Duration(seconds: seconds));
    }
    await failed;
    verify(() => messaging.getToken()).called(5);
    when(() => messaging.getToken()).thenAnswer((_) async => 'current-token');
    await tester.pump(const Duration(seconds: 30));
    verify(
      () => dio.post(
        ApiConstants.notificationPushToken,
        data: {'token': 'current-token', 'device_type': 'android'},
      ),
    ).called(1);
  });

  testWidgets(
    'transient Firebase exception retries the lookup before registration',
    (tester) async {
      final messaging = _MessagingMock();
      var lookups = 0;
      when(() => messaging.getToken()).thenAnswer((_) async {
        if (++lookups == 1) throw StateError('SERVICE_NOT_AVAILABLE');
        return 'current-token';
      });
      final dio = _DioMock();
      _stubRegistration(dio, 'current-token');
      final service = _PushService(messaging);
      addTearDown(service.dispose);
      final registration = service.ensureRegistered(
        'android',
        dio,
        userId: 'user-1',
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await registration;
      expect(lookups, 2);
      verify(
        () => dio.post(
          ApiConstants.notificationPushToken,
          data: {'token': 'current-token', 'device_type': 'android'},
        ),
      ).called(1);
    },
  );

  testWidgets(
    'logout cancels pending lookup and scheduled registration retry',
    (tester) async {
      final messaging = _MessagingMock();
      final token = Completer<String?>();
      when(() => messaging.getToken()).thenAnswer((_) => token.future);
      final dio = _DioMock();
      final service = _PushService(messaging);
      addTearDown(service.dispose);
      final registration = service.ensureRegistered(
        'android',
        dio,
        userId: 'user-1',
      );
      await tester.pump();
      service.cancelRegistration();
      token.complete('late-token');
      await registration;
      verifyZeroInteractions(dio);

      when(() => messaging.getToken()).thenAnswer((_) async => null);
      final failed = expectLater(
        service.ensureRegistered('android', dio, userId: 'user-1'),
        throwsStateError,
      );
      await tester.pump();
      for (final seconds in [1, 2, 3, 4]) {
        await tester.pump(Duration(seconds: seconds));
      }
      await failed;
      service.cancelRegistration();
      await tester.pump(const Duration(seconds: 60));
      verify(() => messaging.getToken()).called(6);
      verifyZeroInteractions(dio);
    },
  );

  test(
    'failed backend registration can be retried without a cached success',
    () async {
      final dio = _DioMock();
      when(
        () => dio.post(
          ApiConstants.notificationPushToken,
          data: {'token': 'current-token', 'device_type': 'android'},
        ),
      ).thenThrow(StateError('Backend unavailable'));
      final service = PushService();
      await expectLater(
        service.registerToken(
          'current-token',
          'android',
          dio,
          userId: 'user-1',
        ),
        throwsStateError,
      );
      _stubRegistration(dio, 'current-token');
      await service.registerToken(
        'current-token',
        'android',
        dio,
        userId: 'user-1',
      );
      verify(
        () => dio.post(
          ApiConstants.notificationPushToken,
          data: {'token': 'current-token', 'device_type': 'android'},
        ),
      ).called(2);
    },
  );
}
