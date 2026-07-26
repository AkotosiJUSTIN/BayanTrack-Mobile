import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum EvidenceUploadState {
  pending,
  uploading,
  retryWaiting,
  completed,
  failed,
  missingLocalFile,
  dismissed,
}

enum EvidenceUploadError {
  authenticationRequired,
  uploadUnavailable,
  requestRejected,
  retryLimitReached,
  missingLocalFile,
}

@immutable
class EvidenceUploadIntent {
  const EvidenceUploadIntent({
    required this.id,
    required this.ownerUserId,
    required this.reportId,
    required this.localFilePath,
    required this.isPrimary,
    required this.state,
    this.retryCount = 0,
    this.nextRetryAt,
    this.error,
  });

  final String id;
  final String ownerUserId;
  final String reportId;
  final String localFilePath;
  final bool isPrimary;
  final EvidenceUploadState state;
  final int retryCount;
  final DateTime? nextRetryAt;
  final EvidenceUploadError? error;

  EvidenceUploadIntent copyWith({
    EvidenceUploadState? state,
    int? retryCount,
    DateTime? nextRetryAt,
    bool clearNextRetryAt = false,
    EvidenceUploadError? error,
    bool clearError = false,
  }) {
    return EvidenceUploadIntent(
      id: id,
      ownerUserId: ownerUserId,
      reportId: reportId,
      localFilePath: localFilePath,
      isPrimary: isPrimary,
      state: state ?? this.state,
      retryCount: retryCount ?? this.retryCount,
      nextRetryAt: clearNextRetryAt ? null : (nextRetryAt ?? this.nextRetryAt),
      error: clearError ? null : (error ?? this.error),
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'owner_user_id': ownerUserId,
    'report_id': reportId,
    'local_file_path': localFilePath,
    'is_primary': isPrimary,
    'state': state.name,
    'retry_count': retryCount,
    'next_retry_at': nextRetryAt?.toUtc().toIso8601String(),
    'error': error?.name,
  };

  static EvidenceUploadIntent? fromJson(Object? value) {
    if (value is! Map) return null;
    final json = Map<String, dynamic>.from(value);
    final id = json['id'];
    final ownerUserId = json['owner_user_id'];
    final reportId = json['report_id'];
    final localFilePath = json['local_file_path'];
    if (id is! String ||
        ownerUserId is! String ||
        reportId is! String ||
        localFilePath is! String ||
        id.isEmpty ||
        ownerUserId.isEmpty ||
        reportId.isEmpty ||
        localFilePath.isEmpty) {
      return null;
    }

    EvidenceUploadState? storedState;
    for (final item in EvidenceUploadState.values) {
      if (item.name == json['state']) storedState = item;
    }
    EvidenceUploadError? storedError;
    for (final item in EvidenceUploadError.values) {
      if (item.name == json['error']) storedError = item;
    }
    return EvidenceUploadIntent(
      id: id,
      ownerUserId: ownerUserId,
      reportId: reportId,
      localFilePath: localFilePath,
      isPrimary: json['is_primary'] == true,
      state: storedState ?? EvidenceUploadState.pending,
      retryCount: (json['retry_count'] as num?)?.toInt() ?? 0,
      nextRetryAt: DateTime.tryParse(json['next_retry_at']?.toString() ?? ''),
      error: storedError,
    );
  }
}

typedef EvidenceUploader =
    Future<void> Function({
      required File file,
      required String reportId,
      required String evidenceKey,
      required bool isPrimary,
      required CancelToken cancelToken,
    });

typedef EvidenceAuthenticationCheck = Future<bool> Function(String userId);

class EvidenceUploadQueue extends ChangeNotifier {
  EvidenceUploadQueue({
    required SharedPreferences preferences,
    required Directory uploadDirectory,
    required EvidenceUploader upload,
    required EvidenceAuthenticationCheck isAuthenticated,
    DateTime Function()? now,
    this.maxRetryCount = 5,
    this.baseBackoff = const Duration(seconds: 2),
    this.maxBackoff = const Duration(minutes: 5),
    this.autoSchedule = true,
  }) : _preferences = preferences,
       _uploadDirectory = uploadDirectory,
       _upload = upload,
       _isAuthenticated = isAuthenticated,
       _now = now ?? DateTime.now;

  static const _storageKey = 'pending_evidence_uploads_v1';

  final SharedPreferences _preferences;
  final Directory _uploadDirectory;
  final EvidenceUploader _upload;
  final EvidenceAuthenticationCheck _isAuthenticated;
  final DateTime Function() _now;
  final int maxRetryCount;
  final Duration baseBackoff;
  final Duration maxBackoff;
  final bool autoSchedule;

  final List<EvidenceUploadIntent> _intents = [];
  bool _initialized = false;
  bool _disposed = false;
  String? _activeUserId;
  String? _uploadingIntentId;
  CancelToken? _cancelToken;
  Timer? _retryTimer;
  Future<void>? _drainFuture;

  List<EvidenceUploadIntent> get state => List.unmodifiable(
    _activeUserId == null
        ? const <EvidenceUploadIntent>[]
        : _intents.where((item) => item.ownerUserId == _activeUserId),
  );

  @visibleForTesting
  List<EvidenceUploadIntent> get allState => List.unmodifiable(_intents);

  static Future<EvidenceUploadQueue> open({
    required EvidenceUploader upload,
    required EvidenceAuthenticationCheck isAuthenticated,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final supportDirectory = await getApplicationSupportDirectory();
    final queue = EvidenceUploadQueue(
      preferences: preferences,
      uploadDirectory: Directory(
        '${supportDirectory.path}${Platform.pathSeparator}pending_evidence',
      ),
      upload: upload,
      isAuthenticated: isAuthenticated,
    );
    await queue.initialize();
    return queue;
  }

  Future<void> initialize() async {
    if (_initialized || _disposed) return;
    await _preferences.reload();
    final stored = _preferences.getString(_storageKey);
    if (stored != null) {
      try {
        final decoded = jsonDecode(stored);
        if (decoded is List) {
          for (final value in decoded) {
            final intent = EvidenceUploadIntent.fromJson(value);
            if (intent == null) continue;
            _intents.add(
              intent.state == EvidenceUploadState.uploading
                  ? intent.copyWith(
                      state: EvidenceUploadState.pending,
                      clearNextRetryAt: true,
                    )
                  : intent,
            );
          }
        }
      } on FormatException {
        // Corrupt queue metadata is ignored. No file path or payload is logged.
      }
    }
    _initialized = true;
    await _persist();
    await _cleanupTerminalFiles();
    _notify();
  }

  Future<List<EvidenceUploadIntent>> enqueue({
    required String userId,
    required String reportId,
    required List<File> files,
  }) async {
    await initialize();
    if (_disposed || userId.isEmpty || reportId.isEmpty || files.isEmpty) {
      return const [];
    }
    if (_activeUserId == null && await _isAuthenticated(userId)) {
      _activeUserId = userId;
    }
    await _uploadDirectory.create(recursive: true);
    final added = <EvidenceUploadIntent>[];

    for (var index = 0; index < files.length; index++) {
      final source = files[index];
      final id = _newEvidenceKey();
      final target = File(
        '${_uploadDirectory.path}${Platform.pathSeparator}$id${_safeExtension(source)}',
      );
      var uploadState = EvidenceUploadState.pending;
      EvidenceUploadError? error;
      try {
        if (!await source.exists()) {
          uploadState = EvidenceUploadState.missingLocalFile;
          error = EvidenceUploadError.missingLocalFile;
        } else {
          await source.copy(target.path);
        }
      } on FileSystemException {
        uploadState = EvidenceUploadState.missingLocalFile;
        error = EvidenceUploadError.missingLocalFile;
      }

      final intent = EvidenceUploadIntent(
        id: id,
        ownerUserId: userId,
        reportId: reportId,
        localFilePath: target.path,
        isPrimary: index == 0,
        state: uploadState,
        error: error,
      );
      _intents.add(intent);
      added.add(intent);
      await _persist();
      _notify();
    }
    return List.unmodifiable(added);
  }

  Future<void> resume(String userId) async {
    await initialize();
    if (_disposed || userId.isEmpty) return;
    if (_activeUserId != null && _activeUserId != userId) {
      await pause();
    }
    if (!await _isAuthenticated(userId)) return;
    _activeUserId = userId;
    await _drain();
  }

  Future<void> pause() async {
    _retryTimer?.cancel();
    _retryTimer = null;
    final uploadingId = _uploadingIntentId;
    _activeUserId = null;
    _cancelToken?.cancel('Evidence upload paused');
    _cancelToken = null;
    _uploadingIntentId = null;
    if (uploadingId != null) {
      final index = _indexOf(uploadingId);
      if (index >= 0 &&
          _intents[index].state == EvidenceUploadState.uploading) {
        _intents[index] = _intents[index].copyWith(
          state: EvidenceUploadState.pending,
          clearNextRetryAt: true,
        );
        await _persist();
        _notify();
      }
    }
  }

  Future<void> retry([String? id]) async {
    await initialize();
    final userId = _activeUserId;
    if (_disposed || userId == null) return;
    var changed = false;
    for (var index = 0; index < _intents.length; index++) {
      final item = _intents[index];
      if (item.ownerUserId != userId ||
          (id != null && item.id != id) ||
          (item.state != EvidenceUploadState.failed &&
              item.state != EvidenceUploadState.missingLocalFile &&
              item.state != EvidenceUploadState.retryWaiting)) {
        continue;
      }
      _intents[index] = item.copyWith(
        state: EvidenceUploadState.pending,
        retryCount: 0,
        clearNextRetryAt: true,
        clearError: true,
      );
      changed = true;
    }
    if (!changed) return;
    await _persist();
    _notify();
    await _drain();
  }

  Future<void> dismiss(String id) async {
    await initialize();
    final index = _indexOf(id);
    if (index < 0) return;
    final item = _intents[index];
    if (_activeUserId == null || item.ownerUserId != _activeUserId) return;
    if (_uploadingIntentId == id) {
      _cancelToken?.cancel('Evidence upload dismissed');
      _cancelToken = null;
      _uploadingIntentId = null;
    }
    _intents[index] = item.copyWith(
      state: EvidenceUploadState.dismissed,
      clearNextRetryAt: true,
      clearError: true,
    );
    await _persist();
    await _deleteOwnedFile(item.localFilePath);
    _notify();
  }

  Future<void> dismissTerminal() async {
    await initialize();
    final userId = _activeUserId;
    if (userId == null) return;
    final terminal = _intents
        .where(
          (item) =>
              item.ownerUserId == userId &&
              (item.state == EvidenceUploadState.completed ||
                  item.state == EvidenceUploadState.failed ||
                  item.state == EvidenceUploadState.missingLocalFile),
        )
        .map((item) => item.id)
        .toList();
    for (final id in terminal) {
      await dismiss(id);
    }
  }

  Future<void> _drain() {
    if (_drainFuture != null) return _drainFuture!;
    final completer = Completer<void>();
    _drainFuture = completer.future;
    () async {
      try {
        while (!_disposed) {
          final userId = _activeUserId;
          if (userId == null || !await _isAuthenticated(userId)) break;
          final index = await _nextReadyIndex(userId);
          if (index < 0) break;
          await _attempt(_intents[index]);
        }
      } finally {
        _drainFuture = null;
        if (!_disposed) _scheduleNext();
        completer.complete();
      }
    }();
    return completer.future;
  }

  Future<int> _nextReadyIndex(String userId) async {
    final now = _now();
    for (var index = 0; index < _intents.length; index++) {
      final item = _intents[index];
      if (item.ownerUserId != userId ||
          item.state == EvidenceUploadState.completed ||
          item.state == EvidenceUploadState.failed ||
          item.state == EvidenceUploadState.missingLocalFile ||
          item.state == EvidenceUploadState.dismissed) {
        continue;
      }
      if (!await File(item.localFilePath).exists()) {
        _intents[index] = item.copyWith(
          state: EvidenceUploadState.missingLocalFile,
          clearNextRetryAt: true,
          error: EvidenceUploadError.missingLocalFile,
        );
        await _persist();
        _notify();
        continue;
      }
      if (item.state == EvidenceUploadState.retryWaiting &&
          item.nextRetryAt != null &&
          item.nextRetryAt!.isAfter(now)) {
        continue;
      }
      return index;
    }
    return -1;
  }

  Future<void> _attempt(EvidenceUploadIntent intent) async {
    final index = _indexOf(intent.id);
    if (index < 0) return;
    final token = CancelToken();
    _cancelToken = token;
    _uploadingIntentId = intent.id;
    _intents[index] = intent.copyWith(
      state: EvidenceUploadState.uploading,
      clearNextRetryAt: true,
      clearError: true,
    );
    await _persist();
    _notify();

    try {
      await _upload(
        file: File(intent.localFilePath),
        reportId: intent.reportId,
        evidenceKey: intent.id,
        isPrimary: intent.isPrimary,
        cancelToken: token,
      );
      if (_disposed ||
          _activeUserId != intent.ownerUserId ||
          token.isCancelled) {
        return;
      }
      final completedIndex = _indexOf(intent.id);
      if (completedIndex < 0) return;
      _intents[completedIndex] = _intents[completedIndex].copyWith(
        state: EvidenceUploadState.completed,
        clearNextRetryAt: true,
        clearError: true,
      );
      await _persist();
      await _deleteOwnedFile(intent.localFilePath);
      _notify();
    } catch (error) {
      if (_disposed ||
          _activeUserId != intent.ownerUserId ||
          token.isCancelled) {
        return;
      }
      final failedIndex = _indexOf(intent.id);
      if (failedIndex < 0) return;
      final current = _intents[failedIndex];
      final statusCode = error is DioException
          ? error.response?.statusCode
          : null;
      if (statusCode == 401) {
        _activeUserId = null;
        _intents[failedIndex] = current.copyWith(
          state: EvidenceUploadState.pending,
          clearNextRetryAt: true,
          error: EvidenceUploadError.authenticationRequired,
        );
      } else if (statusCode != null && statusCode >= 400 && statusCode < 500) {
        _intents[failedIndex] = current.copyWith(
          state: EvidenceUploadState.failed,
          clearNextRetryAt: true,
          error: EvidenceUploadError.requestRejected,
        );
      } else {
        final retryCount = current.retryCount + 1;
        if (retryCount >= maxRetryCount) {
          _intents[failedIndex] = current.copyWith(
            state: EvidenceUploadState.failed,
            retryCount: retryCount,
            clearNextRetryAt: true,
            error: EvidenceUploadError.retryLimitReached,
          );
        } else {
          _intents[failedIndex] = current.copyWith(
            state: EvidenceUploadState.retryWaiting,
            retryCount: retryCount,
            nextRetryAt: _now().add(_backoff(retryCount)),
            error: EvidenceUploadError.uploadUnavailable,
          );
        }
      }
      await _persist();
      _notify();
    } finally {
      if (identical(_cancelToken, token)) _cancelToken = null;
      if (_uploadingIntentId == intent.id) _uploadingIntentId = null;
    }
  }

  Duration _backoff(int retryCount) {
    final exponent = (retryCount - 1).clamp(0, 20);
    final multiplier = 1 << exponent;
    final milliseconds = baseBackoff.inMilliseconds * multiplier;
    return Duration(milliseconds: min(milliseconds, maxBackoff.inMilliseconds));
  }

  void _scheduleNext() {
    _retryTimer?.cancel();
    _retryTimer = null;
    if (!autoSchedule || _activeUserId == null) return;
    final now = _now();
    final next = _intents
        .where(
          (item) =>
              item.ownerUserId == _activeUserId &&
              item.state == EvidenceUploadState.retryWaiting &&
              item.nextRetryAt != null,
        )
        .map((item) => item.nextRetryAt!)
        .fold<DateTime?>(
          null,
          (earliest, value) =>
              earliest == null || value.isBefore(earliest) ? value : earliest,
        );
    if (next == null) return;
    final delay = next.isAfter(now) ? next.difference(now) : Duration.zero;
    _retryTimer = Timer(delay, () {
      final userId = _activeUserId;
      if (userId != null) unawaited(resume(userId));
    });
  }

  Future<void> _persist() async {
    if (!_initialized || _disposed) return;
    await _preferences.setString(
      _storageKey,
      jsonEncode(_intents.map((item) => item.toJson()).toList()),
    );
  }

  Future<void> _cleanupTerminalFiles() async {
    for (final item in _intents) {
      if (item.state == EvidenceUploadState.completed ||
          item.state == EvidenceUploadState.dismissed) {
        await _deleteOwnedFile(item.localFilePath);
      }
    }
  }

  Future<void> _deleteOwnedFile(String path) async {
    final ownedRoot = _uploadDirectory.absolute.path;
    final file = File(path).absolute;
    if (!file.path.startsWith('$ownedRoot${Platform.pathSeparator}')) return;
    try {
      if (await file.exists()) await file.delete();
    } on FileSystemException {
      // A later restore retries terminal-file cleanup.
    }
  }

  int _indexOf(String id) => _intents.indexWhere((item) => item.id == id);

  String _newEvidenceKey() {
    final random = Random.secure().nextInt(0x7fffffff).toRadixString(36);
    return 'evi_${_now().microsecondsSinceEpoch}_$random';
  }

  String _safeExtension(File source) {
    final segments = source.uri.pathSegments;
    final name = segments.isEmpty ? '' : segments.last;
    final separator = name.lastIndexOf('.');
    if (separator < 0) return '.jpg';
    final extension = name.substring(separator).toLowerCase();
    return RegExp(r'^\.[a-z0-9]{1,5}$').hasMatch(extension)
        ? extension
        : '.jpg';
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _retryTimer?.cancel();
    _cancelToken?.cancel('Evidence upload queue disposed');
    super.dispose();
  }
}
