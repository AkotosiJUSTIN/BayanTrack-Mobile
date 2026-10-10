import 'dart:async';

import 'package:bayantrack_mobile/core/realtime/realtime_contract.dart';
import 'package:bayantrack_mobile/core/providers/connectivity_provider.dart';
import 'package:bayantrack_mobile/core/providers/backend_reachability_provider.dart';
import 'package:bayantrack_mobile/features/system_governance/system_governance_gate.dart';
import 'package:bayantrack_mobile/features/system_governance/system_governance_models.dart';
import 'package:bayantrack_mobile/features/system_governance/system_governance_provider.dart';
import 'package:bayantrack_mobile/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _unrestricted = SystemGovernanceState(
  maintenanceEnabled: false,
  maintenanceMessage: '',
  termsAcceptanceRequired: false,
  latestTermsVersion: 'version-2',
  acceptedTermsVersion: 'version-2',
);
const _pending = SystemGovernanceState(
  maintenanceEnabled: false,
  maintenanceMessage: '',
  termsAcceptanceRequired: true,
  latestTermsVersion: 'version-2',
  acceptedTermsVersion: 'version-1',
);

PublishedTerms _terms(String version) => PublishedTerms(
  versionId: version,
  checksum: 'checksum-$version',
  translations: {
    'en': const LegalTranslation(
      title: 'Published English Terms',
      terms: 'English terms from the superadmin.',
      privacy: 'English privacy from the superadmin.',
    ),
    'fil': const LegalTranslation(
      title: 'Mga tuntuning inilathala',
      terms: 'Mga bagong tuntunin mula sa superadmin.',
      privacy: 'Bagong pribasiya mula sa superadmin.',
    ),
  },
);

class _Repository extends SystemGovernanceRepository {
  _Repository() : super(Dio());

  SystemGovernanceState currentStatus = _pending;
  PublishedTerms document = _terms('version-2');
  Future<SystemGovernanceState>? nextStatus;
  bool statusUnavailable = false;
  bool termsUnavailable = false;
  int termsReads = 0;
  bool staleAcceptance = false;
  final consentCalls = <Map<String, String>>[];

  @override
  Future<SystemGovernanceState> status() async {
    if (statusUnavailable) throw StateError('Offline');
    return nextStatus ?? Future.value(currentStatus);
  }

  @override
  Future<PublishedTerms> currentTerms() async {
    termsReads++;
    if (termsUnavailable) throw StateError('Terms unavailable');
    return document;
  }

  @override
  Future<void> accept(PublishedTerms terms, String language) async {
    consentCalls.add(terms.consent(language));
    if (staleAcceptance) {
      document = _terms('version-3');
      final request = RequestOptions(path: '/legal/terms/accept/');
      throw DioException.badResponse(
        statusCode: 409,
        requestOptions: request,
        response: Response(
          requestOptions: request,
          statusCode: 409,
          data: {'code': 'terms_version_stale'},
        ),
      );
    }
    currentStatus = _unrestricted;
  }
}

class _Connectivity extends ConnectivityNotifier {
  _Connectivity(this.online);
  final bool online;
  @override
  bool build() => online;
}

class _Reachability extends BackendReachabilityNotifier {
  _Reachability(this.reachability);
  final BackendReachability reachability;
  @override
  BackendReachability build() => reachability;
}

Future<ProviderContainer> _pump(
  WidgetTester tester,
  _Repository repository, {
  String language = 'en',
  double textScale = 1,
  bool online = true,
  BackendReachability reachability = BackendReachability.reachable,
}) async {
  tester.view.physicalSize = const Size(320, 568);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      systemGovernanceRepositoryProvider.overrideWithValue(repository),
      isOnlineProvider.overrideWith(() => _Connectivity(online)),
      backendReachabilityProvider.overrideWith(
        () => _Reachability(reachability),
      ),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: Locale(language),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const SystemGovernanceGate(
          child: Scaffold(body: Text('Ordinary workspace')),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('account check never renders cached pending consent', (
    tester,
  ) async {
    final repository = _Repository();
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        systemGovernanceRepositoryProvider.overrideWithValue(repository),
        isOnlineProvider.overrideWith(() => _Connectivity(true)),
        backendReachabilityProvider.overrideWith(
          () => _Reachability(BackendReachability.reachable),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container.read(systemGovernanceProvider.future);
    final accountStatus = Completer<SystemGovernanceState>();
    repository.nextStatus = accountStatus.future;
    container.invalidate(systemGovernanceProvider);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SystemGovernanceGate(
            child: Scaffold(body: Text('Ordinary workspace')),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(CurrentTermsScreen), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('Ordinary workspace'), findsNothing);
    expect(
      find.byKey(const Key('governance-emergency-button')),
      findsOneWidget,
    );
    accountStatus.complete(_unrestricted);
    await tester.pumpAndSettle();
    expect(find.text('Ordinary workspace'), findsOneWidget);
    expect(repository.consentCalls, isEmpty);
  });

  testWidgets('current terms can be read without recording consent', (
    tester,
  ) async {
    final repository = _Repository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          systemGovernanceRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: CurrentTermsScreen(readOnly: true),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text(repository.document.translation('en').title),
      findsOneWidget,
    );
    expect(
      find.text(repository.document.translation('en').content),
      findsOneWidget,
    );
    expect(find.byKey(const Key('governance-consent-checkbox')), findsNothing);
    expect(find.byKey(const Key('governance-accept-button')), findsNothing);
    expect(repository.consentCalls, isEmpty);
  });

  testWidgets('offline status failure leaves local workspace available', (
    tester,
  ) async {
    final repository = _Repository()..statusUnavailable = true;
    final container = await _pump(tester, repository, online: false);
    expect(find.text('Ordinary workspace'), findsOneWidget);
    expect(
      permitsReportSnapshot(container.read(systemGovernanceProvider), {
        'isEmergency': false,
      }),
      isFalse,
    );
    expect(repository.consentCalls, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('offline access does not bypass known pending terms', (
    tester,
  ) async {
    await _pump(tester, _Repository(), online: false);
    expect(find.byType(CurrentTermsScreen), findsOneWidget);
    expect(find.text('Ordinary workspace'), findsNothing);
  });

  testWidgets('connected Wi-Fi without backend still permits local work', (
    tester,
  ) async {
    final repository = _Repository()..statusUnavailable = true;
    final container = await _pump(
      tester,
      repository,
      reachability: BackendReachability.unreachable,
    );
    expect(find.text('Ordinary workspace'), findsOneWidget);
    expect(container.read(isOnlineProvider), isTrue);
    expect(
      permitsReportSnapshot(container.read(systemGovernanceProvider), {
        'isEmergency': false,
      }),
      isFalse,
    );
  });

  testWidgets('read-only terms expose retry when the server is unavailable', (
    tester,
  ) async {
    final repository = _Repository()..termsUnavailable = true;
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          systemGovernanceRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: CurrentTermsScreen(readOnly: true),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SelectableText), findsNothing);
    repository.termsUnavailable = false;
    await tester.tap(find.widgetWithIcon(OutlinedButton, Icons.refresh));
    await tester.pumpAndSettle();
    expect(
      find.text(repository.document.translation('en').content),
      findsOneWidget,
    );
    expect(repository.termsReads, 2);
    expect(repository.consentCalls, isEmpty);
  });

  for (final language in ['en', 'fil']) {
    for (final scale in [1.0, 2.0]) {
      testWidgets(
        'published $language terms and explicit consent at ${scale}x',
        (tester) async {
          final repository = _Repository();
          await _pump(tester, repository, language: language, textScale: scale);
          expect(
            find.text(repository.document.translation(language).title),
            findsOneWidget,
          );
          expect(find.text('Ordinary workspace'), findsNothing);
          final accept = find.byKey(const Key('governance-accept-button'));
          expect(tester.widget<FilledButton>(accept).onPressed, isNull);
          expect(
            tester
                .widget<OutlinedButton>(
                  find.byKey(const Key('governance-emergency-button')),
                )
                .onPressed,
            isNotNull,
          );
          expect(tester.takeException(), isNull);
          final checkbox = find.byKey(const Key('governance-consent-checkbox'));
          await tester.ensureVisible(checkbox);
          await tester.tap(checkbox);
          await tester.pump();
          await tester.ensureVisible(accept);
          await tester.tap(accept);
          await tester.pumpAndSettle();
          expect(repository.consentCalls, [
            repository.document.consent(language),
          ]);
          expect(find.text('Ordinary workspace'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('stale acceptance reloads terms and requires a new checkbox', (
    tester,
  ) async {
    final repository = _Repository()..staleAcceptance = true;
    await _pump(tester, repository);
    final checkbox = find.byKey(const Key('governance-consent-checkbox'));
    await tester.ensureVisible(checkbox);
    await tester.tap(checkbox);
    await tester.pump();
    await tester.ensureVisible(
      find.byKey(const Key('governance-accept-button')),
    );
    await tester.tap(find.byKey(const Key('governance-accept-button')));
    await tester.pumpAndSettle();
    expect(find.text('Ordinary workspace'), findsNothing);
    expect(
      tester
          .widget<CheckboxListTile>(
            find.byKey(const Key('governance-consent-checkbox')),
          )
          .value,
      isFalse,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const Key('governance-accept-button')),
          )
          .onPressed,
      isNull,
    );
    expect(repository.consentCalls.single['terms_version_id'], 'version-2');
  });

  testWidgets(
    'maintenance keeps ordinary reading and displays server message',
    (tester) async {
      final repository = _Repository()
        ..currentStatus = const SystemGovernanceState(
          maintenanceEnabled: true,
          maintenanceMessage: 'Scheduled server maintenance',
          termsAcceptanceRequired: false,
        );
      await _pump(tester, repository, textScale: 2);
      expect(find.text('Ordinary workspace'), findsOneWidget);
      expect(find.text('Scheduled server maintenance'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('long maintenance notices remain bounded on small screens', (
    tester,
  ) async {
    final message = List.filled(100, 'Scheduled maintenance notice.').join(' ');
    final repository = _Repository()
      ..currentStatus = SystemGovernanceState(
        maintenanceEnabled: true,
        maintenanceMessage: message,
        termsAcceptanceRequired: false,
      );
    await _pump(tester, repository, textScale: 2);
    expect(find.text(message), findsOneWidget);
    expect(find.text('Ordinary workspace'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('malformed status fails closed and never permits ordinary mutation', () {
    expect(() => SystemGovernanceState.fromJson({}), throwsFormatException);
    expect(
      permitsReportSnapshot(const AsyncLoading(), {'isEmergency': false}),
      isFalse,
    );
    expect(
      permitsReportSnapshot(const AsyncLoading(), {'isEmergency': true}),
      isTrue,
    );
  });

  test('late refresh cannot erase a newer server restriction', () async {
    final repository = _Repository()..currentStatus = _unrestricted;
    final container = ProviderContainer(
      overrides: [
        systemGovernanceRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    await container.read(systemGovernanceProvider.future);
    final pending = Completer<SystemGovernanceState>();
    repository.nextStatus = pending.future;
    final controller = container.read(systemGovernanceProvider.notifier);
    final refreshing = controller.refresh();
    controller.noteRestriction('maintenance_read_only');
    pending.complete(_unrestricted);
    await refreshing;
    expect(
      container.read(systemGovernanceProvider).requireValue.maintenanceEnabled,
      isTrue,
    );
  });

  test(
    'repeated restrictions do not retrigger queue resume listeners',
    () async {
      final repository = _Repository()..currentStatus = _unrestricted;
      final container = ProviderContainer(
        overrides: [
          systemGovernanceRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
      await container.read(systemGovernanceProvider.future);
      var notifications = 0;
      container.listen(systemGovernanceProvider, (_, _) => notifications++);
      final controller = container.read(systemGovernanceProvider.notifier);
      controller.noteRestriction('maintenance_read_only');
      controller.noteRestriction('maintenance_read_only');
      controller.noteRestriction('maintenance_read_only');
      expect(notifications, 1);
    },
  );

  test(
    'system realtime invalidation does not masquerade as a report event',
    () {
      final event = RealtimeEvent.tryParse({
        'version': 1,
        'event_id': 'system-event-1',
        'name': 'system.state_changed',
        'entity': {'kind': 'system', 'id': 'maintenance'},
        'occurred_at': '2026-10-06T04:00:00Z',
        'correlation_id': 'system-event-1',
      });
      expect(event, isNotNull);
      expect(invalidationTargets(event!), {RealtimeTarget.system});
    },
  );
}
