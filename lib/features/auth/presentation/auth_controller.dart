import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/auth_models.dart';
import '../data/auth_repository.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {
    // Initial state is void (idle)
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      final request = LoginRequest(email: email, password: password);
      final _ = await repository.login(request);
      // Here you would save the token to secure storage
      // await ref.read(secureStorageProvider).write(key: 'token', value: response.accessToken);
    });
  }
}
