/// Authenticated session with tokens.
///
/// Returned by login/register operations.
class AuthTokens {
  final String accessToken;
  final String refreshToken;

  const AuthTokens({required this.accessToken, required this.refreshToken});
}
