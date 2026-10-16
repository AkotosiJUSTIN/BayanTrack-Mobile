import 'dart:async';
import 'package:bayantrack_mobile/core/domain/failures.dart';
import 'package:bayantrack_mobile/core/domain/result.dart';
import 'package:bayantrack_mobile/core/providers/session_content_cache.dart';
import 'package:bayantrack_mobile/features/reports/domain/entities/report.dart';
import 'package:bayantrack_mobile/features/reports/domain/entities/blockchain_verification.dart';
import 'package:bayantrack_mobile/features/reports/domain/reports_repository.dart';
import 'package:bayantrack_mobile/features/reports/presentation/report_detail_controller.dart';
import 'package:bayantrack_mobile/features/reports/presentation/report_verification_controller.dart';
import 'package:bayantrack_mobile/features/reports/reports_di.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class Repo extends Mock implements ReportsRepository {}

const first = Report(
  id: 'r',
  description: 'original',
  protectedSnapshotToken: 'v1',
);
const second = Report(
  id: 'r',
  description: 'updated',
  protectedSnapshotToken: 'v2',
);
BlockchainVerificationResult proof({
  String? token = 'v1',
  bool verified = true,
  bool? current = true,
  bool pending = false,
  bool connection = false,
}) => BlockchainVerificationResult(
  reportId: 'r',
  protectedSnapshotToken: token,
  verified: verified,
  originalSnapshotVerified: true,
  currentContentVerified: current,
  verificationPending: pending,
  connectionError: connection,
  blockchainData: const {},
  auditHistory: const [],
  message: 'result',
);
ProviderContainer setup(Repo repo, SessionContentCache cache) =>
    ProviderContainer(
      overrides: [
        reportsRepositoryDomainProvider.overrideWithValue(repo),
        sessionContentCacheProvider.overrideWithValue(cache),
      ],
    );
Future<void> flush(ProviderContainer c) async {
  await c.pump();
  await Future<void>.delayed(Duration.zero);
  await c.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'only exact successful current snapshot qualifies; older servers do not',
    () {
      expect(ReportVerificationController.matches(first, proof()), isTrue);
      expect(
        ReportVerificationController.matches(first, proof(token: 'v2')),
        isFalse,
      );
      expect(
        ReportVerificationController.matches(first, proof(token: null)),
        isFalse,
      );
      expect(
        ReportVerificationController.matches(first, proof(current: null)),
        isFalse,
      );
      expect(
        ReportVerificationController.matches(first, proof(pending: true)),
        isFalse,
      );
      expect(
        ReportVerificationController.matches(first, proof(connection: true)),
        isFalse,
      );
      expect(
        ReportVerificationController.retryable(
          proof(verified: false, current: false),
        ),
        isFalse,
      );
      expect(
        ReportVerificationController.retryable(
          proof(verified: false, pending: true),
        ),
        isTrue,
      );
    },
  );
  test(
    'cached detail appears before network refresh; failed refresh preserves content and blocks mutation',
    () async {
      final repo = Repo();
      final cache = SessionContentCache()..write('report:r', first);
      final network = Completer<Result<Report>>();
      when(() => repo.getReport('r')).thenAnswer((_) => network.future);
      final c = setup(repo, cache);
      addTearDown(c.dispose);
      final sub = c.listen(reportDetailControllerProvider('r'), (_, _) {});
      addTearDown(sub.close);
      expect(await c.read(reportDetailControllerProvider('r').future), first);
      expect(
        c.read(reportDetailControllerProvider('r').notifier).isFresh,
        isFalse,
      );
      network.complete(const Err(ServerFailure('offline')));
      await flush(c);
      expect(c.read(reportDetailControllerProvider('r')).value, first);
      expect(
        c.read(contentFreshnessProvider)['report:r'],
        ContentFreshness.stale,
      );
      await expectLater(
        c
            .read(reportDetailControllerProvider('r').notifier)
            .citizenCloseReport(satisfied: true),
        throwsStateError,
      );
    },
  );
  test(
    'fresh details automatically check cached backend proof then full check once',
    () async {
      final repo = Repo();
      final cache = SessionContentCache();
      when(
        () => repo.getReport('r'),
      ).thenAnswer((_) async => const Success(first));
      when(
        () => repo.verifyReport('r', cachedOnly: true),
      ).thenAnswer((_) async => const Err(ServerFailure('no cache')));
      when(
        () => repo.verifyReport('r'),
      ).thenAnswer((_) async => Success(proof()));
      final c = setup(repo, cache);
      addTearDown(c.dispose);
      final sub = c.listen(reportVerificationProvider('r'), (_, _) {});
      addTearDown(sub.close);
      await c.read(reportDetailControllerProvider('r').future);
      await flush(c);
      expect(c.read(reportVerificationProvider('r')).result?.verified, isTrue);
      await c.read(reportVerificationProvider('r').notifier).check();
      verify(() => repo.verifyReport('r')).called(1);
      expect(
        cache
            .read<BlockchainVerificationResult>('verification:r')
            ?.protectedSnapshotToken,
        'v1',
      );
    },
  );
  test(
    'snapshot changes invalidate success and reject a late old full-check response',
    () async {
      final repo = Repo();
      final cache = SessionContentCache();
      var report = first;
      final late = Completer<Result<BlockchainVerificationResult>>();
      var calls = 0;
      when(() => repo.getReport('r')).thenAnswer((_) async => Success(report));
      when(
        () => repo.verifyReport('r', cachedOnly: true),
      ).thenAnswer((_) async => const Err(ServerFailure('no cache')));
      when(() => repo.verifyReport('r')).thenAnswer(
        (_) => ++calls == 1
            ? late.future
            : Future.value(Success(proof(token: 'v2'))),
      );
      final c = setup(repo, cache);
      addTearDown(c.dispose);
      final sub = c.listen(reportVerificationProvider('r'), (_, _) {});
      addTearDown(sub.close);
      await c.read(reportDetailControllerProvider('r').future);
      await flush(c);
      report = second;
      await c.read(reportDetailControllerProvider('r').notifier).refresh();
      await flush(c);
      expect(
        c.read(reportVerificationProvider('r')).result?.protectedSnapshotToken,
        'v2',
      );
      late.complete(Success(proof()));
      await flush(c);
      expect(
        c.read(reportVerificationProvider('r')).result?.protectedSnapshotToken,
        'v2',
      );
    },
  );
  test(
    'inactive lifecycle rejects in-flight proof and cancels spinner',
    () async {
      final repo = Repo();
      final cache = SessionContentCache();
      final late = Completer<Result<BlockchainVerificationResult>>();
      when(
        () => repo.getReport('r'),
      ).thenAnswer((_) async => const Success(first));
      when(
        () => repo.verifyReport('r', cachedOnly: true),
      ).thenAnswer((_) async => const Err(ServerFailure('none')));
      when(() => repo.verifyReport('r')).thenAnswer((_) => late.future);
      final c = setup(repo, cache);
      addTearDown(c.dispose);
      final sub = c.listen(reportVerificationProvider('r'), (_, _) {});
      addTearDown(sub.close);
      await c.read(reportDetailControllerProvider('r').future);
      await flush(c);
      c.read(reportVerificationProvider('r').notifier).setActive(false);
      late.complete(Success(proof()));
      await flush(c);
      expect(c.read(reportVerificationProvider('r')).checking, isFalse);
      expect(c.read(reportVerificationProvider('r')).result, isNull);
      expect(
        cache.read<BlockchainVerificationResult>('verification:r'),
        isNull,
      );
    },
  );
  testWidgets(
    'pending automatically retries at 10/30/60 seconds then stops; hidden screen cancels',
    (tester) async {
      final repo = Repo();
      final cache = SessionContentCache();
      var full = 0;
      when(
        () => repo.getReport('r'),
      ).thenAnswer((_) async => const Success(first));
      when(
        () => repo.verifyReport('r', cachedOnly: true),
      ).thenAnswer((_) async => const Err(ServerFailure('none')));
      when(() => repo.verifyReport('r')).thenAnswer((_) async {
        full++;
        return Success(proof(verified: false, pending: true));
      });
      final c = setup(repo, cache);
      addTearDown(c.dispose);
      final sub = c.listen(reportVerificationProvider('r'), (_, _) {});
      addTearDown(sub.close);
      await tester.pump();
      await tester.pump();
      expect(full, 1);
      await tester.pump(const Duration(seconds: 10));
      await tester.pump();
      expect(full, 2);
      await tester.pump(const Duration(seconds: 30));
      await tester.pump();
      expect(full, 3);
      await tester.pump(const Duration(seconds: 60));
      await tester.pump();
      expect(full, 4);
      await tester.pump(const Duration(minutes: 2));
      expect(full, 4);
      c.read(reportVerificationProvider('r').notifier).setActive(false);
      await tester.pump(const Duration(minutes: 2));
      expect(full, 4);
    },
  );
}
