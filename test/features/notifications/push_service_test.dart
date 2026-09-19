import 'package:bayantrack_mobile/core/constants/api_constants.dart';
import 'package:bayantrack_mobile/features/notifications/push_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _DioMock extends Mock implements Dio {}

void main() {
  test('does not register the same token twice for one account', () async {
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
    ).called(1);
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
}
