import 'dart:async';

import 'package:bayantrack_mobile/core/constants/api_constants.dart';
import 'package:bayantrack_mobile/core/domain/failures.dart';
import 'package:bayantrack_mobile/features/auth/auth_di.dart';
import 'package:bayantrack_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:bayantrack_mobile/features/auth/data/repositories/auth_session_repository_impl.dart';
import 'package:bayantrack_mobile/features/auth/domain/entities/user.dart';
import 'package:bayantrack_mobile/features/auth/domain/usecases/load_session_usecase.dart';
import 'package:bayantrack_mobile/features/auth/presentation/auth_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _StorageMock extends Mock implements FlutterSecureStorage {}

class _DioMock extends Mock implements Dio {}

const _user = User(
  id: 'citizen-a',
  email: 'citizen@example.test',
  firstName: 'Test',
  lastName: 'Citizen',
  role: UserRole.citizen,
);

void main() {
  late _StorageMock storage;
  late Map<String, String> values;
  late _DioMock dio;
  late AuthSessionRepositoryImpl session;
  late AuthRepositoryImpl repository;
  late LoadSessionUseCase restore;

  setUp(() async {
    storage = _StorageMock();
    values = {};
    when(
      () => storage.read(key: any(named: 'key')),
    ).thenAnswer((invocation) async => values[invocation.namedArguments[#key]]);
    when(
      () => storage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((invocation) async {
      values[invocation.namedArguments[#key] as String] =
          invocation.namedArguments[#value] as String;
    });
    when(() => storage.delete(key: any(named: 'key'))).thenAnswer(
      (invocation) async => values.remove(invocation.namedArguments[#key]),
    );
    dio = _DioMock();
    session = AuthSessionRepositoryImpl(storage);
    repository = AuthRepositoryImpl(dio, sessionRepository: session);
    restore = LoadSessionUseCase(
      sessionRepository: session,
      authRepository: repository,
    );
    await session.saveTokens(
      accessToken: 'access-a',
      refreshToken: 'refresh-a',
    );
  });

  tearDown(() => session.dispose());

  void offline() {
    when(() => dio.get(ApiConstants.profile)).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: ApiConstants.profile),
        type: DioExceptionType.connectionError,
      ),
    );
  }

  test('verified profile survives cold restart offline', () async {
    when(() => dio.get(ApiConstants.profile)).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: ApiConstants.profile),
        data: {
          'user': {
            'id': _user.id,
            'email': _user.email,
            'first_name': _user.firstName,
            'last_name': _user.lastName,
            'role': 'citizen',
            'is_active': true,
          },
        },
      ),
    );
    expect((await restore()).dataOrNull, _user);
    final restartedSession = AuthSessionRepositoryImpl(storage);
    addTearDown(restartedSession.dispose);
    offline();
    final container = ProviderContainer(
      overrides: [
        authSessionRepositoryProvider.overrideWithValue(restartedSession),
        loadSessionUseCaseProvider.overrideWithValue(
          LoadSessionUseCase(
            sessionRepository: restartedSession,
            authRepository: repository,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(authControllerProvider, (_, _) {});
    addTearDown(subscription.close);
    await container.read(authControllerProvider.notifier).checkAuth();
    final state = container.read(authControllerProvider);
    expect(state, isA<AuthSuccess>());
    expect((state as AuthSuccess).user, _user);
    expect(await restartedSession.getAccessToken(), 'access-a');
  });

  test('no verified identity cannot restore offline access', () async {
    offline();
    expect((await restore()).failureOrNull, isA<NetworkFailure>());
    expect(await session.isAuthenticated, isTrue);
  });

  test('known offline startup restores without waiting for HTTP', () async {
    await session.cacheUser(_user, expectedAccessToken: 'access-a');
    final offlineRestore = LoadSessionUseCase(
      sessionRepository: session,
      authRepository: repository,
      isOnline: () => false,
    );
    expect((await offlineRestore()).dataOrNull, _user);
    verifyNever(() => dio.get(ApiConstants.profile));
  });

  test('server outage preserves verified local identity', () async {
    await session.cacheUser(_user, expectedAccessToken: 'access-a');
    when(() => dio.get(ApiConstants.profile)).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: ApiConstants.profile),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: ApiConstants.profile),
          statusCode: 503,
        ),
      ),
    );
    expect((await restore()).dataOrNull, _user);
  });

  test('rejected credentials clear tokens and cached identity', () async {
    await session.cacheUser(_user, expectedAccessToken: 'access-a');
    when(() => dio.get(ApiConstants.profile)).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: ApiConstants.profile),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: ApiConstants.profile),
          statusCode: 401,
        ),
      ),
    );
    final result = await restore();
    expect(result.isSuccess, isTrue);
    expect(result.dataOrNull, isNull);
    expect(values, isEmpty);
  });

  test('logout removes offline access', () async {
    await session.cacheUser(_user, expectedAccessToken: 'access-a');
    await session.clearSession();
    offline();
    expect((await restore()).dataOrNull, isNull);
    expect(await session.getCachedUser(), isNull);
    verifyNever(() => dio.get(ApiConstants.profile));
  });

  test('new login cannot inherit previous account profile', () async {
    await session.cacheUser(_user, expectedAccessToken: 'access-a');
    await session.saveTokens(
      accessToken: 'access-b',
      refreshToken: 'refresh-b',
    );
    offline();
    expect((await restore()).failureOrNull, isA<NetworkFailure>());
    expect(await session.getCachedUser(), isNull);
  });

  test('token rotation retains same account offline identity', () async {
    await session.cacheUser(_user, expectedAccessToken: 'access-a');
    expect(
      await session.saveTokensIfRefreshTokenMatches(
        expectedRefreshToken: 'refresh-a',
        accessToken: 'access-a2',
        refreshToken: 'refresh-a2',
      ),
      isTrue,
    );
    offline();
    expect((await restore()).dataOrNull, _user);
  });

  test('late profile response cannot repopulate cache after logout', () async {
    final response = Completer<Response<dynamic>>();
    when(
      () => dio.get(ApiConstants.profile),
    ).thenAnswer((_) => response.future);
    final request = repository.getProfile();
    await Future<void>.delayed(Duration.zero);
    await session.clearSession();
    response.complete(
      Response(
        requestOptions: RequestOptions(path: ApiConstants.profile),
        data: {'id': _user.id, 'email': _user.email},
      ),
    );
    await request;
    expect(values, isEmpty);
    expect(await session.getCachedUser(), isNull);
  });

  test('inactive cached account is not restored', () async {
    await session.cacheUser(
      const User(
        id: 'inactive',
        email: 'inactive@example.test',
        firstName: 'Test',
        lastName: 'Citizen',
        role: UserRole.citizen,
        isActive: false,
      ),
      expectedAccessToken: 'access-a',
    );
    offline();
    expect((await restore()).failureOrNull, isA<NetworkFailure>());
  });

  test('cached profile preserves forced password-change restriction', () async {
    const restricted = User(
      id: 'restricted',
      email: 'restricted@example.test',
      firstName: 'Test',
      lastName: 'Citizen',
      role: UserRole.citizen,
      passwordChangeRequired: true,
    );
    await session.cacheUser(restricted, expectedAccessToken: 'access-a');
    offline();
    expect((await restore()).dataOrNull?.requiresPasswordChange, isTrue);
  });
}
