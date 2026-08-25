import 'package:bayantrack_mobile/core/widget/widget_bridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('maps supported destinations and rejects malformed values', () {
    expect(
      parseWidgetDestination('quick_report'),
      WidgetDestination.quickReport,
    );
    expect(
      parseWidgetDestination('quick-report'),
      WidgetDestination.quickReport,
    );
    expect(
      parseWidgetDestination('notifications'),
      WidgetDestination.notifications,
    );
    expect(parseWidgetDestination(''), isNull);
    expect(parseWidgetDestination('profile'), isNull);
    expect(parseWidgetDestination(42), isNull);
  });

  test('cold-start destination waits for restored authentication', () async {
    final bridge = WidgetBridge(
      invokeNative: (method, _) async =>
          method == 'getInitialWidgetDestination' ? 'quick_report' : null,
    );
    addTearDown(bridge.dispose);

    await bridge.initialize();
    expect(bridge.pendingDestination, WidgetDestination.quickReport);
    expect(bridge.takePendingDestination(), isNull);

    await bridge.syncAuthenticated(true);
    expect(bridge.takePendingDestination(), WidgetDestination.quickReport);
    expect(bridge.takePendingDestination(), isNull);
  });

  test(
    'logged-out destination remains pending until authentication succeeds',
    () async {
      final bridge = WidgetBridge(invokeNative: (_, _) async => null);
      addTearDown(bridge.dispose);

      bridge.ingestRaw('notifications');
      await bridge.syncAuthenticated(false);
      expect(bridge.takePendingDestination(), isNull);

      await bridge.syncAuthenticated(true);
      expect(bridge.takePendingDestination(), WidgetDestination.notifications);
    },
  );

  test(
    'already-authenticated taps expose each supported destination once',
    () async {
      final bridge = WidgetBridge(invokeNative: (_, _) async => null);
      addTearDown(bridge.dispose);
      await bridge.syncAuthenticated(true);

      bridge.ingestRaw('quick_report');
      expect(bridge.takePendingDestination(), WidgetDestination.quickReport);
      expect(bridge.takePendingDestination(), isNull);

      bridge.ingestRaw('notifications');
      expect(bridge.takePendingDestination(), WidgetDestination.notifications);
    },
  );

  test('duplicate pending intent is ignored', () async {
    final bridge = WidgetBridge(invokeNative: (_, _) async => null);
    addTearDown(bridge.dispose);
    await bridge.syncAuthenticated(true);

    bridge.ingestRaw('quick_report');
    bridge.ingestRaw('quick_report');
    expect(bridge.takePendingDestination(), WidgetDestination.quickReport);
    expect(bridge.takePendingDestination(), isNull);
  });

  test('maps Filipino locale and falls back to English', () {
    expect(widgetLocaleCode(const Locale('fil')), 'fil');
    expect(widgetLocaleCode(const Locale('en')), 'en');
    expect(widgetLocaleCode(const Locale('tl')), 'en');
  });

  test(
    'syncs unread count only as safe numeric widget state and clears on logout',
    () async {
      final states = <Map<String, Object>>[];
      final bridge = WidgetBridge(
        invokeNative: (method, arguments) async {
          if (method == 'updateState') {
            states.add(Map<String, Object>.from(arguments! as Map));
          }
        },
      );
      addTearDown(bridge.dispose);

      await bridge.syncAuthenticated(true);
      await bridge.syncUnreadCount(3);
      expect(states.last, {
        'locale': 'en',
        'authenticated': true,
        'unreadCount': 3,
      });

      await bridge.syncUnreadCount(-1);
      expect(states.last['unreadCount'], 0);
      await bridge.syncAuthenticated(false);
      expect(states.last, {
        'locale': 'en',
        'authenticated': false,
        'unreadCount': 0,
      });
    },
  );
}
