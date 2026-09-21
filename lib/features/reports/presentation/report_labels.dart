import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/entities/report.dart';
import '../domain/entities/report_enums.dart';

String localizedReportCategory(
  ReportCategory? category,
  AppLocalizations l10n, {
  String? fallback,
}) => switch (category) {
  ReportCategory.engineeringInfrastructure =>
    l10n.categoryEngineeringInfrastructure,
  ReportCategory.floodDisaster => l10n.categoryFloodDisaster,
  ReportCategory.wasteEnvironment => l10n.categoryWasteEnvironment,
  ReportCategory.publicSafety => l10n.categoryPublicSafety,
  ReportCategory.publicUtilities => l10n.categoryPublicUtilities,
  null => fallback ?? l10n.uncategorized,
};

String localizedReportStatus(ReportStatus status, AppLocalizations l10n) =>
    switch (status) {
      ReportStatus.submitted => l10n.submitted,
      ReportStatus.underReview ||
      ReportStatus.verified ||
      ReportStatus.assigned ||
      ReportStatus.escalated ||
      ReportStatus.endorsed => l10n.underReview,
      ReportStatus.inProgress => l10n.inProgress,
      ReportStatus.resolved => l10n.resolvedStatus,
      ReportStatus.closed => l10n.closed,
      ReportStatus.rejected => l10n.rejected,
    };

String localizedPriorityLabel(PriorityLevel level, AppLocalizations l10n) =>
    switch (level) {
      PriorityLevel.critical => l10n.priorityCritical,
      PriorityLevel.high => l10n.priorityHigh,
      PriorityLevel.medium => l10n.medium,
      PriorityLevel.low => l10n.priorityLow,
      PriorityLevel.veryLow => l10n.priorityVeryLow,
    };

String localizedPriorityAuthority(Report report, AppLocalizations l10n) {
  if (report.queuePriorityLevel != null) return l10n.queuePriority;
  if (report.displayPriorityLevel != null) return l10n.aiSuggestion;
  return l10n.aiSuggestionPending;
}

enum _ReportStatusColorGroup { pending, progress, urgent, success }

_ReportStatusColorGroup _reportStatusColorGroup(ReportStatus status) =>
    switch (status) {
      ReportStatus.submitted ||
      ReportStatus.underReview ||
      ReportStatus.verified ||
      ReportStatus.assigned => _ReportStatusColorGroup.pending,
      ReportStatus.inProgress => _ReportStatusColorGroup.progress,
      ReportStatus.escalated ||
      ReportStatus.endorsed ||
      ReportStatus.rejected => _ReportStatusColorGroup.urgent,
      ReportStatus.resolved ||
      ReportStatus.closed => _ReportStatusColorGroup.success,
    };

Color reportStatusIndicatorColor(ReportStatus status) =>
    switch (_reportStatusColorGroup(status)) {
      _ReportStatusColorGroup.pending => AppColors.alertMedium,
      _ReportStatusColorGroup.progress => AppColors.primaryLight,
      _ReportStatusColorGroup.urgent => AppColors.alertHigh,
      _ReportStatusColorGroup.success => AppColors.success,
    };

Color reportMapStatusColor(ReportStatus status) =>
    reportStatusIndicatorColor(status);

Color reportStatusForegroundColor(ReportStatus status, ThemeData theme) {
  final isDark = theme.brightness == Brightness.dark;
  return switch (_reportStatusColorGroup(status)) {
    _ReportStatusColorGroup.pending =>
      isDark ? AppColors.pendingTextDark : AppColors.pendingText,
    _ReportStatusColorGroup.progress => theme.colorScheme.primary,
    _ReportStatusColorGroup.urgent =>
      isDark ? AppColors.rejectedTextDark : AppColors.rejectedText,
    _ReportStatusColorGroup.success =>
      isDark ? AppColors.resolvedTextDark : AppColors.resolvedText,
  };
}

String localizedRelativeTime(
  BuildContext context,
  DateTime? date,
  AppLocalizations l10n,
) {
  if (date == null) return l10n.unknownTime;

  final difference = DateTime.now().difference(date);
  if (difference.isNegative || difference.inMinutes < 1) return l10n.justNow;
  if (difference.inHours < 1) return l10n.minutesAgo(difference.inMinutes);
  if (difference.inDays < 1) return l10n.hoursAgo(difference.inHours);
  if (difference.inDays < 7) return l10n.daysAgo(difference.inDays);
  return MaterialLocalizations.of(context).formatMediumDate(date);
}
