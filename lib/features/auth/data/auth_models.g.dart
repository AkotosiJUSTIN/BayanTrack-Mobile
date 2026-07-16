// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) =>
    _LoginRequest(
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$LoginRequestToJson(_LoginRequest instance) =>
    <String, dynamic>{'email': instance.email, 'password': instance.password};

_LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    _LoginResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      user: json['user'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$LoginResponseToJson(_LoginResponse instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'user': instance.user,
    };

_RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) =>
    _RegisterRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      passwordConfirm: json['password_confirm'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      barangayId: json['barangay_id'] as String,
      role: json['role'] as String? ?? 'citizen',
    );

Map<String, dynamic> _$RegisterRequestToJson(_RegisterRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'password_confirm': instance.passwordConfirm,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'barangay_id': instance.barangayId,
      'role': instance.role,
    };

_RefreshTokenRequest _$RefreshTokenRequestFromJson(Map<String, dynamic> json) =>
    _RefreshTokenRequest(refreshToken: json['refresh_token'] as String);

Map<String, dynamic> _$RefreshTokenRequestToJson(
  _RefreshTokenRequest instance,
) => <String, dynamic>{'refresh_token': instance.refreshToken};

_RefreshTokenResponse _$RefreshTokenResponseFromJson(
  Map<String, dynamic> json,
) => _RefreshTokenResponse(
  accessToken: json['access_token'] as String,
  refreshToken: json['refresh_token'] as String,
);

Map<String, dynamic> _$RefreshTokenResponseToJson(
  _RefreshTokenResponse instance,
) => <String, dynamic>{
  'access_token': instance.accessToken,
  'refresh_token': instance.refreshToken,
};

_UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => _UserProfile(
  id: _readUserId(json, 'id') as String,
  email: json['email'] as String,
  firstName: json['first_name'] as String? ?? '',
  lastName: json['last_name'] as String? ?? '',
  avatarUrl: json['avatar_url'] as String?,
  role: json['role'] as String? ?? 'citizen',
  isActive: json['is_active'] as bool? ?? true,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$UserProfileToJson(_UserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'avatar_url': instance.avatarUrl,
      'role': instance.role,
      'is_active': instance.isActive,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

_ProfileUpdateRequest _$ProfileUpdateRequestFromJson(
  Map<String, dynamic> json,
) => _ProfileUpdateRequest(
  firstName: json['first_name'] as String?,
  lastName: json['last_name'] as String?,
  avatarUrl: json['avatar_url'] as String?,
);

Map<String, dynamic> _$ProfileUpdateRequestToJson(
  _ProfileUpdateRequest instance,
) => <String, dynamic>{
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'avatar_url': ?instance.avatarUrl,
};

_ChangePasswordRequest _$ChangePasswordRequestFromJson(
  Map<String, dynamic> json,
) => _ChangePasswordRequest(
  currentPassword: json['old_password'] as String,
  newPassword: json['new_password'] as String,
  newPasswordConfirm: json['new_password_confirm'] as String,
);

Map<String, dynamic> _$ChangePasswordRequestToJson(
  _ChangePasswordRequest instance,
) => <String, dynamic>{
  'old_password': instance.currentPassword,
  'new_password': instance.newPassword,
  'new_password_confirm': instance.newPasswordConfirm,
};

_ForgotPasswordRequest _$ForgotPasswordRequestFromJson(
  Map<String, dynamic> json,
) => _ForgotPasswordRequest(
  email: json['email'] as String,
  platform: json['platform'] as String? ?? 'mobile',
);

Map<String, dynamic> _$ForgotPasswordRequestToJson(
  _ForgotPasswordRequest instance,
) => <String, dynamic>{'email': instance.email, 'platform': instance.platform};

_ResetPasswordRequest _$ResetPasswordRequestFromJson(
  Map<String, dynamic> json,
) => _ResetPasswordRequest(
  token: json['token'] as String,
  newPassword: json['new_password'] as String,
  newPasswordConfirm: json['new_password_confirm'] as String,
);

Map<String, dynamic> _$ResetPasswordRequestToJson(
  _ResetPasswordRequest instance,
) => <String, dynamic>{
  'token': instance.token,
  'new_password': instance.newPassword,
  'new_password_confirm': instance.newPasswordConfirm,
};

_BarangayModel _$BarangayModelFromJson(Map<String, dynamic> json) =>
    _BarangayModel(
      id: json['id'] as String,
      name: json['name'] as String,
      centerLat: (json['center_lat'] as num).toDouble(),
      centerLng: (json['center_lng'] as num).toDouble(),
      municipalityId: json['municipality_id'] as String? ?? 'urdaneta',
      municipality: json['municipality'] as String?,
      province: json['province'] as String?,
    );

Map<String, dynamic> _$BarangayModelToJson(_BarangayModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'center_lat': instance.centerLat,
      'center_lng': instance.centerLng,
      'municipality_id': instance.municipalityId,
      'municipality': instance.municipality,
      'province': instance.province,
    };

_BarangaysResponse _$BarangaysResponseFromJson(Map<String, dynamic> json) =>
    _BarangaysResponse(
      barangays: (json['barangays'] as List<dynamic>)
          .map((e) => BarangayModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$BarangaysResponseToJson(_BarangaysResponse instance) =>
    <String, dynamic>{'barangays': instance.barangays, 'count': instance.count};
