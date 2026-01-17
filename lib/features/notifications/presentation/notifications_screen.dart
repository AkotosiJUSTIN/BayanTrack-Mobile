import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/theme/app_colors.dart';
import '../../reports/presentation/report_detail_screen.dart';
import '../data/notification_models.dart';
import 'notifications_controller.dart';
import '../../../core/presentation/widgets/empty_content_placeholder.dart';

/// Notifications screen showing list of notifications with read/unread states.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsControllerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          // Mark all as read button
          notificationsAsync.maybeWhen(
            data: (data) => data.unreadCount > 0
                ? TextButton(
                    onPressed: () async {
                      await ref
                          .read(notificationsControllerProvider.notifier)
                          .markAllAsRead();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('All notifications marked as read'),
                          ),
                        );
                      }
                    },
                    child: const Text('Mark all read'),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(notificationsControllerProvider);
        },
        child: notificationsAsync.when(
          data: (data) => _buildContent(context, ref, data, theme, isDark),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _buildErrorState(context, ref, theme, error),
        ),
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
      return _buildEmptyState(theme, ref);
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: data.results.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
      ),
      itemBuilder: (context, index) {
        final notification = data.results[index];
        return _NotificationTile(
          notification: notification,
          onTap: () => _handleNotificationTap(context, ref, notification),
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme, WidgetRef ref) {
    return EmptyContentPlaceholder(
      icon: Icons.notifications_off_outlined,
      title: 'All caught up!',
      message: 'You have no new notifications at the moment.',
      onRetry: () => ref.invalidate(notificationsControllerProvider),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    Object error,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.alertHigh),
          const SizedBox(height: 16),
          Text(
            'Failed to load notifications',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error.toString(),
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.invalidate(notificationsControllerProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(
    BuildContext context,
    WidgetRef ref,
    AppNotification notification,
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
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      tileColor: notification.isRead
          ? null
          : (isDark
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.primary.withValues(alpha: 0.05)),
      leading: _buildIcon(isDark),
      title: Text(
        notification.title,
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
          if (notification.createdAt != null) ...[
            const SizedBox(height: 4),
            Text(
              timeago.format(DateTime.parse(notification.createdAt!)),
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                fontSize: 11,
              ),
            ),
          ],
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
      case NotificationType.statusChange:
        icon = Icons.sync;
        color = AppColors.primary;
      case NotificationType.comment:
        icon = Icons.comment;
        color = AppColors.alertMedium;
      case NotificationType.assignment:
        icon = Icons.assignment_ind;
        color = AppColors.success;
      case NotificationType.system:
        icon = Icons.info;
        color = isDark
            ? AppColors.darkTextSecondary
            : AppColors.lightTextSecondary;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
