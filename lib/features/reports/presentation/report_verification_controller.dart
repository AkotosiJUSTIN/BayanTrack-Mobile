import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/session_content_cache.dart';
import '../domain/entities/blockchain_verification.dart';
import '../domain/entities/report.dart';
import 'report_detail_controller.dart';

class ReportVerificationState {
  const ReportVerificationState({this.result, this.checking = false});
  final BlockchainVerificationResult? result;
  final bool checking;
}

/// Coordinates visible-screen checks; a request can only update its own snapshot.
class ReportVerificationController extends Notifier<ReportVerificationState> {
  ReportVerificationController(this.reportId);
  final String reportId;
  Timer? _retry;
  int _generation = 0;
  int _attempt = 0;
  bool _active = true;
  bool _pending = false;
  String? _token;
  static const retryDelays = [
    Duration(seconds: 10),
    Duration(seconds: 30),
    Duration(seconds: 60),
  ];

  @override
  ReportVerificationState build() {
    _generation++;
    _pending = false;
    _retry?.cancel();
    final cache = ref.watch(sessionContentCacheProvider);
    ref.onDispose(() {
      _generation++;
      _retry?.cancel();
    });
    ref.listen(contentFreshnessProvider, (_, next) {
      if (next['report:$reportId'] == ContentFreshness.current && _active) {
        unawaited(check());
      }
    });
    ref.listen(reportDetailControllerProvider(reportId), (_, next) {
      final report = next.value;
      if (report == null) return;
      final changed = report.protectedSnapshotToken != _token;
      if (changed) {
        _token = report.protectedSnapshotToken;
        _generation++;
        _retry?.cancel();
        _attempt = 0;
        _pending = false;
        state = const ReportVerificationState();
      }
      if (_active && !next.isLoading && !next.hasError && !report.isStale) {
        final saved = cache.read<BlockchainVerificationResult>(
          'verification:$reportId',
        );
        if (matches(report, saved)) {
          state = ReportVerificationState(result: saved);
        } else if (changed || state.result == null) {
          unawaited(check());
        }
      }
    });
    Future.microtask(() {
      if (ref.mounted) unawaited(check());
    });
    final report = ref.read(reportDetailControllerProvider(reportId)).value;
    _token = report?.protectedSnapshotToken;
    final saved = cache.read<BlockchainVerificationResult>(
      'verification:$reportId',
    );
    return ReportVerificationState(
      result: report != null && matches(report, saved) ? saved : null,
    );
  }

  static bool matches(Report report, BlockchainVerificationResult? result) =>
      report.protectedSnapshotToken?.isNotEmpty == true &&
      result?.protectedSnapshotToken == report.protectedSnapshotToken &&
      result?.verified == true &&
      result?.currentContentVerified == true &&
      result?.originalSnapshotVerified != false &&
      result?.connectionError == false &&
      result?.verificationPending == false &&
      result?.verificationState != 'MISSING_IPFS' &&
      result?.verificationState != 'UNAVAILABLE' &&
      result?.verificationState != 'PENDING' &&
      result?.reason != 'ipfs_unreachable' &&
      result?.notFoundOnChain == false &&
      result?.isAnchored == true;

  void setActive(bool active) {
    _active = active;
    if (!active) {
      _generation++;
      _retry?.cancel();
      _pending = false;
      state = ReportVerificationState(result: state.result);
    } else {
      _attempt = 0;
      unawaited(
        ref.read(reportDetailControllerProvider(reportId).notifier).refresh(),
      );
      unawaited(check());
    }
  }

  Future<void> check({bool force = false}) async {
    if (!_active || _pending) return;
    final detail = ref.read(reportDetailControllerProvider(reportId));
    final report = detail.value;
    if (report == null ||
        detail.isLoading ||
        detail.hasError ||
        report.isStale ||
        !ref.read(reportDetailControllerProvider(reportId).notifier).isFresh) {
      return;
    }
    if (!force && matches(report, state.result)) return;
    _pending = true;
    _retry?.cancel();
    final generation = _generation;
    final token = report.protectedSnapshotToken;
    final cache = ref.read(sessionContentCacheProvider);
    final controller = ref.read(
      reportDetailControllerProvider(reportId).notifier,
    );
    state = ReportVerificationState(result: state.result, checking: true);
    var result = force ? null : await controller.verifyReport(cachedOnly: true);
    if (!ref.mounted ||
        cache.isClosed ||
        generation != _generation ||
        !_active) {
      return;
    }
    if (!matches(report, result)) result = await controller.verifyReport();
    if (!ref.mounted ||
        cache.isClosed ||
        generation != _generation ||
        !_active) {
      return;
    }
    _pending = false;
    if (ref
            .read(reportDetailControllerProvider(reportId))
            .value
            ?.protectedSnapshotToken !=
        token) {
      return;
    }
    // A success without snapshot metadata cannot be presented as current proof.
    if (result?.verified == true && !matches(report, result)) result = null;
    state = ReportVerificationState(result: result);
    if (matches(report, result)) {
      cache.write('verification:$reportId', result!);
    } else if (retryable(result) && _attempt < retryDelays.length) {
      _retry = Timer(retryDelays[_attempt++], () => unawaited(_retryCheck()));
    }
  }

  Future<void> _retryCheck() async {
    final generation = _generation;
    await ref.read(reportDetailControllerProvider(reportId).notifier).refresh();
    if (ref.mounted && _active && generation == _generation) {
      await check(force: true);
    }
  }

  static bool retryable(BlockchainVerificationResult? result) =>
      result == null ||
      result.verificationPending ||
      result.connectionError ||
      !result.isAnchored ||
      result.verificationState == 'PENDING' ||
      result.verificationState == 'UNAVAILABLE' ||
      result.reason == 'checkpoint_history_pending' ||
      result.reason == 'not_anchored' ||
      result.reason == 'chain_scan_incomplete' ||
      result.reason == 'checkpoint_pending' ||
      result.reason == 'ipfs_unreachable';
}

final reportVerificationProvider = NotifierProvider.autoDispose
    .family<ReportVerificationController, ReportVerificationState, String>(
      ReportVerificationController.new,
    );
