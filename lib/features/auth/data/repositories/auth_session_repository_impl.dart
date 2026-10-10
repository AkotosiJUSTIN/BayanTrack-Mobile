import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/auth_session_repository.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/user.dart';
import '../auth_models.dart';
import '../mappers/auth_mapper.dart';

/// Implementation of [AuthSessionRepository] using FlutterSecureStorage.
class AuthSessionRepositoryImpl implements AuthSessionRepository {
  static const _cachedUserKey = 'bayantrack_verified_session_user_v1';
  final FlutterSecureStorage _storage;
  final StreamController<bool> _authStateController =
      StreamController<bool>.broadcast();
  Future<void> _tail = Future<void>.value();

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
  Future<User?> getCachedUser() => _serialize(() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    if (accessToken == null ||
        accessToken.isEmpty ||
        refreshToken == null ||
        refreshToken.isEmpty) {
      return null;
    }
    final value = await _storage.read(key: _cachedUserKey);
    if (value == null) return null;
    try {
      final json = Map<String, dynamic>.from(jsonDecode(value) as Map);
      final user = AuthMapper.userFromProfile(UserProfile.fromJson(json));
      return user.id.isNotEmpty && user.isActive ? user : null;
    } on Object {
      return null;
    }
  });

  @override
  Future<bool> cacheUser(User user, {required String expectedAccessToken}) =>
      _serialize(() async {
        if (expectedAccessToken.isEmpty ||
            await getAccessToken() != expectedAccessToken ||
            user.id.isEmpty) {
          return false;
        }
        await _storage.write(
          key: _cachedUserKey,
          value: jsonEncode(AuthMapper.profileFromUser(user).toJson()),
        );
        return true;
      });

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) => _serialize(() async {
    // A fresh login must never inherit the previous account's offline identity.
    await _storage.delete(key: _cachedUserKey);
    await _writeTokens(accessToken, refreshToken);
  });

  @override
  Future<bool> saveTokensIfRefreshTokenMatches({
    required String expectedRefreshToken,
    required String accessToken,
    required String refreshToken,
  }) => _serialize(() async {
    final current = await _storage.read(key: ApiConstants.refreshTokenKey);
    if (current != expectedRefreshToken) return false;
    await _writeTokens(accessToken, refreshToken);
    return true;
  });

  @override
  Future<void> clearSession() => _serialize(_clearSession);

  @override
  Future<bool> clearSessionIfRefreshTokenMatches(
    String? expectedRefreshToken,
  ) => _serialize(() async {
    final current = await _storage.read(key: ApiConstants.refreshTokenKey);
    if (current != expectedRefreshToken) return false;
    await _clearSession();
    return true;
  });

  Future<void> _writeTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: ApiConstants.accessTokenKey, value: accessToken);
    await _storage.write(
      key: ApiConstants.refreshTokenKey,
      value: refreshToken,
    );
    _authStateController.add(true);
  }

  Future<void> _clearSession() async {
    await _storage.delete(key: _cachedUserKey);
    await _storage.delete(key: ApiConstants.accessTokenKey);
    await _storage.delete(key: ApiConstants.refreshTokenKey);
    _authStateController.add(false);
  }

  Future<T> _serialize<T>(Future<T> Function() action) async {
    final previous = _tail;
    final done = Completer<void>();
    _tail = done.future;
    await previous;
    try {
      return await action();
    } finally {
      done.complete();
    }
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
