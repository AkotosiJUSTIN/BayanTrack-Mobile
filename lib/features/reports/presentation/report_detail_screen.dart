import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/presentation/profile_controller.dart';
import '../domain/entities/blockchain_verification.dart';
import '../domain/entities/report.dart';
import '../domain/entities/report_enums.dart';
import 'citizen_review_screen.dart';
import 'report_detail_controller.dart';
import 'widgets/priority_badge.dart';

/// Report Detail Screen showing full report with images and details
class ReportDetailScreen extends ConsumerStatefulWidget {
  final String reportId;
  final Report? initialReport;

  const ReportDetailScreen({
    super.key,
    required this.reportId,
    this.initialReport,
  });

  @override
  ConsumerState<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends ConsumerState<ReportDetailScreen> {
  int _currentImageIndex = 0;
  BlockchainVerificationResult? _verificationResult;
  bool _isVerifying = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Use the controller to fetch the report
    final reportAsync = ref.watch(
      reportDetailControllerProvider(widget.reportId),
    );

    return Scaffold(
      body: reportAsync.when(
        loading: () => CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildImagePlaceholder(isDark),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
        error: (error, stack) => CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildImagePlaceholder(isDark),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildErrorState(theme, error.toString()),
            ),
          ],
        ),
        data: (report) {
          final imageUrls = report.images
              .map((img) => ApiConstants.getImageUrl(img.url))
              .toList();

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildImageCarousel(isDark, imageUrls),
                ),
              ),
              SliverToBoxAdapter(
                child: _buildReportContent(theme, isDark, report),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImagePlaceholder(bool isDark) {
    return Container(
      color: isDark ? AppColors.darkSurface : AppColors.lightSurfaceVariant,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 64,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel(bool isDark, List<String> imageUrls) {
    if (imageUrls.isEmpty) {
      return Container(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurfaceVariant,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported_outlined,
                size: 64,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              const SizedBox(height: 8),
              Text(
                'No images',
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          itemCount: imageUrls.length,
          onPageChanged: (index) {
            setState(() => _currentImageIndex = index);
          },
          itemBuilder: (context, index) {
            return Image.network(
              imageUrls[index],
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: isDark
                    ? AppColors.darkSurface
                    : AppColors.lightSurfaceVariant,
                child: const Icon(Icons.broken_image, size: 64),
              ),
            );
          },
        ),
        // Page indicator
        if (imageUrls.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(imageUrls.length, (index) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentImageIndex
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorState(ThemeData theme, String error) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.alertHigh),
          const SizedBox(height: 16),
          Text('Unable to Load Report', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'We\'re having trouble loading this report. Please check your internet connection and try again.',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () =>
                ref.invalidate(reportDetailControllerProvider(widget.reportId)),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent(ThemeData theme, bool isDark, Report report) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status and category badges
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildStatusBadge(report.status),
              if (report.category != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.lightSurfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    report.category!.displayName,
                    style: theme.textTheme.labelSmall,
                  ),
                ),
              PriorityBadge(
                priorityLevel: report.priorityLevel,
                showScores: false, // Simplified view for citizens
              ),
              if (report.blockchainSynced)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        size: 14,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Verified',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Time
          if (report.createdAt != null)
            Text(
              timeago.format(report.createdAt!),
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          const SizedBox(height: 16),

          // Description
          Text(
            'Description',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(report.description, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 24),

          // Location
          if (report.latitude != null && report.longitude != null) ...[
            Text(
              'Location',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 200,
                child: Stack(
                  children: [
                    FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(
                          report.latitude!,
                          report.longitude!,
                        ),
                        initialZoom: 16,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.pinchZoom |
                              InteractiveFlag.drag,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName:
                              'com.example.bayantrack_mobile',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(
                                report.latitude!,
                                report.longitude!,
                              ),
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.location_on,
                                size: 40,
                                color: AppColors.alertHigh,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor
                              .withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${report.latitude?.toStringAsFixed(7)}, '
                          '${report.longitude?.toStringAsFixed(7)}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // AI Analysis (if available)
          if (report.category != null || report.priority != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryVariant.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: AppColors.primaryVariant),
                      const SizedBox(width: 8),
                      Text(
                        'AI Analysis',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (report.category != null)
                    _buildInfoRow(
                      'Category',
                      report.category!.displayName,
                      theme,
                    ),
                  if (report.categoryConfidence != null)
                    _buildInfoRow(
                      'Confidence',
                      '${(report.categoryConfidence! * 100).toStringAsFixed(1)}%',
                      theme,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Zone info
          if (report.zone != null) ...[
            _buildInfoRow('Zone', report.zone!, theme),
            const SizedBox(height: 8),
          ],

          // Report ID
          _buildInfoRow('Report ID', report.id.substring(0, 8), theme),
          const SizedBox(height: 24),

          // Citizen resolution review banner (shown only to the report owner
          // when the report has been resolved by barangay staff)
          _buildCitizenReviewBanner(theme, isDark, report),

          // Blockchain Verification Section
          _buildBlockchainSection(theme, isDark, report),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// Shows a prominent call-to-action banner to the report owner when the
  /// barangay has marked the report as resolved and the citizen hasn't yet
  /// submitted their review.
  Widget _buildCitizenReviewBanner(
    ThemeData theme,
    bool isDark,
    Report report,
  ) {
    if (report.status != ReportStatus.resolved) return const SizedBox.shrink();

    // Only show to the report owner
    final profileAsync = ref.watch(profileControllerProvider);
    final currentUserId = profileAsync.asData?.value.id;
    if (currentUserId == null || currentUserId != report.userId) {
      return const SizedBox.shrink();
    }

    // --- Already reviewed: show a compact confirmation chip ---
    if (report.citizenVerifiedAt != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.success.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.verified_rounded, color: AppColors.success, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'You have already submitted your review. Thank you!',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // --- Pending review: show the CTA ---
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.success.withValues(alpha: 0.15),
              AppColors.success.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.success.withValues(alpha: 0.4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.task_alt_rounded, color: AppColors.success),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your report has been resolved!',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'The barangay has addressed your report. '
              'Please review their action and confirm whether the issue '
              'was properly resolved.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  final acted = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => CitizenReviewScreen(report: report),
                    ),
                  );
                  // Refresh report after review is submitted
                  if (acted == true && mounted) {
                    ref.invalidate(
                      reportDetailControllerProvider(report.id),
                    );
                  }
                },
                icon: const Icon(Icons.rate_review_outlined),
                label: const Text('Review & Sign Off'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.success,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockchainSection(ThemeData theme, bool isDark, Report report) {    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_tree_outlined,
                size: 20,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Blockchain Verification',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_isVerifying)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                TextButton.icon(
                  onPressed: _isVerifying
                      ? null
                      : () => _handleVerification(report.id),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Verify Integrity'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    textStyle: theme.textTheme.labelMedium,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_verificationResult != null) ...[
            _buildVerificationStatus(theme),
            const Divider(height: 24),
            Text(
              'Audit History',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (_verificationResult!.auditHistory.isEmpty)
              Text('No audit entries found.', style: theme.textTheme.bodySmall)
            else
              ..._verificationResult!.auditHistory.map(
                (entry) => _buildAuditEntry(theme, entry, isDark),
              ),
          ] else if (report.blockchainSynced)
            Text(
              'This report is anchored on the blockchain. Click verify to perform a live integrity check.',
              style: theme.textTheme.bodySmall,
            )
          else
            Text(
              'This report is pending blockchain synchronization.',
              style: theme.textTheme.bodySmall,
            ),
        ],
      ),
    );
  }

  Widget _buildVerificationStatus(ThemeData theme) {
    final result = _verificationResult!;

    // `verified` = content hash intact. `statusVerified` = on-chain status enum
    // matches the local DB status. The contract only stores status=Submitted at
    // anchoring time and never updates it, so statusVerified will always be false
    // once staff take any action. This is expected and NOT a breach — surface it
    // as a separate informational note, not as a red "Integrity Breach".
    final isHealthy = result.verified; // content integrity only

    // Determine the display state
    final isNotFound = result.notFoundOnChain;
    final isConnectionError = result.connectionError;
    final isNotAnchored = !result.isAnchored;
    final isNeutral = isNotFound || isConnectionError || isNotAnchored;
    // Status is out of sync with blockchain (expected after staff actions)
    final isStatusPending = result.verified && !result.statusVerified;

    final Color statusColor;
    final IconData statusIcon;
    final String title;

    if (isHealthy && !isStatusPending) {
      statusColor = AppColors.success;
      statusIcon = Icons.check_circle;
      title = 'Integrity Verified';
    } else if (isStatusPending) {
      // Content is intact; only the on-chain status enum lags behind
      statusColor = AppColors.alertMedium;
      statusIcon = Icons.sync_rounded;
      title = 'Content Verified';
    } else if (isNotAnchored) {
      statusColor = AppColors.alertMedium;
      statusIcon = Icons.hourglass_empty;
      title = 'Not Yet Anchored';
    } else if (isNotFound) {
      statusColor = AppColors.alertMedium;
      statusIcon = Icons.search_off;
      title = 'Record Not Found';
    } else if (isConnectionError) {
      statusColor = AppColors.alertMedium;
      statusIcon = Icons.cloud_off;
      title = 'Blockchain Unavailable';
    } else {
      statusColor = AppColors.alertHigh;
      statusIcon = Icons.warning;
      title = 'Integrity Breach Detected';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isNeutral ? AppColors.alertMedium : statusColor).withValues(
          alpha: 0.1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  result.message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditEntry(
    ThemeData theme,
    BlockchainAuditEntry entry,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
              ),
              Container(
                width: 1,
                height: 30,
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getActionLabel(entry.actionType),
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat('MMM dd, HH:mm').format(
                        DateTime.fromMillisecondsSinceEpoch(
                          entry.timestamp * 1000,
                        ),
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                Text(
                  'By ${entry.actor.substring(0, 6)}...${entry.actor.substring(entry.actor.length - 4)}',
                  style: theme.textTheme.bodySmall,
                ),
                if (entry.oldStatus != entry.newStatus)
                  Text(
                    'Status: ${entry.oldStatus} → ${entry.newStatus}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getActionLabel(int type) {
    return switch (type) {
      0 => 'Created',
      1 => 'Status Updated',
      2 => 'Metadata Updated',
      _ => 'Unknown Action',
    };
  }

  Future<void> _handleVerification(String reportId) async {
    setState(() => _isVerifying = true);

    final controller = ref.read(
      reportDetailControllerProvider(reportId).notifier,
    );
    final result = await controller.verifyReport();

    if (mounted) {
      setState(() {
        _verificationResult = result;
        _isVerifying = false;
      });

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification failed. Please try again later.'),
          ),
        );
      }
    }
  }

  Widget _buildStatusBadge(ReportStatus status) {
    final (color, label) = switch (status) {
      ReportStatus.submitted => (const Color(0xFFF59E0B), 'Submitted'), // Amber
      ReportStatus.underReview => (const Color(0xFF8B5CF6), 'Under Review'), // Violet
      ReportStatus.inProgress => (const Color(0xFF2563EB), 'In Progress'), // Blue
      ReportStatus.escalated => (const Color(0xFFDC2626), 'Escalated'), // Red
      ReportStatus.endorsed => (const Color(0xFF06B6D4), 'Endorsed'), // Cyan
      ReportStatus.resolved => (const Color(0xFF22C55E), 'Resolved'), // Green
      ReportStatus.closed => (const Color(0xFF64748B), 'Closed'), // Gray
      ReportStatus.rejected => (const Color(0xFFEF4444), 'Rejected'), // Light Red
      ReportStatus.verified => (const Color(0xFF10B981), 'Verified'), // Emerald
      ReportStatus.assigned => (const Color(0xFF3B82F6), 'Assigned'), // Light Blue
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
