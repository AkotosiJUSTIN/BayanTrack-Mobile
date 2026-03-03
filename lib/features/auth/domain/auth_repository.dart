import '../../../core/domain/result.dart';
import '../data/auth_models.dart';
import 'entities/user.dart';
import 'entities/auth_tokens.dart';

/// Repository interface for authentication operations.
///
/// Implemented by [AuthRepositoryImpl] in the data layer.
/// All methods return [Result<T>] for explicit error handling.
abstract interface class AuthRepository {
  /// Authenticate user and return tokens (does NOT save tokens)
  Future<Result<AuthTokens>> login({
    required String email,
    required String password,
  });

  /// Register new user and return auth tokens
  Future<Result<AuthTokens>> register({
    required String email,
    required String password,
    required String passwordConfirm,
    required String firstName,
    required String lastName,
  });

  /// Refresh access token using refresh token
  Future<Result<AuthTokens>> refreshToken(String refreshToken);

  /// Logout (invalidate token on backend)
  Future<Result<void>> logout(String refreshToken);

  /// Logout from all devices
  Future<Result<void>> logoutAll();

  /// Get current user profile
  Future<Result<User>> getProfile();

  /// Update user profile
  Future<Result<User>> updateProfile({
    String? firstName,
    String? lastName,
    String? avatarUrl,
  });

  /// Change password
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirm,
  });

  /// Request password reset email
  Future<Result<void>> forgotPassword(String email);

  /// Verify OTP sent to email and return reset token
  Future<Result<String>> verifyResetOtp({
    required String email,
    required String otp,
  });

  /// Reset password with verified reset token
  Future<Result<void>> resetPassword({
    required String resetToken,
    required String newPassword,
    required String newPasswordConfirm,
  });

  /// Get list of barangays for location picker
  Future<Result<List<BarangayModel>>> getBarangays();
}
