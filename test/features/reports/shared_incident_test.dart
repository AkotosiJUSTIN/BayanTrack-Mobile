import 'dart:async';

import 'package:bayantrack_mobile/core/domain/failures.dart';
import 'package:bayantrack_mobile/core/domain/result.dart';
import 'package:bayantrack_mobile/features/home/presentation/widgets/home_report_card.dart';
import 'package:bayantrack_mobile/features/notifications/data/mappers/notification_mapper.dart';
import 'package:bayantrack_mobile/features/notifications/data/notification_models.dart'
    as dto;
import 'package:bayantrack_mobile/features/notifications/domain/entities/notification_type.dart';
import 'package:bayantrack_mobile/features/reports/data/repositories/shared_incident_repository_impl.dart';
import 'package:bayantrack_mobile/features/reports/domain/entities/report.dart';
import 'package:bayantrack_mobile/features/reports/domain/entities/shared_incident.dart';
import 'package:bayantrack_mobile/features/reports/domain/shared_incident_repository.dart';
import 'package:bayantrack_mobile/features/reports/presentation/report_detail_controller.dart';
import 'package:bayantrack_mobile/features/reports/presentation/shared_incident_provider.dart';
import 'package:bayantrack_mobile/features/reports/presentation/widgets/shared_incident_section.dart';
import 'package:bayantrack_mobile/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Dio extends Mock implements Dio {}

class _Repository extends Mock implements SharedIncidentRepository {}

class _CancelToken extends Fake implements CancelToken {}

const _summary = SharedIncident(
  groupId: 'group-1',
  status: 'in_progress',
  reportCount: 3,
  assignedDepartment: 'City Engineering',
  integrityStatus: 'pending',
  canReportMismatch: true,
  updates: [
    IncidentUpdate(
      id: 'update-1',
      kind: 'progress',
      message: 'Drainage clearing has started.',
    ),
  ],
);

Map<String, dynamic> _payload() => {
  'group_id': 'group-1',
  'status': 'in_progress',
  'report_count': 3,
  'assigned_department': 'City Engineering',
  'needs_review': true,
  'can_report_mismatch': true,
  'updates': [
    {
      'id': 'update-1',
      'kind': 'progress',
      'message': 'Clearing started',
      'created_at': '2026-10-15T08:00:00Z',
    },
  ],
  'evidence': [
    {'id': 'photo-1', 'url': '/media/approved.jpg'},
  ],
  'integrity': {'status': 'pending', 'tx_hash': '0x123'},
  'reports': [
    {'report_id': 'never-displayed'},
  ],
};

Future<void> _pump(
  WidgetTester tester,
  _Repository repository, {
  Future<SharedIncident?> Function()? load,
  Widget? child,
}) async {
  tester.view.physicalSize = const Size(320, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedIncidentRepositoryProvider.overrideWithValue(repository),
        reportDetailControllerProvider.overrideWithBuild(
          (_, _) async => const Report(
            id: 'report-1',
            description: 'Own report',
            incidentGroupId: 'group-1',
          ),
        ),
        sharedIncidentProvider(
          'report-1',
        ).overrideWith((_) => load?.call() ?? Future.value(_summary)),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: child ?? const SharedIncidentSection(reportId: 'report-1'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  setUpAll(() => registerFallbackValue(_CancelToken()));

  test(
    'summary maps only public incident fields and handles no membership',
    () async {
      final dio = _Dio();
      when(
        () => dio.get<Map<String, dynamic>>(
          '/reports/report-1/incident/',
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {'incident': _payload()},
          requestOptions: RequestOptions(path: '/'),
        ),
      );
      final repository = SharedIncidentRepositoryImpl(dio);
      final result = await repository.getIncident('report-1');
      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.groupId, 'group-1');
      expect(result.dataOrNull?.reportCount, 3);
      expect(result.dataOrNull?.needsReview, isTrue);
      expect(result.dataOrNull?.canReportMismatch, isTrue);
      expect(result.dataOrNull?.evidence.single.url, '/media/approved.jpg');
      expect(
        result.dataOrNull?.updates.single.createdAt,
        DateTime.utc(2026, 10, 15, 8).toLocal(),
      );
      expect(result.dataOrNull?.integrityStatus, 'pending');
      when(
        () => dio.get<Map<String, dynamic>>(
          '/reports/report-1/incident/',
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {'incident': null},
          requestOptions: RequestOptions(path: '/'),
        ),
      );
      expect((await repository.getIncident('report-1')).dataOrNull, isNull);
    },
  );

  test(
    'public and legacy responses cannot grant owner feedback actions',
    () async {
      final dio = _Dio();
      final payload = _payload()..remove('can_report_mismatch');
      when(
        () => dio.get<Map<String, dynamic>>(
          '/reports/report-1/incident/',
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {'incident': payload},
          requestOptions: RequestOptions(path: '/'),
        ),
      );
      final repository = SharedIncidentRepositoryImpl(dio);
      expect(
        (await repository.getIncident(
          'report-1',
        )).dataOrNull?.canReportMismatch,
        isFalse,
      );
      payload['can_report_mismatch'] = false;
      expect(
        (await repository.getIncident(
          'report-1',
        )).dataOrNull?.canReportMismatch,
        isFalse,
      );
    },
  );

  test(
    'mismatch posts only citizen feedback with expected group and stable key',
    () async {
      final dio = _Dio();
      Map? sent;
      when(
        () => dio.post<Map<String, dynamic>>(
          '/reports/report-1/incident/actions/',
          data: any(named: 'data'),
        ),
      ).thenAnswer((invocation) async {
        sent = invocation.namedArguments[#data] as Map;
        return Response(
          data: {'incident': _payload()},
          requestOptions: RequestOptions(path: '/'),
        );
      });
      final result = await SharedIncidentRepositoryImpl(dio).reportMismatch(
        reportId: 'report-1',
        groupId: 'group-1',
        reason: 'Another street',
        idempotencyKey: 'attempt-1',
      );
      expect(result.isSuccess, isTrue);
      expect(sent, {
        'action': 'report_mismatch',
        'expected_group_id': 'group-1',
        'reason': 'Another street',
        'idempotency_key': 'attempt-1',
      });
    },
  );

  test('409 preserves stale-membership status for the presentation', () async {
    final dio = _Dio();
    when(
      () => dio.post<Map<String, dynamic>>(
        '/reports/report-1/incident/actions/',
        data: any(named: 'data'),
      ),
    ).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.badResponse,
        response: Response(
          statusCode: 409,
          data: {'error': 'Membership changed'},
          requestOptions: RequestOptions(path: '/'),
        ),
      ),
    );
    final result = await SharedIncidentRepositoryImpl(dio).reportMismatch(
      reportId: 'report-1',
      groupId: 'group-1',
      reason: 'Another street',
      idempotencyKey: 'attempt-1',
    );
    expect(result.failureOrNull?.statusCode, 409);
  });

  test('ungrouped report never fetches an incident', () async {
    final repository = _Repository();
    final container = ProviderContainer(
      overrides: [
        sharedIncidentRepositoryProvider.overrideWithValue(repository),
        reportDetailControllerProvider.overrideWithBuild(
          (_, _) async =>
              const Report(id: 'report-1', description: 'Own report'),
        ),
      ],
    );
    addTearDown(container.dispose);
    expect(
      await container.read(sharedIncidentProvider('report-1').future),
      isNull,
    );
    verifyNever(
      () =>
          repository.getIncident(any(), cancelToken: any(named: 'cancelToken')),
    );
  });

  test(
    'late summary from previous membership cannot replace current summary',
    () async {
      final repository = _Repository();
      final previous = Completer<Result<SharedIncident?>>();
      var groupId = 'group-1';
      var reads = 0;
      when(
        () => repository.getIncident(
          'report-1',
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) {
        reads++;
        return reads == 1
            ? previous.future
            : Future.value(
                const Success(
                  SharedIncident(
                    groupId: 'group-2',
                    status: 'assigned',
                    reportCount: 2,
                  ),
                ),
              );
      });
      final container = ProviderContainer(
        overrides: [
          sharedIncidentRepositoryProvider.overrideWithValue(repository),
          reportDetailControllerProvider.overrideWithBuild(
            (_, _) async => Report(
              id: 'report-1',
              description: 'Own report',
              incidentGroupId: groupId,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      final subscription = container.listen(
        sharedIncidentProvider('report-1'),
        (_, _) {},
      );
      addTearDown(subscription.close);
      await Future<void>.delayed(Duration.zero);
      groupId = 'group-2';
      container.invalidate(reportDetailControllerProvider('report-1'));
      expect(
        (await container.read(
          sharedIncidentProvider('report-1').future,
        ))?.groupId,
        'group-2',
      );
      previous.complete(const Success(_summary));
      await Future<void>.delayed(Duration.zero);
      expect(
        container.read(sharedIncidentProvider('report-1')).value?.groupId,
        'group-2',
      );
    },
  );

  test('disposing incident provider cancels the in-flight read', () async {
    final repository = _Repository();
    final pending = Completer<Result<SharedIncident?>>();
    CancelToken? token;
    when(
      () => repository.getIncident(
        'report-1',
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer((invocation) {
      token = invocation.namedArguments[#cancelToken] as CancelToken;
      return pending.future;
    });
    final container = ProviderContainer(
      overrides: [
        sharedIncidentRepositoryProvider.overrideWithValue(repository),
        reportDetailControllerProvider.overrideWithBuild(
          (_, _) async => const Report(
            id: 'report-1',
            description: 'Own report',
            incidentGroupId: 'group-1',
          ),
        ),
      ],
    );
    container.listen(sharedIncidentProvider('report-1'), (_, _) {});
    await Future<void>.delayed(Duration.zero);
    expect(token?.isCancelled, isFalse);
    container.dispose();
    expect(token?.isCancelled, isTrue);
    pending.complete(const Err(NetworkFailure()));
  });

  for (final type in ['report_linked', 'report_unlinked', 'incident_update']) {
    test('notification $type preserves own-report navigation', () {
      final notification = dto.AppNotification.fromJson({
        'id': 'notice',
        'title': 'Shared incident',
        'message': 'Changed',
        'type': type,
        'related_report_id': 'own-report',
      });
      final mapped = NotificationMapper.toNotificationEntity(notification);
      expect(mapped.type, NotificationType.fromString(type));
      expect(mapped.type, isNot(NotificationType.system));
      expect(mapped.reportId, 'own-report');
      expect(notification.toJson()['type'], type);
    });
  }

  testWidgets('non-representative card shows link even without priority', (
    tester,
  ) async {
    await _pump(
      tester,
      _Repository(),
      child: const HomeReportCard(
        report: Report(
          id: 'report-1',
          description: 'Original report',
          incidentGroupId: 'group-1',
          linkedReportCount: 3,
          isIncidentRepresentative: false,
        ),
      ),
    );
    expect(find.text('Linked to a shared incident'), findsOneWidget);
    expect(find.text('Original report'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'shared progress is distinct and pending is never called confirmed',
    (tester) async {
      await _pump(tester, _Repository());
      expect(find.text('Incident status: In Progress'), findsOneWidget);
      expect(find.text('Drainage clearing has started.'), findsOneWidget);
      expect(
        find.text('The protected incident record is waiting for confirmation.'),
        findsOneWidget,
      );
      expect(
        find.text('A protected record of this incident has been saved.'),
        findsNothing,
      );
      expect(find.text('never-displayed'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('public viewers see the same summary without owner feedback', (
    tester,
  ) async {
    await _pump(
      tester,
      _Repository(),
      load: () async => SharedIncident(
        groupId: _summary.groupId,
        status: _summary.status,
        reportCount: _summary.reportCount,
        assignedDepartment: _summary.assignedDepartment,
        integrityStatus: _summary.integrityStatus,
        updates: _summary.updates,
      ),
    );
    expect(find.text('Incident status: In Progress'), findsOneWidget);
    expect(find.text('Drainage clearing has started.'), findsOneWidget);
    expect(
      find.text('The protected incident record is waiting for confirmation.'),
      findsOneWidget,
    );
    expect(find.text('This is a different incident'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('loading, failure and retry states do not hide the report', (
    tester,
  ) async {
    final pending = Completer<SharedIncident?>();
    var loads = 0;
    await _pump(
      tester,
      _Repository(),
      load: () {
        loads++;
        return loads == 1 ? pending.future : Future.value(_summary);
      },
    );
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    pending.completeError(Exception('Unavailable'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        "We couldn't load the shared incident. Refresh the report to try again.",
      ),
      findsOneWidget,
    );
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();
    expect(find.text('Drainage clearing has started.'), findsOneWidget);
  });

  testWidgets(
    'mismatch retry reuses key and reason edits start another attempt',
    (tester) async {
      final repository = _Repository();
      final keys = <String>[];
      when(
        () => repository.reportMismatch(
          reportId: 'report-1',
          groupId: 'group-1',
          reason: any(named: 'reason'),
          idempotencyKey: any(named: 'idempotencyKey'),
        ),
      ).thenAnswer((invocation) async {
        keys.add(invocation.namedArguments[#idempotencyKey] as String);
        return const Err(NetworkFailure());
      });
      await _pump(tester, repository);
      await tester.tap(find.text('This is a different incident'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a reason for staff review.'), findsOneWidget);
      expect(keys, isEmpty);
      await tester.enterText(find.byType(TextField), 'Different street');
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      expect(
        find.text('Feedback was not saved. Please try again.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      expect(keys.length, 2);
      expect(keys[0], keys[1]);
      await tester.enterText(
        find.byType(TextField),
        'Different street and date',
      );
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      expect(keys[2], isNot(keys[0]));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'successful mismatch refreshes summary without closing other reports',
    (tester) async {
      final repository = _Repository();
      when(
        () => repository.reportMismatch(
          reportId: 'report-1',
          groupId: 'group-1',
          reason: any(named: 'reason'),
          idempotencyKey: any(named: 'idempotencyKey'),
        ),
      ).thenAnswer((_) async => const Success(_summary));
      var loads = 0;
      await _pump(
        tester,
        repository,
        load: () async {
          loads++;
          return _summary;
        },
      );
      await tester.tap(find.text('This is a different incident'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Different street');
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(loads, 2);
    },
  );

  testWidgets('stale membership disables resubmitting old group feedback', (
    tester,
  ) async {
    final repository = _Repository();
    when(
      () => repository.reportMismatch(
        reportId: 'report-1',
        groupId: 'group-1',
        reason: any(named: 'reason'),
        idempotencyKey: any(named: 'idempotencyKey'),
      ),
    ).thenAnswer(
      (_) async => const Err(UnknownFailure.withStatus('Stale group', 409)),
    );
    await _pump(tester, repository);
    await tester.tap(find.text('This is a different incident'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Different street');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        "This report's linked incident has changed. Refresh the report.",
      ),
      findsOneWidget,
    );
    final submit = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Submit'),
        matching: find.byWidgetPredicate((widget) => widget is FilledButton),
      ),
    );
    expect(submit.onPressed, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('authorized incident evidence opens in a zoomable viewer', (
    tester,
  ) async {
    await _pump(
      tester,
      _Repository(),
      load: () async => const SharedIncident(
        groupId: 'group-1',
        status: 'resolved',
        reportCount: 3,
        evidence: [
          IncidentEvidence(
            id: 'approved',
            url: 'https://example.com/proof.jpg',
          ),
        ],
      ),
    );
    await tester.tap(find.bySemanticsLabel('Shared response evidence 1'));
    await tester.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
