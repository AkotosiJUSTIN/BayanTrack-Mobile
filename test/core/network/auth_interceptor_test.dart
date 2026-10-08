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

class _DioExceptionFake extends Fake implements DioException {}

void main() {
  setUpAll(() {
    registerFallbackValue(_RequestOptionsFake());
    registerFallbackValue(_ResponseFake());
    registerFallbackValue(_DioExceptionFake());
  });

  test('403 passes through once without refresh', () async {
    final interceptor = AuthInterceptor(_DioMock(), _SessionMock());
    final handler = _HandlerMock();
    final request = RequestOptions(path: '/reports/report-1/');
    final error = _httpError(request, 403);

    await interceptor.onError(error, handler);

    verify(() => handler.next(error)).called(1);
  });

  test('401 refreshes and retries original request', () async {
    final dio = _DioMock();
    final session = _SessionMock();
    final handler = _HandlerMock();
    final request = RequestOptions(path: '/reports/report-1/');
    var currentRefreshToken = 'refresh-1';
    when(
      () => session.getRefreshToken(),
    ).thenAnswer((_) async => currentRefreshToken);
    when(
      () => session.saveTokensIfRefreshTokenMatches(
        expectedRefreshToken: 'refresh-1',
        accessToken: 'access-2',
        refreshToken: 'refresh-2',
      ),
    ).thenAnswer((_) async {
      currentRefreshToken = 'refresh-2';
      return true;
    });
    when(
      () => dio.post(
        ApiConstants.refresh,
        data: {'refresh_token': 'refresh-1', 'client_type': 'mobile'},
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

    await AuthInterceptor(
      dio,
      session,
    ).onError(_httpError(request, 401), handler);

    verify(
      () => session.saveTokensIfRefreshTokenMatches(
        expectedRefreshToken: 'refresh-1',
        accessToken: 'access-2',
        refreshToken: 'refresh-2',
      ),
    ).called(1);
    verify(() => dio.fetch(request)).called(1);
    verify(() => handler.resolve(any())).called(1);
  });

  test(
    'revoked refresh clears matching session and rejects all waiters',
    () async {
      final dio = _DioMock();
      final session = _SessionMock();
      final firstHandler = _HandlerMock();
      final secondHandler = _HandlerMock();
      final firstRequest = RequestOptions(path: '/reports/first/');
      final secondRequest = RequestOptions(path: '/reports/second/');
      final refreshError = _httpError(
        RequestOptions(path: ApiConstants.refresh),
        401,
      );
      when(
        () => session.getRefreshToken(),
      ).thenAnswer((_) async => 'refresh-a');
      when(
        () => dio.post(
          ApiConstants.refresh,
          data: {'refresh_token': 'refresh-a', 'client_type': 'mobile'},
        ),
      ).thenThrow(refreshError);
      when(
        () => session.clearSessionIfRefreshTokenMatches('refresh-a'),
      ).thenAnswer((_) async => true);

      final interceptor = AuthInterceptor(dio, session);
      final first = interceptor.onError(
        _httpError(firstRequest, 401),
        firstHandler,
      );
      await interceptor.onError(_httpError(secondRequest, 401), secondHandler);
      await first;

      verify(
        () => session.clearSessionIfRefreshTokenMatches('refresh-a'),
      ).called(1);
      verify(() => firstHandler.reject(any())).called(1);
      verify(() => secondHandler.reject(any())).called(1);
      verifyNever(() => dio.fetch(any()));
    },
  );

  test(
    'temporary refresh failure rejects waiters without clearing session',
    () async {
      final dio = _DioMock();
      final session = _SessionMock();
      final firstHandler = _HandlerMock();
      final secondHandler = _HandlerMock();
      final firstRequest = RequestOptions(path: '/reports/first/');
      final secondRequest = RequestOptions(path: '/reports/second/');
      final refreshError = DioException(
        requestOptions: RequestOptions(path: ApiConstants.refresh),
        type: DioExceptionType.connectionTimeout,
      );
      when(
        () => session.getRefreshToken(),
      ).thenAnswer((_) async => 'refresh-a');
      when(
        () => dio.post(
          ApiConstants.refresh,
          data: {'refresh_token': 'refresh-a', 'client_type': 'mobile'},
        ),
      ).thenThrow(refreshError);

      final interceptor = AuthInterceptor(dio, session);
      final first = interceptor.onError(
        _httpError(firstRequest, 401),
        firstHandler,
      );
      await interceptor.onError(_httpError(secondRequest, 401), secondHandler);
      await first;

      verify(() => firstHandler.reject(any())).called(1);
      verify(() => secondHandler.reject(any())).called(1);
      verifyNever(() => session.clearSessionIfRefreshTokenMatches(any()));
      verifyNever(() => dio.fetch(any()));
    },
  );

  test('late refresh cannot replace a different signed-in account', () async {
    final dio = _DioMock();
    final session = _SessionMock();
    final handler = _HandlerMock();
    final request = RequestOptions(path: '/reports/report-1/');
    when(() => session.getRefreshToken()).thenAnswer((_) async => 'refresh-a');
    when(
      () => dio.post(
        ApiConstants.refresh,
        data: {'refresh_token': 'refresh-a', 'client_type': 'mobile'},
      ),
    ).thenAnswer(
      (_) async => Response(
        data: {'access_token': 'access-a2'},
        statusCode: 200,
        requestOptions: RequestOptions(path: ApiConstants.refresh),
      ),
    );
    when(
      () => session.saveTokensIfRefreshTokenMatches(
        expectedRefreshToken: 'refresh-a',
        accessToken: 'access-a2',
        refreshToken: 'refresh-a',
      ),
    ).thenAnswer((_) async => false);

    await AuthInterceptor(
      dio,
      session,
    ).onError(_httpError(request, 401), handler);

    verify(() => handler.reject(any())).called(1);
    verifyNever(() => dio.fetch(any()));
    verifyNever(() => session.clearSessionIfRefreshTokenMatches(any()));
  });
}

DioException _httpError(RequestOptions request, int statusCode) => DioException(
  requestOptions: request,
  type: DioExceptionType.badResponse,
  response: Response(requestOptions: request, statusCode: statusCode),
);
