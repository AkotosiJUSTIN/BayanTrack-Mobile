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
  @override
  Future<Report> build(String reportId) async {
    return _fetchReport(reportId);
  }

  Future<Report> _fetchReport(String reportId) async {
    final getReport = ref.read(getReportUseCaseProvider);
    final result = await getReport(reportId);

    return result.when(
      success: (data) => data,
      failure: (failure) => throw Exception(failure.message),
    );
  }

  /// Refresh the report
  Future<void> refresh() async {
    final id = reportId;
    final next = await AsyncValue.guard(() => _fetchReport(id));
    if (ref.mounted) state = next;
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
    final id = reportId;
    final useCase = ref.read(citizenCloseReportUseCaseProvider);

    final result = await useCase(
      reportId: id,
      satisfied: satisfied,
      rating: rating,
      note: note,
      reason: reason,
      signatureImageId: signatureImageId,
      signatureName: signatureName,
    );

    return result.when(
      success: (data) => data,
      failure: (failure) => throw failure,
    );
  }
}
