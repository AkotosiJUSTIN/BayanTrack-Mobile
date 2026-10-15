import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/shared_incident.dart';
import '../report_detail_controller.dart';
import '../shared_incident_provider.dart';

class SharedIncidentSection extends ConsumerWidget {
  const SharedIncidentSection({super.key, required this.reportId});

  final String reportId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final incident = ref.watch(sharedIncidentProvider(reportId));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.link, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.sharedIncident,
                style: theme.textTheme.titleMedium,
              ),
            ),
            IconButton(
              tooltip: l10n.retry,
              onPressed: () {
                ref.invalidate(reportDetailControllerProvider(reportId));
                ref.invalidate(sharedIncidentProvider(reportId));
              },
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        incident.when(
          skipLoadingOnRefresh: false,
          loading: () => const LinearProgressIndicator(),
          error: (_, _) => Text(l10n.incidentLoadFailed),
          data: (data) => data == null
              ? Text(l10n.incidentMembershipChanged)
              : _summary(context, ref, data),
        ),
      ],
    );
  }

  Widget _summary(
    BuildContext context,
    WidgetRef ref,
    SharedIncident incident,
  ) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.confirmedLinkedReports(incident.reportCount)),
        const SizedBox(height: 8),
        Text(
          l10n.incidentOperationalStatus(_statusLabel(incident.status, l10n)),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (incident.assignedDepartment?.isNotEmpty == true)
          Text(incident.assignedDepartment!),
        if (incident.needsReview)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              l10n.incidentNeedsReview,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        const SizedBox(height: 8),
        Text(
          _integrityLabel(incident.integrityStatus, l10n),
          style: theme.textTheme.bodySmall,
        ),
        if (incident.transactionHash?.isNotEmpty == true)
          SelectableText(
            incident.transactionHash!,
            style: theme.textTheme.bodySmall,
          ),
        if (incident.updates.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(l10n.incidentProgress, style: theme.textTheme.titleSmall),
          for (final update in incident.updates)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(update.message),
                  if (update.createdAt != null)
                    Text(
                      DateFormat.yMMMd(
                        l10n.localeName,
                      ).add_jm().format(update.createdAt!.toLocal()),
                      style: theme.textTheme.bodySmall,
                    ),
                ],
              ),
            ),
        ],
        if (incident.evidence.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(l10n.incidentEvidence, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: incident.evidence.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final caption = incident.evidence[index].caption?.trim();
                final url = ApiConstants.getImageUrl(
                  incident.evidence[index].url,
                );
                return SizedBox(
                  width: 144,
                  child: Semantics(
                    button: true,
                    label: '${l10n.incidentEvidence} ${index + 1}',
                    child: InkWell(
                      onTap: () => showDialog<void>(
                        context: context,
                        builder: (context) => Dialog(
                          child: Stack(
                            children: [
                              AspectRatio(
                                aspectRatio: 1,
                                child: InteractiveViewer(
                                  child: Image.network(
                                    url,
                                    errorBuilder: (_, _, _) =>
                                        const Icon(Icons.broken_image_outlined),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: IconButton(
                                  tooltip: MaterialLocalizations.of(
                                    context,
                                  ).closeButtonTooltip,
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.close),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Image.network(
                              url,
                              width: 144,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const Center(
                                child: Icon(Icons.broken_image_outlined),
                              ),
                            ),
                          ),
                          if (caption?.isNotEmpty == true)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                caption!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall,
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
        ],
        if (incident.canReportMismatch) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () async {
              final submitted = await showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (_) => _MismatchDialog(
                  reportId: reportId,
                  groupId: incident.groupId,
                ),
              );
              if (submitted == true && ref.context.mounted) {
                ref.invalidate(sharedIncidentProvider(reportId));
              }
            },
            icon: const Icon(Icons.flag_outlined),
            label: Text(l10n.incidentDifferent),
          ),
        ],
      ],
    );
  }

  String _integrityLabel(String status, AppLocalizations l10n) =>
      switch (status) {
        'confirmed' => l10n.incidentIntegrityConfirmed,
        'pending' => l10n.incidentIntegrityPending,
        'failed' => l10n.incidentIntegrityFailed,
        _ => l10n.incidentIntegrityNotRecorded,
      };

  String _statusLabel(String status, AppLocalizations l10n) => switch (status) {
    'submitted' => l10n.submitted,
    'under_review' => l10n.underReview,
    'assigned' => l10n.incidentAssigned,
    'verified' => l10n.verified,
    'in_progress' => l10n.inProgress,
    'escalated' => l10n.escalated,
    'endorsed' => l10n.incidentEndorsed,
    'resolved' => l10n.resolvedStatus,
    'closed' => l10n.closed,
    'rejected' => l10n.rejected,
    _ => l10n.incidentStatusUnavailable,
  };
}

class _MismatchDialog extends ConsumerStatefulWidget {
  const _MismatchDialog({required this.reportId, required this.groupId});

  final String reportId;
  final String groupId;

  @override
  ConsumerState<_MismatchDialog> createState() => _MismatchDialogState();
}

class _MismatchDialogState extends ConsumerState<_MismatchDialog> {
  final _reason = TextEditingController();
  String? _lastReason;
  String? _idempotencyKey;
  bool _submitting = false;
  String? _error;
  bool _stale = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final reason = _reason.text.trim();
    final l10n = AppLocalizations.of(context);
    if (reason.isEmpty) {
      setState(() => _error = l10n.incidentReasonRequired);
      return;
    }
    if (_lastReason != reason) {
      _lastReason = reason;
      _idempotencyKey =
          'mobile-mismatch-${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(1 << 32)}';
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    final result = await ref
        .read(sharedIncidentRepositoryProvider)
        .reportMismatch(
          reportId: widget.reportId,
          groupId: widget.groupId,
          reason: reason,
          idempotencyKey: _idempotencyKey!,
        );
    if (!mounted) return;
    result.when(
      success: (_) => Navigator.pop(context, true),
      failure: (failure) {
        setState(() {
          _submitting = false;
          _stale = failure.statusCode == 409;
          _error = _stale
              ? l10n.incidentMembershipChanged
              : l10n.incidentFeedbackFailed;
        });
        if (_stale) {
          ref.invalidate(reportDetailControllerProvider(widget.reportId));
          ref.invalidate(sharedIncidentProvider(widget.reportId));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: !_submitting,
      child: AlertDialog(
        title: Text(l10n.incidentDifferent),
        content: SingleChildScrollView(
          child: TextField(
            controller: _reason,
            enabled: !_submitting && !_stale,
            minLines: 3,
            maxLines: 6,
            maxLength: 1000,
            decoration: InputDecoration(
              labelText: l10n.incidentReason,
              errorText: _error,
              errorMaxLines: 4,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _submitting ? null : () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton.icon(
            onPressed: _submitting || _stale ? null : _submit,
            icon: _submitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_outlined),
            label: Text(l10n.submit),
          ),
        ],
      ),
    );
  }
}
