import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Provider;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/network/dio_provider.dart';
import '../../core/providers/connectivity_provider.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/auth_session_repository_impl.dart';
import 'domain/auth_repository.dart';
import 'domain/auth_session_repository.dart';
import 'domain/usecases/get_current_user_usecase.dart';
import 'domain/usecases/load_session_usecase.dart';
import 'domain/usecases/login_usecase.dart';
import 'domain/usecases/logout_usecase.dart';
import 'domain/usecases/password_recovery_usecase.dart';
import 'domain/usecases/profile_mutation_usecase.dart';
import 'domain/usecases/register_usecase.dart';

part 'auth_di.g.dart';

// ==================== STORAGE ====================

@Riverpod(keepAlive: true)
FlutterSecureStorage secureStorage(Ref ref) {
  return const FlutterSecureStorage();
}

// ==================== REPOSITORIES ====================

@Riverpod(keepAlive: true)
AuthSessionRepository authSessionRepository(Ref ref) {
  final storage = ref.watch(secureStorageProvider);
  return AuthSessionRepositoryImpl(storage);
}

@riverpod
AuthRepository authRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  return AuthRepositoryImpl(
    dio,
    sessionRepository: ref.watch(authSessionRepositoryProvider),
  );
}

// ==================== USE CASES ====================

@riverpod
LoginUseCase loginUseCase(Ref ref) {
  return LoginUseCase(
    authRepository: ref.watch(authRepositoryProvider),
    sessionRepository: ref.watch(authSessionRepositoryProvider),
  );
}

@riverpod
RegisterUseCase registerUseCase(Ref ref) {
  return RegisterUseCase(
    authRepository: ref.watch(authRepositoryProvider),
    sessionRepository: ref.watch(authSessionRepositoryProvider),
  );
}

@riverpod
LogoutUseCase logoutUseCase(Ref ref) {
  return LogoutUseCase(
    authRepository: ref.watch(authRepositoryProvider),
    sessionRepository: ref.watch(authSessionRepositoryProvider),
  );
}

@riverpod
GetCurrentUserUseCase getCurrentUserUseCase(Ref ref) {
  return GetCurrentUserUseCase(
    authRepository: ref.watch(authRepositoryProvider),
  );
}

@riverpod
LoadSessionUseCase loadSessionUseCase(Ref ref) {
  final isOnline = ref.watch(isOnlineProvider);
  return LoadSessionUseCase(
    sessionRepository: ref.watch(authSessionRepositoryProvider),
    authRepository: ref.watch(authRepositoryProvider),
    isOnline: () => isOnline,
  );
}

final passwordRecoveryUseCaseProvider = Provider<PasswordRecoveryUseCase>((
  ref,
) {
  return PasswordRecoveryUseCase(repository: ref.watch(authRepositoryProvider));
});

final profileMutationUseCaseProvider = Provider<ProfileMutationUseCase>((ref) {
  return ProfileMutationUseCase(repository: ref.watch(authRepositoryProvider));
});
