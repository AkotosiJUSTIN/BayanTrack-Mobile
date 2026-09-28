import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'report_models.dart' as dto;

class ReportCacheStore {
  ReportCacheStore(this._storage);

  static const _keyPrefix = 'bayantrack_report_read_v1';

  final FlutterSecureStorage _storage;
  Future<void> _tail = Future<void>.value();

  Future<dto.PaginatedReports?> readReports({
    required String ownerId,
    required String scope,
    required Map<String, dynamic> query,
  }) => _serialize(() async {
    final value = await _read(_reportsKey(ownerId, scope, query));
    if (value == null) return null;
    try {
      return dto.PaginatedReports.fromJson(value);
    } catch (_) {
      return null;
    }
  });

  Future<void> writeReports({
    required String ownerId,
    required String scope,
    required Map<String, dynamic> query,
    required dto.PaginatedReports reports,
  }) => _serialize(
    () => _write(_reportsKey(ownerId, scope, query), reports.toJson()),
  );

  Future<dto.Report?> readReport({
    required String ownerId,
    required String reportId,
  }) => _serialize(() async {
    final value = await _read(_reportKey(ownerId, reportId));
    if (value == null) return null;
    try {
      return dto.Report.fromJson(value);
    } catch (_) {
      return null;
    }
  });

  Future<void> writeReport({
    required String ownerId,
    required String reportId,
    required dto.Report report,
  }) =>
      _serialize(() => _write(_reportKey(ownerId, reportId), report.toJson()));

  Future<void> deleteOwner(String ownerId) => _serialize(() async {
    if (ownerId.trim().isEmpty) return;
    final prefix = '$_keyPrefix.${_encode(ownerId)}.';
    final values = await _storage.readAll();
    final keys = values.keys.where((key) => key.startsWith(prefix)).toList();
    for (final key in keys) {
      await _storage.delete(key: key);
    }
  });

  Future<void> deleteOtherOwners(String ownerId) => _serialize(() async {
    if (ownerId.trim().isEmpty) return;
    final prefix = '$_keyPrefix.';
    final retainedPrefix = '$_keyPrefix.${_encode(ownerId)}.';
    final values = await _storage.readAll();
    final keys = values.keys
        .where(
          (key) => key.startsWith(prefix) && !key.startsWith(retainedPrefix),
        )
        .toList();
    for (final key in keys) {
      await _storage.delete(key: key);
    }
  });

  Future<Map<String, dynamic>?> _read(String key) async {
    try {
      final value = await _storage.read(key: key);
      if (value == null) return null;
      final decoded = jsonDecode(value);
      if (decoded is Map<String, dynamic>) return decoded;
      return Map<String, dynamic>.from(decoded as Map);
    } catch (_) {
      return null;
    }
  }

  Future<void> _write(String key, Map<String, dynamic> value) =>
      _storage.write(key: key, value: jsonEncode(value));

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

  String _reportsKey(String ownerId, String scope, Map<String, dynamic> query) {
    final sortedKeys = query.keys.toList()..sort();
    final canonicalQuery = jsonEncode({
      for (final key in sortedKeys) key: query[key],
    });
    return '$_keyPrefix.${_encode(ownerId)}.$scope.${_encode(canonicalQuery)}';
  }

  String _reportKey(String ownerId, String reportId) =>
      '$_keyPrefix.${_encode(ownerId)}.detail.${_encode(reportId)}';

  String _encode(String value) =>
      base64Url.encode(utf8.encode(value)).replaceAll('=', '');
}
