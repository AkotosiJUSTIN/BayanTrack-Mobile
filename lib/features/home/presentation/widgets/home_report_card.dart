import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../reports/data/report_models.dart';

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
                        Text(
                          (report.category ?? 'UNCATEGORIZED').toUpperCase(),
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
      'submitted' => (
        isDark ? AppColors.pendingBgDark : AppColors.pendingBg,
        isDark ? AppColors.pendingTextDark : AppColors.pendingText,
        'Submitted',
      ),
      'under_review' => (
        isDark ? AppColors.pendingBgDark : AppColors.pendingBg,
        isDark ? AppColors.pendingTextDark : AppColors.pendingText,
        'Under Review',
      ),
      'in_progress' => (
        isDark ? AppColors.inProgressBgDark : AppColors.inProgressBg,
        isDark ? AppColors.inProgressTextDark : AppColors.inProgressText,
        'In Progress',
      ),
      'resolved' => (
        isDark ? AppColors.resolvedBgDark : AppColors.resolvedBg,
        isDark ? AppColors.resolvedTextDark : AppColors.resolvedText,
        'Resolved',
      ),
      'rejected' => (
        isDark ? AppColors.rejectedBgDark : AppColors.rejectedBg,
        isDark ? AppColors.rejectedTextDark : AppColors.rejectedText,
        'Rejected',
      ),
      'verified' => (
        isDark ? AppColors.inProgressBgDark : AppColors.inProgressBg,
        isDark ? AppColors.inProgressTextDark : AppColors.inProgressText,
        'Verified',
      ),
      'assigned' => (
        isDark ? AppColors.inProgressBgDark : AppColors.inProgressBg,
        isDark ? AppColors.inProgressTextDark : AppColors.inProgressText,
        'Assigned',
      ),
      _ => (
        isDark ? AppColors.pendingBgDark : AppColors.pendingBg,
        isDark ? AppColors.pendingTextDark : AppColors.pendingText,
        report.status.replaceAll('_', ' ').toUpperCase(),
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

  String _formatTimeAgo(String? dateStr) {
    if (dateStr == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateStr);
      return timeago.format(date);
    } catch (_) {
      return 'Unknown';
    }
  }

  Color _getCategoryColor(String? category) {
    final cat = (category ?? '').toUpperCase();
    return switch (cat) {
      'ROAD DAMAGE' || 'INFRASTRUCTURE' => AppColors.alertHigh,
      'ELECTRICAL' || 'UTILITIES' => AppColors.alertMedium,
      'GARBAGE' || 'SANITATION' => AppColors.alertLow,
      'FLOODING' || 'WATER' => AppColors.primary,
      _ => AppColors.primary,
    };
  }

  IconData _getCategoryIcon(String? category) {
    final cat = (category ?? '').toUpperCase();
    return switch (cat) {
      'ROAD DAMAGE' => Icons.warning_amber_rounded,
      'ELECTRICAL' || 'UTILITIES' => Icons.electrical_services,
      'GARBAGE' || 'SANITATION' => Icons.delete_outline,
      'FLOODING' || 'WATER' => Icons.water_damage_outlined,
      'INFRASTRUCTURE' => Icons.construction,
      _ => Icons.report_problem_outlined,
    };
  }
}
