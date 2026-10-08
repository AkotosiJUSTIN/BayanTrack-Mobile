import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/presentation/widgets/app_toast.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/evidence_upload_queue.dart';
import '../data/evidence_upload_queue_provider.dart';

/// Watches durable evidence uploads and turns lightweight state changes into
/// centralized transient feedback. No persistent layout banner is rendered.
class EvidenceUploadFeedback extends ConsumerStatefulWidget {
  const EvidenceUploadFeedback({super.key});

  @override
  ConsumerState<EvidenceUploadFeedback> createState() =>
      _EvidenceUploadFeedbackState();
}

class _EvidenceUploadFeedbackState
    extends ConsumerState<EvidenceUploadFeedback> {
  EvidenceUploadQueue? _queue;
  String? _userId;
  Map<String, EvidenceUploadState> _previousStates = const {};

  @override
  void dispose() {
    _queue?.removeListener(_onQueueChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final userId = auth is AuthSuccess ? auth.user?.id : null;
    final queue = ref.watch(evidenceUploadQueueProvider).asData?.value;
    _syncQueue(queue, userId);
    return const SizedBox.shrink();
  }

  void _syncQueue(EvidenceUploadQueue? queue, String? userId) {
    if (identical(_queue, queue) && _userId == userId) return;

    _queue?.removeListener(_onQueueChanged);
    _queue = queue;
    _userId = userId;
    _previousStates = queue == null || userId == null
        ? const {}
        : _snapshot(queue);
    if (queue != null && userId != null) {
      queue.addListener(_onQueueChanged);
      if (_previousStates.values.any(_isTerminalFailure)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _showFailureToast(
              queue,
              missing: _previousStates.values.contains(
                EvidenceUploadState.missingLocalFile,
              ),
            );
          }
        });
      }
    }
  }

  Map<String, EvidenceUploadState> _snapshot(EvidenceUploadQueue queue) => {
    for (final item in queue.state) item.id: item.state,
  };

  void _onQueueChanged() {
    final queue = _queue;
    if (!mounted || queue == null || _userId == null) return;

    final current = _snapshot(queue);
    final completed = current.entries.any(
      (entry) =>
          entry.value == EvidenceUploadState.completed &&
          _previousStates[entry.key] != EvidenceUploadState.completed,
    );
    final failed = current.entries.any(
      (entry) =>
          _isTerminalFailure(entry.value) &&
          _previousStates[entry.key] != entry.value,
    );
    final missing = current.entries.any(
      (entry) =>
          entry.value == EvidenceUploadState.missingLocalFile &&
          _previousStates[entry.key] != entry.value,
    );
    _previousStates = current;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      if (failed) {
        _showFailureToast(queue, missing: missing);
      } else if (completed) {
        AppToast.success(context, l10n.evidenceUploadCompleted);
      }
    });
  }

  void _showFailureToast(EvidenceUploadQueue queue, {required bool missing}) {
    final l10n = AppLocalizations.of(context);
    AppToast.error(
      context,
      missing ? l10n.evidenceFileMissing : l10n.evidenceUploadFailed,
      actionLabel: l10n.retry,
      onAction: () => unawaited(queue.retry()),
    );
  }

  bool _isTerminalFailure(EvidenceUploadState state) =>
      state == EvidenceUploadState.failed ||
      state == EvidenceUploadState.missingLocalFile;
}
