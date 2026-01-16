import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/notification_models.dart';
import 'notifications_controller.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(notificationPreferencesControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      body: prefsAsync.when(
        data: (prefs) => _buildSettingsList(context, ref, prefs),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading settings: $err')),
      ),
    );
  }

  Widget _buildSettingsList(
    BuildContext context,
    WidgetRef ref,
    NotificationPreferences prefs,
  ) {
    return ListView(
      children: [
        _buildSectionHeader(context, 'Channels'),
        SwitchListTile(
          title: const Text('Email Notifications'),
          subtitle: const Text('Receive updates via email'),
          value: prefs.emailEnabled,
          onChanged: (val) => _update(ref, prefs, emailEnabled: val),
        ),
        SwitchListTile(
          title: const Text('Push Notifications'),
          subtitle: const Text('Receive updates on this device'),
          value: prefs.pushEnabled,
          onChanged: (val) => _update(ref, prefs, pushEnabled: val),
        ),
        const Divider(),
        _buildSectionHeader(context, 'Events'),
        SwitchListTile(
          title: const Text('Status Changes'),
          subtitle: const Text('When report status changes'),
          value: prefs.notifyOnStatusChange,
          onChanged: (val) => _update(ref, prefs, notifyOnStatusChange: val),
        ),
        SwitchListTile(
          title: const Text('Comments'),
          subtitle: const Text('When someone comments on your report'),
          value: prefs.notifyOnComment,
          onChanged: (val) => _update(ref, prefs, notifyOnComment: val),
        ),
        SwitchListTile(
          title: const Text('Assignments'),
          subtitle: const Text('When a report is assigned'),
          value: prefs.notifyOnAssignment,
          onChanged: (val) => _update(ref, prefs, notifyOnAssignment: val),
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

  void _update(
    WidgetRef ref,
    NotificationPreferences current, {
    bool? emailEnabled,
    bool? pushEnabled,
    bool? notifyOnStatusChange,
    bool? notifyOnComment,
    bool? notifyOnAssignment,
  }) {
    final request = UpdatePreferencesRequest(
      emailEnabled: emailEnabled ?? current.emailEnabled,
      pushEnabled: pushEnabled ?? current.pushEnabled,
      notifyOnStatusChange:
          notifyOnStatusChange ?? current.notifyOnStatusChange,
      notifyOnComment: notifyOnComment ?? current.notifyOnComment,
      notifyOnAssignment: notifyOnAssignment ?? current.notifyOnAssignment,
    );

    ref
        .read(notificationPreferencesControllerProvider.notifier)
        .updatePreferences(request);
  }
}
