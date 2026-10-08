import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/api_constants.dart';
import '../network/dio_provider.dart';
import 'connectivity_provider.dart';

enum BackendReachability { unknown, reachable, unreachable }

final backendReachabilityProvider =
    NotifierProvider<BackendReachabilityNotifier, BackendReachability>(
      BackendReachabilityNotifier.new,
    );

class BackendReachabilityNotifier extends Notifier<BackendReachability> {
  static const _probeInterval = Duration(seconds: 30);
  static const _probeTimeout = Duration(seconds: 4);

  Timer? _timer;
  Future<void>? _pendingProbe;
  late Dio _dio;

  @override
  BackendReachability build() {
    _dio = ref.watch(dioRawProvider);
    ref.listen<bool>(isOnlineProvider, (_, isOnline) {
      if (isOnline) {
        _startMonitoring();
      } else {
        _timer?.cancel();
        _timer = null;
        state = BackendReachability.unreachable;
      }
    });
    ref.onDispose(() => _timer?.cancel());

    if (ref.read(isOnlineProvider)) {
      Future<void>.microtask(_startMonitoring);
    } else {
      return BackendReachability.unreachable;
    }
    return BackendReachability.unknown;
  }

  Future<void> checkNow() => _pendingProbe ??= _probe().whenComplete(() {
    _pendingProbe = null;
  });

  void _startMonitoring() {
    _timer ??= Timer.periodic(_probeInterval, (_) => unawaited(checkNow()));
    unawaited(checkNow());
  }

  Future<void> _probe() async {
    try {
      final response = await _dio.get(
        ApiConstants.health,
        options: Options(
          connectTimeout: _probeTimeout,
          receiveTimeout: _probeTimeout,
        ),
      );
      state = response.statusCode != null && response.statusCode! < 500
          ? BackendReachability.reachable
          : BackendReachability.unreachable;
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      state = statusCode != null && statusCode < 500
          ? BackendReachability.reachable
          : BackendReachability.unreachable;
    } catch (_) {
      state = BackendReachability.unreachable;
    }
  }
}
