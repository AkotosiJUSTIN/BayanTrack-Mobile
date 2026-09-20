import 'package:bayantrack_mobile/core/constants/api_constants.dart';
import 'package:bayantrack_mobile/features/auth/domain/auth_session_repository.dart';
import 'package:bayantrack_mobile/core/network/auth_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _DioMock extends Mock implements Dio {}

class _HandlerMock extends Mock implements ErrorInterceptorHandler {}

class _SessionMock extends Mock implements AuthSessionRepository {}

class _RequestOptionsFake extends Fake implements RequestOptions {}

class _ResponseFake extends Fake implements Response<dynamic> {}

void main() {
  setUpAll(() {
    registerFallbackValue(_RequestOptionsFake());
    registerFallbackValue(_ResponseFake());
  });

  test('403 passes through once without refresh', () async {
    final interceptor = AuthInterceptor(_DioMock(), _SessionMock());
    final handler = _HandlerMock();
    final request = RequestOptions(path: '/reports/report-1/');
    final error = DioException(
      requestOptions: request,
      type: DioExceptionType.badResponse,
      response: Response(requestOptions: request, statusCode: 403),
    );

    await interceptor.onError(error, handler);

    verify(() => handler.next(error)).called(1);
  });

  test('401 refreshes and retries original request', () async {
    final dio = _DioMock();
    final session = _SessionMock();
    final handler = _HandlerMock();
    final request = RequestOptions(path: '/reports/report-1/');
    final error = DioException(
      requestOptions: request,
      type: DioExceptionType.badResponse,
      response: Response(requestOptions: request, statusCode: 401),
    );

    when(() => session.getRefreshToken()).thenAnswer((_) async => 'refresh');
    when(
      () => session.saveTokens(
        accessToken: 'access-2',
        refreshToken: 'refresh-2',
      ),
    ).thenAnswer((_) async {});
    when(
      () => dio.post(
        ApiConstants.refresh,
        data: {'refresh_token': 'refresh', 'client_type': 'mobile'},
      ),
    ).thenAnswer(
      (_) async => Response(
        data: {'access_token': 'access-2', 'refresh_token': 'refresh-2'},
        statusCode: 200,
        requestOptions: RequestOptions(path: ApiConstants.refresh),
      ),
    );
    when(() => dio.fetch(any())).thenAnswer(
      (_) async => Response(
        data: {'id': 'report-1'},
        statusCode: 200,
        requestOptions: request,
      ),
    );

    await AuthInterceptor(dio, session).onError(error, handler);

    verify(
      () => session.saveTokens(
        accessToken: 'access-2',
        refreshToken: 'refresh-2',
      ),
    ).called(1);
    verify(() => dio.fetch(request)).called(1);
    verify(() => handler.resolve(any())).called(1);
  });
}
