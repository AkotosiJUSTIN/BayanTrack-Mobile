import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

var _draftSequence = 0;
const _draftDirectoryName = 'report_evidence_drafts';
const _draftMarkerName = '.bayantrack_evidence_drafts';

Future<File> stageEvidenceFile(
  XFile source, {
  Directory? stagingDirectory,
}) async {
  final sourceSize = await source.length();
  if (sourceSize == 0) {
    throw const FileSystemException('Evidence draft is empty');
  }

  final root = stagingDirectory ?? await getApplicationSupportDirectory();
  final directory = Directory(
    '${root.path}${Platform.pathSeparator}$_draftDirectoryName',
  );
  await directory.create(recursive: true);
  final marker = File(
    '${directory.path}${Platform.pathSeparator}$_draftMarkerName',
  );
  if (!await marker.exists()) await marker.create();

  final extension = _safeExtension(source.name);
  final target = File(
    '${directory.path}${Platform.pathSeparator}draft_${DateTime.now().microsecondsSinceEpoch}_${_draftSequence++}$extension',
  );
  final partial = File('${target.path}.part');
  try {
    await source.saveTo(partial.path);
    if (await partial.length() != sourceSize) {
      throw const FileSystemException('Evidence draft verification failed');
    }
    return await partial.rename(target.path);
  } on FileSystemException {
    if (await partial.exists()) await partial.delete();
    if (await target.exists()) await target.delete();
    rethrow;
  }
}

Future<void> discardEvidenceDraft(File file) async {
  if (!await isEvidenceDraft(file)) return;

  try {
    if (await file.exists()) await file.delete();
  } on FileSystemException {
    // A stale draft can be cleaned up during a later report flow.
  }
}

Future<bool> isEvidenceDraft(File file) async {
  final parentSegments = file.parent.uri.pathSegments
      .where((segment) => segment.isNotEmpty)
      .toList();
  if (parentSegments.isEmpty ||
      parentSegments.last != _draftDirectoryName ||
      !file.uri.pathSegments.last.startsWith('draft_')) {
    return false;
  }
  final marker = File(
    '${file.parent.path}${Platform.pathSeparator}$_draftMarkerName',
  );
  return marker.exists();
}

Future<File?> resolveEvidenceDraftReference(
  String path, {
  Directory? stagingDirectory,
  bool allowMissing = false,
}) async {
  final root = stagingDirectory ?? await getApplicationSupportDirectory();
  final expectedDirectory = Directory(
    '${root.path}${Platform.pathSeparator}$_draftDirectoryName',
  ).absolute;
  final candidate = File(path).absolute;
  final segments = candidate.uri.pathSegments;
  final name = segments.isEmpty ? null : segments.last;
  if (name == null ||
      !RegExp(r'^draft_[A-Za-z0-9_-]+\.[A-Za-z0-9]{1,5}$').hasMatch(name) ||
      candidate.parent.path != expectedDirectory.path) {
    return null;
  }

  try {
    if (!await File(
      '${expectedDirectory.path}${Platform.pathSeparator}$_draftMarkerName',
    ).exists()) {
      return null;
    }
    final canonicalRoot = await root.resolveSymbolicLinks();
    final expectedPath = await expectedDirectory.resolveSymbolicLinks();
    final canonicalExpectedPath = Directory(
      '$canonicalRoot${Platform.pathSeparator}$_draftDirectoryName',
    ).absolute.path;
    final canonicalParent = await candidate.parent.resolveSymbolicLinks();
    if (expectedPath != canonicalExpectedPath ||
        canonicalParent != expectedPath) {
      return null;
    }
    if (!await candidate.exists()) return allowMissing ? candidate : null;
    final canonicalPath = await candidate.resolveSymbolicLinks();
    final resolved = File(canonicalPath);
    if (resolved.parent.path != expectedPath || await resolved.length() == 0) {
      return null;
    }
    return resolved;
  } on FileSystemException {
    return null;
  }
}

Future<void> discardEvidenceDrafts(Iterable<File> files) async {
  for (final file in files) {
    await discardEvidenceDraft(file);
  }
}

Future<void> cleanupStaleEvidenceDrafts({
  Directory? stagingDirectory,
  Iterable<String> retainedPaths = const [],
  Duration maxAge = const Duration(days: 7),
  DateTime Function()? now,
}) async {
  final root = stagingDirectory ?? await getApplicationSupportDirectory();
  final directory = Directory(
    '${root.path}${Platform.pathSeparator}$_draftDirectoryName',
  );
  if (!await directory.exists()) return;

  final retained = retainedPaths
      .map((path) => File(path).absolute.path)
      .toSet();
  final cutoff = (now ?? DateTime.now)().subtract(maxAge);
  await for (final entity in directory.list()) {
    if (entity is! File || retained.contains(entity.absolute.path)) continue;
    final name = entity.uri.pathSegments.last;
    if (!name.startsWith('draft_')) continue;
    try {
      if ((await entity.lastModified()).isBefore(cutoff)) await entity.delete();
    } on FileSystemException {
      // Cleanup is best-effort and will run again during a later flow.
    }
  }
}

String _safeExtension(String name) {
  final separator = name.lastIndexOf('.');
  if (separator < 0) return '.jpg';
  final extension = name.substring(separator).toLowerCase();
  return RegExp(r'^\.[a-z0-9]{1,5}$').hasMatch(extension) ? extension : '.jpg';
}
