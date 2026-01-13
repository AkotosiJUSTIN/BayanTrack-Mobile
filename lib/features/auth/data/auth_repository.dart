import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_provider.dart';
import 'auth_models.dart';

part 'auth_repository.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  return AuthRepository(dio);
}

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: request.toJson(),
      );
      return LoginResponse.fromJson(response.data);
    } catch (e) {
      // Handle DioError specifically if needed, rethrow for now
      rethrow;
    }
  }

  Future<void> register(RegisterRequest request) async {
    await _dio.post(ApiConstants.register, data: request.toJson());
  }
}
