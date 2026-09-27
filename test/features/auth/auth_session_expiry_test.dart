import 'dart:async';

import 'package:bayantrack_mobile/features/auth/auth_di.dart';
import 'package:bayantrack_mobile/features/auth/domain/auth_session_repository.dart';
import 'package:bayantrack_mobile/features/auth/domain/entities/user.dart';
import 'package:bayantrack_mobile/features/auth/presentation/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _SessionRepository extends Mock implements AuthSessionRepository {
  final changes = StreamController<bool>.broadcast(sync: true);

  @override
  Stream<bool> get authStateChanges => changes.stream;
}

void main() {
  test(
    'widget destinations require a user without a forced password change',
    () {
      const eligibleUser = User(
        id: 'citizen-1',
        email: 'citizen@example.test',
        firstName: 'Test',
        lastName: 'Citizen',
        role: UserRole.citizen,
      );
      const passwordChangeUser = User(
        id: 'citizen-2',
        email: 'citizen2@example.test',
        firstName: 'Test',
        lastName: 'Citizen',
        role: UserRole.citizen,
        passwordChangeRequired: true,
      );

      expect(
        AuthSuccess('active', eligibleUser).mayOpenWidgetDestination,
        isTrue,
      );
      expect(
        AuthSuccess(
          'password change required',
          passwordChangeUser,
        ).mayOpenWidgetDestination,
        isFalse,
      );
      expect(const AuthSuccess().mayOpenWidgetDestination, isFalse);
    },
  );

  test(
    'cleared session returns an authenticated controller to sign-in',
    () async {
      final sessionRepository = _SessionRepository();
      final container = ProviderContainer(
        overrides: [
          authSessionRepositoryProvider.overrideWithValue(sessionRepository),
        ],
      );
      addTearDown(() async {
        await sessionRepository.changes.close();
        container.dispose();
      });

      final subscription = container.listen(authControllerProvider, (_, _) {});
      final controller = container.read(authControllerProvider.notifier);
      controller.state = const AuthSuccess();
      sessionRepository.changes.add(false);
      await Future<void>.delayed(Duration.zero);

      expect(container.read(authControllerProvider), isA<AuthIdle>());
      subscription.close();
    },
  );
}
