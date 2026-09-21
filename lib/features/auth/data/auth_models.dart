import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/maps/municipality_boundary.dart';

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
    String? phone,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'avatar_revision') @Default(0) int avatarRevision,
    @JsonKey(name: 'avatar_storage_status') String? avatarStorageStatus,
    @JsonKey(name: 'profile_revision') @Default(0) int profileRevision,
    @Default('citizen') String role,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    @JsonKey(name: 'password_changed_at') String? passwordChangedAt,
    @JsonKey(name: 'password_expires_at') String? passwordExpiresAt,
    @JsonKey(name: 'password_days_remaining') int? passwordDaysRemaining,
    @JsonKey(name: 'password_warning_level') String? passwordWarningLevel,
    @JsonKey(name: 'password_expired') @Default(false) bool passwordExpired,
    @JsonKey(name: 'password_change_required')
    @Default(false)
    bool passwordChangeRequired,
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
    String? phone,
    @JsonKey(name: 'expected_revision') int? expectedRevision,
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
    @JsonKey(name: 'municipality_id')
    @Default('urdaneta')
    String municipalityId,
    String? municipality,
    String? province,
  }) = _BarangayModel;

  factory BarangayModel.fromJson(Map<String, dynamic> json) =>
      _$BarangayModelFromJson(json);
}

/// Geographic bounds supplied by the municipality metadata endpoint.
class MunicipalityBounds {
  final double south;
  final double west;
  final double north;
  final double east;

  const MunicipalityBounds({
    required this.south,
    required this.west,
    required this.north,
    required this.east,
  });

  factory MunicipalityBounds.fromJson(Map<String, dynamic> json) {
    double number(String key) => (json[key] as num).toDouble();
    return MunicipalityBounds(
      south: number('south'),
      west: number('west'),
      north: number('north'),
      east: number('east'),
    );
  }

  bool get isValid => south < north && west < east;

  bool contains(double latitude, double longitude) =>
      isValid &&
      latitude >= south &&
      latitude <= north &&
      longitude >= west &&
      longitude <= east;

  Map<String, dynamic> toJson() => {
    'south': south,
    'west': west,
    'north': north,
    'east': east,
  };
}

/// Canonical municipality metadata used by report submission.
class MunicipalityModel {
  final String id;
  final String name;
  final String province;
  final double? centerLat;
  final double? centerLng;
  final MunicipalityBounds? bounds;
  final MunicipalityBoundary? boundary;
  final String? psgcCode;
  final bool isDefault;
  final bool isSupported;

  const MunicipalityModel({
    required this.id,
    required this.name,
    required this.province,
    this.centerLat,
    this.centerLng,
    this.bounds,
    this.boundary,
    this.psgcCode,
    this.isDefault = false,
    this.isSupported = true,
  });

  factory MunicipalityModel.fromJson(Map<String, dynamic> json) {
    final rawBounds = json['bounds'];
    final boundary = MunicipalityBoundary.tryParse(json['boundary']);
    return MunicipalityModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      province: json['province']?.toString() ?? '',
      centerLat: (json['center_lat'] as num?)?.toDouble(),
      centerLng: (json['center_lng'] as num?)?.toDouble(),
      bounds: rawBounds is Map
          ? MunicipalityBounds.fromJson(Map<String, dynamic>.from(rawBounds))
          : null,
      boundary: boundary,
      psgcCode: json['psgc_code']?.toString(),
      isDefault: json['is_default'] == true,
      isSupported: json['is_supported'] != false,
    );
  }

  bool get hasUsableBounds => bounds?.isValid == true;
  bool get hasUsableBoundary => boundary != null && hasUsableBounds;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'province': province,
    'center_lat': centerLat,
    'center_lng': centerLng,
    'bounds': bounds?.toJson(),
    'boundary': boundary?.toGeoJson(),
    'psgc_code': psgcCode,
    'is_default': isDefault,
    'is_supported': isSupported,
  };
}

class MunicipalitiesResponse {
  final List<MunicipalityModel> municipalities;
  final int count;
  final String defaultMunicipalityId;

  const MunicipalitiesResponse({
    required this.municipalities,
    required this.count,
    required this.defaultMunicipalityId,
  });

  factory MunicipalitiesResponse.fromJson(Map<String, dynamic> json) {
    final items = json['municipalities'] as List<dynamic>? ?? const [];
    return MunicipalitiesResponse(
      municipalities: items
          .map(
            (item) => MunicipalityModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(growable: false),
      count: (json['count'] as num?)?.toInt() ?? items.length,
      defaultMunicipalityId:
          json['default_municipality_id']?.toString() ?? 'urdaneta',
    );
  }
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

/// Optional named-place context for a report location.
class NearbyLandmarkModel {
  final String name;
  final double distanceMeters;
  final String? category;

  const NearbyLandmarkModel({
    required this.name,
    required this.distanceMeters,
    this.category,
  });

  factory NearbyLandmarkModel.fromJson(Map<String, dynamic> json) {
    return NearbyLandmarkModel(
      name: json['name']?.toString().trim() ?? '',
      distanceMeters:
          (json['distance_meters'] as num?)?.toDouble() ?? double.infinity,
      category: json['category']?.toString(),
    );
  }
}
