import 'package:bayantrack_mobile/features/kyc/presentation/id_capture_geometry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IdCaptureGeometry', () {
    test('keeps ID guide bounds inside portrait and landscape screens', () {
      for (final size in const [
        Size(360, 800),
        Size(390, 844),
        Size(844, 390),
        Size(1280, 720),
      ]) {
        final frame = IdCaptureGeometry.frameFor(size);

        expect(frame.left, greaterThanOrEqualTo(0));
        expect(frame.top, greaterThanOrEqualTo(0));
        expect(frame.right, lessThanOrEqualTo(size.width));
        expect(frame.bottom, lessThanOrEqualTo(size.height));
        expect(frame.width / frame.height, closeTo(1.58, 0.01));
      }
    });

    test('maps portrait overlay to portrait capture pixels', () {
      const viewport = Size(360, 800);
      const preview = Size(1080, 1920);
      const image = Size(2160, 3840);
      final frame = IdCaptureGeometry.frameFor(viewport);

      final crop = IdCaptureGeometry.mapFrameToImage(
        previewSize: preview,
        imageSize: image,
        viewportSize: viewport,
        frame: frame,
      );

      expect(crop, isNotNull);
      expect(crop!.left, greaterThanOrEqualTo(0));
      expect(crop.top, greaterThanOrEqualTo(0));
      expect(crop.right, lessThanOrEqualTo(image.width));
      expect(crop.bottom, lessThanOrEqualTo(image.height));
      expect(crop.width / crop.height, closeTo(1.58, 0.01));
    });

    test('maps landscape cover crop and preserves sensor aspect ratio', () {
      const viewport = Size(844, 390);
      const preview = Size(1920, 1080);
      const image = Size(3840, 2160);
      final frame = IdCaptureGeometry.frameFor(viewport);

      final crop = IdCaptureGeometry.mapFrameToImage(
        previewSize: preview,
        imageSize: image,
        viewportSize: viewport,
        frame: frame,
      );

      expect(crop, isNotNull);
      expect(crop!.top, greaterThan(0));
      expect(crop.bottom, lessThan(image.height));
      expect(crop.width / crop.height, closeTo(1.58, 0.01));
    });

    test('maps a 16:9 preview onto a 4:3 still image', () {
      const viewport = Size(844, 390);
      const preview = Size(1920, 1080);
      const image = Size(4000, 3000);
      final crop = IdCaptureGeometry.mapFrameToImage(
        previewSize: preview,
        imageSize: image,
        viewportSize: viewport,
        frame: IdCaptureGeometry.frameFor(viewport),
      );

      expect(crop, isNotNull);
      expect(crop!.top, greaterThan(0));
      expect(crop.bottom, lessThan(image.height));
    });

    test(
      'returns null for invalid geometry so caller can preserve original',
      () {
        final crop = IdCaptureGeometry.mapFrameToImage(
          previewSize: Size.zero,
          imageSize: const Size(4000, 3000),
          viewportSize: const Size(360, 800),
          frame: IdCaptureGeometry.frameFor(const Size(360, 800)),
        );

        expect(crop, isNull);
      },
    );

    test('orients raw sensor preview for both landscape directions', () {
      const raw = Size(1920, 1080);

      expect(
        IdCaptureGeometry.orientedPreviewSize(raw, landscape: false),
        const Size(1080, 1920),
      );
      expect(IdCaptureGeometry.orientedPreviewSize(raw, landscape: true), raw);
    });
  });
}
