import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/presentation/widgets/empty_content_placeholder.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/user_permissions.dart';
import '../../auth/presentation/verification_widgets.dart';
import '../domain/entities/report.dart';
import '../presentation/report_detail_screen.dart';
import '../presentation/reports_controller.dart';
import '../reports_di.dart';
import '../../home/presentation/widgets/home_report_card.dart';

/// My Reports screen showing user's submitted reports.
class MyReportsScreen extends ConsumerStatefulWidget {
  const MyReportsScreen({super.key});

  @override
  ConsumerState<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends ConsumerState<MyReportsScreen> {
  int _selectedFilter = 0;

  bool _isInitialLoading = true;
  bool _isLoadingMore = false;
  bool _isNavigatingToReportDetail = false;
  String? _loadError;

  int _currentPage = 0;
  int _totalPages = 1;
  int _totalReports = 0;

  final _scrollController = ScrollController();
  final List<Report> _reports = [];

  final List<String?> _filters = const [
    null,
    'submitted',
    'under_review',
    'in_progress',
    'resolved',
    'closed',
    'rejected',
  ];

  String? get _selectedStatus => _filters[_selectedFilter];
  String get _selectedSort => 'date';
  bool get _hasNextPage => _currentPage < _totalPages;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialReports();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await _loadInitialReports();
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

    final getMyReports = ref.read(getMyReportsUseCaseProvider);
    final result = await getMyReports(
      page: 1,
      status: _selectedStatus,
      sortBy: _selectedSort,
    );

    if (!mounted) return;

    result.when(
      success: (data) {
        setState(() {
          _reports.addAll(data.results);
          _currentPage = data.page;
          _totalPages = data.totalPages;
          _totalReports = data.total;
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
    final getMyReports = ref.read(getMyReportsUseCaseProvider);
    final result = await getMyReports(
      page: nextPage,
      status: _selectedStatus,
      sortBy: _selectedSort,
    );

    if (!mounted) return;

    result.when(
      success: (data) {
        final existingIds = _reports.map((r) => r.id).toSet();
        final newReports = data.results
            .where((report) => !existingIds.contains(report.id))
            .toList();

        setState(() {
          _reports.addAll(newReports);
          _currentPage = data.page;
          _totalPages = data.totalPages;
          _totalReports = data.total;
          _isLoadingMore = false;
        });
      },
      failure: (_) {
        setState(() => _isLoadingMore = false);
      },
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 320;
    if (_scrollController.position.pixels >= threshold) {
      _loadNextPage();
    }
  }

  Future<void> _openReportDetail(String reportId) async {
    if (_isNavigatingToReportDetail || !mounted) return;

    setState(() => _isNavigatingToReportDetail = true);
    try {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ReportDetailScreen(reportId: reportId),
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

    // Auto-reload when a new report is submitted from the new-report flow.
    // The review screen calls increment() on MyReportsRefreshNotifier on success.
    ref.listen<int>(myReportsRefreshProvider, (previous, next) {
      if (next > (previous ?? 0)) {
        _loadInitialReports();
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myReports)),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: VerificationBanner(permissions: permissions),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Text(
                  l10n.reportCount(_totalReports),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
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
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
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
                        label: Text(_filterLabel(_filters[index], l10n)),
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
                            _selectedFilter = index;
                          });
                          _loadInitialReports();
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            _buildSliverContent(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverContent(ThemeData theme) {
    if (_isInitialLoading) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null && _reports.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _buildErrorState(theme, _loadError!),
      );
    }

    if (_reports.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _buildEmptyState(theme),
      );
    }

    final sectionItems = _buildSectionItems(_reports);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
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
            onTap: () => _openReportDetail(report.id),
          );
        }, childCount: sectionItems.length + 1),
      ),
    );
  }

  String _filterLabel(String? status, AppLocalizations l10n) {
    return switch (status) {
      null => l10n.all,
      'submitted' => l10n.submitted,
      'under_review' => l10n.underReview,
      'in_progress' => l10n.inProgress,
      'resolved' => l10n.resolvedStatus,
      'closed' => l10n.closed,
      'rejected' => l10n.rejected,
      _ => l10n.status,
    };
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
    // Personal history stays chronological regardless of operational priority.
    final sorted = [...reports]
      ..sort((a, b) {
        final aDate = a.createdAt ?? DateTime(0);
        final bDate = b.createdAt ?? DateTime(0);
        return bDate.compareTo(aDate);
      });

    final items = <_ReportSectionItem>[];
    DateTime? previousDate;

    for (final report in sorted) {
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
      icon: Icons.assignment_outlined,
      title: AppLocalizations.of(context)!.noReportsFound,
      message: AppLocalizations.of(context)!.noReportsForFilter,
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
