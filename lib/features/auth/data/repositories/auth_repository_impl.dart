import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/domain/result.dart';
import '../../../../core/network/error_mapper.dart';
import '../../domain/auth_repository.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/user.dart';
import '../auth_models.dart';
import '../mappers/auth_mapper.dart';

/// Implementation of [AuthRepository] using Dio.
///
/// All methods return [Result<T>] and use [ErrorMapper] for error handling.
class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;

  AuthRepositoryImpl(this._dio);

  @override
  Future<Result<AuthTokens>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: LoginRequest(email: email, password: password).toJson(),
      );
      final loginResponse = LoginResponse.fromJson(response.data);
      return Success(AuthMapper.tokensFromLoginResponse(loginResponse));
    } catch (e, stack) {
      return Err(ErrorMapper.mapException(e, stack));
    }
  }

  @override
  Future<Result<AuthTokens>> register({
    required String email,
    required String password,
    required String passwordConfirm,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: RegisterRequest(
          email: email,
          password: password,
          passwordConfirm: passwordConfirm,
          firstName: firstName,
          lastName: lastName,
        ).toJson(),
      );
      // Backend returns tokens on registration (same shape as login)
      final loginResponse = LoginResponse.fromJson(response.data);
      return Success(AuthMapper.tokensFromLoginResponse(loginResponse));
    } catch (e, stack) {
      return Err(ErrorMapper.mapException(e, stack));
    }
  }

  @override
  Future<Result<AuthTokens>> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        ApiConstants.refresh,
        data: RefreshTokenRequest(refreshToken: refreshToken).toJson(),
      );
      final tokenResponse = RefreshTokenResponse.fromJson(response.data);
      return Success(AuthMapper.tokensFromRefreshResponse(tokenResponse));
    } catch (e, stack) {
      return Err(ErrorMapper.mapException(e, stack));
    }
  }

  @override
  Future<Result<void>> logout(String refreshToken) async {
    try {
      await _dio.post(
        ApiConstants.logout,
        data: {'refresh_token': refreshToken},
      );
      return const Success(null);
    } catch (e, stack) {
      return Err(ErrorMapper.mapException(e, stack));
    }
  }

  @override
  Future<Result<void>> logoutAll() async {
    try {
      await _dio.post(ApiConstants.logoutAll);
      return const Success(null);
    } catch (e, stack) {
      return Err(ErrorMapper.mapException(e, stack));
    }
  }

  @override
  Future<Result<User>> getProfile() async {
    try {
      final response = await _dio.get(ApiConstants.profile);
      final userData = response.data['user'] ?? response.data;
      final profile = UserProfile.fromJson(userData);
      return Success(AuthMapper.userFromProfile(profile));
    } catch (e, stack) {
      return Err(ErrorMapper.mapException(e, stack));
    }
  }

  @override
  Future<Result<User>> updateProfile({
    String? firstName,
    String? lastName,
  }) async {
    try {
      final response = await _dio.put(
        ApiConstants.profileUpdate,
        data: ProfileUpdateRequest(
          firstName: firstName,
          lastName: lastName,
        ).toJson(),
      );
      final userData = response.data['user'] ?? response.data;
      final profile = UserProfile.fromJson(userData);
      return Success(AuthMapper.userFromProfile(profile));
    } catch (e, stack) {
      return Err(ErrorMapper.mapException(e, stack));
    }
  }

  @override
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    try {
      await _dio.post(
        ApiConstants.changePassword,
        data: ChangePasswordRequest(
          currentPassword: currentPassword,
          newPassword: newPassword,
          newPasswordConfirm: newPasswordConfirm,
        ).toJson(),
      );
      return const Success(null);
    } catch (e, stack) {
      return Err(ErrorMapper.mapException(e, stack));
    }
  }

  @override
  Future<Result<void>> forgotPassword(String email) async {
    try {
      await _dio.post(
        ApiConstants.forgotPassword,
        data: ForgotPasswordRequest(email: email).toJson(),
      );
      return const Success(null);
    } catch (e, stack) {
      return Err(ErrorMapper.mapException(e, stack));
    }
  }

  @override
  Future<Result<void>> resetPassword({
    required String token,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    try {
      await _dio.post(
        ApiConstants.resetPassword,
        data: ResetPasswordRequest(
          token: token,
          newPassword: newPassword,
          newPasswordConfirm: newPasswordConfirm,
        ).toJson(),
      );
      return const Success(null);
    } catch (e, stack) {
      return Err(ErrorMapper.mapException(e, stack));
    }
  }
}
