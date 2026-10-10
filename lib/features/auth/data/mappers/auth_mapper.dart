import '../../domain/entities/user.dart';
import '../../domain/entities/auth_tokens.dart';
import '../auth_models.dart';

/// Mapper for converting between DTOs and domain entities.
class AuthMapper {
  AuthMapper._(); // Prevent instantiation

  /// Map [LoginResponse] to [AuthTokens]
  static AuthTokens tokensFromLoginResponse(LoginResponse response) {
    return AuthTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
  }

  /// Map [RefreshTokenResponse] to [AuthTokens]
  static AuthTokens tokensFromRefreshResponse(RefreshTokenResponse response) {
    return AuthTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
  }

  static User userFromProfile(UserProfile profile) {
    return User(
      id: profile.id,
      email: profile.email,
      firstName: profile.firstName,
      lastName: profile.lastName,
      phone: profile.phone,
      avatarUrl: profile.avatarUrl,
      avatarRevision: profile.avatarRevision,
      avatarStorageStatus: profile.avatarStorageStatus,
      profileRevision: profile.profileRevision,
      role: UserRole.fromString(profile.role),
      isActive: profile.isActive,
      createdAt: _parseDateTime(profile.createdAt),
      updatedAt: _parseDateTime(profile.updatedAt),
      passwordChangedAt: _parseDateTime(profile.passwordChangedAt),
      passwordExpiresAt: _parseDateTime(profile.passwordExpiresAt),
      passwordDaysRemaining: profile.passwordDaysRemaining,
      passwordWarningLevel: profile.passwordWarningLevel,
      passwordExpired: profile.passwordExpired,
      passwordChangeRequired: profile.passwordChangeRequired,
    );
  }

  static DateTime? _parseDateTime(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  static UserProfile profileFromUser(User user) => UserProfile(
    id: user.id,
    email: user.email,
    firstName: user.firstName,
    lastName: user.lastName,
    phone: user.phone,
    avatarUrl: user.avatarUrl,
    avatarRevision: user.avatarRevision,
    avatarStorageStatus: user.avatarStorageStatus,
    profileRevision: user.profileRevision,
    role: user.role.toApiString(),
    isActive: user.isActive,
    createdAt: user.createdAt?.toUtc().toIso8601String(),
    updatedAt: user.updatedAt?.toUtc().toIso8601String(),
    passwordChangedAt: user.passwordChangedAt?.toUtc().toIso8601String(),
    passwordExpiresAt: user.passwordExpiresAt?.toUtc().toIso8601String(),
    passwordDaysRemaining: user.passwordDaysRemaining,
    passwordWarningLevel: user.passwordWarningLevel,
    passwordExpired: user.passwordExpired,
    passwordChangeRequired: user.passwordChangeRequired,
  );
}
