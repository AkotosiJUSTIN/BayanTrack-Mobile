import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:bayantrack_mobile/features/images/data/evidence_file_stager.dart';
import 'package:bayantrack_mobile/features/images/data/evidence_upload_queue.dart';
import 'package:bayantrack_mobile/features/images/domain/evidence_image_editor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Uint8List> evidenceFixture({int width = 64, int height = 48}) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      canvas.drawRect(
        ui.Rect.fromLTWH(x.toDouble(), y.toDouble(), 1, 1),
        ui.Paint()..color = ui.Color((x + y).isEven ? 0xffff0000 : 0xff0000ff),
      );
    }
  }
  final picture = recorder.endRecording();
  final image = await picture.toImage(width, height);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  picture.dispose();
  return data!.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
}

Future<Uint8List> pixels(ui.Image image) async {
  final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  return data!.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'crop exports correct landscape and portrait dimensions and pixels',
    () async {
      for (final size in [(64, 48), (48, 64)]) {
        final source = await evidenceFixture(width: size.$1, height: size.$2);
        final editor = await EvidenceImageEditor.open(source);
        final before = await pixels(editor.image);
        await editor.apply(
          EvidenceEditTool.crop,
          const ui.Rect.fromLTWH(8, 6, 16, 20),
        );
        expect(editor.image.width, 16);
        expect(editor.image.height, 20);
        final after = await pixels(editor.image);
        final offset = (6 * size.$1 + 8) * 4;
        expect(after.sublist(0, 4), before.sublist(offset, offset + 4));
        final decoded = await EvidenceImageEditor.open(await editor.export());
        expect(decoded.image.width, 16);
        decoded.dispose();
        editor.dispose();
      }
    },
  );

  test(
    'redaction is opaque black only inside selection, blur changes real pixels',
    () async {
      for (final tool in [EvidenceEditTool.redact, EvidenceEditTool.blur]) {
        final editor = await EvidenceImageEditor.open(await evidenceFixture());
        final before = await pixels(editor.image);
        await editor.apply(tool, const ui.Rect.fromLTWH(16, 12, 32, 24));
        final after = await pixels(editor.image);
        expect(after.sublist(0, 4), before.sublist(0, 4));
        final center = (24 * 64 + 32) * 4;
        if (tool == EvidenceEditTool.redact) {
          for (var y = 12; y < 36; y++) {
            for (var x = 16; x < 48; x++) {
              final index = (y * 64 + x) * 4;
              expect(after.sublist(index, index + 4), [0, 0, 0, 255]);
            }
          }
        } else {
          expect(after[center], inInclusiveRange(80, 180));
          expect(after[center + 2], inInclusiveRange(80, 180));
          expect(
            after.sublist(center, center + 4),
            isNot(before.sublist(center, center + 4)),
          );
        }
        editor.dispose();
      }
    },
  );

  test(
    'undo and reset recover source pixels, invalid selections never mutate',
    () async {
      final editor = await EvidenceImageEditor.open(await evidenceFixture());
      final original = await pixels(editor.image);
      await editor.apply(
        EvidenceEditTool.redact,
        const ui.Rect.fromLTWH(0, 0, 20, 20),
      );
      await editor.apply(
        EvidenceEditTool.crop,
        const ui.Rect.fromLTWH(4, 4, 40, 40),
      );
      await editor.undo();
      expect(editor.image.width, 64);
      expect(editor.hasEdits, isTrue);
      await editor.undo();
      expect(await pixels(editor.image), original);
      expect(editor.canUndo, isFalse);
      await expectLater(
        editor.apply(EvidenceEditTool.crop, ui.Rect.zero),
        throwsFormatException,
      );
      expect(await pixels(editor.image), original);
      await editor.apply(
        EvidenceEditTool.redact,
        const ui.Rect.fromLTWH(0, 0, 20, 20),
      );
      await editor.reset();
      expect(editor.hasEdits, isFalse);
      expect(await pixels(editor.image), original);
      editor.dispose();
    },
  );

  test('corrupt and empty photos fail closed', () async {
    await expectLater(
      EvidenceImageEditor.open(Uint8List(0)),
      throwsFormatException,
    );
    await expectLater(
      EvidenceImageEditor.open(Uint8List.fromList([1, 2, 3])),
      throwsA(anything),
    );
  });

  test(
    'only edited derivative survives offline/restart/retry; original stays untouched',
    () async {
      final root = await Directory.systemTemp.createTemp('edited_evidence_');
      final original = File('${root.path}/original.png');
      final source = await evidenceFixture();
      await original.writeAsBytes(source);
      final editor = await EvidenceImageEditor.open(source);
      await editor.apply(
        EvidenceEditTool.redact,
        const ui.Rect.fromLTWH(0, 0, 32, 48),
      );
      final edited = await editor.export();
      final staged = await stageEvidenceFile(
        XFile.fromData(edited, name: 'evidence.png'),
        stagingDirectory: root,
      );
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      var reachable = false;
      final received = <Uint8List>[];
      var attempt = 0;
      EvidenceUploadQueue queue() => EvidenceUploadQueue(
        preferences: preferences,
        uploadDirectory: Directory('${root.path}/pending_evidence'),
        autoSchedule: false,
        canReachBackend: () => reachable,
        isAuthenticated: (id) async => id == 'owner',
        upload:
            ({
              required file,
              required reportId,
              required evidenceKey,
              required isPrimary,
              required cancelToken,
            }) async {
              received.add(await file.readAsBytes());
              if (attempt++ == 0) throw const SocketException('offline');
            },
      );
      final first = queue();
      final intents = await first.enqueue(
        userId: 'owner',
        reportId: 'report',
        files: [staged],
      );
      await first.resume('owner');
      expect(received, isEmpty);
      first.dispose();
      final restored = queue();
      await restored.initialize();
      expect(restored.allState.single.id, intents.single.id);
      expect(restored.allState.single.localFilePath, staged.path);
      reachable = true;
      await restored.resume('other-account');
      expect(received, isEmpty);
      await restored.resume('owner');
      expect(received.single, edited);
      expect(await staged.exists(), isTrue);
      await restored.retry();
      expect(received, [edited, edited]);
      expect(await staged.exists(), isFalse);
      expect(await original.readAsBytes(), source);
      restored.dispose();
      editor.dispose();
      await root.delete(recursive: true);
    },
  );
}
