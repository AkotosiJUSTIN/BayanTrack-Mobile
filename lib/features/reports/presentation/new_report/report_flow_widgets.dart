import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'quick_report_geo.dart';

class ReportReadOnlyLocationField extends StatelessWidget {
  const ReportReadOnlyLocationField({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return Semantics(
      container: true,
      label: '$label: $value',
      child: Material(
        color: scheme.surfaceContainerHighest.withValues(
          alpha: isDark ? 0.52 : 0.72,
        ),
        elevation: isDark ? 0 : 1,
        shadowColor: scheme.shadow.withValues(alpha: isDark ? 0 : 0.08),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 0, 12),
              child: Icon(icon, color: scheme.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 14, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      value,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReportLandmarkSuggestionChips extends StatelessWidget {
  const ReportLandmarkSuggestionChips({
    super.key,
    required this.suggestions,
    this.selectedLandmark,
    this.onSelected,
  });

  final List<String> suggestions;
  final String? selectedLandmark;
  final ValueChanged<String>? onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: suggestions
          .map(
            (suggestion) => FilterChip(
              selected: suggestion == selectedLandmark,
              showCheckmark: false,
              onSelected: onSelected == null
                  ? null
                  : (_) => onSelected!(suggestion),
              avatar: Icon(
                Icons.place_outlined,
                size: 17,
                color: suggestion == selectedLandmark
                    ? scheme.secondary
                    : scheme.onSurfaceVariant,
              ),
              label: Text(suggestion),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              side: BorderSide.none,
              shape: const StadiumBorder(),
              backgroundColor: scheme.surfaceContainerHighest.withValues(
                alpha: isDark ? 0.68 : 0.78,
              ),
              selectedColor: scheme.primaryContainer,
              disabledColor: scheme.surfaceContainerHighest.withValues(
                alpha: isDark ? 0.54 : 0.62,
              ),
              labelStyle: theme.textTheme.labelLarge?.copyWith(
                color: suggestion == selectedLandmark
                    ? scheme.onPrimaryContainer
                    : scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              materialTapTargetSize: MaterialTapTargetSize.padded,
            ),
          )
          .toList(),
    );
  }
}

class ReportLocationSummary extends StatelessWidget {
  const ReportLocationSummary({
    super.key,
    required this.city,
    this.location,
    this.coordinates,
    this.barangay,
    this.isResolvingBarangay = false,
    this.landmark,
    this.isResolvingLandmark = false,
    this.landmarkLookupError,
    this.landmarkLookupCompleted = false,
    this.landmarkSuggestions = const [],
    this.onLandmarkSelected,
    this.showCity = true,
  });

  final String city;
  final String? location;
  final String? coordinates;
  final String? barangay;
  final bool isResolvingBarangay;
  final String? landmark;
  final bool isResolvingLandmark;
  final String? landmarkLookupError;
  final bool landmarkLookupCompleted;
  final List<String> landmarkSuggestions;
  final ValueChanged<String>? onLandmarkSelected;
  final bool showCity;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showCity)
          _buildValue(context, l10n.city, city, Icons.location_city_outlined),
        _buildValue(
          context,
          l10n.barangay,
          barangay ?? l10n.barangaysUnavailable,
          Icons.location_city_outlined,
          isLoading: isResolvingBarangay,
        ),
        _buildLandmarkValue(context, l10n),
        if (location?.trim().isNotEmpty == true)
          _buildValue(
            context,
            l10n.address,
            _displayLocation(location!),
            Icons.place_outlined,
          ),
        if (coordinates != null)
          _buildValue(context, l10n.gps, coordinates!, Icons.gps_fixed),
      ],
    );
  }

  String _displayLocation(String value) {
    const manualSelectionPrefix = 'Manual selection: ';
    return value.startsWith(manualSelectionPrefix)
        ? value.substring(manualSelectionPrefix.length)
        : value;
  }

  Widget _buildLandmarkValue(BuildContext context, AppLocalizations l10n) {
    final value =
        landmarkLookupError ??
        (landmark?.trim().isNotEmpty == true
            ? landmark!.trim()
            : landmarkLookupCompleted
            ? landmarkSuggestions.isNotEmpty
                  ? chooseNearbyLandmark
                  : noNearbyLandmarkFound
            : l10n.gettingLocation);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildValue(
          context,
          l10n.streetLandmark,
          value,
          Icons.place_outlined,
          isLoading: isResolvingLandmark,
          isError: landmarkLookupError != null,
        ),
        if (landmarkSuggestions.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            l10n.streetLandmark,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          ReportLandmarkSuggestionChips(
            suggestions: landmarkSuggestions,
            selectedLandmark: landmark,
            onSelected: onLandmarkSelected,
          ),
        ],
      ],
    );
  }

  Widget _buildValue(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    bool isLoading = false,
    bool isError = false,
  }) {
    final theme = Theme.of(context);
    final color = isError ? theme.colorScheme.error : null;
    return Semantics(
      container: true,
      label: '$label: $value',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: (color ?? theme.colorScheme.primary).withValues(
                  alpha: theme.brightness == Brightness.dark ? 0.16 : 0.10,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: color ?? theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (isLoading)
                    Row(
                      children: [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(child: Text(value)),
                      ],
                    )
                  else
                    Text(
                      value,
                      style: theme.textTheme.bodyMedium?.copyWith(color: color),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReportFlowProgress extends StatelessWidget {
  const ReportFlowProgress({
    super.key,
    required this.step,
    required this.total,
  });

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final scheme = theme.colorScheme;

    return Semantics(
      container: true,
      label: l10n.stepOf(step, total),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.stepOf(step, total),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(step / total * 100).round()}%',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: step / total,
                minHeight: 5,
                backgroundColor: scheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReportFlowHeader extends StatelessWidget {
  const ReportFlowHeader({
    super.key,
    required this.title,
    required this.guidance,
  });

  final String title;
  final String guidance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            guidance,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class ReportFlowBottomBar extends StatelessWidget {
  const ReportFlowBottomBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.scaffoldBackgroundColor,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
        ),
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: child,
        ),
      ),
    );
  }
}

class ReportFlowSection extends StatelessWidget {
  const ReportFlowSection({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.trailing,
    this.description,
  });

  final String title;
  final Widget child;
  final IconData? icon;
  final String? trailing;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: scheme.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: scheme.primary),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (trailing != null)
                Flexible(
                  child: Text(
                    trailing!,
                    textAlign: TextAlign.end,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
          if (description != null) ...[
            const SizedBox(height: 4),
            Text(
              description!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
