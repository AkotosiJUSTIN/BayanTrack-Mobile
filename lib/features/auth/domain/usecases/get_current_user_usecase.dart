import '../../../../core/domain/result.dart';
import '../auth_repository.dart';
import '../entities/user.dart';

/// Use case for getting the current user's profile.
class GetCurrentUserUseCase {
  final AuthRepository _authRepository;

  GetCurrentUserUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  Future<Result<User>> call() {
    return _authRepository.getProfile();
  }
}
