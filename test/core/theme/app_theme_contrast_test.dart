import 'package:bayantrack_mobile/core/theme/app_colors.dart';
import 'package:bayantrack_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double _contrast(Color foreground, Color background) {
  final foregroundLuminance = foreground.computeLuminance();
  final backgroundLuminance = background.computeLuminance();
  final lighter = foregroundLuminance > backgroundLuminance
      ? foregroundLuminance
      : backgroundLuminance;
  final darker = foregroundLuminance > backgroundLuminance
      ? backgroundLuminance
      : foregroundLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'secondary and tertiary text tokens remain readable on app surfaces',
    () {
      expect(
        _contrast(AppColors.lightTextSecondary, AppColors.lightSurfaceVariant),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrast(AppColors.lightTextTertiary, AppColors.lightSurfaceVariant),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrast(AppColors.darkTextSecondary, AppColors.darkSurface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrast(AppColors.darkTextTertiary, AppColors.darkSurface),
        greaterThanOrEqualTo(4.5),
      );
    },
  );

  test('light page and card surfaces use distinct tonal levels', () {
    expect(
      AppTheme.light.scaffoldBackgroundColor,
      AppColors.lightSurfaceVariant,
    );
    expect(AppTheme.light.cardTheme.color, AppColors.lightBackground);
    expect(
      AppTheme.light.colorScheme.onSurfaceVariant,
      AppColors.lightTextSecondary,
    );
    expect(
      AppTheme.dark.colorScheme.onSurfaceVariant,
      AppColors.darkTextSecondary,
    );
  });
}
