import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../reports/domain/entities/report.dart';
import '../../../reports/domain/entities/report_enums.dart';
import '../../../reports/presentation/widgets/priority_badge.dart';

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
                child: report.images.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          ApiConstants.getImageUrl(report.images.first.url),
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
                            (report.category?.displayName ?? 'UNCATEGORIZED').toUpperCase(),
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
                        _buildStatusBadge(isDark),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // Priority badge (if available)
                    if (report.priorityLevel != null) ...[
                      PriorityBadge(
                        priorityLevel: report.priorityLevel,
                        fontSize: 10,
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
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
                            report.zone ?? 'Unknown location',
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
                          _formatTimeAgo(report.createdAt),
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

  Widget _buildStatusBadge(bool isDark) {
    final (bgColor, textColor, label) = switch (report.status) {
      ReportStatus.submitted => (
        isDark ? AppColors.pendingBgDark : AppColors.pendingBg,
        isDark ? AppColors.pendingTextDark : AppColors.pendingText,
        'Submitted',
      ),
      ReportStatus.underReview => (
        isDark ? AppColors.pendingBgDark : AppColors.pendingBg,
        isDark ? AppColors.pendingTextDark : AppColors.pendingText,
        'Under Review',
      ),
      ReportStatus.inProgress => (
        isDark ? AppColors.inProgressBgDark : AppColors.inProgressBg,
        isDark ? AppColors.inProgressTextDark : AppColors.inProgressText,
        'In Progress',
      ),
      ReportStatus.resolved => (
        isDark ? AppColors.resolvedBgDark : AppColors.resolvedBg,
        isDark ? AppColors.resolvedTextDark : AppColors.resolvedText,
        'Resolved',
      ),
      ReportStatus.rejected => (
        isDark ? AppColors.rejectedBgDark : AppColors.rejectedBg,
        isDark ? AppColors.rejectedTextDark : AppColors.rejectedText,
        'Rejected',
      ),
      ReportStatus.verified => (
        isDark ? AppColors.inProgressBgDark : AppColors.inProgressBg,
        isDark ? AppColors.inProgressTextDark : AppColors.inProgressText,
        'Verified',
      ),
      ReportStatus.assigned => (
        isDark ? AppColors.inProgressBgDark : AppColors.inProgressBg,
        isDark ? AppColors.inProgressTextDark : AppColors.inProgressText,
        'Assigned',
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

  String _formatTimeAgo(DateTime? date) {
    if (date == null) return 'Unknown';
    return timeago.format(date);
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
