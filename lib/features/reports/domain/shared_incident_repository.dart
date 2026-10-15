import 'package:dio/dio.dart';

import '../../../core/domain/result.dart';
import 'entities/shared_incident.dart';

abstract class SharedIncidentRepository {
  Future<Result<SharedIncident?>> getIncident(
    String reportId, {
    CancelToken? cancelToken,
  });

  Future<Result<SharedIncident>> reportMismatch({
    required String reportId,
    required String groupId,
    required String reason,
    required String idempotencyKey,
  });
}
