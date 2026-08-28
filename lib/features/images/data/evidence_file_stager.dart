import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

var _draftSequence = 0;

Future<File> stageEvidenceFile(
  XFile source, {
  Directory? stagingDirectory,
}) async {
  final root = stagingDirectory ?? await getTemporaryDirectory();
  final directory = Directory(
    '${root.path}${Platform.pathSeparator}report_evidence_drafts',
  );
  await directory.create(recursive: true);

  final extension = _safeExtension(source.name);
  final target = File(
    '${directory.path}${Platform.pathSeparator}draft_${DateTime.now().microsecondsSinceEpoch}_${_draftSequence++}$extension',
  );
  await source.saveTo(target.path);
  return target;
}

String _safeExtension(String name) {
  final separator = name.lastIndexOf('.');
  if (separator < 0) return '.jpg';
  final extension = name.substring(separator).toLowerCase();
  return RegExp(r'^\.[a-z0-9]{1,5}$').hasMatch(extension) ? extension : '.jpg';
}
