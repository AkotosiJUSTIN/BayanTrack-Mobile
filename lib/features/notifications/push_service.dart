import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool _permissionRequested = false;

  FirebaseMessaging get _firebaseMessaging =>
      _messaging ?? FirebaseMessaging.instance;

  static const _tokenKey = 'push_token';
  static const _registeredKey = 'push_token_registered';
  static const _registeredUserKey = 'push_token_registered_user';
  static const _registeredDeviceKey = 'push_token_registered_device';

  Future<String?> getToken() => _firebaseMessaging.getToken();

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
    final prefs = await SharedPreferences.getInstance();
    if (_isRegistered(prefs, token, deviceType, userId)) return;

    try {
      debugPrint('Registering FCM token for $deviceType');
      await dio.post(
        ApiConstants.notificationPushToken,
        data: {'token': token, 'device_type': deviceType},
      );
      // persist registered token
      await prefs.setString(_tokenKey, token);
      await prefs.setBool(_registeredKey, true);
      await prefs.setString(_registeredDeviceKey, deviceType);
      if (userId == null) {
        await prefs.remove(_registeredUserKey);
      } else {
        await prefs.setString(_registeredUserKey, userId);
      }
    } catch (e) {
      debugPrint('Failed to register push token: $e');
      // mark not registered to retry later
      await prefs.setBool(_registeredKey, false);
      rethrow;
    }
  }

  /// Ensure token is registered with backend; retry with backoff on failure.
  Future<void> ensureRegistered(
    String deviceType,
    Dio dio, {
    String? userId,
  }) async {
    final registrationKey = '$userId:$deviceType';
    final pending = _registrationFuture;
    if (pending != null) {
      if (_registrationKey == registrationKey) return pending;
      await pending;
    }

    final future = _ensureRegistered(deviceType, dio, userId: userId);
    _registrationKey = registrationKey;
    _registrationFuture = future;
    try {
      await future;
    } finally {
      if (identical(_registrationFuture, future)) {
        _registrationFuture = null;
        _registrationKey = null;
      }
    }
  }

  Future<void> _ensureRegistered(
    String deviceType,
    Dio dio, {
    String? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString(_tokenKey);

    debugPrint(
      'ensureRegistered start: hasSavedToken=${savedToken != null} '
      'registered=${prefs.getBool(_registeredKey) ?? false}',
    );

    if (savedToken != null &&
        _isRegistered(prefs, savedToken, deviceType, userId)) {
      return;
    }

    await requestPermission();

    String? token;
    for (var attempt = 0; attempt < 5; attempt++) {
      token = await _firebaseMessaging.getToken();
      token ??= savedToken;
      if (token != null && token.isNotEmpty) {
        break;
      }
      debugPrint('FCM token not ready yet, retrying (${attempt + 1}/5)');
      await Future.delayed(Duration(seconds: attempt + 1));
    }

    if (token == null || token.isEmpty) {
      debugPrint('FCM token is still unavailable; will retry later');
      await prefs.setBool('push_token_registered', false);
      return;
    }

    // Try registering with simple retry/backoff
    int attempts = 0;
    while (attempts < 3) {
      try {
        await registerToken(token, deviceType, dio, userId: userId);
        return;
      } catch (_) {
        attempts += 1;
        await Future.delayed(Duration(seconds: 1 << attempts));
      }
    }
  }

  bool _isRegistered(
    SharedPreferences prefs,
    String token,
    String deviceType,
    String? userId,
  ) =>
      prefs.getBool(_registeredKey) == true &&
      prefs.getString(_tokenKey) == token &&
      prefs.getString(_registeredDeviceKey) == deviceType &&
      prefs.getString(_registeredUserKey) == userId;

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
