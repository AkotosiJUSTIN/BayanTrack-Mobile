import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/presentation/widgets/empty_content_placeholder.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/user_permissions.dart';
import '../../auth/presentation/barangays_provider.dart';
import '../../auth/presentation/verification_widgets.dart';
import '../../kyc/presentation/kyc_controller.dart';
import '../../reports/domain/entities/report.dart';
import '../../reports/domain/entities/report_enums.dart';
import '../../reports/presentation/report_detail_screen.dart';
import '../../reports/presentation/report_labels.dart';
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

  final List<String?> _statusFilters = const [
    null,
    'submitted',
    'under_review',
    'in_progress',
    'resolved',
    'escalated',
  ];

  String? get _selectedStatus => _statusFilters[_selectedStatusFilterIndex];
  final String _selectedSort = 'priority';
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
        final newReports = data.results.where((report) {
          return report.status != ReportStatus.closed &&
              report.status != ReportStatus.rejected &&
              !existingIds.contains(report.id);
        }).toList();

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
    final l10n = AppLocalizations.of(context)!;

    // Auto-refresh when a new report is created
    ref.listen<int>(myReportsRefreshProvider, (previous, next) {
      if (previous != null && next > previous) {
        _loadInitialReports();
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.home)),
      body: Column(
        children: [
          VerificationBanner(permissions: permissions),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: l10n.searchReports,
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final viewSelector = _buildViewSelector(l10n);
                final count = Text(
                  l10n.reportCount(_totalReports),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                );

                if (constraints.maxWidth < 360) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      count,
                      const SizedBox(height: 8),
                      SizedBox(width: double.infinity, child: viewSelector),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: count),
                    Flexible(child: viewSelector),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.status,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
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
                    label: Text(
                      _statusFilterLabel(_statusFilters[index], l10n),
                    ),
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
              child: _isMapView ? _buildMapView(theme) : _buildListView(theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewSelector(AppLocalizations l10n) {
    return SegmentedButton<bool>(
      expandedInsets: EdgeInsets.zero,
      showSelectedIcon: false,
      segments: [
        ButtonSegment<bool>(
          value: true,
          label: Text(l10n.map),
          icon: const Icon(Icons.map_outlined),
        ),
        ButtonSegment<bool>(
          value: false,
          label: Text(l10n.list),
          icon: const Icon(Icons.list),
        ),
      ],
      selected: {_isMapView},
      onSelectionChanged: (selection) {
        if (selection.isNotEmpty) {
          setState(() => _isMapView = selection.first);
        }
      },
    );
  }

  String _statusFilterLabel(String? status, AppLocalizations l10n) {
    return switch (status) {
      null => l10n.all,
      'submitted' => l10n.submitted,
      'under_review' => l10n.underReview,
      'in_progress' => l10n.inProgress,
      'resolved' => l10n.resolvedStatus,
      'escalated' => l10n.escalated,
      _ => l10n.status,
    };
  }

  Widget _buildMapView(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;

    if (_isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null && _reports.isEmpty) {
      return _buildErrorState(theme);
    }

    if (_reports.isEmpty) {
      return _buildEmptyState(theme);
    }

    final mapReports = _reports
        .where((report) => report.status != ReportStatus.closed)
        .toList(growable: false);
    final municipalityIds = mapReports
        .map((report) => report.municipalityId)
        .toSet();
    final municipalityId = municipalityIds.length == 1
        ? municipalityIds.single
        : defaultMunicipalityId;
    final municipalities = ref.watch(municipalitiesProvider).asData?.value;
    final municipality =
        findMunicipalityMetadata(
          municipalities ?? const [bundledUrdanetaMunicipality],
          municipalityId,
        ) ??
        bundledUrdanetaMunicipality;

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : MediaQuery.of(context).size.height;

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: viewportHeight,
              child: Stack(
                children: [
                  MapPlaceholder(
                    reports: mapReports,
                    municipality: municipality,
                    onMarkerTap: (report) =>
                        _openReportDetail(report.id, report),
                  ),
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
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          _buildLegendItem(
                            l10n.submitted,
                            reportMapStatusColor(ReportStatus.submitted),
                          ),
                          _buildLegendItem(
                            l10n.inProgress,
                            reportMapStatusColor(ReportStatus.inProgress),
                          ),
                          _buildLegendItem(
                            l10n.escalated,
                            reportMapStatusColor(ReportStatus.escalated),
                          ),
                          _buildLegendItem(
                            l10n.resolvedStatus,
                            reportMapStatusColor(ReportStatus.resolved),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
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
      return _buildErrorState(theme);
    }

    if (_reports.isEmpty) {
      return _buildEmptyState(theme);
    }

    final sectionItems = _buildSectionItems(_reports);

    return ListView.builder(
      controller: _listScrollController,
      physics: const AlwaysScrollableScrollPhysics(),
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
                _hasNextPage
                    ? AppLocalizations.of(context)!.scrollLoadMore
                    : AppLocalizations.of(context)!.noMoreReports,
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
    // Keep emergencies first, then Quick Reports, then effective priority.
    const order = [
      PriorityLevel.critical,
      PriorityLevel.high,
      PriorityLevel.medium,
      PriorityLevel.low,
      PriorityLevel.veryLow,
    ];

    final sorted = [...reports];
    sorted.sort((a, b) {
      final aGroup = a.isEmergency ? 0 : (a.isQuickReport ? 1 : 2);
      final bGroup = b.isEmergency ? 0 : (b.isQuickReport ? 1 : 2);
      final groupComparison = aGroup.compareTo(bGroup);
      if (groupComparison != 0) return groupComparison;
      final aLevel = a.displayPriorityLevel;
      final bLevel = b.displayPriorityLevel;
      final aIdx = aLevel == null ? order.length : order.indexOf(aLevel);
      final bIdx = bLevel == null ? order.length : order.indexOf(bLevel);
      final priorityComparison = aIdx.compareTo(bIdx);
      if (priorityComparison != 0) return priorityComparison;
      final boostComparison = b.linkedUrgencyBoost.compareTo(
        a.linkedUrgencyBoost,
      );
      if (boostComparison != 0) return boostComparison;
      return (a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(
        b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
      );
    });

    final items = <_ReportSectionItem>[];
    String? previousGroup;

    for (final report in sorted) {
      final group = report.isEmergency
          ? 'emergency'
          : report.isQuickReport
          ? 'quick'
          : (report.displayPriorityLevel?.name ?? 'unscored');
      if (group != previousGroup) {
        final l10n = AppLocalizations.of(context)!;
        final label = switch (group) {
          'emergency' => l10n.emergencyReport,
          'quick' => l10n.quickReport,
          'unscored' => l10n.unscored,
          _ => localizedPriorityLabel(report.displayPriorityLevel!, l10n),
        };
        items.add(_ReportSectionItem.header(label));
        previousGroup = group;
      }
      items.add(_ReportSectionItem.report(report));
    }

    return items;
  }

  String _sectionLabelForDate(DateTime? date) {
    final l10n = AppLocalizations.of(context)!;
    if (date == null) return l10n.unknownDate;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) return l10n.today;
    if (date == yesterday) return l10n.yesterday;

    return MaterialLocalizations.of(context).formatMediumDate(date);
  }

  Widget _buildEmptyState(ThemeData theme) {
    return EmptyContentPlaceholder(
      icon: Icons.location_off_outlined,
      title: AppLocalizations.of(context)!.noReportsFound,
      message: AppLocalizations.of(context)!.noReportsMatch,
      onRetry: _onRefresh,
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppColors.alertHigh),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.unableLoadReports,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    AppLocalizations.of(context)!.reportsNetworkError,
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: _onRefresh,
                  child: Text(AppLocalizations.of(context)!.retry),
                ),
              ],
            ),
          ),
        ),
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
