import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/data/user_permissions.dart';
import '../../auth/presentation/verification_widgets.dart';
import '../../kyc/presentation/kyc_controller.dart';
import '../../reports/data/report_models.dart';
import '../../reports/presentation/report_detail_screen.dart';
import '../../reports/presentation/reports_controller.dart';
import 'widgets/home_report_card.dart';

import 'widgets/map_placeholder.dart';
import '../../../core/presentation/widgets/empty_content_placeholder.dart';

/// Home screen with map/list toggle and report list.
/// Shows nearby reports in either map or list view.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isMapView = true;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    ref.invalidate(reportsControllerProvider());
    ref.invalidate(kycStatusControllerProvider);
  }

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(reportsControllerProvider());
    final permissions = ref.watch(userPermissionsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          // Verification banner for unverified users
          VerificationBanner(permissions: permissions),

          // Main content with refresh
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: CustomScrollView(
          slivers: [
            // Search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search reports...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.tune),
                      onPressed: () {},
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

            // View toggle and count
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Map/List toggle
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurface
                            : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildToggleButton(
                            label: 'Map',
                            icon: Icons.map_outlined,
                            isSelected: _isMapView,
                            onTap: () => setState(() => _isMapView = true),
                          ),
                          _buildToggleButton(
                            label: 'List',
                            icon: Icons.list,
                            isSelected: !_isMapView,
                            onTap: () => setState(() => _isMapView = false),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    reportsAsync.when(
                      data: (data) => Text(
                        '${data.count} reports nearby',
                        style: theme.textTheme.bodySmall,
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Content area
            SliverFillRemaining(
              child: _isMapView
                  ? _buildMapView(reportsAsync, theme)
                  : _buildListView(reportsAsync, theme),
            ),
          ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.lightSurfaceVariant)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? (isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary)
                  : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? (isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary)
                    : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapView(
    AsyncValue<PaginatedReports> reportsAsync,
    ThemeData theme,
  ) {
    return reportsAsync.when(
      data: (data) {
        if (data.results.isEmpty) {
          return _buildEmptyState(theme);
        }
        return Stack(
          children: [
            const MapPlaceholder(),
            // Legend at bottom
            Positioned(
              left: 16,
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).scaffoldBackgroundColor.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLegendItem('Low', AppColors.alertLow),
                    const SizedBox(width: 16),
                    _buildLegendItem('Medium', AppColors.alertMedium),
                    const SizedBox(width: 16),
                    _buildLegendItem('High', AppColors.alertHigh),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _buildErrorState(theme, error.toString()),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildListView(
    AsyncValue<PaginatedReports> reportsAsync,
    ThemeData theme,
  ) {
    return reportsAsync.when(
      data: (data) {
        if (data.results.isEmpty) {
          return _buildEmptyState(theme);
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: data.results.length,
          itemBuilder: (context, index) {
            final report = data.results[index];
            return HomeReportCard(
              report: report,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ReportDetailScreen(
                      reportId: report.id,
                      initialReport: report,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _buildErrorState(theme, error.toString()),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return EmptyContentPlaceholder(
      icon: Icons.location_off_outlined,
      title: 'No reports nearby',
      message:
          'There are no reports in your area yet.\nBe the first to submit one!',
      onRetry: _onRefresh,
    );
  }

  Widget _buildErrorState(ThemeData theme, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.alertHigh),
          const SizedBox(height: 16),
          Text('Failed to load reports', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
