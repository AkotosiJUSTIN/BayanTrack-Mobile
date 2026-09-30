import 'dart:typed_data';

import 'package:bayantrack_mobile/features/images/domain/evidence_image_editor.dart';
import 'package:bayantrack_mobile/features/images/presentation/evidence_photo_review.dart';
import 'package:bayantrack_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

import 'evidence_image_editor_test.dart' show evidenceFixture, pixels;

Future<void> settlePhoto(WidgetTester tester) async {
  // Native codecs need real event-loop turns outside widget tests' fake clock.
  for (var step = 0; step < 12; step++) {
    await tester.pump(const Duration(milliseconds: 50));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 15)),
    );
  }
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Done previews redaction; Use photo returns edited bytes only', (
    tester,
  ) async {
    final bytes = await tester.runAsync(() => evidenceFixture());
    XFile? accepted;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              child: const Text('Pick'),
              onPressed: () async {
                accepted = await reviewEvidencePhoto(
                  context,
                  XFile.fromData(bytes!, name: 'original.png'),
                  sensitive: true,
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Pick'));
    await settlePhoto(tester);
    expect(find.textContaining('Privacy-sensitive'), findsOneWidget);
    expect(accepted, isNull);
    await tester.tap(find.byTooltip('Edit'));
    await tester.pumpAndSettle();
    final image = find.byType(RawImage);
    final topLeft = tester.getTopLeft(image);
    final size = tester.getSize(image);
    await tester.dragFrom(
      topLeft + const Offset(10, 10),
      Offset(size.width / 2, size.height / 2),
    );
    await tester.pump();
    await tester.tap(find.text('Apply redact'));
    await settlePhoto(tester);
    await tester.tap(find.byTooltip('Done'));
    await settlePhoto(tester);
    expect(find.text('Review evidence'), findsOneWidget);
    expect(accepted, isNull);
    final acceptedPixels = await tester.runAsync(
      () => pixels(tester.widget<RawImage>(find.byType(RawImage)).image!),
    );
    await tester.tap(find.byTooltip('Edit'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Reset'));
    await settlePhoto(tester);
    await tester.tap(find.byTooltip('Cancel'));
    await settlePhoto(tester);
    expect(
      await tester.runAsync(
        () => pixels(tester.widget<RawImage>(find.byType(RawImage)).image!),
      ),
      acceptedPixels,
    );
    await tester.tap(find.byKey(const Key('evidence-confirm-photo')));
    await settlePhoto(tester);
    expect(accepted, isNotNull);
    final output = await tester.runAsync(() => accepted!.readAsBytes());
    expect(output, isNot(bytes));
    final editor = await tester.runAsync(
      () => EvidenceImageEditor.open(output!),
    );
    final data = await tester.runAsync(() => pixels(editor!.image));
    final center = (24 * 64 + 32) * 4;
    expect(data!.sublist(center, center + 4), [0, 0, 0, 255]);
    editor!.dispose();
  });

  testWidgets(
    'Cancel edits restores previous pixels; Cancel preview returns nothing',
    (tester) async {
      final bytes = await tester.runAsync(() => evidenceFixture());
      Uint8List? result;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                child: const Text('Pick'),
                onPressed: () async {
                  result = await Navigator.push(
                    context,
                    MaterialPageRoute<Uint8List>(
                      builder: (_) => EvidencePhotoReview(bytes: bytes!),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Pick'));
      await settlePhoto(tester);
      final before = tester.widget<RawImage>(find.byType(RawImage)).image!;
      final beforePixels = await tester.runAsync(() => pixels(before));
      await tester.tap(find.byTooltip('Edit'));
      await tester.pumpAndSettle();
      final raw = find.byType(RawImage);
      await tester.dragFrom(
        tester.getTopLeft(raw) + const Offset(10, 10),
        const Offset(100, 100),
      );
      await tester.pump();
      await tester.tap(find.text('Apply redact'));
      await settlePhoto(tester);
      await tester.tap(find.byTooltip('Cancel'));
      await settlePhoto(tester);
      expect(find.text('Review evidence'), findsOneWidget);
      final restored = tester.widget<RawImage>(find.byType(RawImage)).image!;
      expect(await tester.runAsync(() => pixels(restored)), beforePixels);
      await tester.tap(find.byTooltip('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Pick'), findsOneWidget);
      expect(result, isNull);
    },
  );

  testWidgets('corrupt image cannot be confirmed', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: EvidencePhotoReview(bytes: Uint8List.fromList([1, 2, 3])),
      ),
    );
    await settlePhoto(tester);
    expect(find.textContaining('Unable to open'), findsOneWidget);
    expect(find.byKey(const Key('evidence-confirm-photo')), findsNothing);
  });

  testWidgets('landscape and large text keep editor controls reachable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(844, 390);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final bytes = await tester.runAsync(() => evidenceFixture());
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.5)),
          child: child!,
        ),
        home: EvidencePhotoReview(bytes: bytes!, sensitive: true),
      ),
    );
    await settlePhoto(tester);
    await tester.tap(find.byTooltip('Edit'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(RawImage)).height, greaterThan(0));
    await tester.tap(find.byTooltip('Done'));
    await settlePhoto(tester);
    expect(find.byKey(const Key('evidence-confirm-photo')), findsOneWidget);
  });
}
