import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/incident_catalog.g.dart';
import '../../data/reports_repository.dart';

final incidentChoicesProvider = FutureProvider((ref) async {
  final options = await ref.watch(reportsRepositoryProvider).getFormOptions();
  return (
    version: options.incidentCatalogVersion,
    items: options.incidentTypes,
  );
});

String incidentDisplay(String? key, String language, String fallback) {
  for (final entry in bundledIncidentCatalog['incident_types'] as List) {
    if (entry['key'] == key) {
      return (entry['labels'] as Map)[language]?.toString() ?? fallback;
    }
  }
  return fallback;
}

class IncidentChoiceField extends ConsumerWidget {
  const IncidentChoiceField({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });
  final String? value;
  final void Function(String?, String?) onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(incidentChoicesProvider);
    final live = state.asData?.value;
    final items = live?.version != null
        ? live!.items
        : (bundledIncidentCatalog['incident_types'] as List)
              .cast<Map<String, dynamic>>();
    final version =
        live?.version ??
        bundledIncidentCatalog['incident_catalog_version'] as String;
    final language = Localizations.localeOf(context).languageCode;
    final filipino = language == 'fil';
    final choices = items.where((entry) => entry['active'] == true).toList();
    final known = choices.any((entry) => entry['key'] == value);
    return DropdownButtonFormField<String>(
      key: ValueKey('incident-choice-${value ?? ''}-$version'),
      initialValue: value ?? '',
      isExpanded: true,
      decoration: InputDecoration(
        labelText: filipino ? 'Insidente (opsyonal)' : 'Incident (optional)',
        helperText: filipino
            ? 'Hiwalay ang opisyal na pag-uuri.'
            : 'Reported observation; staff classification is separate.',
        helperMaxLines: 2,
      ),
      items: [
        DropdownMenuItem(
          value: '',
          child: Text(filipino ? 'Hindi tinukoy' : 'Not specified'),
        ),
        if (value != null && !known)
          DropdownMenuItem(
            value: value,
            child: Text(
              filipino
                  ? 'Dating pagpili — maaaring alisin'
                  : 'Previous choice — clear to remove',
            ),
          ),
        for (final group in bundledIncidentCatalog['categories'] as List) ...[
          DropdownMenuItem(
            value: 'group:${group['key']}',
            enabled: false,
            child: Text(
              group['label'] as String,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          for (final item in choices.where(
            (entry) => entry['category_key'] == group['key'],
          ))
            DropdownMenuItem(
              value: item['key'] as String,
              child: Text(
                (item['labels'] as Map?)?[language]?.toString() ??
                    item['label'] as String,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ],
      onChanged: enabled
          ? (key) =>
                onChanged(key == '' ? null : key, key == '' ? null : version)
          : null,
    );
  }
}
