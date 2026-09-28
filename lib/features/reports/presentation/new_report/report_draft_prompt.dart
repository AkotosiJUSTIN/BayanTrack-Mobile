import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/report_draft_store.dart';

enum ReportDraftAction { resume, discard, startNew }

Future<ReportDraftAction?> showReportDraftPrompt(
  BuildContext context, {
  required ReportDraft draft,
}) async {
  final l10n = AppLocalizations.of(context);
  final sheetHeight = MediaQuery.sizeOf(context).height * 0.85;
  final action = await showModalBottomSheet<ReportDraftAction>(
    context: context,
    isDismissible: false,
    enableDrag: false,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: sheetHeight),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.reportDraftFoundTitle,
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.reportDraftFoundMessage(_typeName(l10n, draft.type)),
                style: Theme.of(sheetContext).textTheme.bodyMedium,
              ),
              if (draft.type == ReportDraftType.emergency) ...[
                const SizedBox(height: 12),
                Text(
                  l10n.emergencyNotYetTransmitted,
                  key: const Key('emergency-draft-not-transmitted'),
                  style: Theme.of(sheetContext).textTheme.titleSmall?.copyWith(
                    color: Theme.of(sheetContext).colorScheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () =>
                    Navigator.pop(sheetContext, ReportDraftAction.resume),
                icon: const Icon(Icons.edit_outlined),
                label: Text(l10n.resumeDraft),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () =>
                    Navigator.pop(sheetContext, ReportDraftAction.startNew),
                icon: const Icon(Icons.note_add_outlined),
                label: Text(l10n.startNewReport),
              ),
              TextButton.icon(
                onPressed: () =>
                    Navigator.pop(sheetContext, ReportDraftAction.discard),
                icon: const Icon(Icons.delete_outline),
                label: Text(l10n.discardDraft),
              ),
              TextButton(
                onPressed: () => Navigator.pop(sheetContext),
                child: Text(l10n.notNow),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  if (action == null || action == ReportDraftAction.resume) return action;
  if (!context.mounted) return null;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.discardDraftConfirmationTitle),
      content: Text(
        action == ReportDraftAction.startNew
            ? l10n.replaceDraftConfirmationMessage
            : l10n.discardDraftConfirmationMessage,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(l10n.keepDraft),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(l10n.discardDraft),
        ),
      ],
    ),
  );
  return confirmed == true ? action : null;
}

String _typeName(AppLocalizations l10n, ReportDraftType type) => switch (type) {
  ReportDraftType.full => l10n.fullReport,
  ReportDraftType.quick => l10n.quickReport,
  ReportDraftType.emergency => l10n.emergencyReport,
};
