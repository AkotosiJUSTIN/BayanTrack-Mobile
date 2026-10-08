import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class OfflineStaleBanner extends StatelessWidget {
  const OfflineStaleBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Semantics(
      liveRegion: true,
      label: l10n.cachedReportsOffline,
      child: Material(
        color: theme.colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off_outlined,
                color: theme.colorScheme.onErrorContainer,
                size: 18,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  l10n.cachedReportsOffline,
                  style: TextStyle(
                    color: theme.colorScheme.onErrorContainer,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
