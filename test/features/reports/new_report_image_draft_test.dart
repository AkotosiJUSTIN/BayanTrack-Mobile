import 'dart:io';

import 'package:bayantrack_mobile/features/reports/presentation/new_report/new_report_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory root;
  late Directory drafts;
  late ProviderContainer container;
  late ProviderSubscription<NewReportState> subscription;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('report_image_draft_test_');
    drafts = Directory(
      '${root.path}${Platform.pathSeparator}report_evidence_drafts',
    );
    await drafts.create();
    await File(
      '${drafts.path}${Platform.pathSeparator}.bayantrack_evidence_drafts',
    ).create();
    container = ProviderContainer();
    subscription = container.listen(newReportControllerProvider, (_, _) {});
  });

  tearDown(() async {
    subscription.close();
    container.dispose();
    if (await root.exists()) await root.delete(recursive: true);
  });

  Future<File> draft(String name) async {
    final file = File('${drafts.path}${Platform.pathSeparator}$name');
    await file.writeAsBytes(List<int>.filled(16, 1));
    return file;
  }

  test('removing a selected image deletes its app-owned draft', () async {
    final controller = container.read(newReportControllerProvider.notifier);
    final image = await draft('draft_remove.jpg');

    controller.addImage(image);
    controller.removeImage(0);
    await _waitForDeletion(image);

    expect(container.read(newReportControllerProvider).selectedImages, isEmpty);
  });

  test('reset deletes all selected app-owned drafts', () async {
    final controller = container.read(newReportControllerProvider.notifier);
    final images = [await draft('draft_one.jpg'), await draft('draft_two.jpg')];

    controller.addImages(images);
    controller.reset();
    await Future.wait(images.map(_waitForDeletion));

    expect(container.read(newReportControllerProvider).selectedImages, isEmpty);
  });

  test('photos beyond former client limit remain selected', () async {
    final controller = container.read(newReportControllerProvider.notifier);
    final images = <File>[];
    for (var index = 0; index < 6; index++) {
      images.add(await draft('draft_image-$index.jpg'));
    }

    controller.addImages(images);

    expect(
      container.read(newReportControllerProvider).selectedImages,
      hasLength(images.length),
    );
    expect(images.every((file) => file.existsSync()), isTrue);
  });

  test(
    'submission handoff resets state without deleting queue-owned draft',
    () async {
      final controller = container.read(newReportControllerProvider.notifier);
      final image = await draft('draft_queue-owned.jpg');

      controller.addImage(image);
      controller.resetAfterEvidenceHandoff();
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(
        container.read(newReportControllerProvider).selectedImages,
        isEmpty,
      );
      expect(await image.exists(), isTrue);
    },
  );
}

Future<void> _waitForDeletion(File file) async {
  for (var attempt = 0; attempt < 20 && await file.exists(); attempt++) {
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  expect(await file.exists(), isFalse);
}
