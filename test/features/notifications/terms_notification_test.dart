import 'package:bayantrack_mobile/features/auth/data/user_permissions.dart';
import 'package:bayantrack_mobile/features/notifications/data/notification_models.dart'
    as dto;
import 'package:bayantrack_mobile/features/notifications/data/mappers/notification_mapper.dart';
import 'package:bayantrack_mobile/features/notifications/domain/entities/notification.dart';
import 'package:bayantrack_mobile/features/notifications/domain/entities/notification_type.dart';
import 'package:bayantrack_mobile/features/notifications/domain/entities/paginated_notifications.dart';
import 'package:bayantrack_mobile/features/notifications/notification_payload.dart';
import 'package:bayantrack_mobile/features/notifications/presentation/notification_navigation.dart';
import 'package:bayantrack_mobile/features/notifications/presentation/notifications_controller.dart';
import 'package:bayantrack_mobile/features/notifications/presentation/notifications_screen.dart';
import 'package:bayantrack_mobile/features/system_governance/system_governance_models.dart';
import 'package:bayantrack_mobile/features/system_governance/system_governance_provider.dart';
import 'package:bayantrack_mobile/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _PolicyRepository extends SystemGovernanceRepository {
  _PolicyRepository({this.requiresAcceptance = false}) : super(Dio());
  bool requiresAcceptance;
  int acceptances = 0;
  int termsReads = 0;

  @override
  Future<SystemGovernanceState> status() async => SystemGovernanceState(
    maintenanceEnabled: false,
    maintenanceMessage: '',
    termsAcceptanceRequired: requiresAcceptance,
    latestTermsVersion: 'new-version',
    acceptedTermsVersion: requiresAcceptance ? 'old-version' : 'new-version',
  );

  @override
  Future<PublishedTerms> currentTerms() async {
    termsReads++;
    return const PublishedTerms(
      versionId: 'new-version',
      checksum: 'new-checksum',
      translations: {
        'en': LegalTranslation(
          title: 'Updated policy',
          terms: 'Latest terms published by the Superadmin.',
          privacy: 'Latest privacy text.',
        ),
      },
    );
  }

  @override
  Future<void> accept(PublishedTerms terms, String language) async {
    acceptances++;
    requiresAcceptance = false;
  }
}

class _PolicyNotifications extends NotificationsController {
  static final readIds = <String>[];

  @override
  Future<PaginatedNotifications> build() async => const PaginatedNotifications(
    unreadCount: 1,
    count: 1,
    results: [
      NotificationEntity(
        id: 'policy-notification',
        title: 'Terms and privacy policy updated',
        message: 'Please review the updated terms.',
        type: NotificationType.termsUpdated,
      ),
    ],
  );

  @override
  Future<void> markAsRead(String id) async => readIds.add(id);
}

Future<void> _pump(
  WidgetTester tester,
  _PolicyRepository repository, {
  bool inbox = false,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        systemGovernanceRepositoryProvider.overrideWithValue(repository),
        notificationsControllerProvider.overrideWith(_PolicyNotifications.new),
        userPermissionsProvider.overrideWithValue(UserPermissions(null)),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: inbox
            ? const NotificationsScreen()
            : Consumer(
                builder: (context, ref, _) => Scaffold(
                  body: TextButton(
                    onPressed: () => openNotificationDestination(context, ref, {
                      'type': 'terms_updated',
                    }),
                    child: const Text('Open policy alert'),
                  ),
                ),
              ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test('policy notification DTO and domain preserve the policy type', () {
    final notification = dto.AppNotification.fromJson({
      'id': 'policy-1',
      'title': 'Policy updated',
      'message': 'Review the updated terms.',
      'type': 'terms_updated',
    });
    expect(notification.toJson()['type'], 'terms_updated');
    expect(
      NotificationMapper.toNotificationEntity(notification).type,
      NotificationType.termsUpdated,
    );
    expect(
      NotificationType.fromString('terms_updated'),
      NotificationType.termsUpdated,
    );
  });

  test(
    'local policy payload preserves type and version without a report ID',
    () {
      const data = {
        'type': 'terms_updated',
        'terms_version_id': 'new-version',
        'event_id': 'terms:new-version',
      };
      expect(decodeNotificationPayload(encodeNotificationPayload(data)), data);
      expect(decodeNotificationPayload('old-report-id'), {
        'report_id': 'old-report-id',
      });
      expect(decodeNotificationPayload(null), isEmpty);
      expect(decodeNotificationPayload('{broken json'), isEmpty);
    },
  );

  testWidgets('inbox policy tap marks read and opens current terms', (
    tester,
  ) async {
    _PolicyNotifications.readIds.clear();
    final repository = _PolicyRepository();
    await _pump(tester, repository, inbox: true);
    expect(find.byIcon(Icons.policy_outlined), findsOneWidget);
    await tester.tap(find.text('Terms and privacy policy updated'));
    await tester.pumpAndSettle();
    expect(_PolicyNotifications.readIds, ['policy-notification']);
    expect(find.text('Updated policy'), findsOneWidget);
    expect(find.textContaining('Latest terms published'), findsOneWidget);
    expect(find.byKey(const Key('governance-consent-checkbox')), findsNothing);
    expect(repository.acceptances, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'push destination requires explicit acceptance only when pending',
    (tester) async {
      final repository = _PolicyRepository(requiresAcceptance: true);
      await _pump(tester, repository);
      await tester.tap(find.text('Open policy alert'));
      await tester.pumpAndSettle();
      expect(find.text('Updated policy'), findsOneWidget);
      final consent = find.byKey(const Key('governance-consent-checkbox'));
      expect(consent, findsOneWidget);
      expect(repository.acceptances, 0);
      await tester.ensureVisible(consent);
      await tester.tap(consent);
      await tester.pumpAndSettle();
      final accept = find.byKey(const Key('governance-accept-button'));
      await tester.ensureVisible(accept);
      await tester.tap(accept);
      await tester.pumpAndSettle();
      expect(repository.acceptances, 1);
      expect(
        find.byKey(const Key('governance-consent-checkbox')),
        findsNothing,
      );
      expect(find.text('Updated policy'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
