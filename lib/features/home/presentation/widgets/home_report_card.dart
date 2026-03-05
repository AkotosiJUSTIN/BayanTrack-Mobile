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
        isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7), // Amber
        isDark ? const Color(0xFFFCD34D) : const Color(0xFFB45309),
        'Submitted',
      ),
      ReportStatus.underReview => (
        isDark ? const Color(0xFF581C87) : const Color(0xFFF3E8FF), // Violet
        isDark ? const Color(0xFFD8B4FE) : const Color(0xFF7C3AED),
        'Under Review',
      ),
      ReportStatus.inProgress => (
        isDark ? AppColors.inProgressBgDark : AppColors.inProgressBg,
        isDark ? AppColors.inProgressTextDark : AppColors.inProgressText,
        'In Progress',
      ),
      ReportStatus.escalated => (
        isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2), // Red
        isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626),
        'Escalated',
      ),
      ReportStatus.endorsed => (
        isDark ? const Color(0xFF164E63) : const Color(0xFFCFFAFE), // Cyan
        isDark ? const Color(0xFF67E8F9) : const Color(0xFF0891B2),
        'Endorsed',
      ),
      ReportStatus.resolved => (
        isDark ? AppColors.resolvedBgDark : AppColors.resolvedBg,
        isDark ? AppColors.resolvedTextDark : AppColors.resolvedText,
        'Resolved',
      ),
      ReportStatus.closed => (
        isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9), // Gray
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
        'Closed',
      ),
      ReportStatus.rejected => (
        isDark ? AppColors.rejectedBgDark : AppColors.rejectedBg,
        isDark ? AppColors.rejectedTextDark : AppColors.rejectedText,
        'Rejected',
      ),
      ReportStatus.verified => (
        isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5), // Emerald
        isDark ? const Color(0xFF6EE7B7) : const Color(0xFF059669),
        'Verified',
      ),
      ReportStatus.assigned => (
        isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE), // Light Blue
        isDark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB),
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
