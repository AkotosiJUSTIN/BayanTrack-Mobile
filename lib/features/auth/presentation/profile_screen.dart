import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/providers/connectivity_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../l10n/app_localizations.dart';
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
import 'verification_widgets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileControllerProvider);
    final statsAsync = ref.watch(profileStatsControllerProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l10n.logout,
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
                      error: (_, _) =>
                          _buildProfileError(context, ref, theme),
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
                            l10n.version(
                              snapshot.data!.version,
                              snapshot.data!.buildNumber,
                            ),
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
    final l10n = AppLocalizations.of(context)!;

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

    final isDark = theme.brightness == Brightness.dark;
    final initials = getInitials();
    final displayName = getDisplayName();
    final roleLabel = profile.role.toLowerCase() == 'citizen'
        ? l10n.citizen
        : profile.role.toUpperCase();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.primary,
            child: profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      ApiConstants.getImageUrl(profile.avatarUrl!),
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      semanticLabel: '$displayName ${l10n.profilePicture}',
                      errorBuilder: (_, _, _) => Center(
                        child: Text(
                          initials,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                : Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                if (profile.phone != null && profile.phone!.isNotEmpty)
                  Text(
                    profile.phone!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                if (profile.avatarStorageStatus == 'degraded')
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      l10n.profilePictureBackupPending,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.tertiary,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    roleLabel,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isDark
                          ? AppColors.primaryLight
                          : AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileError(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          Icon(Icons.person_off_outlined, size: 48, color: AppColors.alertHigh),
          const SizedBox(height: 12),
          Text(l10n.profileLoadFailed, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: () => ref.invalidate(profileControllerProvider),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(
    BuildContext context,
    Map<String, int> stats,
    ThemeData theme,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: isDark ? 0.45 : 0.7,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              label: '${l10n.reports}: ${stats['total'] ?? 0}',
              child: _buildStatItem(
                context,
                l10n.reports,
                stats['total']?.toString() ?? '0',
                theme,
              ),
            ),
          ),
          const SizedBox(height: 40, child: VerticalDivider()),
          Expanded(
            child: Semantics(
              label: '${l10n.resolved}: ${stats['resolved'] ?? 0}',
              child: _buildStatItem(
                context,
                l10n.resolved,
                stats['resolved']?.toString() ?? '0',
                theme,
              ),
            ),
          ),
          const SizedBox(height: 40, child: VerticalDivider()),
          Expanded(
            child: Semantics(
              label: '${l10n.pending}: ${stats['pending'] ?? 0}',
              child: _buildStatItem(
                context,
                l10n.pending,
                stats['pending']?.toString() ?? '0',
                theme,
              ),
            ),
          ),
        ],
      ),
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
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
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
        final locale = ref.watch(appLocaleProvider);
        final l10n = AppLocalizations.of(context)!;
        return Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(l10n.editProfile),
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
                title: Text(l10n.changePassword),
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
                title: Text(l10n.notificationSettings),
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
                title: Text(l10n.theme),
                subtitle: Text(
                  themeMode == ThemeMode.dark
                      ? l10n.darkMode
                      : themeMode == ThemeMode.light
                      ? l10n.lightMode
                      : l10n.systemDefault,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => ref.read(themeModeProvider.notifier).toggleTheme(),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.translate),
                title: Text(l10n.language),
                subtitle: Text(
                  locale.languageCode == 'fil' ? l10n.filipino : l10n.english,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showLanguagePicker(context, ref, locale),
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
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const KycStatusScreen()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getKycStatusIcon(kycStatus?.status),
                      color: statusColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.userVerification,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          localizedVerificationStatusMessage(
                            permissions,
                            AppLocalizations.of(context)!,
                          ),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: statusColor),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: statusColor),
                ],
              ),
              if (!permissions.isVerified) ...[
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: () => _navigateToVerificationAction(
                    context,
                    ref,
                    permissions,
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.alertMedium,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.verified_user_outlined),
                  label: Text(
                    localizedVerificationActionLabel(
                      permissions,
                      AppLocalizations.of(context)!,
                    ),
                  ),
                ),
              ],
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
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.logout, style: const TextStyle(color: Colors.red)),
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

  Future<void> _showLanguagePicker(
    BuildContext context,
    WidgetRef ref,
    Locale currentLocale,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<Locale>(
              title: Text(l10n.english),
              value: const Locale('en'),
              groupValue: currentLocale,
              onChanged: (locale) async {
                if (locale == null) return;
                await ref.read(appLocaleProvider.notifier).setLocale(locale);
                if (sheetContext.mounted) Navigator.pop(sheetContext);
              },
            ),
            RadioListTile<Locale>(
              title: Text(l10n.filipino),
              value: const Locale('fil'),
              groupValue: currentLocale,
              onChanged: (locale) async {
                if (locale == null) return;
                await ref.read(appLocaleProvider.notifier).setLocale(locale);
                if (sheetContext.mounted) Navigator.pop(sheetContext);
              },
            ),
          ],
        ),
      ),
    );
  }
}
