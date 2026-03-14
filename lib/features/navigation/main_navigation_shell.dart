import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../auth/data/user_permissions.dart';
import '../auth/presentation/verification_widgets.dart';
import '../auth/presentation/profile_screen.dart';
import '../home/presentation/home_screen.dart';
import 'placeholder_screens.dart';
import '../reports/presentation/my_reports_screen.dart';
import '../reports/presentation/new_report/new_report_photos_screen.dart';

/// Main navigation shell with bottom nav bar and center FAB.
/// Handles tab switching between Home, My Reports, Notifications, Profile.
class MainNavigationShell extends ConsumerStatefulWidget {
  const MainNavigationShell({super.key});

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
    debugPrint('[MainNavigationShell] Initializing...');
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const MyReportsScreen(),
    const NotificationsPlaceholder(),
    const ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onFabPressed() {
    if (_isNavigatingToNewReport || !mounted) return;

    // Check if user has permission to create reports
    final permissions = ref.read(userPermissionsProvider);

    if (!permissions.hasPermission(UserPermission.createReports)) {
      showVerificationRequiredDialog(context, permissions, 'create reports');
      return;
    }

    // Navigate to new report flow, guarded to prevent duplicate pushes.
    setState(() => _isNavigatingToNewReport = true);
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const NewReportPhotosScreen()))
        .whenComplete(() {
          if (mounted) {
            setState(() => _isNavigatingToNewReport = false);
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[MainNavigationShell] Building with index: $_currentIndex');
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: FloatingActionButton(
          onPressed: _onFabPressed,
          elevation: 4,
          child: const Icon(Icons.add, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        elevation: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.description_outlined,
                activeIcon: Icons.description,
                label: 'My Reports',
              ),
              const SizedBox(width: 48), // Space for FAB
              _buildNavItem(
                index: 2,
                icon: Icons.notifications_outlined,
                activeIcon: Icons.notifications,
                label: 'Notifications',
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
              ),
            ],
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
    final isDark = theme.brightness == Brightness.dark;

    final color = isSelected
        ? AppColors.primary
        : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary);

    return InkWell(
      onTap: () => _onTabTapped(index),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isSelected ? activeIcon : icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
