import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_models.freezed.dart';
part 'auth_models.g.dart';

// ==================== LOGIN ====================

@freezed
sealed class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    required String email,
    required String password,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
}

@freezed
sealed class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'refresh_token') required String refreshToken,
    Map<String, dynamic>? user,
  }) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
}

// ==================== REGISTER ====================

@freezed
sealed class RegisterRequest with _$RegisterRequest {
  const factory RegisterRequest({
    required String email,
    required String password,
    @JsonKey(name: 'password_confirm') required String passwordConfirm,
    @JsonKey(name: 'first_name') required String firstName,
    @JsonKey(name: 'last_name') required String lastName,
    @JsonKey(name: 'barangay_id') required String barangayId,
    @Default('citizen') String role,
  }) = _RegisterRequest;

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);
}

// ==================== TOKEN REFRESH ====================

@freezed
sealed class RefreshTokenRequest with _$RefreshTokenRequest {
  const factory RefreshTokenRequest({
    @JsonKey(name: 'refresh_token') required String refreshToken,
  }) = _RefreshTokenRequest;

  factory RefreshTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenRequestFromJson(json);
}

@freezed
sealed class RefreshTokenResponse with _$RefreshTokenResponse {
  const factory RefreshTokenResponse({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'refresh_token') required String refreshToken,
  }) = _RefreshTokenResponse;

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenResponseFromJson(json);
}

// ==================== USER PROFILE ====================

@freezed
sealed class UserProfile with _$UserProfile {
  const factory UserProfile({
    @JsonKey(name: 'id', readValue: _readUserId) required String id,
    required String email,
    @JsonKey(name: 'first_name') @Default('') String firstName,
    @JsonKey(name: 'last_name') @Default('') String lastName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @Default('citizen') String role,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

/// Helper to read user ID from either 'id' or '_id' field
/// Returns a non-null String, defaulting to empty string if neither field exists
Object _readUserId(Map<dynamic, dynamic> json, String key) {
  final id = json['id'] ?? json['_id'];
  return id?.toString() ?? '';
}

@freezed
sealed class ProfileUpdateRequest with _$ProfileUpdateRequest {
  const factory ProfileUpdateRequest({
    @JsonKey(name: 'first_name') String? firstName,
    @JsonKey(name: 'last_name') String? lastName,
    // includeIfNull: false → field is excluded from JSON when null.
    // This prevents a name-only save from wiping the stored avatar_url.
    @JsonKey(name: 'avatar_url', includeIfNull: false) String? avatarUrl,
  }) = _ProfileUpdateRequest;

  factory ProfileUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$ProfileUpdateRequestFromJson(json);
}

// ==================== PASSWORD MANAGEMENT ====================

@freezed
sealed class ChangePasswordRequest with _$ChangePasswordRequest {
  const factory ChangePasswordRequest({
    @JsonKey(name: 'old_password') required String currentPassword,
    @JsonKey(name: 'new_password') required String newPassword,
    @JsonKey(name: 'new_password_confirm') required String newPasswordConfirm,
  }) = _ChangePasswordRequest;

  factory ChangePasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ChangePasswordRequestFromJson(json);
}

@freezed
sealed class ForgotPasswordRequest with _$ForgotPasswordRequest {
  const factory ForgotPasswordRequest({
    required String email,
    @Default('mobile') String platform,
  }) = _ForgotPasswordRequest;

  factory ForgotPasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordRequestFromJson(json);
}

@freezed
sealed class ResetPasswordRequest with _$ResetPasswordRequest {
  const factory ResetPasswordRequest({
    required String token,
    @JsonKey(name: 'new_password') required String newPassword,
    @JsonKey(name: 'new_password_confirm') required String newPasswordConfirm,
  }) = _ResetPasswordRequest;

  factory ResetPasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordRequestFromJson(json);
}

// ==================== BARANGAYS ====================

@freezed
sealed class BarangayModel with _$BarangayModel {
  const factory BarangayModel({
    required String id,
    required String name,
    @JsonKey(name: 'center_lat') required double centerLat,
    @JsonKey(name: 'center_lng') required double centerLng,
  }) = _BarangayModel;

  factory BarangayModel.fromJson(Map<String, dynamic> json) =>
      _$BarangayModelFromJson(json);
}

@freezed
sealed class BarangaysResponse with _$BarangaysResponse {
  const factory BarangaysResponse({
    required List<BarangayModel> barangays,
    required int count,
  }) = _BarangaysResponse;

  factory BarangaysResponse.fromJson(Map<String, dynamic> json) =>
      _$BarangaysResponseFromJson(json);
}
