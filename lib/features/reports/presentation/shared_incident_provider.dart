import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../data/repositories/shared_incident_repository_impl.dart';
import '../domain/entities/shared_incident.dart';
import '../domain/shared_incident_repository.dart';
import 'report_detail_controller.dart';

final sharedIncidentRepositoryProvider = Provider<SharedIncidentRepository>(
  (ref) => SharedIncidentRepositoryImpl(ref.watch(dioProvider)),
);

final sharedIncidentProvider = FutureProvider.autoDispose
    .family<SharedIncident?, String>((ref, reportId) async {
      final report = await ref.watch(
        reportDetailControllerProvider(reportId).future,
      );
      if (!ref.mounted || report.incidentGroupId == null) return null;
      final cancelToken = CancelToken();
      ref.onDispose(cancelToken.cancel);
      final result = await ref
          .watch(sharedIncidentRepositoryProvider)
          .getIncident(reportId, cancelToken: cancelToken);
      return result.when(
        success: (incident) =>
            incident?.groupId == report.incidentGroupId ? incident : null,
        failure: (failure) => throw Exception(failure.message),
      );
    }, retry: (_, _) => null);
