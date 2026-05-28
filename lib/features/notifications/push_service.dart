import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/constants/api_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Simple service to handle FCM token registration and message listeners.
class PushService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<String?> getToken() => _messaging.getToken();

  Future<void> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint(
      'FCM permission status: auth=${settings.authorizationStatus} '
      'alert=${settings.alert} badge=${settings.badge} sound=${settings.sound}',
    );
  }

  /// Listen for token refreshes so we keep the backend in sync.
  void onTokenRefresh(
    Future<void> Function(String token) handler,
  ) {
    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      try {
        await handler(token);
      } catch (e) {
        debugPrint('Failed to handle FCM token refresh: $e');
      }
    });
  }

  /// Register current token with backend using provided dio client.
  Future<void> registerToken(String token, String deviceType, Dio dio) async {
    try {
      debugPrint('Registering FCM token for $deviceType: ${token.substring(0, token.length > 10 ? 10 : token.length)}...');
      await dio.post(ApiConstants.notificationPushToken, data: {
        'token': token,
        'device_type': deviceType,
      });
      // persist registered token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('push_token', token);
      await prefs.setBool('push_token_registered', true);
    } catch (e) {
      debugPrint('Failed to register push token: $e');
      // mark not registered to retry later
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('push_token_registered', false);
      rethrow;
    }
  }

  /// Ensure token is registered with backend; retry with backoff on failure.
  Future<void> ensureRegistered(String deviceType, Dio dio) async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('push_token');
    final registered = prefs.getBool('push_token_registered') ?? false;

    debugPrint(
      'ensureRegistered start: savedToken=${savedToken == null ? "null" : savedToken.substring(0, savedToken.length > 10 ? 10 : savedToken.length)}... '
      'registered=$registered',
    );

    await requestPermission();

    String? token;
    for (var attempt = 0; attempt < 5; attempt++) {
      token = await _messaging.getToken();
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

    debugPrint('ensureRegistered got token: ${token.substring(0, token.length > 10 ? 10 : token.length)}...');

    // Try registering with simple retry/backoff
    int attempts = 0;
    while (attempts < 3) {
      try {
        await registerToken(token, deviceType, dio);
        return;
      } catch (_) {
        attempts += 1;
        await Future.delayed(Duration(seconds: 1 << attempts));
      }
    }
  }

  /// Listen to foreground messages and invoke the provided handler.
  void onMessage(void Function(RemoteMessage) handler) {
    FirebaseMessaging.onMessage.listen(handler);
  }

  /// Listen to when user taps a message and the app is opened from background.
  void onMessageOpened(void Function(RemoteMessage) handler) {
    FirebaseMessaging.onMessageOpenedApp.listen(handler);
  }
}

/// A simple provider for PushService if you want to inject it.
final pushServiceProvider = Provider<PushService>((ref) => PushService());
