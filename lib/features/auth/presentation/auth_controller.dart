import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/storage/secure_storage_provider.dart';
import '../data/auth_models.dart';
import '../data/auth_repository.dart';

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
  const AuthSuccess([this.message]);
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

@riverpod
class AuthController extends _$AuthController {
  @override
  AuthState build() => const AuthIdle();

  /// Check for existing session
  Future<void> checkAuth() async {
    state = const AuthLoading();
    try {
      final accessToken = await ref
          .read(tokenStorageProvider.notifier)
          .getAccessToken();
      if (accessToken != null) {
        state = const AuthSuccess();
      } else {
        state = const AuthIdle();
      }
    } catch (e) {
      state = const AuthIdle();
    }
  }

  /// Login user and save tokens
  Future<bool> login(String email, String password) async {
    state = const AuthLoading();
    try {
      final repository = ref.read(authRepositoryProvider);
      final request = LoginRequest(email: email, password: password);
      final response = await repository.login(request);

      // Save tokens to secure storage with retry for algorithm change issues
      await _saveTokensWithRetry(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );

      state = const AuthSuccess('Login successful');
      return true;
    } on DioException catch (e) {
      state = AuthError(_extractErrorMessage(e));
      return false;
    } catch (e) {
      state = AuthError(e.toString());
      return false;
    }
  }

  /// Save tokens with retry logic to handle FlutterSecureStorage algorithm changes
  Future<void> _saveTokensWithRetry({
    required String accessToken,
    required String refreshToken,
    int maxRetries = 3,
  }) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        await ref
            .read(tokenStorageProvider.notifier)
            .saveTokens(accessToken: accessToken, refreshToken: refreshToken);
        return; // Success
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) {
          // Log error but don't fail login - tokens will be requested again on next app open
          // ignore: avoid_print
          print(
            'Warning: Failed to save tokens after $maxRetries attempts: $e',
          );
          return; // Continue without throwing - login was successful
        }
        // Wait a bit before retry (allows secure storage migration to complete)
        await Future.delayed(Duration(milliseconds: 100 * attempts));
      }
    }
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
    try {
      final repository = ref.read(authRepositoryProvider);
      final request = RegisterRequest(
        email: email,
        password: password,
        passwordConfirm: passwordConfirm,
        firstName: firstName,
        lastName: lastName,
      );
      await repository.register(request);
      state = const AuthSuccess('Registration successful. Please login.');
      return true;
    } on DioException catch (e) {
      state = AuthError(_extractErrorMessage(e));
      return false;
    } catch (e) {
      state = AuthError(e.toString());
      return false;
    }
  }

  /// Request password reset email
  Future<bool> forgotPassword(String email) async {
    state = const AuthLoading();
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.forgotPassword(email);
      state = const AuthSuccess('Password reset email sent');
      return true;
    } on DioException catch (e) {
      state = AuthError(_extractErrorMessage(e));
      return false;
    } catch (e) {
      state = AuthError(e.toString());
      return false;
    }
  }

  /// Logout and clear tokens
  Future<void> logout() async {
    state = const AuthLoading();
    try {
      final repository = ref.read(authRepositoryProvider);
      final refreshToken = await ref
          .read(tokenStorageProvider.notifier)
          .getRefreshToken();
      if (refreshToken != null) {
        await repository.logout(refreshToken);
      }
    } catch (_) {
      // Ignore errors, still clear tokens
    }
    await ref.read(tokenStorageProvider.notifier).clearTokens();
    state = const AuthIdle();
  }

  /// Reset state to idle
  void resetState() {
    state = const AuthIdle();
  }

  /// Extract user-friendly error message from DioException
  String _extractErrorMessage(DioException e) {
    if (e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        // Check common error field names
        if (data.containsKey('detail')) return data['detail'].toString();
        if (data.containsKey('message')) return data['message'].toString();
        if (data.containsKey('error')) return data['error'].toString();
        // Check for field-specific errors
        if (data.containsKey('email')) return 'Email: ${data['email']}';
        if (data.containsKey('password')) {
          return 'Password: ${data['password']}';
        }
      }
    }

    // Network-level errors
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet.';
      case DioExceptionType.connectionError:
        return 'Unable to connect. Check your internet connection.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) return 'Invalid email or password';
        if (statusCode == 403) return 'Access denied';
        if (statusCode == 404) return 'Service not found';
        if (statusCode == 422) return 'Invalid input data';
        if (statusCode != null && statusCode >= 500) {
          return 'Server error. Please try again later.';
        }
        return 'Request failed';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
