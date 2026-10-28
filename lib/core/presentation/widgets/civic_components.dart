import 'package:flutter/material.dart';

/// Shared presentation primitives for the citizen-facing public-service UI.
/// These stay deliberately small and build on the app's existing theme tokens.
class CivicSurface extends StatelessWidget {
  const CivicSurface({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: scheme.surface,
        elevation: isDark ? 0 : 1,
        shadowColor: scheme.shadow.withValues(alpha: isDark ? 0 : 0.08),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: padding == null
            ? child
            : Padding(padding: padding!, child: child),
      ),
    );
  }
}

class CivicSectionHeading extends StatelessWidget {
  const CivicSectionHeading({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
      child: Semantics(
        header: true,
        child: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class CivicStatusChip extends StatelessWidget {
  const CivicStatusChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.semanticLabel,
  });

  final String label;
  final Color color;
  final IconData? icon;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      container: true,
      label: semanticLabel ?? label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 5),
            ],
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 220),
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared, low-chrome filter control used by report lists.
class CivicFilterChip extends StatelessWidget {
  const CivicFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ChoiceChip(
      selected: selected,
      label: Text(label),
      showCheckmark: false,
      selectedColor: scheme.primaryContainer,
      backgroundColor: scheme.surfaceContainerLow,
      labelStyle: TextStyle(
        color: selected ? scheme.onPrimaryContainer : scheme.onSurface,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
      ),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: onSelected,
    );
  }
}

/// Native-feeling grouped settings surface with one consistent row pattern.
class CivicSettingsGroup extends StatelessWidget {
  const CivicSettingsGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return CivicSurface(child: Column(children: children));
  }
}

class CivicSettingsRow extends StatelessWidget {
  const CivicSettingsRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.destructive = false,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool destructive;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final foreground = destructive ? scheme.error : scheme.onSurfaceVariant;
    final titleStyle = theme.textTheme.bodyLarge?.copyWith(
      color: destructive ? scheme.error : scheme.onSurface,
      fontWeight: FontWeight.w600,
    );

    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          minLeadingWidth: 32,
          leading: Icon(icon, color: foreground),
          title: Text(title, style: titleStyle),
          subtitle: subtitle == null
              ? null
              : Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
          trailing:
              trailing ??
              (onTap == null
                  ? null
                  : Icon(Icons.chevron_right, color: scheme.onSurfaceVariant)),
          onTap: onTap,
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 64,
            endIndent: 16,
            color: scheme.outlineVariant.withValues(alpha: 0.72),
          ),
      ],
    );
  }
}

class CivicSkeletonBlock extends StatelessWidget {
  const CivicSkeletonBlock({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.radius = 10,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
