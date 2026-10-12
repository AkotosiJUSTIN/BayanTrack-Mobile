import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

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

  test('A-origin 401 after B login never refreshes or replays as B', () async {
    final session = _DummySession();
    final dispatched = Completer<void>();
    final response = Completer<ResponseBody>();
    var refreshes = 0;
    var bMutations = 0;
    final raw = Dio()
      ..httpClientAdapter = _DummyAdapter((options) async {
        if (options.path == ApiConstants.refresh) {
          refreshes++;
          return _body(200, {'access_token': 'access-b2'});
        }
        if (options.headers['Authorization'] == 'Bearer access-b2') {
          bMutations++;
        }
        return _body(200, {});
      });
    final client = Dio()
      ..httpClientAdapter = _DummyAdapter((options) {
        expect(options.headers['Authorization'], 'Bearer access-a');
        dispatched.complete();
        return response.future;
      });
    client.interceptors.add(AuthInterceptor(raw, session.repository));
    addTearDown(() {
      client.close();
      raw.close();
    });

    final operation = client.post(ApiConstants.notificationMarkAllRead);
    final rejected = expectLater(
      operation,
      throwsA(
        isA<DioException>().having(
          (error) => error.type,
          'type',
          DioExceptionType.cancel,
        ),
      ),
    );
    await dispatched.future;
    session.login('b');
    response.complete(_body(401, {}));
    await rejected;

    expect(refreshes, 0);
    expect(bMutations, 0);
    expect(session.refreshToken, 'refresh-b');
    verifyNever(
      () => session.repository.clearSessionIfRefreshTokenMatches(any()),
    );
  });

  test('mixed pending replay rejects A and preserves B waiters', () async {
    final session = _DummySession();
    final aDispatched = Completer<void>();
    final aResponse = Completer<ResponseBody>();
    final refreshStarted = Completer<void>();
    final refreshResponse = Completer<ResponseBody>();
    final errorsSeen = <String, Completer<void>>{
      '/a-operation/': Completer<void>(),
      '/b-pending/': Completer<void>(),
    };
    final replays = <String>[];
    final raw = Dio()
      ..httpClientAdapter = _DummyAdapter((options) async {
        if (options.path == ApiConstants.refresh) {
          expect(options.data['refresh_token'], 'refresh-b');
          refreshStarted.complete();
          return refreshResponse.future;
        }
        expect(options.headers['Authorization'], 'Bearer access-b2');
        replays.add(options.path);
        return _body(200, {});
      });
    final client = Dio()
      ..httpClientAdapter = _DummyAdapter((options) async {
        if (options.path == '/a-operation/') {
          expect(options.headers['Authorization'], 'Bearer access-a');
          aDispatched.complete();
          return aResponse.future;
        }
        expect(options.headers['Authorization'], 'Bearer access-b');
        return _body(401, {});
      });
    final interceptor = AuthInterceptor(raw, session.repository);
    client.interceptors.add(
      InterceptorsWrapper(
        onRequest: interceptor.onRequest,
        onError: (error, handler) async {
          await interceptor.onError(error, handler);
          errorsSeen[error.requestOptions.path]?.complete();
        },
      ),
    );
    addTearDown(() {
      client.close();
      raw.close();
    });

    final aOperation = client.post('/a-operation/');
    final rejected = expectLater(
      aOperation,
      throwsA(
        isA<DioException>().having(
          (error) => error.type,
          'type',
          DioExceptionType.cancel,
        ),
      ),
    );
    await aDispatched.future;
    session.login('b');
    final bLeader = client.post('/b-leader/');
    await refreshStarted.future;
    aResponse.complete(_body(401, {}));
    await errorsSeen['/a-operation/']!.future;
    final bPending = client.post('/b-pending/');
    await errorsSeen['/b-pending/']!.future;
    refreshResponse.complete(
      _body(200, {'access_token': 'access-b2', 'refresh_token': 'refresh-b2'}),
    );
    await Future.wait([rejected, bLeader, bPending]);

    expect(replays, ['/b-leader/', '/b-pending/']);
    expect(session.refreshToken, 'refresh-b2');
    verifyNever(
      () => session.repository.clearSessionIfRefreshTokenMatches(any()),
    );
  });

  test(
    'session switch while binding headers cancels before dispatch',
    () async {
      final session = _DummySession();
      when(() => session.repository.getAccessToken()).thenAnswer((_) async {
        session.login('b');
        return 'access-a';
      });
      var dispatched = 0;
      final adapter = _DummyAdapter((options) async {
        dispatched++;
        return _body(200, {});
      });
      final raw = Dio()..httpClientAdapter = adapter;
      final client = Dio()..httpClientAdapter = adapter;
      client.interceptors.add(AuthInterceptor(raw, session.repository));
      addTearDown(() {
        client.close();
        raw.close();
      });

      await expectLater(
        client.post('/operation/'),
        throwsA(
          isA<DioException>().having(
            (error) => error.type,
            'type',
            DioExceptionType.cancel,
          ),
        ),
      );

      expect(dispatched, 0);
      expect(session.refreshToken, 'refresh-b');
    },
  );

  test('403 passes through once without refresh', () async {
    final interceptor = AuthInterceptor(_DioMock(), _SessionMock());
    final handler = _HandlerMock();
    final request = RequestOptions(path: '/reports/report-1/');
    final error = _httpError(request, 403);

    await interceptor.onError(error, handler);

    verify(() => handler.next(error)).called(1);
  });

  test('public login 401 passes through without session refresh', () async {
    final dio = _DioMock();
    final session = _SessionMock();
    final interceptor = AuthInterceptor(dio, session);
    final handler = _HandlerMock();
    final request = RequestOptions(path: ApiConstants.login);
    await interceptor.onRequest(request, RequestInterceptorHandler());
    final error = _httpError(request, 401);

    await interceptor.onError(error, handler);

    verify(() => handler.next(error)).called(1);
    verifyNever(() => session.getRefreshToken());
    verifyNever(() => dio.post(any(), data: any(named: 'data')));
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

    final interceptor = AuthInterceptor(dio, session);
    await _bindRequest(interceptor, session, request);
    await interceptor.onError(_httpError(request, 401), handler);

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
      await _bindRequest(interceptor, session, firstRequest);
      await _bindRequest(interceptor, session, secondRequest);
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
      await _bindRequest(interceptor, session, firstRequest);
      await _bindRequest(interceptor, session, secondRequest);
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

    final interceptor = AuthInterceptor(dio, session);
    await _bindRequest(interceptor, session, request);
    await interceptor.onError(_httpError(request, 401), handler);

    verify(() => handler.reject(any())).called(1);
    verifyNever(() => dio.fetch(any()));
    verifyNever(() => session.clearSessionIfRefreshTokenMatches(any()));
  });
}

Future<void> _bindRequest(
  AuthInterceptor interceptor,
  _SessionMock session,
  RequestOptions request,
) async {
  when(() => session.getAccessToken()).thenAnswer((_) async => 'dummy-access');
  await interceptor.onRequest(request, RequestInterceptorHandler());
}

class _DummySession {
  final repository = _SessionMock();
  String accessToken = 'access-a';
  String refreshToken = 'refresh-a';

  _DummySession() {
    when(
      () => repository.getAccessToken(),
    ).thenAnswer((_) async => accessToken);
    when(
      () => repository.getRefreshToken(),
    ).thenAnswer((_) async => refreshToken);
    when(
      () => repository.saveTokensIfRefreshTokenMatches(
        expectedRefreshToken: any(named: 'expectedRefreshToken'),
        accessToken: any(named: 'accessToken'),
        refreshToken: any(named: 'refreshToken'),
      ),
    ).thenAnswer((invocation) async {
      if (invocation.namedArguments[#expectedRefreshToken] != refreshToken) {
        return false;
      }
      accessToken = invocation.namedArguments[#accessToken] as String;
      refreshToken = invocation.namedArguments[#refreshToken] as String;
      return true;
    });
  }

  void login(String account) {
    accessToken = 'access-$account';
    refreshToken = 'refresh-$account';
  }
}

class _DummyAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions) respond;

  _DummyAdapter(this.respond);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => respond(options);

  @override
  void close({bool force = false}) {}
}

ResponseBody _body(int status, Map<String, dynamic> data) =>
    ResponseBody.fromString(
      jsonEncode(data),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

DioException _httpError(RequestOptions request, int statusCode) => DioException(
  requestOptions: request,
  type: DioExceptionType.badResponse,
  response: Response(requestOptions: request, statusCode: statusCode),
);
