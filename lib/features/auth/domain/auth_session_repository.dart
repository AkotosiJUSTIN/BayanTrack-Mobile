import 'entities/auth_tokens.dart';

/// Repository interface for session/token management.
///
/// Implemented by [AuthSessionRepositoryImpl] in the data layer.
/// Used by interceptors and use cases to manage authentication state.
abstract interface class AuthSessionRepository {
  /// Check if user is currently authenticated (has valid tokens)
  Future<bool> get isAuthenticated;

  /// Stream of authentication state changes
  /// Emits `false` when session is cleared (e.g., after failed refresh)
  Stream<bool> get authStateChanges;

  /// Get stored tokens
  Future<AuthTokens?> getTokens();

  /// Get access token only
  Future<String?> getAccessToken();

  /// Get refresh token only
  Future<String?> getRefreshToken();

  /// Save tokens to secure storage
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  /// Clear all session data (logout)
  Future<void> clearSession();
}
