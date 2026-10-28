import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../../../core/providers/session_content_cache.dart';
import '../data/repositories/shared_incident_repository_impl.dart';
import '../domain/entities/shared_incident.dart';
import '../domain/entities/report.dart';
import '../domain/shared_incident_repository.dart';
import 'report_detail_controller.dart';

final sharedIncidentRepositoryProvider = Provider<SharedIncidentRepository>(
  (ref) => SharedIncidentRepositoryImpl(ref.watch(dioProvider)),
);

typedef _IncidentCacheEntry = ({
  Report report,
  SharedIncident? incident,
  DateTime fetchedAt,
});

final sharedIncidentProvider = FutureProvider.autoDispose
    .family<SharedIncident?, String>((ref, reportId) async {
      final cache = ref.watch(sessionContentCacheProvider);
      final report = await ref.watch(
        reportDetailControllerProvider(reportId).future,
      );
      if (!ref.mounted || cache.isClosed) return null;
      final key = 'incident:$reportId';
      if (report.incidentGroupId == null) {
        cache.remove(key);
        return null;
      }
      final saved = cache.read<_IncidentCacheEntry>(key);
      if (saved != null &&
          saved.report == report &&
          DateTime.now().difference(saved.fetchedAt) <
              const Duration(seconds: 30)) {
        return saved.incident;
      }
      final cancelToken = CancelToken();
      ref.onDispose(cancelToken.cancel);
      final result = await ref
          .watch(sharedIncidentRepositoryProvider)
          .getIncident(reportId, cancelToken: cancelToken);
      if (!ref.mounted || cache.isClosed) return null;
      return result.when(
        success: (incident) {
          final current = incident?.groupId == report.incidentGroupId
              ? incident
              : null;
          cache.write(key, (
            report: report,
            incident: current,
            fetchedAt: DateTime.now(),
          ));
          return current;
        },
        failure: (failure) => throw Exception(failure.message),
      );
    }, retry: (_, _) => null);
