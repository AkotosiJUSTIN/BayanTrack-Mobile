import 'package:flutter/material.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/reports/domain/entities/report_enums.dart';

/// Data model for report card display
class ReportData {
  final String id;
  final String category;
  final String title;
  final String location;
  final String timeAgo;
  final ReportStatus status;
  final String? imageUrl;

  const ReportData({
    required this.id,
    required this.category,
    required this.title,
    required this.location,
    required this.timeAgo,
    required this.status,
    this.imageUrl,
  });
}

/// Report card widget matching the design mockup.
/// Shows thumbnail, category, title, location, time, and status badge.
class ReportCard extends StatelessWidget {
  final ReportData report;
  final VoidCallback? onTap;

  const ReportCard({super.key, required this.report, this.onTap});

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
                child: report.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          ApiConstants.getImageUrl(report.imageUrl!),
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
                        Text(
                          report.category,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getCategoryColor(report.category),
                          ),
                        ),
                        const Spacer(),
                        _buildStatusBadge(isDark),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Title
                    Text(
                      report.title,
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
                            report.location,
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
                        Text(report.timeAgo, style: theme.textTheme.bodySmall),
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
      ReportStatus.escalated => (
        isDark ? AppColors.pendingBgDark : AppColors.pendingBg,
        isDark ? AppColors.pendingTextDark : AppColors.pendingText,
        'Under Review',
      ),
      ReportStatus.endorsed => (
        isDark ? AppColors.pendingBgDark : AppColors.pendingBg,
        isDark ? AppColors.pendingTextDark : AppColors.pendingText,
        'Under Review',
      ),
      ReportStatus.resolved => (
        isDark ? AppColors.resolvedBgDark : AppColors.resolvedBg,
        isDark ? AppColors.resolvedTextDark : AppColors.resolvedText,
        'Resolved',
      ),
      ReportStatus.closed => (
        isDark ? AppColors.resolvedBgDark : AppColors.resolvedBg,
        isDark ? AppColors.resolvedTextDark : AppColors.resolvedText,
        'Closed',
      ),
      ReportStatus.rejected => (
        isDark ? AppColors.rejectedBgDark : AppColors.rejectedBg,
        isDark ? AppColors.rejectedTextDark : AppColors.rejectedText,
        'Rejected',
      ),
      ReportStatus.verified => (
        isDark ? AppColors.pendingBgDark : AppColors.pendingBg,
        isDark ? AppColors.pendingTextDark : AppColors.pendingText,
        'Under Review',
      ),
      ReportStatus.assigned => (
        isDark ? AppColors.pendingBgDark : AppColors.pendingBg,
        isDark ? AppColors.pendingTextDark : AppColors.pendingText,
        'Under Review',
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

  Color _getCategoryColor(String category) {
    return switch (category.toUpperCase()) {
      'ROAD DAMAGE' => AppColors.alertHigh,
      'ELECTRICAL' => AppColors.alertMedium,
      'GARBAGE' => AppColors.alertLow,
      'FLOODING' => AppColors.primary,
      'INFRASTRUCTURE' => AppColors.accent,
      _ => AppColors.primary,
    };
  }

  IconData _getCategoryIcon(String category) {
    return switch (category.toUpperCase()) {
      'ROAD DAMAGE' => Icons.warning_amber_rounded,
      'ELECTRICAL' => Icons.electrical_services,
      'GARBAGE' => Icons.delete_outline,
      'FLOODING' => Icons.water_damage_outlined,
      'INFRASTRUCTURE' => Icons.construction,
      _ => Icons.report_problem_outlined,
    };
  }
}
