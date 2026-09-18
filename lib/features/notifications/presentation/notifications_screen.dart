import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/presentation/widgets/app_toast.dart';
import '../../../core/presentation/widgets/civic_components.dart';
import '../../../core/presentation/widgets/empty_content_placeholder.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/user_permissions.dart';
import '../../auth/presentation/verification_widgets.dart';
import '../../reports/presentation/report_detail_screen.dart';
import '../../reports/presentation/report_labels.dart';
import '../domain/entities/notification.dart';
import '../domain/entities/notification_type.dart';
import '../domain/entities/paginated_notifications.dart';
import 'notifications_controller.dart';

/// Notifications screen showing civic updates with read/unread states.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsControllerProvider);
    final permissions = ref.watch(userPermissionsProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notifications)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(notificationsControllerProvider);
          try {
            await ref.read(notificationsControllerProvider.future);
          } catch (_) {
            // The inline error state gives the user the retry action.
          }
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: VerificationBanner(permissions: permissions),
            ),
            SliverToBoxAdapter(child: _buildIntro(theme, l10n)),
            ...notificationsAsync.when(
              data: (data) =>
                  _buildDataSlivers(context, ref, data, theme, l10n),
              loading: () => _buildLoadingSlivers(),
              error: (_, _) => [
                SliverFillRemaining(
                  hasScrollBody: true,
                  child: _buildErrorState(context, ref, theme, l10n),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntro(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.notificationsGuidance,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDataSlivers(
    BuildContext context,
    WidgetRef ref,
    PaginatedNotifications data,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final summary = data.unreadCount > 0
        ? Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final unread = CivicStatusChip(
                  label: l10n.unreadNotifications(data.unreadCount),
                  color: theme.colorScheme.primary,
                  icon: Icons.mark_email_unread_outlined,
                );
                final markAll = TextButton.icon(
                  onPressed: () => _markAllAsRead(context, ref, l10n),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  icon: const Icon(Icons.done_all, size: 18),
                  label: Text(l10n.markAllRead),
                );
                if (constraints.maxWidth < 420) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [unread, markAll],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [unread, const Spacer(), markAll],
                );
              },
            ),
          )
        : Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              l10n.allCaughtUp,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );

    if (data.results.isEmpty) {
      return [
        SliverToBoxAdapter(child: summary),
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyContentPlaceholder(
            icon: Icons.notifications_none_outlined,
            title: l10n.allCaughtUp,
            message: l10n.noNewNotifications,
            onRetry: () => ref.invalidate(notificationsControllerProvider),
          ),
        ),
      ];
    }

    return [
      SliverToBoxAdapter(child: summary),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        sliver: SliverList.separated(
          itemCount: data.results.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final notification = data.results[index];
            return _NotificationTile(
              notification: notification,
              onTap: () =>
                  _handleNotificationTap(context, ref, notification, l10n),
            );
          },
        ),
      ),
    ];
  }

  List<Widget> _buildLoadingSlivers() {
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        sliver: SliverList.separated(
          itemCount: 4,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (_, _) => const _NotificationSkeleton(),
        ),
      ),
    ];
  }

  Widget _buildErrorState(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
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
                    l10n.failedLoadNotifications,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.notificationsNetworkError,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.tonal(
                    onPressed: () =>
                        ref.invalidate(notificationsControllerProvider),
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

  Future<void> _markAllAsRead(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    try {
      await ref.read(notificationsControllerProvider.notifier).markAllAsRead();
      if (context.mounted) {
        AppToast.success(context, l10n.allNotificationsRead);
      }
    } catch (_) {
      if (context.mounted) {
        AppToast.error(context, l10n.notificationsUpdateFailed);
      }
    }
  }

  Future<void> _handleNotificationTap(
    BuildContext context,
    WidgetRef ref,
    NotificationEntity notification,
    AppLocalizations l10n,
  ) async {
    if (!notification.isRead) {
      try {
        await ref
            .read(notificationsControllerProvider.notifier)
            .markAsRead(notification.id);
      } catch (_) {
        if (context.mounted) {
          AppToast.error(context, l10n.notificationsUpdateFailed);
        }
      }
    }

    if (context.mounted && notification.reportId != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ReportDetailScreen(reportId: notification.reportId!),
        ),
      );
    }
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final NotificationEntity notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final visual = _notificationVisual(theme, notification.type);
    final time = notification.createdAt == null
        ? l10n.unknownTime
        : localizedRelativeTime(context, notification.createdAt, l10n);
    final semanticLabel = notification.isRead
        ? '${notification.title}. ${notification.message}'
        : '${l10n.unread}: ${notification.title}. ${notification.message}';
    final radius = BorderRadius.circular(16);
    final backgroundColor = notification.isRead
        ? scheme.surface
        : theme.brightness == Brightness.dark
        ? Color.alphaBlend(
            scheme.primary.withValues(alpha: 0.07),
            scheme.surface,
          )
        : AppColors.citizenLightUnreadNotification;

    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: backgroundColor,
        elevation: theme.brightness == Brightness.dark ? 0 : 1,
        shadowColor: scheme.shadow.withValues(
          alpha: theme.brightness == Brightness.dark ? 0 : 0.08,
        ),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: visual.color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(visual.icon, color: visual.color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (!notification.isRead)
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: scheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          Text(
                            notification.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: notification.isRead
                                  ? FontWeight.w600
                                  : FontWeight.w800,
                            ),
                          ),
                          if (!notification.isRead)
                            Text(
                              l10n.unread,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        notification.message,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            time,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (notification.reportId != null) ...[
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                l10n.reportDetails,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationSkeleton extends StatelessWidget {
  const _NotificationSkeleton();

  @override
  Widget build(BuildContext context) {
    return CivicSurface(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CivicSkeletonBlock(width: 44, height: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CivicSkeletonBlock(width: 160, height: 14),
                const SizedBox(height: 10),
                const CivicSkeletonBlock(height: 14),
                const SizedBox(height: 7),
                CivicSkeletonBlock(
                  width: MediaQuery.sizeOf(context).width * 0.54,
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

({Color color, IconData icon}) _notificationVisual(
  ThemeData theme,
  NotificationType type,
) {
  return switch (type) {
    NotificationType.reportSubmitted => (
      color: theme.colorScheme.primary,
      icon: Icons.assignment_turned_in_outlined,
    ),
    NotificationType.statusChange => (
      color: theme.colorScheme.primary,
      icon: Icons.sync_outlined,
    ),
    NotificationType.comment => (
      color: theme.colorScheme.secondary,
      icon: Icons.chat_bubble_outline,
    ),
    NotificationType.assignment => (
      color: theme.colorScheme.tertiary,
      icon: Icons.account_balance_outlined,
    ),
    NotificationType.reportUpdated => (
      color: theme.colorScheme.primary,
      icon: Icons.edit_note_outlined,
    ),
    NotificationType.kycUpdate => (
      color: theme.colorScheme.secondary,
      icon: Icons.verified_user_outlined,
    ),
    NotificationType.system => (
      color: theme.colorScheme.onSurfaceVariant,
      icon: Icons.info_outline,
    ),
  };
}
