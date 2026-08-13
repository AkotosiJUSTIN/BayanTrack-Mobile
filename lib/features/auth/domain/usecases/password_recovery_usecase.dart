import '../../../../core/domain/result.dart';
import '../auth_repository.dart';

/// Owns the password-recovery workflow exposed to presentation controllers.
class PasswordRecoveryUseCase {
  const PasswordRecoveryUseCase({required AuthRepository repository})
    : _repository = repository;

  final AuthRepository _repository;

  Future<Result<void>> requestReset(String email) {
    return _repository.forgotPassword(email);
  }

  Future<Result<String>> verifyOtp({
    required String email,
    required String otp,
  }) {
    return _repository.verifyResetOtp(email: email, otp: otp);
  }

  Future<Result<void>> resetPassword({
    required String resetToken,
    required String newPassword,
    required String newPasswordConfirm,
  }) {
    return _repository.resetPassword(
      resetToken: resetToken,
      newPassword: newPassword,
      newPasswordConfirm: newPasswordConfirm,
    );
  }
}
