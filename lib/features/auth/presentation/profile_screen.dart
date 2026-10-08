import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/presentation/widgets/civic_components.dart';
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
import '../../help/presentation/help_screens.dart';
import '../../system_governance/system_governance_gate.dart';
import '../../system_governance/system_governance_provider.dart';
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
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile)),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(profileControllerProvider);
                ref.invalidate(profileStatsControllerProvider);
                try {
                  await Future.wait([
                    ref.read(profileControllerProvider.future),
                    ref.read(profileStatsControllerProvider.future),
                  ]);
                } catch (_) {
                  // The refreshed sections render their own retry states.
                }
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                children: [
                  profileAsync.when(
                    data: (profile) =>
                        _buildProfileHeader(context, profile, theme),
                    loading: () => const _ProfileSkeleton(),
                    error: (_, _) => _buildProfileError(context, ref, theme),
                  ),
                  const SizedBox(height: 20),
                  statsAsync.when(
                    data: (stats) => _buildStatsRow(context, stats, theme),
                    loading: () => const _StatsSkeleton(),
                    error: (_, _) => Center(
                      child: TextButton.icon(
                        onPressed: () =>
                            ref.invalidate(profileStatsControllerProvider),
                        icon: const Icon(Icons.refresh, size: 18),
                        label: Text(l10n.retry),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  CivicSectionHeading(title: l10n.userVerification),
                  Consumer(
                    builder: (context, ref, _) {
                      final kycStatusAsync = ref.watch(
                        kycStatusControllerProvider,
                      );
                      return kycStatusAsync.when(
                        data: (kycStatus) =>
                            _buildKycStatusCard(context, ref, kycStatus),
                        loading: () => const CivicSkeletonBlock(height: 108),
                        error: (_, _) =>
                            _buildKycStatusCard(context, ref, null),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  CivicSectionHeading(title: l10n.accountSecurity),
                  _buildAccountMenu(context),
                  const SizedBox(height: 24),
                  CivicSectionHeading(title: l10n.preferences),
                  _buildPreferencesMenu(context),
                  const SizedBox(height: 24),
                  const HelpSafetySection(),
                  const SizedBox(height: 16),
                  CivicSettingsGroup(
                    children: [
                      CivicSettingsRow(
                        key: const ValueKey('profile-terms-and-privacy'),
                        icon: Icons.description_outlined,
                        title: l10n.termsAndPrivacy,
                        showDivider: false,
                        onTap: () {
                          ref.invalidate(publishedTermsProvider);
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  const CurrentTermsScreen(readOnly: true),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildLogoutTile(context, ref),
                  const SizedBox(height: 16),
                  FutureBuilder<PackageInfo>(
                    future: PackageInfo.fromPlatform(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox.shrink();
                      return Text(
                        l10n.version(
                          snapshot.data!.version,
                          snapshot.data!.buildNumber,
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                ],
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
    final l10n = AppLocalizations.of(context);

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

    final initials = getInitials();
    final displayName = getDisplayName();
    final roleLabel = profile.role.toLowerCase() == 'citizen'
        ? l10n.citizen
        : profile.role.toUpperCase();

    return CivicSurface(
      padding: const EdgeInsets.all(16),
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
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (profile.phone != null && profile.phone!.isNotEmpty)
                  Text(
                    profile.phone!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                if (profile.avatarStorageStatus == 'degraded')
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      l10n.profilePictureBackupPending,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
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
                      color: theme.brightness == Brightness.dark
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
    final l10n = AppLocalizations.of(context);
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
    final l10n = AppLocalizations.of(context);

    return CivicSurface(
      padding: const EdgeInsets.symmetric(vertical: 12),
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
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountMenu(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final l10n = AppLocalizations.of(context);
        return CivicSettingsGroup(
          children: [
            CivicSettingsRow(
              icon: Icons.person_outline,
              title: l10n.editProfile,
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                );
                // Refresh profile data when returning from edit screen
                // so avatar and name changes appear immediately.
                ref.invalidate(profileControllerProvider);
              },
            ),
            CivicSettingsRow(
              icon: Icons.lock_outline,
              title: l10n.changePassword,
              showDivider: false,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ChangePasswordScreen(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildPreferencesMenu(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final themeMode = ref.watch(themeModeProvider);
        final locale = ref.watch(appLocaleProvider);
        final l10n = AppLocalizations.of(context);
        return CivicSettingsGroup(
          children: [
            CivicSettingsRow(
              icon: Icons.notifications_outlined,
              title: l10n.notificationSettings,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const NotificationSettingsScreen(),
                  ),
                );
              },
            ),
            CivicSettingsRow(
              icon: themeMode == ThemeMode.dark
                  ? Icons.dark_mode
                  : themeMode == ThemeMode.light
                  ? Icons.light_mode
                  : Icons.brightness_auto,
              title: l10n.theme,
              subtitle: themeMode == ThemeMode.dark
                  ? l10n.darkMode
                  : themeMode == ThemeMode.light
                  ? l10n.lightMode
                  : l10n.systemDefault,
              onTap: () => ref.read(themeModeProvider.notifier).toggleTheme(),
            ),
            CivicSettingsRow(
              key: const ValueKey('profile-language'),
              icon: Icons.translate,
              title: l10n.language,
              subtitle: locale.languageCode == 'fil'
                  ? l10n.filipino
                  : l10n.english,
              showDivider: false,
              onTap: () => _showLanguagePicker(context, ref, locale),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLogoutTile(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return CivicSettingsGroup(
      children: [
        CivicSettingsRow(
          icon: Icons.logout,
          title: l10n.logout,
          destructive: true,
          showDivider: false,
          onTap: () => _confirmLogout(context, ref),
        ),
      ],
    );
  }

  Widget _buildKycStatusCard(
    BuildContext context,
    WidgetRef ref,
    KycStatusEntity? kycStatus,
  ) {
    final permissions = ref.watch(userPermissionsProvider);
    final theme = Theme.of(context);
    final statusColor = _getKycStatusColor(theme, kycStatus?.status);
    final l10n = AppLocalizations.of(context);

    return CivicSurface(
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
                          l10n.userVerification,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          localizedVerificationStatusMessage(permissions, l10n),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: statusColor,
                          ),
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
                  onPressed: () =>
                      _navigateToVerificationAction(context, ref, permissions),
                  icon: const Icon(Icons.verified_user_outlined),
                  label: Text(
                    localizedVerificationActionLabel(permissions, l10n),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getKycStatusColor(ThemeData theme, KycVerificationStatus? status) {
    final isDark = theme.brightness == Brightness.dark;
    if (status == null) {
      return isDark ? AppColors.pendingTextDark : AppColors.pendingText;
    }

    switch (status) {
      case KycVerificationStatus.verified:
        return isDark ? AppColors.resolvedTextDark : AppColors.resolvedText;
      case KycVerificationStatus.pending:
        return isDark ? AppColors.pendingTextDark : AppColors.pendingText;
      case KycVerificationStatus.rejected:
      case KycVerificationStatus.resubmitRequested:
      case KycVerificationStatus.suspended:
        return isDark ? AppColors.rejectedTextDark : AppColors.rejectedText;
      case KycVerificationStatus.unverified:
        return isDark
            ? AppColors.darkTextSecondary
            : AppColors.lightTextSecondary;
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
    final l10n = AppLocalizations.of(context);
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
            child: Text(
              l10n.logout,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
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
    final l10n = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: RadioGroup<Locale>(
          groupValue: currentLocale,
          onChanged: (locale) async {
            if (locale == null) return;
            await ref.read(appLocaleProvider.notifier).setLocale(locale);
            if (sheetContext.mounted) Navigator.pop(sheetContext);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<Locale>(
                title: Text(l10n.english),
                value: const Locale('en'),
              ),
              RadioListTile<Locale>(
                title: Text(l10n.filipino),
                value: const Locale('fil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return CivicSurface(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CivicSkeletonBlock(width: 64, height: 64, radius: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CivicSkeletonBlock(width: 150, height: 18),
                const SizedBox(height: 10),
                const CivicSkeletonBlock(width: 190, height: 14),
                const SizedBox(height: 8),
                const CivicSkeletonBlock(width: 92, height: 24, radius: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsSkeleton extends StatelessWidget {
  const _StatsSkeleton();

  @override
  Widget build(BuildContext context) {
    return CivicSurface(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          3,
          (_) => const Column(
            children: [
              CivicSkeletonBlock(width: 34, height: 20),
              SizedBox(height: 8),
              CivicSkeletonBlock(width: 52, height: 13),
            ],
          ),
        ),
      ),
    );
  }
}
