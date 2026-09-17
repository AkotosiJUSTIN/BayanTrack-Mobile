import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';

/// Password strength levels — mirrors the web's StrongPasswordInput.tsx
enum _StrengthLevel { empty, weak, medium, strong, veryStrong, superStrong }

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({super.key, required this.password});

  // ── Requirement checks ────────────────────────────────────────────────────
  bool get _hasMinLength => password.length >= 8;
  bool get _hasLowercase => password.contains(RegExp(r'[a-z]'));
  bool get _hasUppercase => password.contains(RegExp(r'[A-Z]'));
  bool get _hasNumbers => password.contains(RegExp(r'[0-9]'));
  bool get _hasSpecial => password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  int get _passedCount {
    int count = 0;
    if (_hasMinLength) count++;
    if (_hasLowercase) count++;
    if (_hasUppercase) count++;
    if (_hasNumbers) count++;
    if (_hasSpecial) count++;
    return count;
  }

  // ── Strength level (matches web logic exactly) ────────────────────────────
  _StrengthLevel get _level {
    if (password.isEmpty) return _StrengthLevel.empty;
    switch (_passedCount) {
      case 0:
      case 1:
        return _StrengthLevel.weak;
      case 2:
        return _StrengthLevel.medium;
      case 3:
        return _StrengthLevel.strong;
      case 4:
        return _StrengthLevel.veryStrong;
      case 5:
        return _StrengthLevel.superStrong;
      default:
        return _StrengthLevel.empty;
    }
  }

  String _strengthLabel(AppLocalizations l10n) {
    return switch (_level) {
      _StrengthLevel.empty => '',
      _StrengthLevel.weak => l10n.weak,
      _StrengthLevel.medium => l10n.medium,
      _StrengthLevel.strong => l10n.strong,
      _StrengthLevel.veryStrong => l10n.veryStrong,
      _StrengthLevel.superStrong => l10n.superStrong,
    };
  }

  Color _strengthColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return switch (_level) {
      _StrengthLevel.empty => Colors.transparent,
      _StrengthLevel.weak => scheme.error,
      _StrengthLevel.medium => scheme.secondary,
      _StrengthLevel.strong => scheme.primary,
      _StrengthLevel.veryStrong => scheme.tertiary,
      _StrengthLevel.superStrong =>
        Theme.of(context).brightness == Brightness.dark
            ? AppColors.resolvedTextDark
            : AppColors.resolvedText,
    };
  }

  /// How many bar segments are active (min 1 when something is typed)
  int get _activeSegments {
    if (password.isEmpty) return 0;
    return _passedCount.clamp(1, 5);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final mutedColor = theme.colorScheme.onSurfaceVariant.withValues(
      alpha: 0.72,
    );
    final strengthColor = _strengthColor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Segmented strength bar ──────────────────────────────────────────
        Row(
          children: List.generate(5, (i) {
            final isActive = i < _activeSegments;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: 5,
                margin: EdgeInsets.only(right: i < 4 ? 3 : 0),
                decoration: BoxDecoration(
                  color: isActive
                      ? strengthColor
                      : theme.colorScheme.onSurface.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 10),

        // ── Level label ────────────────────────────────────────────────────
        Wrap(
          spacing: 4,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              '${l10n.level}: ',
              style: theme.textTheme.bodySmall?.copyWith(
                color: mutedColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                _strengthLabel(l10n),
                key: ValueKey(_strengthLabel(l10n)),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: strengthColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // ── Requirements header ────────────────────────────────────────────
        Text(
          l10n.passwordMustContain,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: mutedColor,
          ),
        ),
        const SizedBox(height: 6),

        // ── Requirements list ──────────────────────────────────────────────
        _RequirementRow(text: l10n.minimumCharacters, isMet: _hasMinLength),
        _RequirementRow(text: l10n.lowercaseRequirement, isMet: _hasLowercase),
        _RequirementRow(text: l10n.uppercaseRequirement, isMet: _hasUppercase),
        _RequirementRow(text: l10n.numberRequirement, isMet: _hasNumbers),
        _RequirementRow(
          text: l10n.specialCharacterRequirement,
          isMet: _hasSpecial,
        ),
      ],
    );
  }
}

class _RequirementRow extends StatelessWidget {
  final String text;
  final bool isMet;

  const _RequirementRow({required this.text, required this.isMet});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metColor = theme.brightness == Brightness.dark
        ? AppColors.resolvedTextDark
        : AppColors.resolvedText;
    final mutedColor = theme.colorScheme.onSurfaceVariant.withValues(
      alpha: 0.72,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              isMet ? Icons.check : Icons.close,
              key: ValueKey(isMet),
              size: 15,
              color: isMet ? metColor : mutedColor,
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isMet ? metColor : mutedColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
