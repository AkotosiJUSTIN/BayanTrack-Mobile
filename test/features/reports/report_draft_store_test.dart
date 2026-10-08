import 'dart:convert';

import 'package:bayantrack_mobile/features/reports/data/report_draft_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _StorageMock extends Mock implements FlutterSecureStorage {}

void main() {
  late _StorageMock storage;
  late Map<String, String> values;

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
  });

  test(
    'all draft types survive store recreation with incomplete payloads',
    () async {
      final store = ReportDraftStore(storage);
      final drafts = [
        _draft('user-A', ReportDraftType.full, {
          'description': 'Incomplete full report',
        }),
        _draft('user-A', ReportDraftType.quick, {'description': 'Quick note'}),
        _draft('user-A', ReportDraftType.emergency, {
          'categoryKey': 'flood_disaster',
        }),
      ];
      for (final draft in drafts) {
        await store.write(draft);
      }

      final afterRestart = ReportDraftStore(storage);
      final restored = await afterRestart.readAll('user-A');

      expect(restored, hasLength(3));
      for (final draft in drafts) {
        final saved = await afterRestart.read('user-A', draft.type);
        expect(saved?.draftId, draft.draftId);
        expect(saved?.payload, draft.payload);
        expect(saved?.resumeStep, draft.resumeStep);
      }
    },
  );

  test(
    'draft records and reads are isolated by owner and report type',
    () async {
      final store = ReportDraftStore(storage);
      await store.write(
        _draft('user-A', ReportDraftType.full, {
          'description': 'A private draft',
        }),
      );
      await store.write(
        _draft('user-B', ReportDraftType.full, {
          'description': 'B private draft',
        }),
      );

      expect(
        (await store.read(
          'user-A',
          ReportDraftType.full,
        ))?.payload['description'],
        'A private draft',
      );
      expect(
        (await store.read(
          'user-B',
          ReportDraftType.full,
        ))?.payload['description'],
        'B private draft',
      );
      expect(await store.readAll('user-A'), hasLength(1));
      expect(await store.read('user-A', ReportDraftType.quick), isNull);
    },
  );

  test(
    'attachment cleanup references include every valid owner draft',
    () async {
      final store = ReportDraftStore(storage);
      await store.write(
        _draft(
          'user-A',
          ReportDraftType.full,
          const {},
          refs: ['/private/a.jpg'],
        ),
      );
      await store.write(
        _draft(
          'user-B',
          ReportDraftType.full,
          const {},
          refs: ['/private/b.jpg'],
        ),
      );
      await store.write(
        _draft('user-A', ReportDraftType.quick, const {}, refs: const []),
      );

      expect(await store.readAllAttachmentReferences(), {
        '/private/a.jpg',
        '/private/b.jpg',
      });
    },
  );

  test('foreign-owner metadata stored under another key is ignored', () async {
    final store = ReportDraftStore(storage);
    await store.write(
      _draft(
        'user-A',
        ReportDraftType.full,
        const {},
        refs: ['/private/a.jpg'],
      ),
    );
    final entry = values.entries.single;
    final payload = ReportDraft.fromJson(jsonDecode(entry.value))!;
    values[entry.key] = jsonEncode(
      ReportDraft(
        schemaVersion: payload.schemaVersion,
        draftId: payload.draftId,
        ownerId: 'user-B',
        type: payload.type,
        createdAt: payload.createdAt,
        updatedAt: payload.updatedAt,
        resumeStep: payload.resumeStep,
        payload: payload.payload,
        attachmentRefs: payload.attachmentRefs,
      ).toJson(),
    );

    expect(await store.read('user-A', ReportDraftType.full), isNull);
    expect(await store.readAllAttachmentReferences(), isEmpty);
  });

  test('unsupported and malformed schema versions are rejected', () async {
    final value = _draft('user-A', ReportDraftType.full, const {}).toJson();
    expect(ReportDraft.fromJson(value), isNotNull);
    expect(ReportDraft.fromJson({...value, 'schemaVersion': 2}), isNull);
    expect(
      ReportDraft.fromJson({...value, 'attachmentRefs': 'not-a-list'}),
      isNull,
    );
  });
}

ReportDraft _draft(
  String ownerId,
  ReportDraftType type,
  Map<String, Object?> payload, {
  List<String> refs = const [],
}) {
  final now = DateTime.utc(2026, 9, 27);
  return ReportDraft(
    schemaVersion: ReportDraft.currentSchemaVersion,
    draftId: 'draft-${type.name}-$ownerId',
    ownerId: ownerId,
    type: type,
    createdAt: now,
    updatedAt: now,
    resumeStep: type == ReportDraftType.full ? 'details' : 'form',
    payload: payload,
    attachmentRefs: refs,
  );
}
