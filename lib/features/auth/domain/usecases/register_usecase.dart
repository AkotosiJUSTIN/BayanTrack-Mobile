import '../../../../core/domain/result.dart';
import '../auth_repository.dart';
import '../auth_session_repository.dart';
import '../entities/user.dart';

/// Use case for registering a new user.
///
/// Registers with the backend, saves tokens, and returns the user profile.
/// Mirrors [LoginUseCase] flow since backend returns tokens on registration.
class RegisterUseCase {
  final AuthRepository _authRepository;
  final AuthSessionRepository _sessionRepository;

  RegisterUseCase({
    required AuthRepository authRepository,
    required AuthSessionRepository sessionRepository,
  }) : _authRepository = authRepository,
       _sessionRepository = sessionRepository;

  Future<Result<User>> call({
    required String email,
    required String password,
    required String passwordConfirm,
    required String firstName,
    required String lastName,
    required String barangayId,
  }) async {
    // Step 1: Register with backend (returns tokens)
    final tokensResult = await _authRepository.register(
      email: email,
      password: password,
      passwordConfirm: passwordConfirm,
      firstName: firstName,
      lastName: lastName,
      barangayId: barangayId,
    );

    // Step 2: Check if registration succeeded
    if (tokensResult.isFailure) {
      return Err(tokensResult.failureOrNull!);
    }

    // Step 3: Save tokens (auto-login)
    final tokens = tokensResult.dataOrNull!;
    await _sessionRepository.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );

    // Step 4: Fetch user profile
    return _authRepository.getProfile();
  }
}
