import 'package:flutter/foundation.dart';
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
    debugPrint('[LoginUseCase] Step 1: Calling login API...');
    final tokensResult = await _authRepository.login(
      email: email,
      password: password,
    );

    // Step 2: Check if login succeeded
    if (tokensResult.isFailure) {
      debugPrint(
        '[LoginUseCase] Step 2: Login FAILED - ${tokensResult.failureOrNull}',
      );
      return Err(tokensResult.failureOrNull!);
    }

    debugPrint('[LoginUseCase] Step 2: Login SUCCESS - got tokens');

    // Step 3: Save tokens
    final tokens = tokensResult.dataOrNull!;
    debugPrint(
      '[LoginUseCase] Step 3: Saving tokens (access=${tokens.accessToken.substring(0, 20)}...)',
    );
    await _sessionRepository.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    debugPrint('[LoginUseCase] Step 3: Tokens saved');

    // Step 4: Fetch user profile
    debugPrint('[LoginUseCase] Step 4: Fetching profile...');
    final profileResult = await _authRepository.getProfile();
    if (profileResult.isFailure) {
      debugPrint(
        '[LoginUseCase] Step 4: Profile fetch FAILED - ${profileResult.failureOrNull}',
      );
    } else {
      debugPrint(
        '[LoginUseCase] Step 4: Profile fetch SUCCESS - ${profileResult.dataOrNull}',
      );
    }
    return profileResult;
  }
}
