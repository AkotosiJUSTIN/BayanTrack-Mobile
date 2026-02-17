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
    // Get refresh token for backend logout.
    final refreshToken = await _sessionRepository.getRefreshToken();

    // Notify backend first while access token is still available for auth header.
    if (refreshToken != null) {
      await _authRepository.logout(refreshToken);
    }

    // Always clear local session regardless of backend result.
    await _sessionRepository.clearSession();

    return const Success(null);
  }
}
