import 'package:flutter/material.dart';

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

  String get _strengthLabel {
    return switch (_level) {
      _StrengthLevel.empty => '',
      _StrengthLevel.weak => 'Weak',
      _StrengthLevel.medium => 'Medium',
      _StrengthLevel.strong => 'Strong',
      _StrengthLevel.veryStrong => 'Very Strong',
      _StrengthLevel.superStrong => 'Super Strong',
    };
  }

  Color get _strengthColor {
    return switch (_level) {
      _StrengthLevel.empty => Colors.transparent,
      _StrengthLevel.weak => const Color(0xFFEF4444),      // red-500
      _StrengthLevel.medium => const Color(0xFFF59E0B),    // amber-500
      _StrengthLevel.strong => const Color(0xFF2563EB),    // blue-600
      _StrengthLevel.veryStrong => const Color(0xFF6366F1), // indigo-500
      _StrengthLevel.superStrong => const Color(0xFF22C55E), // green-500
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
    final mutedColor = theme.colorScheme.onSurface.withValues(alpha: 0.4);

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
                      ? _strengthColor
                      : theme.colorScheme.onSurface.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 10),

        // ── Level label ────────────────────────────────────────────────────
        Row(
          children: [
            Text(
              'Level: ',
              style: theme.textTheme.bodySmall?.copyWith(
                color: mutedColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                _strengthLabel,
                key: ValueKey(_strengthLabel),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _strengthColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // ── Requirements header ────────────────────────────────────────────
        Text(
          'Your password must contain:',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: mutedColor,
          ),
        ),
        const SizedBox(height: 6),

        // ── Requirements list ──────────────────────────────────────────────
        _RequirementRow(
          text: 'Minimum number of characters is 8.',
          isMet: _hasMinLength,
        ),
        _RequirementRow(
          text: 'Should contain lowercase.',
          isMet: _hasLowercase,
        ),
        _RequirementRow(
          text: 'Should contain uppercase.',
          isMet: _hasUppercase,
        ),
        _RequirementRow(text: 'Should contain numbers.', isMet: _hasNumbers),
        _RequirementRow(
          text: 'Should contain special characters.',
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
    final metColor = const Color(0xFF22C55E);
    final mutedColor = theme.colorScheme.onSurface.withValues(alpha: 0.4);

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
