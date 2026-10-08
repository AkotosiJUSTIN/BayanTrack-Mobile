import 'dart:io';

import 'package:bayantrack_mobile/core/constants/api_constants.dart';
import 'package:bayantrack_mobile/core/domain/failures.dart';
import 'package:bayantrack_mobile/features/reports/data/report_cache_store.dart';
import 'package:bayantrack_mobile/features/reports/data/report_models.dart'
    as dto;
import 'package:bayantrack_mobile/features/reports/data/repositories/reports_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _StorageMock extends Mock implements FlutterSecureStorage {}

class _DioMock extends Mock implements Dio {}

void main() {
  late _StorageMock storage;
  late Map<String, String> values;
  late ReportCacheStore cache;

  setUp(() {
    storage = _StorageMock();
    values = {};
    when(
      () => storage.read(key: any(named: 'key')),
    ).thenAnswer((invocation) async => values[invocation.namedArguments[#key]]);
    when(
      () => storage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((invocation) async {
      values[invocation.namedArguments[#key] as String] =
          invocation.namedArguments[#value] as String;
    });
    when(() => storage.delete(key: any(named: 'key'))).thenAnswer((
      invocation,
    ) async {
      values.remove(invocation.namedArguments[#key]);
    });
    when(() => storage.readAll()).thenAnswer((_) async => values);
    cache = ReportCacheStore(storage);
  });

  const query = {'page': 1, 'page_size': 20, 'sort_by': 'date'};

  test('secure cache survives store recreation and isolates owners', () async {
    final stored = dto.PaginatedReports(
      results: [dto.Report(id: 'A-report', description: 'Private report A')],
      count: 1,
      total: 1,
    );
    await cache.writeReports(
      ownerId: 'user-A',
      scope: 'mine',
      query: query,
      reports: stored,
    );
    await cache.writeReport(
      ownerId: 'user-A',
      reportId: 'A-report',
      report: stored.results.single,
    );

    final afterRestart = ReportCacheStore(storage);
    final userAList = await afterRestart.readReports(
      ownerId: 'user-A',
      scope: 'mine',
      query: query,
    );
    final userAReport = await afterRestart.readReport(
      ownerId: 'user-A',
      reportId: 'A-report',
    );

    expect(userAList?.results.single.description, 'Private report A');
    expect(userAReport?.id, 'A-report');
    expect(
      await afterRestart.readReports(
        ownerId: 'user-B',
        scope: 'mine',
        query: query,
      ),
      isNull,
    );
    expect(
      await afterRestart.readReport(ownerId: 'user-B', reportId: 'A-report'),
      isNull,
    );
  });

  test('account changes and logout purge only report-read cache', () async {
    final reports = dto.PaginatedReports(
      results: [dto.Report(id: 'report-1', description: 'Cached report')],
      count: 1,
      total: 1,
    );
    await cache.writeReports(
      ownerId: 'user-A',
      scope: 'mine',
      query: query,
      reports: reports,
    );
    await cache.writeReports(
      ownerId: 'user-B',
      scope: 'mine',
      query: query,
      reports: reports,
    );

    await cache.deleteOtherOwners('user-B');
    expect(
      await cache.readReports(ownerId: 'user-A', scope: 'mine', query: query),
      isNull,
    );
    expect(
      await cache.readReports(ownerId: 'user-B', scope: 'mine', query: query),
      isNotNull,
    );

    await cache.deleteOwner('user-B');
    expect(
      await cache.readReports(ownerId: 'user-B', scope: 'mine', query: query),
      isNull,
    );
  });

  test(
    'online public fetch writes cache and failed refresh returns stale data',
    () async {
      final dio = _DioMock();
      when(
        () => dio.get(ApiConstants.reports, queryParameters: query),
      ).thenAnswer(
        (_) async => _response(
          ApiConstants.reports,
          _pageJson('RPT-1', 'Server version'),
        ),
      );
      final online = ReportsRepositoryImpl(
        dio,
        cache: cache,
        currentOwnerId: () => 'user-A',
      );

      final fetched = await online.getReports(sortBy: 'date');

      expect(fetched.dataOrNull?.isStale, isFalse);
      expect(
        (await cache.readReports(
          ownerId: 'user-A',
          scope: 'public',
          query: query,
        ))?.results.single.title,
        'Server version',
      );

      final offlineDio = _DioMock();
      when(
        () => offlineDio.get(ApiConstants.reports, queryParameters: query),
      ).thenThrow(_offline(ApiConstants.reports));
      final offline = ReportsRepositoryImpl(
        offlineDio,
        cache: cache,
        currentOwnerId: () => 'user-A',
      );

      final fallback = await offline.getReports(sortBy: 'date');

      expect(fallback.isSuccess, isTrue);
      expect(fallback.dataOrNull?.isStale, isTrue);
      expect(fallback.dataOrNull?.results.single.title, 'Server version');
      expect(fallback.dataOrNull?.results.single.isStale, isTrue);
    },
  );

  test('My Reports cache never crosses user boundary', () async {
    final query = {'page': 1, 'page_size': 20, 'sort_by': 'date'};
    final dioA = _DioMock();
    when(
      () => dioA.get(ApiConstants.myReports, queryParameters: query),
    ).thenAnswer(
      (_) async => _response(
        ApiConstants.myReports,
        _pageJson('A-report', 'Private report A'),
      ),
    );
    final userA = ReportsRepositoryImpl(
      dioA,
      cache: cache,
      currentOwnerId: () => 'user-A',
    );
    expect((await userA.getMyReports(sortBy: 'date')).isSuccess, isTrue);

    final dioB = _DioMock();
    when(
      () => dioB.get(ApiConstants.myReports, queryParameters: query),
    ).thenThrow(_offline(ApiConstants.myReports));
    final userB = ReportsRepositoryImpl(
      dioB,
      cache: cache,
      currentOwnerId: () => 'user-B',
    );
    final userBResult = await userB.getMyReports(sortBy: 'date');
    expect(userBResult.isSuccess, isFalse);

    final userAOffline = ReportsRepositoryImpl(
      dioB,
      cache: cache,
      currentOwnerId: () => 'user-A',
    );
    final userAResult = await userAOffline.getMyReports(sortBy: 'date');
    expect(userAResult.dataOrNull?.results.single.id, 'A-report');
    expect(userAResult.dataOrNull?.isStale, isTrue);
  });

  test(
    'detail cache falls back offline and Backend refresh replaces it',
    () async {
      final dio = _DioMock();
      when(() => dio.get(ApiConstants.reportById('RPT-2'))).thenAnswer(
        (_) async => _response(ApiConstants.reportById('RPT-2'), {
          'id': 'RPT-2',
          'title': 'Old title',
          'description': 'Details',
        }),
      );
      final repository = ReportsRepositoryImpl(
        dio,
        cache: cache,
        currentOwnerId: () => 'user-A',
      );
      expect((await repository.getReport('RPT-2')).isSuccess, isTrue);

      final offlineDio = _DioMock();
      when(
        () => offlineDio.get(ApiConstants.reportById('RPT-2')),
      ).thenThrow(_offline(ApiConstants.reportById('RPT-2')));
      final offline = ReportsRepositoryImpl(
        offlineDio,
        cache: cache,
        currentOwnerId: () => 'user-A',
      );
      final stale = await offline.getReport('RPT-2');
      expect(stale.dataOrNull?.title, 'Old title');
      expect(stale.dataOrNull?.isStale, isTrue);

      final refreshedDio = _DioMock();
      when(() => refreshedDio.get(ApiConstants.reportById('RPT-2'))).thenAnswer(
        (_) async => _response(ApiConstants.reportById('RPT-2'), {
          'id': 'RPT-2',
          'title': 'Current title',
          'description': 'Details',
        }),
      );
      final refreshed = ReportsRepositoryImpl(
        refreshedDio,
        cache: cache,
        currentOwnerId: () => 'user-A',
      );

      final current = await refreshed.getReport('RPT-2');

      expect(current.dataOrNull?.title, 'Current title');
      expect(current.dataOrNull?.isStale, isFalse);
      expect(
        (await cache.readReport(ownerId: 'user-A', reportId: 'RPT-2'))?.title,
        'Current title',
      );
    },
  );

  test('empty offline cache preserves network error', () async {
    final dio = _DioMock();
    when(
      () => dio.get(ApiConstants.reports, queryParameters: query),
    ).thenThrow(_offline(ApiConstants.reports));
    final repository = ReportsRepositoryImpl(
      dio,
      cache: cache,
      currentOwnerId: () => 'user-A',
    );

    final result = await repository.getReports(sortBy: 'date');

    expect(result.isSuccess, isFalse);
    expect(result.failureOrNull, isA<NetworkFailure>());
  });
}

Response<dynamic> _response(String path, dynamic data) => Response<dynamic>(
  data: data,
  statusCode: 200,
  requestOptions: RequestOptions(path: path),
);

Map<String, dynamic> _pageJson(String id, String title) => {
  'results': [
    {'id': id, 'title': title, 'description': 'Report description'},
  ],
  'count': 1,
  'total': 1,
  'page': 1,
  'page_size': 20,
  'total_pages': 1,
};

DioException _offline(String path) => DioException.connectionError(
  requestOptions: RequestOptions(path: path),
  reason: 'Backend unreachable',
  error: const SocketException('Backend unreachable'),
);
