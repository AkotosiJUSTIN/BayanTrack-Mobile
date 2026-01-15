import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../constants/api_constants.dart';

part 'secure_storage_provider.g.dart';

@riverpod
FlutterSecureStorage secureStorage(Ref ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
}

@riverpod
class TokenStorage extends _$TokenStorage {
  @override
  Future<(String?, String?)> build() async {
    final storage = ref.watch(secureStorageProvider);
    final accessToken = await storage.read(key: ApiConstants.accessTokenKey);
    final refreshToken = await storage.read(key: ApiConstants.refreshTokenKey);
    return (accessToken, refreshToken);
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final storage = ref.read(secureStorageProvider);
    await storage.write(key: ApiConstants.accessTokenKey, value: accessToken);
    await storage.write(key: ApiConstants.refreshTokenKey, value: refreshToken);
    ref.invalidateSelf();
  }

  Future<void> clearTokens() async {
    final storage = ref.read(secureStorageProvider);
    await storage.delete(key: ApiConstants.accessTokenKey);
    await storage.delete(key: ApiConstants.refreshTokenKey);
    ref.invalidateSelf();
  }

  Future<String?> getAccessToken() async {
    final storage = ref.read(secureStorageProvider);
    return storage.read(key: ApiConstants.accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    final storage = ref.read(secureStorageProvider);
    return storage.read(key: ApiConstants.refreshTokenKey);
  }
}
