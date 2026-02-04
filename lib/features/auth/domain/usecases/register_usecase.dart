import '../../../../core/domain/result.dart';
import '../auth_repository.dart';

/// Use case for registering a new user.
class RegisterUseCase {
  final AuthRepository _authRepository;

  RegisterUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  Future<Result<void>> call({
    required String email,
    required String password,
    required String passwordConfirm,
    required String firstName,
    required String lastName,
  }) {
    return _authRepository.register(
      email: email,
      password: password,
      passwordConfirm: passwordConfirm,
      firstName: firstName,
      lastName: lastName,
    );
  }
}
