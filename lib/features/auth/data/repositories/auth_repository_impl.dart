import 'dart:io';

import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/domain/failures.dart';
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
        data: {
          ...LoginRequest(email: email, password: password).toJson(),
          'client_type': 'mobile',
        },
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
    required String barangayId,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: {
          ...RegisterRequest(
            email: email,
            password: password,
            passwordConfirm: passwordConfirm,
            firstName: firstName,
            lastName: lastName,
            barangayId: barangayId,
          ).toJson(),
          'client_type': 'mobile',
        },
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
        data: {
          ...RefreshTokenRequest(refreshToken: refreshToken).toJson(),
          'client_type': 'mobile',
        },
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
    String? phone,
    int? expectedRevision,
  }) async {
    try {
      final response = await _dio.put(
        ApiConstants.profileUpdate,
        data: ProfileUpdateRequest(
          firstName: firstName,
          lastName: lastName,
          phone: phone,
          expectedRevision: expectedRevision,
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
  Future<Result<User>> uploadAvatar(
    File imageFile, {
    void Function(int sent, int total)? onSendProgress,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.profileAvatar,
        data: FormData.fromMap({
          'avatar': await MultipartFile.fromFile(
            imageFile.path,
            filename: 'avatar',
          ),
        }),
        onSendProgress: onSendProgress,
      );
      final userData = response.data['user'] ?? response.data;
      return Success(
        AuthMapper.userFromProfile(UserProfile.fromJson(userData)),
      );
    } catch (e, stack) {
      return Err(ErrorMapper.mapException(e, stack));
    }
  }

  @override
  Future<Result<User>> removeAvatar() async {
    try {
      final response = await _dio.delete(ApiConstants.profileAvatar);
      final userData = response.data['user'] ?? response.data;
      return Success(
        AuthMapper.userFromProfile(UserProfile.fromJson(userData)),
      );
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
        data: ForgotPasswordRequest(email: email, platform: 'mobile').toJson(),
      );
      return const Success(null);
    } catch (e, stack) {
      return Err(ErrorMapper.mapException(e, stack));
    }
  }

  @override
  Future<Result<String>> verifyResetOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.verifyResetOtp,
        data: {'email': email, 'otp': otp},
      );
      final resetToken = response.data['reset_token'] as String?;
      if (resetToken == null || resetToken.isEmpty) {
        return const Err(
          ServerFailure('Invalid response from server. Please try again.'),
        );
      }
      return Success(resetToken);
    } catch (e, stack) {
      return Err(ErrorMapper.mapException(e, stack));
    }
  }

  @override
  Future<Result<void>> resetPassword({
    required String resetToken,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    try {
      await _dio.post(
        ApiConstants.resetPassword,
        data: {
          'token': resetToken,
          'new_password': newPassword,
          'new_password_confirm': newPasswordConfirm,
        },
      );
      return const Success(null);
    } catch (e, stack) {
      return Err(ErrorMapper.mapException(e, stack));
    }
  }

  @override
  Future<Result<List<MunicipalityModel>>> getMunicipalities() async {
    try {
      final response = await _dio.get(ApiConstants.municipalities);
      return Success(
        MunicipalitiesResponse.fromJson(response.data).municipalities,
      );
    } catch (e, stack) {
      return Err(ErrorMapper.mapException(e, stack));
    }
  }

  @override
  Future<Result<List<BarangayModel>>> getBarangays({
    String municipalityId = 'urdaneta',
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.barangays,
        queryParameters: {'municipality_id': municipalityId},
      );
      final barangaysResponse = BarangaysResponse.fromJson(response.data);
      return Success(barangaysResponse.barangays);
    } catch (e, stack) {
      return Err(ErrorMapper.mapException(e, stack));
    }
  }
}
