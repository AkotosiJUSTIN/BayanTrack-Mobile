import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';

/// Provides a stream of connectivity results to detect online/offline state.
final connectivityStreamProvider = StreamProvider<List<ConnectivityResult>>((
  ref,
) {
  return Connectivity().onConnectivityChanged;
});

/// Tracks whether the device is currently online.
///
/// Initial state assumes online (true). Listens to connectivity changes
/// and updates accordingly.
final isOnlineProvider = NotifierProvider<ConnectivityNotifier, bool>(
  ConnectivityNotifier.new,
);

/// Notifier that manages online/offline state.
class ConnectivityNotifier extends Notifier<bool> {
  @override
  bool build() {
    // Listen to connectivity changes
    Connectivity().onConnectivityChanged.listen((results) {
      final isConnected =
          results.isNotEmpty &&
          !results.every((r) => r == ConnectivityResult.none);
      state = isConnected;
    });
    // Check initial connectivity
    Connectivity().checkConnectivity().then((results) {
      final isConnected =
          results.isNotEmpty &&
          !results.every((r) => r == ConnectivityResult.none);
      state = isConnected;
    });
    return true; // Assume online initially
  }

  void setOnline(bool isOnline) {
    state = isOnline;
  }
}

/// Widget that shows an offline banner at the top of the screen
/// when the device loses connectivity.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);

    if (isOnline) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return Semantics(
      liveRegion: true,
      label: l10n.noInternetConnection,
      child: Material(
        color: scheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                color: scheme.onErrorContainer,
                size: 18,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  l10n.noInternetConnection,
                  style: TextStyle(
                    color: scheme.onErrorContainer,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
