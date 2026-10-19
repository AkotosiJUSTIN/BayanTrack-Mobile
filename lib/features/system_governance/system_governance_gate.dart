import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../core/providers/connectivity_provider.dart';
import '../../core/providers/backend_reachability_provider.dart';
import '../reports/presentation/new_report/quick_report_screen.dart';
import 'system_governance_models.dart';
import 'system_governance_provider.dart';

/// Keeps emergency navigation outside ordinary policy-restricted workflows.
class SystemGovernanceGate extends ConsumerWidget {
  const SystemGovernanceGate({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(systemGovernanceProvider);
    if (status.asData == null &&
        (!ref.watch(isOnlineProvider) ||
            ref.watch(backendReachabilityProvider) ==
                BackendReachability.unreachable) &&
        status.value?.termsAcceptanceRequired != true) {
      // Local work stays available; outbox uploads still require live policy.
      return child;
    }
    return status.when(
      // Account changes must not render the previous account's consent state.
      skipLoadingOnRefresh: false,
      // Opening the workspace does not authorize uploads; queues require policy.
      loading: () => child,
      error: (_, _) => _UnavailableGovernance(
        onRetry: () => ref.read(systemGovernanceProvider.notifier).refresh(),
      ),
      data: (state) {
        if (state.termsAcceptanceRequired) {
          return const CurrentTermsScreen();
        }
        if (!state.maintenanceEnabled) return child;
        return Column(
          children: [
            Material(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: SafeArea(
                bottom: false,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 160),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.construction_outlined),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              state.maintenanceMessage.isEmpty
                                  ? AppLocalizations.of(
                                      context,
                                    ).governanceReadOnly
                                  : state.maintenanceMessage,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}

class _UnavailableGovernance extends StatelessWidget {
  const _UnavailableGovernance({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('BayanTrack')),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context).governanceStatusUnavailable),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context).retry),
            ),
            const _EmergencyButton(),
          ],
        ),
      ),
    ),
  );
}

class _EmergencyButton extends StatelessWidget {
  const _EmergencyButton();

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    key: const Key('governance-emergency-button'),
    onPressed: () => Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const EmergencyReportScreen()),
    ),
    icon: const Icon(Icons.emergency_outlined),
    label: Text(AppLocalizations.of(context).emergencyReport),
  );
}

class CurrentTermsScreen extends ConsumerStatefulWidget {
  const CurrentTermsScreen({super.key, this.readOnly = false});
  final bool readOnly;

  @override
  ConsumerState<CurrentTermsScreen> createState() => _CurrentTermsScreenState();
}

class _CurrentTermsScreenState extends ConsumerState<CurrentTermsScreen> {
  bool _agreed = false;
  bool _saving = false;
  String? _reviewedVersion;
  String? _reviewedLanguage;
  String? _error;

  Future<void> _accept(PublishedTerms terms, String language) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(systemGovernanceRepositoryProvider)
          .accept(terms, language);
      await ref.read(systemGovernanceProvider.notifier).refresh();
    } on DioException catch (error) {
      if (!mounted) return;
      final body = error.response?.data;
      if (error.response?.statusCode == 409 &&
          body is Map &&
          body['code'] == 'terms_version_stale') {
        ref.invalidate(publishedTermsProvider);
        setState(() {
          _agreed = false;
          _error = AppLocalizations.of(context).governanceTermsChanged;
        });
      } else {
        setState(
          () =>
              _error = AppLocalizations.of(context).governanceAcceptanceFailed,
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () =>
              _error = AppLocalizations.of(context).governanceAcceptanceFailed,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode == 'fil'
        ? 'fil'
        : 'en';
    final terms = ref.watch(publishedTermsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).termsAndPrivacy)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: terms.when(
                skipLoadingOnRefresh: false,
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppLocalizations.of(
                            context,
                          ).governanceTermsUnavailable,
                        ),
                        OutlinedButton.icon(
                          onPressed: () =>
                              ref.invalidate(publishedTermsProvider),
                          icon: const Icon(Icons.refresh),
                          label: Text(AppLocalizations.of(context).retry),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (document) {
                  if (_reviewedVersion != document.versionId ||
                      _reviewedLanguage != language) {
                    _reviewedVersion = document.versionId;
                    _reviewedLanguage = language;
                    _agreed = false;
                  }
                  final translation = document.translation(language);
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          translation.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        SelectableText(
                          translation.content,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (!widget.readOnly) ...[
                          const SizedBox(height: 24),
                          CheckboxListTile(
                            key: const Key('governance-consent-checkbox'),
                            value: _agreed,
                            onChanged: _saving
                                ? null
                                : (value) =>
                                      setState(() => _agreed = value == true),
                            title: Text(
                              AppLocalizations.of(
                                context,
                              ).governanceConsentLabel,
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                          if (_error != null)
                            Text(
                              _error!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          FilledButton.icon(
                            key: const Key('governance-accept-button'),
                            onPressed: _agreed && !_saving
                                ? () => _accept(document, language)
                                : null,
                            icon: const Icon(Icons.check),
                            label: Text(AppLocalizations.of(context).accept),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
            if (!widget.readOnly)
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: _EmergencyButton(),
              ),
          ],
        ),
      ),
    );
  }
}
