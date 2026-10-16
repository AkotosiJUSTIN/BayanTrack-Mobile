import 'dart:async';
import 'dart:io';

import 'package:bayantrack_mobile/core/constants/api_constants.dart';
import 'package:bayantrack_mobile/core/domain/failures.dart';
import 'package:bayantrack_mobile/core/domain/result.dart';
import 'package:bayantrack_mobile/core/presentation/widgets/civic_components.dart';
import 'package:bayantrack_mobile/core/providers/backend_reachability_provider.dart';
import 'package:bayantrack_mobile/core/theme/app_theme.dart';
import 'package:bayantrack_mobile/features/auth/data/auth_models.dart';
import 'package:bayantrack_mobile/features/auth/presentation/barangays_provider.dart';
import 'package:bayantrack_mobile/features/kyc/domain/entities/kyc_enums.dart';
import 'package:bayantrack_mobile/features/kyc/domain/entities/kyc_status.dart';
import 'package:bayantrack_mobile/features/kyc/domain/kyc_repository.dart';
import 'package:bayantrack_mobile/features/kyc/kyc_di.dart';
import 'package:bayantrack_mobile/features/kyc/presentation/kyc_controller.dart';
import 'package:bayantrack_mobile/features/kyc/presentation/kyc_status_screen.dart';
import 'package:bayantrack_mobile/features/notifications/domain/entities/notification_preferences.dart';
import 'package:bayantrack_mobile/features/notifications/domain/notifications_repository.dart';
import 'package:bayantrack_mobile/features/notifications/notifications_di.dart';
import 'package:bayantrack_mobile/features/notifications/presentation/notification_settings_screen.dart';
import 'package:bayantrack_mobile/features/reports/data/report_cache_store.dart';
import 'package:bayantrack_mobile/features/reports/data/repositories/reports_repository_impl.dart';
import 'package:bayantrack_mobile/features/reports/domain/entities/report.dart';
import 'package:bayantrack_mobile/features/reports/domain/entities/report_enums.dart';
import 'package:bayantrack_mobile/features/reports/domain/entities/blockchain_verification.dart';
import 'package:bayantrack_mobile/features/reports/domain/reports_repository.dart';
import 'package:bayantrack_mobile/features/reports/presentation/report_detail_controller.dart';
import 'package:bayantrack_mobile/features/reports/presentation/report_detail_screen.dart';
import 'package:bayantrack_mobile/features/reports/reports_di.dart';
import 'package:bayantrack_mobile/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;

class _Reports extends Mock implements ReportsRepository {}

class _Kyc extends Mock implements KycRepository {}

class _Prefs extends Mock implements NotificationsRepository {}

class _Dio extends Mock implements Dio {}

class _Storage extends Mock implements FlutterSecureStorage {}

class _Municipalities extends Municipalities {
  @override
  FutureOr<List<MunicipalityModel>> build() => const [
    bundledUrdanetaMunicipality,
  ];
}

class _Reachability extends BackendReachabilityNotifier {
  @override
  BackendReachability build() => BackendReachability.reachable;
}

const _report = Report(
  id: 'QA-LEAF3',
  title: 'Synthetic QA drainage',
  description: 'Synthetic QA only.',
  assignedDepartment: 'City Engineering Office',
  respondingAgency: 'Bureau of Fire Protection',
);

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  required List<Override> overrides,
  Locale locale = const Locale('en'),
  bool dark = false,
  double width = 360,
  double textScale = 1,
}) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        municipalitiesProvider.overrideWith(_Municipalities.new),
        backendReachabilityProvider.overrideWith(_Reachability.new),
        ...overrides,
      ],
      child: MaterialApp(
        locale: locale,
        theme: dark ? AppTheme.dark : AppTheme.light,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: child,
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  testWidgets('report refresh retains visible content until replacement', (
    tester,
  ) async {
    final repository = _Reports();
    final delayed = Completer<Result<Report>>();
    var attempt = 0;
    when(() => repository.getReport(_report.id)).thenAnswer(
      (_) => attempt++ == 0
          ? Future.value(const Success(_report))
          : delayed.future,
    );
    await _pump(
      tester,
      const ReportDetailScreen(reportId: 'QA-LEAF3'),
      overrides: [
        reportsRepositoryDomainProvider.overrideWithValue(repository),
      ],
    );
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(ReportDetailScreen));
    final container = ProviderScope.containerOf(context);
    final refresh = container
        .read(reportDetailControllerProvider(_report.id).notifier)
        .refresh();
    await tester.pump();
    expect(find.text(_report.title!), findsOneWidget);
    expect(find.byType(CivicSkeletonBlock), findsNothing);
    delayed.complete(
      const Success(
        Report(
          id: 'QA-LEAF3',
          title: 'Updated report',
          description: 'Synthetic QA only.',
        ),
      ),
    );
    await refresh;
    await tester.pumpAndSettle();
    expect(find.text('Updated report'), findsOneWidget);
  });

  testWidgets(
    'KYC refresh retains visible status then exposes outage and retry',
    (tester) async {
      final repository = _Kyc();
      final delayed = Completer<Result<KycStatusEntity>>();
      var attempt = 0;
      when(repository.getKycStatus).thenAnswer(
        (_) => attempt++ == 1
            ? delayed.future
            : Future.value(
                const Success(
                  KycStatusEntity(status: KycVerificationStatus.pending),
                ),
              ),
      );
      await _pump(
        tester,
        const KycStatusScreen(),
        overrides: [kycDomainRepositoryProvider.overrideWithValue(repository)],
      );
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(
        tester.element(find.byType(KycStatusScreen)),
      );
      final visibleTexts = tester
          .widgetList<Text>(find.byType(Text))
          .map((text) => text.data)
          .toList();
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();
      expect(
        tester
            .widgetList<Text>(find.byType(Text))
            .map((text) => text.data)
            .toList(),
        visibleTexts,
      );
      expect(find.byType(CivicSkeletonBlock), findsNothing);
      delayed.complete(const Err(NetworkFailure('Synthetic outage')));
      await tester.pumpAndSettle();
      expect(find.text(l10n.requestNetworkError), findsOneWidget);
      expect(find.text(l10n.verifyIdentity), findsNothing);
      await tester.tap(find.text(l10n.retry));
      await tester.pumpAndSettle();
      expect(find.text(l10n.requestNetworkError), findsNothing);
      verify(repository.getKycStatus).called(3);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'initial KYC outage presents error instead of verification action',
    (tester) async {
      final repository = _Kyc();
      when(
        repository.getKycStatus,
      ).thenAnswer((_) async => const Err(NetworkFailure('Synthetic outage')));
      await _pump(
        tester,
        const KycStatusScreen(),
        overrides: [kycDomainRepositoryProvider.overrideWithValue(repository)],
      );
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(
        tester.element(find.byType(KycStatusScreen)),
      );
      expect(find.text(l10n.requestNetworkError), findsOneWidget);
      expect(find.text(l10n.verifyIdentity), findsNothing);
      expect(find.byType(CivicSkeletonBlock), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  for (final locale in ['en', 'fil']) {
    for (final dark in [false, true]) {
      final suffix = '$locale dark=$dark narrow=320 text=2x';
      testWidgets('loaded report metadata and actions fit $suffix', (
        tester,
      ) async {
        final report = Report(
          id: _report.id,
          title: _report.title,
          description: _report.description,
          respondingAgency: _report.respondingAgency,
          assignedDepartment: _report.assignedDepartment,
          streetLandmark: 'Synthetic QA street and landmark',
          barangay: 'Synthetic QA barangay',
          cityMunicipality: 'Urdaneta City',
          province: 'Pangasinan',
          category: ReportCategory.engineeringInfrastructure,
          status: ReportStatus.resolved,
          queuePriorityLevel: PriorityLevel.critical,
          blockchainSynced: true,
          createdAt: DateTime(2026, 10, 5),
        );
        await _pump(
          tester,
          const ReportDetailScreen(reportId: 'QA-LEAF3'),
          locale: Locale(locale),
          dark: dark,
          width: 320,
          textScale: 2,
          overrides: [
            reportDetailControllerProvider.overrideWithBuild(
              (_, _) async => report,
            ),
          ],
        );
        await tester.pumpAndSettle();
        for (var i = 0; i < 8; i++) {
          await tester.drag(
            find.byType(CustomScrollView),
            const Offset(0, -300),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      });

      for (final status in [
        KycVerificationStatus.unverified,
        KycVerificationStatus.pending,
        KycVerificationStatus.verified,
        KycVerificationStatus.rejected,
      ]) {
        testWidgets('KYC delayed transition to ${status.name} fits $suffix', (
          tester,
        ) async {
          final delayed = Completer<KycStatusEntity?>();
          await _pump(
            tester,
            const KycStatusScreen(),
            locale: Locale(locale),
            dark: dark,
            width: 320,
            textScale: 2,
            overrides: [
              kycStatusControllerProvider.overrideWithBuild(
                (_, _) => delayed.future,
              ),
            ],
          );
          expect(find.byType(CivicSkeletonBlock), findsWidgets);
          delayed.complete(
            KycStatusEntity(
              status: status,
              fullName: status == KycVerificationStatus.unverified
                  ? ''
                  : 'Synthetic QA Citizen',
              rejectionReason: status == KycVerificationStatus.rejected
                  ? 'Synthetic QA reason'
                  : null,
            ),
          );
          await tester.pumpAndSettle();
          expect(find.byType(CivicSkeletonBlock), findsNothing);
          final l10n = AppLocalizations.of(
            tester.element(find.byType(KycStatusScreen)),
          );
          final expected = switch (status) {
            KycVerificationStatus.unverified => l10n.noVerificationSubmitted,
            KycVerificationStatus.pending => l10n.pendingReview,
            KycVerificationStatus.verified => l10n.kycVerified,
            _ => l10n.rejected,
          };
          expect(find.text(expected), findsWidgets);
          await tester.drag(
            find.byType(SingleChildScrollView),
            const Offset(0, -500),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });
      }
      testWidgets('report initial skeleton and localized semantics $suffix', (
        tester,
      ) async {
        final delayed = Completer<Report>();
        final semantics = tester.ensureSemantics();
        await _pump(
          tester,
          const ReportDetailScreen(reportId: 'QA-LEAF3'),
          locale: Locale(locale),
          dark: dark,
          width: 320,
          textScale: 2,
          overrides: [
            reportDetailControllerProvider.overrideWithBuild(
              (_, _) => delayed.future,
            ),
          ],
        );
        final l10n = AppLocalizations.of(
          tester.element(find.byType(ReportDetailScreen)),
        );
        expect(tester.takeException(), isNull);
        expect(
          find.byType(CivicSkeletonBlock),
          findsWidgets,
          reason:
              'Checklist requires neutral content placeholders, not a centered spinner.',
        );
        expect(find.bySemanticsLabel(l10n.loading), findsWidgets);
        semantics.dispose();
      });

      testWidgets('KYC initial skeleton, no invented identity $suffix', (
        tester,
      ) async {
        final delayed = Completer<KycStatusEntity?>();
        final semantics = tester.ensureSemantics();
        await _pump(
          tester,
          const KycStatusScreen(),
          locale: Locale(locale),
          dark: dark,
          width: 320,
          textScale: 2,
          overrides: [
            kycStatusControllerProvider.overrideWithBuild(
              (_, _) => delayed.future,
            ),
          ],
        );
        final l10n = AppLocalizations.of(
          tester.element(find.byType(KycStatusScreen)),
        );
        expect(tester.takeException(), isNull);
        expect(find.text('Waiting for review'), findsNothing);
        expect(find.text('Verify Identity'), findsNothing);
        expect(find.byType(CivicSkeletonBlock), findsWidgets);
        expect(find.bySemanticsLabel(l10n.loading), findsWidgets);
        semantics.dispose();
      });

      testWidgets('preferences initial five rows, no switches $suffix', (
        tester,
      ) async {
        final delayed = Completer<Result<NotificationPreferences>>();
        final prefs = _Prefs();
        when(prefs.getPreferences).thenAnswer((_) => delayed.future);
        final semantics = tester.ensureSemantics();
        await _pump(
          tester,
          const NotificationSettingsScreen(),
          locale: Locale(locale),
          dark: dark,
          width: 320,
          textScale: 2,
          overrides: [
            notificationsDomainRepositoryProvider.overrideWithValue(prefs),
          ],
        );
        final l10n = AppLocalizations.of(
          tester.element(find.byType(NotificationSettingsScreen)),
        );
        expect(find.byType(SwitchListTile), findsNothing);
        expect(tester.takeException(), isNull);
        expect(
          find.byType(CivicSkeletonBlock),
          findsNWidgets(15),
          reason: 'Five neutral preference rows, with three blocks per row.',
        );
        expect(find.bySemanticsLabel(l10n.loading), findsWidgets);
        semantics.dispose();
      });
    }
  }

  testWidgets(
    'report delayed load reveals responder separate from current handler',
    (tester) async {
      final delayed = Completer<Report>();
      await _pump(
        tester,
        const ReportDetailScreen(reportId: 'QA-LEAF3'),
        overrides: [
          reportDetailControllerProvider.overrideWithBuild(
            (_, _) => delayed.future,
          ),
        ],
      );
      expect(find.text(_report.title!), findsNothing);
      delayed.complete(_report);
      await tester.pumpAndSettle();
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(find.text('Responded by'), findsOneWidget);
      expect(find.text('Bureau of Fire Protection'), findsOneWidget);
      expect(find.text('City Engineering Office'), findsOneWidget);
      expect(find.byType(CivicSkeletonBlock), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('report without responder does not invent Responded by', (
    tester,
  ) async {
    await _pump(
      tester,
      const ReportDetailScreen(reportId: 'QA-LEAF3'),
      overrides: [
        reportDetailControllerProvider.overrideWithBuild(
          (_, _) async => const Report(
            id: 'QA-LEAF3',
            description: 'Synthetic QA only.',
            assignedDepartment: 'City Engineering Office',
          ),
        ),
      ],
    );
    await tester.pumpAndSettle();
    expect(find.text('Responded by'), findsNothing);
    expect(find.text('Team handling this report'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('loaded report fits narrow phone with enlarged text', (
    tester,
  ) async {
    await _pump(
      tester,
      const ReportDetailScreen(reportId: 'QA-LEAF3'),
      width: 320,
      textScale: 2,
      overrides: [
        reportDetailControllerProvider.overrideWithBuild(
          (_, _) async => _report,
        ),
      ],
    );
    await tester.pumpAndSettle();
    final error = tester.takeException();
    if (error != null) throw error;
  });

  for (final locale in ['en', 'fil']) {
    for (final screen in ['report', 'kyc', 'preferences']) {
      testWidgets('$screen exposes localized loading announcement $locale', (
        tester,
      ) async {
        final semantics = tester.ensureSemantics();
        final report = Completer<Report>();
        final kyc = Completer<KycStatusEntity?>();
        final prefs = _Prefs();
        final delayedPrefs = Completer<Result<NotificationPreferences>>();
        when(prefs.getPreferences).thenAnswer((_) => delayedPrefs.future);
        final child = switch (screen) {
          'report' => const ReportDetailScreen(reportId: 'QA-LEAF3'),
          'kyc' => const KycStatusScreen(),
          _ => const NotificationSettingsScreen(),
        };
        await _pump(
          tester,
          child,
          locale: Locale(locale),
          overrides: [
            reportDetailControllerProvider.overrideWithBuild(
              (_, _) => report.future,
            ),
            kycStatusControllerProvider.overrideWithBuild((_, _) => kyc.future),
            notificationsDomainRepositoryProvider.overrideWithValue(prefs),
          ],
        );
        final l10n = AppLocalizations.of(
          tester.element(find.byType(child.runtimeType)),
        );
        expect(find.bySemanticsLabel(l10n.loading), findsWidgets);
        semantics.dispose();
      });
    }
  }

  testWidgets('report error leaves initial loading and retry recovers', (
    tester,
  ) async {
    var attempt = 0;
    await _pump(
      tester,
      const ReportDetailScreen(reportId: 'QA-LEAF3'),
      overrides: [
        reportDetailControllerProvider.overrideWithBuild((_, _) async {
          if (attempt++ == 0) throw StateError('Synthetic outage');
          return _report;
        }),
      ],
    );
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pump();
    await tester.ensureVisible(find.text('Try again'));
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text(_report.title!), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('preferences failed load leaves spinner and retry recovers', (
    tester,
  ) async {
    final prefs = _Prefs();
    var attempt = 0;
    when(prefs.getPreferences).thenAnswer(
      (_) async => attempt++ == 0
          ? const Err(ServerFailure('Synthetic outage'))
          : const Success(NotificationPreferences(pushEnabled: false)),
    );
    await _pump(
      tester,
      const NotificationSettingsScreen(),
      overrides: [
        notificationsDomainRepositoryProvider.overrideWithValue(prefs),
      ],
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    final tile = tester.widget<SwitchListTile>(
      find.widgetWithText(SwitchListTile, 'Push Notifications'),
    );
    expect(tile.value, isFalse);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('delayed preference save keeps list and disables switches', (
    tester,
  ) async {
    final prefs = _Prefs();
    final delayed = Completer<Result<NotificationPreferences>>();
    when(
      prefs.getPreferences,
    ).thenAnswer((_) async => const Success(NotificationPreferences.defaults));
    when(
      () => prefs.updatePreferences(
        emailEnabled: any(named: 'emailEnabled'),
        pushEnabled: any(named: 'pushEnabled'),
        notifyOnStatusChange: any(named: 'notifyOnStatusChange'),
        notifyOnComment: any(named: 'notifyOnComment'),
        notifyOnAssignment: any(named: 'notifyOnAssignment'),
      ),
    ).thenAnswer((_) => delayed.future);
    await _pump(
      tester,
      const NotificationSettingsScreen(),
      overrides: [
        notificationsDomainRepositoryProvider.overrideWithValue(prefs),
      ],
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Push Notifications'));
    await tester.pump();
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.byType(CivicSkeletonBlock), findsNothing);
    for (final tile in tester.widgetList<SwitchListTile>(
      find.byType(SwitchListTile),
    )) {
      expect(tile.onChanged, isNull);
    }
    delayed.complete(
      const Success(NotificationPreferences(pushEnabled: false)),
    );
    await tester.pumpAndSettle();
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('blockchain action keeps spinner during delayed verification', (
    tester,
  ) async {
    final repo = _Reports();
    final delayed = Completer<Result<BlockchainVerificationResult>>();
    when(
      () => repo.getReport('QA-LEAF3'),
    ).thenAnswer((_) async => const Success(_report));
    when(
      () => repo.verifyReport('QA-LEAF3', cachedOnly: true),
    ).thenAnswer((_) async => const Err(ServerFailure('No saved proof')));
    when(() => repo.verifyReport('QA-LEAF3')).thenAnswer((_) => delayed.future);
    await _pump(
      tester,
      const ReportDetailScreen(reportId: 'QA-LEAF3'),
      overrides: [reportsRepositoryDomainProvider.overrideWithValue(repo)],
    );
    await tester.pump();
    final scroll = tester.state<ScrollableState>(find.byType(Scrollable).first);
    scroll.position.jumpTo(scroll.position.maxScrollExtent);
    await tester.pump();
    final initialExtent = scroll.position.maxScrollExtent;
    // Automatic verification is already running when fresh details arrive.
    expect(find.text('Check record'), findsNothing);
    expect(scroll.position.maxScrollExtent, initialExtent);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(CivicSkeletonBlock), findsNothing);
    expect(find.text(_report.title!), findsOneWidget);
    delayed.complete(
      const Success(
        BlockchainVerificationResult(
          reportId: 'QA-LEAF3',
          verified: true,
          blockchainData: {},
          auditHistory: [],
          message: 'Synthetic integrity success',
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });

  test('report refresh retains data during delayed backend read', () async {
    final repo = _Reports();
    final delayed = Completer<Result<Report>>();
    var attempt = 0;
    when(() => repo.getReport('QA-LEAF3')).thenAnswer(
      (_) => attempt++ == 0
          ? Future.value(const Success(_report))
          : delayed.future,
    );
    final container = ProviderContainer(
      overrides: [reportsRepositoryDomainProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    final sub = container.listen(
      reportDetailControllerProvider('QA-LEAF3'),
      (_, _) {},
    );
    addTearDown(sub.close);
    await container.read(reportDetailControllerProvider('QA-LEAF3').future);
    final refresh = container
        .read(reportDetailControllerProvider('QA-LEAF3').notifier)
        .refresh();
    final retained = container
        .read(reportDetailControllerProvider('QA-LEAF3'))
        .asData
        ?.value;
    delayed.complete(const Success(_report));
    await refresh;
    expect(retained?.title, _report.title);
  });

  test(
    'KYC refresh retains pending state during delayed backend read',
    () async {
      final repo = _Kyc();
      final delayed = Completer<Result<KycStatusEntity>>();
      var attempt = 0;
      when(repo.getKycStatus).thenAnswer(
        (_) => attempt++ == 0
            ? Future.value(
                const Success(
                  KycStatusEntity(status: KycVerificationStatus.pending),
                ),
              )
            : delayed.future,
      );
      final container = ProviderContainer(
        overrides: [kycDomainRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      final sub = container.listen(kycStatusControllerProvider, (_, _) {});
      addTearDown(sub.close);
      await container.read(kycStatusControllerProvider.future);
      final refresh = container
          .read(kycStatusControllerProvider.notifier)
          .refresh();
      final retained = container
          .read(kycStatusControllerProvider)
          .asData
          ?.value;
      delayed.complete(
        const Success(KycStatusEntity(status: KycVerificationStatus.pending)),
      );
      await refresh;
      expect(retained?.status, KycVerificationStatus.pending);
    },
  );

  test('KYC outage must not masquerade as no submission', () async {
    final repo = _Kyc();
    when(
      repo.getKycStatus,
    ).thenAnswer((_) async => const Err(NetworkFailure('Synthetic outage')));
    final container = ProviderContainer(
      overrides: [kycDomainRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    await expectLater(
      container.read(kycStatusControllerProvider.future),
      throwsA(anything),
    );
  });

  test(
    'responding agency survives secure detail cache offline fallback',
    () async {
      final storage = _Storage();
      final values = <String, String>{};
      when(
        () => storage.read(key: any(named: 'key')),
      ).thenAnswer((i) async => values[i.namedArguments[#key]]);
      when(
        () => storage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((i) async {
        values[i.namedArguments[#key] as String] =
            i.namedArguments[#value] as String;
      });
      final cache = ReportCacheStore(storage);
      final dio = _Dio();
      final path = ApiConstants.reportById('QA-LEAF3');
      when(() => dio.get(path)).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: path),
          statusCode: 200,
          data: {
            'id': 'QA-LEAF3',
            'description': 'Synthetic QA only.',
            'responding_agency': 'Bureau of Fire Protection',
          },
        ),
      );
      final repository = ReportsRepositoryImpl(
        dio,
        cache: cache,
        currentOwnerId: () => 'QA-owner',
      );
      expect(
        (await repository.getReport('QA-LEAF3')).dataOrNull?.respondingAgency,
        'Bureau of Fire Protection',
      );
      when(() => dio.get(path)).thenThrow(
        DioException.connectionError(
          requestOptions: RequestOptions(path: path),
          reason: 'Synthetic outage',
          error: const SocketException('Synthetic outage'),
        ),
      );
      final stale = await repository.getReport('QA-LEAF3');
      expect(stale.dataOrNull?.isStale, isTrue);
      expect(stale.dataOrNull?.respondingAgency, 'Bureau of Fire Protection');
    },
  );
}
