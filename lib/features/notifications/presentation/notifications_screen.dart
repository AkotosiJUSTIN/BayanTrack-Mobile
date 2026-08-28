import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/presentation/widgets/app_toast.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/data/user_permissions.dart';
import '../../auth/presentation/verification_widgets.dart';
import '../../reports/presentation/report_detail_screen.dart';
import '../domain/entities/notification.dart';
import '../domain/entities/notification_type.dart';
import '../domain/entities/paginated_notifications.dart';
import 'notifications_controller.dart';
import '../../../core/presentation/widgets/empty_content_placeholder.dart';
import '../../../l10n/app_localizations.dart';
import '../../reports/presentation/report_labels.dart';

/// Notifications screen showing list of notifications with read/unread states.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsControllerProvider);
    final permissions = ref.watch(userPermissionsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications),
        actions: [
          // Mark all as read button
          notificationsAsync.maybeWhen(
            data: (data) => data.unreadCount > 0
                ? Semantics(
                    button: true,
                    label: l10n.markAllRead,
                    child: TextButton(
                      onPressed: () async {
                        await ref
                            .read(notificationsControllerProvider.notifier)
                            .markAllAsRead();
                        if (context.mounted) {
                          AppToast.success(context, l10n.allNotificationsRead);
                        }
                      },
                      child: Text(l10n.markAllRead),
                    ),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: Column(
        children: [
          VerificationBanner(permissions: permissions),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(notificationsControllerProvider);
              },
              child: notificationsAsync.when(
                data: (data) =>
                    _buildContent(context, ref, data, theme, isDark),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) =>
                    _buildErrorState(context, ref, theme, error),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    PaginatedNotifications data,
    ThemeData theme,
    bool isDark,
  ) {
    if (data.results.isEmpty) {
      return _buildEmptyState(context, theme, ref);
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: data.results.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final notification = data.results[index];
        return _NotificationTile(
          notification: notification,
          onTap: () => _handleNotificationTap(context, ref, notification),
        );
      },
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ThemeData theme,
    WidgetRef ref,
  ) {
    return EmptyContentPlaceholder(
      icon: Icons.notifications_off_outlined,
      title: AppLocalizations.of(context)!.allCaughtUp,
      message: AppLocalizations.of(context)!.noNewNotifications,
      onRetry: () => ref.invalidate(notificationsControllerProvider),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    Object _,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.alertHigh),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.failedLoadNotifications,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              AppLocalizations.of(context)!.notificationsNetworkError,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: () => ref.invalidate(notificationsControllerProvider),
            child: Text(AppLocalizations.of(context)!.retry),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(
    BuildContext context,
    WidgetRef ref,
    NotificationEntity notification,
  ) async {
    // Mark as read if unread
    if (!notification.isRead) {
      await ref
          .read(notificationsControllerProvider.notifier)
          .markAsRead(notification.id);
    }

    // Navigate to report if linked
    if (context.mounted && notification.reportId != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ReportDetailScreen(reportId: notification.reportId!),
        ),
      );
    }
  }
}

/// Single notification tile with read/unread styling
class _NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      tileColor: notification.isRead
          ? null
          : (isDark
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.primary.withValues(alpha: 0.05)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: notification.isRead
            ? BorderSide.none
            : BorderSide(color: AppColors.primary.withValues(alpha: 0.24)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      minVerticalPadding: 12,
      leading: _buildIcon(isDark),
      title: Text(
        notification.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            notification.message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            notification.createdAt != null
                ? localizedRelativeTime(context, notification.createdAt, l10n)
                : l10n.unknownTime,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
      trailing: notification.isRead
          ? null
          : Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
      onTap: onTap,
    );
  }

  Widget _buildIcon(bool isDark) {
    IconData icon;
    Color color;

    switch (notification.type) {
      case NotificationType.reportSubmitted:
        icon = Icons.upload_file;
        color = AppColors.primary;
      case NotificationType.statusChange:
        icon = Icons.sync;
        color = AppColors.primary;
      case NotificationType.comment:
        icon = Icons.comment;
        color = AppColors.alertMedium;
      case NotificationType.assignment:
        icon = Icons.assignment_ind;
        color = AppColors.success;
      case NotificationType.reportUpdated:
        icon = Icons.edit_note;
        color = AppColors.primary;
      case NotificationType.kycUpdate:
        icon = Icons.verified_user;
        color = AppColors.alertMedium;
      case NotificationType.system:
        icon = Icons.info;
        color = isDark
            ? AppColors.darkTextSecondary
            : AppColors.lightTextSecondary;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
