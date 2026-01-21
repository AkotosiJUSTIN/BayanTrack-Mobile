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
              '_id': 'report_1',
              'description': 'Broken streetlight',
              'status': 'pending',
              'category': 'infrastructure',
              'barangay': 'Barangay 1',
              'latitude': 14.5995,
              'longitude': 120.9842,
              'images': [],
              'created_at': '2026-01-15T00:00:00Z',
            },
            {
              '_id': 'report_2',
              'description': 'Pothole on main road',
              'status': 'in_progress',
              'category': 'roads',
              'barangay': 'Barangay 2',
              'images': ['image1.jpg'],
            },
          ],
          'count': 2,
          'next': null,
          'previous': null,
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
        expect(result.results.first.status, ReportStatus.pending);
        expect(result.results[1].status, ReportStatus.inProgress);
      });

      test('should pass filter parameters correctly', () async {
        // Arrange
        final responseData = {'results': [], 'count': 0};

        when(
          () => mockDio.get(
            ApiConstants.reports,
            queryParameters: {
              'page': 2,
              'limit': 5,
              'status': 'pending',
              'barangay': 'Barangay 1',
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
          limit: 5,
          status: ReportStatus.pending,
          barangay: 'Barangay 1',
        );

        // Assert
        verify(
          () => mockDio.get(
            ApiConstants.reports,
            queryParameters: {
              'page': 2,
              'limit': 5,
              'status': 'pending',
              'barangay': 'Barangay 1',
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
              '_id': 'my_report_1',
              'description': 'My report',
              'status': 'pending',
            },
          ],
          'count': 1,
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
          '_id': reportId,
          'description': 'Detailed report',
          'status': 'resolved',
          'category': 'sanitation',
          'latitude': 14.5995,
          'longitude': 120.9842,
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
        expect(result.status, ReportStatus.resolved);
      });
    });

    group('createReport', () {
      test('should create report and return created report', () async {
        // Arrange
        final request = CreateReportRequest(
          description: 'New issue report',
          location: '123 Main Street, Quezon City',
          barangay: 'Barangay 5',
          latitude: "14.5995",
          longitude: "120.9842",
        );
        final responseData = {
          'id': 'new_report_123',
          'description': 'New issue report',
          'status': 'Pending',
          'location': '123 Main Street, Quezon City',
          'barangay': 'Barangay 5',
          'latitude': "14.5995",
          'longitude': "120.9842",
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
        expect(result.status, ReportStatus.pending);
        verify(
          () => mockDio.post(ApiConstants.reports, data: request.toJson()),
        ).called(1);
      });
    });

    group('updateReport', () {
      test('should update report status', () async {
        // Arrange
        const reportId = 'report_123';
        final request = UpdateReportRequest(status: ReportStatus.inProgress);
        final responseData = {
          '_id': reportId,
          'description': 'Updated report',
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
        expect(result.status, ReportStatus.inProgress);
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
          'pending': 30,
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
        expect(result.pending, 30);
        expect(result.inProgress, 25);
        expect(result.resolved, 40);
        expect(result.rejected, 5);
      });
    });
  });
}
