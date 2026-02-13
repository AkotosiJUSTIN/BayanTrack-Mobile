import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../auth_di.dart';
import '../domain/entities/user.dart';
import '../../../core/domain/failures.dart';
import '../../kyc/presentation/kyc_controller.dart';

part 'auth_controller.g.dart';

/// Sealed state for authentication UI
sealed class AuthState {
  const AuthState();
}

class AuthIdle extends AuthState {
  const AuthIdle();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  final String? message;
  final User? user;
  const AuthSuccess([this.message, this.user]);
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

/// AuthController - ViewModel for authentication flows.
///
/// Uses Clean Architecture use cases for all operations.
/// Does NOT directly access repositories or storage.
@riverpod
class AuthController extends _$AuthController {
  @override
  AuthState build() => const AuthIdle();

  /// Check for existing session on app startup
  Future<void> checkAuth() async {
    state = const AuthLoading();
    try {
      final loadSession = ref.read(loadSessionUseCaseProvider);
      final result = await loadSession();

      result.when(
        success: (user) {
          if (user != null) {
            state = AuthSuccess('Session restored', user);
          } else {
            state = const AuthIdle();
          }
        },
        failure: (failure) {
          // On failure, just go to idle state (not logged in)
          state = const AuthIdle();
        },
      );
    } catch (e) {
      state = const AuthIdle();
    }
  }

  /// Login user
  Future<bool> login(String email, String password) async {
    state = const AuthLoading();

    final loginUseCase = ref.read(loginUseCaseProvider);
    final result = await loginUseCase(email: email, password: password);

    return result.when(
      success: (user) {
        // Fetch KYC status after successful login
        try {
          ref.invalidate(kycStatusControllerProvider);
        } catch (_) {
          // Ignore KYC fetch errors, don't fail login
        }

        state = AuthSuccess('Login successful', user);
        return true;
      },
      failure: (failure) {
        state = AuthError(_failureToMessage(failure));
        return false;
      },
    );
  }

  /// Register new user
  Future<bool> register({
    required String email,
    required String password,
    required String passwordConfirm,
    required String firstName,
    required String lastName,
  }) async {
    state = const AuthLoading();

    final registerUseCase = ref.read(registerUseCaseProvider);
    final result = await registerUseCase(
      email: email,
      password: password,
      passwordConfirm: passwordConfirm,
      firstName: firstName,
      lastName: lastName,
    );

    return result.when(
      success: (user) {
        // Auto-login: tokens are saved by RegisterUseCase
        try {
          ref.invalidate(kycStatusControllerProvider);
        } catch (_) {
          // Ignore KYC fetch errors, don't fail registration
        }
        state = AuthSuccess('Registration successful', user);
        return true;
      },
      failure: (failure) {
        state = AuthError(_failureToMessage(failure));
        return false;
      },
    );
  }

  /// Request password reset email
  Future<bool> forgotPassword(String email) async {
    state = const AuthLoading();

    final authRepository = ref.read(authRepositoryProvider);
    final result = await authRepository.forgotPassword(email);

    return result.when(
      success: (_) {
        state = const AuthSuccess('Password reset email sent');
        return true;
      },
      failure: (failure) {
        state = AuthError(_failureToMessage(failure));
        return false;
      },
    );
  }

  /// Logout - INSTANT UI response
  void logout() {
    // Set state to AuthIdle IMMEDIATELY (synchronous) for instant UI
    state = const AuthIdle();

    // Do all cleanup in background - don't block UI
    _performLogoutAsync();
  }

  /// Background cleanup after logout
  Future<void> _performLogoutAsync() async {
    try {
      final logoutUseCase = ref.read(logoutUseCaseProvider);
      await logoutUseCase();
    } catch (_) {
      // Ignore all errors - logout UI already succeeded
    }
  }

  /// Reset state to idle
  void resetState() {
    state = const AuthIdle();
  }

  /// Convert domain Failure to user-friendly message
  String _failureToMessage(Failure failure) {
    return switch (failure) {
      AuthFailure(:final message) => message,
      ValidationFailure(:final message, :final fieldErrors) =>
        fieldErrors != null && fieldErrors.isNotEmpty
            ? fieldErrors.entries.map((e) => '${e.key}: ${e.value}').join('\n')
            : message,
      NetworkFailure(:final message) => message,
      ServerFailure(:final message) => message,
      NotFoundFailure(:final message) => message,
      CacheFailure(:final message) => message,
      UnknownFailure(:final message) => message,
    };
  }
}
