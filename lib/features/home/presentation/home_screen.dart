import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/presentation/widgets/civic_components.dart';
import '../../../core/presentation/widgets/empty_content_placeholder.dart';
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

bool isHomeReportVisible(Report report) =>
    report.status != ReportStatus.closed &&
    report.status != ReportStatus.rejected;

List<Report> mergeHomeReports(
  Iterable<Report> existing,
  Iterable<Report> incoming,
) {
  final merged = <String, Report>{
    for (final report in existing)
      if (isHomeReportVisible(report)) report.id: report,
  };
  for (final report in incoming) {
    if (isHomeReportVisible(report)) {
      merged[report.id] = report;
    } else {
      merged.remove(report.id);
    }
  }
  return merged.values.toList(growable: false);
}

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
  int _loadGeneration = 0;

  final _searchController = TextEditingController();
  final _listScrollController = ScrollController();
  final List<Report> _reports = [];
  final Set<ReportStatus> _selectedStatusFilters = <ReportStatus>{};

  List<Report> get _visibleReports {
    final query = _searchController.text.trim().toLowerCase();
    final homeReports = _reports
        .where(isHomeReportVisible)
        .where(_matchesStatusFilter);
    if (query.isEmpty) return homeReports.toList(growable: false);

    return homeReports
        .where((report) {
          final values = [
            report.title,
            report.description,
            report.zone,
            report.streetLandmark,
            report.barangay,
            report.cityMunicipality,
            report.categoryDisplay,
          ];
          return values.any(
            (value) => value?.toLowerCase().contains(query) ?? false,
          );
        })
        .toList(growable: false);
  }

  final List<ReportStatus?> _statusFilters = const [
    null,
    ReportStatus.submitted,
    ReportStatus.underReview,
    ReportStatus.inProgress,
    ReportStatus.escalated,
    ReportStatus.resolved,
  ];

  final String _selectedSort = 'date';
  bool get _hasNextPage => _currentPage < _totalPages;

  bool _matchesStatusFilter(Report report) {
    if (_selectedStatusFilters.isEmpty) return true;

    return _selectedStatusFilters.any((filter) {
      if (filter == ReportStatus.underReview) {
        return report.status == ReportStatus.underReview ||
            report.status == ReportStatus.verified ||
            report.status == ReportStatus.assigned ||
            report.status == ReportStatus.endorsed;
      }
      return report.status == filter;
    });
  }

  void _toggleStatusFilter(ReportStatus? status) {
    setState(() {
      if (status == null) {
        _selectedStatusFilters.clear();
      } else if (!_selectedStatusFilters.add(status)) {
        _selectedStatusFilters.remove(status);
      }
    });
  }

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
    final generation = ++_loadGeneration;
    setState(() {
      _isInitialLoading = true;
      _isLoadingMore = false;
      _loadError = null;
      _currentPage = 0;
      _totalPages = 1;
      _reports.clear();
    });

    final getReports = ref.read(getReportsUseCaseProvider);
    final result = await getReports(page: 1, sortBy: _selectedSort);

    if (!mounted || generation != _loadGeneration) return;

    result.when(
      success: (data) {
        final mergedReports = mergeHomeReports(<Report>[], data.results);

        setState(() {
          _reports.addAll(mergedReports);
          _currentPage = data.page;
          _totalPages = data.totalPages;
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

    final generation = _loadGeneration;
    setState(() => _isLoadingMore = true);

    try {
      final nextPage = _currentPage + 1;
      final getReports = ref.read(getReportsUseCaseProvider);
      final result = await getReports(page: nextPage, sortBy: _selectedSort);

      if (!mounted || generation != _loadGeneration) return;

      result.when(
        success: (data) {
          final mergedReports = mergeHomeReports(_reports, data.results);

          setState(() {
            _reports
              ..clear()
              ..addAll(mergedReports);
            _currentPage = data.page;
            _totalPages = data.totalPages;
          });
        },
        failure: (_) {},
      );
    } finally {
      // Always clear the paging flag, even if the future throws, so
      // infinite scroll cannot get stuck after a transient failure.
      if (mounted && generation == _loadGeneration) {
        setState(() => _isLoadingMore = false);
      }
    }
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
    final l10n = AppLocalizations.of(context);

    // Auto-refresh when a new report is created
    ref.listen<int>(myReportsRefreshProvider, (previous, next) {
      if (previous != null && next > previous) {
        _loadInitialReports();
      }
    });

    return Scaffold(
      // Search is always above the keyboard; resizing would also relayout the
      // map/list subtree for every IME inset frame.
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(l10n.home),
        actions: [
          IconButton(
            tooltip: l10n.retry,
            onPressed: _onRefresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final textScale = MediaQuery.textScalerOf(context).scale(1);
          final shouldScrollHeader =
              constraints.maxHeight < 640 || textScale > 1.15;
          final header = _buildHomeHeader(permissions, theme, l10n);

          return Column(
            children: [
              SizedBox(
                height: shouldScrollHeader
                    ? constraints.maxHeight * 0.48
                    : null,
                child: SingleChildScrollView(
                  physics: shouldScrollHeader
                      ? const ClampingScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  child: header,
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: _isMapView
                      ? _buildMapView(theme)
                      : _buildListView(theme),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHomeHeader(
    UserPermissions permissions,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        VerificationBanner(permissions: permissions),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: l10n.searchReports,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).deleteButtonTooltip,
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.clear),
                    ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    l10n.browseReports,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.homeGuidance,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final viewSelector = _buildViewSelector(l10n);
              final reportCount = _visibleReports.length;
              final count = Text(
                l10n.reportCount(reportCount),
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
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.filterByStatus,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
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
              final status = _statusFilters[index];
              final isSelected = status == null
                  ? _selectedStatusFilters.isEmpty
                  : _selectedStatusFilters.contains(status);
              final label = _statusFilterLabel(status, l10n);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: KeyedSubtree(
                  key: Key('home-status-filter-${status?.apiValue ?? 'all'}'),
                  child: CivicFilterChip(
                    label: label,
                    selected: isSelected,
                    onSelected: (_) => _toggleStatusFilter(status),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
      ],
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

  String _statusFilterLabel(ReportStatus? status, AppLocalizations l10n) {
    return switch (status) {
      null => l10n.all,
      ReportStatus.submitted => l10n.submitted,
      ReportStatus.underReview => l10n.underReview,
      ReportStatus.inProgress => l10n.inProgress,
      ReportStatus.resolved => l10n.resolvedStatus,
      ReportStatus.escalated => l10n.escalated,
      _ => l10n.status,
    };
  }

  Widget _buildMapView(ThemeData theme) {
    final l10n = AppLocalizations.of(context);

    if (_isInitialLoading) {
      return _buildLoadingState();
    }

    if (_loadError != null && _reports.isEmpty) {
      return _buildErrorState(theme);
    }

    final mapReports = _visibleReports;
    if (mapReports.isEmpty) {
      return _buildEmptyState(theme);
    }

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
            : MediaQuery.sizeOf(context).height;

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
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width - 32,
                      ),
                      child: Material(
                        color: theme.colorScheme.surface.withValues(
                          alpha: 0.92,
                        ),
                        elevation: 1,
                        shadowColor: theme.colorScheme.shadow.withValues(
                          alpha: 0.08,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              for (final status
                                  in _statusFilters.whereType<ReportStatus>())
                                _buildLegendItem(status, l10n),
                            ],
                          ),
                        ),
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

  Widget _buildLegendItem(ReportStatus status, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final color = reportStatusIndicatorColor(status);
    final isSelected = _selectedStatusFilters.contains(status);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FilterChip(
          key: Key('home-map-status-${status.apiValue}'),
          avatar: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.32),
                        blurRadius: 4,
                      ),
                    ]
                  : null,
            ),
          ),
          label: Text(_statusFilterLabel(status, l10n)),
          selected: isSelected,
          showCheckmark: false,
          backgroundColor: theme.colorScheme.surfaceContainerLow,
          selectedColor: color.withValues(
            alpha: theme.brightness == Brightness.dark ? 0.24 : 0.14,
          ),
          labelStyle: theme.textTheme.labelMedium?.copyWith(
            color: isSelected
                ? reportStatusForegroundColor(status, theme)
                : theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
          side: BorderSide.none,
          onSelected: (_) => _toggleStatusFilter(status),
        ),
      ],
    );
  }

  Widget _buildListView(ThemeData theme) {
    if (_isInitialLoading) {
      return _buildLoadingState();
    }

    if (_loadError != null && _reports.isEmpty) {
      return _buildErrorState(theme);
    }

    final visibleReports = _visibleReports;
    if (visibleReports.isEmpty) {
      return _buildEmptyState(theme);
    }

    final sectionItems = _buildSectionItems(visibleReports);

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
                    ? AppLocalizations.of(context).scrollLoadMore
                    : AppLocalizations.of(context).noMoreReports,
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
        final l10n = AppLocalizations.of(context);
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
    final l10n = AppLocalizations.of(context);
    if (date == null) return l10n.unknownDate;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) return l10n.today;
    if (date == yesterday) return l10n.yesterday;

    return MaterialLocalizations.of(context).formatMediumDate(date);
  }

  Widget _buildEmptyState(ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: EmptyContentPlaceholder(
            icon: Icons.location_off_outlined,
            title: AppLocalizations.of(context).noReportsFound,
            message: AppLocalizations.of(context).noReportsMatch,
            onRetry: _onRefresh,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        if (_isMapView)
          const CivicSkeletonBlock(height: 280, radius: 16)
        else ...[
          const _HomeSkeletonCard(),
          const SizedBox(height: 12),
          const _HomeSkeletonCard(),
          const SizedBox(height: 12),
          const _HomeSkeletonCard(),
        ],
      ],
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
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context).unableLoadReports,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    AppLocalizations.of(context).reportsNetworkError,
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: _onRefresh,
                  child: Text(AppLocalizations.of(context).retry),
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

class _HomeSkeletonCard extends StatelessWidget {
  const _HomeSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return CivicSurface(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CivicSkeletonBlock(width: 52, height: 52),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CivicSkeletonBlock(width: 120, height: 14),
                const SizedBox(height: 10),
                const CivicSkeletonBlock(height: 18),
                const SizedBox(height: 8),
                CivicSkeletonBlock(
                  width: MediaQuery.sizeOf(context).width * 0.48,
                  height: 14,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
