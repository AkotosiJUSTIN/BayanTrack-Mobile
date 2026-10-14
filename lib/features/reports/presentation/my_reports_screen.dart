import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/presentation/widgets/civic_components.dart';
import '../../../core/presentation/widgets/app_toast.dart';
import '../../../core/presentation/widgets/empty_content_placeholder.dart';
import '../../../core/presentation/widgets/offline_stale_banner.dart';
import '../../../core/providers/backend_reachability_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/data/user_permissions.dart';
import '../../auth/presentation/verification_widgets.dart';
import '../../home/presentation/widgets/home_report_card.dart';
import '../domain/entities/report.dart';
import '../domain/entities/report_enums.dart';
import '../data/report_create_outbox.dart';
import '../data/report_draft_store.dart';
import '../presentation/report_detail_screen.dart';
import '../presentation/report_labels.dart';
import 'new_report/new_report_photos_screen.dart';
import 'new_report/quick_report_screen.dart';
import 'new_report/report_draft_prompt.dart';
import '../presentation/reports_controller.dart';
import '../reports_di.dart';

/// My Reports screen showing user's submitted reports.
class MyReportsScreen extends ConsumerStatefulWidget {
  const MyReportsScreen({super.key});

  @override
  ConsumerState<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends ConsumerState<MyReportsScreen> {
  int _selectedFilter = 0;

  bool _isInitialLoading = true;
  bool _isStale = false;
  bool _isLoadingMore = false;
  bool _isNavigatingToReportDetail = false;
  bool _isHandlingOutbox = false;
  String? _loadError;

  int _currentPage = 0;
  int _totalPages = 1;
  int _totalReports = 0;
  int _loadGeneration = 0;

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

  Future<void> _onRefresh() => _loadInitialReports();

  Future<void> _loadInitialReports({bool clearExisting = false}) async {
    final generation = ++_loadGeneration;
    setState(() {
      _isInitialLoading = clearExisting || _reports.isEmpty;
      _isLoadingMore = false;
      _loadError = null;
      if (clearExisting) {
        _currentPage = 0;
        _totalPages = 1;
        _totalReports = 0;
        _isStale = false;
        _reports.clear();
      }
    });

    final result = await ref.read(getMyReportsUseCaseProvider)(
      page: 1,
      status: _selectedStatus,
      sortBy: _selectedSort,
    );

    if (!mounted || generation != _loadGeneration) return;

    result.when(
      success: (data) {
        final uniqueReports = <String, Report>{
          for (final report in data.results) report.id: report,
        };
        setState(() {
          _reports
            ..clear()
            ..addAll(uniqueReports.values);
          _currentPage = data.page;
          _totalPages = data.totalPages;
          _totalReports = data.total;
          _isStale = data.isStale;
          _isInitialLoading = false;
        });
      },
      failure: (failure) {
        setState(() {
          _loadError = _reports.isEmpty ? failure.message : null;
          _isStale = _reports.isNotEmpty;
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
      final result = await ref.read(getMyReportsUseCaseProvider)(
        page: _currentPage + 1,
        status: _selectedStatus,
        sortBy: _selectedSort,
      );

      if (!mounted || generation != _loadGeneration) return;

      result.when(
        success: (data) {
          final existingIds = _reports.map((report) => report.id).toSet();
          final newReports = data.results
              .where((report) => !existingIds.contains(report.id))
              .toList();
          setState(() {
            _reports.addAll(newReports);
            _currentPage = data.page;
            _totalPages = data.totalPages;
            _totalReports = data.total;
            _isStale = _isStale || data.isStale;
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

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 320;
    if (_scrollController.position.pixels >= threshold) _loadNextPage();
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
      if (mounted) setState(() => _isNavigatingToReportDetail = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final ownerId = auth is AuthSuccess ? auth.user?.id : null;
    final outboxItems = ownerId == null
        ? const <ReportCreateOutboxItem>[]
        : ref.watch(reportCreateOutboxItemsProvider(ownerId)).asData?.value ??
              const <ReportCreateOutboxItem>[];
    final handoffPending = outboxItems
        .where(
          (item) =>
              item.status == ReportCreateOutboxStatus.synced &&
              !item.evidenceHandedOff &&
              item.attachmentRefs.isNotEmpty,
        )
        .toList();
    if (ownerId != null) {
      ref.listen(reportCreateOutboxItemsProvider(ownerId), (previous, next) {
        final before = previous?.asData?.value;
        final after = next.asData?.value;
        if (before == null || after == null) return;
        final beforePending = before
            .where((item) => item.isPending)
            .map((item) => item.localReportId)
            .toSet();
        final afterPending = after
            .where((item) => item.isPending)
            .map((item) => item.localReportId)
            .toSet();
        if (beforePending.difference(afterPending).isNotEmpty) {
          _loadInitialReports();
        }
      });
    }
    final reachability = ref.watch(backendReachabilityProvider);
    final backendUnreachable = reachability == BackendReachability.unreachable;
    final permissions = ref.watch(userPermissionsProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    ref.listen<int>(myReportsRefreshProvider, (previous, next) {
      if (next > (previous ?? 0)) _loadInitialReports();
    });
    ref.listen<BackendReachability>(backendReachabilityProvider, (
      previous,
      next,
    ) {
      if (previous == BackendReachability.unreachable &&
          next == BackendReachability.reachable) {
        _loadInitialReports();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myReports),
        actions: [
          IconButton(
            tooltip: l10n.retry,
            onPressed: _onRefresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: VerificationBanner(permissions: permissions),
            ),
            if (_isStale || backendUnreachable)
              const SliverToBoxAdapter(child: OfflineStaleBanner()),
            if (outboxItems.any((item) => item.isPending))
              SliverToBoxAdapter(
                child: _buildPendingOutbox(
                  outboxItems.where((item) => item.isPending).toList(),
                  theme,
                  l10n,
                ),
              ),
            if (handoffPending.isNotEmpty)
              SliverToBoxAdapter(
                child: _buildEvidenceHandoff(
                  handoffPending,
                  canRetry: reachability == BackendReachability.reachable,
                ),
              ),
            SliverToBoxAdapter(child: _buildOverview(theme, l10n)),
            SliverToBoxAdapter(
              child: CivicSectionHeading(title: l10n.filterByStatus),
            ),
            SliverToBoxAdapter(child: _buildFilters(l10n)),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            _buildSliverContent(theme, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingOutbox(
    List<ReportCreateOutboxItem> items,
    ThemeData theme,
    AppLocalizations l10n,
  ) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CivicSectionHeading(title: l10n.reportPendingSyncTitle),
        for (final item in items) _buildPendingItem(item, theme, l10n),
      ],
    ),
  );

  Widget _buildEvidenceHandoff(
    List<ReportCreateOutboxItem> items, {
    required bool canRetry,
  }) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CivicSectionHeading(title: l10n.reportEvidenceHandoffTitle),
          for (final item in items)
            CivicSurface(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.reportEvidenceHandoffPending,
                    style: theme.textTheme.bodyMedium,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: canRetry
                          ? () => ref
                                .read(reportCreateOutboxProvider)
                                .resume(item.ownerId)
                          : null,
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.reportEvidenceHandoffRetry),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPendingItem(
    ReportCreateOutboxItem item,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final emergency =
        item.type == ReportDraftType.emergency ||
        item.payload['isEmergency'] == true;
    final title = emergency
        ? l10n.emergencyReport
        : item.type == ReportDraftType.quick
        ? l10n.quickReport
        : l10n.fullReport;
    final statusMessage = switch (item.errorKind) {
      ReportCreateOutboxErrorKind.authentication =>
        l10n.reportOutboxWaitingAuth,
      ReportCreateOutboxErrorKind.network ||
      ReportCreateOutboxErrorKind.server => l10n.reportOutboxRetrying,
      ReportCreateOutboxErrorKind.conflict => l10n.reportOutboxConflict,
      ReportCreateOutboxErrorKind.systemRestriction =>
        l10n.governanceSyncPaused,
      ReportCreateOutboxErrorKind.validation ||
      ReportCreateOutboxErrorKind.unavailable =>
        item.safeError ?? l10n.reportOutboxNeedsEdit,
      null => l10n.reportPendingSync,
    };
    final themeColors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: CivicSurface(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  emergency
                      ? Icons.warning_amber_rounded
                      : Icons.cloud_upload_outlined,
                  color: emergency ? themeColors.error : themeColors.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(statusMessage, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            if (emergency) ...[
              const SizedBox(height: 10),
              Text(
                l10n.emergencyNotYetTransmitted,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: themeColors.error,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.emergencyCallGuidance,
                style: theme.textTheme.bodySmall,
              ),
            ],
            if (item.status == ReportCreateOutboxStatus.paused ||
                item.status == ReportCreateOutboxStatus.retryWaiting)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _isHandlingOutbox
                      ? null
                      : () => _handleOutboxAction(() => _retryOutbox(item)),
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.reportOutboxRetryNow),
                ),
              )
            else if (item.status == ReportCreateOutboxStatus.rejected)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _isHandlingOutbox
                      ? null
                      : () => _handleOutboxAction(() => _editOutbox(item)),
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(l10n.reportOutboxEdit),
                ),
              ),
            if (item.canDiscard)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _isHandlingOutbox
                      ? null
                      : () => _handleOutboxAction(() => _discardOutbox(item)),
                  icon: const Icon(Icons.delete_outline),
                  label: Text(l10n.discardDraft),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleOutboxAction(Future<void> Function() action) async {
    if (_isHandlingOutbox) return;
    setState(() => _isHandlingOutbox = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _isHandlingOutbox = false);
    }
  }

  Future<void> _retryOutbox(ReportCreateOutboxItem item) async {
    try {
      await ref
          .read(reportCreateOutboxProvider)
          .retry(item.ownerId, item.localReportId);
    } catch (_) {
      if (mounted) {
        AppToast.error(
          context,
          AppLocalizations.of(context).unableSubmitReport,
        );
      }
    }
  }

  Future<void> _editOutbox(ReportCreateOutboxItem item) async {
    try {
      await ref
          .read(reportCreateOutboxProvider)
          .restoreRejectedDraft(item.ownerId, item.localReportId);
    } on StateError catch (error) {
      if (mounted) AppToast.error(context, error.message.toString());
      return;
    } catch (_) {
      if (mounted) {
        AppToast.error(
          context,
          AppLocalizations.of(context).unableSubmitReport,
        );
      }
      return;
    }
    if (!mounted) return;
    final screen = item.type == ReportDraftType.full
        ? const NewReportPhotosScreen()
        : QuickReportScreen(
            emergencyMode: item.type == ReportDraftType.emergency,
            fastReportMode:
                item.type == ReportDraftType.quick &&
                item.payload['isEmergency'] == true,
          );
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  Future<void> _discardOutbox(ReportCreateOutboxItem item) async {
    if (!await confirmReportDraftDiscard(context) || !mounted) return;
    try {
      await ref
          .read(reportCreateOutboxProvider)
          .discard(item.ownerId, item.localReportId);
    } catch (_) {
      if (mounted) {
        AppToast.error(
          context,
          AppLocalizations.of(context).unableSubmitReport,
        );
      }
    }
  }

  Widget _buildOverview(ThemeData theme, AppLocalizations l10n) {
    final reviewCount = _reports
        .where((report) => report.needsCitizenReview)
        .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: CivicSurface(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final details = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.reportHistory,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.reportCount(_totalReports),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.myReportsGuidance,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            );
            if (reviewCount == 0) return details;

            final review = CivicStatusChip(
              label: l10n.reportsAwaitingReview(reviewCount),
              color: _resolvedColor(theme),
              icon: Icons.rate_review_outlined,
            );
            if (constraints.maxWidth < 420) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [details, const SizedBox(height: 12), review],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: details),
                review,
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilters(AppLocalizations l10n) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = _selectedFilter == index;
          return CivicFilterChip(
            label: _filterLabel(_filters[index], l10n),
            selected: selected,
            onSelected: (_) {
              setState(() => _selectedFilter = index);
              _loadInitialReports(clearExisting: true);
            },
          );
        },
      ),
    );
  }

  Widget _buildSliverContent(ThemeData theme, AppLocalizations l10n) {
    if (_isInitialLoading && _reports.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverList.builder(
          itemCount: 3,
          itemBuilder: (_, _) => const _ReportSkeleton(),
        ),
      );
    }

    if (_loadError != null && _reports.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: true,
        child: _buildErrorState(theme, l10n),
      );
    }

    if (_reports.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyContentPlaceholder(
          icon: Icons.assignment_outlined,
          title: l10n.noReportsFound,
          message: l10n.noReportsForFilter,
          onRetry: _onRefresh,
        ),
      );
    }

    final sectionItems = _buildSectionItems(_reports);
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList.builder(
        itemCount: sectionItems.length + 1,
        itemBuilder: (context, index) {
          if (index == sectionItems.length) {
            return _buildListFooter(theme, l10n);
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
            showCitizenReviewState: true,
            onTap: () => _openReportDetail(report.id),
          );
        },
      ),
    );
  }

  Widget _buildListFooter(ThemeData theme, AppLocalizations l10n) {
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
                _hasNextPage ? l10n.scrollLoadMore : l10n.noMoreReports,
                style: theme.textTheme.bodySmall,
              ),
      ),
    );
  }

  String _filterLabel(String? status, AppLocalizations l10n) =>
      switch (status) {
        null => l10n.all,
        'submitted' => l10n.submitted,
        'under_review' => l10n.underReview,
        'in_progress' => l10n.inProgress,
        'resolved' => l10n.resolvedStatus,
        'closed' => l10n.closed,
        'rejected' => l10n.rejected,
        _ => l10n.status,
      };

  List<_ReportSectionItem> _buildSectionItems(List<Report> reports) {
    final sorted = [...reports]
      ..sort((a, b) {
        final aDate = a.createdAt ?? DateTime(0);
        final bDate = b.createdAt ?? DateTime(0);
        final dateCompare = bDate.compareTo(aDate);
        if (dateCompare != 0) return dateCompare;
        return (b.queuePriorityLevel?.index ?? -1).compareTo(
          a.queuePriorityLevel?.index ?? -1,
        );
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
    final l10n = AppLocalizations.of(context);
    if (date == null) return l10n.unknownDate;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (date == today) return l10n.today;
    if (date == yesterday) return l10n.yesterday;
    return MaterialLocalizations.of(context).formatMediumDate(date);
  }

  Widget _buildErrorState(ThemeData theme, AppLocalizations l10n) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 56,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.unableLoadReports,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.reportsNetworkError,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.tonal(
                    onPressed: _onRefresh,
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _resolvedColor(ThemeData theme) =>
      reportStatusForegroundColor(ReportStatus.resolved, theme);
}

class _ReportSkeleton extends StatelessWidget {
  const _ReportSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CivicSurface(
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
      ),
    );
  }
}

class _ReportSectionItem {
  const _ReportSectionItem._({this.header, this.report});

  final String? header;
  final Report? report;

  factory _ReportSectionItem.header(String text) =>
      _ReportSectionItem._(header: text);

  factory _ReportSectionItem.report(Report report) =>
      _ReportSectionItem._(report: report);

  bool get isHeader => header != null;
}
