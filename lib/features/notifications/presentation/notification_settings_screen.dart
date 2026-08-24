import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notificationSettings)),
      body: prefsAsync.when(
        data: (prefs) => _buildSettingsList(context, prefs),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${l10n.error}: $err'),
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

  Widget _buildSettingsList(
    BuildContext context,
    NotificationPreferences prefs,
  ) {
    return ListView(
      children: [
        if (_isSaving) const LinearProgressIndicator(),
        if (_saveError != null)
          ListTile(
            title: Text(
              _saveError!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            trailing: TextButton(
              onPressed: _isSaving ? null : _retrySave,
              child: Text(AppLocalizations.of(context)!.retry),
            ),
          ),
        _buildSectionHeader(context, AppLocalizations.of(context)!.channels),
        SwitchListTile(
          title: Text(AppLocalizations.of(context)!.notificationsEmail),
          subtitle: Text(AppLocalizations.of(context)!.emailUpdates),
          value: prefs.emailEnabled,
          onChanged: _isSaving ? null : (val) => _update(emailEnabled: val),
        ),
        SwitchListTile(
          title: Text(AppLocalizations.of(context)!.notificationsPush),
          subtitle: Text(AppLocalizations.of(context)!.pushUpdates),
          value: prefs.pushEnabled,
          onChanged: _isSaving ? null : (val) => _update(pushEnabled: val),
        ),
        const Divider(),
        _buildSectionHeader(context, AppLocalizations.of(context)!.events),
        SwitchListTile(
          title: Text(AppLocalizations.of(context)!.notifyStatusChange),
          subtitle: Text(AppLocalizations.of(context)!.statusChangeUpdates),
          value: prefs.notifyOnStatusChange,
          onChanged: _isSaving
              ? null
              : (val) => _update(notifyOnStatusChange: val),
        ),
        SwitchListTile(
          title: Text(AppLocalizations.of(context)!.notifyComment),
          subtitle: Text(AppLocalizations.of(context)!.commentUpdates),
          value: prefs.notifyOnComment,
          onChanged: _isSaving ? null : (val) => _update(notifyOnComment: val),
        ),
        SwitchListTile(
          title: Text(AppLocalizations.of(context)!.notifyAssignment),
          subtitle: Text(AppLocalizations.of(context)!.assignmentUpdates),
          value: prefs.notifyOnAssignment,
          onChanged: _isSaving
              ? null
              : (val) => _update(notifyOnAssignment: val),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
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
