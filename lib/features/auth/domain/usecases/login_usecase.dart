import '../../../../core/domain/result.dart';
import '../auth_repository.dart';
import '../auth_session_repository.dart';
import '../entities/user.dart';

/// Use case for logging in a user.
///
/// Authenticates with the backend, saves tokens, and returns the user profile.
class LoginUseCase {
  final AuthRepository _authRepository;
  final AuthSessionRepository _sessionRepository;

  LoginUseCase({
    required AuthRepository authRepository,
    required AuthSessionRepository sessionRepository,
  }) : _authRepository = authRepository,
       _sessionRepository = sessionRepository;

  Future<Result<User>> call({
    required String email,
    required String password,
  }) async {
    // Step 1: Authenticate with backend
    final tokensResult = await _authRepository.login(
      email: email,
      password: password,
    );

    // Step 2: Check if login succeeded
    if (tokensResult.isFailure) {
      return Err(tokensResult.failureOrNull!);
    }

    // Step 3: Save tokens
    final tokens = tokensResult.dataOrNull!;
    await _sessionRepository.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );

    // Step 4: Fetch user profile
    return _authRepository.getProfile();
  }
}
