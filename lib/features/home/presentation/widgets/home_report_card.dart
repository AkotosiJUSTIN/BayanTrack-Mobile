import 'package:flutter/material.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/presentation/widgets/civic_components.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../reports/domain/entities/report.dart';
import '../../../reports/domain/entities/report_enums.dart';
import '../../../reports/presentation/report_labels.dart';
import '../../../reports/presentation/widgets/priority_badge.dart';

/// Compact report summary shared by Home and My Reports.
class HomeReportCard extends StatelessWidget {
  const HomeReportCard({
    super.key,
    required this.report,
    this.onTap,
    this.showCitizenReviewState = false,
  });

  final Report report;
  final VoidCallback? onTap;
  final bool showCitizenReviewState;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final title = report.title?.trim().isNotEmpty == true
        ? report.title!.trim()
        : report.description;
    final statusLabel = localizedReportStatus(report.status, l10n);
    final needsReview =
        showCitizenReviewState &&
        report.status == ReportStatus.resolved &&
        report.citizenVerifiedAt == null;

    return Semantics(
      button: onTap != null,
      label: '$title, $statusLabel',
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: CivicSurface(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLeading(context, title),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  localizedReportCategory(
                                    report.category,
                                    l10n,
                                    fallback: report.categoryDisplay,
                                  ),
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                CivicStatusChip(
                                  label: statusLabel,
                                  color: _statusColor(context),
                                  icon: _statusIcon,
                                ),
                              ],
                            ),
                            const SizedBox(height: 7),
                            Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (onTap != null) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ],
                  ),
                  if (report.displayPriorityLevel != null) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        PriorityBadge(
                          priorityLevel: report.displayPriorityLevel,
                          fontSize: 11,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                        ),
                        Text(
                          report.priorityIsAdvisory
                              ? l10n.aiSuggestion
                              : l10n.queuePriority,
                          style: theme.textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ],
                  if (report.incidentGroupId != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.link,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            l10n.sharedIncident,
                            style: theme.textTheme.labelSmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  _buildMetaRow(
                    context,
                    icon: Icons.location_on_outlined,
                    value: _locationLabel(l10n),
                    includeTime: true,
                  ),
                  if (_departmentLabel != null) ...[
                    const SizedBox(height: 6),
                    _buildMetaRow(
                      context,
                      icon: Icons.account_balance_outlined,
                      value: _departmentLabel!,
                      includeTime: false,
                    ),
                  ],
                  if (needsReview) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor(context).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.rate_review_outlined,
                            size: 18,
                            color: _statusColor(context),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.awaitingStaffConfirmation,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: _statusColor(context),
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 20,
                            color: _statusColor(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? get _departmentLabel {
    final value = report.assignedDepartment ?? report.departmentDisplay;
    return value?.trim().isNotEmpty == true ? value!.trim() : null;
  }

  String _locationLabel(AppLocalizations l10n) {
    final values = [
      report.barangay,
      report.zone,
      report.streetLandmark,
      report.cityMunicipality,
    ];
    final value = values
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .join(', ');
    return value.isEmpty ? l10n.unknownLocation : value;
  }

  Widget _buildLeading(BuildContext context, String title) {
    final scheme = Theme.of(context).colorScheme;
    final images = report.coreImages;
    final image = images.isEmpty ? null : images.first;
    if (image != null) {
      return Semantics(
        image: true,
        label: '${AppLocalizations.of(context).photos}: $title',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            ApiConstants.getImageUrl(image.url),
            width: 52,
            height: 52,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _buildIconBox(scheme),
          ),
        ),
      );
    }
    return _buildIconBox(scheme);
  }

  Widget _buildIconBox(ColorScheme scheme) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(_categoryIcon, color: scheme.onPrimaryContainer, size: 26),
    );
  }

  Widget _buildMetaRow(
    BuildContext context, {
    required IconData icon,
    required String value,
    required bool includeTime,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 17, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        if (includeTime) ...[
          const SizedBox(width: 8),
          Text(
            _formatTime(context),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  String _formatTime(BuildContext context) => localizedRelativeTime(
    context,
    report.createdAt,
    AppLocalizations.of(context),
  );

  Color _statusColor(BuildContext context) {
    return reportStatusForegroundColor(report.status, Theme.of(context));
  }

  IconData get _statusIcon => switch (report.status) {
    ReportStatus.submitted => Icons.schedule_outlined,
    ReportStatus.underReview ||
    ReportStatus.verified ||
    ReportStatus.assigned ||
    ReportStatus.escalated ||
    ReportStatus.endorsed => Icons.fact_check_outlined,
    ReportStatus.inProgress => Icons.engineering_outlined,
    ReportStatus.resolved => Icons.check_circle_outline,
    ReportStatus.closed => Icons.lock_outline,
    ReportStatus.rejected => Icons.cancel_outlined,
  };

  IconData get _categoryIcon => switch (report.category) {
    ReportCategory.engineeringInfrastructure => Icons.construction_outlined,
    ReportCategory.floodDisaster => Icons.water_damage_outlined,
    ReportCategory.wasteEnvironment => Icons.delete_outline,
    ReportCategory.publicSafety => Icons.shield_outlined,
    ReportCategory.publicUtilities => Icons.electrical_services_outlined,
    null => Icons.report_problem_outlined,
  };
}
