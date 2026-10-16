import 'dart:async';
import 'package:bayantrack_mobile/core/domain/result.dart';
import 'package:bayantrack_mobile/core/domain/failures.dart';
import 'package:bayantrack_mobile/core/providers/session_content_cache.dart';
import 'package:bayantrack_mobile/features/auth/auth_di.dart';
import 'package:bayantrack_mobile/features/auth/data/auth_models.dart';
import 'package:bayantrack_mobile/features/auth/domain/auth_repository.dart';
import 'package:bayantrack_mobile/features/auth/domain/entities/user.dart';
import 'package:bayantrack_mobile/features/auth/presentation/profile_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class Repo extends Mock implements AuthRepository {}

const user = User(
  id: 'u',
  email: 'test@example.invalid',
  firstName: 'Test',
  lastName: 'User',
  role: UserRole.citizen,
);
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'cached profile survives refresh failure with freshness indicator',
    () async {
      final repo = Repo();
      final cache = SessionContentCache()
        ..write(
          'profile:me',
          const UserProfile(
            id: 'u',
            email: 'test@example.invalid',
            firstName: 'Saved',
          ),
        );
      when(
        repo.getProfile,
      ).thenAnswer((_) async => const Err(ServerFailure('offline')));
      final c = ProviderContainer(
        overrides: [
          sessionContentCacheProvider.overrideWithValue(cache),
          authRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(c.dispose);
      final sub = c.listen(profileControllerProvider, (_, _) {});
      addTearDown(sub.close);
      expect(
        (await c.read(profileControllerProvider.future)).firstName,
        'Saved',
      );
      await c.pump();
      await Future<void>.delayed(Duration.zero);
      expect(c.read(profileControllerProvider).value?.firstName, 'Saved');
      expect(
        c.read(contentFreshnessProvider)['profile:me'],
        ContentFreshness.stale,
      );
    },
  );
  test(
    'old session refresh response cannot overwrite new session profile',
    () async {
      final repo = Repo();
      final late = Completer<Result<User>>();
      var calls = 0;
      when(repo.getProfile).thenAnswer((_) async {
        calls++;
        if (calls == 2) return late.future;
        return Success(
          User(
            id: 'u',
            email: 'test@example.invalid',
            firstName: calls >= 3 ? 'New account' : 'Original',
            lastName: 'User',
            role: UserRole.citizen,
          ),
        );
      });
      final c = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(repo),
          sessionContentCacheProvider.overrideWith((ref) {
            final cache = SessionContentCache();
            ref.onDispose(cache.close);
            return cache;
          }),
        ],
      );
      addTearDown(c.dispose);
      final sub = c.listen(profileControllerProvider, (_, _) {});
      addTearDown(sub.close);
      await c.read(profileControllerProvider.future);
      final pending = c.read(profileControllerProvider.notifier).reload();
      c.invalidate(sessionContentCacheProvider);
      await c.pump();
      await c.read(profileControllerProvider.future);
      late.complete(const Success(user));
      await pending;
      expect(c.read(profileControllerProvider).value?.firstName, 'New account');
    },
  );
}
