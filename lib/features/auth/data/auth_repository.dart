import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_provider.dart';
import 'auth_models.dart';

part 'auth_repository.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  return AuthRepository(dio);
}

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  // ==================== LOGIN / REGISTER ====================

  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: request.toJson(),
    );
    return LoginResponse.fromJson(response.data);
  }

  Future<void> register(RegisterRequest request) async {
    await _dio.post(ApiConstants.register, data: request.toJson());
  }

  // ==================== TOKEN MANAGEMENT ====================

  Future<RefreshTokenResponse> refreshToken(String refreshToken) async {
    final response = await _dio.post(
      ApiConstants.refresh,
      data: RefreshTokenRequest(refreshToken: refreshToken).toJson(),
    );
    return RefreshTokenResponse.fromJson(response.data);
  }

  Future<void> logout(String refreshToken) async {
    await _dio.post(ApiConstants.logout, data: {'refresh_token': refreshToken});
  }

  Future<void> logoutAll() async {
    await _dio.post(ApiConstants.logoutAll);
  }

  // ==================== PROFILE ====================

  Future<UserProfile> getProfile() async {
    final response = await _dio.get(ApiConstants.profile);
    return UserProfile.fromJson(response.data);
  }

  Future<UserProfile> updateProfile(ProfileUpdateRequest request) async {
    final response = await _dio.put(
      ApiConstants.profileUpdate,
      data: request.toJson(),
    );
    return UserProfile.fromJson(response.data);
  }

  // ==================== PASSWORD MANAGEMENT ====================

  Future<void> changePassword(ChangePasswordRequest request) async {
    await _dio.post(ApiConstants.changePassword, data: request.toJson());
  }

  Future<void> forgotPassword(String email) async {
    await _dio.post(
      ApiConstants.forgotPassword,
      data: ForgotPasswordRequest(email: email).toJson(),
    );
  }

  Future<void> resetPassword(ResetPasswordRequest request) async {
    await _dio.post(ApiConstants.resetPassword, data: request.toJson());
  }
}
