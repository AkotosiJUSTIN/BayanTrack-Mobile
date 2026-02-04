import '../../../../core/domain/result.dart';
import '../../../../core/domain/failures.dart';
import '../auth_session_repository.dart';
import '../entities/user.dart';
import '../auth_repository.dart';

/// Use case for loading session on app startup.
///
/// Checks if valid tokens exist and fetches user profile if authenticated.
class LoadSessionUseCase {
  final AuthSessionRepository _sessionRepository;
  final AuthRepository _authRepository;

  LoadSessionUseCase({
    required AuthSessionRepository sessionRepository,
    required AuthRepository authRepository,
  }) : _sessionRepository = sessionRepository,
       _authRepository = authRepository;

  /// Returns the user if authenticated, or null if not logged in.
  /// Returns a Failure only on actual errors (network, etc.)
  Future<Result<User?>> call() async {
    final isAuth = await _sessionRepository.isAuthenticated;

    if (!isAuth) {
      return const Success(null); // Not logged in, but not an error
    }

    // Try to fetch profile to validate tokens
    final profileResult = await _authRepository.getProfile();

    return profileResult.when(
      success: (user) => Success(user),
      failure: (failure) {
        // If auth failure, clear session and return null (not logged in)
        if (failure is AuthFailure) {
          _sessionRepository.clearSession();
          return const Success(null);
        }
        // For other failures (network), propagate the error
        return Err(failure);
      },
    );
  }
}
