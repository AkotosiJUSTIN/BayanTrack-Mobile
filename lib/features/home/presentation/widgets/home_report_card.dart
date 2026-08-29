import 'package:flutter/material.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../reports/domain/entities/report.dart';
import '../../../reports/domain/entities/report_enums.dart';
import '../../../reports/presentation/widgets/priority_badge.dart';
import '../../../reports/presentation/report_labels.dart';

/// Report card widget for home screen matching the design mockup.
/// Shows thumbnail, category, title, location, time, and status badge.
class HomeReportCard extends StatelessWidget {
  final Report report;
  final VoidCallback? onTap;

  const HomeReportCard({super.key, required this.report, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final linkedReportCount = report.linkedReportCount;
    final l10n = AppLocalizations.of(context)!;
    final priorityAuthority = localizedPriorityAuthority(report, l10n);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceVariant
                      : AppColors.lightSurfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: report.coreImages.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          ApiConstants.getImageUrl(report.coreImages.first.url),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
                        ),
                      )
                    : _buildPlaceholderIcon(),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category and status
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            localizedReportCategory(
                              report.category,
                              l10n,
                            ).toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _getCategoryColor(report.category),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Spacer(),
                        _buildStatusBadge(context, isDark),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Always show the effective priority, including Unscored.
                    ...[
                      Row(
                        children: [
                          if (report.displayPriorityLevel != null)
                            PriorityBadge(
                              priorityLevel: report.displayPriorityLevel,
                              authorityLabel: priorityAuthority,
                              fontSize: 10,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                            )
                          else
                            Text(
                              l10n.unscored,
                              style: theme.textTheme.labelSmall,
                            ),
                          const SizedBox(width: 6),
                          Text(
                            priorityAuthority,
                            style: theme.textTheme.labelSmall,
                          ),
                          if (linkedReportCount > 1 &&
                              report.isIncidentRepresentative) ...[
                            const SizedBox(width: 6),
                            Text(
                              l10n.linkedReports(linkedReportCount),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],

                    // Title/Description
                    Text(
                      report.description,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Location and time
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            report.zone ?? l10n.unknownLocation,
                            style: theme.textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTimeAgo(context, report.createdAt),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Icon(
      _getCategoryIcon(report.category),
      size: 32,
      color: _getCategoryColor(report.category).withValues(alpha: 0.5),
    );
  }

  Widget _buildStatusBadge(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    final (bgColor, textColor, label) = switch (report.status) {
      ReportStatus.submitted => (
        isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7), // Amber
        isDark ? const Color(0xFFFCD34D) : const Color(0xFFB45309),
        l10n.submitted,
      ),
      ReportStatus.underReview => (
        isDark ? const Color(0xFF581C87) : const Color(0xFFF3E8FF), // Violet
        isDark ? const Color(0xFFD8B4FE) : const Color(0xFF7C3AED),
        l10n.underReview,
      ),
      ReportStatus.inProgress => (
        isDark ? AppColors.inProgressBgDark : AppColors.inProgressBg,
        isDark ? AppColors.inProgressTextDark : AppColors.inProgressText,
        l10n.inProgress,
      ),
      ReportStatus.escalated => (
        isDark ? const Color(0xFF581C87) : const Color(0xFFF3E8FF), // Violet
        isDark ? const Color(0xFFD8B4FE) : const Color(0xFF7C3AED),
        l10n.underReview,
      ),
      ReportStatus.endorsed => (
        isDark ? const Color(0xFF581C87) : const Color(0xFFF3E8FF), // Violet
        isDark ? const Color(0xFFD8B4FE) : const Color(0xFF7C3AED),
        l10n.underReview,
      ),
      ReportStatus.resolved => (
        isDark ? AppColors.resolvedBgDark : AppColors.resolvedBg,
        isDark ? AppColors.resolvedTextDark : AppColors.resolvedText,
        l10n.resolvedStatus,
      ),
      ReportStatus.closed => (
        isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9), // Gray
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
        l10n.closed,
      ),
      ReportStatus.rejected => (
        isDark ? AppColors.rejectedBgDark : AppColors.rejectedBg,
        isDark ? AppColors.rejectedTextDark : AppColors.rejectedText,
        l10n.rejected,
      ),
      ReportStatus.verified => (
        isDark ? const Color(0xFF581C87) : const Color(0xFFF3E8FF), // Violet
        isDark ? const Color(0xFFD8B4FE) : const Color(0xFF7C3AED),
        l10n.underReview,
      ),
      ReportStatus.assigned => (
        isDark ? const Color(0xFF581C87) : const Color(0xFFF3E8FF), // Violet
        isDark ? const Color(0xFFD8B4FE) : const Color(0xFF7C3AED),
        l10n.underReview,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  String _formatTimeAgo(BuildContext context, DateTime? date) {
    return localizedRelativeTime(context, date, AppLocalizations.of(context)!);
  }

  Color _getCategoryColor(ReportCategory? category) {
    return switch (category) {
      ReportCategory.engineeringInfrastructure => AppColors.alertHigh,
      ReportCategory.floodDisaster => AppColors.alertHigh,
      ReportCategory.wasteEnvironment => AppColors.alertLow,
      ReportCategory.publicSafety => AppColors.alertMedium,
      ReportCategory.publicUtilities => AppColors.alertMedium,
      null => AppColors.primary,
    };
  }

  IconData _getCategoryIcon(ReportCategory? category) {
    return switch (category) {
      ReportCategory.engineeringInfrastructure => Icons.construction_outlined,
      ReportCategory.floodDisaster => Icons.water_damage_outlined,
      ReportCategory.wasteEnvironment => Icons.delete_outline,
      ReportCategory.publicSafety => Icons.shield_outlined,
      ReportCategory.publicUtilities => Icons.electrical_services,
      null => Icons.report_problem_outlined,
    };
  }
}
