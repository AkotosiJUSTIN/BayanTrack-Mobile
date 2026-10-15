import 'dart:async';

import 'package:bayantrack_mobile/core/domain/failures.dart';
import 'package:bayantrack_mobile/core/domain/result.dart';
import 'package:bayantrack_mobile/core/presentation/widgets/offline_stale_banner.dart';
import 'package:bayantrack_mobile/core/providers/backend_reachability_provider.dart';
import 'package:bayantrack_mobile/features/auth/presentation/auth_controller.dart';
import 'package:bayantrack_mobile/features/auth/data/user_permissions.dart';
import 'package:bayantrack_mobile/features/auth/domain/entities/user.dart';
import 'package:bayantrack_mobile/features/reports/domain/entities/paginated_reports.dart';
import 'package:bayantrack_mobile/features/reports/domain/entities/report.dart';
import 'package:bayantrack_mobile/features/reports/domain/entities/report_enums.dart';
import 'package:bayantrack_mobile/features/reports/data/report_create_outbox.dart';
import 'package:bayantrack_mobile/features/reports/data/report_draft_store.dart';
import 'package:bayantrack_mobile/features/reports/domain/reports_repository.dart';
import 'package:bayantrack_mobile/features/reports/domain/usecases/get_my_reports_usecase.dart';
import 'package:bayantrack_mobile/features/reports/presentation/my_reports_screen.dart';
import 'package:bayantrack_mobile/features/reports/reports_di.dart';
import 'package:bayantrack_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _ReportsRepositoryMock extends Mock implements ReportsRepository {}

class _OutboxMock extends Mock implements ReportCreateOutbox {}

class _TestReachability extends BackendReachabilityNotifier {
  @override
  BackendReachability build() => BackendReachability.reachable;
}

final _cachedReport = Report(
  id: 'report-a',
  title: 'Saved report A',
  description: 'Cached report details',
  status: ReportStatus.inProgress,
  isStale: true,
);

Widget _app(ReportsRepository repository) => ProviderScope(
  overrides: [
    getMyReportsUseCaseProvider.overrideWithValue(
      GetMyReportsUseCase(repository: repository),
    ),
    userPermissionsProvider.overrideWithValue(UserPermissions(null)),
    backendReachabilityProvider.overrideWith(_TestReachability.new),
  ],
  child: MaterialApp(
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: const MyReportsScreen(),
  ),
);

Widget _handoffApp(
  ReportsRepository repository,
  ReportCreateOutboxItem item, {
  ReportCreateOutbox? outbox,
}) => ProviderScope(
  overrides: [
    getMyReportsUseCaseProvider.overrideWithValue(
      GetMyReportsUseCase(repository: repository),
    ),
    userPermissionsProvider.overrideWithValue(UserPermissions(null)),
    backendReachabilityProvider.overrideWith(_TestReachability.new),
    authControllerProvider.overrideWithValue(
      const AuthSuccess(
        'test',
        User(
          id: 'user-a',
          email: 'citizen@example.test',
          firstName: 'Test',
          lastName: 'Citizen',
          role: UserRole.citizen,
        ),
      ),
    ),
    reportCreateOutboxItemsProvider.overrideWith(
      (ref, ownerId) async => ownerId == 'user-a' ? [item] : [],
    ),
    if (outbox != null) reportCreateOutboxProvider.overrideWithValue(outbox),
  ],
  child: MaterialApp(
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: const MyReportsScreen(),
  ),
);

void main() {
  testWidgets('rejected pending report discard requires confirmation', (
    tester,
  ) async {
    final repository = _ReportsRepositoryMock();
    when(
      () => repository.getMyReports(
        page: 1,
        pageSize: 20,
        status: null,
        sortBy: 'date',
      ),
    ).thenAnswer(
      (_) async => const Success(PaginatedReports(results: [], total: 0)),
    );
    final outbox = _OutboxMock();
    when(() => outbox.discard('user-a', 'rejected-1')).thenAnswer((_) async {});
    final now = DateTime.utc(2026, 10, 12);
    final item = ReportCreateOutboxItem(
      schemaVersion: ReportCreateOutboxItem.currentSchemaVersion,
      localReportId: 'rejected-1',
      ownerId: 'user-a',
      type: ReportDraftType.emergency,
      createdAt: now,
      updatedAt: now,
      idempotencyKey: 'rejected-key',
      payload: const {'isEmergency': true},
      attachmentRefs: const [],
      status: ReportCreateOutboxStatus.rejected,
      errorKind: ReportCreateOutboxErrorKind.validation,
      safeError: 'Description cannot be empty',
    );
    await tester.pumpWidget(_handoffApp(repository, item, outbox: outbox));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard Draft'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keep Draft'));
    await tester.pumpAndSettle();
    verifyNever(() => outbox.discard('user-a', 'rejected-1'));
    await tester.tap(find.text('Discard Draft'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Discard Draft').last);
    await tester.pumpAndSettle();
    verify(() => outbox.discard('user-a', 'rejected-1')).called(1);
    expect(tester.takeException(), isNull);
  });
  testWidgets('My Reports shows stale state with cached rows', (tester) async {
    final repository = _ReportsRepositoryMock();
    when(
      () => repository.getMyReports(
        page: 1,
        pageSize: 20,
        status: null,
        sortBy: 'date',
      ),
    ).thenAnswer(
      (_) async => Success(
        PaginatedReports(results: [_cachedReport], total: 1, isStale: true),
      ),
    );

    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    expect(find.text('Saved report A'), findsOneWidget);
    expect(find.byType(OfflineStaleBanner), findsOneWidget);
  });

  testWidgets('failed My Reports refresh preserves cached rows', (
    tester,
  ) async {
    final repository = _ReportsRepositoryMock();
    final refresh = Completer<Result<PaginatedReports>>();
    var calls = 0;
    when(
      () => repository.getMyReports(
        page: 1,
        pageSize: 20,
        status: null,
        sortBy: 'date',
      ),
    ).thenAnswer((_) async {
      calls++;
      if (calls == 1) {
        return Success(PaginatedReports(results: [_cachedReport], total: 1));
      }
      return refresh.future;
    });

    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();
    final refreshing = tester
        .widget<RefreshIndicator>(find.byType(RefreshIndicator))
        .onRefresh();
    await tester.pump();
    expect(find.text('Saved report A'), findsOneWidget);

    refresh.complete(const Err(NetworkFailure('offline')));
    await refreshing;
    await tester.pumpAndSettle();

    expect(calls, 2);
    expect(find.text('Saved report A'), findsOneWidget);
    expect(find.byType(OfflineStaleBanner), findsOneWidget);
  });

  testWidgets('synced report shows retry when evidence handoff is pending', (
    tester,
  ) async {
    final repository = _ReportsRepositoryMock();
    when(
      () => repository.getMyReports(
        page: 1,
        pageSize: 20,
        status: null,
        sortBy: 'date',
      ),
    ).thenAnswer(
      (_) async => const Success(PaginatedReports(results: [], total: 0)),
    );
    final now = DateTime.utc(2026, 9, 28);
    final item = ReportCreateOutboxItem(
      schemaVersion: ReportCreateOutboxItem.currentSchemaVersion,
      localReportId: 'local-1',
      ownerId: 'user-a',
      type: ReportDraftType.emergency,
      createdAt: now,
      updatedAt: now,
      idempotencyKey: 'operation-1',
      payload: const {'isEmergency': true},
      attachmentRefs: const ['/private/draft_1.jpg'],
      status: ReportCreateOutboxStatus.synced,
      serverReportId: 'server-1',
    );

    await tester.pumpWidget(_handoffApp(repository, item));
    await tester.pumpAndSettle();

    expect(
      find.text('Report received. Evidence is still waiting to upload.'),
      findsOneWidget,
    );
    expect(find.text('Try uploading again'), findsOneWidget);
    expect(find.text('Not sent yet'), findsNothing);
  });

  testWidgets('uncertain emergency send does not claim receipt', (
    tester,
  ) async {
    final repository = _ReportsRepositoryMock();
    when(
      () => repository.getMyReports(
        page: 1,
        pageSize: 20,
        status: null,
        sortBy: 'date',
      ),
    ).thenAnswer(
      (_) async => const Success(PaginatedReports(results: [], total: 0)),
    );
    final now = DateTime.utc(2026, 9, 28);
    final item = ReportCreateOutboxItem(
      schemaVersion: ReportCreateOutboxItem.currentSchemaVersion,
      localReportId: 'local-emergency',
      ownerId: 'user-a',
      type: ReportDraftType.emergency,
      createdAt: now,
      updatedAt: now,
      idempotencyKey: 'operation-emergency',
      payload: const {'isEmergency': true},
      attachmentRefs: const [],
      status: ReportCreateOutboxStatus.retryWaiting,
      attemptCount: 1,
      nextAttemptAt: now.add(const Duration(seconds: 10)),
      errorKind: ReportCreateOutboxErrorKind.network,
      safeError: 'Will retry when connection returns.',
    );

    await tester.pumpWidget(_handoffApp(repository, item));
    await tester.pumpAndSettle();

    expect(
      find.text('Will retry safely when BayanTrack is reachable.'),
      findsOneWidget,
    );
    expect(find.text('Not sent yet'), findsOneWidget);
    expect(
      find.textContaining('BayanTrack has not confirmed receipt'),
      findsOneWidget,
    );
    expect(find.textContaining('BayanTrack has not received'), findsNothing);
    expect(find.text('Discard Draft'), findsNothing);
  });
}
