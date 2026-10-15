import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/presentation/widgets/civic_components.dart';
import '../../../core/presentation/failure_message.dart';
import '../../../core/presentation/widgets/empty_content_placeholder.dart';
import '../../../core/presentation/widgets/app_toast.dart';
import '../../../core/presentation/widgets/offline_stale_banner.dart';
import '../../../core/providers/backend_reachability_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/user_permissions.dart';
import '../../auth/presentation/barangays_provider.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/presentation/verification_widgets.dart';
import '../../images/data/evidence_file_stager.dart';
import '../../images/presentation/evidence_photo_review.dart';
import '../../images/data/evidence_upload_queue.dart';
import '../../images/data/evidence_upload_queue_provider.dart';
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
  const HomeScreen({super.key, this.addFollowUpImageOverride});

  @visibleForTesting
  final Future<bool> Function(String reportId, ImageSource source)?
  addFollowUpImageOverride;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isMapView = true;
  bool _isMapLegendExpanded = false;
  bool _isNavigatingToReportDetail = false;
  bool _isInitialLoading = true;
  bool _isStale = false;
  bool _isLoadingMore = false;
  String? _loadError;

  int _currentPage = 0;
  int _totalPages = 1;
  int _loadGeneration = 0;

  final _searchController = TextEditingController();
  final _listScrollController = ScrollController();
  final List<Report> _reports = [];
  final Set<ReportStatus> _selectedStatusFilters = <ReportStatus>{};
  Report? _fastReportFollowUp;
  String? _fastReportFollowUpError;
  bool _isUpdatingFastReport = false;

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
    unawaited(_loadFastReportFollowUp());
  }

  @override
  void dispose() {
    _listScrollController.removeListener(_onListScroll);
    _listScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await Future.wait([_loadInitialReports(), _loadFastReportFollowUp()]);
    ref.invalidate(kycStatusControllerProvider);
  }

  String _fastReportFollowUpKey(String reportId) =>
      'fast_report_follow_up_v1_$reportId';

  Future<void> _loadFastReportFollowUp() async {
    final auth = ref.read(authControllerProvider);
    if (auth is! AuthSuccess || auth.user == null) return;

    try {
      final result = await ref.read(getMyReportsUseCaseProvider)(
        page: 1,
        pageSize: 20,
        sortBy: 'date',
      );
      final preferences = await SharedPreferences.getInstance();
      Report? eligible;
      result.when(
        success: (data) {
          final candidates =
              data.results
                  .where((report) => report.isEmergency && report.isQuickReport)
                  .where((report) => report.coreImages.isEmpty)
                  .where(
                    (report) =>
                        preferences.getString(
                          _fastReportFollowUpKey(report.id),
                        ) ==
                        null,
                  )
                  .toList()
                ..sort(
                  (left, right) => (right.createdAt ?? DateTime(1970))
                      .compareTo(left.createdAt ?? DateTime(1970)),
                );
          eligible = candidates.isEmpty ? null : candidates.first;
        },
        failure: (_) {},
      );
      if (!mounted) return;
      setState(() => _fastReportFollowUp = eligible);
    } catch (_) {
      // The public dashboard remains usable when the private report list fails.
    }
  }

  Future<void> _completeFastReportFollowUp(String outcome) async {
    final report = _fastReportFollowUp;
    if (report == null) return;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_fastReportFollowUpKey(report.id), outcome);
    if (mounted) {
      setState(() {
        _fastReportFollowUp = null;
        _fastReportFollowUpError = null;
        _isUpdatingFastReport = false;
      });
    }
  }

  Future<void> _dismissFastReportFollowUp() =>
      _completeFastReportFollowUp('dismissed');

  Future<void> _addFastReportDetails() async {
    final report = _fastReportFollowUp;
    if (report == null || _isUpdatingFastReport) return;
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final details = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.addDetails),
        content: TextField(
          key: const Key('fast-report-follow-up-details'),
          controller: controller,
          autofocus: true,
          minLines: 3,
          maxLines: 6,
          maxLength: 2000,
          decoration: InputDecoration(hintText: l10n.emergencyDetailsHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) Navigator.pop(dialogContext, value);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    // showDialog completes when dismissal starts; keep the controller alive
    // until the route transition has detached its TextField.
    unawaited(
      Future<void>.delayed(kThemeAnimationDuration, controller.dispose),
    );
    if (!mounted || details == null) return;

    setState(() {
      _isUpdatingFastReport = true;
      _fastReportFollowUpError = null;
    });
    final enrichedDescription = report.description.trim().isEmpty
        ? details
        : '${report.description.trim()}\n\nAdditional details:\n$details';
    try {
      final result = await ref.read(updateReportUseCaseProvider)(
        id: report.id,
        description: enrichedDescription,
      );
      if (!mounted) return;
      await result.when(
        success: (_) async {
          AppToast.success(context, l10n.detailsSaved);
          await _completeFastReportFollowUp('details_added');
        },
        failure: (failure) async {
          setState(() {
            _isUpdatingFastReport = false;
            _fastReportFollowUpError = localizedFailureMessage(
              failure,
              l10n,
              fallback: l10n.unableSubmitReport,
            );
          });
        },
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _isUpdatingFastReport = false;
          _fastReportFollowUpError = l10n.unableSubmitReport;
        });
      }
    }
  }

  Future<void> _addFastReportImage() async {
    final report = _fastReportFollowUp;
    if (report == null || _isUpdatingFastReport) return;
    final l10n = AppLocalizations.of(context);
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text(l10n.takePhoto),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.gallery),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (!mounted || source == null) return;

    final addFollowUpImageOverride = widget.addFollowUpImageOverride;
    if (addFollowUpImageOverride != null) {
      setState(() {
        _isUpdatingFastReport = true;
        _fastReportFollowUpError = null;
      });
      try {
        final accepted = await addFollowUpImageOverride(report.id, source);
        if (!mounted) return;
        if (accepted) {
          await _completeFastReportFollowUp('image_added');
        } else {
          setState(() {
            _isUpdatingFastReport = false;
            _fastReportFollowUpError = l10n.evidenceUploadFailed;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _isUpdatingFastReport = false;
            _fastReportFollowUpError = l10n.evidenceUploadFailed;
          });
        }
      }
      return;
    }

    setState(() {
      _isUpdatingFastReport = true;
      _fastReportFollowUpError = null;
    });

    var queueAccepted = false;
    File? staged;
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 75,
      );
      if (!mounted) return;
      if (picked == null) {
        setState(() => _isUpdatingFastReport = false);
        return;
      }
      final reviewed = await reviewEvidencePhoto(
        context,
        picked,
        sensitive:
            report.isEmergency ||
            (report.assignedDepartmentKey ?? report.assignedDepartment)
                    ?.trim()
                    .toLowerCase() ==
                'mdrrmo',
      );
      if (!mounted) return;
      if (reviewed == null) {
        setState(() => _isUpdatingFastReport = false);
        return;
      }
      staged = await stageEvidenceFile(reviewed);
      final auth = ref.read(authControllerProvider);
      final userId = auth is AuthSuccess ? auth.user?.id : null;
      if (userId == null) throw StateError('No authenticated user');
      final queue = await ref.read(evidenceUploadQueueProvider.future);
      final intents = await queue.enqueue(
        userId: userId,
        reportId: report.id,
        files: [staged],
      );
      queueAccepted =
          intents.length == 1 &&
          intents.single.state != EvidenceUploadState.missingLocalFile;
      if (!queueAccepted) throw StateError('Evidence could not be queued');
      unawaited(queue.resume(userId));
      if (!mounted) return;
      AppToast.success(context, l10n.evidenceUploadsPending(1));
      await _completeFastReportFollowUp('image_added');
    } catch (_) {
      if (!queueAccepted && staged != null) await discardEvidenceDraft(staged);
      if (mounted) {
        setState(() {
          _isUpdatingFastReport = false;
          _fastReportFollowUpError = l10n.evidenceUploadFailed;
        });
      }
    }
  }

  Future<void> _loadInitialReports() async {
    final generation = ++_loadGeneration;
    setState(() {
      _isInitialLoading = _reports.isEmpty;
      _isLoadingMore = false;
      _loadError = null;
      if (_reports.isEmpty) {
        _currentPage = 0;
        _totalPages = 1;
      }
    });

    final getReports = ref.read(getReportsUseCaseProvider);
    final result = await getReports(page: 1, sortBy: _selectedSort);

    if (!mounted || generation != _loadGeneration) return;

    result.when(
      success: (data) {
        final mergedReports = mergeHomeReports(<Report>[], data.results);

        setState(() {
          _reports
            ..clear()
            ..addAll(mergedReports);
          _currentPage = data.page;
          _totalPages = data.totalPages;
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
    final backendUnreachable =
        ref.watch(backendReachabilityProvider) ==
        BackendReachability.unreachable;
    final permissions = ref.watch(userPermissionsProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    // Auto-refresh when a new report is created
    ref.listen<int>(myReportsRefreshProvider, (previous, next) {
      if (previous != null && next > previous) {
        _loadInitialReports();
        _loadFastReportFollowUp();
      }
    });
    ref.listen<BackendReachability>(backendReachabilityProvider, (
      previous,
      next,
    ) {
      if (previous == BackendReachability.unreachable &&
          next == BackendReachability.reachable) {
        _loadInitialReports();
        _loadFastReportFollowUp();
      }
    });

    return Scaffold(
      // Search is always above the keyboard; resizing would also relayout the
      // map/list subtree for every IME inset frame.
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text(l10n.home)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final textScale = MediaQuery.textScalerOf(context).scale(1);
          final shouldScrollHeader =
              constraints.maxHeight < 640 || textScale > 1.15;
          final header = _buildHomeHeader(permissions, theme, l10n);

          return Column(
            children: [
              if (_isStale || backendUnreachable) const OfflineStaleBanner(),
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
        VerificationBanner(permissions: permissions, compact: true),
        if (_fastReportFollowUp != null)
          _buildFastReportFollowUpCard(theme, l10n),
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

  Widget _buildFastReportFollowUpCard(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Card(
        key: const Key('fast-report-follow-up-card'),
        color: theme.colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.emergency_outlined,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.completeFastReport,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                l10n.completeFastReportBody,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
              if (_fastReportFollowUpError != null) ...[
                const SizedBox(height: 8),
                Text(
                  _fastReportFollowUpError!,
                  key: const Key('fast-report-follow-up-error'),
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ],
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.tonalIcon(
                    key: const Key('fast-report-add-image'),
                    onPressed: _isUpdatingFastReport
                        ? null
                        : _addFastReportImage,
                    icon: const Icon(Icons.add_a_photo_outlined),
                    label: Text(l10n.addImage),
                  ),
                  FilledButton.tonalIcon(
                    key: const Key('fast-report-add-details'),
                    onPressed: _isUpdatingFastReport
                        ? null
                        : _addFastReportDetails,
                    icon: const Icon(Icons.notes_outlined),
                    label: Text(l10n.addDetails),
                  ),
                  TextButton(
                    key: const Key('fast-report-dismiss'),
                    onPressed: _isUpdatingFastReport
                        ? null
                        : _dismissFastReportFollowUp,
                    child: Text(l10n.dismiss),
                  ),
                ],
              ),
            ],
          ),
        ),
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
                        maxWidth: constraints.maxWidth - 32,
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
                            horizontal: 8,
                            vertical: 6,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Semantics(
                                expanded: _isMapLegendExpanded,
                                child: TextButton.icon(
                                  key: const Key('home-map-legend-toggle'),
                                  onPressed: () => setState(() {
                                    _isMapLegendExpanded =
                                        !_isMapLegendExpanded;
                                  }),
                                  style: TextButton.styleFrom(
                                    foregroundColor:
                                        theme.colorScheme.onSurface,
                                    minimumSize: const Size(0, 48),
                                  ),
                                  icon: Icon(
                                    _isMapLegendExpanded
                                        ? Icons.expand_more
                                        : Icons.info_outline,
                                    size: 20,
                                  ),
                                  label: Text(l10n.pinColors),
                                ),
                              ),
                              if (_isMapLegendExpanded)
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxHeight: viewportHeight * 0.4,
                                  ),
                                  child: SingleChildScrollView(
                                    child: Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: [
                                        for (final status
                                            in _statusFilters
                                                .whereType<ReportStatus>())
                                          _buildLegendItem(status, l10n),
                                      ],
                                    ),
                                  ),
                                ),
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
            width: 8,
            height: 8,
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
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          backgroundColor: theme.colorScheme.surfaceContainerLow,
          selectedColor: color.withValues(
            alpha: theme.brightness == Brightness.dark ? 0.24 : 0.14,
          ),
          labelStyle: theme.textTheme.labelSmall?.copyWith(
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
