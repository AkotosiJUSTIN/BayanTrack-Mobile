import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/auth_controller.dart';

/// Session-only cache. A disposed account scope cannot accept late responses.
class SessionContentCache {
  SessionContentCache({DateTime Function()? now}) : _now = now ?? DateTime.now;
  final DateTime Function() _now;
  final _entries = <String, ({Object value, DateTime accessed})>{};
  bool _closed = false;
  bool get isClosed => _closed;
  static const idleExpiry = Duration(minutes: 10);

  T? read<T>(String key) {
    if (_closed) return null;
    final entry = _entries.remove(key);
    if (entry == null || _now().difference(entry.accessed) >= idleExpiry) {
      return null;
    }
    _entries[key] = (value: entry.value, accessed: _now());
    return entry.value as T;
  }

  void write(String key, Object value) {
    if (_closed) return;
    _entries.removeWhere((_, e) => _now().difference(e.accessed) >= idleExpiry);
    _entries.remove(key);
    _entries[key] = (value: value, accessed: _now());
    final namespace = key.split(':').first;
    final keys = _entries.keys
        .where((k) => k.startsWith('$namespace:'))
        .toList();
    final limit = namespace == 'report' || namespace == 'verification' ? 20 : 1;
    while (keys.length > limit) {
      final removed = keys.removeAt(0);
      _entries.remove(removed);
      if (namespace == 'report') {
        _entries.remove(removed.replaceFirst('report:', 'verification:'));
      }
    }
  }

  void remove(String key) => _entries.remove(key);
  void close() {
    _closed = true;
    _entries.clear();
  }
}

final sessionContentCacheProvider = Provider<SessionContentCache>((ref) {
  ref.watch(
    authControllerProvider.select(
      (state) => state is AuthSuccess
          ? (
              state.user?.id,
              state.user?.role,
              state.user?.isActive,
              state.user?.requiresPasswordChange,
            )
          : null,
    ),
  );
  final cache = SessionContentCache();
  ref.onDispose(cache.close);
  return cache;
});

enum ContentFreshness { refreshing, current, stale }

class ContentFreshnessController
    extends Notifier<Map<String, ContentFreshness>> {
  @override
  Map<String, ContentFreshness> build() {
    ref.watch(sessionContentCacheProvider);
    return {};
  }

  void set(String key, ContentFreshness value) {
    final next = {...state, key: value};
    final reports = next.keys.where((k) => k.startsWith('report:')).toList();
    while (reports.length > 20) {
      next.remove(reports.removeAt(0));
    }
    state = next;
  }
}

final contentFreshnessProvider =
    NotifierProvider<ContentFreshnessController, Map<String, ContentFreshness>>(
      ContentFreshnessController.new,
    );
