import 'dart:io';

import 'package:bayantrack_mobile/core/domain/failures.dart';
import 'package:bayantrack_mobile/core/domain/result.dart';
import 'package:bayantrack_mobile/features/auth/auth_di.dart';
import 'package:bayantrack_mobile/features/auth/data/auth_models.dart';
import 'package:bayantrack_mobile/features/auth/domain/auth_repository.dart';
import 'package:bayantrack_mobile/features/auth/domain/entities/user.dart';
import 'package:bayantrack_mobile/features/auth/presentation/profile_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _AuthRepositoryMock extends Mock implements AuthRepository {}

class _FileFake extends Fake implements File {}

User _user({
  String firstName = 'Synthetic',
  String? avatarUrl,
  int profileRevision = 4,
  int avatarRevision = 0,
}) => User(
  id: 'USR-1',
  email: 'synthetic@example.test',
  firstName: firstName,
  lastName: 'Citizen',
  phone: '+639123456789',
  avatarUrl: avatarUrl,
  profileRevision: profileRevision,
  avatarRevision: avatarRevision,
  role: UserRole.citizen,
);

void main() {
  setUpAll(() => registerFallbackValue(_FileFake()));

  test('profile update failure preserves previous profile data', () async {
    final repository = _AuthRepositoryMock();
    when(repository.getProfile).thenAnswer((_) async => Success(_user()));
    when(
      () => repository.updateProfile(
        firstName: 'Changed',
        lastName: 'Citizen',
        phone: '+639123456789',
        expectedRevision: 4,
      ),
    ).thenAnswer((_) async => const Err(ServerFailure('Unavailable')));
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      profileControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    await container.read(profileControllerProvider.future);

    await expectLater(
      container
          .read(profileControllerProvider.notifier)
          .updateProfile(
            const ProfileUpdateRequest(
              firstName: 'Changed',
              lastName: 'Citizen',
              phone: '+639123456789',
              expectedRevision: 4,
            ),
          ),
      throwsException,
    );

    final state = container.read(profileControllerProvider);
    expect(state.value?.firstName, 'Synthetic');
    expect(state.value?.profileRevision, 4);
    expect(state.hasError, isFalse);
  });

  test('avatar success refreshes URL and revision in provider state', () async {
    final repository = _AuthRepositoryMock();
    when(repository.getProfile).thenAnswer((_) async => Success(_user()));
    when(
      () => repository.uploadAvatar(
        any<File>(),
        onSendProgress: any<dynamic>(named: 'onSendProgress'),
      ),
    ).thenAnswer(
      (_) async => Success(
        _user(
          avatarUrl: '/api/auth/avatars/media-1/?v=2',
          profileRevision: 5,
          avatarRevision: 2,
        ),
      ),
    );
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      profileControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    await container.read(profileControllerProvider.future);

    await container
        .read(profileControllerProvider.notifier)
        .uploadAvatar(File('synthetic-avatar.jpg'));

    final profile = container.read(profileControllerProvider).requireValue;
    expect(profile.avatarUrl, '/api/auth/avatars/media-1/?v=2');
    expect(profile.avatarRevision, 2);
    expect(profile.profileRevision, 5);
  });
}
