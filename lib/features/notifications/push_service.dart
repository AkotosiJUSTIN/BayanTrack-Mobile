import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Simple service to handle FCM token registration and message listeners.
class PushService {
  PushService({FirebaseMessaging? messaging}) : _messaging = messaging;

  final FirebaseMessaging? _messaging;
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _messageSubscription;
  StreamSubscription<RemoteMessage>? _messageOpenedSubscription;
  Future<void>? _registrationFuture;
  String? _registrationKey;
  Timer? _registrationRetry;
  int _registrationGeneration = 0;
  bool _disposed = false;
  bool _permissionRequested = false;

  FirebaseMessaging get _firebaseMessaging =>
      _messaging ?? FirebaseMessaging.instance;

  Future<String?> getToken() => _firebaseMessaging.getToken();

  Future<RemoteMessage?> getInitialMessage() =>
      _firebaseMessaging.getInitialMessage();

  Future<void> requestPermission() async {
    if (_permissionRequested) return;
    _permissionRequested = true;
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint(
        'FCM permission status: auth=${settings.authorizationStatus} '
        'alert=${settings.alert} badge=${settings.badge} sound=${settings.sound}',
      );
    } catch (_) {
      _permissionRequested = false;
      rethrow;
    }
  }

  /// Listen for token refreshes so we keep the backend in sync.
  void onTokenRefresh(Future<void> Function(String token) handler) {
    unawaited(_tokenRefreshSubscription?.cancel());
    _tokenRefreshSubscription = _firebaseMessaging.onTokenRefresh.listen((
      token,
    ) async {
      try {
        await handler(token);
      } catch (e) {
        debugPrint('Failed to handle FCM token refresh: $e');
      }
    });
  }

  /// Register current token with backend using provided dio client.
  Future<void> registerToken(
    String token,
    String deviceType,
    Dio dio, {
    String? userId,
  }) async {
    // The server may have lost this token; local registration flags are not proof.
    try {
      debugPrint('Registering FCM token for $deviceType');
      await dio.post(
        ApiConstants.notificationPushToken,
        data: {'token': token, 'device_type': deviceType},
      );
    } catch (e) {
      debugPrint('Failed to register push token: $e');
      rethrow;
    }
  }

  /// Ensure token is registered with backend; retry with backoff on failure.
  Future<void> ensureRegistered(
    String deviceType,
    Dio dio, {
    String? userId,
  }) async {
    if (_disposed) return;
    final registrationKey = '$userId:$deviceType';
    if (_registrationKey != registrationKey) {
      cancelRegistration();
      _registrationKey = registrationKey;
    }
    _registrationRetry?.cancel();
    final pending = _registrationFuture;
    if (pending != null) return pending;

    final generation = _registrationGeneration;
    final future = _ensureRegistered(
      deviceType,
      dio,
      generation: generation,
      userId: userId,
    );
    _registrationFuture = future;
    try {
      await future;
    } catch (_) {
      if (!_disposed && generation == _registrationGeneration) {
        _registrationRetry = Timer(const Duration(seconds: 30), () {
          unawaited(
            ensureRegistered(deviceType, dio, userId: userId).catchError(
              (Object error) => debugPrint(
                'Push registration retry failed (${error.runtimeType})',
              ),
            ),
          );
        });
      }
      rethrow;
    } finally {
      if (identical(_registrationFuture, future)) {
        _registrationFuture = null;
      }
    }
  }

  /// Stop retries and prevent a late token lookup from registering after logout.
  void cancelRegistration() {
    _registrationGeneration++;
    _registrationRetry?.cancel();
    _registrationRetry = null;
    _registrationFuture = null;
    _registrationKey = null;
  }

  Future<void> _ensureRegistered(
    String deviceType,
    Dio dio, {
    required int generation,
    String? userId,
  }) async {
    await requestPermission();

    String? token;
    for (var attempt = 0; attempt < 5; attempt++) {
      if (_disposed || generation != _registrationGeneration) return;
      try {
        token = await _firebaseMessaging.getToken();
      } catch (_) {
        if (attempt == 4) rethrow;
      }
      if (token != null && token.isNotEmpty) {
        break;
      }
      debugPrint('FCM token not ready yet, retrying (${attempt + 1}/5)');
      if (attempt < 4) await Future.delayed(Duration(seconds: attempt + 1));
    }

    if (_disposed || generation != _registrationGeneration) return;
    if (token == null || token.isEmpty) {
      throw StateError('FCM token unavailable; registration will retry');
    }

    // Try registering with simple retry/backoff
    int attempts = 0;
    while (attempts < 3) {
      if (_disposed || generation != _registrationGeneration) return;
      try {
        await registerToken(token, deviceType, dio, userId: userId);
        return;
      } catch (_) {
        attempts += 1;
        if (attempts == 3) rethrow;
        await Future.delayed(Duration(seconds: 1 << attempts));
      }
    }
  }

  /// Listen to foreground messages and invoke the provided handler.
  void onMessage(void Function(RemoteMessage) handler) {
    unawaited(_messageSubscription?.cancel());
    _messageSubscription = FirebaseMessaging.onMessage.listen(handler);
  }

  /// Listen to when user taps a message and the app is opened from background.
  void onMessageOpened(void Function(RemoteMessage) handler) {
    unawaited(_messageOpenedSubscription?.cancel());
    _messageOpenedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      handler,
    );
  }

  void dispose() {
    _disposed = true;
    cancelRegistration();
    unawaited(_tokenRefreshSubscription?.cancel());
    unawaited(_messageSubscription?.cancel());
    unawaited(_messageOpenedSubscription?.cancel());
  }
}

/// A simple provider for PushService if you want to inject it.
final pushServiceProvider = Provider<PushService>((ref) {
  final service = PushService();
  ref.onDispose(service.dispose);
  return service;
});
