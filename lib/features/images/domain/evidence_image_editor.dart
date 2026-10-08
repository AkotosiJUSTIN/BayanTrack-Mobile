import 'dart:typed_data';
import 'dart:ui' as ui;

enum EvidenceEditTool { crop, blur, redact }

/// Raster edits are flattened into a new PNG; source metadata is not copied.
class EvidenceImageEditor {
  EvidenceImageEditor._(this.original, this._image);

  final Uint8List original;
  ui.Image _image;
  final List<Uint8List> _history = [];
  Uint8List? _current;
  bool _disposed = false;

  ui.Image get image => _image;
  bool get canUndo => _history.isNotEmpty;
  bool get hasEdits => _current != null;

  static Future<EvidenceImageEditor> open(Uint8List bytes) async {
    if (bytes.isEmpty || bytes.length > 10 * 1024 * 1024) {
      throw const FormatException('Image must be between 1 byte and 10 MB');
    }
    final image = await _decode(bytes);
    return EvidenceImageEditor._(bytes, image);
  }

  static Future<ui.Image> _decode(Uint8List bytes) async {
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    ui.ImageDescriptor? descriptor;
    ui.Codec? codec;
    try {
      descriptor = await ui.ImageDescriptor.encoded(buffer);
      if (descriptor.width * descriptor.height > 40000000) {
        throw const FormatException('Image dimensions are too large');
      }
      // Bound editing memory; preserve aspect ratio, never upscale.
      final scale =
          2048 /
          (descriptor.width > descriptor.height
              ? descriptor.width
              : descriptor.height);
      codec = await descriptor.instantiateCodec(
        targetWidth: scale < 1 ? (descriptor.width * scale).round() : null,
        targetHeight: scale < 1 ? (descriptor.height * scale).round() : null,
      );
      if (codec.frameCount != 1) {
        throw const FormatException('Select a still photo');
      }
      return (await codec.getNextFrame()).image;
    } finally {
      codec?.dispose();
      descriptor?.dispose();
      buffer.dispose();
    }
  }

  Future<Uint8List> export() async {
    final data = await _image.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) throw StateError('Image export failed');
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  Future<void> apply(EvidenceEditTool tool, ui.Rect selection) async {
    final bounds = ui.Rect.fromLTWH(
      0,
      0,
      _image.width.toDouble(),
      _image.height.toDouble(),
    );
    final selected = selection.intersect(bounds);
    if (!selected.isFinite || selected.width < 1 || selected.height < 1) {
      throw const FormatException('Select an area inside the photo');
    }
    final region = ui.Rect.fromLTRB(
      selected.left.floorToDouble(),
      selected.top.floorToDouble(),
      selected.right.ceilToDouble(),
      selected.bottom.ceilToDouble(),
    );
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final crop = tool == EvidenceEditTool.crop;
    final output = crop ? region : bounds;
    if (crop) {
      canvas.drawImageRect(
        _image,
        region,
        ui.Offset.zero & region.size,
        ui.Paint(),
      );
    } else {
      canvas.drawImage(_image, ui.Offset.zero, ui.Paint());
      if (tool == EvidenceEditTool.redact) {
        canvas.drawRect(region, ui.Paint()..color = const ui.Color(0xff000000));
      } else {
        canvas.save();
        canvas.clipRect(region, doAntiAlias: false);
        canvas.drawImage(
          _image,
          ui.Offset.zero,
          ui.Paint()
            ..imageFilter = ui.ImageFilter.blur(
              sigmaX: (region.shortestSide / 6).clamp(12, 80),
              sigmaY: (region.shortestSide / 6).clamp(12, 80),
              tileMode: ui.TileMode.clamp,
            ),
        );
        canvas.restore();
      }
    }
    final picture = recorder.endRecording();
    ui.Image? next;
    try {
      next = await picture.toImage(output.width.toInt(), output.height.toInt());
      final data = await next.toByteData(format: ui.ImageByteFormat.png);
      if (_disposed) return;
      if (data == null) throw StateError('Image export failed');
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      if (bytes.length > 10 * 1024 * 1024) {
        throw StateError('Edited image exceeds 10 MB');
      }
      _history.add(_current ?? original);
      // ponytail: ten PNG undo snapshots; replay operations if deeper history is needed.
      if (_history.length > 10) _history.removeAt(0);
      _current = bytes;
      _image.dispose();
      _image = next;
      next = null;
    } finally {
      next?.dispose();
      picture.dispose();
    }
  }

  Future<void> undo() async {
    if (!canUndo) return;
    final previous = _history.last;
    final decoded = await _decode(previous);
    if (_disposed) {
      decoded.dispose();
      return;
    }
    _history.removeLast();
    _image.dispose();
    _image = decoded;
    _current = identical(previous, original) ? null : previous;
  }

  Future<void> reset() async {
    final decoded = await _decode(original);
    if (_disposed) {
      decoded.dispose();
      return;
    }
    _image.dispose();
    _image = decoded;
    _current = null;
    _history.clear();
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _image.dispose();
    _history.clear();
  }
}
