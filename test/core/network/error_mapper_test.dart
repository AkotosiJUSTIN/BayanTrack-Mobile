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
}
