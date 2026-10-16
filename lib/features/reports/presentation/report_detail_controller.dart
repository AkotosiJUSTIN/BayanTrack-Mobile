import 'dart:async';
import '../../../core/providers/session_content_cache.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/entities/blockchain_verification.dart';
import '../domain/entities/report.dart';
import '../reports_di.dart';

part 'report_detail_controller.g.dart';

Duration? _noDetailRetry(int retryCount, Object error) => null;

/// Controller for fetching a single report by ID.
///
/// Uses [GetReportUseCase] for proper clean architecture layering.
/// Returns domain [Report] entity.
@Riverpod(retry: _noDetailRetry)
class ReportDetailController extends _$ReportDetailController {
  int _revision = 0;
  @override
  Future<Report> build(String reportId) async {
    _revision++;
    _refreshing = null;
    isFresh = false;
    final cache = ref.watch(sessionContentCacheProvider);
    final cached = cache.read<Report>('report:$reportId');
    if (cached != null) {
      Future.microtask(refresh);
      return cached;
    }
    final report = await _fetchReport(reportId);
    if (cache.isClosed) throw StateError('Session changed.');
    isFresh = !report.isStale;
    cache.write('report:$reportId', report);
    return report;
  }

  Future<Report> _fetchReport(String reportId) async {
    final getReport = ref.read(getReportUseCaseProvider);
    final result = await getReport(reportId);

    return result.when(
      success: (data) => data,
      failure: (failure) => throw Exception(failure.message),
    );
  }

  bool isFresh = false;
  Future<void>? _refreshing;

  /// Refresh the report
  Future<void> refresh() async {
    if (_refreshing != null) return _refreshing;
    late final Future<void> task;
    task = _refresh().whenComplete(() {
      if (identical(_refreshing, task)) _refreshing = null;
    });
    _refreshing = task;
    return task;
  }

  Future<void> _refresh() async {
    final revision = ++_revision;
    final cache = ref.read(sessionContentCacheProvider);
    final freshness = ref.read(contentFreshnessProvider.notifier);
    freshness.set('report:$reportId', ContentFreshness.refreshing);
    try {
      final report = await _fetchReport(reportId);
      if (!ref.mounted || cache.isClosed || revision != _revision) return;
      isFresh = !report.isStale;
      cache.write('report:$reportId', report);
      state = AsyncData(report);
      freshness.set(
        'report:$reportId',
        isFresh ? ContentFreshness.current : ContentFreshness.stale,
      );
    } catch (error, stack) {
      if (!ref.mounted || cache.isClosed || revision != _revision) return;
      isFresh = false;
      freshness.set('report:$reportId', ContentFreshness.stale);
      if (!state.hasValue) state = AsyncError<Report>(error, stack);
    }
  }

  /// Verify the report against blockchain
  Future<BlockchainVerificationResult?> verifyReport({
    bool cachedOnly = false,
  }) async {
    final id = reportId;
    try {
      final verifyUseCase = ref.read(verifyReportUseCaseProvider);
      final result = await verifyUseCase(id, cachedOnly: cachedOnly);
      return result.when(success: (data) => data, failure: (failure) => null);
    } catch (_) {
      return null;
    }
  }

  /// Submit citizen closure / review for a resolved report.
  ///
  /// Returns the backend response payload (message, report_status) on success,
  /// or throws the typed failure on error.
  Future<Map<String, dynamic>> citizenCloseReport({
    required bool satisfied,
    int? rating,
    String? note,
    String? reason,
    String? signatureImageId,
    String? signatureName,
  }) async {
    if (!isFresh || state.hasError) {
      throw StateError('Refresh the report before submitting a review.');
    }
    final cache = ref.read(sessionContentCacheProvider);
    final id = reportId;
    final useCase = ref.read(citizenCloseReportUseCaseProvider);
    final pendingReview = ref.keepAlive();
    try {
      final result = await useCase(
        reportId: id,
        satisfied: satisfied,
        rating: rating,
        note: note,
        reason: reason,
        signatureImageId: signatureImageId,
        signatureName: signatureName,
      );

      if (!ref.mounted || cache.isClosed) throw StateError('Session changed.');
      return result.when(
        success: (data) {
          ref.read(sessionContentCacheProvider).remove('verification:$id');
          unawaited(refresh());
          return data;
        },
        failure: (failure) => throw failure,
      );
    } finally {
      pendingReview.close();
    }
  }
}
