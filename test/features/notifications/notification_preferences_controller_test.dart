import 'dart:async';

import 'package:bayantrack_mobile/core/domain/failures.dart';
import 'package:bayantrack_mobile/core/domain/result.dart';
import 'package:bayantrack_mobile/core/presentation/widgets/civic_components.dart';
import 'package:bayantrack_mobile/core/theme/app_theme.dart';
import 'package:bayantrack_mobile/features/notifications/domain/entities/notification_preferences.dart';
import 'package:bayantrack_mobile/features/notifications/domain/notifications_repository.dart';
import 'package:bayantrack_mobile/features/notifications/notifications_di.dart';
import 'package:bayantrack_mobile/features/notifications/presentation/notification_settings_screen.dart';
import 'package:bayantrack_mobile/features/notifications/presentation/notifications_controller.dart';
import 'package:bayantrack_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _NotificationsRepositoryMock extends Mock
    implements NotificationsRepository {}

void _stubUpdate(
  _NotificationsRepositoryMock repository,
  Future<Result<NotificationPreferences>> Function(Invocation) answer,
) {
  when(
    () => repository.updatePreferences(
      emailEnabled: any(named: 'emailEnabled'),
      pushEnabled: any(named: 'pushEnabled'),
      notifyOnStatusChange: any(named: 'notifyOnStatusChange'),
      notifyOnComment: any(named: 'notifyOnComment'),
      notifyOnAssignment: any(named: 'notifyOnAssignment'),
    ),
  ).thenAnswer(answer);
}

void main() {
  for (final theme in [AppTheme.light, AppTheme.dark]) {
    testWidgets(
      'settings loading has no interactive switches in ${theme.brightness.name}',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final pending = Completer<NotificationPreferences>();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              notificationPreferencesControllerProvider.overrideWithBuild(
                (_, _) => pending.future,
              ),
            ],
            child: MaterialApp(
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              theme: theme,
              home: const NotificationSettingsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(CivicSkeletonBlock), findsWidgets);
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.bySemanticsLabel(RegExp(r'^Loading')), findsOneWidget);
        expect(find.byType(SwitchListTile), findsNothing);
        expect(tester.takeException(), isNull);

        pending.complete(NotificationPreferences.defaults);
        await tester.pumpAndSettle();

        expect(find.byType(CivicSkeletonBlock), findsNothing);
        expect(find.byType(SwitchListTile), findsNWidgets(5));
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('saving settings keeps the list and progress indicator', (
    tester,
  ) async {
    final repository = _NotificationsRepositoryMock();
    final pending = Completer<Result<NotificationPreferences>>();
    when(
      repository.getPreferences,
    ).thenAnswer((_) async => const Success(NotificationPreferences.defaults));
    _stubUpdate(repository, (_) => pending.future);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationsDomainRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const NotificationSettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Push Notifications'));
    await tester.pump();

    expect(find.byType(CivicSkeletonBlock), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(
      tester.widgetList<SwitchListTile>(find.byType(SwitchListTile)),
      everyElement(
        isA<SwitchListTile>().having(
          (tile) => tile.onChanged,
          'onChanged',
          isNull,
        ),
      ),
    );

    pending.complete(
      const Success(NotificationPreferences(pushEnabled: false)),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(
      tester
          .widget<SwitchListTile>(
            find.widgetWithText(SwitchListTile, 'Push Notifications'),
          )
          .value,
      isFalse,
    );
  });

  test(
    'successful save adopts returned preferences without stale refetch',
    () async {
      final repository = _NotificationsRepositoryMock();
      when(repository.getPreferences).thenAnswer(
        (_) async => const Success(NotificationPreferences.defaults),
      );
      _stubUpdate(
        repository,
        (_) async => const Success(NotificationPreferences(pushEnabled: false)),
      );
      final container = ProviderContainer(
        overrides: [
          notificationsDomainRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
      final subscription = container.listen(
        notificationPreferencesControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);
      await container.read(notificationPreferencesControllerProvider.future);

      await container
          .read(notificationPreferencesControllerProvider.notifier)
          .updatePreferences(pushEnabled: false);

      expect(
        container
            .read(notificationPreferencesControllerProvider)
            .requireValue
            .pushEnabled,
        isFalse,
      );
    },
  );

  testWidgets('save failure preserves values and Retry resubmits one field', (
    tester,
  ) async {
    final repository = _NotificationsRepositoryMock();
    final updates = <Map<Symbol, dynamic>>[];
    var attempt = 0;
    when(
      repository.getPreferences,
    ).thenAnswer((_) async => const Success(NotificationPreferences.defaults));
    _stubUpdate(repository, (invocation) async {
      updates.add(invocation.namedArguments);
      attempt += 1;
      if (attempt == 1) {
        return const Err(ServerFailure('Save unavailable'));
      }
      return const Success(NotificationPreferences(pushEnabled: false));
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationsDomainRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const NotificationSettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Push Notifications'));
    await tester.pumpAndSettle();

    expect(find.text('Save unavailable'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(updates.single[#pushEnabled], isFalse);
    expect(updates.single[#emailEnabled], isNull);
    expect(updates.single[#notifyOnStatusChange], isNull);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(updates, hasLength(2));
    expect(find.text('Save unavailable'), findsNothing);
    final pushSwitch = tester.widget<SwitchListTile>(
      find.widgetWithText(SwitchListTile, 'Push Notifications'),
    );
    expect(pushSwitch.value, isFalse);
  });
}
