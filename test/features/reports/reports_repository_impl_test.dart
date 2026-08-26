import 'package:bayantrack_mobile/core/constants/api_constants.dart';
import 'package:bayantrack_mobile/features/reports/data/repositories/reports_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _DioMock extends Mock implements Dio {}

void main() {
  test(
    'quick report preserves canonical and compatibility contract fields',
    () async {
      final dio = _DioMock();
      Map<String, dynamic>? sent;
      when(
        () => dio.post(ApiConstants.reports, data: any(named: 'data')),
      ).thenAnswer((invocation) async {
        sent = Map<String, dynamic>.from(
          invocation.namedArguments[#data] as Map,
        );
        return Response(
          data: {
            'report': {'id': 'quick-1', 'description': 'Floodwater is rising'},
          },
          statusCode: 201,
          requestOptions: RequestOptions(path: ApiConstants.reports),
        );
      });
      final repository = ReportsRepositoryImpl(dio);

      final result = await repository.createReport(
        description: 'Floodwater is rising',
        isHappeningNow: true,
        municipalityId: 'urdaneta',
        barangayId: 'bactad_east',
        barangay: 'Bactad East',
        zone: 'Bactad East',
        cityMunicipality: 'Urdaneta',
        province: 'Pangasinan',
        latitude: '15.9813940000',
        longitude: '120.6284780000',
        locationAccuracy: 'exact',
        streetLandmark: 'Urdaneta Public Market',
        location: 'Urdaneta Public Market',
        isQuickReport: true,
      );

      expect(result.isSuccess, isTrue);
      expect(sent?['municipality_id'], 'urdaneta');
      expect(sent?['barangay_id'], 'bactad_east');
      expect(sent?['barangay'], 'Bactad East');
      expect(sent?['zone'], 'Bactad East');
      expect(sent?['latitude'], '15.9813940000');
      expect(sent?['longitude'], '120.6284780000');
      expect(sent?['street_landmark'], 'Urdaneta Public Market');
      expect(sent?['location'], 'Urdaneta Public Market');
      expect(sent?['is_quick_report'], isTrue);
    },
  );
}
