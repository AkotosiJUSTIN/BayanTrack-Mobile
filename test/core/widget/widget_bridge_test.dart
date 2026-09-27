import 'package:bayantrack_mobile/core/widget/widget_bridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    expect(
      parseWidgetDestination('emergency_report'),
      WidgetDestination.emergencyReport,
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
    bridge.finishWidgetDestination();
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
      bridge.finishWidgetDestination();
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
      bridge.finishWidgetDestination();

      bridge.ingestRaw('notifications');
      expect(bridge.takePendingDestination(), WidgetDestination.notifications);
      bridge.finishWidgetDestination();
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
    bridge.finishWidgetDestination();
  });

  test(
    'emergency destination waits for authentication like every widget entry',
    () async {
      final bridge = WidgetBridge(invokeNative: (_, _) async => null);
      addTearDown(bridge.dispose);

      bridge.ingestRaw('emergency_report');
      expect(bridge.takePendingDestination(), isNull);
      await bridge.syncAuthenticated(true);
      expect(
        bridge.takePendingDestination(),
        WidgetDestination.emergencyReport,
      );
      bridge.finishWidgetDestination();
    },
  );

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
        'quickReportStatus': 'ready',
      });

      await bridge.syncUnreadCount(-1);
      expect(states.last['unreadCount'], 0);
      await bridge.syncAuthenticated(false);
      expect(states.last, {
        'locale': 'en',
        'authenticated': false,
        'unreadCount': 0,
        'quickReportStatus': 'ready',
      });
    },
  );

  test('syncs Quick Report states without exposing report data', () async {
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
    for (final status in QuickReportWidgetStatus.values) {
      await bridge.syncQuickReportStatus(status);
      expect(states.last['quickReportStatus'], status.name);
      expect(states.last.keys, isNot(contains('description')));
      expect(states.last.keys, isNot(contains('token')));
    }

    await bridge.syncAuthenticated(false);
    expect(states.last['authenticated'], isFalse);
    expect(states.last['quickReportStatus'], 'ready');
  });

  test('ignores repeated destination until the app backgrounds', () async {
    final bridge = WidgetBridge(invokeNative: (_, _) async => null);
    addTearDown(bridge.dispose);
    await bridge.syncAuthenticated(true);

    bridge.ingestRaw('quick_report');
    expect(bridge.takePendingDestination(), WidgetDestination.quickReport);
    bridge.ingestRaw('quick_report');

    expect(bridge.pendingDestination, isNull);
    expect(bridge.takePendingDestination(), isNull);
    bridge.finishWidgetDestination();

    bridge.ingestRaw('quick_report');
    expect(bridge.pendingDestination, isNull);
    expect(bridge.takePendingDestination(), isNull);

    bridge.clearFinishedDestinations();
    bridge.ingestRaw('quick_report');
    expect(bridge.takePendingDestination(), WidgetDestination.quickReport);
  });

  test(
    'acknowledges an intent delivered while the app is already running',
    () async {
      final channel = _RecordingWidgetChannel();
      final bridge = WidgetBridge(channel: channel);
      addTearDown(bridge.dispose);

      await bridge.initialize();
      channel.pendingDestination = 'quick_report';
      await channel.dispatch(
        const MethodCall('widgetDestination', 'quick_report'),
      );

      expect(bridge.pendingDestination, WidgetDestination.quickReport);
      expect(channel.pendingDestination, isNull);
      expect(channel.acknowledgedDestinations, ['quick_report']);
    },
  );

  test(
    'queues a different widget destination until the open route closes',
    () async {
      final bridge = WidgetBridge(invokeNative: (_, _) async => null);
      addTearDown(bridge.dispose);
      await bridge.syncAuthenticated(true);

      bridge.ingestRaw('quick_report');
      expect(bridge.takePendingDestination(), WidgetDestination.quickReport);
      bridge.ingestRaw('notifications');
      expect(bridge.pendingDestination, WidgetDestination.notifications);
      expect(bridge.takePendingDestination(), isNull);

      bridge.finishWidgetDestination();
      expect(bridge.takePendingDestination(), WidgetDestination.notifications);
    },
  );
}

class _RecordingWidgetChannel extends MethodChannel {
  _RecordingWidgetChannel() : super('test/bayantrack/widget');

  Future<dynamic> Function(MethodCall call)? _handler;
  String? pendingDestination;
  final List<Object?> acknowledgedDestinations = [];

  Future<void> dispatch(MethodCall call) async {
    await _handler?.call(call);
  }

  @override
  void setMethodCallHandler(
    Future<dynamic> Function(MethodCall call)? handler,
  ) {
    _handler = handler;
  }

  @override
  Future<T?> invokeMethod<T>(String method, [dynamic arguments]) async {
    if (method == 'getInitialWidgetDestination') {
      final destination = pendingDestination;
      pendingDestination = null;
      return destination as T?;
    }
    if (method == 'acknowledgeWidgetDestination' &&
        pendingDestination == arguments) {
      pendingDestination = null;
      acknowledgedDestinations.add(arguments);
    }
    return null;
  }
}
