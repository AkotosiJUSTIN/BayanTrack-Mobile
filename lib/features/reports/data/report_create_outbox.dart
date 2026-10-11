import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/domain/failures.dart';
import '../../../core/domain/result.dart';
import '../../../core/network/error_mapper.dart';
import '../../auth/auth_di.dart';
import '../domain/entities/report.dart';
import 'report_draft_store.dart';

enum ReportCreateOutboxStatus {
  pending,
  retryWaiting,
  paused,
  rejected,
  synced,
}

enum ReportCreateOutboxErrorKind {
  network,
  server,
  authentication,
  validation,
  conflict,
  unavailable,
  systemRestriction,
}

class ReportCreateOutboxItem {
  ReportCreateOutboxItem({
    required this.schemaVersion,
    required this.localReportId,
    required this.ownerId,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.idempotencyKey,
    required Map<String, Object?> payload,
    required List<String> attachmentRefs,
    required this.status,
    this.sourceDraftId,
    this.sourceDraftUpdatedAt,
    this.attemptCount = 0,
    this.nextAttemptAt,
    this.serverReportId,
    this.safeError,
    this.errorKind,
    Map<String, String>? fieldErrors,
    this.evidenceHandedOff = false,
  }) : payload = _freezeMap(payload),
       attachmentRefs = List.unmodifiable(attachmentRefs),
       fieldErrors = fieldErrors == null ? null : Map.unmodifiable(fieldErrors);

  static const currentSchemaVersion = 1;

  final int schemaVersion;
  final String localReportId;
  final String ownerId;
  final ReportDraftType type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String idempotencyKey;
  final String? sourceDraftId;
  final DateTime? sourceDraftUpdatedAt;
  final Map<String, Object?> payload;
  final List<String> attachmentRefs;
  final ReportCreateOutboxStatus status;
  final int attemptCount;
  final DateTime? nextAttemptAt;
  final String? serverReportId;
  final String? safeError;
  final ReportCreateOutboxErrorKind? errorKind;
  final Map<String, String>? fieldErrors;
  final bool evidenceHandedOff;

  bool get isPending => status != ReportCreateOutboxStatus.synced;

  bool get canDiscard =>
      serverReportId == null &&
      (status == ReportCreateOutboxStatus.rejected &&
              errorKind != ReportCreateOutboxErrorKind.conflict ||
          status != ReportCreateOutboxStatus.synced && attemptCount == 0);

  Map<String, Object?> toJson() => {
    'schemaVersion': schemaVersion,
    'localReportId': localReportId,
    'ownerId': ownerId,
    'type': type.name,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'idempotencyKey': idempotencyKey,
    'sourceDraftId': sourceDraftId,
    'sourceDraftUpdatedAt': sourceDraftUpdatedAt?.toUtc().toIso8601String(),
    'payload': payload,
    'attachmentRefs': attachmentRefs,
    'status': status.name,
    'attemptCount': attemptCount,
    'nextAttemptAt': nextAttemptAt?.toUtc().toIso8601String(),
    'serverReportId': serverReportId,
    'safeError': safeError,
    'errorKind': errorKind?.name,
    'fieldErrors': fieldErrors,
    'evidenceHandedOff': evidenceHandedOff,
  };

  static ReportCreateOutboxItem? fromJson(Object? value) {
    if (value is! Map) return null;
    final json = Map<String, dynamic>.from(value);
    final type = ReportDraftType.values.where(
      (item) => item.name == json['type'],
    );
    final status = ReportCreateOutboxStatus.values.where(
      (item) => item.name == json['status'],
    );
    final errorKind = ReportCreateOutboxErrorKind.values.where(
      (item) => item.name == json['errorKind'],
    );
    final payload = json['payload'];
    final attachmentRefs = json['attachmentRefs'];
    final fieldErrors = json['fieldErrors'];
    final createdAt = DateTime.tryParse(json['createdAt']?.toString() ?? '');
    final updatedAt = DateTime.tryParse(json['updatedAt']?.toString() ?? '');
    final sourceDraftUpdatedAt = json['sourceDraftUpdatedAt'] == null
        ? null
        : DateTime.tryParse(json['sourceDraftUpdatedAt'].toString());
    final nextAttemptAt = json['nextAttemptAt'] == null
        ? null
        : DateTime.tryParse(json['nextAttemptAt'].toString());

    if (json['schemaVersion'] != currentSchemaVersion ||
        json['localReportId'] is! String ||
        (json['localReportId'] as String).isEmpty ||
        json['ownerId'] is! String ||
        (json['ownerId'] as String).isEmpty ||
        json['idempotencyKey'] is! String ||
        (json['idempotencyKey'] as String).isEmpty ||
        type.isEmpty ||
        status.isEmpty ||
        createdAt == null ||
        updatedAt == null ||
        (json['sourceDraftUpdatedAt'] != null &&
            sourceDraftUpdatedAt == null) ||
        (json['nextAttemptAt'] != null && nextAttemptAt == null) ||
        payload is! Map ||
        attachmentRefs is! List ||
        attachmentRefs.any((item) => item is! String) ||
        (json['sourceDraftId'] != null && json['sourceDraftId'] is! String) ||
        (fieldErrors != null && fieldErrors is! Map) ||
        (fieldErrors is Map &&
            fieldErrors.entries.any(
              (entry) => entry.key is! String || entry.value is! String,
            ))) {
      return null;
    }
    try {
      final payloadMap = Map<String, Object?>.from(payload);
      jsonEncode(payloadMap);
      return ReportCreateOutboxItem(
        schemaVersion: currentSchemaVersion,
        localReportId: json['localReportId'] as String,
        ownerId: json['ownerId'] as String,
        type: type.first,
        createdAt: createdAt,
        updatedAt: updatedAt,
        idempotencyKey: json['idempotencyKey'] as String,
        sourceDraftId: json['sourceDraftId'] as String?,
        sourceDraftUpdatedAt: sourceDraftUpdatedAt,
        payload: payloadMap,
        attachmentRefs: List<String>.from(attachmentRefs),
        status: status.first,
        attemptCount: (json['attemptCount'] as num?)?.toInt() ?? 0,
        nextAttemptAt: nextAttemptAt,
        serverReportId: json['serverReportId'] as String?,
        safeError: json['safeError'] as String?,
        errorKind: errorKind.isEmpty ? null : errorKind.first,
        fieldErrors: fieldErrors == null
            ? null
            : Map<String, String>.from(fieldErrors),
        evidenceHandedOff: json['evidenceHandedOff'] == true,
      );
    } on Object {
      return null;
    }
  }

  ReportCreateOutboxItem copyWith({
    ReportCreateOutboxStatus? status,
    DateTime? updatedAt,
    int? attemptCount,
    DateTime? nextAttemptAt,
    bool clearNextAttemptAt = false,
    String? serverReportId,
    List<String>? attachmentRefs,
    bool? evidenceHandedOff,
    String? safeError,
    ReportCreateOutboxErrorKind? errorKind,
    Map<String, String>? fieldErrors,
    bool clearFailure = false,
  }) => ReportCreateOutboxItem(
    schemaVersion: schemaVersion,
    localReportId: localReportId,
    ownerId: ownerId,
    type: type,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    idempotencyKey: idempotencyKey,
    sourceDraftId: sourceDraftId,
    sourceDraftUpdatedAt: sourceDraftUpdatedAt,
    payload: payload,
    attachmentRefs: attachmentRefs ?? this.attachmentRefs,
    status: status ?? this.status,
    attemptCount: attemptCount ?? this.attemptCount,
    nextAttemptAt: clearNextAttemptAt
        ? null
        : nextAttemptAt ?? this.nextAttemptAt,
    serverReportId: serverReportId ?? this.serverReportId,
    safeError: clearFailure ? safeError : safeError ?? this.safeError,
    errorKind: clearFailure ? errorKind : errorKind ?? this.errorKind,
    fieldErrors: clearFailure ? fieldErrors : fieldErrors ?? this.fieldErrors,
    evidenceHandedOff: evidenceHandedOff ?? this.evidenceHandedOff,
  );
}

class ReportCreateOutboxStore {
  ReportCreateOutboxStore(this._storage);

  static const _keyPrefix = 'bayantrack_report_create_outbox_v1';
  static const _mappingKeyPrefix = 'bayantrack_report_create_mapping_v1';

  final FlutterSecureStorage _storage;
  Future<void> _tail = Future<void>.value();

  Future<List<ReportCreateOutboxItem>> readAll(String ownerId) =>
      _serialize(() async {
        final items = await _readAllStored();
        return items.where((item) => item.ownerId == ownerId).toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      });

  Future<ReportCreateOutboxItem?> read(String ownerId, String localReportId) =>
      _serialize(() => _read(ownerId, localReportId));

  Future<String?> readServerReportId(String ownerId, String localReportId) =>
      _serialize(() async {
        if (ownerId.trim().isEmpty || localReportId.isEmpty) return null;
        return _storage.read(key: _mappingKey(ownerId, localReportId));
      });

  Future<void> writeServerReportMapping(
    String ownerId,
    String localReportId,
    String serverReportId,
  ) => _serialize(() async {
    if (ownerId.trim().isEmpty ||
        localReportId.isEmpty ||
        serverReportId.trim().isEmpty) {
      throw ArgumentError('Invalid report mapping owner or ID');
    }
    final item = await _read(ownerId, localReportId);
    if (item?.serverReportId != serverReportId) {
      throw StateError('Report mapping requires a persisted server ID');
    }
    final key = _mappingKey(ownerId, localReportId);
    final previous = await _storage.read(key: key);
    if (previous != null && previous != serverReportId) {
      throw StateError('A local report cannot map to multiple server IDs');
    }
    await _storage.write(key: key, value: serverReportId);
  });

  Future<void> removeAfterEvidenceHandoff(
    String ownerId,
    String localReportId,
  ) => _serialize(() async {
    final item = await _read(ownerId, localReportId);
    if (item == null) return;
    final serverReportId = item.serverReportId;
    final mappedId = await _storage.read(
      key: _mappingKey(ownerId, localReportId),
    );
    if (item.status != ReportCreateOutboxStatus.synced ||
        !item.evidenceHandedOff ||
        item.attachmentRefs.isNotEmpty ||
        serverReportId == null ||
        mappedId != serverReportId) {
      throw StateError('Report outbox cleanup requires a complete handoff');
    }
    await _storage.delete(key: _key(ownerId, localReportId));
  });

  Future<void> write(ReportCreateOutboxItem item) => _serialize(() async {
    if (item.ownerId.trim().isEmpty ||
        item.localReportId.isEmpty ||
        item.idempotencyKey.isEmpty ||
        item.schemaVersion != ReportCreateOutboxItem.currentSchemaVersion) {
      throw ArgumentError('Invalid report outbox owner, key, or schema');
    }
    final key = _key(item.ownerId, item.localReportId);
    final previousValue = await _storage.read(key: key);
    if (previousValue != null) {
      ReportCreateOutboxItem? previous;
      try {
        previous = ReportCreateOutboxItem.fromJson(jsonDecode(previousValue));
      } catch (_) {
        // Replace corrupt metadata only with a new operation at a distinct key.
      }
      if (previous != null && !_sameSnapshot(previous, item)) {
        throw StateError('Report outbox submission snapshots are immutable');
      }
      if (previous?.status == ReportCreateOutboxStatus.synced &&
          item.status != ReportCreateOutboxStatus.synced) {
        throw StateError('A synchronized report cannot return to pending');
      }
    }
    await _storage.write(key: key, value: jsonEncode(item.toJson()));
  });

  Future<void> discard(String ownerId, String localReportId) =>
      _serialize(() async {
        final item = await _read(ownerId, localReportId);
        if (item == null) return;
        if (!item.canDiscard) {
          throw StateError('This report may already have reached the server.');
        }
        await _storage.delete(key: _key(ownerId, localReportId));
      });

  Future<Set<String>> readAllAttachmentReferences() => _serialize(() async {
    final items = await _readAllStored();
    return items
        .expand((item) => item.attachmentRefs)
        .where((path) => path.isNotEmpty)
        .toSet();
  });

  Future<ReportCreateOutboxItem?> _read(
    String ownerId,
    String localReportId,
  ) async {
    final stored = await _storage.read(key: _key(ownerId, localReportId));
    if (stored == null) return null;
    try {
      final item = ReportCreateOutboxItem.fromJson(jsonDecode(stored));
      if (item == null ||
          item.ownerId != ownerId ||
          item.localReportId != localReportId ||
          _key(item.ownerId, item.localReportId) !=
              _key(ownerId, localReportId)) {
        return null;
      }
      return item;
    } catch (_) {
      return null;
    }
  }

  Future<List<ReportCreateOutboxItem>> _readAllStored() async {
    final values = await _storage.readAll();
    final items = <ReportCreateOutboxItem>[];
    for (final entry in values.entries) {
      if (!entry.key.startsWith('$_keyPrefix.')) continue;
      try {
        final item = ReportCreateOutboxItem.fromJson(jsonDecode(entry.value));
        if (item != null &&
            _key(item.ownerId, item.localReportId) == entry.key) {
          items.add(item);
        }
      } catch (_) {
        // Keep corrupt records and files untouched; a later repair can inspect them.
      }
    }
    return items;
  }

  bool _sameSnapshot(ReportCreateOutboxItem a, ReportCreateOutboxItem b) {
    final canClearAttachments =
        a.status == ReportCreateOutboxStatus.synced &&
        b.status == ReportCreateOutboxStatus.synced &&
        b.evidenceHandedOff &&
        b.attachmentRefs.isEmpty;
    return a.ownerId == b.ownerId &&
        a.localReportId == b.localReportId &&
        a.type == b.type &&
        a.idempotencyKey == b.idempotencyKey &&
        a.sourceDraftId == b.sourceDraftId &&
        a.sourceDraftUpdatedAt == b.sourceDraftUpdatedAt &&
        _canonicalJson(a.payload) == _canonicalJson(b.payload) &&
        (canClearAttachments ||
            _sameStrings(a.attachmentRefs, b.attachmentRefs));
  }

  bool _sameStrings(List<String> a, List<String> b) => listEquals(a, b);

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

  String _key(String ownerId, String localReportId) {
    return '$_keyPrefix.${_encodeKeyPart(ownerId)}.${_encodeKeyPart(localReportId)}';
  }

  String _mappingKey(String ownerId, String localReportId) =>
      '$_mappingKeyPrefix.${_encodeKeyPart(ownerId)}.${_encodeKeyPart(localReportId)}';

  String _encodeKeyPart(String value) =>
      base64Url.encode(utf8.encode(value)).replaceAll('=', '');
}

typedef ReportCreateRequest =
    Future<Result<Report>> Function({
      required Map<String, Object?> payload,
      required String idempotencyKey,
      required CancelToken cancelToken,
    });

typedef ReportOutboxOwnerCheck = Future<bool> Function(String ownerId);
typedef ReportOutboxAttachmentHandoff =
    Future<bool> Function(ReportCreateOutboxItem item);

class ReportCreateOutbox {
  ReportCreateOutbox({
    required ReportCreateOutboxStore store,
    required ReportDraftStore drafts,
    required ReportCreateRequest submit,
    required ReportOutboxOwnerCheck isCurrentOwner,
    required ReportOutboxOwnerCheck hasValidSession,
    required bool Function() canReachBackend,
    bool Function(Map<String, Object?> payload)? canSubmit,
    required ReportOutboxAttachmentHandoff handoffAttachments,
    required void Function(String ownerId) onChanged,
    DateTime Function()? now,
    this.maxAttempts = 5,
  }) : _store = store,
       _drafts = drafts,
       _submit = submit,
       _isCurrentOwner = isCurrentOwner,
       _hasValidSession = hasValidSession,
       _canReachBackend = canReachBackend,
       _canSubmit = canSubmit ?? ((_) => true),
       _handoffAttachments = handoffAttachments,
       _changed = onChanged,
       _now = now ?? DateTime.now;

  final ReportCreateOutboxStore _store;
  final ReportDraftStore _drafts;
  final ReportCreateRequest _submit;
  final ReportOutboxOwnerCheck _isCurrentOwner;
  final ReportOutboxOwnerCheck _hasValidSession;
  final bool Function() _canReachBackend;
  final bool Function(Map<String, Object?> payload) _canSubmit;
  final ReportOutboxAttachmentHandoff _handoffAttachments;
  final void Function(String ownerId) _changed;
  final DateTime Function() _now;
  final int maxAttempts;

  String? _activeOwnerId;
  Timer? _retryTimer;
  Future<int>? _drainFuture;
  final Map<String, Future<ReportCreateOutboxItem>> _attempts = {};
  final Map<String, Future<ReportCreateOutboxItem>> _submissions = {};
  final Map<String, CancelToken> _cancelTokens = {};
  final Map<String, Future<void>> _handoffs = {};
  bool _disposed = false;

  Future<ReportCreateOutboxItem> submit({
    required String ownerId,
    required ReportDraftType type,
    required Map<String, Object?> payload,
    List<String> attachmentRefs = const [],
    String? sourceDraftId,
    DateTime? sourceDraftUpdatedAt,
  }) {
    final identity = sourceDraftId == null
        ? '$ownerId:${type.name}:${_canonicalJson(payload)}:${_canonicalJson(attachmentRefs.toSet().toList()..sort())}'
        : '$ownerId:${type.name}:$sourceDraftId';
    final active = _submissions[identity];
    if (active != null) return active;
    final future = _enqueueSubmission(
      ownerId: ownerId,
      type: type,
      payload: payload,
      attachmentRefs: attachmentRefs,
      sourceDraftId: sourceDraftId,
      sourceDraftUpdatedAt: sourceDraftUpdatedAt,
    );
    _submissions[identity] = future;
    return future.whenComplete(() {
      if (identical(_submissions[identity], future)) {
        _submissions.remove(identity);
      }
    });
  }

  Future<ReportCreateOutboxItem> _enqueueSubmission({
    required String ownerId,
    required ReportDraftType type,
    required Map<String, Object?> payload,
    List<String> attachmentRefs = const [],
    String? sourceDraftId,
    DateTime? sourceDraftUpdatedAt,
  }) async {
    if (ownerId.trim().isEmpty || !await _isCurrentOwner(ownerId)) {
      throw StateError('A matching signed-in report owner is required');
    }

    final frozenPayload = _freezeMap(
      Map<String, Object?>.from(jsonDecode(jsonEncode(payload)) as Map),
    );
    final refs = attachmentRefs.toSet().toList();
    final existingItems = await _store.readAll(ownerId);
    final previousForDraft = sourceDraftId == null
        ? null
        : existingItems
              .where(
                (item) =>
                    item.sourceDraftId == sourceDraftId ||
                    item.localReportId == sourceDraftId,
              )
              .fold<ReportCreateOutboxItem?>(
                null,
                (latest, item) =>
                    latest == null || item.updatedAt.isAfter(latest.updatedAt)
                    ? item
                    : latest,
              );

    final identical =
        previousForDraft != null &&
        previousForDraft.type == type &&
        _canonicalJson(previousForDraft.payload) ==
            _canonicalJson(frozenPayload) &&
        _sameStrings(previousForDraft.attachmentRefs, refs);
    if (previousForDraft != null &&
        previousForDraft.errorKind == ReportCreateOutboxErrorKind.conflict) {
      return previousForDraft;
    }
    if (identical &&
        previousForDraft.status == ReportCreateOutboxStatus.synced) {
      return previousForDraft;
    }
    if (identical &&
        previousForDraft.status == ReportCreateOutboxStatus.rejected &&
        previousForDraft.errorKind != ReportCreateOutboxErrorKind.validation) {
      return previousForDraft;
    }
    if (previousForDraft != null &&
        previousForDraft.status != ReportCreateOutboxStatus.synced &&
        previousForDraft.status != ReportCreateOutboxStatus.rejected &&
        !identical) {
      return previousForDraft;
    }

    final now = _now().toUtc();
    final reuseSnapshot =
        identical &&
        previousForDraft.status != ReportCreateOutboxStatus.rejected;
    final item = reuseSnapshot
        ? previousForDraft
        : ReportCreateOutboxItem(
            schemaVersion: ReportCreateOutboxItem.currentSchemaVersion,
            localReportId: newReportLocalId('report'),
            ownerId: ownerId,
            type: type,
            createdAt: now,
            updatedAt: now,
            idempotencyKey: 'report-${newReportLocalId('key')}',
            sourceDraftId: sourceDraftId,
            sourceDraftUpdatedAt: sourceDraftUpdatedAt,
            payload: frozenPayload,
            attachmentRefs: refs,
            status: ReportCreateOutboxStatus.pending,
          );
    if (!reuseSnapshot) {
      await _store.write(item);
      // Persist the replacement before removing definitively rejected snapshots.
      for (final previous in existingItems) {
        if (sourceDraftId != null &&
            (previous.sourceDraftId == sourceDraftId ||
                previous.localReportId == sourceDraftId) &&
            previous.status == ReportCreateOutboxStatus.rejected) {
          await _store.discard(ownerId, previous.localReportId);
        }
      }
    }
    _notifyChanged(ownerId);

    if (item.status == ReportCreateOutboxStatus.synced ||
        item.status == ReportCreateOutboxStatus.rejected ||
        (item.status == ReportCreateOutboxStatus.retryWaiting &&
            (item.attemptCount >= maxAttempts ||
                item.nextAttemptAt?.isAfter(_now()) == true)) ||
        !_canReachBackend()) {
      return item;
    }
    if (!await _hasValidSession(ownerId)) {
      return _savePaused(item);
    }
    _activeOwnerId = ownerId;
    return _attempt(item);
  }

  Future<int> resume(String ownerId) async {
    if (_disposed ||
        ownerId.isEmpty ||
        !_canReachBackend() ||
        !await _isCurrentOwner(ownerId) ||
        !await _hasValidSession(ownerId)) {
      await pause();
      return 0;
    }
    if (_activeOwnerId != null && _activeOwnerId != ownerId) await pause();
    _activeOwnerId = ownerId;
    final running = _drainFuture;
    if (running != null) await running;
    if (_activeOwnerId != ownerId) return 0;
    return _drain(ownerId);
  }

  Future<void> pause() async {
    _retryTimer?.cancel();
    _retryTimer = null;
    _activeOwnerId = null;
    for (final token in _cancelTokens.values) {
      token.cancel('Report synchronization paused');
    }
  }

  Future<void> retry(String ownerId, String localReportId) async {
    if (!await _isCurrentOwner(ownerId)) {
      throw StateError('Sign in with the original account.');
    }
    final item = await _store.read(ownerId, localReportId);
    if (item == null ||
        (item.status != ReportCreateOutboxStatus.retryWaiting &&
            item.status != ReportCreateOutboxStatus.paused)) {
      return;
    }
    final pending = item.copyWith(
      status: ReportCreateOutboxStatus.pending,
      updatedAt: _now().toUtc(),
      attemptCount: 0,
      clearNextAttemptAt: true,
      clearFailure: true,
    );
    await _store.write(pending);
    _notifyChanged(ownerId);
    await resume(ownerId);
  }

  Future<void> discard(String ownerId, String localReportId) async {
    if (!await _isCurrentOwner(ownerId) ||
        _attempts.containsKey(localReportId)) {
      throw StateError('This report cannot be discarded while sending.');
    }
    final item = await _store.read(ownerId, localReportId);
    if (item == null) return;
    await _store.discard(ownerId, localReportId);
    final remaining = await _store.readAll(ownerId);
    if (!remaining.any((other) => other.sourceDraftId == item.sourceDraftId)) {
      await _deleteSourceDraftIfUnchanged(item);
    }
    _notifyChanged(ownerId);
  }

  Future<void> discardDraft(ReportDraft draft) async {
    if (!await _isCurrentOwner(draft.ownerId)) {
      throw StateError('Sign in with the original account.');
    }
    final items = (await _store.readAll(draft.ownerId))
        .where(
          (item) =>
              item.sourceDraftId == draft.draftId ||
              item.localReportId == draft.draftId,
        )
        .toList();
    if (items.any(
      (item) => !item.canDiscard || _attempts.containsKey(item.localReportId),
    )) {
      throw StateError('This report may already have reached the server.');
    }
    for (final item in items) {
      await _store.discard(draft.ownerId, item.localReportId);
    }
    final current = await _drafts.read(draft.ownerId, draft.type);
    if (current?.draftId == draft.draftId) {
      await _drafts.delete(draft.ownerId, draft.type);
    }
    _notifyChanged(draft.ownerId);
  }

  Future<void> restoreRejectedDraft(
    String ownerId,
    String localReportId,
  ) async {
    if (!await _isCurrentOwner(ownerId)) {
      throw StateError('Sign in with the original account.');
    }
    final item = await _store.read(ownerId, localReportId);
    if (item == null ||
        item.status != ReportCreateOutboxStatus.rejected ||
        !item.canDiscard) {
      throw StateError(
        'Submission could not be confirmed. Retry with the original operation.',
      );
    }
    final draftId = item.sourceDraftId ?? item.localReportId;
    final current = await _drafts.read(ownerId, item.type);
    if (current != null && current.draftId != draftId) {
      throw StateError('Finish or discard your other saved draft first.');
    }
    final payload = Map<String, Object?>.from(item.payload);
    for (final key in ['latitude', 'longitude']) {
      final value = payload[key];
      if (value is String) payload[key] = double.tryParse(value);
    }
    if (item.type == ReportDraftType.emergency) {
      payload['categoryKey'] = payload['category'];
    }
    await _drafts.write(
      ReportDraft(
        schemaVersion: ReportDraft.currentSchemaVersion,
        draftId: draftId,
        ownerId: ownerId,
        type: item.type,
        createdAt: item.createdAt,
        updatedAt: _now().toUtc(),
        resumeStep: item.type == ReportDraftType.full ? 'review' : 'form',
        payload: payload,
        attachmentRefs: item.attachmentRefs,
      ),
    );
  }

  Future<int> _drain(String ownerId) {
    final running = _drainFuture;
    if (running != null) return running;
    final completer = Completer<int>();
    _drainFuture = completer.future;
    () async {
      var synchronized = 0;
      try {
        final items = await _store.readAll(ownerId);
        for (final item in items) {
          if (_disposed ||
              _activeOwnerId != ownerId ||
              !_canReachBackend() ||
              !await _isCurrentOwner(ownerId) ||
              !await _hasValidSession(ownerId)) {
            break;
          }
          if (item.status == ReportCreateOutboxStatus.synced) {
            await _finishAcknowledged(item);
            continue;
          }
          if (item.status == ReportCreateOutboxStatus.rejected) continue;
          if (!_canSubmit(item.payload)) {
            await _saveSystemPaused(item);
            continue;
          }
          if (item.status == ReportCreateOutboxStatus.paused) {
            final pending = item.copyWith(
              status: ReportCreateOutboxStatus.pending,
              updatedAt: _now().toUtc(),
              clearFailure: true,
            );
            await _store.write(pending);
            _notifyChanged(ownerId);
            final result = await _attempt(pending);
            if (result.status == ReportCreateOutboxStatus.synced) {
              synchronized++;
            }
            continue;
          }
          if (item.status != ReportCreateOutboxStatus.pending &&
              item.status != ReportCreateOutboxStatus.retryWaiting) {
            continue;
          }
          if (item.status == ReportCreateOutboxStatus.retryWaiting &&
              item.attemptCount >= maxAttempts) {
            continue;
          }
          if (item.nextAttemptAt != null &&
              item.nextAttemptAt!.isAfter(_now())) {
            continue;
          }
          final result = await _attempt(item);
          if (result.status == ReportCreateOutboxStatus.synced) synchronized++;
        }
      } catch (_) {
        // Keep durable records unchanged; a later auth or reachability event retries.
      } finally {
        _drainFuture = null;
        _scheduleRetry(ownerId);
        completer.complete(synchronized);
      }
    }();
    return completer.future;
  }

  Future<ReportCreateOutboxItem> _attempt(ReportCreateOutboxItem item) {
    final active = _attempts[item.localReportId];
    if (active != null) return active;
    final token = CancelToken();
    _cancelTokens[item.localReportId] = token;
    final future = _send(item, token);
    _attempts[item.localReportId] = future;
    return future.whenComplete(() {
      if (identical(_cancelTokens[item.localReportId], token)) {
        _cancelTokens.remove(item.localReportId);
      }
      _attempts.remove(item.localReportId);
      _scheduleRetry(item.ownerId);
    });
  }

  Future<ReportCreateOutboxItem> _send(
    ReportCreateOutboxItem item,
    CancelToken token,
  ) async {
    if (_disposed ||
        !_canReachBackend() ||
        !await _isCurrentOwner(item.ownerId) ||
        !await _hasValidSession(item.ownerId)) {
      return item;
    }
    if (!_canSubmit(item.payload)) return _saveSystemPaused(item);
    // A drain may hold a snapshot discarded while it awaited ownership checks.
    final current = await _store.read(item.ownerId, item.localReportId);
    if (current == null ||
        current.status == ReportCreateOutboxStatus.rejected ||
        current.status == ReportCreateOutboxStatus.synced) {
      return current ?? item;
    }
    final started = item.copyWith(
      status: ReportCreateOutboxStatus.pending,
      updatedAt: _now().toUtc(),
      attemptCount: item.attemptCount + 1,
      clearNextAttemptAt: true,
      clearFailure: true,
    );
    await _store.write(started);
    _notifyChanged(item.ownerId);

    Result<Report> result;
    try {
      result = await _submit(
        payload: item.payload,
        idempotencyKey: item.idempotencyKey,
        cancelToken: token,
      );
    } catch (error, stack) {
      result = Err(ErrorMapper.mapException(error, stack));
    }
    if (token.isCancelled && !_isActiveOwner(item.ownerId)) {
      return (await _store.read(item.ownerId, item.localReportId)) ?? started;
    }

    return result.when(
      success: (report) async {
        if (report.id.trim().isEmpty) {
          return _saveFailure(
            started,
            const NetworkFailure('Report acknowledgement was incomplete.'),
          );
        }
        final mapped = started.copyWith(
          status: ReportCreateOutboxStatus.synced,
          updatedAt: _now().toUtc(),
          serverReportId: report.id,
          clearNextAttemptAt: true,
          clearFailure: true,
        );
        await _store.write(mapped);
        _notifyChanged(item.ownerId);
        if (_isActiveOwner(item.ownerId) &&
            await _isCurrentOwner(item.ownerId) &&
            await _hasValidSession(item.ownerId)) {
          await _finishAcknowledged(mapped);
        }
        final remaining = await _store.read(item.ownerId, item.localReportId);
        if (remaining != null) return remaining;
        if (await _store.readServerReportId(item.ownerId, item.localReportId) ==
            report.id) {
          return mapped.copyWith(
            attachmentRefs: const [],
            evidenceHandedOff: true,
          );
        }
        return mapped;
      },
      failure: (failure) => _saveFailure(started, failure),
    );
  }

  Future<ReportCreateOutboxItem> _saveFailure(
    ReportCreateOutboxItem item,
    Failure failure,
  ) async {
    if (!_isActiveOwner(item.ownerId) && !await _isCurrentOwner(item.ownerId)) {
      return (await _store.read(item.ownerId, item.localReportId)) ?? item;
    }
    final classified = _classifyFailure(failure, item.attemptCount);
    final updated = item.copyWith(
      status: classified.status,
      updatedAt: _now().toUtc(),
      nextAttemptAt: classified.nextAttemptAt,
      clearNextAttemptAt: classified.nextAttemptAt == null,
      safeError: classified.message,
      errorKind: classified.kind,
      fieldErrors: classified.fieldErrors,
      clearFailure: classified.fieldErrors == null,
    );
    await _store.write(updated);
    _notifyChanged(item.ownerId);
    return updated;
  }

  _ClassifiedFailure _classifyFailure(Failure failure, int attempts) {
    if (failure is SystemRestrictionFailure) {
      return _ClassifiedFailure(
        ReportCreateOutboxStatus.paused,
        ReportCreateOutboxErrorKind.systemRestriction,
        _safeText(failure.message),
      );
    }
    if (failure is AuthFailure) {
      return const _ClassifiedFailure(
        ReportCreateOutboxStatus.paused,
        ReportCreateOutboxErrorKind.authentication,
        'Sign in with the original account to send this report.',
      );
    }
    if (failure is ValidationFailure) {
      return _ClassifiedFailure(
        ReportCreateOutboxStatus.rejected,
        ReportCreateOutboxErrorKind.validation,
        _safeText(ErrorMapper.userMessage(failure)),
        failure.fieldErrors,
      );
    }
    if (failure is UnknownFailure && failure.statusCode == 409) {
      return const _ClassifiedFailure(
        ReportCreateOutboxStatus.rejected,
        ReportCreateOutboxErrorKind.conflict,
        'Submission could not be confirmed. Edit report before resubmitting.',
      );
    }
    final retryable =
        failure is NetworkFailure ||
        failure is ServerFailure ||
        failure is UnknownFailure &&
            (failure.statusCode == null ||
                failure.statusCode == 408 ||
                failure.statusCode == 429);
    if (retryable) {
      final exhausted = attempts >= maxAttempts;
      final next = exhausted ? null : _now().toUtc().add(_backoff(attempts));
      return _ClassifiedFailure(
        ReportCreateOutboxStatus.retryWaiting,
        failure is NetworkFailure
            ? ReportCreateOutboxErrorKind.network
            : ReportCreateOutboxErrorKind.server,
        failure is NetworkFailure
            ? 'Will retry when connection returns.'
            : 'BayanTrack could not accept report yet. Retry is safe.',
        null,
        next,
      );
    }
    if (failure is UnknownFailure &&
        failure.statusCode != null &&
        failure.statusCode! >= 400 &&
        failure.statusCode! < 500) {
      return _ClassifiedFailure(
        ReportCreateOutboxStatus.rejected,
        ReportCreateOutboxErrorKind.unavailable,
        'Report was not accepted. Review it and try again.',
      );
    }
    return const _ClassifiedFailure(
      ReportCreateOutboxStatus.rejected,
      ReportCreateOutboxErrorKind.unavailable,
      'Report was not accepted. Review it and try again.',
    );
  }

  Future<ReportCreateOutboxItem> _savePaused(
    ReportCreateOutboxItem item,
  ) async {
    final paused = item.copyWith(
      status: ReportCreateOutboxStatus.paused,
      updatedAt: _now().toUtc(),
      safeError: 'Waiting for the original account session.',
      errorKind: ReportCreateOutboxErrorKind.authentication,
      clearNextAttemptAt: true,
    );
    await _store.write(paused);
    _notifyChanged(item.ownerId);
    return paused;
  }

  Future<ReportCreateOutboxItem> _saveSystemPaused(
    ReportCreateOutboxItem item,
  ) async {
    final paused = item.copyWith(
      status: ReportCreateOutboxStatus.paused,
      updatedAt: _now().toUtc(),
      safeError: 'Waiting for current terms acceptance or maintenance to end.',
      errorKind: ReportCreateOutboxErrorKind.systemRestriction,
      clearNextAttemptAt: true,
    );
    await _store.write(paused);
    _notifyChanged(item.ownerId);
    return paused;
  }

  Future<void> _finishAcknowledged(ReportCreateOutboxItem item) {
    final active = _handoffs[item.localReportId];
    if (active != null) return active;
    final future = _finishAcknowledgedOnce(item);
    _handoffs[item.localReportId] = future;
    return future.whenComplete(() => _handoffs.remove(item.localReportId));
  }

  Future<void> _finishAcknowledgedOnce(ReportCreateOutboxItem item) async {
    final serverReportId = item.serverReportId;
    if (serverReportId == null) return;
    try {
      await _store.writeServerReportMapping(
        item.ownerId,
        item.localReportId,
        serverReportId,
      );
      await _deleteSourceDraftIfUnchanged(item);
      var current = await _store.read(item.ownerId, item.localReportId);
      if (current == null) return;
      if (!current.evidenceHandedOff) {
        if (current.attachmentRefs.isNotEmpty) {
          if (!_isActiveOwner(item.ownerId) ||
              !await _isCurrentOwner(item.ownerId) ||
              !await _hasValidSession(item.ownerId)) {
            return;
          }
          if (!await _handoffAttachments(current) ||
              !_isActiveOwner(item.ownerId) ||
              !await _isCurrentOwner(item.ownerId) ||
              !await _hasValidSession(item.ownerId)) {
            return;
          }
          current = await _store.read(item.ownerId, item.localReportId);
          if (current == null) return;
        }
        await _markAttachmentsHandedOff(current);
      }
      await _store.removeAfterEvidenceHandoff(item.ownerId, item.localReportId);
      _notifyChanged(item.ownerId);
    } catch (_) {
      // Durable state lets a later authenticated resume finish the handoff.
    }
  }

  Future<void> _markAttachmentsHandedOff(ReportCreateOutboxItem item) async {
    final updated = item.copyWith(
      status: ReportCreateOutboxStatus.synced,
      updatedAt: _now().toUtc(),
      attachmentRefs: const [],
      evidenceHandedOff: true,
      clearNextAttemptAt: true,
    );
    await _store.write(updated);
    _notifyChanged(item.ownerId);
  }

  Future<void> _deleteSourceDraftIfUnchanged(
    ReportCreateOutboxItem item,
  ) async {
    final draftId = item.sourceDraftId;
    final draftUpdatedAt = item.sourceDraftUpdatedAt;
    if (draftId == null || draftUpdatedAt == null) return;
    final draft = await _drafts.read(item.ownerId, item.type);
    if (draft?.draftId == draftId && draft?.updatedAt == draftUpdatedAt) {
      await _drafts.delete(item.ownerId, item.type);
    }
  }

  void _scheduleRetry(String ownerId) {
    _retryTimer?.cancel();
    _retryTimer = null;
    if (_disposed ||
        _activeOwnerId != ownerId ||
        !_canReachBackend() ||
        _drainFuture != null) {
      return;
    }
    unawaited(() async {
      try {
        final items = await _store.readAll(ownerId);
        if (_activeOwnerId != ownerId || !_canReachBackend()) return;
        final next = items
            .where(
              (item) =>
                  item.status == ReportCreateOutboxStatus.retryWaiting &&
                  _canSubmit(item.payload) &&
                  item.nextAttemptAt != null,
            )
            .map((item) => item.nextAttemptAt!)
            .fold<DateTime?>(
              null,
              (earliest, value) => earliest == null || value.isBefore(earliest)
                  ? value
                  : earliest,
            );
        if (next == null) return;
        final delay = next.isAfter(_now())
            ? next.difference(_now())
            : Duration.zero;
        _retryTimer = Timer(delay, () => unawaited(_drain(ownerId)));
      } catch (_) {
        // A later connectivity or auth event will retry the durable work.
      }
    }());
  }

  Duration _backoff(int attempt) {
    final exponent = (attempt - 1).clamp(0, 5);
    return Duration(seconds: min(2 << exponent, 60));
  }

  bool _isActiveOwner(String ownerId) =>
      !_disposed && _activeOwnerId == ownerId;

  bool _sameStrings(List<String> a, List<String> b) => listEquals(a, b);

  String _safeText(String value) {
    final normalized = value
        .replaceAll(RegExp(r'[\u0000-\u001f\u007f]'), ' ')
        .trim();
    return normalized.length <= 300 ? normalized : normalized.substring(0, 300);
  }

  void _notifyChanged(String ownerId) {
    if (!_disposed) _changed(ownerId);
  }

  void dispose() {
    _disposed = true;
    _retryTimer?.cancel();
    _retryTimer = null;
    for (final token in _cancelTokens.values) {
      token.cancel('Report synchronization disposed');
    }
  }
}

class _ClassifiedFailure {
  const _ClassifiedFailure(
    this.status,
    this.kind,
    this.message, [
    this.fieldErrors,
    this.nextAttemptAt,
  ]);

  final ReportCreateOutboxStatus status;
  final ReportCreateOutboxErrorKind kind;
  final String message;
  final Map<String, String>? fieldErrors;
  final DateTime? nextAttemptAt;
}

Map<String, Object?> _freezeMap(Map<String, Object?> source) =>
    Map.unmodifiable({
      for (final entry in source.entries) entry.key: _freezeValue(entry.value),
    });

Object? _freezeValue(Object? value) {
  if (value is Map) {
    return Map.unmodifiable({
      for (final entry in value.entries)
        entry.key.toString(): _freezeValue(entry.value),
    });
  }
  if (value is List) return List.unmodifiable(value.map(_freezeValue));
  return value;
}

String _canonicalJson(Object? value) {
  if (value is Map) {
    final keys = value.keys.map((key) => key.toString()).toList()..sort();
    return '{${keys.map((key) => '${jsonEncode(key)}:${_canonicalJson(value[key])}').join(',')}}';
  }
  if (value is List) return '[${value.map(_canonicalJson).join(',')}]';
  return jsonEncode(value);
}

final reportCreateOutboxStoreProvider = Provider<ReportCreateOutboxStore>((
  ref,
) {
  return ReportCreateOutboxStore(ref.watch(secureStorageProvider));
});

final reportCreateOutboxItemsProvider =
    FutureProvider.family<List<ReportCreateOutboxItem>, String>((ref, ownerId) {
      return ref.watch(reportCreateOutboxStoreProvider).readAll(ownerId);
    });
