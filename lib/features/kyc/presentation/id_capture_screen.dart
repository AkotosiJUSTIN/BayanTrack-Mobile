import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/app_localizations.dart';
import 'id_capture_geometry.dart';

enum IdCaptureSide { front, back }

class IdCaptureScreen extends StatefulWidget {
  const IdCaptureScreen({super.key, required this.side, this.cameraLoader});

  final IdCaptureSide side;
  final Future<List<CameraDescription>> Function()? cameraLoader;

  @override
  State<IdCaptureScreen> createState() => _IdCaptureScreenState();
}

class _IdCaptureScreenState extends State<IdCaptureScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  String? _error;
  bool _isInitializing = false;
  bool _flashlightOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_initializeCamera());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    final controller = _controller;
    if (controller != null) unawaited(controller.dispose());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      final controller = _controller;
      _controller = null;
      if (controller != null) unawaited(controller.dispose());
      if (mounted) setState(() {});
    } else if (state == AppLifecycleState.resumed) {
      unawaited(_initializeCamera());
    }
  }

  Future<void> _initializeCamera() async {
    if (_isInitializing || !mounted) return;
    _isInitializing = true;
    if (mounted) setState(() => _error = null);

    CameraController? nextController;
    try {
      final loader = widget.cameraLoader ?? availableCameras;
      final cameras = await loader();
      if (!mounted) return;
      if (cameras.isEmpty) {
        setState(() => _error = AppLocalizations.of(context).imageAccessError);
        return;
      }

      final description = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      nextController = CameraController(
        description,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await nextController.initialize();
      await _applyFlashlightMode(nextController);
      if (!mounted) {
        unawaited(nextController.dispose());
        return;
      }

      final previousController = _controller;
      setState(() {
        _controller = nextController;
        _error = null;
      });
      if (previousController != null) {
        unawaited(previousController.dispose());
      }
      nextController = null;
    } catch (_) {
      if (mounted) {
        setState(() => _error = AppLocalizations.of(context).imageAccessError);
      }
    } finally {
      if (nextController != null) unawaited(nextController.dispose());
      _isInitializing = false;
    }
  }

  Future<void> _applyFlashlightMode(CameraController controller) async {
    try {
      await controller.setFlashMode(
        _flashlightOn ? FlashMode.torch : FlashMode.off,
      );
    } on CameraException {
      // Some cameras do not expose a torch. Keep capture available and reset
      // the toggle so the UI reflects the actual camera state.
      _flashlightOn = false;
    }
  }

  Future<void> _toggleFlashlight() async {
    final controller = _controller;
    if (controller == null ||
        !controller.value.isInitialized ||
        controller.value.isTakingPicture) {
      return;
    }

    final nextValue = !_flashlightOn;
    try {
      await controller.setFlashMode(
        nextValue ? FlashMode.torch : FlashMode.off,
      );
      if (mounted) setState(() => _flashlightOn = nextValue);
    } on CameraException {
      if (mounted) {
        setState(() => _error = AppLocalizations.of(context).imageAccessError);
      }
    }
  }

  Future<void> _takePicture(Size viewportSize, Rect frame) async {
    final controller = _controller;
    if (controller == null ||
        !controller.value.isInitialized ||
        controller.value.isTakingPicture) {
      return;
    }

    try {
      final image = await controller.takePicture();
      final framedImage = await _cropCapturedImage(
        image,
        viewportSize: viewportSize,
        frame: frame,
        previewSize: _orientedPreviewSize(controller),
      );
      if (mounted) Navigator.of(context).pop(framedImage);
    } on CameraException {
      if (mounted) {
        setState(() => _error = AppLocalizations.of(context).imageAccessError);
      }
    }
  }

  DeviceOrientation _applicableOrientation(CameraController controller) {
    final value = controller.value;
    return value.previewPauseOrientation ??
        value.lockedCaptureOrientation ??
        value.deviceOrientation;
  }

  bool _isLandscape(CameraController controller) {
    final orientation = _applicableOrientation(controller);
    return orientation == DeviceOrientation.landscapeLeft ||
        orientation == DeviceOrientation.landscapeRight;
  }

  Size _orientedPreviewSize(CameraController controller) {
    final raw = controller.value.previewSize;
    if (raw == null) return Size.zero;
    return IdCaptureGeometry.orientedPreviewSize(
      raw,
      landscape: _isLandscape(controller),
    );
  }

  Widget _buildCameraPreview(CameraController controller) {
    final previewSize = _orientedPreviewSize(controller);
    if (previewSize == Size.zero) return const ColoredBox(color: Colors.black);

    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: previewSize.width,
          height: previewSize.height,
          child: CameraPreview(controller),
        ),
      ),
    );
  }

  Future<XFile> _cropCapturedImage(
    XFile image, {
    required Size viewportSize,
    required Rect frame,
    required Size previewSize,
  }) async {
    ui.Codec? codec;
    ui.Image? decoded;
    ui.Image? cropped;
    try {
      final bytes = await image.readAsBytes();
      codec = await ui.instantiateImageCodec(bytes);
      final frameInfo = await codec.getNextFrame();
      decoded = frameInfo.image;
      final crop = IdCaptureGeometry.mapFrameToImage(
        previewSize: previewSize,
        imageSize: Size(decoded.width.toDouble(), decoded.height.toDouble()),
        viewportSize: viewportSize,
        frame: frame,
      );
      if (crop == null) return image;

      final outputWidth = crop.width.round().clamp(1, decoded.width).toInt();
      final outputHeight = crop.height.round().clamp(1, decoded.height).toInt();
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.drawImageRect(
        decoded,
        crop,
        Rect.fromLTWH(0, 0, outputWidth.toDouble(), outputHeight.toDouble()),
        Paint()..filterQuality = FilterQuality.high,
      );
      cropped = await recorder.endRecording().toImage(
        outputWidth,
        outputHeight,
      );
      final outputBytes = await cropped.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (outputBytes == null) return image;

      final outputPath = _framedImagePath(image.path);
      await File(outputPath).writeAsBytes(
        outputBytes.buffer.asUint8List(
          outputBytes.offsetInBytes,
          outputBytes.lengthInBytes,
        ),
        flush: true,
      );
      return XFile(outputPath, mimeType: 'image/png');
    } catch (_) {
      // Frame mapping is conservative. Never replace a usable capture with a
      // malformed crop when decoding or writing fails.
      return image;
    } finally {
      codec?.dispose();
      decoded?.dispose();
      cropped?.dispose();
    }
  }

  String _framedImagePath(String sourcePath) {
    final separator = math.max(
      sourcePath.lastIndexOf('/'),
      sourcePath.lastIndexOf('\\'),
    );
    final dot = sourcePath.lastIndexOf('.');
    final hasExtension = dot > separator;
    final base = hasExtension ? sourcePath.substring(0, dot) : sourcePath;
    return '${base}_framed.png';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final controller = _controller;
    final canCapture =
        controller?.value.isInitialized == true &&
        controller?.value.isTakingPicture == false;
    final title = widget.side == IdCaptureSide.front
        ? l10n.idFrontPhoto
        : l10n.idBackPhoto;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final viewportSize = Size(
              constraints.maxWidth,
              constraints.maxHeight,
            );
            final frame = IdCaptureGeometry.frameFor(viewportSize);
            final isLandscape = viewportSize.width > viewportSize.height;

            return Stack(
              fit: StackFit.expand,
              children: [
                controller?.value.isInitialized == true
                    ? _buildCameraPreview(controller!)
                    : const ColoredBox(color: Colors.black),
                IgnorePointer(
                  child: Semantics(
                    container: true,
                    label:
                        '${l10n.fitIdInsideFrame}. ${l10n.keepIdFlatReadable}',
                    child: const IdCaptureGuide(),
                  ),
                ),
                Positioned(
                  top: isLandscape ? 4 : 8,
                  left: 12,
                  right: 12,
                  child: Row(
                    children: [
                      Material(
                        color: theme.colorScheme.surface.withValues(
                          alpha: 0.82,
                        ),
                        shape: const CircleBorder(),
                        child: IconButton(
                          tooltip: l10n.back,
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.close),
                          color: theme.colorScheme.onSurface,
                          constraints: const BoxConstraints.tightFor(
                            width: 48,
                            height: 48,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            shadows: const [
                              Shadow(color: Colors.black54, blurRadius: 6),
                            ],
                          ),
                        ),
                      ),
                      Material(
                        color: theme.colorScheme.surface.withValues(
                          alpha: 0.82,
                        ),
                        shape: const CircleBorder(),
                        child: IconButton(
                          tooltip: _flashlightOn
                              ? l10n.flashlightOff
                              : l10n.flashlightOn,
                          onPressed: canCapture ? _toggleFlashlight : null,
                          icon: Icon(
                            _flashlightOn ? Icons.flash_on : Icons.flash_off,
                          ),
                          color: _flashlightOn
                              ? Colors.orange
                              : theme.colorScheme.onSurface,
                          constraints: const BoxConstraints.tightFor(
                            width: 48,
                            height: 48,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: isLandscape ? 58 : 72,
                  left: isLandscape ? 32 : 24,
                  right: isLandscape ? 32 : 24,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isLandscape ? 12 : 16,
                      vertical: isLandscape ? 8 : 12,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withValues(alpha: 0.84),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: isLandscape
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  l10n.fitIdInsideFrame,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Text(
                                ' · ',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  l10n.keepIdFlatReadable,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              Text(
                                l10n.fitIdInsideFrame,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.keepIdFlatReadable,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                if (_error != null)
                  Positioned.fill(
                    child: ColoredBox(
                      color: Colors.black.withValues(alpha: 0.32),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              FilledButton.tonal(
                                onPressed: _initializeCamera,
                                child: Text(l10n.retry),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                if (_error == null && controller == null)
                  const Center(child: CircularProgressIndicator()),
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: isLandscape ? 12 : 16,
                  child: Center(
                    child: Semantics(
                      button: true,
                      enabled: canCapture,
                      label: l10n.takePhoto,
                      child: Material(
                        color: canCapture
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest,
                        shape: const CircleBorder(),
                        child: IconButton(
                          tooltip: l10n.takePhoto,
                          onPressed: canCapture
                              ? () => _takePicture(viewportSize, frame)
                              : null,
                          icon: const Icon(Icons.camera_alt_outlined),
                          color: canCapture
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurfaceVariant,
                          iconSize: 30,
                          constraints: const BoxConstraints.tightFor(
                            width: 64,
                            height: 64,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class IdCaptureGuide extends StatelessWidget {
  const IdCaptureGuide({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(
        key: const ValueKey('id-capture-guide'),
        painter: _IdCaptureGuidePainter(Theme.of(context).colorScheme.primary),
      ),
    );
  }
}

class _IdCaptureGuidePainter extends CustomPainter {
  const _IdCaptureGuidePainter(this.accentColor);

  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final frame = _frameRect(size);
    final frameRRect = RRect.fromRectAndRadius(
      frame,
      const Radius.circular(20),
    );
    final outside = Path()..addRect(Offset.zero & size);
    final inside = Path()..addRRect(frameRRect);

    canvas.drawPath(
      Path.combine(PathOperation.difference, outside, inside),
      Paint()..color = Colors.black.withValues(alpha: 0.26),
    );
    canvas.drawRRect(
      frameRRect,
      Paint()..color = accentColor.withValues(alpha: 0.08),
    );
    canvas.drawRRect(
      frameRRect,
      Paint()
        ..color = accentColor.withValues(alpha: 0.66)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final cornerPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.94)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 3.5;
    final length = math.min(28.0, frame.width * 0.16);
    final path = Path()
      ..moveTo(frame.left, frame.top + length)
      ..lineTo(frame.left, frame.top)
      ..lineTo(frame.left + length, frame.top)
      ..moveTo(frame.right - length, frame.top)
      ..lineTo(frame.right, frame.top)
      ..lineTo(frame.right, frame.top + length)
      ..moveTo(frame.left, frame.bottom - length)
      ..lineTo(frame.left, frame.bottom)
      ..lineTo(frame.left + length, frame.bottom)
      ..moveTo(frame.right - length, frame.bottom)
      ..lineTo(frame.right, frame.bottom)
      ..lineTo(frame.right, frame.bottom - length);
    canvas.drawPath(path, cornerPaint);
  }

  Rect _frameRect(Size size) {
    return IdCaptureGeometry.frameFor(size);
  }

  @override
  bool shouldRepaint(covariant _IdCaptureGuidePainter oldDelegate) =>
      oldDelegate.accentColor != accentColor;
}
