import 'dart:io';

import 'package:bayantrack_mobile/features/images/data/evidence_file_stager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  late Directory root;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('evidence_stager_test_');
  });

  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  test('copies picker bytes into app-owned draft storage', () async {
    final source = File('${root.path}${Platform.pathSeparator}picked.png');
    final bytes = List<int>.generate(8, (index) => index);
    await source.writeAsBytes(bytes);

    final staged = await stageEvidenceFile(
      XFile(source.path),
      stagingDirectory: root,
    );

    expect(staged.path, isNot(source.path));
    expect(staged.parent.path, endsWith('report_evidence_drafts'));
    expect(staged.path, endsWith('.png'));
    expect(await staged.readAsBytes(), bytes);
  });

  test('deletes only files owned by evidence draft storage', () async {
    final source = File('${root.path}${Platform.pathSeparator}picked.jpg');
    await source.writeAsBytes(List<int>.filled(16, 1));
    final staged = await stageEvidenceFile(
      XFile(source.path),
      stagingDirectory: root,
    );

    await discardEvidenceDraft(staged);
    await discardEvidenceDraft(source);

    expect(await staged.exists(), isFalse);
    expect(await source.exists(), isTrue);
  });

  test(
    'rejects an empty picker file without leaving a partial draft',
    () async {
      final source = File('${root.path}${Platform.pathSeparator}empty.jpg');
      await source.create();

      await expectLater(
        stageEvidenceFile(XFile(source.path), stagingDirectory: root),
        throwsA(isA<FileSystemException>()),
      );

      final drafts = Directory(
        '${root.path}${Platform.pathSeparator}report_evidence_drafts',
      );
      expect(await drafts.list().toList(), isEmpty);
    },
  );
}
