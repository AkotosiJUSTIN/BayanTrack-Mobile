import 'package:flutter/material.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({super.key, required this.password});

  bool get _hasMinLength => password.length >= 8;
  bool get _hasLowercase => password.contains(RegExp(r'[a-z]'));
  bool get _hasUppercase => password.contains(RegExp(r'[A-Z]'));
  bool get _hasNumbers => password.contains(RegExp(r'[0-9]'));
  bool get _hasSpecial => password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  int get _strengthScore {
    int score = 0;
    if (_hasMinLength) score++;
    if (_hasLowercase) score++;
    if (_hasUppercase) score++;
    if (_hasNumbers) score++;
    if (_hasSpecial) score++;
    return score;
  }

  String get _strengthText {
    if (password.isEmpty) return 'None';
    switch (_strengthScore) {
      case 0:
      case 1:
      case 2:
        return 'Weak';
      case 3:
      case 4:
        return 'Good';
      case 5:
        return 'Super Strong';
      default:
        return 'None';
    }
  }

  Color _strengthColor(BuildContext context) {
    if (password.isEmpty) return Colors.grey;
    switch (_strengthScore) {
      case 0:
      case 1:
      case 2:
        return Colors.red;
      case 3:
      case 4:
        return Colors.orange;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // We only show this if the password isn't completely empty, or we can always show it.
    // The image shows the requirements text.

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Level: ',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              _strengthText,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: _strengthColor(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Your password must contain:',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
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
    final color = isMet ? Colors.green : Colors.red;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(isMet ? Icons.check : Icons.close, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
