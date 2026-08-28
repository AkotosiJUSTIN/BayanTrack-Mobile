import 'package:bayantrack_mobile/core/constants/api_constants.dart';
import 'package:bayantrack_mobile/features/reports/data/repositories/reports_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _DioMock extends Mock implements Dio {}

Response<Map<String, dynamic>> _response(String path) => Response(
      data: const {
        'message': 'ok',
        'satisfied': false,
        'report_status': 'escalated',
      },
      statusCode: 200,
      requestOptions: RequestOptions(path: path),
    );

void main() {
  test('dispute sends reason without confirmation signature fields', () async {
    final dio = _DioMock();
    Map<String, dynamic>? sent;
    when(
      () => dio.patch(
        ApiConstants.reportCitizenClose('RPT-DISPUTE'),
        data: any(named: 'data'),
      ),
    ).thenAnswer((invocation) async {
      sent = Map<String, dynamic>.from(
        invocation.namedArguments[#data] as Map,
      );
      return _response(ApiConstants.reportCitizenClose('RPT-DISPUTE'));
    });

    final result = await ReportsRepositoryImpl(dio).citizenCloseReport(
      id: 'RPT-DISPUTE',
      satisfied: false,
      reason: 'The repair failed after rain.',
    );

    expect(result.isSuccess, isTrue);
    expect(sent, {
      'satisfied': false,
      'reason': 'The repair failed after rain.',
    });
  });

  test('confirmation preserves note and signature payload', () async {
    final dio = _DioMock();
    Map<String, dynamic>? sent;
    when(
      () => dio.patch(
        ApiConstants.reportCitizenClose('RPT-CONFIRM'),
        data: any(named: 'data'),
      ),
    ).thenAnswer((invocation) async {
      sent = Map<String, dynamic>.from(
        invocation.namedArguments[#data] as Map,
      );
      return _response(ApiConstants.reportCitizenClose('RPT-CONFIRM'));
    });

    await ReportsRepositoryImpl(dio).citizenCloseReport(
      id: 'RPT-CONFIRM',
      satisfied: true,
      note: 'Looks good.',
      signatureImageId: 'image-1',
      signatureName: 'Citizen One',
    );

    expect(sent, {
      'satisfied': true,
      'note': 'Looks good.',
      'signature_image_id': 'image-1',
      'signature_name': 'Citizen One',
    });
  });
}
