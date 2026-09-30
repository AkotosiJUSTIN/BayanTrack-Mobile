import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/evidence_image_editor.dart';

/// No upload or filesystem writes occur until the calling flow accepts a result.
Future<XFile?> reviewEvidencePhoto(
  BuildContext context,
  XFile source, {
  bool sensitive = false,
}) async {
  final length = await source.length();
  if (length < 1 || length > 10 * 1024 * 1024) {
    throw const FormatException('Select a photo smaller than 10 MB');
  }
  final bytes = await source.readAsBytes();
  if (!context.mounted) return null;
  final result = await Navigator.of(context).push<Uint8List>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => EvidencePhotoReview(bytes: bytes, sensitive: sensitive),
    ),
  );
  return result == null
      ? null
      : XFile.fromData(result, name: 'evidence.png', mimeType: 'image/png');
}

class EvidencePhotoReview extends StatefulWidget {
  const EvidencePhotoReview({
    super.key,
    required this.bytes,
    this.sensitive = false,
  });

  final Uint8List bytes;
  final bool sensitive;

  @override
  State<EvidencePhotoReview> createState() => _EvidencePhotoReviewState();
}

class _EvidencePhotoReviewState extends State<EvidencePhotoReview> {
  EvidenceImageEditor? _editor;
  Uint8List? _accepted;
  bool _editing = false;
  bool _busy = true;
  bool _before = false;
  String? _error;
  EvidenceEditTool _tool = EvidenceEditTool.redact;
  Offset? _start;
  Rect? _selection;

  @override
  void initState() {
    super.initState();
    _load(widget.bytes);
  }

  Future<void> _load(Uint8List bytes) async {
    try {
      final editor = await EvidenceImageEditor.open(bytes);
      if (!mounted) {
        editor.dispose();
        return;
      }
      _editor?.dispose();
      setState(() {
        _editor = editor;
        _busy = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'Unable to open photo. Select a valid still image.';
        });
      }
    }
  }

  @override
  void dispose() {
    _editor?.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
      if (mounted) setState(() => _selection = null);
    } catch (_) {
      if (mounted) setState(() => _error = 'Unable to edit photo. Try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _done() => _run(() async {
    final result = await _editor!.export();
    if (!mounted) return;
    setState(() {
      _accepted = result;
      _editing = false;
      _before = false;
    });
  });

  Future<void> _cancelEdits() => _run(() async {
    await _load(_accepted ?? widget.bytes);
    if (mounted) {
      setState(() {
        _editing = false;
        _before = false;
      });
    }
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final editor = _editor;
    return PopScope(
      canPop: !_busy && !_editing,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _editing && !_busy) _cancelEdits();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_editing ? 'Edit evidence' : 'Review evidence'),
          leading: IconButton(
            tooltip: l10n.cancel,
            icon: const Icon(Icons.close),
            onPressed: _busy
                ? null
                : () {
                    if (_editing) {
                      _cancelEdits();
                    } else {
                      Navigator.pop(context);
                    }
                  },
          ),
          actions: [
            if (editor != null && !_editing)
              IconButton(
                tooltip: 'Edit',
                icon: const Icon(Icons.edit_outlined),
                onPressed: _busy ? null : () => setState(() => _editing = true),
              ),
            if (_editing)
              IconButton(
                tooltip: l10n.done,
                icon: const Icon(Icons.check),
                onPressed: _busy ? null : _done,
              ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              if (widget.sensitive)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: const Text(
                    'Privacy-sensitive evidence. Cover faces and identifying details. Black redaction is safer than blur.',
                  ),
                ),
              if (_editing)
                Text(
                  _before ? 'Before' : 'After',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Semantics(liveRegion: true, child: Text(_error!)),
                ),
              Expanded(
                child: editor == null
                    ? Center(
                        child: _busy
                            ? const CircularProgressIndicator()
                            : const Icon(Icons.broken_image_outlined),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final imageSize = Size(
                            editor.image.width.toDouble(),
                            editor.image.height.toDouble(),
                          );
                          final fitted = applyBoxFit(
                            BoxFit.contain,
                            imageSize,
                            constraints.biggest,
                          ).destination;
                          _viewport = fitted;
                          return Center(
                            child: SizedBox(
                              width: fitted.width,
                              height: fitted.height,
                              child: GestureDetector(
                                onPanStart: !_editing || _busy || _before
                                    ? null
                                    : (details) => setState(() {
                                        _start = details.localPosition;
                                        _selection = null;
                                      }),
                                onPanUpdate: !_editing || _busy || _before
                                    ? null
                                    : (details) => setState(() {
                                        _selection = Rect.fromPoints(
                                          _start!,
                                          details.localPosition,
                                        ).intersect(Offset.zero & fitted);
                                      }),
                                onPanCancel: () =>
                                    setState(() => _selection = null),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    if (_before)
                                      Image.memory(
                                        widget.bytes,
                                        fit: BoxFit.contain,
                                      )
                                    else
                                      RawImage(
                                        image: editor.image,
                                        fit: BoxFit.contain,
                                      ),
                                    if (_selection != null)
                                      Positioned.fromRect(
                                        rect: _selection!,
                                        child: IgnorePointer(
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 2,
                                              ),
                                              color: Colors.black26,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              if (_busy && editor != null) const LinearProgressIndicator(),
              if (_editing && editor != null)
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * 0.45,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: SegmentedButton<EvidenceEditTool>(
                            segments: const [
                              ButtonSegment(
                                value: EvidenceEditTool.crop,
                                icon: Icon(Icons.crop),
                                tooltip: 'Crop',
                              ),
                              ButtonSegment(
                                value: EvidenceEditTool.blur,
                                icon: Icon(Icons.blur_on),
                                tooltip: 'Blur',
                              ),
                              ButtonSegment(
                                value: EvidenceEditTool.redact,
                                icon: Icon(Icons.rectangle),
                                tooltip: 'Redact',
                              ),
                            ],
                            selected: {_tool},
                            onSelectionChanged: _busy
                                ? null
                                : (values) => setState(() {
                                    _tool = values.single;
                                    _before = false;
                                  }),
                          ),
                        ),
                        Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            IconButton(
                              tooltip: 'Undo',
                              icon: const Icon(Icons.undo),
                              onPressed: _busy || !editor.canUndo
                                  ? null
                                  : () => _run(editor.undo),
                            ),
                            IconButton(
                              tooltip: 'Reset',
                              icon: const Icon(Icons.restart_alt),
                              onPressed: _busy || !editor.hasEdits
                                  ? null
                                  : () => _run(editor.reset),
                            ),
                            IconButton(
                              tooltip: _before ? 'After' : 'Before',
                              icon: const Icon(Icons.compare),
                              onPressed: _busy
                                  ? null
                                  : () => setState(() => _before = !_before),
                            ),
                            FilledButton.icon(
                              icon: const Icon(Icons.check),
                              label: Text('Apply ${_tool.name}'),
                              onPressed: _busy || _before || _selection == null
                                  ? null
                                  : () => _run(() async {
                                      // Selection is measured in the fitted photo, not the surrounding letterbox.
                                      final area = _selection!;
                                      final viewport = _viewport;
                                      await editor.apply(
                                        _tool,
                                        Rect.fromLTRB(
                                          area.left *
                                              editor.image.width /
                                              viewport.width,
                                          area.top *
                                              editor.image.height /
                                              viewport.height,
                                          area.right *
                                              editor.image.width /
                                              viewport.width,
                                          area.bottom *
                                              editor.image.height /
                                              viewport.height,
                                        ),
                                      );
                                    }),
                            ),
                          ],
                        ),
                        ExpansionTile(
                          title: const Text('Selection bounds'),
                          children: [
                            for (final field in [
                              'Left',
                              'Top',
                              'Width',
                              'Height',
                            ])
                              Row(
                                children: [
                                  SizedBox(width: 64, child: Text(field)),
                                  Expanded(
                                    child: Slider(
                                      label: field,
                                      min: 0,
                                      max: field == 'Left' || field == 'Width'
                                          ? _viewport.width
                                          : _viewport.height,
                                      value: _boundValue(field).clamp(
                                        0,
                                        field == 'Left' || field == 'Width'
                                            ? _viewport.width
                                            : _viewport.height,
                                      ),
                                      onChanged: _busy || _before
                                          ? null
                                          : (value) =>
                                                _changeBound(field, value),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              if (!_editing && editor != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: FilledButton.icon(
                    key: const Key('evidence-confirm-photo'),
                    icon: const Icon(Icons.check),
                    label: const Text('Use photo'),
                    onPressed: _busy
                        ? null
                        : () => _run(() async {
                            final bytes = _accepted ?? await editor.export();
                            if (bytes.length > 10 * 1024 * 1024) {
                              throw StateError('Export exceeds upload limit');
                            }
                            if (context.mounted) Navigator.pop(context, bytes);
                          }),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Size _viewport = Size.zero;

  double _boundValue(String field) {
    final region =
        _selection ??
        Rect.fromLTWH(0, 0, _viewport.width / 2, _viewport.height / 2);
    return switch (field) {
      'Left' => region.left,
      'Top' => region.top,
      'Width' => region.width,
      _ => region.height,
    };
  }

  void _changeBound(String field, double value) {
    final region =
        _selection ??
        Rect.fromLTWH(0, 0, _viewport.width / 2, _viewport.height / 2);
    setState(
      () => _selection = Rect.fromLTWH(
        field == 'Left' ? value : region.left,
        field == 'Top' ? value : region.top,
        field == 'Width' ? value : region.width,
        field == 'Height' ? value : region.height,
      ).intersect(Offset.zero & _viewport),
    );
  }
}
