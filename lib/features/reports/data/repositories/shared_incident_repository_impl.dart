import 'package:dio/dio.dart';

import '../../../../core/domain/result.dart';
import '../../../../core/network/error_mapper.dart';
import '../../../../core/utils/api_datetime.dart';
import '../../domain/entities/shared_incident.dart';
import '../../domain/shared_incident_repository.dart';

class SharedIncidentRepositoryImpl implements SharedIncidentRepository {
  SharedIncidentRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<Result<SharedIncident?>> getIncident(
    String reportId, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/reports/${Uri.encodeComponent(reportId)}/incident/',
        cancelToken: cancelToken,
      );
      final incident = response.data?['incident'];
      return Success(
        incident == null ? null : _incident(incident as Map<String, dynamic>),
      );
    } catch (error, stack) {
      return Err(ErrorMapper.mapException(error, stack));
    }
  }

  @override
  Future<Result<SharedIncident>> reportMismatch({
    required String reportId,
    required String groupId,
    required String reason,
    required String idempotencyKey,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/reports/${Uri.encodeComponent(reportId)}/incident/actions/',
        data: {
          'action': 'report_mismatch',
          'expected_group_id': groupId,
          'reason': reason,
          'idempotency_key': idempotencyKey,
        },
      );
      return Success(
        _incident(response.data!['incident'] as Map<String, dynamic>),
      );
    } catch (error, stack) {
      return Err(ErrorMapper.mapException(error, stack));
    }
  }

  SharedIncident _incident(Map<String, dynamic> json) {
    final integrity = json['integrity'] as Map<String, dynamic>? ?? {};
    return SharedIncident(
      groupId: json['group_id'] as String,
      status: json['status'] as String,
      reportCount: (json['report_count'] as num).toInt(),
      assignedDepartment: json['assigned_department'] as String?,
      needsReview: json['needs_review'] == true,
      integrityStatus: integrity['status'] as String? ?? 'not_recorded',
      transactionHash: integrity['tx_hash'] as String?,
      updates: (json['updates'] as List? ?? []).map((value) {
        final update = value as Map<String, dynamic>;
        return IncidentUpdate(
          id: update['id'] as String,
          kind: update['kind'] as String,
          message: update['message'] as String,
          createdAt: parseApiDateTime(update['created_at'] as String?),
        );
      }).toList(),
      evidence: (json['evidence'] as List? ?? []).map((value) {
        final evidence = value as Map<String, dynamic>;
        return IncidentEvidence(
          id: evidence['id'] as String,
          url: evidence['url'] as String,
        );
      }).toList(),
    );
  }
}
