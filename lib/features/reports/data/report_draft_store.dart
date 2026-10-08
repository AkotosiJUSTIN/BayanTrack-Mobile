import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../auth/auth_di.dart';

enum ReportDraftType { full, quick, emergency }

String newReportLocalId([String prefix = 'draft']) {
  final random = Random.secure().nextInt(0x7fffffff).toRadixString(36);
  return '${prefix}_${DateTime.now().microsecondsSinceEpoch}_$random';
}

class ReportDraft {
  const ReportDraft({
    required this.schemaVersion,
    required this.draftId,
    required this.ownerId,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.resumeStep,
    required this.payload,
    required this.attachmentRefs,
  });

  static const currentSchemaVersion = 1;

  final int schemaVersion;
  final String draftId;
  final String ownerId;
  final ReportDraftType type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String resumeStep;
  final Map<String, Object?> payload;
  final List<String> attachmentRefs;

  Map<String, Object?> toJson() => {
    'schemaVersion': schemaVersion,
    'draftId': draftId,
    'ownerId': ownerId,
    'type': type.name,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'resumeStep': resumeStep,
    'payload': payload,
    'attachmentRefs': attachmentRefs,
  };

  static ReportDraft? fromJson(Object? value) {
    if (value is! Map) return null;
    final json = Map<String, dynamic>.from(value);
    final type = ReportDraftType.values.where(
      (item) => item.name == json['type'],
    );
    final payload = json['payload'];
    final attachmentRefs = json['attachmentRefs'];
    final createdAt = DateTime.tryParse(json['createdAt']?.toString() ?? '');
    final updatedAt = DateTime.tryParse(json['updatedAt']?.toString() ?? '');
    if (json['schemaVersion'] != currentSchemaVersion ||
        json['draftId'] is! String ||
        (json['draftId'] as String).isEmpty ||
        json['ownerId'] is! String ||
        (json['ownerId'] as String).isEmpty ||
        type.isEmpty ||
        createdAt == null ||
        updatedAt == null ||
        json['resumeStep'] is! String ||
        payload is! Map ||
        attachmentRefs is! List ||
        attachmentRefs.any((item) => item is! String)) {
      return null;
    }
    return ReportDraft(
      schemaVersion: currentSchemaVersion,
      draftId: json['draftId'] as String,
      ownerId: json['ownerId'] as String,
      type: type.first,
      createdAt: createdAt,
      updatedAt: updatedAt,
      resumeStep: json['resumeStep'] as String,
      payload: Map<String, Object?>.from(payload),
      attachmentRefs: List<String>.from(attachmentRefs),
    );
  }
}

class ReportDraftStore {
  ReportDraftStore(this._storage);

  static const _keyPrefix = 'bayantrack_report_draft_v1';

  final FlutterSecureStorage _storage;
  Future<void> _tail = Future<void>.value();

  Future<ReportDraft?> read(String ownerId, ReportDraftType type) =>
      _serialize(() => _read(ownerId, type));

  Future<List<ReportDraft>> readAll(String ownerId) => _serialize(() async {
    final drafts = <ReportDraft>[];
    for (final type in ReportDraftType.values) {
      final draft = await _read(ownerId, type);
      if (draft != null) drafts.add(draft);
    }
    return drafts;
  });

  Future<void> write(ReportDraft draft) => _serialize(() async {
    if (draft.ownerId.trim().isEmpty ||
        draft.schemaVersion != ReportDraft.currentSchemaVersion) {
      throw ArgumentError('Invalid report draft owner or schema');
    }
    await _storage.write(
      key: _key(draft.ownerId, draft.type),
      value: jsonEncode(draft.toJson()),
    );
  });

  Future<void> delete(String ownerId, ReportDraftType type) =>
      _serialize(() => _storage.delete(key: _key(ownerId, type)));

  Future<Set<String>> readAllAttachmentReferences() => _serialize(() async {
    final values = await _storage.readAll();
    final references = <String>{};
    for (final entry in values.entries) {
      if (!entry.key.startsWith('$_keyPrefix.')) continue;
      try {
        final draft = ReportDraft.fromJson(jsonDecode(entry.value));
        if (draft == null || _key(draft.ownerId, draft.type) != entry.key) {
          continue;
        }
        references.addAll(draft.attachmentRefs);
      } catch (_) {
        // Ignore corrupt draft metadata without deleting referenced files.
      }
    }
    return references;
  });

  Future<ReportDraft?> _read(String ownerId, ReportDraftType type) async {
    try {
      final stored = await _storage.read(key: _key(ownerId, type));
      final draft = stored == null
          ? null
          : ReportDraft.fromJson(jsonDecode(stored));
      if (draft == null || draft.ownerId != ownerId || draft.type != type) {
        return null;
      }
      return draft;
    } catch (_) {
      return null;
    }
  }

  Future<T> _serialize<T>(Future<T> Function() action) async {
    final previous = _tail;
    final done = Completer<void>();
    _tail = done.future;
    await previous;
    try {
      return await action();
    } finally {
      done.complete();
    }
  }

  String _key(String ownerId, ReportDraftType type) {
    final encodedOwner = base64Url
        .encode(utf8.encode(ownerId))
        .replaceAll('=', '');
    return '$_keyPrefix.$encodedOwner.${type.name}';
  }
}

final reportDraftStoreProvider = Provider<ReportDraftStore>((ref) {
  return ReportDraftStore(ref.watch(secureStorageProvider));
});
