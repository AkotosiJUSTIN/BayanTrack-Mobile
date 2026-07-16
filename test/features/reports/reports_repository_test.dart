import 'package:bayantrack_mobile/core/constants/api_constants.dart';
import 'package:bayantrack_mobile/features/reports/data/report_models.dart';
import 'package:bayantrack_mobile/features/reports/data/reports_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late ReportsRepository reportsRepository;

  setUp(() {
    mockDio = MockDio();
    reportsRepository = ReportsRepository(mockDio);
  });

  group('ReportsRepository', () {
    group('getReports', () {
      test('should return paginated reports on success', () async {
        // Arrange
        final responseData = {
          'results': [
            {
              'id': 'report_1',
              'description': 'Broken streetlight',
              'status': 'submitted',
              'category': 'infrastructure',
              'zone': 'Zone 1',
              'latitude': '14.5995',
              'longitude': '120.9842',
              'recommended_department': 'Engineering',
              'department_confidence': 0.91,
              'credibility_score': 72.5,
              'images': [],
              'created_at': '2026-01-15T00:00:00Z',
            },
            {
              'id': 'report_2',
              'description': 'Pothole on main road',
              'status': 'in_progress',
              'category': 'roads',
              'zone': 'Zone 2',
              'images': [],
            },
          ],
          'count': 2,
          'total': 2,
          'page': 1,
          'page_size': 20,
          'total_pages': 1,
        };

        when(
          () => mockDio.get(
            ApiConstants.reports,
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ApiConstants.reports),
          ),
        );

        // Act
        final result = await reportsRepository.getReports();

        // Assert
        expect(result.results.length, 2);
        expect(result.count, 2);
        expect(result.results.first.id, 'report_1');
        expect(result.results.first.description, 'Broken streetlight');
        expect(result.results.first.status, 'submitted');
        expect(result.results.first.recommendedDepartment, 'Engineering');
        expect(result.results.first.departmentConfidence, 0.91);
        expect(result.results.first.credibilityScore, 72.5);
        expect(result.results[1].status, 'in_progress');
      });

      test('should pass filter parameters correctly', () async {
        // Arrange
        final responseData = {
          'results': [],
          'count': 0,
          'total': 0,
          'page': 2,
          'page_size': 5,
          'total_pages': 0,
        };

        when(
          () => mockDio.get(
            ApiConstants.reports,
            queryParameters: {
              'page': 2,
              'page_size': 5,
              'status': 'submitted',
              'zone': 'Zone 1',
            },
          ),
        ).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ApiConstants.reports),
          ),
        );

        // Act
        await reportsRepository.getReports(
          page: 2,
          pageSize: 5,
          status: 'submitted',
          zone: 'Zone 1',
        );

        // Assert
        verify(
          () => mockDio.get(
            ApiConstants.reports,
            queryParameters: {
              'page': 2,
              'page_size': 5,
              'status': 'submitted',
              'zone': 'Zone 1',
            },
          ),
        ).called(1);
      });
    });

    group('getMyReports', () {
      test('should return user reports', () async {
        // Arrange
        final responseData = {
          'results': [
            {
              'id': 'my_report_1',
              'description': 'My report',
              'status': 'submitted',
            },
          ],
          'count': 1,
          'total': 1,
          'page': 1,
          'page_size': 20,
          'total_pages': 1,
        };

        when(
          () => mockDio.get(
            ApiConstants.myReports,
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ApiConstants.myReports),
          ),
        );

        // Act
        final result = await reportsRepository.getMyReports();

        // Assert
        expect(result.results.length, 1);
        expect(result.results.first.id, 'my_report_1');
      });
    });

    group('getReport', () {
      test('should return single report by id', () async {
        // Arrange
        const reportId = 'report_123';
        final responseData = {
          'id': reportId,
          'description': 'Detailed report',
          'status': 'resolved',
          'category': 'sanitation',
          'latitude': '14.5995',
          'longitude': '120.9842',
        };

        when(() => mockDio.get(ApiConstants.reportById(reportId))).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(
              path: ApiConstants.reportById(reportId),
            ),
          ),
        );

        // Act
        final result = await reportsRepository.getReport(reportId);

        // Assert
        expect(result.id, reportId);
        expect(result.description, 'Detailed report');
        expect(result.status, 'resolved');
      });

      test(
        'should tolerate advisory duplicate metadata without exposing candidate data',
        () async {
          const reportId = 'report_123';
          final responseData = {
            'id': reportId,
            'description': 'Detailed report',
            'status': 'submitted',
            'duplicate_state': 'potential_duplicate',
            'duplicate_score': 0.91,
            'duplicate_confidence': 'high',
            'duplicate_explanation': 'similar_wording, same_barangay',
            'related_issue_id': 'LEGACY-RELATED-ID',
            'incident_group_id': 'IG-1',
            'duplicate_suggestions': [
              {
                'candidate_report_id': 'PRIVATE-CANDIDATE-ID',
                'candidate_title': 'Private candidate title',
              },
            ],
          };

          when(() => mockDio.get(ApiConstants.reportById(reportId))).thenAnswer(
            (_) async => Response(
              data: responseData,
              statusCode: 200,
              requestOptions: RequestOptions(
                path: ApiConstants.reportById(reportId),
              ),
            ),
          );

          final result = await reportsRepository.getReport(reportId);

          expect(result.id, reportId);
          expect(result.description, 'Detailed report');
          expect(result.incidentGroupId, 'IG-1');
          expect(result.toJson().containsKey('duplicate_suggestions'), isFalse);
          expect(result.toJson().containsKey('related_issue_id'), isFalse);
          expect(
            result.toJson().toString(),
            isNot(contains('PRIVATE-CANDIDATE-ID')),
          );
        },
      );
    });

    group('createReport', () {
      test('should create report and return created report', () async {
        // Arrange
        final request = CreateReportRequest(
          description: 'New issue report',
          streetLandmark: '123 Main Street, Quezon City',
          municipalityId: 'urdaneta',
          barangayId: 'zone_5',
          barangay: 'Zone 5',
          latitude: "14.5995",
          longitude: "120.9842",
        );
        final responseData = {
          'report': {
            'id': 'new_report_123',
            'description': 'New issue report',
            'status': 'submitted',
            'street_landmark': '123 Main Street, Quezon City',
            'barangay': 'Zone 5',
            'latitude': "14.5995",
            'longitude': "120.9842",
          },
        };

        when(
          () => mockDio.post(ApiConstants.reports, data: request.toJson()),
        ).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 201,
            requestOptions: RequestOptions(path: ApiConstants.reports),
          ),
        );

        // Act
        final result = await reportsRepository.createReport(request);

        // Assert
        expect(result.id, 'new_report_123');
        expect(result.description, 'New issue report');
        expect(result.status, 'submitted');
        expect(request.toJson()['municipality_id'], 'urdaneta');
        expect(request.toJson()['barangay_id'], 'zone_5');
        verify(
          () => mockDio.post(ApiConstants.reports, data: request.toJson()),
        ).called(1);
      });
    });

    group('updateReport', () {
      test('should update report', () async {
        // Arrange
        const reportId = 'report_123';
        final request = UpdateReportRequest(description: 'Updated description');
        final responseData = {
          'id': reportId,
          'description': 'Updated description',
          'status': 'in_progress',
        };

        when(
          () => mockDio.patch(
            ApiConstants.reportById(reportId),
            data: request.toJson(),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(
              path: ApiConstants.reportById(reportId),
            ),
          ),
        );

        // Act
        final result = await reportsRepository.updateReport(reportId, request);

        // Assert
        expect(result.status, 'in_progress');
      });
    });

    group('deleteReport', () {
      test('should delete report successfully', () async {
        // Arrange
        const reportId = 'report_123';

        when(
          () => mockDio.delete(ApiConstants.reportById(reportId)),
        ).thenAnswer(
          (_) async => Response(
            data: null,
            statusCode: 204,
            requestOptions: RequestOptions(
              path: ApiConstants.reportById(reportId),
            ),
          ),
        );

        // Act
        await reportsRepository.deleteReport(reportId);

        // Assert
        verify(
          () => mockDio.delete(ApiConstants.reportById(reportId)),
        ).called(1);
      });
    });

    group('getStats', () {
      test('should return report statistics', () async {
        // Arrange
        final responseData = {
          'total': 100,
          'submitted': 30,
          'in_progress': 25,
          'resolved': 40,
          'rejected': 5,
        };

        when(() => mockDio.get(ApiConstants.reportStats)).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ApiConstants.reportStats),
          ),
        );

        // Act
        final result = await reportsRepository.getStats();

        // Assert
        expect(result.total, 100);
        expect(result.submitted, 30);
        expect(result.inProgress, 25);
        expect(result.resolved, 40);
        expect(result.rejected, 5);
      });
    });
  });
}
