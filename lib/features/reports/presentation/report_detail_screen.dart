import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/presentation/widgets/app_toast.dart';
import '../../../core/presentation/widgets/civic_components.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/maps/municipality_map.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/presentation/barangays_provider.dart';
import '../domain/entities/blockchain_verification.dart';
import '../domain/entities/report.dart';
import '../domain/entities/report_enums.dart';
import '../domain/entities/report_image.dart';
import 'citizen_review_screen.dart';
import 'report_detail_controller.dart';
import 'widgets/priority_badge.dart';
import 'report_labels.dart';

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
  final MapController _locationMapController = MapController();
  int _currentImageIndex = 0;
  BlockchainVerificationResult? _verificationResult;
  bool _isVerifying = false;

  @override
  void dispose() {
    _locationMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

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
              title: Text(l10n.reportDetails),
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
              title: Text(l10n.reportDetails),
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
          final imageUrls = report.coreImages
              .map((img) => ApiConstants.getImageUrl(img.url))
              .toList();

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                title: Text(l10n.reportDetails),
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
    final theme = Theme.of(context);
    return Container(
      color: isDark ? AppColors.darkSurface : AppColors.lightSurfaceVariant,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel(bool isDark, List<String> imageUrls) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
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
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).noImages,
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
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
              semanticLabel: '${l10n.reportDetails} ${index + 1}',
              errorBuilder: (_, _, _) => Container(
                color: isDark
                    ? AppColors.darkSurface
                    : AppColors.lightSurfaceVariant,
                child: Icon(
                  Icons.broken_image,
                  size: 64,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
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
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.alertHigh),
          const SizedBox(height: 16),
          Text(l10n.unableLoadReports, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            l10n.reportsNetworkError,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () =>
                ref.invalidate(reportDetailControllerProvider(widget.reportId)),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent(ThemeData theme, bool isDark, Report report) {
    final l10n = AppLocalizations.of(context);
    final successColor = theme.brightness == Brightness.dark
        ? AppColors.resolvedTextDark
        : AppColors.resolvedText;
    final municipalities = ref.watch(municipalitiesProvider).asData?.value;
    final municipality =
        findMunicipalityMetadata(
          municipalities ?? const [bundledUrdanetaMunicipality],
          report.municipalityId,
        ) ??
        (report.municipalityId == defaultMunicipalityId
            ? bundledUrdanetaMunicipality
            : null);
    final linkedReportCount = report.linkedReportCount;
    final reportShortId = report.id.length > 8
        ? report.id.substring(0, 8)
        : report.id;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (report.title?.trim().isNotEmpty == true) ...[
            Text(
              report.title!,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
          ],
          Semantics(
            container: true,
            explicitChildNodes: true,
            label:
                '${l10n.status}: ${localizedReportStatus(report.status, l10n)}',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _buildStatusBadge(context, report.status),
                if (report.categoryDisplay != null || report.category != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(
                          alpha: 0.26,
                        ),
                      ),
                    ),
                    child: Text(
                      localizedReportCategory(
                        report.category,
                        l10n,
                        fallback: report.categoryDisplay,
                      ),
                      style: theme.textTheme.labelMedium,
                    ),
                  ),
                if (report.displayPriorityLevel != null)
                  PriorityBadge(
                    priorityLevel: report.displayPriorityLevel,
                    authorityLabel: localizedPriorityAuthority(report, l10n),
                    showScores: false,
                  )
                else
                  Text(l10n.unscored, style: theme.textTheme.labelMedium),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              Text(
                localizedPriorityAuthority(report, l10n),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (linkedReportCount > 1 && report.isIncidentRepresentative)
                Text(
                  l10n.confirmedLinkedReports(linkedReportCount),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              if (report.credibilityScore != null)
                Text(
                  l10n.credibility(report.credibilityScore!.round()),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              if (report.blockchainSynced)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      size: 16,
                      color: successColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.verified,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: successColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Time
          if (report.createdAt != null)
            Text(
              localizedRelativeTime(context, report.createdAt, l10n),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: 16),

          if (report.createdAt != null ||
              report.submittedAt != null ||
              report.verifiedAt != null ||
              report.resolvedAt != null ||
              report.assignedDepartment != null) ...[
            _buildWorkflowActivity(theme, report),
            const SizedBox(height: 24),
          ],

          // Description
          _buildSectionHeading(
            theme,
            icon: Icons.description_outlined,
            title: l10n.reportDescription,
          ),
          const SizedBox(height: 8),
          Text(
            report.description,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
          ),
          const SizedBox(height: 24),

          // Location
          if (report.hasCoordinates ||
              report.streetLandmark != null ||
              report.location != null ||
              report.barangay != null ||
              report.cityMunicipality != null ||
              report.zone != null) ...[
            _buildSectionHeading(
              theme,
              icon: Icons.location_on_outlined,
              title: l10n.reportLocation,
            ),
            const SizedBox(height: 8),
            if (report.streetLandmark != null)
              _buildInfoRow(l10n.address, report.streetLandmark!, theme),
            if (report.barangay != null)
              _buildInfoRow(l10n.barangay, report.barangay!, theme),
            if (report.cityMunicipality != null)
              _buildInfoRow(l10n.city, report.cityMunicipality!, theme),
            if (report.zone != null)
              _buildInfoRow(l10n.zone, report.zone!, theme),
            if (report.streetLandmark == null &&
                report.barangay == null &&
                report.cityMunicipality == null &&
                report.zone == null &&
                report.location != null)
              Text(
                report.location!,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.4),
              ),
            if (report.hasCoordinates) ...[
              const SizedBox(height: 12),
              Semantics(
                container: true,
                label: '${l10n.reportLocation}: ${report.displayLocation}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 200,
                    child: Stack(
                      children: [
                        FlutterMap(
                          mapController: _locationMapController,
                          options: MapOptions(
                            initialCenter: LatLng(
                              report.latitude!,
                              report.longitude!,
                            ),
                            initialZoom: 16,
                            initialCameraFit: municipality == null
                                ? null
                                : MunicipalityMapCamera.initialFit(
                                    municipality,
                                  ),
                            cameraConstraint: municipality == null
                                ? const CameraConstraint.unconstrained()
                                : MunicipalityMapCamera.constraintFor(
                                        municipality,
                                      ) ??
                                      const CameraConstraint.unconstrained(),
                            interactionOptions: const InteractionOptions(
                              flags:
                                  InteractiveFlag.pinchZoom |
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
                            MunicipalityBoundaryLayer(
                              boundary: municipality?.boundary,
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
                        if (municipality != null)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton.filledTonal(
                              constraints: const BoxConstraints.tightFor(
                                width: 48,
                                height: 48,
                              ),
                              tooltip: l10n.recenterToMunicipality(
                                municipality.name,
                              ),
                              onPressed: () => MunicipalityMapCamera.recenter(
                                _locationMapController,
                                municipality,
                              ),
                              icon: const Icon(
                                Icons.center_focus_strong_outlined,
                              ),
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
                              color: theme.scaffoldBackgroundColor.withValues(
                                alpha: 0.85,
                              ),
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
              ),
            ],
            const SizedBox(height: 24),
          ],

          // AI Analysis (if available)
          if (report.categoryDisplay != null ||
              report.category != null ||
              report.displayPriorityLevel != null ||
              report.departmentDisplay != null ||
              report.recommendedDepartment != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryVariant.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryVariant.withValues(alpha: 0.2),
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
                        l10n.aiAnalysis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (report.categoryDisplay != null || report.category != null)
                    _buildInfoRow(
                      l10n.category,
                      localizedReportCategory(
                        report.category,
                        l10n,
                        fallback: report.categoryDisplay,
                      ),
                      theme,
                    ),
                  if (report.categoryConfidence != null)
                    _buildInfoRow(
                      l10n.categoryConfidence,
                      '${(report.categoryConfidence! * 100).toStringAsFixed(1)}%',
                      theme,
                    ),
                  if (report.departmentDisplay != null ||
                      report.recommendedDepartment != null)
                    _buildInfoRow(
                      l10n.aiDepartmentSuggestion,
                      '${report.departmentDisplay ?? report.recommendedDepartment}'
                      '${report.departmentProbability != null ? ' (${(report.departmentProbability! * 100).toStringAsFixed(1)}%)' : ''}',
                      theme,
                    ),
                  if (report.departmentDisplay != null ||
                      report.recommendedDepartment != null)
                    _buildInfoRow(
                      l10n.routingStatus,
                      report.needsDepartmentReview
                          ? l10n.awaitingStaffConfirmation
                          : l10n.routingPolicyApplied,
                      theme,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Report ID
          _buildInfoRow('Report ID', reportShortId, theme),
          const SizedBox(height: 24),

          if (report.resolvedProofImages.isNotEmpty &&
              (report.status == ReportStatus.resolved ||
                  report.status == ReportStatus.closed)) ...[
            _buildSectionHeading(
              theme,
              icon: Icons.photo_library_outlined,
              title: l10n.resolutionProof,
            ),
            const SizedBox(height: 8),
            Text(
              report.status == ReportStatus.resolved
                  ? l10n.resolutionProofResolved
                  : l10n.resolutionProofClosed,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 104,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: report.resolvedProofImages.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final proofImage = report.resolvedProofImages[index];
                  return Semantics(
                    button: true,
                    image: true,
                    label: '${l10n.resolutionProof} ${index + 1}',
                    child: GestureDetector(
                      onTap: () => _openResolutionProofGallery(
                        report.resolvedProofImages,
                        index,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          ApiConstants.getImageUrl(proofImage.url),
                          width: 140,
                          height: 104,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            width: 140,
                            height: 104,
                            color: theme.colorScheme.surfaceContainerHighest,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Citizen resolution review banner (shown only to the report owner
          // when the report has been resolved by barangay staff)
          _buildCitizenReviewBanner(theme, report),

          // Blockchain Verification Section
          _buildBlockchainSection(theme, isDark, report),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _openResolutionProofGallery(
    List<ReportImage> images,
    int initialIndex,
  ) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => _ResolutionProofGallery(
        images: images,
        initialIndex: initialIndex,
      ),
    );
  }

  Widget _buildWorkflowActivity(ThemeData theme, Report report) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeading(
          theme,
          icon: Icons.timeline_outlined,
          title: l10n.status,
        ),
        const SizedBox(height: 8),
        CivicSurface(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              if (report.createdAt != null)
                _buildInfoRow(
                  l10n.submitted,
                  _formatDate(report.createdAt!),
                  theme,
                ),
              if (report.verifiedAt != null)
                _buildInfoRow(
                  l10n.verified,
                  _formatDate(report.verifiedAt!),
                  theme,
                ),
              if (report.resolvedAt != null)
                _buildInfoRow(
                  l10n.resolvedStatus,
                  _formatDate(report.resolvedAt!),
                  theme,
                ),
              if (report.assignedDepartment != null)
                _buildInfoRow(
                  l10n.currentHandler,
                  report.assignedDepartment!,
                  theme,
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) =>
      DateFormat('MMM dd, yyyy, HH:mm').format(date);

  Widget _buildSectionHeading(
    ThemeData theme, {
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  /// Shows a prominent call-to-action banner to the report owner when the
  /// barangay has marked the report as resolved and the citizen hasn't yet
  /// submitted their review.
  Widget _buildCitizenReviewBanner(ThemeData theme, Report report) {
    final l10n = AppLocalizations.of(context);
    final successColor = theme.brightness == Brightness.dark
        ? AppColors.resolvedTextDark
        : AppColors.resolvedText;
    if (report.status != ReportStatus.resolved) return const SizedBox.shrink();

    // Citizen report-detail requests are owner-authorized by the backend.
    // The citizen-safe response deliberately omits `user_id`, so ownership
    // must not be rechecked against the redacted mobile payload here.

    // --- Already reviewed: show a compact confirmation chip ---
    if (report.citizenVerifiedAt != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: successColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: successColor.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.verified_rounded, color: successColor, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.alreadyReviewed,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: successColor,
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
          color: successColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: successColor.withValues(alpha: 0.24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.task_alt_rounded, color: successColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.reportResolved,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: successColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.resolvedReviewDescription,
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
                    ref.invalidate(reportDetailControllerProvider(report.id));
                  }
                },
                icon: const Icon(Icons.rate_review_outlined),
                label: Text(l10n.reviewSignOff),
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  minimumSize: const Size.fromHeight(52),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockchainSection(ThemeData theme, bool isDark, Report report) {
    final l10n = AppLocalizations.of(context);
    return CivicSurface(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_tree_outlined,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.blockchainVerification,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (_isVerifying)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                TextButton.icon(
                  onPressed: _isVerifying
                      ? null
                      : () => _handleVerification(report.id),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: Text(l10n.verifyNow),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    textStyle: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_verificationResult != null) ...[
            _buildVerificationStatus(theme),
            const Divider(height: 24),
            Text(
              l10n.auditHistory,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (_verificationResult!.auditHistory.isEmpty)
              Text(l10n.noAuditEntries, style: theme.textTheme.bodySmall)
            else
              ..._verificationResult!.auditHistory.map(
                (entry) => _buildAuditEntry(theme, entry, isDark),
              ),
          ] else if (report.blockchainSynced)
            Text(l10n.blockchainAnchored, style: theme.textTheme.bodySmall)
          else
            Text(l10n.blockchainPending, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildVerificationStatus(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    final result = _verificationResult!;
    final isDark = theme.brightness == Brightness.dark;
    final successColor = isDark
        ? AppColors.resolvedTextDark
        : AppColors.resolvedText;
    final warningColor = isDark
        ? AppColors.pendingTextDark
        : AppColors.pendingText;
    final errorColor = isDark
        ? AppColors.rejectedTextDark
        : AppColors.rejectedText;

    // `verified` = content hash intact. `statusVerified` is only populated for
    // legacy v3 status events; v4 checkpoints deliberately leave workflow
    // status off-chain and return null.
    final isHealthy = result.verified; // content integrity only

    // Determine the display state
    final isNotFound = result.notFoundOnChain;
    final isConnectionError = result.connectionError;
    final isNotAnchored = !result.isAnchored;
    final isNeutral = isNotFound || isConnectionError || isNotAnchored;
    // Status is out of sync with blockchain (expected after staff actions)
    final isStatusPending = result.verified && result.statusVerified == false;

    final Color statusColor;
    final IconData statusIcon;
    final String title;

    if (isHealthy && !isStatusPending) {
      statusColor = successColor;
      statusIcon = Icons.check_circle;
      title = l10n.integrityVerified;
    } else if (isStatusPending) {
      // Content is intact; only the on-chain status enum lags behind
      statusColor = warningColor;
      statusIcon = Icons.sync_rounded;
      title = l10n.contentVerified;
    } else if (isNotAnchored) {
      statusColor = warningColor;
      statusIcon = Icons.hourglass_empty;
      title = l10n.notYetAnchored;
    } else if (isNotFound) {
      statusColor = warningColor;
      statusIcon = Icons.search_off;
      title = l10n.recordNotFound;
    } else if (isConnectionError) {
      statusColor = warningColor;
      statusIcon = Icons.cloud_off;
      title = l10n.blockchainUnavailable;
    } else {
      statusColor = errorColor;
      statusIcon = Icons.warning;
      title = l10n.integrityBreach;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isNeutral ? warningColor : statusColor).withValues(alpha: 0.1),
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
    final l10n = AppLocalizations.of(context);
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
                  children: [
                    Expanded(
                      child: Text(
                        _getActionLabel(entry),
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
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
                  l10n.byActor(
                    entry.actor.length > 10
                        ? '${entry.actor.substring(0, 6)}...${entry.actor.substring(entry.actor.length - 4)}'
                        : entry.actor,
                  ),
                  style: theme.textTheme.bodySmall,
                ),
                if (entry.oldStatus != entry.newStatus)
                  Text(
                    l10n.statusTransition(entry.oldStatus, entry.newStatus),
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

  String _getActionLabel(BlockchainAuditEntry entry) {
    // v4 checkpoints intentionally reuse the compact action integer space;
    // equal statuses distinguish them from legacy workflow transitions.
    if (entry.oldStatus == entry.newStatus) {
      return switch (entry.actionType) {
        0 => 'Created integrity checkpoint',
        1 => 'Final integrity checkpoint',
        2 => 'Dispute / reopen checkpoint',
        3 => 'Administrative override checkpoint',
        _ => AuditActionType.fromInt(entry.actionType).displayLabel,
      };
    }
    return AuditActionType.fromInt(entry.actionType).displayLabel;
  }

  Future<void> _handleVerification(String reportId) async {
    final l10n = AppLocalizations.of(context);
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
        AppToast.error(context, l10n.verificationFailed);
      }
    }
  }

  Widget _buildStatusBadge(BuildContext context, ReportStatus status) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final (background, foreground, label) = switch (status) {
      ReportStatus.submitted => (
        colorScheme.tertiaryContainer,
        colorScheme.onTertiaryContainer,
        l10n.submitted,
      ),
      ReportStatus.underReview ||
      ReportStatus.verified ||
      ReportStatus.assigned ||
      ReportStatus.escalated ||
      ReportStatus.endorsed => (
        colorScheme.secondaryContainer,
        colorScheme.onSecondaryContainer,
        l10n.underReview,
      ),
      ReportStatus.inProgress => (
        colorScheme.primaryContainer,
        colorScheme.onPrimaryContainer,
        l10n.inProgress,
      ),
      ReportStatus.resolved => (
        AppColors.success.withValues(alpha: 0.16),
        colorScheme.onSurface,
        l10n.resolvedStatus,
      ),
      ReportStatus.closed => (
        colorScheme.surfaceContainerHighest,
        colorScheme.onSurfaceVariant,
        l10n.closed,
      ),
      ReportStatus.rejected => (
        colorScheme.errorContainer,
        colorScheme.onErrorContainer,
        l10n.rejected,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: foreground.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ResolutionProofGallery extends StatefulWidget {
  final List<ReportImage> images;
  final int initialIndex;

  const _ResolutionProofGallery({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_ResolutionProofGallery> createState() =>
      _ResolutionProofGalleryState();
}

class _ResolutionProofGalleryState extends State<_ResolutionProofGallery> {
  late final PageController _pageController = PageController(
    initialPage: widget.initialIndex,
  );
  late int _currentIndex = widget.initialIndex;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Center(
                    child: Image.network(
                      ApiConstants.getImageUrl(widget.images[index].url),
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white70,
                        size: 56,
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
            if (widget.images.length > 1)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Text(
                  '${_currentIndex + 1} / ${widget.images.length}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
