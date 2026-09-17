import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../auth/data/user_permissions.dart';
import '../auth/presentation/verification_widgets.dart';
import '../auth/presentation/profile_screen.dart';
import '../home/presentation/home_screen.dart';
import '../images/presentation/evidence_upload_status_banner.dart';
import '../notifications/presentation/notifications_screen.dart';
import '../reports/presentation/my_reports_screen.dart';
import '../reports/presentation/new_report/quick_report_screen.dart';
import '../reports/presentation/new_report/new_report_photos_screen.dart';

/// Main navigation shell with bottom nav bar and center FAB.
/// Handles tab switching between Home, My Reports, Notifications, Profile.
class MainNavigationShell extends ConsumerStatefulWidget {
  const MainNavigationShell({super.key, this.screens});

  @visibleForTesting
  final List<Widget>? screens;

  @override
  ConsumerState<MainNavigationShell> createState() =>
      _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> {
  int _currentIndex = 0;
  bool _isNavigatingToNewReport = false;

  @override
  void initState() {
    super.initState();
  }

  late final List<Widget> _screens =
      widget.screens ??
      [
        const HomeScreen(),
        const MyReportsScreen(),
        const NotificationsScreen(),
        const ProfileScreen(),
      ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onFabPressed() {
    if (_isNavigatingToNewReport || !mounted) return;

    final permissions = ref.read(userPermissionsProvider);
    final l10n = AppLocalizations.of(context);

    if (!permissions.hasPermission(UserPermission.createReports)) {
      showVerificationRequiredDialog(context, permissions, l10n.createReport);
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.createReport,
                  style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.chooseReportType,
                  style: Theme.of(sheetContext).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _openReportFlow(const QuickReportScreen());
                  },
                  icon: const Icon(Icons.flash_on),
                  label: Text(l10n.quickReport),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _openReportFlow(const NewReportPhotosScreen());
                  },
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(l10n.fullReport),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openReportFlow(Widget page) {
    if (_isNavigatingToNewReport || !mounted) return;

    setState(() => _isNavigatingToNewReport = true);
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => page)).whenComplete(() {
      if (mounted) {
        setState(() => _isNavigatingToNewReport = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final navigationHeight =
        72.0 + ((textScale - 1).clamp(0.0, 1.0) * 20).toDouble();

    return Scaffold(
      body: Column(
        children: [
          const EvidenceUploadFeedback(),
          Expanded(
            child: IndexedStack(index: _currentIndex, children: _screens),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 24),
        child: FloatingActionButton(
          onPressed: _onFabPressed,
          elevation: 4,
          tooltip: l10n.createReport,
          child: const Icon(Icons.add, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 7,
        color: theme.colorScheme.surface,
        elevation: 2,
        padding: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.08),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: navigationHeight,
            child: Row(
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: l10n.home,
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.description_outlined,
                  activeIcon: Icons.description,
                  label: l10n.myReports,
                ),
                const SizedBox(width: 72),
                _buildNavItem(
                  index: 2,
                  icon: Icons.notifications_outlined,
                  activeIcon: Icons.notifications,
                  label: l10n.notifications,
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: l10n.profile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);
    final color = isSelected
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurfaceVariant;

    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        label: label,
        child: Tooltip(
          message: label,
          child: InkWell(
            onTap: () => _onTabTapped(index),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : const Duration(milliseconds: 160),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primaryContainer
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isSelected ? activeIcon : icon,
                      color: color,
                      size: 23,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: color,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
