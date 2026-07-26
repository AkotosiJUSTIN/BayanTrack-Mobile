import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../data/evidence_upload_queue.dart';
import '../data/evidence_upload_queue_provider.dart';

class EvidenceUploadStatusBanner extends ConsumerWidget {
  const EvidenceUploadStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final userId = auth is AuthSuccess ? auth.user?.id : null;
    if (userId == null) return const SizedBox.shrink();

    return ref
        .watch(evidenceUploadQueueProvider)
        .maybeWhen(
          data: (queue) => ListenableBuilder(
            listenable: queue,
            builder: (context, _) => _Banner(queue: queue, userId: userId),
          ),
          orElse: () => const SizedBox.shrink(),
        );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.queue, required this.userId});

  final EvidenceUploadQueue queue;
  final String userId;

  @override
  Widget build(BuildContext context) {
    final intents = queue.state
        .where(
          (item) =>
              item.ownerUserId == userId &&
              item.state != EvidenceUploadState.dismissed,
        )
        .toList();
    final failed = intents
        .where(
          (item) =>
              item.state == EvidenceUploadState.failed ||
              item.state == EvidenceUploadState.missingLocalFile,
        )
        .toList();
    final pending = intents
        .where(
          (item) =>
              item.state == EvidenceUploadState.pending ||
              item.state == EvidenceUploadState.uploading ||
              item.state == EvidenceUploadState.retryWaiting,
        )
        .toList();
    final completed = intents
        .where((item) => item.state == EvidenceUploadState.completed)
        .toList();
    if (failed.isEmpty && pending.isEmpty && completed.isEmpty) {
      return const SizedBox.shrink();
    }

    final scheme = Theme.of(context).colorScheme;
    final hasMissing = failed.any(
      (item) => item.state == EvidenceUploadState.missingLocalFile,
    );
    final (icon, message, color) = failed.isNotEmpty
        ? (
            Icons.error_outline,
            hasMissing
                ? 'Report submitted. Evidence file is missing.'
                : 'Report submitted. Evidence upload failed.',
            scheme.errorContainer,
          )
        : pending.isNotEmpty
        ? (
            Icons.cloud_upload_outlined,
            'Report submitted. ${pending.length} evidence upload${pending.length == 1 ? '' : 's'} pending.',
            scheme.secondaryContainer,
          )
        : (
            Icons.cloud_done_outlined,
            'Evidence upload completed.',
            scheme.primaryContainer,
          );

    return Material(
      color: color,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
              if (failed.isNotEmpty)
                TextButton(onPressed: queue.retry, child: const Text('Retry')),
              if (failed.isNotEmpty || completed.isNotEmpty)
                TextButton(
                  onPressed: queue.dismissTerminal,
                  child: const Text('Dismiss'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
