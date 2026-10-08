import 'package:bayantrack_mobile/core/widget/widget_bridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('maps supported destinations and rejects malformed values', () {
    expect(parseWidgetDestination('fast_report'), WidgetDestination.fastReport);
    expect(
      parseWidgetDestination('bayantrack://fast-report'),
      WidgetDestination.fastReport,
    );
    expect(parseWidgetDestination('open_app'), WidgetDestination.openApp);
    expect(
      parseWidgetDestination('bayantrack://home'),
      WidgetDestination.openApp,
    );
    expect(parseWidgetDestination(''), isNull);
    expect(parseWidgetDestination('profile'), isNull);
    expect(parseWidgetDestination(42), isNull);
  });

  test('cold-start destination waits for restored authentication', () async {
    final bridge = WidgetBridge(
      invokeNative: (method, _) async =>
          method == 'getInitialWidgetDestination' ? 'fast_report' : null,
    );
    addTearDown(bridge.dispose);

    await bridge.initialize();
    expect(bridge.pendingDestination, WidgetDestination.fastReport);
    expect(bridge.takePendingDestination(), isNull);

    await bridge.syncAuthenticated(true);
    expect(bridge.takePendingDestination(), WidgetDestination.fastReport);
    expect(bridge.takePendingDestination(), isNull);
    bridge.finishWidgetDestination();
  });

  test(
    'logged-out destination remains pending until authentication succeeds',
    () async {
      final bridge = WidgetBridge(invokeNative: (_, _) async => null);
      addTearDown(bridge.dispose);

      bridge.ingestRaw('open_app');
      await bridge.syncAuthenticated(false);
      expect(bridge.takePendingDestination(), isNull);

      await bridge.syncAuthenticated(true);
      expect(bridge.takePendingDestination(), WidgetDestination.openApp);
      bridge.finishWidgetDestination();
    },
  );

  test(
    'already-authenticated taps expose each supported destination once',
    () async {
      final bridge = WidgetBridge(invokeNative: (_, _) async => null);
      addTearDown(bridge.dispose);
      await bridge.syncAuthenticated(true);

      bridge.ingestRaw('fast_report');
      expect(bridge.takePendingDestination(), WidgetDestination.fastReport);
      expect(bridge.takePendingDestination(), isNull);
      bridge.finishWidgetDestination();

      bridge.ingestRaw('open_app');
      expect(bridge.takePendingDestination(), WidgetDestination.openApp);
      bridge.finishWidgetDestination();
    },
  );

  test('duplicate pending intent is ignored', () async {
    final bridge = WidgetBridge(invokeNative: (_, _) async => null);
    addTearDown(bridge.dispose);
    await bridge.syncAuthenticated(true);

    bridge.ingestRaw('fast_report');
    bridge.ingestRaw('fast_report');
    expect(bridge.takePendingDestination(), WidgetDestination.fastReport);
    expect(bridge.takePendingDestination(), isNull);
    bridge.finishWidgetDestination();
  });

  test(
    'Fast Report destination waits for authentication like every widget entry',
    () async {
      final bridge = WidgetBridge(invokeNative: (_, _) async => null);
      addTearDown(bridge.dispose);

      bridge.ingestRaw('fast_report');
      expect(bridge.takePendingDestination(), isNull);
      await bridge.syncAuthenticated(true);
      expect(bridge.takePendingDestination(), WidgetDestination.fastReport);
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

    bridge.ingestRaw('fast_report');
    expect(bridge.takePendingDestination(), WidgetDestination.fastReport);
    bridge.ingestRaw('fast_report');

    expect(bridge.pendingDestination, isNull);
    expect(bridge.takePendingDestination(), isNull);
    bridge.finishWidgetDestination();

    bridge.ingestRaw('fast_report');
    expect(bridge.pendingDestination, isNull);
    expect(bridge.takePendingDestination(), isNull);

    bridge.clearFinishedDestinations();
    bridge.ingestRaw('fast_report');
    expect(bridge.takePendingDestination(), WidgetDestination.fastReport);
  });

  test(
    'acknowledges an intent delivered while the app is already running',
    () async {
      final channel = _RecordingWidgetChannel();
      final bridge = WidgetBridge(channel: channel);
      addTearDown(bridge.dispose);

      await bridge.initialize();
      channel.pendingDestination = 'fast_report';
      await channel.dispatch(
        const MethodCall('widgetDestination', 'fast_report'),
      );

      expect(bridge.pendingDestination, WidgetDestination.fastReport);
      expect(channel.pendingDestination, isNull);
      expect(channel.acknowledgedDestinations, ['fast_report']);
    },
  );

  test(
    'queues a different widget destination until the open route closes',
    () async {
      final bridge = WidgetBridge(invokeNative: (_, _) async => null);
      addTearDown(bridge.dispose);
      await bridge.syncAuthenticated(true);

      bridge.ingestRaw('fast_report');
      expect(bridge.takePendingDestination(), WidgetDestination.fastReport);
      bridge.ingestRaw('open_app');
      expect(bridge.pendingDestination, WidgetDestination.openApp);
      expect(bridge.takePendingDestination(), isNull);

      bridge.finishWidgetDestination();
      expect(bridge.takePendingDestination(), WidgetDestination.openApp);
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
