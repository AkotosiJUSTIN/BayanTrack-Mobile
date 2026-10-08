import 'dart:async';

import 'package:bayantrack_mobile/features/notifications/local_notification_service.dart';
import 'package:bayantrack_mobile/features/notifications/notification_payload.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'cold launch and foreground local alert preserve Terms navigation',
    (tester) async {
      const channel = MethodChannel(
        'dexterous.com/flutter/local_notifications',
      );
      const payload = {
        'type': 'terms_updated',
        'terms_version_id': 'published-2',
        'event_id': 'terms:published-2',
      };
      final encoded = encodeNotificationPayload(payload);
      final calls = <MethodCall>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
        call,
      ) async {
        calls.add(call);
        if (call.method == 'initialize' ||
            call.method == 'requestNotificationsPermission') {
          return true;
        }
        if (call.method == 'getNotificationAppLaunchDetails') {
          return {
            'notificationLaunchedApp': true,
            'notificationResponse': {
              'notificationId': 1,
              'notificationResponseType': 0,
              'payload': encoded,
            },
          };
        }
        return null;
      });
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          null,
        ),
      );

      await LocalNotificationService.initialize();
      expect(LocalNotificationService.takePendingTap(), payload);
      expect(LocalNotificationService.takePendingTap(), isNull);

      await LocalNotificationService.showFromRemoteMessage(
        const RemoteMessage(
          notification: RemoteNotification(
            title: 'Terms updated',
            body: 'Review the policy',
          ),
          data: payload,
        ),
      );
      final show = calls.singleWhere((call) => call.method == 'show');
      expect(
        decodeNotificationPayload(show.arguments['payload'] as String),
        payload,
      );

      final received = Completer<Map<String, dynamic>>();
      final subscription = LocalNotificationService.taps.listen((data) {
        if (!received.isCompleted) received.complete(data);
      });
      addTearDown(subscription.cancel);
      tester.binding.channelBuffers.push(
        channel.name,
        const StandardMethodCodec().encodeMethodCall(
          MethodCall('didReceiveNotificationResponse', {
            'notificationId': 1,
            'notificationResponseType': 0,
            'payload': encoded,
          }),
        ),
        (_) {},
      );
      await tester.pump();
      expect(await received.future, payload);
      expect(LocalNotificationService.takePendingTap(), payload);
    },
    variant: TargetPlatformVariant({TargetPlatform.android}),
  );
}
