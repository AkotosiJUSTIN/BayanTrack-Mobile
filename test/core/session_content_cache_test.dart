import 'package:bayantrack_mobile/core/providers/session_content_cache.dart';
import 'package:bayantrack_mobile/features/auth/presentation/auth_controller.dart';
import 'package:bayantrack_mobile/features/auth/domain/entities/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class TestAuth extends AuthController {
  @override
  AuthState build() => const AuthSuccess(
    null,
    User(
      id: 'a',
      email: 'a@test.invalid',
      firstName: 'A',
      lastName: 'Test',
      role: UserRole.citizen,
    ),
  );
  void change(AuthState value) => state = value;
}

void main() {
  test('report cache has 20 LRU entries and evicts matching proof', () {
    final cache = SessionContentCache();
    for (var i = 0; i < 20; i++) {
      cache.write('report:$i', i);
    }
    cache.write('verification:1', 'proof');
    cache.write('incident:1', 'summary');
    expect(cache.read<int>('report:0'), 0);
    cache.write('report:20', 20);
    expect(cache.read<int>('report:1'), isNull);
    expect(cache.read<String>('verification:1'), isNull);
    expect(cache.read<String>('incident:1'), isNull);
    expect(cache.read<int>('report:0'), 0);
  });
  test(
    'incident summaries retain 20 entries and group invalidation preserves other content',
    () {
      final cache = SessionContentCache();
      for (var i = 0; i < 21; i++) {
        cache.write('incident:$i', i);
      }
      expect(cache.read<int>('incident:0'), isNull);
      expect(cache.read<int>('incident:1'), 1);
      cache.write('report:r', 'report');
      cache.write('verification:r', 'proof');
      cache.write('profile:me', 'profile');
      cache.removeReports();
      expect(cache.read<int>('incident:1'), isNull);
      expect(cache.read<String>('report:r'), isNull);
      expect(cache.read<String>('verification:r'), isNull);
      expect(cache.read<String>('profile:me'), 'profile');
    },
  );
  test('idle expiry touches access and expires at ten minutes', () {
    var time = DateTime.utc(2026);
    final cache = SessionContentCache(now: () => time);
    cache.write('profile:me', 'profile');
    time = time.add(const Duration(minutes: 9));
    expect(cache.read<String>('profile:me'), 'profile');
    time = time.add(const Duration(minutes: 10));
    expect(cache.read<String>('profile:me'), isNull);
  });
  test(
    'logout clears and closes old cache; late writes cannot repopulate it',
    () async {
      final container = ProviderContainer(
        overrides: [authControllerProvider.overrideWith(TestAuth.new)],
      );
      addTearDown(container.dispose);
      final cache = container.read(sessionContentCacheProvider);
      cache.write('report:r', 'private');
      (container.read(authControllerProvider.notifier) as TestAuth).change(
        const AuthIdle(),
      );
      await container.pump();
      final next = container.read(sessionContentCacheProvider);
      expect(cache.isClosed, isTrue);
      cache.write('report:r', 'late');
      expect(cache.read<String>('report:r'), isNull);
      expect(next.read<String>('report:r'), isNull);
    },
  );
  test('role/permission context change gets a new cache', () async {
    final container = ProviderContainer(
      overrides: [authControllerProvider.overrideWith(TestAuth.new)],
    );
    addTearDown(container.dispose);
    final cache = container.read(sessionContentCacheProvider);
    (container.read(authControllerProvider.notifier) as TestAuth).change(
      const AuthSuccess(
        null,
        User(
          id: 'a',
          email: 'a@test.invalid',
          firstName: 'A',
          lastName: 'Test',
          role: UserRole.officer,
        ),
      ),
    );
    await container.pump();
    expect(
      identical(container.read(sessionContentCacheProvider), cache),
      isFalse,
    );
    expect(cache.isClosed, isTrue);
  });
}
