import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/connectivity_provider.dart';
import '../../../l10n/app_localizations.dart';
import 'app_update_controller.dart';

/// Sits above the root navigator so routes and Back cannot bypass the prompt.
class AppUpdateGate extends ConsumerStatefulWidget {
  const AppUpdateGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppUpdateGate> createState() => _AppUpdateGateState();
}

class _AppUpdateGateState extends ConsumerState<AppUpdateGate>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() {
      if (mounted) unawaited(ref.read(appUpdateProvider.notifier).check());
    });
    ref.listenManual<bool>(isOnlineProvider, (previous, next) {
      if (previous == false && next) {
        unawaited(ref.read(appUpdateProvider.notifier).check());
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(ref.read(appUpdateProvider.notifier).check());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appUpdateProvider);
    return Stack(
      fit: StackFit.expand,
      children: [
        ExcludeFocus(
          excluding: state.requiresUpdate,
          child: ExcludeSemantics(
            excluding: state.requiresUpdate,
            child: AbsorbPointer(
              absorbing: state.requiresUpdate,
              child: widget.child,
            ),
          ),
        ),
        if (state.requiresUpdate) ...[
          const ModalBarrier(dismissible: false, color: Colors.black54),
          const AppVersionDialog(requiredUpdate: true),
        ],
      ],
    );
  }
}

class AppVersionCheckButton extends ConsumerWidget {
  const AppVersionCheckButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => IconButton(
    key: const Key('app-version-check'),
    tooltip: AppLocalizations.of(context).appCheckVersion,
    icon: const Icon(Icons.system_update_alt),
    onPressed: () => showDialog<void>(
      context: context,
      builder: (_) => const AppVersionDialog(requiredUpdate: false),
    ),
  );
}

class AppVersionDialog extends ConsumerStatefulWidget {
  const AppVersionDialog({super.key, required this.requiredUpdate});

  final bool requiredUpdate;

  @override
  ConsumerState<AppVersionDialog> createState() => _AppVersionDialogState();
}

class _AppVersionDialogState extends ConsumerState<AppVersionDialog> {
  bool _opening = false;
  bool _openFailed = false;

  @override
  void initState() {
    super.initState();
    if (!widget.requiredUpdate) {
      Future.microtask(() {
        if (mounted) unawaited(ref.read(appUpdateProvider.notifier).check());
      });
    }
  }

  Future<void> _openReleases() async {
    if (_opening) return;
    setState(() {
      _opening = true;
      _openFailed = false;
    });
    var opened = false;
    try {
      opened = await ref.read(openAppReleasesProvider)();
    } catch (_) {
      // Keep the required prompt visible when the external browser fails.
    }
    if (mounted) {
      setState(() {
        _opening = false;
        _openFailed = !opened;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appUpdateProvider);
    final l10n = AppLocalizations.of(context);
    final required = widget.requiredUpdate || state.requiresUpdate;
    final message = required
        ? l10n.appUpdateRequiredMessage
        : state.checking
        ? l10n.appCheckingVersion
        : state.failed || !state.checked
        ? l10n.appVersionUnavailable
        : l10n.appVersionCurrent;
    return AlertDialog(
      key: const Key('app-version-dialog'),
      scrollable: true,
      icon: Icon(
        required ? Icons.system_update : Icons.system_update_alt,
        size: 32,
      ),
      title: Text(required ? l10n.appUpdateRequired : l10n.appCheckVersion),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          if (state.installed != null) ...[
            const SizedBox(height: 16),
            Text(l10n.appInstalledVersion(state.installed.toString())),
          ],
          if (state.latest != null)
            Text(l10n.appLatestVersion(state.latest.toString())),
          if (state.checking) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
          ],
          if (_openFailed) ...[
            const SizedBox(height: 16),
            Text(
              l10n.appReleaseOpenFailed,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (required && state.failed) ...[
            const SizedBox(height: 16),
            Text(l10n.appVersionUnavailable),
          ],
        ],
      ),
      actions: [
        if (!required)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.close),
          ),
        if (required || state.failed)
          TextButton.icon(
            onPressed: state.checking
                ? null
                : () => ref.read(appUpdateProvider.notifier).check(),
            icon: const Icon(Icons.refresh),
            label: Text(l10n.retry),
          ),
        if (required)
          FilledButton.icon(
            key: const Key('app-update-download'),
            onPressed: _opening ? null : _openReleases,
            icon: const Icon(Icons.open_in_new),
            label: Text(l10n.appGetUpdate),
          ),
      ],
    );
  }
}
