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
  final bool Function() _isOnline;

  LoadSessionUseCase({
    required AuthSessionRepository sessionRepository,
    required AuthRepository authRepository,
    bool Function()? isOnline,
  }) : _sessionRepository = sessionRepository,
       _authRepository = authRepository,
       _isOnline = isOnline ?? (() => true);

  /// Returns the user if authenticated, or null if not logged in.
  /// Returns a Failure only on actual errors (network, etc.)
  Future<Result<User?>> call() async {
    final isAuth = await _sessionRepository.isAuthenticated;

    if (!isAuth) {
      return const Success(null); // Not logged in, but not an error
    }

    if (!_isOnline()) {
      final cachedUser = await _sessionRepository.getCachedUser();
      return cachedUser == null
          ? const Err(NetworkFailure())
          : Success(cachedUser);
    }

    // Try to fetch profile to validate tokens
    final refreshToken = await _sessionRepository.getRefreshToken();
    final profileResult = await _authRepository.getProfile();

    return profileResult.when(
      success: (user) async => Success(user),
      failure: (failure) async {
        // If auth failure, clear session and return null (not logged in)
        if (failure is AuthFailure) {
          await _sessionRepository.clearSessionIfRefreshTokenMatches(
            refreshToken,
          );
          return const Success(null);
        }
        if (failure is NetworkFailure || failure is ServerFailure) {
          final cachedUser = await _sessionRepository.getCachedUser();
          if (cachedUser != null) return Success(cachedUser);
        }
        return Err(failure);
      },
    );
  }
}
