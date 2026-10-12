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
  static const _requestSessionKey = 'authInterceptor.requestSession';
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
    debugPrint('[AuthInterceptor] Request: ${options.method} ${options.path}');
    // Skip auth header for public endpoints
    final publicEndpoints = [
      ApiConstants.login,
      ApiConstants.register,
      ApiConstants.forgotPassword,
      ApiConstants.resetPassword,
      ApiConstants.refresh,
    ];

    if (publicEndpoints.any((endpoint) => options.path.contains(endpoint))) {
      debugPrint('[AuthInterceptor] Skipping auth header for public endpoint');
      return handler.next(options);
    }

    // Bind replay to dispatch, not to whichever account handles a late 401.
    final refreshToken = await _sessionRepository.getRefreshToken();
    final accessToken = await _sessionRepository.getAccessToken();
    if (await _sessionRepository.getRefreshToken() != refreshToken) {
      return handler.reject(_sessionChanged(options));
    }
    options.extra[_requestSessionKey] = refreshToken;

    if (accessToken != null) {
      debugPrint('[AuthInterceptor] Injecting access token');
      options.headers['Authorization'] = 'Bearer $accessToken';
    } else {
      debugPrint('[AuthInterceptor] No access token found');
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    debugPrint(
      '[AuthInterceptor] Error: status=${err.response?.statusCode} '
      'type=${err.type} path=${err.requestOptions.path}',
    );
    // Only handle 401 Unauthorized
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Refresh calls use raw Dio; do not recurse if the route uses this client.
    if (err.requestOptions.path.contains(ApiConstants.refresh)) {
      return handler.next(err);
    }

    // Public requests have no originating session to refresh.
    if (!err.requestOptions.extra.containsKey(_requestSessionKey)) {
      return handler.next(err);
    }

    // Queue requests while refreshing
    if (_isRefreshing) {
      _pendingRequests.add((options: err.requestOptions, handler: handler));
      return;
    }

    _isRefreshing = true;
    try {
      await _refreshAndReplay(err, handler);
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _refreshAndReplay(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    String? refreshToken;
    String? refreshedToken;
    String? accessToken;
    try {
      refreshToken = await _sessionRepository.getRefreshToken();
      if (err.requestOptions.extra[_requestSessionKey] != refreshToken) {
        final failure = _sessionChanged(err.requestOptions);
        handler.reject(failure);
        _rejectPending(failure);
        return;
      }
      if (refreshToken == null) {
        await _clearMatchingSession(null);
        handler.reject(err);
        _rejectPending(err);
        return;
      }

      final response = await _dio.post(
        ApiConstants.refresh,
        data: {'refresh_token': refreshToken, 'client_type': 'mobile'},
      );
      accessToken = response.data['access_token'] as String;
      refreshedToken =
          response.data['refresh_token'] as String? ?? refreshToken;

      final saved = await _sessionRepository.saveTokensIfRefreshTokenMatches(
        expectedRefreshToken: refreshToken,
        accessToken: accessToken,
        refreshToken: refreshedToken,
      );
      if (!saved ||
          await _sessionRepository.getRefreshToken() != refreshedToken) {
        handler.reject(err);
        _rejectPending(err);
        return;
      }
    } on DioException catch (refreshError) {
      final terminal = switch (refreshError.response?.statusCode) {
        400 || 401 => true,
        _ => false,
      };
      if (terminal) await _clearMatchingSession(refreshToken);
      handler.reject(
        terminal ? err : _forRequest(refreshError, err.requestOptions),
      );
      _rejectPending(terminal ? err : refreshError);
      return;
    } catch (error, stackTrace) {
      final failure = DioException(
        requestOptions: err.requestOptions,
        type: DioExceptionType.unknown,
        error: error,
        message: 'Session refresh failed',
        stackTrace: stackTrace,
      );
      handler.reject(failure);
      _rejectPending(failure);
      return;
    }

    err.requestOptions.headers['Authorization'] = 'Bearer $accessToken';
    try {
      handler.resolve(await _dio.fetch(err.requestOptions));
    } on DioException catch (retryError) {
      if (retryError.response?.statusCode == 401) {
        await _clearMatchingSession(refreshedToken);
      }
      handler.reject(retryError);
      if (retryError.response?.statusCode == 401) {
        _rejectPending(retryError);
        return;
      }
    } catch (error, stackTrace) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: error,
          stackTrace: stackTrace,
        ),
      );
    }
    await _retryPending(accessToken, refreshedToken, refreshToken);
  }

  Future<void> _retryPending(
    String accessToken,
    String refreshToken,
    String originatingRefreshToken,
  ) async {
    final pendingRequests = List.of(_pendingRequests);
    _pendingRequests.clear();
    for (var index = 0; index < pendingRequests.length; index++) {
      final pending = pendingRequests[index];
      if (!pending.options.extra.containsKey(_requestSessionKey) ||
          pending.options.extra[_requestSessionKey] !=
              originatingRefreshToken) {
        pending.handler.reject(_sessionChanged(pending.options));
        continue;
      }
      if (await _sessionRepository.getRefreshToken() != refreshToken) {
        for (final remaining in pendingRequests.skip(index)) {
          remaining.handler.reject(
            DioException(
              requestOptions: remaining.options,
              type: DioExceptionType.cancel,
              message: 'Session changed during token refresh',
            ),
          );
        }
        return;
      }
      pending.options.headers['Authorization'] = 'Bearer $accessToken';
      try {
        pending.handler.resolve(await _dio.fetch(pending.options));
      } on DioException catch (error) {
        if (error.response?.statusCode == 401) {
          await _clearMatchingSession(refreshToken);
          pending.handler.reject(error);
          for (final remaining in pendingRequests.skip(index + 1)) {
            remaining.handler.reject(_forRequest(error, remaining.options));
          }
          return;
        }
        pending.handler.reject(error);
      } catch (error, stackTrace) {
        pending.handler.reject(
          DioException(
            requestOptions: pending.options,
            error: error,
            stackTrace: stackTrace,
          ),
        );
      }
    }
  }

  void _rejectPending(DioException error) {
    final pendingRequests = List.of(_pendingRequests);
    _pendingRequests.clear();
    for (final pending in pendingRequests) {
      pending.handler.reject(_forRequest(error, pending.options));
    }
  }

  DioException _forRequest(DioException error, RequestOptions options) =>
      DioException(
        requestOptions: options,
        response: error.response,
        type: error.type,
        error: error.error,
        message: error.message,
        stackTrace: error.stackTrace,
      );

  DioException _sessionChanged(RequestOptions options) => DioException(
    requestOptions: options,
    type: DioExceptionType.cancel,
    message: 'Session changed before request replay',
  );

  Future<void> _clearMatchingSession(String? refreshToken) async {
    try {
      await _sessionRepository.clearSessionIfRefreshTokenMatches(refreshToken);
    } catch (_) {
      debugPrint('Unable to clear rejected session.');
    }
  }
}
