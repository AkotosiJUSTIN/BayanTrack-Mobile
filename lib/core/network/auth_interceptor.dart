import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../../features/auth/domain/auth_session_repository.dart';

/// Interceptor that handles JWT authentication:
/// - Injects Authorization header on all requests
/// - Catches 401 errors and attempts token refresh
/// - Clears tokens on refresh failure
///
/// Uses AuthSessionRepository interface for token management,
/// following Clean Architecture principles.
class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final AuthSessionRepository _sessionRepository;
  bool _isRefreshing = false;
  final _pendingRequests =
      <({RequestOptions options, ErrorInterceptorHandler handler})>[];

  AuthInterceptor(this._dio, this._sessionRepository);

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
    final accessToken = await _sessionRepository.getAccessToken();

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
      final refreshToken = await _sessionRepository.getRefreshToken();

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
      // Backend may not return a new refresh token - keep the existing one
      final newRefreshToken =
          response.data['refresh_token'] as String? ?? refreshToken;

      // Save new tokens through the repository
      await _sessionRepository.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

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
    } on DioException catch (refreshError) {
      // Don't clear tokens on refresh failure - just reject this request
      // User can still try again or manually logout
      debugPrint('Token refresh failed: ${refreshError.message}');
      handler.reject(err); // Reject with original error
    } finally {
      _isRefreshing = false;
      _pendingRequests.clear();
    }
  }

  Future<void> _clearTokensAndReject(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    await _sessionRepository.clearSession();
    handler.reject(err);
  }
}
