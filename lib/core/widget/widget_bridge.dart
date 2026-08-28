import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _widgetChannelName = 'bayantrack/widget';

enum WidgetDestination { quickReport, emergencyReport, notifications }

WidgetDestination? parseWidgetDestination(Object? raw) {
  if (raw is! String) return null;

  return switch (raw.trim().toLowerCase()) {
    'quick_report' ||
    'quick-report' ||
    'quickreport' => WidgetDestination.quickReport,
    'emergency_report' ||
    'emergency-report' ||
    'emergencyreport' => WidgetDestination.emergencyReport,
    'notifications' || 'notification' => WidgetDestination.notifications,
    _ => null,
  };
}

String widgetLocaleCode(Locale locale) =>
    locale.languageCode.toLowerCase() == 'fil' ? 'fil' : 'en';

class WidgetDestinationQueue {
  WidgetDestination? _pending;

  WidgetDestination? get pending => _pending;

  bool enqueue(WidgetDestination destination) {
    if (_pending == destination) return false;
    _pending = destination;
    return true;
  }

  WidgetDestination? take() {
    final destination = _pending;
    _pending = null;
    return destination;
  }

  void restore(WidgetDestination destination) {
    _pending ??= destination;
  }
}

typedef WidgetNativeInvoker =
    Future<dynamic> Function(String method, Object? arguments);

class WidgetBridge {
  WidgetBridge({
    MethodChannel? channel,
    WidgetNativeInvoker? invokeNative,
    WidgetDestinationQueue? destinationQueue,
  }) : _channel = channel ?? const MethodChannel(_widgetChannelName),
       _invokeNative = invokeNative,
       _destinationQueue = destinationQueue ?? WidgetDestinationQueue();

  final MethodChannel _channel;
  final WidgetNativeInvoker? _invokeNative;
  final WidgetDestinationQueue _destinationQueue;
  final StreamController<WidgetDestination> _destinationController =
      StreamController<WidgetDestination>.broadcast();

  String _locale = 'en';
  bool _authenticated = false;
  int _unreadCount = 0;
  Map<String, Object>? _lastSentState;
  bool _initialized = false;

  Stream<WidgetDestination> get destinations => _destinationController.stream;

  WidgetDestination? get pendingDestination => _destinationQueue.pending;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    _channel.setMethodCallHandler(_handleMethodCall);

    try {
      ingestRaw(await _invoke('getInitialWidgetDestination', null));
    } catch (_) {
      // Widget integration is Android-only; missing native support is safe.
    }
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == 'widgetDestination') {
      ingestRaw(call.arguments);
    }
    return null;
  }

  void ingestRaw(Object? raw) {
    final destination = parseWidgetDestination(raw);
    if (destination == null || !_destinationQueue.enqueue(destination)) return;
    _destinationController.add(destination);
  }

  WidgetDestination? takePendingDestination() =>
      _authenticated ? _destinationQueue.take() : null;

  void restoreDestination(WidgetDestination destination) {
    _destinationQueue.restore(destination);
  }

  Future<void> syncLocale(Locale locale) {
    _locale = widgetLocaleCode(locale);
    return _sendState();
  }

  Future<void> syncAuthenticated(bool authenticated) {
    _authenticated = authenticated;
    if (!authenticated) _unreadCount = 0;
    return _sendState();
  }

  Future<void> syncUnreadCount(int unreadCount) {
    if (!_authenticated) return Future<void>.value();
    _unreadCount = unreadCount < 0 ? 0 : unreadCount;
    return _sendState();
  }

  Future<void> _sendState() async {
    final state = <String, Object>{
      'locale': _locale,
      'authenticated': _authenticated,
      'unreadCount': _unreadCount,
    };
    if (_lastSentState?['locale'] == state['locale'] &&
        _lastSentState?['authenticated'] == state['authenticated'] &&
        _lastSentState?['unreadCount'] == state['unreadCount']) {
      return;
    }
    _lastSentState = state;

    try {
      await _invoke('updateState', state);
    } catch (_) {
      _lastSentState = null;
    }
  }

  Future<dynamic> _invoke(String method, Object? arguments) {
    final invokeNative = _invokeNative;
    return invokeNative == null
        ? _channel.invokeMethod(method, arguments)
        : invokeNative(method, arguments);
  }

  void dispose() {
    if (_initialized) _channel.setMethodCallHandler(null);
    unawaited(_destinationController.close());
  }
}

final widgetBridgeProvider = Provider<WidgetBridge>((ref) {
  final bridge = WidgetBridge();
  ref.onDispose(bridge.dispose);
  return bridge;
});
