import '../../../../core/domain/result.dart';
import '../auth_repository.dart';
import '../auth_session_repository.dart';

/// Use case for logging out a user.
///
/// Notifies backend and clears local session.
class LogoutUseCase {
  final AuthRepository _authRepository;
  final AuthSessionRepository _sessionRepository;

  LogoutUseCase({
    required AuthRepository authRepository,
    required AuthSessionRepository sessionRepository,
  }) : _authRepository = authRepository,
       _sessionRepository = sessionRepository;

  Future<Result<void>> call() async {
    // Get refresh token for backend logout
    final refreshToken = await _sessionRepository.getRefreshToken();

    // Clear local session first (even if backend call fails)
    await _sessionRepository.clearSession();

    // Notify backend (best effort - don't fail if this errors)
    if (refreshToken != null) {
      final result = await _authRepository.logout(refreshToken);
      // Log but don't fail on backend error
      if (result.isFailure) {
        // Silent fail - user is already logged out locally
      }
    }

    return const Success(null);
  }
}
