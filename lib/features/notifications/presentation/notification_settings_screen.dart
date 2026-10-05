import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/presentation/widgets/civic_components.dart';
import '../domain/entities/notification_preferences.dart';
import 'notifications_controller.dart';
import '../../../l10n/app_localizations.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  bool _isSaving = false;
  String? _saveError;
  Future<void> Function()? _retrySave;

  @override
  Widget build(BuildContext context) {
    final prefsAsync = ref.watch(notificationPreferencesControllerProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notificationSettings)),
      body: prefsAsync.when(
        data: (prefs) => _buildSettingsList(context, prefs),
        loading: () => _buildLoadingState(context),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.notificationsNetworkError, textAlign: TextAlign.center),
              TextButton(
                onPressed: () =>
                    ref.invalidate(notificationPreferencesControllerProvider),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      container: true,
      liveRegion: true,
      label: l10n.loading,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          CivicSectionHeading(title: l10n.channels),
          _buildSkeletonGroup(context, 2),
          const SizedBox(height: 24),
          CivicSectionHeading(title: l10n.events),
          _buildSkeletonGroup(context, 3),
        ],
      ),
    );
  }

  Widget _buildSkeletonGroup(BuildContext context, int rowCount) {
    return CivicSettingsGroup(
      children: [
        for (var i = 0; i < rowCount; i++) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CivicSkeletonBlock(height: 16),
                      SizedBox(height: 8),
                      FractionallySizedBox(
                        widthFactor: 0.75,
                        child: CivicSkeletonBlock(height: 12),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 24),
                CivicSkeletonBlock(width: 48, height: 28, radius: 14),
              ],
            ),
          ),
          if (i < rowCount - 1)
            Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withValues(alpha: 0.72),
            ),
        ],
      ],
    );
  }

  Widget _buildSettingsList(
    BuildContext context,
    NotificationPreferences prefs,
  ) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        if (_isSaving) const LinearProgressIndicator(),
        if (_saveError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: CivicSurface(
              child: ListTile(
                title: Text(
                  _saveError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                trailing: TextButton(
                  onPressed: _isSaving ? null : _retrySave,
                  child: Text(l10n.retry),
                ),
              ),
            ),
          ),
        CivicSectionHeading(title: l10n.channels),
        CivicSettingsGroup(
          children: [
            _buildSwitchTile(
              context,
              title: l10n.notificationsEmail,
              subtitle: l10n.emailUpdates,
              value: prefs.emailEnabled,
              onChanged: _isSaving
                  ? null
                  : (value) => _update(emailEnabled: value),
            ),
            _buildSwitchTile(
              context,
              title: l10n.notificationsPush,
              subtitle: l10n.pushUpdates,
              value: prefs.pushEnabled,
              showDivider: false,
              onChanged: _isSaving
                  ? null
                  : (value) => _update(pushEnabled: value),
            ),
          ],
        ),
        const SizedBox(height: 24),
        CivicSectionHeading(title: l10n.events),
        CivicSettingsGroup(
          children: [
            _buildSwitchTile(
              context,
              title: l10n.notifyStatusChange,
              subtitle: l10n.statusChangeUpdates,
              value: prefs.notifyOnStatusChange,
              onChanged: _isSaving
                  ? null
                  : (value) => _update(notifyOnStatusChange: value),
            ),
            _buildSwitchTile(
              context,
              title: l10n.notifyComment,
              subtitle: l10n.commentUpdates,
              value: prefs.notifyOnComment,
              onChanged: _isSaving
                  ? null
                  : (value) => _update(notifyOnComment: value),
            ),
            _buildSwitchTile(
              context,
              title: l10n.notifyAssignment,
              subtitle: l10n.assignmentUpdates,
              value: prefs.notifyOnAssignment,
              showDivider: false,
              onChanged: _isSaving
                  ? null
                  : (value) => _update(notifyOnAssignment: value),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          title: Text(title),
          subtitle: Text(subtitle),
          value: value,
          onChanged: onChanged,
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.72),
          ),
      ],
    );
  }

  Future<void> _update({
    bool? emailEnabled,
    bool? pushEnabled,
    bool? notifyOnStatusChange,
    bool? notifyOnComment,
    bool? notifyOnAssignment,
  }) async {
    setState(() {
      _isSaving = true;
      _saveError = null;
      _retrySave = () => _update(
        emailEnabled: emailEnabled,
        pushEnabled: pushEnabled,
        notifyOnStatusChange: notifyOnStatusChange,
        notifyOnComment: notifyOnComment,
        notifyOnAssignment: notifyOnAssignment,
      );
    });
    try {
      await ref
          .read(notificationPreferencesControllerProvider.notifier)
          .updatePreferences(
            emailEnabled: emailEnabled,
            pushEnabled: pushEnabled,
            notifyOnStatusChange: notifyOnStatusChange,
            notifyOnComment: notifyOnComment,
            notifyOnAssignment: notifyOnAssignment,
          );
      if (mounted) {
        setState(() => _retrySave = null);
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _saveError = error.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
