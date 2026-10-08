import 'entities/auth_tokens.dart';

/// Repository interface for session/token management.
///
/// Implemented by [AuthSessionRepositoryImpl] in the data layer.
/// Used by interceptors and use cases to manage authentication state.
abstract interface class AuthSessionRepository {
  /// Check if user is currently authenticated (has valid tokens)
  Future<bool> get isAuthenticated;

  /// Triggers a token refresh using the existing refresh token
  Future<String?> refreshToken();

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

  /// Replace a session only while it still owns the refresh token used by a
  /// refresh request. Prevents late refresh responses from restoring a logged
  /// out or switched account.
  Future<bool> saveTokensIfRefreshTokenMatches({
    required String expectedRefreshToken,
    required String accessToken,
    required String refreshToken,
  });

  /// Clear only the session that failed refresh. A concurrent login may have
  /// already installed another account's token.
  Future<bool> clearSessionIfRefreshTokenMatches(String? expectedRefreshToken);

  /// Clear all session data (logout)
  Future<void> clearSession();
}
