import 'dart:async';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

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

  Future<void> _takePicture() async {
    final controller = _controller;
    if (controller == null ||
        !controller.value.isInitialized ||
        controller.value.isTakingPicture) {
      return;
    }

    try {
      final image = await controller.takePicture();
      if (mounted) Navigator.of(context).pop(image);
    } on CameraException {
      if (mounted) {
        setState(() => _error = AppLocalizations.of(context).imageAccessError);
      }
    }
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
        child: Stack(
          fit: StackFit.expand,
          children: [
            controller?.value.isInitialized == true
                ? CameraPreview(controller!)
                : const ColoredBox(color: Colors.black),
            IgnorePointer(
              child: Semantics(
                container: true,
                label: '${l10n.fitIdInsideFrame}. ${l10n.keepIdFlatReadable}',
                child: const IdCaptureGuide(),
              ),
            ),
            Positioned(
              top: 8,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  Material(
                    color: theme.colorScheme.surface.withValues(alpha: 0.82),
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
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48, height: 48),
                ],
              ),
            ),
            Positioned(
              top: 72,
              left: 24,
              right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.84),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
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
              bottom: 16,
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
                      onPressed: canCapture ? _takePicture : null,
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
    // Visual guide only. No detection, crop, or dimension validation uses it.
    const visualCardRatio = 1.58;
    final width = math.min(
      size.width * 0.86,
      size.height * 0.52 * visualCardRatio,
    );
    final height = width / visualCardRatio;
    return Rect.fromCenter(
      center: size.center(Offset.zero),
      width: width,
      height: height,
    );
  }

  @override
  bool shouldRepaint(covariant _IdCaptureGuidePainter oldDelegate) =>
      oldDelegate.accentColor != accentColor;
}
