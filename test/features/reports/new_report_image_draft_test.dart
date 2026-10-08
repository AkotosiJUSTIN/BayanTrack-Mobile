import 'dart:io';

import 'package:bayantrack_mobile/features/reports/data/report_draft_store.dart';
import 'package:bayantrack_mobile/features/reports/data/report_models.dart';
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

  test('removing an image leaves cleanup to the durable owner', () async {
    final controller = container.read(newReportControllerProvider.notifier);
    final image = await draft('draft_remove.jpg');

    controller.addImage(image);
    controller.removeImage(0);

    expect(container.read(newReportControllerProvider).selectedImages, isEmpty);
    expect(await image.exists(), isTrue);
  });

  test('reset clears form references without deleting staged files', () async {
    final controller = container.read(newReportControllerProvider.notifier);
    final images = [await draft('draft_one.jpg'), await draft('draft_two.jpg')];

    controller.addImages(images);
    controller.reset();

    expect(container.read(newReportControllerProvider).selectedImages, isEmpty);
    expect(images.every((file) => file.existsSync()), isTrue);
  });

  test(
    'restores an incomplete full draft without consent or transient state',
    () async {
      final controller = container.read(newReportControllerProvider.notifier);
      final image = await draft('draft_restore.jpg');
      final now = DateTime.utc(2026, 9, 27);
      final saved = ReportDraft(
        schemaVersion: ReportDraft.currentSchemaVersion,
        draftId: 'full-draft-1',
        ownerId: 'user-A',
        type: ReportDraftType.full,
        createdAt: now,
        updatedAt: now,
        resumeStep: 'review',
        payload: {
          'category': ReportCategory.floodDisaster.value,
          'title': 'Road flooding',
          'description': 'Water covers the road',
          'incidentDatetime': now.toIso8601String(),
          'isHappeningNow': true,
          'streetLandmark': 'Market road',
          'municipalityId': 'urdaneta',
          'latitude': 15.979204,
          'longitude': 120.622210,
          'locationAccuracy': LocationAccuracy.exact.name,
        },
        attachmentRefs: [image.path],
      );

      controller.restoreDraft(saved, attachments: [image]);
      final restored = container.read(newReportControllerProvider);

      expect(restored.title, 'Road flooding');
      expect(restored.description, 'Water covers the road');
      expect(restored.category, ReportCategory.floodDisaster);
      expect(restored.selectedImages, [image]);
      expect(restored.resumeStep, 'review');
      expect(restored.barangayId, isNull);
      expect(restored.declarationConfirmed, isFalse);
      expect(restored.dataProcessingConsent, isFalse);
      expect(restored.isSubmitting, isFalse);
      expect(restored.error, isNull);
      expect(restored.nearbyLandmarkSuggestions, isEmpty);
      expect(restored.canSubmit, isFalse);
    },
  );

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
