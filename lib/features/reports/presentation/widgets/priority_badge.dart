import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/report_enums.dart';

/// Priority badge widget displaying priority level with color coding
class PriorityBadge extends StatelessWidget {
  final PriorityLevel? priorityLevel;
  final int? priorityRank;
  final bool showRank;
  final String? authorityLabel;
  final double fontSize;
  final EdgeInsets padding;

  const PriorityBadge({
    super.key,
    required this.priorityLevel,
    this.priorityRank,
    this.showRank = false,
    this.authorityLabel,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    if (priorityLevel == null) {
      return const SizedBox.shrink();
    }

    final colors = _getPriorityColors(context, priorityLevel!);
    final rank = priorityRank ?? 0;
    final l10n = AppLocalizations.of(context);

    final label = _priorityLabel(priorityLevel!, l10n);

    return Semantics(
      container: true,
      label: '${authorityLabel ?? l10n.operationalPriority}: $label',
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getPriorityIcon(priorityLevel!),
              size: fontSize + 2,
              color: colors.text,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: colors.text,
              ),
            ),
            if (showRank && rank >= 1 && rank <= 5) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: colors.text.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$rank / 5',
                  style: TextStyle(
                    fontSize: fontSize - 1,
                    fontWeight: FontWeight.w600,
                    color: colors.text,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _priorityLabel(PriorityLevel level, AppLocalizations l10n) =>
      switch (level) {
        PriorityLevel.critical => l10n.priorityCritical,
        PriorityLevel.high => l10n.priorityHigh,
        PriorityLevel.medium => l10n.medium,
        PriorityLevel.low => l10n.priorityLow,
        PriorityLevel.veryLow => l10n.priorityVeryLow,
      };

  IconData _getPriorityIcon(PriorityLevel level) {
    return switch (level) {
      PriorityLevel.critical => Icons.error,
      PriorityLevel.high => Icons.warning,
      PriorityLevel.medium => Icons.info_outline,
      PriorityLevel.low => Icons.check_circle_outline,
      PriorityLevel.veryLow => Icons.remove_circle_outline,
    };
  }

  _PriorityColors _getPriorityColors(
    BuildContext context,
    PriorityLevel level,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return switch (level) {
      PriorityLevel.critical => _PriorityColors(
        background: colorScheme.errorContainer,
        text: colorScheme.onErrorContainer,
      ),
      PriorityLevel.high => _PriorityColors(
        background: AppColors.alertMedium.withValues(alpha: 0.16),
        text: theme.brightness == Brightness.dark
            ? AppColors.pendingTextDark
            : AppColors.pendingText,
      ),
      PriorityLevel.medium => _PriorityColors(
        background: colorScheme.tertiaryContainer,
        text: colorScheme.onTertiaryContainer,
      ),
      PriorityLevel.low => _PriorityColors(
        background: colorScheme.secondaryContainer,
        text: colorScheme.onSecondaryContainer,
      ),
      PriorityLevel.veryLow => _PriorityColors(
        background: colorScheme.primaryContainer,
        text: colorScheme.onPrimaryContainer,
      ),
    };
  }
}

class _PriorityColors {
  final Color background;
  final Color text;

  _PriorityColors({required this.background, required this.text});
}

/// Priority reasons expandable widget
class PriorityReasons extends StatefulWidget {
  final List<String> reasons;

  const PriorityReasons({super.key, required this.reasons});

  @override
  State<PriorityReasons> createState() => _PriorityReasonsState();
}

class _PriorityReasonsState extends State<PriorityReasons> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.reasons.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    Icons.priority_high,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.priorityAnalysis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reasons list
                  Text(
                    l10n.reasons,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...widget.reasons.map(
                    (reason) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontSize: 16)),
                          Expanded(
                            child: Text(
                              reason,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
