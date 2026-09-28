import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:bayantrack_mobile/features/images/data/evidence_file_stager.dart';
import 'package:bayantrack_mobile/features/images/data/evidence_upload_queue.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory root;
  late SharedPreferences preferences;
  late DateTime now;
  late bool authenticated;
  late bool backendReachable;

  Future<File> source(String name) async {
    final file = File('${root.path}${Platform.pathSeparator}$name');
    await file.writeAsBytes(List<int>.generate(32, (index) => index));
    return file;
  }

  EvidenceUploadQueue queue({
    required EvidenceUploader upload,
    int maxRetryCount = 5,
    Duration baseBackoff = const Duration(seconds: 2),
    Future<Set<String>> Function()? readDraftAttachmentReferences,
    bool Function()? canReachBackend,
  }) {
    return EvidenceUploadQueue(
      preferences: preferences,
      uploadDirectory: Directory('${root.path}${Platform.pathSeparator}owned'),
      upload: upload,
      isAuthenticated: (_) async => authenticated,
      canReachBackend: canReachBackend ?? () => backendReachable,
      readDraftAttachmentReferences: readDraftAttachmentReferences,
      now: () => now,
      maxRetryCount: maxRetryCount,
      baseBackoff: baseBackoff,
      autoSchedule: false,
    );
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    root = await Directory.systemTemp.createTemp('evidence_queue_test_');
    now = DateTime.utc(2026, 7, 26, 12);
    authenticated = true;
    backendReachable = true;
  });

  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  test('failed upload stays durable after report creation', () async {
    final uploads = <String>[];
    var reportCreates = 0;
    Future<String> createReport() async {
      reportCreates++;
      return 'report-created';
    }

    final subject = queue(
      upload:
          ({
            required file,
            required reportId,
            required evidenceKey,
            required isPrimary,
            required cancelToken,
          }) async {
            uploads.add(evidenceKey);
            throw const SocketException('offline');
          },
    );
    final reportId = await createReport();
    final added = await subject.enqueue(
      userId: 'user-a',
      reportId: reportId,
      files: [await source('evidence.jpg')],
    );

    await subject.resume('user-a');

    expect(uploads, [added.single.id]);
    expect(subject.state.single.reportId, 'report-created');
    expect(subject.state.single.state, EvidenceUploadState.retryWaiting);
    expect(subject.state.single.retryCount, 1);
    expect(subject.state.single.error, EvidenceUploadError.uploadUnavailable);
    expect(reportCreates, 1);
  });

  test('pending intent and stable key survive queue restart', () async {
    authenticated = false;
    final first = queue(upload: _successfulUpload);
    final added = await first.enqueue(
      userId: 'user-a',
      reportId: 'report-1',
      files: [await source('restart.jpg')],
    );
    final ownedPath = added.single.localFilePath;
    first.dispose();

    final restored = queue(upload: _successfulUpload);
    await restored.initialize();

    expect(restored.allState.single.id, added.single.id);
    expect(restored.allState.single.state, EvidenceUploadState.pending);
    expect(await File(ownedPath).exists(), isTrue);
  });

  test(
    'unreachable Backend pauses evidence until reachability returns',
    () async {
      final uploads = <String>[];
      final subject = queue(
        upload:
            ({
              required file,
              required reportId,
              required evidenceKey,
              required isPrimary,
              required cancelToken,
            }) async {
              uploads.add(evidenceKey);
            },
      );
      final added = await subject.enqueue(
        userId: 'user-a',
        reportId: 'report-1',
        files: [await source('reachability.jpg')],
      );

      backendReachable = false;
      await subject.resume('user-a');
      expect(uploads, isEmpty);
      expect(subject.allState.single.state, EvidenceUploadState.pending);

      backendReachable = true;
      await subject.resume('user-a');
      expect(uploads, [added.single.id]);
      expect(subject.allState.single.state, EvidenceUploadState.completed);
    },
  );

  test('queue cleanup retains staged files referenced by a draft', () async {
    final picked = await source('draft-photo.jpg');
    final staged = await stageEvidenceFile(
      XFile(picked.path),
      stagingDirectory: root,
    );
    await staged.setLastModified(now.subtract(const Duration(days: 8)));
    final subject = queue(
      upload: _successfulUpload,
      readDraftAttachmentReferences: () async => {staged.path},
    );

    await subject.initialize();

    expect(await staged.exists(), isTrue);
    subject.dispose();
  });

  test('staged photo stays queue-owned until upload completes', () async {
    authenticated = false;
    final picked = await source('picked.jpg');
    final staged = await stageEvidenceFile(
      XFile(picked.path),
      stagingDirectory: root,
    );
    await picked.delete();
    final subject = queue(upload: _successfulUpload);

    final added = await subject.enqueue(
      userId: 'user-a',
      reportId: 'report-1',
      files: [staged],
    );

    expect(added.single.localFilePath, staged.path);
    expect(await staged.exists(), isTrue);
    expect(await File(added.single.localFilePath).length(), 32);

    authenticated = true;
    await subject.resume('user-a');
    expect(subject.state.single.state, EvidenceUploadState.completed);
    expect(await staged.exists(), isFalse);
  });

  test(
    'retry reuses one evidence key, never recreates report, and completed stays done',
    () async {
      var calls = 0;
      var reportCreates = 0;
      final keys = <String>[];
      final reportIds = <String>[];
      Future<String> createReport() async {
        reportCreates++;
        return 'report-1';
      }

      final subject = queue(
        upload:
            ({
              required file,
              required reportId,
              required evidenceKey,
              required isPrimary,
              required cancelToken,
            }) async {
              calls++;
              keys.add(evidenceKey);
              reportIds.add(reportId);
              if (calls == 1) throw const SocketException('temporary');
            },
      );
      final reportId = await createReport();
      final added = await subject.enqueue(
        userId: 'user-a',
        reportId: reportId,
        files: [await source('retry.jpg')],
      );

      await subject.resume('user-a');
      await subject.retry(added.single.id);
      await subject.retry(added.single.id);
      await subject.resume('user-a');

      expect(calls, 2);
      expect(keys.toSet(), {added.single.id});
      expect(reportIds.toSet(), {'report-1'});
      expect(reportCreates, 1);
      expect(subject.state.single.state, EvidenceUploadState.completed);
    },
  );

  test('missing source and missing owned copy are marked safely', () async {
    final subject = queue(upload: _successfulUpload);
    final missingSource = File(
      '${root.path}${Platform.pathSeparator}does-not-exist.jpg',
    );
    await subject.enqueue(
      userId: 'user-a',
      reportId: 'report-1',
      files: [missingSource],
    );
    expect(subject.state.single.state, EvidenceUploadState.missingLocalFile);

    final added = await subject.enqueue(
      userId: 'user-a',
      reportId: 'report-1',
      files: [await source('will-disappear.jpg')],
    );
    await File(added.single.localFilePath).delete();
    await subject.resume('user-a');

    expect(subject.state.last.state, EvidenceUploadState.missingLocalFile);
  });

  test('empty draft is preserved when durable ingestion fails', () async {
    final draftDirectory = Directory(
      '${root.path}${Platform.pathSeparator}report_evidence_drafts',
    );
    await draftDirectory.create();
    final staged = File(
      '${draftDirectory.path}${Platform.pathSeparator}draft_empty.jpg',
    );
    await staged.create();
    final subject = queue(upload: _successfulUpload);

    final added = await subject.enqueue(
      userId: 'user-a',
      reportId: 'report-1',
      files: [staged],
    );

    expect(added.single.state, EvidenceUploadState.missingLocalFile);
    expect(added.single.localFilePath, staged.path);
    expect(await staged.exists(), isTrue);
  });

  test('logout and account change isolate intents', () async {
    final uploadedOwners = <String>[];
    final subject = queue(
      upload:
          ({
            required file,
            required reportId,
            required evidenceKey,
            required isPrimary,
            required cancelToken,
          }) async {
            uploadedOwners.add(reportId);
          },
    );
    await subject.enqueue(
      userId: 'user-a',
      reportId: 'report-a',
      files: [await source('a.jpg')],
    );
    await subject.enqueue(
      userId: 'user-b',
      reportId: 'report-b',
      files: [await source('b.jpg')],
    );

    await subject.resume('user-b');
    await subject.pause();
    await subject.resume('user-a');

    expect(uploadedOwners, ['report-b', 'report-a']);
    expect(
      subject.allState.where(
        (item) => item.state == EvidenceUploadState.completed,
      ),
      hasLength(2),
    );
  });

  test('disposal during upload restores uploading intent as pending', () async {
    final pending = Completer<void>();
    final started = Completer<void>();
    final first = queue(
      upload:
          ({
            required file,
            required reportId,
            required evidenceKey,
            required isPrimary,
            required cancelToken,
          }) async {
            started.complete();
            await pending.future;
          },
    );
    await first.enqueue(
      userId: 'user-a',
      reportId: 'report-1',
      files: [await source('dispose.jpg')],
    );
    unawaited(first.resume('user-a'));
    await started.future;
    expect(first.state.single.state, EvidenceUploadState.uploading);

    first.dispose();
    pending.complete();
    await Future<void>.delayed(Duration.zero);

    final restored = queue(upload: _successfulUpload);
    await restored.initialize();
    expect(restored.allState.single.state, EvidenceUploadState.pending);
    await restored.resume('user-a');
    expect(restored.state.single.state, EvidenceUploadState.completed);
  });

  test(
    'owned temporary file is removed only after completion or dismissal',
    () async {
      authenticated = false;
      final subject = queue(upload: _successfulUpload);
      final pending = await subject.enqueue(
        userId: 'user-a',
        reportId: 'report-1',
        files: [await source('pending.jpg')],
      );
      expect(await File(pending.single.localFilePath).exists(), isTrue);

      authenticated = true;
      await subject.resume('user-a');
      expect(await File(pending.single.localFilePath).exists(), isFalse);

      final dismissed = await subject.enqueue(
        userId: 'user-a',
        reportId: 'report-2',
        files: [await source('dismiss.jpg')],
      );
      expect(await File(dismissed.single.localFilePath).exists(), isTrue);
      await subject.dismiss(dismissed.single.id);
      expect(await File(dismissed.single.localFilePath).exists(), isFalse);
      expect(subject.state.last.state, EvidenceUploadState.dismissed);
    },
  );

  test('retry backoff is bounded and retry limit becomes failed', () async {
    var calls = 0;
    final subject = queue(
      maxRetryCount: 3,
      baseBackoff: const Duration(seconds: 4),
      upload:
          ({
            required file,
            required reportId,
            required evidenceKey,
            required isPrimary,
            required cancelToken,
          }) async {
            calls++;
            throw const SocketException('temporary');
          },
    );
    await subject.enqueue(
      userId: 'user-a',
      reportId: 'report-1',
      files: [await source('backoff.jpg')],
    );

    await subject.resume('user-a');
    expect(
      subject.state.single.nextRetryAt,
      now.add(const Duration(seconds: 4)),
    );
    await subject.resume('user-a');
    expect(calls, 1);

    now = now.add(const Duration(seconds: 4));
    await subject.resume('user-a');
    expect(
      subject.state.single.nextRetryAt,
      now.add(const Duration(seconds: 8)),
    );
    now = now.add(const Duration(seconds: 8));
    await subject.resume('user-a');

    expect(calls, 3);
    expect(subject.state.single.state, EvidenceUploadState.failed);
    expect(subject.state.single.error, EvidenceUploadError.retryLimitReached);
  });

  test(
    'multiple evidence items keep one primary and single-flight uploads',
    () async {
      var inFlight = 0;
      var maxInFlight = 0;
      final keys = <String>[];
      final primary = <bool>[];
      final subject = queue(
        upload:
            ({
              required file,
              required reportId,
              required evidenceKey,
              required isPrimary,
              required cancelToken,
            }) async {
              inFlight++;
              maxInFlight = max(maxInFlight, inFlight);
              keys.add(evidenceKey);
              primary.add(isPrimary);
              await Future<void>.delayed(Duration.zero);
              inFlight--;
            },
      );
      final added = await subject.enqueue(
        userId: 'user-a',
        reportId: 'report-1',
        files: [await source('one.jpg'), await source('two.jpg')],
      );

      await Future.wait([subject.resume('user-a'), subject.resume('user-a')]);

      expect(maxInFlight, 1);
      expect(keys, added.map((item) => item.id));
      expect(primary, [true, false]);
      expect(
        subject.state.where(
          (item) => item.state == EvidenceUploadState.completed,
        ),
        hasLength(2),
      );
    },
  );
}

Future<void> _successfulUpload({
  required File file,
  required String reportId,
  required String evidenceKey,
  required bool isPrimary,
  required CancelToken cancelToken,
}) async {}
