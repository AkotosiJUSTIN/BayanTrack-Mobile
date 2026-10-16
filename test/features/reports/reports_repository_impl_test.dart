import 'package:bayantrack_mobile/core/constants/api_constants.dart';
import 'package:bayantrack_mobile/features/reports/data/report_models.dart'
    as dto;
import 'package:bayantrack_mobile/features/reports/data/repositories/reports_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _DioMock extends Mock implements Dio {}

class _OptionsFake extends Fake implements Options {}

void main() {
  setUpAll(() => registerFallbackValue(_OptionsFake()));

  test(
    'incomplete chain scan retains an unavailable result with unknown proof',
    () async {
      final dio = _DioMock();
      final request = RequestOptions(
        path: ApiConstants.reportVerify('report-proof'),
      );
      when(() => dio.get(request.path, queryParameters: null)).thenThrow(
        DioException(
          requestOptions: request,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: request,
            statusCode: 503,
            data: {
              'report_id': 'report-proof',
              'verified': false,
              'original_snapshot_verified': null,
              'current_content_verified': null,
              'blockchain_data': <String, dynamic>{},
              'audit_history': [],
              'message': 'Checkpoint history is being indexed.',
              'scan_incomplete': true,
              'connection_error': true,
              'is_anchored': true,
            },
          ),
        ),
      );
      final result = await ReportsRepositoryImpl(
        dio,
      ).verifyReport('report-proof');
      result.when(
        success: (proof) {
          expect(proof.verified, isFalse);
          expect(proof.originalSnapshotVerified, isNull);
          expect(proof.currentContentVerified, isNull);
          expect(proof.connectionError, isTrue);
          expect(proof.verificationPending, isTrue);
          expect(proof.reason, 'chain_scan_incomplete');
        },
        failure: (failure) => fail(failure.message),
      );
    },
  );

  test('unstructured service outage remains a failure', () async {
    final dio = _DioMock();
    final request = RequestOptions(
      path: ApiConstants.reportVerify('report-proof'),
    );
    when(() => dio.get(request.path, queryParameters: null)).thenThrow(
      DioException(
        requestOptions: request,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: request,
          statusCode: 503,
          data: 'Unavailable',
        ),
      ),
    );
    expect(
      (await ReportsRepositoryImpl(dio).verifyReport('report-proof')).isSuccess,
      isFalse,
    );
  });

  test('saved verification lookup uses cache-only backend query', () async {
    final dio = _DioMock();
    when(
      () => dio.get(
        ApiConstants.reportVerify('report-proof'),
        queryParameters: {'cached_only': 'true'},
      ),
    ).thenAnswer(
      (_) async => Response(
        data: {
          'report_id': 'report-proof',
          'verified': true,
          'is_anchored': true,
          'cached': true,
          'blockchain_data': <String, dynamic>{},
          'audit_history': [],
          'message': 'Previously verified and anchored',
        },
        requestOptions: RequestOptions(
          path: ApiConstants.reportVerify('report-proof'),
        ),
      ),
    );
    final result = await ReportsRepositoryImpl(
      dio,
    ).verifyReport('report-proof', cachedOnly: true);
    expect(result.isSuccess, isTrue);
    result.when(
      success: (proof) {
        expect(proof.verified, isTrue);
        expect(proof.isAnchored, isTrue);
      },
      failure: (failure) => fail(failure.message),
    );
    verify(
      () => dio.get(
        ApiConstants.reportVerify('report-proof'),
        queryParameters: {'cached_only': 'true'},
      ),
    ).called(1);
  });

  test('getReports emits the public reports GET path', () async {
    final dio = _DioMock();
    when(
      () => dio.get(
        ApiConstants.reports,
        queryParameters: {'page': 1, 'page_size': 20},
      ),
    ).thenAnswer(
      (_) async => Response(
        data: {
          'results': [],
          'count': 0,
          'total': 0,
          'page': 1,
          'page_size': 20,
          'total_pages': 0,
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ApiConstants.reports),
      ),
    );
    final repository = ReportsRepositoryImpl(dio);

    final result = await repository.getReports();

    expect(result.isSuccess, isTrue);
    verify(
      () => dio.get(
        ApiConstants.reports,
        queryParameters: {'page': 1, 'page_size': 20},
      ),
    ).called(1);
  });

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

  test('emergency create sends the flag and idempotency header', () async {
    final dio = _DioMock();
    Map<String, dynamic>? sent;
    Options? sentOptions;
    when(
      () => dio.post(
        ApiConstants.reports,
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer((invocation) async {
      sent = Map<String, dynamic>.from(invocation.namedArguments[#data] as Map);
      sentOptions = invocation.namedArguments[#options] as Options;
      return Response(
        data: {
          'report': {
            'id': 'emergency-1',
            'description': '',
            'is_emergency': true,
          },
        },
        statusCode: 201,
        requestOptions: RequestOptions(path: ApiConstants.reports),
      );
    });
    final repository = ReportsRepositoryImpl(dio);

    final result = await repository.createReport(
      category: 'flood_disaster',
      description: '',
      municipalityId: 'urdaneta',
      latitude: '15.9792040000',
      longitude: '120.6222100000',
      locationAccuracy: 'exact',
      isQuickReport: false,
      isEmergency: true,
      idempotencyKey: 'retry-1',
    );

    expect(result.isSuccess, isTrue);
    expect(sent?['category'], 'flood_disaster');
    expect(sent?['description'], isEmpty);
    expect(sent?['is_emergency'], isTrue);
    expect(sent?['is_quick_report'], isFalse);
    expect(sentOptions?.headers?['Idempotency-Key'], 'retry-1');
  });

  test('update report unwraps the backend message/report response', () async {
    final dio = _DioMock();
    const reportId = 'emergency-1';
    final request = dto.UpdateReportRequest(
      description: 'Added access details',
    );
    when(
      () =>
          dio.patch(ApiConstants.reportById(reportId), data: request.toJson()),
    ).thenAnswer(
      (_) async => Response(
        data: {
          'message': 'Report updated successfully',
          'report': {'id': reportId, 'description': 'Added access details'},
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ApiConstants.reportById(reportId)),
      ),
    );
    final repository = ReportsRepositoryImpl(dio);

    final result = await repository.updateReport(
      id: reportId,
      description: request.description,
    );

    expect(result.isSuccess, isTrue);
    expect(result.dataOrNull?.id, reportId);
    expect(result.dataOrNull?.description, 'Added access details');
  });
}
