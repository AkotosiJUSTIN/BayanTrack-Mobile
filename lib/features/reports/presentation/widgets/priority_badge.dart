import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/report_enums.dart';

/// Priority badge widget displaying priority level with color coding
class PriorityBadge extends StatelessWidget {
  final PriorityLevel? priorityLevel;
  final int? priorityScore;
  final bool showScores;
  final double fontSize;
  final EdgeInsets padding;

  const PriorityBadge({
    super.key,
    required this.priorityLevel,
    this.priorityScore,
    this.showScores = false,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    if (priorityLevel == null) {
      return const SizedBox.shrink();
    }

    final colors = _getPriorityColors(priorityLevel!);
    final score = priorityScore ?? 0;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border, width: 1),
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
            _priorityLabel(priorityLevel!, l10n).toUpperCase(),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: colors.text,
              letterSpacing: 0.5,
            ),
          ),
          if (showScores && score > 0) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: colors.text.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                score.toString(),
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

  _PriorityColors _getPriorityColors(PriorityLevel level) {
    return switch (level) {
      PriorityLevel.critical => _PriorityColors(
          background: const Color(0xFFFFEBEE),
          border: const Color(0xFFEF5350),
          text: const Color(0xFFC62828),
        ),
      PriorityLevel.high => _PriorityColors(
          background: const Color(0xFFFFF3E0),
          border: const Color(0xFFFF9800),
          text: const Color(0xFFE65100),
        ),
      PriorityLevel.medium => _PriorityColors(
          background: const Color(0xFFFFF8E1),
          border: const Color(0xFFFFB300),
          text: const Color(0xFFF57F17),
        ),
      PriorityLevel.low => _PriorityColors(
          background: const Color(0xFFE8F5E9),
          border: const Color(0xFF66BB6A),
          text: const Color(0xFF2E7D32),
        ),
      PriorityLevel.veryLow => _PriorityColors(
          background: const Color(0xFFE3F2FD),
          border: const Color(0xFF42A5F5),
          text: const Color(0xFF1565C0),
        ),
    };
  }
}

class _PriorityColors {
  final Color background;
  final Color border;
  final Color text;

  _PriorityColors({
    required this.background,
    required this.border,
    required this.text,
  });
}

/// Priority reasons expandable widget
class PriorityReasons extends StatefulWidget {
  final List<String> reasons;
  final int? baseScore;
  final int? hotspotScore;

  const PriorityReasons({
    super.key,
    required this.reasons,
    this.baseScore,
    this.hotspotScore,
  });

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
    final totalScore = (widget.baseScore ?? 0) + (widget.hotspotScore ?? 0);

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
                  if (totalScore > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        l10n.score(totalScore),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onPrimaryContainer,
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
                  // Score breakdown
                  if (widget.baseScore != null || widget.hotspotScore != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          if (widget.baseScore != null) ...[
                            Text(
                              l10n.baseScore(widget.baseScore!),
                              style: theme.textTheme.bodySmall,
                            ),
                            if (widget.hotspotScore != null)
                              Text(
                                ' + ',
                                style: theme.textTheme.bodySmall,
                              ),
                          ],
                          if (widget.hotspotScore != null)
                            Text(
                              l10n.hotspotScore(widget.hotspotScore!),
                              style: theme.textTheme.bodySmall,
                            ),
                          Text(
                            ' = $totalScore',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  
                  // Reasons list
                  Text(
                    l10n.reasons,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...widget.reasons.map((reason) => Padding(
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
                      )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
