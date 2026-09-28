import 'dart:async';
import 'dart:io';

import 'package:bayantrack_mobile/core/domain/failures.dart';
import 'package:bayantrack_mobile/core/domain/result.dart';
import 'package:bayantrack_mobile/features/images/data/evidence_file_stager.dart';
import 'package:bayantrack_mobile/features/images/data/evidence_upload_queue.dart';
import 'package:bayantrack_mobile/features/reports/data/report_create_outbox.dart';
import 'package:bayantrack_mobile/features/reports/data/report_draft_store.dart';
import 'package:bayantrack_mobile/features/reports/domain/entities/report.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _StorageMock extends Mock implements FlutterSecureStorage {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _StorageMock storage;
  late Map<String, String> values;
  late ReportDraftStore drafts;
  late Directory root;
  late SharedPreferences preferences;
  late DateTime now;
  late String? signedInOwner;
  late bool reachable;
  late bool failOutboxDelete;
  late int evidenceHandoffs;

  setUp(() async {
    storage = _StorageMock();
    values = {};
    root = await Directory.systemTemp.createTemp('report_outbox_test_');
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    failOutboxDelete = false;
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
      final key = invocation.namedArguments[#key] as String;
      if (failOutboxDelete &&
          key.startsWith('bayantrack_report_create_outbox_v1.')) {
        throw StateError('simulated outbox cleanup interruption');
      }
      values.remove(key);
    });
    when(() => storage.readAll()).thenAnswer((_) async => values);
    drafts = ReportDraftStore(storage);
    now = DateTime.utc(2026, 9, 28, 12);
    signedInOwner = 'user-a';
    reachable = false;
    evidenceHandoffs = 0;
  });

  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  ReportCreateOutbox createOutbox(
    ReportCreateRequest submit, {
    ReportOutboxAttachmentHandoff? handoff,
  }) => ReportCreateOutbox(
    store: ReportCreateOutboxStore(storage),
    drafts: drafts,
    submit: submit,
    isCurrentOwner: (ownerId) async => signedInOwner == ownerId,
    hasValidSession: (ownerId) async => signedInOwner == ownerId,
    canReachBackend: () => reachable,
    handoffAttachments:
        handoff ??
        (item) async {
          expect(item.serverReportId, isNotNull);
          evidenceHandoffs++;
          return true;
        },
    onChanged: (_) {},
    now: () => now,
  );

  EvidenceUploadQueue createEvidenceQueue(ReportCreateOutboxStore store) =>
      EvidenceUploadQueue(
        preferences: preferences,
        uploadDirectory: Directory(
          '${root.path}${Platform.pathSeparator}pending_evidence',
        ),
        upload:
            ({
              required file,
              required reportId,
              required evidenceKey,
              required isPrimary,
              required cancelToken,
            }) async {
              throw StateError('Unexpected evidence upload in handoff test');
            },
        isAuthenticated: (_) async => false,
        readDraftAttachmentReferences: () async {
          final references = await drafts.readAllAttachmentReferences();
          references.addAll(await store.readAllAttachmentReferences());
          return references;
        },
        autoSchedule: false,
      );

  test(
    'offline create survives restart and lost-response replay maps once',
    () async {
      final createdByKey = <String, String>{};
      final sentKeys = <String>[];
      var dropFirstResponse = true;
      final request = _fakeServer(
        createdByKey,
        sentKeys,
        dropFirstResponse: () => dropFirstResponse,
        onFirstResponseDropped: () => dropFirstResponse = false,
      );
      final draft = _draft('user-a');
      await drafts.write(draft);

      final firstProcess = createOutbox(request);
      final queued = await firstProcess.submit(
        ownerId: 'user-a',
        type: ReportDraftType.full,
        payload: const {'description': 'Offline report'},
        attachmentRefs: const ['/app/report_evidence_drafts/draft_photo.jpg'],
        sourceDraftId: draft.draftId,
        sourceDraftUpdatedAt: draft.updatedAt,
      );
      expect(queued.status, ReportCreateOutboxStatus.pending);
      expect(await drafts.read('user-a', ReportDraftType.full), isNotNull);
      expect(sentKeys, isEmpty);
      firstProcess.dispose();

      reachable = true;
      final afterLostResponse = createOutbox(request);
      await afterLostResponse.resume('user-a');
      final retrying = await ReportCreateOutboxStore(
        storage,
      ).read('user-a', queued.localReportId);
      expect(retrying?.status, ReportCreateOutboxStatus.retryWaiting);
      expect(retrying?.serverReportId, isNull);
      expect(await drafts.read('user-a', ReportDraftType.full), isNotNull);
      expect(evidenceHandoffs, 0);
      afterLostResponse.dispose();

      now = now.add(const Duration(seconds: 3));
      final restarted = createOutbox(request);
      expect(await restarted.resume('user-a'), 1);
      final synced = await ReportCreateOutboxStore(
        storage,
      ).read('user-a', queued.localReportId);

      expect(synced, isNull);
      expect(
        await ReportCreateOutboxStore(
          storage,
        ).readServerReportId('user-a', queued.localReportId),
        'server-1',
      );
      expect(
        await ReportCreateOutboxStore(
          storage,
        ).readServerReportId('user-b', queued.localReportId),
        isNull,
      );
      expect(createdByKey, hasLength(1));
      expect(sentKeys, [queued.idempotencyKey, queued.idempotencyKey]);
      expect(evidenceHandoffs, 1);
      expect(await drafts.read('user-a', ReportDraftType.full), isNull);
      restarted.dispose();
    },
  );

  test('changed rejected payload gets a new stable idempotency key', () async {
    reachable = true;
    var calls = 0;
    final keys = <String>[];
    final subject = createOutbox(({
      required payload,
      required idempotencyKey,
      required cancelToken,
    }) async {
      calls++;
      keys.add(idempotencyKey);
      if (calls == 1) {
        return const Err(ValidationFailure('Missing report details'));
      }
      return Success(_report('server-2'));
    });
    final draft = _draft('user-a');
    await drafts.write(draft);

    final rejected = await subject.submit(
      ownerId: 'user-a',
      type: ReportDraftType.full,
      payload: const {'description': ''},
      sourceDraftId: draft.draftId,
      sourceDraftUpdatedAt: draft.updatedAt,
    );
    expect(rejected.status, ReportCreateOutboxStatus.rejected);
    expect(rejected.payload['description'], '');
    expect(await drafts.read('user-a', ReportDraftType.full), isNotNull);

    final corrected = await subject.submit(
      ownerId: 'user-a',
      type: ReportDraftType.full,
      payload: const {'description': 'Corrected details'},
      sourceDraftId: draft.draftId,
      sourceDraftUpdatedAt: draft.updatedAt,
    );

    expect(corrected.status, ReportCreateOutboxStatus.synced);
    expect(corrected.idempotencyKey, isNot(rejected.idempotencyKey));
    expect(keys, [rejected.idempotencyKey, corrected.idempotencyKey]);
    expect(
      await ReportCreateOutboxStore(storage).readAll('user-a'),
      hasLength(1),
    );
    expect(
      await ReportCreateOutboxStore(
        storage,
      ).readServerReportId('user-a', corrected.localReportId),
      'server-2',
    );
    subject.dispose();
  });

  test('401 pauses, 409 rejects, 408 and 500 wait for retry', () async {
    reachable = true;
    final failures = <Failure>[
      const AuthFailure('Expired'),
      const UnknownFailure.withStatus('Idempotency conflict', 409),
      const UnknownFailure.withStatus('Request timed out', 408),
      const ServerFailure('Temporary error'),
    ];
    final subject = createOutbox(
      ({
        required payload,
        required idempotencyKey,
        required cancelToken,
      }) async => Err(failures.removeAt(0)),
    );

    final paused = await subject.submit(
      ownerId: 'user-a',
      type: ReportDraftType.quick,
      payload: const {'description': 'Auth case'},
      sourceDraftId: 'auth-draft',
    );
    final conflict = await subject.submit(
      ownerId: 'user-a',
      type: ReportDraftType.quick,
      payload: const {'description': 'Conflict case'},
      sourceDraftId: 'conflict-draft',
    );
    final timeout = await subject.submit(
      ownerId: 'user-a',
      type: ReportDraftType.quick,
      payload: const {'description': 'Timeout case'},
      sourceDraftId: 'timeout-draft',
    );
    final retry = await subject.submit(
      ownerId: 'user-a',
      type: ReportDraftType.quick,
      payload: const {'description': 'Server case'},
      sourceDraftId: 'server-draft',
    );

    expect(paused.status, ReportCreateOutboxStatus.paused);
    expect(conflict.status, ReportCreateOutboxStatus.rejected);
    expect(conflict.errorKind, ReportCreateOutboxErrorKind.conflict);
    expect(timeout.status, ReportCreateOutboxStatus.retryWaiting);
    expect(retry.status, ReportCreateOutboxStatus.retryWaiting);
    expect(retry.nextAttemptAt, isNotNull);
    subject.dispose();
  });

  test('retry timer drains failures after reconnect', () async {
    reachable = false;
    now = DateTime.now().toUtc();
    var calls = 0;
    final subject = createOutbox(({
      required payload,
      required idempotencyKey,
      required cancelToken,
    }) async {
      calls++;
      return calls == 1
          ? const Err(ServerFailure('Temporary error'))
          : Success(_report('server-after-retry'));
    });

    final queued = await subject.submit(
      ownerId: 'user-a',
      type: ReportDraftType.full,
      payload: const {'title': 'Delayed report'},
    );
    reachable = true;
    await subject.resume('user-a');
    expect(calls, 1);
    expect(
      (await ReportCreateOutboxStore(
        storage,
      ).read('user-a', queued.localReportId))?.status,
      ReportCreateOutboxStatus.retryWaiting,
    );

    now = now.add(const Duration(seconds: 3));
    await Future<void>.delayed(const Duration(milliseconds: 2200));

    expect(calls, 2);
    expect(
      await ReportCreateOutboxStore(
        storage,
      ).read('user-a', queued.localReportId),
      isNull,
    );
    subject.dispose();
  });

  test(
    'logout pauses in-flight work and same owner resumes with same key',
    () async {
      reachable = true;
      final requestStarted = Completer<void>();
      final firstResponse = Completer<Result<Report>>();
      final keys = <String>[];
      var calls = 0;
      final subject = createOutbox(({
        required payload,
        required idempotencyKey,
        required cancelToken,
      }) {
        calls++;
        keys.add(idempotencyKey);
        if (calls == 1) {
          requestStarted.complete();
          return firstResponse.future;
        }
        return Future.value(Success(_report('server-resumed')));
      });

      final submission = subject.submit(
        ownerId: 'user-a',
        type: ReportDraftType.full,
        payload: const {'description': 'Preserve after logout'},
      );
      await requestStarted.future;
      await subject.pause();
      firstResponse.complete(Success(_report('server-first')));
      final paused = await submission;

      expect(paused.status, ReportCreateOutboxStatus.pending);
      expect(paused.serverReportId, isNull);
      signedInOwner = 'user-b';
      expect(await subject.resume('user-b'), 0);
      expect(calls, 1);

      signedInOwner = 'user-a';
      expect(await subject.resume('user-a'), 1);
      expect(
        await ReportCreateOutboxStore(
          storage,
        ).readServerReportId('user-a', paused.localReportId),
        'server-resumed',
      );
      expect(keys, [paused.idempotencyKey, paused.idempotencyKey]);
      subject.dispose();
    },
  );

  test(
    'reachability flapping retries the durable operation unchanged',
    () async {
      reachable = true;
      final keys = <String>[];
      var calls = 0;
      final subject = createOutbox(({
        required payload,
        required idempotencyKey,
        required cancelToken,
      }) async {
        calls++;
        keys.add(idempotencyKey);
        if (calls == 1) return const Err(NetworkFailure('Response timed out'));
        return Success(_report('server-flap'));
      });
      final queued = await subject.submit(
        ownerId: 'user-a',
        type: ReportDraftType.quick,
        payload: const {'description': 'Network flapping'},
      );
      expect(queued.status, ReportCreateOutboxStatus.retryWaiting);
      expect(queued.nextAttemptAt, isNotNull);

      reachable = false;
      now = queued.nextAttemptAt!.add(const Duration(milliseconds: 1));
      expect(await subject.resume('user-a'), 0);
      expect(calls, 1);

      reachable = true;
      expect(await subject.resume('user-a'), 1);
      final synced = await ReportCreateOutboxStore(
        storage,
      ).read('user-a', queued.localReportId);
      expect(synced, isNull);
      expect(
        await ReportCreateOutboxStore(
          storage,
        ).readServerReportId('user-a', queued.localReportId),
        'server-flap',
      );
      expect(keys, [queued.idempotencyKey, queued.idempotencyKey]);
      subject.dispose();
    },
  );

  test(
    'handoff recovery keeps staged file and reuses persisted evidence intent',
    () async {
      reachable = true;
      final picked = File('${root.path}${Platform.pathSeparator}picked.jpg');
      await picked.writeAsBytes(List<int>.generate(32, (index) => index));
      final staged = await stageEvidenceFile(
        XFile(picked.path),
        stagingDirectory: root,
      );
      await picked.delete();

      final store = ReportCreateOutboxStore(storage);
      final firstQueue = createEvidenceQueue(store);
      final handoffIntentIds = <String>[];
      var handoffAttempts = 0;
      final submit = _successfulRequest('server-handoff');

      final first = createOutbox(
        submit,
        handoff: (item) async {
          handoffAttempts++;
          expect(
            await store.readServerReportId(item.ownerId, item.localReportId),
            'server-handoff',
          );
          if (handoffAttempts == 1) {
            throw StateError('simulated death after mapping');
          }
          final accepted = await firstQueue.enqueue(
            userId: item.ownerId,
            reportId: item.serverReportId!,
            files: [staged],
          );
          handoffIntentIds.add(accepted.single.id);
          if (handoffAttempts == 2) {
            throw StateError('simulated death after durable queue write');
          }
          await firstQueue.resume(item.ownerId);
          return true;
        },
      );
      final queued = await first.submit(
        ownerId: 'user-a',
        type: ReportDraftType.full,
        payload: const {'description': 'Handoff recovery'},
        attachmentRefs: [staged.path],
      );
      expect(queued.status, ReportCreateOutboxStatus.synced);
      expect(
        (await store.read('user-a', queued.localReportId))?.attachmentRefs,
        [staged.path],
      );
      expect(firstQueue.allState, isEmpty);
      expect(await staged.exists(), isTrue);
      first.dispose();
      firstQueue.dispose();

      signedInOwner = 'user-b';
      final secondQueue = createEvidenceQueue(store);
      final second = createOutbox(
        submit,
        handoff: (item) async {
          handoffAttempts++;
          final accepted = await secondQueue.enqueue(
            userId: item.ownerId,
            reportId: item.serverReportId!,
            files: [staged],
          );
          handoffIntentIds.add(accepted.single.id);
          if (handoffAttempts == 2) {
            throw StateError('simulated death after durable queue write');
          }
          await secondQueue.resume(item.ownerId);
          return true;
        },
      );
      expect(await second.resume('user-b'), 0);
      expect(handoffAttempts, 1);
      expect(secondQueue.allState, isEmpty);

      signedInOwner = 'user-a';
      await second.resume('user-a');
      expect(handoffAttempts, 2);
      expect(secondQueue.allState, hasLength(1));
      expect(await staged.exists(), isTrue);
      expect(
        (await store.read('user-a', queued.localReportId))?.attachmentRefs,
        [staged.path],
      );
      second.dispose();
      secondQueue.dispose();

      final thirdQueue = createEvidenceQueue(store);
      final third = createOutbox(
        submit,
        handoff: (item) async {
          handoffAttempts++;
          final accepted = await thirdQueue.enqueue(
            userId: item.ownerId,
            reportId: item.serverReportId!,
            files: [staged],
          );
          handoffIntentIds.add(accepted.single.id);
          await thirdQueue.resume(item.ownerId);
          return true;
        },
      );
      await third.resume('user-a');

      expect(await store.read('user-a', queued.localReportId), isNull);
      expect(
        await store.readServerReportId('user-a', queued.localReportId),
        'server-handoff',
      );
      expect(thirdQueue.allState, hasLength(1));
      expect(handoffIntentIds, hasLength(2));
      expect(handoffIntentIds.toSet(), hasLength(1));
      expect(thirdQueue.allState.single.ownerUserId, 'user-a');
      expect(thirdQueue.allState.single.reportId, 'server-handoff');
      expect(thirdQueue.allState.single.localFilePath, staged.path);
      expect(await staged.exists(), isTrue);
      await third.resume('user-a');
      expect(handoffAttempts, 3);
      expect(thirdQueue.allState, hasLength(1));
      third.dispose();
      thirdQueue.dispose();
    },
  );

  test(
    'no-photo cleanup recovers after mapping and handoff are durable',
    () async {
      reachable = true;
      failOutboxDelete = true;
      final submit = _successfulRequest('server-no-photo');
      final first = createOutbox(submit);
      final acknowledged = await first.submit(
        ownerId: 'user-a',
        type: ReportDraftType.quick,
        payload: const {'description': 'No evidence'},
      );

      expect(acknowledged.status, ReportCreateOutboxStatus.synced);
      expect(evidenceHandoffs, 0);
      final saved = await ReportCreateOutboxStore(
        storage,
      ).read('user-a', acknowledged.localReportId);
      expect(saved?.evidenceHandedOff, isTrue);
      expect(saved?.attachmentRefs, isEmpty);
      expect(
        await ReportCreateOutboxStore(
          storage,
        ).readServerReportId('user-a', acknowledged.localReportId),
        'server-no-photo',
      );
      first.dispose();

      failOutboxDelete = false;
      final restarted = createOutbox(submit);
      await restarted.resume('user-a');
      expect(
        await ReportCreateOutboxStore(
          storage,
        ).read('user-a', acknowledged.localReportId),
        isNull,
      );
      expect(evidenceHandoffs, 0);
      restarted.dispose();
    },
  );

  test('pending work stays with owner A while B is signed in', () async {
    final sentOwners = <String>[];
    final subject = createOutbox(({
      required payload,
      required idempotencyKey,
      required cancelToken,
    }) async {
      sentOwners.add(signedInOwner!);
      return Success(_report('server-a'));
    });
    final queued = await subject.submit(
      ownerId: 'user-a',
      type: ReportDraftType.emergency,
      payload: const {'description': 'Urgent', 'isEmergency': true},
    );

    signedInOwner = 'user-b';
    reachable = true;
    expect(await subject.resume('user-a'), 0);
    expect(await subject.resume('user-b'), 0);
    expect(sentOwners, isEmpty);
    expect(
      (await ReportCreateOutboxStore(
        storage,
      ).read('user-a', queued.localReportId))?.status,
      ReportCreateOutboxStatus.pending,
    );
    expect(await ReportCreateOutboxStore(storage).readAll('user-b'), isEmpty);

    signedInOwner = 'user-a';
    expect(await subject.resume('user-a'), 1);
    expect(sentOwners, ['user-a']);
    expect(
      await ReportCreateOutboxStore(
        storage,
      ).readServerReportId('user-a', queued.localReportId),
      'server-a',
    );
    subject.dispose();
  });

  test('duplicate taps share one in-flight create request', () async {
    reachable = true;
    final response = Completer<Result<Report>>();
    var calls = 0;
    final subject = createOutbox(({
      required payload,
      required idempotencyKey,
      required cancelToken,
    }) {
      calls++;
      return response.future;
    });
    final first = subject.submit(
      ownerId: 'user-a',
      type: ReportDraftType.quick,
      payload: const {'description': 'Same tap'},
    );
    final second = subject.submit(
      ownerId: 'user-a',
      type: ReportDraftType.quick,
      payload: const {'description': 'Same tap'},
    );
    await Future<void>.delayed(Duration.zero);
    expect(calls, 1);
    response.complete(Success(_report('server-3')));
    final results = await Future.wait([first, second]);

    expect(results[0].localReportId, results[1].localReportId);
    expect(results[0].idempotencyKey, results[1].idempotencyKey);
    expect(calls, 1);
    subject.dispose();
  });

  test('emergency remains not transmitted until acknowledgement', () async {
    reachable = true;
    final response = Completer<Result<Report>>();
    final subject = createOutbox(
      ({required payload, required idempotencyKey, required cancelToken}) =>
          response.future,
    );
    final future = subject.submit(
      ownerId: 'user-a',
      type: ReportDraftType.emergency,
      payload: const {'description': 'Emergency', 'isEmergency': true},
    );
    await Future<void>.delayed(Duration.zero);
    final queued = (await ReportCreateOutboxStore(
      storage,
    ).readAll('user-a')).single;
    expect(queued.status, ReportCreateOutboxStatus.pending);
    expect(queued.serverReportId, isNull);
    expect(evidenceHandoffs, 0);

    response.complete(Success(_report('server-emergency')));
    final submitted = await future;
    expect(submitted.status, ReportCreateOutboxStatus.synced);
    expect(submitted.serverReportId, 'server-emergency');
    subject.dispose();
  });
}

ReportCreateRequest _fakeServer(
  Map<String, String> createdByKey,
  List<String> sentKeys, {
  required bool Function() dropFirstResponse,
  required void Function() onFirstResponseDropped,
}) =>
    ({required payload, required idempotencyKey, required cancelToken}) async {
      sentKeys.add(idempotencyKey);
      final reportId = createdByKey.putIfAbsent(
        idempotencyKey,
        () => 'server-${createdByKey.length + 1}',
      );
      if (dropFirstResponse()) {
        onFirstResponseDropped();
        return const Err(NetworkFailure('Response lost'));
      }
      return Success(_report(reportId));
    };

Report _report(String id) => Report(id: id, description: 'created');

ReportCreateRequest _successfulRequest(String reportId) =>
    ({required payload, required idempotencyKey, required cancelToken}) async =>
        Success(_report(reportId));

ReportDraft _draft(String ownerId) {
  final createdAt = DateTime.utc(2026, 9, 28, 11);
  return ReportDraft(
    schemaVersion: ReportDraft.currentSchemaVersion,
    draftId: 'draft-full-$ownerId',
    ownerId: ownerId,
    type: ReportDraftType.full,
    createdAt: createdAt,
    updatedAt: createdAt,
    resumeStep: 'review',
    payload: const {'description': 'Original draft'},
    attachmentRefs: const [],
  );
}
