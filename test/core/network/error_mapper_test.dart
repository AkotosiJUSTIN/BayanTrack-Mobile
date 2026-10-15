import 'package:bayantrack_mobile/core/domain/failures.dart';
import 'package:bayantrack_mobile/core/network/error_mapper.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps backend details and exposes first validation message', () {
    final request = RequestOptions(path: '/reports/');
    final error = DioException(
      requestOptions: request,
      type: DioExceptionType.badResponse,
      response: Response<Map<String, dynamic>>(
        requestOptions: request,
        statusCode: 400,
        data: {
          'error': 'Invalid report location.',
          'details': {
            'barangay_id': ['Barangay does not belong to municipality.'],
            'code': 'municipality_barangay_mismatch',
          },
        },
      ),
    );

    final failure = ErrorMapper.mapException(error);

    expect(failure, isA<ValidationFailure>());
    expect(
      (failure as ValidationFailure).fieldErrors,
      containsPair('barangay_id', 'Barangay does not belong to municipality.'),
    );
    expect(
      ErrorMapper.userMessage(failure),
      'Barangay does not belong to municipality.',
    );
  });

  test('maps scalar field validation messages', () {
    final request = RequestOptions(path: '/verification/submit/');
    final error = DioException(
      requestOptions: request,
      type: DioExceptionType.badResponse,
      response: Response<Map<String, dynamic>>(
        requestOptions: request,
        statusCode: 400,
        data: {'mobile_number': 'Enter a valid mobile number.'},
      ),
    );

    final failure = ErrorMapper.mapException(error) as ValidationFailure;

    expect(failure.errorFor('mobile_number'), 'Enter a valid mobile number.');
  });

  test('never exposes unexpected exception details', () {
    final failure = ErrorMapper.mapException(
      StateError('database credentials and internal implementation'),
    );

    expect(failure, isA<UnknownFailure>());
    expect(failure.message, 'Something went wrong. Please try again.');
  });

  test('server errors do not expose backend diagnostics', () {
    for (final statusCode in [500, 502, 503]) {
      final failure = ErrorMapper.mapException(
        _responseError(statusCode, {
          'detail': 'Traceback: database connection failed at internal-host',
        }),
      );

      expect(failure, isA<ServerFailure>());
      expect(failure.message, isNot(contains('Traceback')));
      expect(failure.message, contains('Please try again'));
    }
  });

  test('ignores machine codes and structured validation metadata', () {
    final failure =
        ErrorMapper.mapException(
              _responseError(400, {
                'details': {
                  'code': 'invalid_location',
                  'metadata': {'trace': 'private diagnostic'},
                  'ignored': [
                    12,
                    {'code': 'internal'},
                  ],
                  'description': ['Please describe the issue.'],
                },
              }),
            )
            as ValidationFailure;

    expect(failure.fieldErrors, {'description': 'Please describe the issue.'});
    expect(ErrorMapper.userMessage(failure), 'Please describe the issue.');
  });

  test('does not stringify structured error payloads', () {
    final failure =
        ErrorMapper.mapException(
              _responseError(400, {
                'error': {'exception': 'private diagnostic'},
                'code': 'bad_input',
              }),
            )
            as ValidationFailure;

    expect(failure.message, 'Invalid input');
    expect(failure.fieldErrors, isNull);
  });

  test('preserves maintenance restrictions and rate limit status', () {
    final maintenance = ErrorMapper.mapException(
      _responseError(503, {
        'code': 'maintenance_read_only',
        'detail': 'Maintenance is in progress.',
      }),
    );
    expect(maintenance, isA<SystemRestrictionFailure>());
    expect(maintenance.code, 'maintenance_read_only');

    final rateLimit = ErrorMapper.mapException(
      _responseError(429, {'detail': 'internal throttle details'}),
    );
    expect(rateLimit.statusCode, 429);
    expect(rateLimit.message, isNot(contains('internal')));
  });
}

DioException _responseError(int status, Map<String, dynamic> body) {
  final request = RequestOptions(path: '/reports/');
  return DioException(
    requestOptions: request,
    type: DioExceptionType.badResponse,
    response: Response<Map<String, dynamic>>(
      requestOptions: request,
      statusCode: status,
      data: body,
    ),
  );
}
