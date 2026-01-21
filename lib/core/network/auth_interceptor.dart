import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

/// Interceptor that handles JWT authentication:
/// - Injects Authorization header on all requests
/// - Catches 401 errors and attempts token refresh
/// - Clears tokens on refresh failure
class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final FlutterSecureStorage _storage;
  bool _isRefreshing = false;
  final _pendingRequests =
      <({RequestOptions options, ErrorInterceptorHandler handler})>[];

  AuthInterceptor(this._dio)
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        );

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header for public endpoints
    final publicEndpoints = [
      ApiConstants.login,
      ApiConstants.register,
      ApiConstants.forgotPassword,
      ApiConstants.resetPassword,
      ApiConstants.refresh,
    ];

    if (publicEndpoints.any((endpoint) => options.path.contains(endpoint))) {
      return handler.next(options);
    }

    // Inject access token
    final accessToken = await _storage.read(key: ApiConstants.accessTokenKey);

    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Only handle 401 Unauthorized
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Don't retry refresh endpoint
    if (err.requestOptions.path.contains(ApiConstants.refresh)) {
      await _clearTokensAndReject(err, handler);
      return;
    }

    // Queue requests while refreshing
    if (_isRefreshing) {
      _pendingRequests.add((options: err.requestOptions, handler: handler));
      return;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await _storage.read(key: ApiConstants.refreshTokenKey);

      if (refreshToken == null) {
        await _clearTokensAndReject(err, handler);
        return;
      }

      // Attempt token refresh
      final response = await _dio.post(
        ApiConstants.refresh,
        data: {'refresh_token': refreshToken},
      );

      final newAccessToken = response.data['access_token'] as String;
      final newRefreshToken = response.data['refresh_token'] as String;

      await _storage.write(key: ApiConstants.accessTokenKey, value: newAccessToken);
      await _storage.write(key: ApiConstants.refreshTokenKey, value: newRefreshToken);

      // Retry original request with new token
      err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
      final retryResponse = await _dio.fetch(err.requestOptions);
      handler.resolve(retryResponse);

      // Retry all pending requests
      for (final pending in _pendingRequests) {
        pending.options.headers['Authorization'] = 'Bearer $newAccessToken';
        try {
          final response = await _dio.fetch(pending.options);
          pending.handler.resolve(response);
        } catch (e) {
          pending.handler.reject(
            DioException(requestOptions: pending.options, error: e),
          );
        }
      }
    } on DioException {
      await _clearTokensAndReject(err, handler);
    } finally {
      _isRefreshing = false;
      _pendingRequests.clear();
    }
  }

  Future<void> _clearTokensAndReject(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    await _storage.delete(key: ApiConstants.accessTokenKey);
    await _storage.delete(key: ApiConstants.refreshTokenKey);
    handler.reject(err);
  }
}
