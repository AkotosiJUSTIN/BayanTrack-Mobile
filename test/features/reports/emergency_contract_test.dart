import 'package:bayantrack_mobile/core/constants/api_constants.dart';
import 'package:bayantrack_mobile/features/reports/data/repositories/reports_repository_impl.dart';
import 'package:bayantrack_mobile/features/reports/domain/usecases/create_report_usecase.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Dio extends Mock implements Dio {}

class _Options extends Fake implements Options {}

void main() {
  setUpAll(() => registerFallbackValue(_Options()));
  test(
    'use case serializes context and flags while server derives summary',
    () async {
      final dio = _Dio();
      const context = {
        'version': 1,
        'type_key': 'fire_smoke',
        'situation_key': 'building_fire',
        'immediate_danger': 'yes',
        'notes': 'A & B',
      };
      Map<String, dynamic>? sent;
      Options? options;
      when(
        () => dio.post(
          ApiConstants.reports,
          data: any(named: 'data'),
          options: any(named: 'options'),
          cancelToken: null,
        ),
      ).thenAnswer((call) async {
        sent = Map<String, dynamic>.from(call.namedArguments[#data] as Map);
        options = call.namedArguments[#options] as Options;
        return Response(
          requestOptions: RequestOptions(path: ApiConstants.reports),
          statusCode: 201,
          data: {
            'report': {
              'id': 'e1',
              'description': 'Canonical server summary',
              'is_emergency': true,
              'emergency_context': context,
            },
          },
        );
      });
      final result =
          await CreateReportUseCase(repository: ReportsRepositoryImpl(dio))(
            category: 'public_safety',
            incidentType: 'fire_smoke',
            title: 'Local label',
            description: 'Local outbox summary',
            emergencyContext: context,
            isEmergency: true,
            isQuickReport: true,
            latitude: '15.979204',
            longitude: '120.622210',
            declarationConfirmed: true,
            dataProcessingConsent: true,
            idempotencyKey: 'immutable-key',
          );
      expect(result.isSuccess, isTrue);
      expect(sent!['emergency_context'], context);
      expect(sent!['is_emergency'], isTrue);
      expect(sent!['is_quick_report'], isTrue);
      expect(sent!['declaration_confirmed'], isTrue);
      expect(sent!['data_processing_consent'], isTrue);
      for (final key in ['category', 'title', 'incident_type', 'description']) {
        expect(
          sent!.containsKey(key),
          isFalse,
          reason: '$key must be derived by backend',
        );
      }
      expect(options!.headers!['Idempotency-Key'], 'immutable-key');
      result.when(
        success: (report) => expect(report.emergencyContext, context),
        failure: (failure) => fail(failure.message),
      );
    },
  );
}
