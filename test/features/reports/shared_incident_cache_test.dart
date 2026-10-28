import 'dart:async';

import 'package:bayantrack_mobile/core/domain/failures.dart';
import 'package:bayantrack_mobile/core/domain/result.dart';
import 'package:bayantrack_mobile/core/providers/session_content_cache.dart';
import 'package:bayantrack_mobile/core/realtime/realtime_contract.dart';
import 'package:bayantrack_mobile/features/auth/presentation/auth_realtime_controller.dart';
import 'package:bayantrack_mobile/features/reports/domain/entities/report.dart';
import 'package:bayantrack_mobile/features/reports/domain/entities/shared_incident.dart';
import 'package:bayantrack_mobile/features/reports/domain/shared_incident_repository.dart';
import 'package:bayantrack_mobile/features/reports/presentation/report_detail_controller.dart';
import 'package:bayantrack_mobile/features/reports/presentation/shared_incident_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class Repository extends Mock implements SharedIncidentRepository {}

class Token extends Fake implements CancelToken {}

const report = Report(id: 'r', description: 'Report', incidentGroupId: 'g');
const summary = SharedIncident(
  groupId: 'g',
  status: 'assigned',
  reportCount: 2,
);
final provider = sharedIncidentProvider('r');

ProviderContainer setup(
  Repository repository,
  SessionContentCache cache, {
  Report Function()? loadReport,
}) {
  final container = ProviderContainer(
    overrides: [
      sessionContentCacheProvider.overrideWithValue(cache),
      sharedIncidentRepositoryProvider.overrideWithValue(repository),
      reportDetailControllerProvider.overrideWithBuild(
        (_, _) async => loadReport?.call() ?? report,
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  setUpAll(() => registerFallbackValue(Token()));

  test(
    'reopening and unchanged detail refresh reuse the same incident request',
    () async {
      final repository = Repository();
      when(
        () =>
            repository.getIncident('r', cancelToken: any(named: 'cancelToken')),
      ).thenAnswer((_) async => const Success(summary));
      final cache = SessionContentCache();
      final container = setup(repository, cache);
      var subscription = container.listen(provider, (_, _) {});
      expect(await container.read(provider.future), summary);
      subscription.close();
      await container.pump();
      subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);
      expect(await container.read(provider.future), summary);
      container.invalidate(reportDetailControllerProvider('r'));
      expect(await container.read(provider.future), summary);
      verify(
        () =>
            repository.getIncident('r', cancelToken: any(named: 'cancelToken')),
      ).called(1);

      cache.remove('incident:r');
      container.invalidate(provider);
      expect(await container.read(provider.future), summary);
      verify(
        () =>
            repository.getIncident('r', cancelToken: any(named: 'cancelToken')),
      ).called(1);
    },
  );

  test(
    '30 second freshness expires independently of the idle cache lifetime',
    () async {
      final repository = Repository();
      when(
        () =>
            repository.getIncident('r', cancelToken: any(named: 'cancelToken')),
      ).thenAnswer((_) async => const Success(summary));
      final cache = SessionContentCache()
        ..write('incident:r', (
          report: report,
          incident: summary as SharedIncident?,
          fetchedAt: DateTime.now().subtract(const Duration(seconds: 31)),
        ));
      final container = setup(repository, cache);
      expect(await container.read(provider.future), summary);
      verify(
        () =>
            repository.getIncident('r', cancelToken: any(named: 'cancelToken')),
      ).called(1);
    },
  );

  test(
    'link changes bypass cache and unlinking removes the old summary',
    () async {
      final repository = Repository();
      var current = report;
      when(
        () =>
            repository.getIncident('r', cancelToken: any(named: 'cancelToken')),
      ).thenAnswer(
        (_) async => Success(
          SharedIncident(
            groupId: current.incidentGroupId!,
            status: 'assigned',
            reportCount: 2,
          ),
        ),
      );
      final cache = SessionContentCache();
      final container = setup(repository, cache, loadReport: () => current);
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);
      expect((await container.read(provider.future))?.groupId, 'g');
      current = const Report(
        id: 'r',
        description: 'Report',
        incidentGroupId: 'new-group',
      );
      expect(current, isNot(report));
      container.invalidate(reportDetailControllerProvider('r'));
      expect((await container.read(provider.future))?.groupId, 'new-group');
      current = const Report(id: 'r', description: 'Report');
      container.invalidate(reportDetailControllerProvider('r'));
      expect(await container.read(provider.future), isNull);
      expect(cache.read<Object>('incident:r'), isNull);
      verify(
        () =>
            repository.getIncident('r', cancelToken: any(named: 'cancelToken')),
      ).called(2);
    },
  );

  test(
    'failed requests are not cached and concurrent listeners share a request',
    () async {
      final repository = Repository();
      final pending = Completer<Result<SharedIncident?>>();
      when(
        () =>
            repository.getIncident('r', cancelToken: any(named: 'cancelToken')),
      ).thenAnswer((_) => pending.future);
      final cache = SessionContentCache();
      final container = setup(repository, cache);
      final a = container.listen(provider, (_, _) {});
      final b = container.listen(provider, (_, _) {});
      addTearDown(a.close);
      addTearDown(b.close);
      final future = container.read(provider.future);
      final assertion = expectLater(future, throwsException);
      pending.complete(const Err(ServerFailure('offline')));
      await assertion;
      expect(cache.read<Object>('incident:r'), isNull);
      verify(
        () =>
            repository.getIncident('r', cancelToken: any(named: 'cancelToken')),
      ).called(1);
      when(
        () =>
            repository.getIncident('r', cancelToken: any(named: 'cancelToken')),
      ).thenAnswer((_) async => const Success(summary));
      container.invalidate(provider);
      expect(await container.read(provider.future), summary);
    },
  );

  test('closed sessions reject late incident responses', () async {
    final repository = Repository();
    final pending = Completer<Result<SharedIncident?>>();
    when(
      () => repository.getIncident('r', cancelToken: any(named: 'cancelToken')),
    ).thenAnswer((_) => pending.future);
    final cache = SessionContentCache();
    final container = setup(repository, cache);
    final subscription = container.listen(provider, (_, _) {});
    addTearDown(subscription.close);
    final future = container.read(provider.future);
    await container.pump();
    cache.close();
    pending.complete(const Success(summary));
    expect(await future, isNull);
    expect(cache.read<Object>('incident:r'), isNull);
  });

  for (final eventKind in ['incident_group', 'report']) {
    test(
      '$eventKind realtime invalidation bypasses cached incident and reloads open details',
      () async {
        final repository = Repository();
        var current = const Report(id: 'r', description: 'Report');
        var details = 0;
        when(
          () => repository.getIncident(
            'r',
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenAnswer((_) async => const Success(summary));
        final cache = SessionContentCache()..write('profile:me', 'keep');
        final container = setup(
          repository,
          cache,
          loadReport: () {
            details++;
            return current;
          },
        );
        final subscription = container.listen(provider, (_, _) {});
        addTearDown(subscription.close);
        expect(await container.read(provider.future), isNull);
        cache.write('report:r', current);
        cache.write('verification:r', 'old-proof');
        cache.write('incident:r', 'old-summary');
        current = report;
        container
            .read(authRealtimeControllerProvider)
            .handleEvent(
              RealtimeEvent(
                version: 1,
                eventId: 'event',
                name: eventKind == 'report'
                    ? 'report.assignment_changed'
                    : 'incident_group.changed',
                entityKind: eventKind,
                entityId: eventKind == 'report' ? 'r' : 'g',
                occurredAt: '',
                correlationId: '',
              ),
            );
        expect(await container.read(provider.future), summary);
        expect(details, 2);
        expect(cache.read<Object>('report:r'), isNull);
        expect(cache.read<Object>('verification:r'), isNull);
        expect(cache.read<String>('profile:me'), 'keep');
        verify(
          () => repository.getIncident(
            'r',
            cancelToken: any(named: 'cancelToken'),
          ),
        ).called(1);
      },
    );
  }
}
