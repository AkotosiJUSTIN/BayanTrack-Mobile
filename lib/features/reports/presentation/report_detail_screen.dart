import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/theme/app_colors.dart';
import '../../images/data/images_repository.dart';
import '../data/report_models.dart';
import '../data/reports_repository.dart';

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
  Report? _report;
  List<String> _imageUrls = [];
  bool _isLoading = true;
  String? _error;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _report = widget.initialReport;
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repo = ref.read(reportsRepositoryProvider);
      final report = await repo.getReport(widget.reportId);

      // Load images
      List<String> imageUrls = [];
      if (report.images.isNotEmpty) {
        imageUrls = report.images;
      } else {
        // Try to fetch from images endpoint
        try {
          final imagesRepo = ref.read(imagesRepositoryProvider);
          final images = await imagesRepo.getImagesForReport(widget.reportId);
          imageUrls = images.map((img) => img.imageUrl).toList();
        } catch (_) {
          // Ignore image loading errors
        }
      }

      setState(() {
        _report = report;
        _imageUrls = imageUrls;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with image carousel
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImageCarousel(isDark),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(48),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _error != null
                ? _buildErrorState(theme)
                : _buildReportContent(theme, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(bool isDark) {
    if (_imageUrls.isEmpty) {
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
          itemCount: _imageUrls.length,
          onPageChanged: (index) {
            setState(() => _currentImageIndex = index);
          },
          itemBuilder: (context, index) {
            return Image.network(
              _imageUrls[index],
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
        if (_imageUrls.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_imageUrls.length, (index) {
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

  Widget _buildErrorState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.alertHigh),
          const SizedBox(height: 16),
          Text('Failed to load report', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(_error!, style: theme.textTheme.bodySmall),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadReport, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildReportContent(ThemeData theme, bool isDark) {
    final report = _report!;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status and category row
          Row(
            children: [
              _buildStatusBadge(report.status),
              const SizedBox(width: 8),
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
                    report.category!,
                    style: theme.textTheme.labelSmall,
                  ),
                ),
              const Spacer(),
              if (report.createdAt != null)
                Text(
                  timeago.format(DateTime.parse(report.createdAt!)),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
            ],
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
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.lightSurfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.map_outlined,
                      size: 64,
                      color: isDark
                          ? AppColors.darkTextSecondary.withValues(alpha: 0.3)
                          : AppColors.lightTextSecondary.withValues(alpha: 0.3),
                    ),
                  ),
                  Center(
                    child: Icon(
                      Icons.location_on,
                      size: 36,
                      color: AppColors.alertHigh,
                    ),
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
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${report.latitude!.toStringAsFixed(6)}, ${report.longitude!.toStringAsFixed(6)}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // AI Analysis (if available)
          if (report.aiCategory != null || report.aiPriority != null) ...[
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
                  if (report.aiCategory != null)
                    _buildInfoRow('Category', report.aiCategory!, theme),
                  if (report.aiPriority != null)
                    _buildInfoRow(
                      'Priority',
                      _priorityLabel(report.aiPriority!),
                      theme,
                    ),
                  if (report.aiConfidence != null)
                    _buildInfoRow(
                      'Confidence',
                      '${(report.aiConfidence! * 100).toStringAsFixed(1)}%',
                      theme,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Barangay info
          if (report.barangay != null) ...[
            _buildInfoRow('Barangay', report.barangay!, theme),
            const SizedBox(height: 8),
          ],

          // Report ID
          _buildInfoRow('Report ID', report.id.substring(0, 8), theme),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ReportStatus status) {
    final (color, label) = switch (status) {
      ReportStatus.pending => (AppColors.alertMedium, 'Pending'),
      ReportStatus.inProgress => (AppColors.primary, 'In Progress'),
      ReportStatus.resolved => (AppColors.success, 'Resolved'),
      ReportStatus.closed => (AppColors.lightTextSecondary, 'Closed'),
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
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          Text(value, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  String _priorityLabel(int priority) {
    return switch (priority) {
      1 => 'Low',
      2 => 'Medium',
      3 => 'High',
      4 => 'Critical',
      _ => 'Unknown',
    };
  }
}
