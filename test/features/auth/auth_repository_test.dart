import 'package:bayantrack_mobile/core/constants/api_constants.dart';
import 'package:bayantrack_mobile/features/auth/data/auth_models.dart';
import 'package:bayantrack_mobile/features/auth/data/auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late AuthRepository authRepository;

  setUp(() {
    mockDio = MockDio();
    authRepository = AuthRepository(mockDio);
  });

  group('AuthRepository', () {
    group('login', () {
      test('should return LoginResponse on successful login', () async {
        // Arrange
        final request = LoginRequest(
          email: 'test@example.com',
          password: 'Test123!',
        );
        final responseData = {
          'access_token': 'access_token_123',
          'refresh_token': 'refresh_token_456',
          'user': {'_id': '1', 'email': 'test@example.com'},
        };

        when(
          () => mockDio.post(ApiConstants.login, data: request.toJson()),
        ).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ApiConstants.login),
          ),
        );

        // Act
        final result = await authRepository.login(request);

        // Assert
        expect(result.accessToken, 'access_token_123');
        expect(result.refreshToken, 'refresh_token_456');
        verify(
          () => mockDio.post(ApiConstants.login, data: request.toJson()),
        ).called(1);
      });

      test('should throw on login failure', () async {
        // Arrange
        final request = LoginRequest(
          email: 'test@example.com',
          password: 'wrongpassword',
        );

        when(
          () => mockDio.post(ApiConstants.login, data: request.toJson()),
        ).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            response: Response(
              statusCode: 401,
              data: {'detail': 'Invalid credentials'},
              requestOptions: RequestOptions(path: ApiConstants.login),
            ),
            requestOptions: RequestOptions(path: ApiConstants.login),
          ),
        );

        // Act & Assert
        expect(
          () => authRepository.login(request),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('register', () {
      test('should complete successfully on valid registration', () async {
        // Arrange
        final request = RegisterRequest(
          email: 'newuser@example.com',
          password: 'NewP@ss123',
          passwordConfirm: 'NewP@ss123',
          firstName: 'Juan',
          lastName: 'Cruz',
        );

        when(
          () => mockDio.post(ApiConstants.register, data: request.toJson()),
        ).thenAnswer(
          (_) async => Response(
            data: {'message': 'Registration successful'},
            statusCode: 201,
            requestOptions: RequestOptions(path: ApiConstants.register),
          ),
        );

        // Act
        await authRepository.register(request);

        // Assert
        verify(
          () => mockDio.post(ApiConstants.register, data: request.toJson()),
        ).called(1);
      });
    });

    group('getProfile', () {
      test('should return UserProfile on success', () async {
        // Arrange
        final responseData = {
          '_id': 'user_123',
          'email': 'test@example.com',
          'first_name': 'Juan',
          'last_name': 'Cruz',
          'role': 'citizen',
          'is_active': true,
        };

        when(() => mockDio.get(ApiConstants.profile)).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ApiConstants.profile),
          ),
        );

        // Act
        final result = await authRepository.getProfile();

        // Assert
        expect(result.id, 'user_123');
        expect(result.email, 'test@example.com');
        expect(result.firstName, 'Juan');
        expect(result.lastName, 'Cruz');
        expect(result.role, 'citizen');
        verify(() => mockDio.get(ApiConstants.profile)).called(1);
      });
    });

    group('refreshToken', () {
      test('should return new tokens on successful refresh', () async {
        // Arrange
        const refreshToken = 'old_refresh_token';
        final responseData = {
          'access_token': 'new_access_token',
          'refresh_token': 'new_refresh_token',
        };

        when(
          () => mockDio.post(ApiConstants.refresh, data: any(named: 'data')),
        ).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ApiConstants.refresh),
          ),
        );

        // Act
        final result = await authRepository.refreshToken(refreshToken);

        // Assert
        expect(result.accessToken, 'new_access_token');
        expect(result.refreshToken, 'new_refresh_token');
      });
    });

    group('changePassword', () {
      test('should complete successfully on valid password change', () async {
        // Arrange
        final request = ChangePasswordRequest(
          currentPassword: 'OldP@ss123',
          newPassword: 'NewP@ss456',
          newPasswordConfirm: 'NewP@ss456',
        );

        when(
          () =>
              mockDio.post(ApiConstants.changePassword, data: request.toJson()),
        ).thenAnswer(
          (_) async => Response(
            data: {'message': 'Password changed'},
            statusCode: 200,
            requestOptions: RequestOptions(path: ApiConstants.changePassword),
          ),
        );

        // Act
        await authRepository.changePassword(request);

        // Assert
        verify(
          () =>
              mockDio.post(ApiConstants.changePassword, data: request.toJson()),
        ).called(1);
      });
    });

    group('forgotPassword', () {
      test('should complete successfully', () async {
        // Arrange
        const email = 'test@example.com';

        when(
          () => mockDio.post(
            ApiConstants.forgotPassword,
            data: any(named: 'data'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: {'message': 'Reset email sent'},
            statusCode: 200,
            requestOptions: RequestOptions(path: ApiConstants.forgotPassword),
          ),
        );

        // Act
        await authRepository.forgotPassword(email);

        // Assert
        verify(
          () => mockDio.post(
            ApiConstants.forgotPassword,
            data: any(named: 'data'),
          ),
        ).called(1);
      });
    });

    group('logout', () {
      test('should complete successfully', () async {
        // Arrange
        const refreshToken = 'refresh_token_123';

        when(
          () => mockDio.post(
            ApiConstants.logout,
            data: {'refresh_token': refreshToken},
          ),
        ).thenAnswer(
          (_) async => Response(
            data: {'message': 'Logged out'},
            statusCode: 200,
            requestOptions: RequestOptions(path: ApiConstants.logout),
          ),
        );

        // Act
        await authRepository.logout(refreshToken);

        // Assert
        verify(
          () => mockDio.post(
            ApiConstants.logout,
            data: {'refresh_token': refreshToken},
          ),
        ).called(1);
      });
    });
  });
}
