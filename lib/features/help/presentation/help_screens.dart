import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/presentation/widgets/civic_components.dart';
import '../data/help_content.dart';

void _openEmergencyHotlines(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const EmergencyHotlinesScreen()),
  );
}

class HelpSafetySection extends StatelessWidget {
  const HelpSafetySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CivicSectionHeading(title: 'Help & Safety'),
        _EmergencyHelpCard(onPressed: () => _openEmergencyHotlines(context)),
        const SizedBox(height: 12),
        CivicSettingsGroup(
          children: [
            CivicSettingsRow(
              key: const ValueKey('profile-help-hotlines'),
              icon: Icons.call_outlined,
              title: 'Emergency Hotlines',
              onTap: () => _openEmergencyHotlines(context),
            ),
            CivicSettingsRow(
              key: const ValueKey('profile-help-faq'),
              icon: Icons.help_outline_rounded,
              title: 'Help & FAQs',
              subtitle: 'Search topics and answers',
              showDivider: false,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const HelpFaqScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class EmergencyHotlinesScreen extends StatefulWidget {
  const EmergencyHotlinesScreen({
    super.key,
    this.hotlines = emergencyHotlines,
    this.launchCall,
  });

  final List<EmergencyHotline> hotlines;
  final Future<bool> Function(Uri uri)? launchCall;

  @override
  State<EmergencyHotlinesScreen> createState() =>
      _EmergencyHotlinesScreenState();
}

class _EmergencyHotlinesScreenState extends State<EmergencyHotlinesScreen> {
  Future<void> _call(Uri uri) async {
    try {
      final launch =
          widget.launchCall ??
          (uri) => launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!await launch(uri) && mounted) _showCallFailure(uri);
    } catch (_) {
      if (mounted) _showCallFailure(uri);
    }
  }

  void _showCallFailure(Uri uri) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Could not open the phone app. Use your dialer to call ${uri.path}.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Hotlines')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          const _EmergencyHelpCard(),
          const SizedBox(height: 24),
          Text(
            'Verified emergency numbers',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          if (widget.hotlines.isEmpty)
            const _HotlineUnavailable(
              message: 'No verified hotline numbers are available.',
            )
          else
            for (final hotline in widget.hotlines) ...[
              _HotlineTile(hotline: hotline, onCall: _call),
              const SizedBox(height: 12),
            ],
          Text(
            'Help information is stored on this device and available offline.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class HelpFaqScreen extends StatefulWidget {
  const HelpFaqScreen({super.key});

  @override
  State<HelpFaqScreen> createState() => _HelpFaqScreenState();
}

class _HelpFaqScreenState extends State<HelpFaqScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateQuery(String query) => setState(() => _query = query);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = filterHelpFaqCategories(_query);

    return Scaffold(
      appBar: AppBar(title: const Text('Help & FAQs')),
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          _EmergencyHelpCard(onPressed: () => _openEmergencyHotlines(context)),
          const SizedBox(height: 24),
          Text('Frequently Asked Questions', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey('help-faq-search'),
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onChanged: _updateQuery,
            decoration: InputDecoration(
              hintText: 'Search help...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: () {
                        _searchController.clear();
                        _updateQuery('');
                      },
                      icon: const Icon(Icons.close),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Help articles are stored in the app and available offline.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          if (categories.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'No matching help articles. Try another search.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            )
          else
            CivicSurface(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  for (var index = 0; index < categories.length; index++) ...[
                    _FaqCategoryTile(
                      category: categories[index],
                      initiallyExpanded: _query.isNotEmpty,
                      searchActive: _query.isNotEmpty,
                    ),
                    if (index < categories.length - 1)
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _FaqCategoryTile extends StatelessWidget {
  const _FaqCategoryTile({
    required this.category,
    required this.initiallyExpanded,
    required this.searchActive,
  });

  final HelpFaqCategory category;
  final bool initiallyExpanded;
  final bool searchActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ExpansionTile(
      key: PageStorageKey<String>(
        'help-faq-category-${category.title}-$searchActive',
      ),
      initiallyExpanded: initiallyExpanded,
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(
        category.title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      children: [
        for (final entry in category.entries)
          ExpansionTile(
            key: PageStorageKey<String>(
              'help-faq-question-${category.title}-${entry.question}',
            ),
            tilePadding: const EdgeInsets.symmetric(horizontal: 20),
            childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            title: Text(entry.question, style: theme.textTheme.bodyLarge),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(entry.answer, style: theme.textTheme.bodyMedium),
              ),
            ],
          ),
      ],
    );
  }
}

class _HotlineTile extends StatelessWidget {
  const _HotlineTile({required this.hotline, required this.onCall});

  final EmergencyHotline hotline;
  final ValueChanged<Uri> onCall;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uri = hotlineCallUri(hotline.number);

    return CivicSurface(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(hotline.name, style: theme.textTheme.titleMedium),
          if (uri == null)
            const _HotlineUnavailable(
              message:
                  'Call unavailable: this number is unavailable or invalid.',
            )
          else ...[
            const SizedBox(height: 4),
            Text(hotline.number, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 12),
            FilledButton.icon(
              key: ValueKey('hotline-call-${hotline.number}'),
              onPressed: () => onCall(uri),
              icon: const Icon(Icons.call_outlined),
              label: Text('Call ${hotline.number}'),
            ),
          ],
        ],
      ),
    );
  }
}

class _HotlineUnavailable extends StatelessWidget {
  const _HotlineUnavailable({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _EmergencyHelpCard extends StatelessWidget {
  const _EmergencyHelpCard({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.error.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: scheme.onErrorContainer),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Emergency Help',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'In immediate danger, contact emergency services directly. BayanTrack does not replace emergency services.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onErrorContainer,
            ),
          ),
          if (onPressed != null) ...[
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: scheme.error,
                foregroundColor: scheme.onError,
                minimumSize: const Size(double.infinity, 48),
              ),
              icon: const Icon(Icons.call_outlined),
              label: const Text('View Emergency Hotlines'),
            ),
          ],
        ],
      ),
    );
  }
}
