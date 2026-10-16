import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/session_content_cache.dart';
import '../../../l10n/app_localizations.dart';

class ContentFreshnessBanner extends ConsumerWidget {
  const ContentFreshnessBanner({super.key, required this.cacheKey});
  final String cacheKey;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final freshness = ref.watch(
      contentFreshnessProvider.select((s) => s[cacheKey]),
    );
    final l10n = AppLocalizations.of(context);
    if (freshness == null || freshness == ContentFreshness.current) {
      return const SizedBox.shrink();
    }
    return Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          freshness == ContentFreshness.refreshing
              ? l10n.cachedContentRefreshing
              : l10n.cachedContentStale,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}
