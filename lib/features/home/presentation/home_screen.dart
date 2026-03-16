import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/presentation/widgets/empty_content_placeholder.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/data/user_permissions.dart';
import '../../auth/presentation/verification_widgets.dart';
import '../../kyc/presentation/kyc_controller.dart';
import '../../reports/domain/entities/report.dart';
import '../../reports/domain/entities/report_enums.dart';
import '../../reports/presentation/report_detail_screen.dart';
import '../../reports/presentation/reports_controller.dart';
import '../../reports/reports_di.dart';
import 'widgets/home_report_card.dart';
import 'widgets/map_placeholder.dart';

/// Home screen with map/list toggle and report list.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isMapView = true;
  bool _isNavigatingToReportDetail = false;
  bool _isInitialLoading = true;
  bool _isLoadingMore = false;
  String? _loadError;

  int _currentPage = 0;
  int _totalPages = 1;
  int _totalReports = 0;
  int _selectedStatusFilterIndex = 0;

  final _searchController = TextEditingController();
  final _listScrollController = ScrollController();
  final List<Report> _reports = [];

  final List<({String label, String? status})> _statusFilters = const [
    (label: 'All', status: null),
    (label: 'Submitted', status: 'submitted'),
    (label: 'Under Review', status: 'under_review'),
    (label: 'In Progress', status: 'in_progress'),
    (label: 'Resolved', status: 'resolved'),
    (label: 'Escalated', status: 'escalated'),
  ];

  String? get _selectedStatus =>
      _statusFilters[_selectedStatusFilterIndex].status;
  String _selectedSort = 'date';
  bool get _hasNextPage => _currentPage < _totalPages;

  @override
  void initState() {
    super.initState();
    _listScrollController.addListener(_onListScroll);
    _loadInitialReports();
  }

  @override
  void dispose() {
    _listScrollController.removeListener(_onListScroll);
    _listScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await _loadInitialReports();
    ref.invalidate(kycStatusControllerProvider);
  }

  Future<void> _loadInitialReports() async {
    setState(() {
      _isInitialLoading = true;
      _isLoadingMore = false;
      _loadError = null;
      _currentPage = 0;
      _totalPages = 1;
      _totalReports = 0;
      _reports.clear();
    });

    final getReports = ref.read(getReportsUseCaseProvider);
    final result = await getReports(
      page: 1,
      status: _selectedStatus,
      sortBy: _selectedSort,
    );

    if (!mounted) return;

    result.when(
      success: (data) {
        // Filter out closed and rejected reports
        final filteredReports = data.results.where((report) {
          return report.status != ReportStatus.closed &&
                 report.status != ReportStatus.rejected;
        }).toList();

        setState(() {
          _reports.addAll(filteredReports);
          _currentPage = data.page;
          _totalPages = data.totalPages;
          // Set total to the count of displayed reports, not backend total
          _totalReports = _reports.length;
          _isInitialLoading = false;
        });
      },
      failure: (failure) {
        setState(() {
          _loadError = failure.message;
          _isInitialLoading = false;
        });
      },
    );
  }

  Future<void> _loadNextPage() async {
    if (_isInitialLoading || _isLoadingMore || !_hasNextPage) return;

    setState(() => _isLoadingMore = true);

    final nextPage = _currentPage + 1;
    final getReports = ref.read(getReportsUseCaseProvider);
    final result = await getReports(
      page: nextPage,
      status: _selectedStatus,
      sortBy: _selectedSort,
    );

    if (!mounted) return;

    result.when(
      success: (data) {
        final existingIds = _reports.map((r) => r.id).toSet();
        // Filter out closed and rejected reports, and duplicates
        final newReports = data.results
            .where((report) {
              return report.status != ReportStatus.closed &&
                     report.status != ReportStatus.rejected &&
                     !existingIds.contains(report.id);
            })
            .toList();

        setState(() {
          _reports.addAll(newReports);
          _currentPage = data.page;
          _totalPages = data.totalPages;
          // Set total to the count of displayed reports, not backend total
          _totalReports = _reports.length;
          _isLoadingMore = false;
        });
      },
      failure: (_) {
        setState(() => _isLoadingMore = false);
      },
    );
  }

  void _onListScroll() {
    if (!_listScrollController.hasClients) return;
    final threshold = _listScrollController.position.maxScrollExtent - 320;
    if (_listScrollController.position.pixels >= threshold) {
      _loadNextPage();
    }
  }

  Future<void> _openReportDetail(String reportId, Report? initialReport) async {
    if (_isNavigatingToReportDetail || !mounted) return;

    setState(() => _isNavigatingToReportDetail = true);
    try {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ReportDetailScreen(
            reportId: reportId,
            initialReport: initialReport,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isNavigatingToReportDetail = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final permissions = ref.watch(userPermissionsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Auto-refresh when a new report is created
    ref.listen<int>(myReportsRefreshProvider, (previous, next) {
      if (previous != null && next > previous) {
        _loadInitialReports();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Column(
        children: [
          VerificationBanner(permissions: permissions),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search reports...',
                prefixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
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
                Text(
                  '$_totalReports ${_totalReports == 1 ? 'report' : 'reports'}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _statusFilters.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedStatusFilterIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(_statusFilters[index].label),
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
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder),
                    ),
                    onSelected: (_) {
                      setState(() {
                        _selectedStatusFilterIndex = index;
                      });
                      _loadInitialReports();
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: _isMapView
                  ? _buildMapView(theme)
                  : _buildListView(theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip({
    required String label,
    required String value,
    required IconData icon,
    required bool isDark,
  }) {
    final isSelected = _selectedSort == value;
    final selectedColor = AppColors.primary;
    return GestureDetector(
      onTap: () {
        if (_selectedSort != value) {
          setState(() => _selectedSort = value);
          _loadInitialReports();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor.withValues(alpha: 0.12)
              : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? selectedColor
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12,
              color: isSelected
                  ? selectedColor
                  : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? selectedColor
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

  Widget _buildMapView(ThemeData theme) {
    if (_isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null && _reports.isEmpty) {
      return _buildErrorState(theme, _loadError!);
    }

    if (_reports.isEmpty) {
      return _buildEmptyState(theme);
    }

    return Stack(
      children: [
        MapPlaceholder(
          reports: _reports.where((r) => r.status != ReportStatus.closed).toList(),
          onMarkerTap: (report) => _openReportDetail(report.id, report),
        ),
        Positioned(
          left: 16,
          bottom: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).scaffoldBackgroundColor.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildLegendItem('Submitted', AppColors.alertMedium),
                _buildLegendItem('In Progress', const Color(0xFF3B82F6)),
                _buildLegendItem('Escalated', AppColors.alertHigh),
                _buildLegendItem('Resolved', AppColors.success),
              ],
            ),
          ),
        ),
      ],
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

  Widget _buildListView(ThemeData theme) {
    if (_isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null && _reports.isEmpty) {
      return _buildErrorState(theme, _loadError!);
    }

    if (_reports.isEmpty) {
      return _buildEmptyState(theme);
    }

    final sectionItems = _buildSectionItems(_reports);

    return ListView.builder(
      controller: _listScrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sectionItems.length + 1,
      itemBuilder: (context, index) {
        if (index == sectionItems.length) {
          return _buildListFooter(theme);
        }

        final item = sectionItems[index];
        if (item.isHeader) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(4, 10, 4, 8),
            child: Text(
              item.header!,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }

        final report = item.report!;
        return HomeReportCard(
          report: report,
          onTap: () => _openReportDetail(report.id, report),
        );
      },
    );
  }

  Widget _buildListFooter(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
      child: Center(
        child: _isLoadingMore
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : Text(
                _hasNextPage ? 'Scroll to load more' : 'No more reports',
                style: theme.textTheme.bodySmall,
              ),
      ),
    );
  }

  List<_ReportSectionItem> _buildSectionItems(List<Report> reports) {
    if (_selectedSort == 'priority') {
      return _buildPrioritySections(reports);
    }

    final items = <_ReportSectionItem>[];
    DateTime? previousDate;

    for (final report in reports) {
      final createdAt = report.createdAt;
      final reportDate = createdAt == null
          ? null
          : DateTime(createdAt.year, createdAt.month, createdAt.day);

      if (reportDate != previousDate) {
        items.add(_ReportSectionItem.header(_sectionLabelForDate(reportDate)));
        previousDate = reportDate;
      }
      items.add(_ReportSectionItem.report(report));
    }

    return items;
  }

  List<_ReportSectionItem> _buildPrioritySections(List<Report> reports) {
    // Sort critical → high → medium → low → very low → unscored
    const order = [
      PriorityLevel.critical,
      PriorityLevel.high,
      PriorityLevel.medium,
      PriorityLevel.low,
      PriorityLevel.veryLow,
    ];

    final sorted = [...reports];
    sorted.sort((a, b) {
      final aIdx = a.priorityLevel == null
          ? order.length
          : order.indexOf(a.priorityLevel!);
      final bIdx = b.priorityLevel == null
          ? order.length
          : order.indexOf(b.priorityLevel!);
      return aIdx.compareTo(bIdx);
    });

    final items = <_ReportSectionItem>[];
    PriorityLevel? previousLevel;
    bool unscored = false;

    for (final report in sorted) {
      final level = report.priorityLevel;
      if (level != previousLevel || (level == null && !unscored)) {
        final label = level != null
            ? 'Level ${5 - order.indexOf(level)} — ${level.displayName}'
            : 'Unscored';
        items.add(_ReportSectionItem.header(label));
        previousLevel = level;
        if (level == null) unscored = true;
      }
      items.add(_ReportSectionItem.report(report));
    }

    return items;
  }

  String _sectionLabelForDate(DateTime? date) {
    if (date == null) return 'Unknown Date';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) return 'Today';
    if (date == yesterday) return 'Yesterday';

    return MaterialLocalizations.of(context).formatMediumDate(date);
  }

  Widget _buildEmptyState(ThemeData theme) {
    return EmptyContentPlaceholder(
      icon: Icons.location_off_outlined,
      title: 'No reports found',
      message: 'No reports match the selected filters.',
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
          Text('Unable to Load Reports', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'We\'re having trouble loading reports. Please check your internet connection and try again.',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportSectionItem {
  final String? header;
  final Report? report;

  const _ReportSectionItem._({this.header, this.report});

  factory _ReportSectionItem.header(String text) =>
      _ReportSectionItem._(header: text);
  factory _ReportSectionItem.report(Report report) =>
      _ReportSectionItem._(report: report);

  bool get isHeader => header != null;
}
