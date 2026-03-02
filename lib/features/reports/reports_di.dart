import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/network/dio_provider.dart';
import 'data/repositories/reports_repository_impl.dart';
import 'domain/reports_repository.dart';
import 'domain/usecases/create_report_usecase.dart';
import 'domain/usecases/delete_report_usecase.dart';
import 'domain/usecases/get_my_reports_usecase.dart';
import 'domain/usecases/get_report_stats_usecase.dart';
import 'domain/usecases/get_report_usecase.dart';
import 'domain/usecases/get_reports_usecase.dart';
import 'domain/usecases/verify_report_usecase.dart';

part 'reports_di.g.dart';

// ==================== REPOSITORY ====================

/// Provides the [ReportsRepository] implementation.
///
/// Returns [ReportsRepositoryImpl] which uses Dio and ErrorMapper
/// for proper Result<T> error handling.
@riverpod
ReportsRepository reportsRepositoryDomain(Ref ref) {
  final dio = ref.watch(dioProvider);
  return ReportsRepositoryImpl(dio);
}

// ==================== USE CASES ====================

@riverpod
GetReportsUseCase getReportsUseCase(Ref ref) {
  return GetReportsUseCase(
    repository: ref.watch(reportsRepositoryDomainProvider),
  );
}

@riverpod
GetMyReportsUseCase getMyReportsUseCase(Ref ref) {
  return GetMyReportsUseCase(
    repository: ref.watch(reportsRepositoryDomainProvider),
  );
}

@riverpod
GetReportUseCase getReportUseCase(Ref ref) {
  return GetReportUseCase(
    repository: ref.watch(reportsRepositoryDomainProvider),
  );
}

@riverpod
CreateReportUseCase createReportUseCase(Ref ref) {
  return CreateReportUseCase(
    repository: ref.watch(reportsRepositoryDomainProvider),
  );
}

@riverpod
DeleteReportUseCase deleteReportUseCase(Ref ref) {
  return DeleteReportUseCase(
    repository: ref.watch(reportsRepositoryDomainProvider),
  );
}

@riverpod
GetReportStatsUseCase getReportStatsUseCase(Ref ref) {
  return GetReportStatsUseCase(
    repository: ref.watch(reportsRepositoryDomainProvider),
  );
}

@riverpod
VerifyReportUseCase verifyReportUseCase(Ref ref) {
  return VerifyReportUseCase(
    repository: ref.watch(reportsRepositoryDomainProvider),
  );
}
