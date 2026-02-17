import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/auth_session_repository.dart';
import '../../domain/entities/auth_tokens.dart';

/// Implementation of [AuthSessionRepository] using FlutterSecureStorage.
class AuthSessionRepositoryImpl implements AuthSessionRepository {
  final FlutterSecureStorage _storage;
  final StreamController<bool> _authStateController =
      StreamController<bool>.broadcast();

  AuthSessionRepositoryImpl(this._storage);

  @override
  Future<bool> get isAuthenticated async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Stream<bool> get authStateChanges => _authStateController.stream;

  @override
  Future<AuthTokens?> getTokens() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();

    if (accessToken == null || refreshToken == null) return null;

    return AuthTokens(accessToken: accessToken, refreshToken: refreshToken);
  }

  @override
  Future<String?> getAccessToken() async {
    return _storage.read(key: ApiConstants.accessTokenKey);
  }

  @override
  Future<String?> getRefreshToken() async {
    return _storage.read(key: ApiConstants.refreshTokenKey);
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: ApiConstants.accessTokenKey, value: accessToken);
    await _storage.write(
      key: ApiConstants.refreshTokenKey,
      value: refreshToken,
    );
    _authStateController.add(true);
  }

  @override
  Future<void> clearSession() async {
    await _storage.delete(key: ApiConstants.accessTokenKey);
    await _storage.delete(key: ApiConstants.refreshTokenKey);
    _authStateController.add(false);
  }

  @override
  Future<String?> refreshToken() async {
    final token = await getRefreshToken();
    debugPrint(
      '[AuthSessionRepository] Token refresh requested. Has refresh token: ${token != null}',
    );
    return token;
  }

  /// Dispose the stream controller when no longer needed
  void dispose() {
    _authStateController.close();
  }
}
