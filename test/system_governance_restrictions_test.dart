import 'package:bayantrack_mobile/core/domain/failures.dart';
import 'package:bayantrack_mobile/core/network/error_mapper.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final entry in {
    403: 'terms_acceptance_required',
    503: 'maintenance_read_only',
    409: 'terms_version_stale',
  }.entries) {
    test('${entry.value} does not invalidate authentication', () {
      final request = RequestOptions(path: '/reports/');
      final failure = ErrorMapper.mapException(
        DioException.badResponse(
          statusCode: entry.key,
          requestOptions: request,
          response: Response(
            requestOptions: request,
            statusCode: entry.key,
            data: {'code': entry.value, 'error': 'Temporarily restricted'},
          ),
        ),
      );
      expect(failure, isA<SystemRestrictionFailure>());
      expect(failure, isNot(isA<AuthFailure>()));
      expect(failure.code, entry.value);
    });
  }
}
