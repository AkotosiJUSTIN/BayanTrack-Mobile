import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/providers/connectivity_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../kyc/domain/entities/kyc_enums.dart';
import '../../kyc/presentation/kyc_controller.dart';
import '../../kyc/presentation/kyc_form_screen.dart';
import '../../kyc/presentation/kyc_status_screen.dart';
import '../../notifications/presentation/notification_settings_screen.dart';
import '../../kyc/domain/entities/kyc_status.dart';
import '../data/auth_models.dart';
import '../data/user_permissions.dart';
import 'auth_controller.dart';
import 'auth_wrapper.dart';
import 'profile_controller.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileControllerProvider);
    final statsAsync = ref.watch(profileStatsControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmLogout(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // Offline banner
          const OfflineBanner(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(profileControllerProvider);
                ref.invalidate(profileStatsControllerProvider);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // User Info
                    profileAsync.when(
                      data: (profile) =>
                          _buildProfileHeader(context, profile, theme),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Center(child: Text('Error: $err')),
                    ),
                    const SizedBox(height: 24),

                    // KYC Status Card
                    Consumer(
                      builder: (context, ref, _) {
                        final kycStatusAsync = ref.watch(
                          kycStatusControllerProvider,
                        );
                        return kycStatusAsync.when(
                          data: (kycStatus) =>
                              _buildKycStatusCard(context, ref, kycStatus),
                          loading: () => const SizedBox.shrink(),
                          error: (_, _) => const SizedBox.shrink(),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Stats
                    statsAsync.when(
                      data: (stats) => _buildStatsRow(context, stats, theme),
                      loading: () => const SizedBox(height: 80),
                      error: (_, _) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 24),

                    // Menu
                    _buildMenu(context),
                    const SizedBox(height: 16),

                    // App version
                    FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Version ${snapshot.data!.version} (${snapshot.data!.buildNumber})',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    UserProfile profile,
    ThemeData theme,
  ) {
    // Get initials, handling empty names
    String getInitials() {
      final firstInitial = profile.firstName.isNotEmpty
          ? profile.firstName[0].toUpperCase()
          : '';
      final lastInitial = profile.lastName.isNotEmpty
          ? profile.lastName[0].toUpperCase()
          : '';
      if (firstInitial.isEmpty && lastInitial.isEmpty) {
        return profile.email.isNotEmpty ? profile.email[0].toUpperCase() : '?';
      }
      return '$firstInitial$lastInitial';
    }

    // Get display name, handling empty names
    String getDisplayName() {
      final name = '${profile.firstName} ${profile.lastName}'.trim();
      return name.isNotEmpty ? name : profile.email.split('@').first;
    }

    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.primary,
          backgroundImage:
              profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty
              ? NetworkImage(ApiConstants.getImageUrl(profile.avatarUrl!))
              : null,
          child: profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty
              ? null
              : Text(
                  getInitials(),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
        const SizedBox(height: 16),
        Text(
          getDisplayName(),
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          profile.email,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: 8),
        Chip(
          label: Text(profile.role.toUpperCase()),
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          labelStyle: TextStyle(color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildStatsRow(
    BuildContext context,
    Map<String, int> stats,
    ThemeData theme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(
          context,
          'Reports',
          stats['total']?.toString() ?? '0',
          theme,
        ),
        _buildStatItem(
          context,
          'Resolved',
          stats['resolved']?.toString() ?? '0',
          theme,
        ),
        _buildStatItem(
          context,
          'Pending',
          stats['pending']?.toString() ?? '0',
          theme,
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    ThemeData theme,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }

  Widget _buildMenu(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final themeMode = ref.watch(themeModeProvider);
        return Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Edit Profile'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  );
                  // Refresh profile data when returning from edit screen
                  // so avatar and name changes appear immediately.
                  ref.invalidate(profileControllerProvider);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('Change Password'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordScreen(),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: const Text('Notification Settings'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NotificationSettingsScreen(),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(
                  themeMode == ThemeMode.dark
                      ? Icons.dark_mode
                      : themeMode == ThemeMode.light
                      ? Icons.light_mode
                      : Icons.brightness_auto,
                ),
                title: const Text('Theme'),
                subtitle: Text(
                  themeMode == ThemeMode.dark
                      ? 'Dark Mode'
                      : themeMode == ThemeMode.light
                      ? 'Light Mode'
                      : 'System Default',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => ref.read(themeModeProvider.notifier).toggleTheme(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKycStatusCard(
    BuildContext context,
    WidgetRef ref,
    KycStatusEntity? kycStatus,
  ) {
    final permissions = ref.watch(userPermissionsProvider);
    final statusColor = _getKycStatusColor(kycStatus?.status);

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const KycStatusScreen()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getKycStatusIcon(kycStatus?.status),
                  color: statusColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Verification',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      permissions.getStatusMessage(),
                      style: TextStyle(fontSize: 14, color: statusColor),
                    ),
                    if (!permissions.isVerified) ...[
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => _navigateToVerificationAction(
                          context,
                          ref,
                          permissions,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.alertMedium,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Verify Identity'),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: statusColor),
            ],
          ),
        ),
      ),
    );
  }

  Color _getKycStatusColor(KycVerificationStatus? status) {
    if (status == null) return AppColors.alertMedium;

    switch (status) {
      case KycVerificationStatus.verified:
        return AppColors.success;
      case KycVerificationStatus.pending:
        return AppColors.alertMedium;
      case KycVerificationStatus.rejected:
      case KycVerificationStatus.resubmitRequested:
      case KycVerificationStatus.suspended:
        return AppColors.alertHigh;
      case KycVerificationStatus.unverified:
        return AppColors.lightTextSecondary;
    }
  }

  IconData _getKycStatusIcon(KycVerificationStatus? status) {
    if (status == null) return Icons.shield_outlined;

    switch (status) {
      case KycVerificationStatus.verified:
        return Icons.verified_user;
      case KycVerificationStatus.pending:
        return Icons.hourglass_empty;
      case KycVerificationStatus.rejected:
        return Icons.cancel;
      case KycVerificationStatus.resubmitRequested:
        return Icons.refresh;
      case KycVerificationStatus.suspended:
        return Icons.block;
      case KycVerificationStatus.unverified:
        return Icons.shield_outlined;
    }
  }

  Future<void> _navigateToVerificationAction(
    BuildContext context,
    WidgetRef ref,
    UserPermissions permissions,
  ) async {
    if (permissions.canSubmitKyc) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const KycFormScreen()),
      );
      if (result == true) {
        ref.read(kycStatusControllerProvider.notifier).refresh();
      }
      return;
    }

    if (permissions.canResubmitKyc) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => KycFormScreen(
            isResubmission: true,
            existingKyc: permissions.kycStatus,
          ),
        ),
      );
      if (result == true) {
        ref.read(kycStatusControllerProvider.notifier).refresh();
      }
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const KycStatusScreen()),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Logout and wait for session cleanup before remounting auth flow.
      await ref.read(authControllerProvider.notifier).logout();
      // Navigate to AuthWrapper which will show LoginScreen based on auth state
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
        (route) => false,
      );
    }
  }
}
