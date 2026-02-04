import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../constants/api_constants.dart';
import '../../features/auth/auth_di.dart';
import 'auth_interceptor.dart';

part 'dio_provider.g.dart';

/// Creates a raw Dio instance without auth interceptor.
/// Used for token refresh to avoid circular dependency.
@riverpod
Dio dioRaw(Ref ref) {
  return Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
}

/// Main Dio instance with auth interceptor for authenticated requests.
@riverpod
Dio dio(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Use raw dio for refresh to avoid circular dependency
  final rawDio = ref.watch(dioRawProvider);

  // Inject AuthSessionRepository for Clean Architecture compliance
  final sessionRepository = ref.watch(authSessionRepositoryProvider);

  dio.interceptors.addAll([
    AuthInterceptor(rawDio, sessionRepository),
    // NOTE: LogInterceptor removed - it can expose sensitive data from server errors
  ]);

  return dio;
}
