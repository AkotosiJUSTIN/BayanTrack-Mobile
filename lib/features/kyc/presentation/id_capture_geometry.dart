import 'dart:math' as math;

import 'package:flutter/painting.dart';

/// Shared camera-guide and crop math.
///
/// All rectangles use upright, on-screen coordinates. The crop is frame-based;
/// it does not claim document-edge detection.
abstract final class IdCaptureGeometry {
  static const idCardAspectRatio = 1.58;

  static Rect frameFor(Size size) {
    final landscape = size.width > size.height;
    final topReserved = landscape ? 98.0 : 146.0;
    final bottomReserved = landscape ? 80.0 : 106.0;
    final availableHeight = math.max(
      1.0,
      size.height - topReserved - bottomReserved,
    );
    final maxWidth = size.width * (landscape ? 0.78 : 0.86);
    final maxHeight = availableHeight * (landscape ? 0.88 : 0.72);
    final width = math.min(maxWidth, maxHeight * idCardAspectRatio);
    final height = width / idCardAspectRatio;

    return Rect.fromCenter(
      center: Offset(size.width / 2, topReserved + availableHeight / 2),
      width: width,
      height: height,
    );
  }

  static Size orientedPreviewSize(Size raw, {required bool landscape}) {
    final rawIsLandscape = raw.width >= raw.height;
    return rawIsLandscape == landscape ? raw : Size(raw.height, raw.width);
  }

  /// Maps guide coordinates through the same centered `BoxFit.cover` transform
  /// used by the live preview, then through the centered camera crop when the
  /// still image and preview use different sensor aspect ratios.
  static Rect? mapFrameToImage({
    required Size previewSize,
    required Size imageSize,
    required Size viewportSize,
    required Rect frame,
  }) {
    if (!_validSize(previewSize) ||
        !_validSize(imageSize) ||
        !_validSize(viewportSize) ||
        frame.width <= 0 ||
        frame.height <= 0) {
      return null;
    }

    final fitted = applyBoxFit(BoxFit.cover, previewSize, viewportSize);
    final previewCrop = Alignment.center.inscribe(
      fitted.source,
      Offset.zero & previewSize,
    );
    final previewDestination = Alignment.center.inscribe(
      fitted.destination,
      Offset.zero & viewportSize,
    );
    final visibleFrame = Rect.fromLTRB(
      math.max(frame.left, previewDestination.left),
      math.max(frame.top, previewDestination.top),
      math.min(frame.right, previewDestination.right),
      math.min(frame.bottom, previewDestination.bottom),
    );
    if (visibleFrame.width <= 0 || visibleFrame.height <= 0) return null;

    final sourcePerScreenX = previewCrop.width / previewDestination.width;
    final sourcePerScreenY = previewCrop.height / previewDestination.height;
    final mappedPreview = Rect.fromLTRB(
      previewCrop.left +
          (visibleFrame.left - previewDestination.left) * sourcePerScreenX,
      previewCrop.top +
          (visibleFrame.top - previewDestination.top) * sourcePerScreenY,
      previewCrop.left +
          (visibleFrame.right - previewDestination.left) * sourcePerScreenX,
      previewCrop.top +
          (visibleFrame.bottom - previewDestination.top) * sourcePerScreenY,
    );

    final cameraCrop = applyBoxFit(BoxFit.cover, imageSize, previewSize);
    final imageVisibleSource = Alignment.center.inscribe(
      cameraCrop.source,
      Offset.zero & imageSize,
    );
    final imageRect = Rect.fromLTRB(
      imageVisibleSource.left +
          mappedPreview.left / previewSize.width * imageVisibleSource.width,
      imageVisibleSource.top +
          mappedPreview.top / previewSize.height * imageVisibleSource.height,
      imageVisibleSource.left +
          mappedPreview.right / previewSize.width * imageVisibleSource.width,
      imageVisibleSource.top +
          mappedPreview.bottom / previewSize.height * imageVisibleSource.height,
    );
    return Rect.fromLTRB(
      imageRect.left.clamp(0.0, imageSize.width),
      imageRect.top.clamp(0.0, imageSize.height),
      imageRect.right.clamp(0.0, imageSize.width),
      imageRect.bottom.clamp(0.0, imageSize.height),
    );
  }

  static bool _validSize(Size size) =>
      size.width.isFinite &&
      size.height.isFinite &&
      size.width > 0 &&
      size.height > 0;
}
