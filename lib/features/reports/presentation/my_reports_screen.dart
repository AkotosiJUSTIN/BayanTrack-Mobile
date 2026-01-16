import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../data/report_models.dart';
import 'reports_controller.dart';
import '../../home/presentation/widgets/home_report_card.dart';

/// My Reports screen showing user's submitted reports.
/// Features filter tabs: All, Pending, In Progress, Resolved.
class MyReportsScreen extends ConsumerStatefulWidget {
  const MyReportsScreen({super.key});

  @override
  ConsumerState<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends ConsumerState<MyReportsScreen> {
  int _selectedFilter = 0;

  final List<String> _filters = ['All', 'Pending', 'In Progress', 'Resolved'];

  Future<void> _onRefresh() async {
    ref.invalidate(myReportsControllerProvider());
  }

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(myReportsControllerProvider());
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('My Reports')),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          slivers: [
            // Filter tabs
            SliverToBoxAdapter(
              child: SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filters.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedFilter == index;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(_filters[index]),
                        selectedColor: AppColors.primary,
                        backgroundColor: isDark
                            ? AppColors.darkSurface
                            : AppColors.lightSurface,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary),
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder),
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = index;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // Reports list
            SliverFillRemaining(child: _buildContent(reportsAsync, theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    AsyncValue<PaginatedReports> reportsAsync,
    ThemeData theme,
  ) {
    return reportsAsync.when(
      data: (data) {
        final filteredResults = _filterReports(data.results);

        if (filteredResults.isEmpty) {
          return _buildEmptyState(theme);
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filteredResults.length,
          itemBuilder: (context, index) {
            return HomeReportCard(
              report: filteredResults[index],
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'View: ${filteredResults[index].description}',
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

  List<Report> _filterReports(List<Report> reports) {
    if (_selectedFilter == 0) return reports;

    final targetStatus = switch (_selectedFilter) {
      1 => ReportStatus.pending,
      2 => ReportStatus.inProgress,
      3 => ReportStatus.resolved,
      _ => null,
    };

    if (targetStatus == null) return reports;
    return reports.where((r) => r.status == targetStatus).toList();
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text('No reports yet', style: theme.textTheme.titleMedium),
        ],
      ),
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
