import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_payload.dart';

class LocalNotificationService {
  LocalNotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static final _taps = StreamController<Map<String, dynamic>>.broadcast();
  static Map<String, dynamic>? _pendingTap;

  static Stream<Map<String, dynamic>> get taps => _taps.stream;

  static Map<String, dynamic>? takePendingTap() {
    final data = _pendingTap;
    _pendingTap = null;
    return data;
  }

  static void _handleTap(String? payload) {
    final data = decodeNotificationPayload(payload);
    if (data.isEmpty) return;
    _pendingTap = data;
    _taps.add(data);
  }

  static Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/bayantrack_logo',
    );
    const settings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) =>
          _handleTap(response.payload),
    );
    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp == true) {
      _handleTap(launch?.notificationResponse?.payload);
    }

    const androidChannel = AndroidNotificationChannel(
      'bayantrack_general',
      'BayanTrack Notifications',
      description: 'General notifications for report and account updates.',
      importance: Importance.high,
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(androidChannel);
    await androidPlugin?.requestNotificationsPermission();

    _initialized = true;
  }

  static Future<void> showFromRemoteMessage(RemoteMessage message) async {
    await initialize();

    final notification = message.notification;
    final title = notification?.title ?? message.data['title'] as String?;
    final body = notification?.body ?? message.data['body'] as String?;

    if (title == null && body == null) {
      return;
    }

    final androidDetails = const AndroidNotificationDetails(
      'bayantrack_general',
      'BayanTrack Notifications',
      channelDescription:
          'General notifications for report and account updates.',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/bayantrack_logo',
    );

    final payload = encodeNotificationPayload(message.data);

    await _plugin.show(
      message.hashCode,
      title ?? 'BayanTrack',
      body ?? '',
      NotificationDetails(android: androidDetails),
      payload: payload,
    );
  }
}
