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

  /// Map [UserProfile] DTO to [User] entity
  static User userFromProfile(UserProfile profile) {
    return User(
      id: profile.id,
      email: profile.email,
      firstName: profile.firstName,
      lastName: profile.lastName,
      role: UserRole.fromString(profile.role),
      isActive: profile.isActive,
      createdAt: _parseDateTime(profile.createdAt),
      updatedAt: _parseDateTime(profile.updatedAt),
    );
  }

  static DateTime? _parseDateTime(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
