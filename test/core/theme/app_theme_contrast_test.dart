import 'package:bayantrack_mobile/core/theme/app_colors.dart';
import 'package:bayantrack_mobile/core/theme/app_theme.dart';
import 'package:bayantrack_mobile/core/presentation/widgets/civic_components.dart';
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

double _tonalDistance(Color first, Color second) =>
    (first.computeLuminance() - second.computeLuminance()).abs();

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

  test('light unread notification surface preserves text contrast', () {
    final unreadSurface = AppColors.citizenLightUnreadNotification;

    expect(unreadSurface, isNot(AppColors.citizenLightPage));
    expect(
      _contrast(AppColors.primary, unreadSurface),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrast(AppColors.lightTextSecondary, unreadSurface),
      greaterThanOrEqualTo(4.5),
    );
  });

  test('light page, read, and unread surfaces form a clear hierarchy', () {
    final page = AppColors.citizenLightPage;
    final read = AppTheme.light.colorScheme.surface;
    final unread = AppColors.citizenLightUnreadNotification;

    expect(page, const Color(0xFFF7F8FA));
    expect(AppTheme.light.scaffoldBackgroundColor, page);
    expect(read, Colors.white);
    expect(
      _tonalDistance(unread, page),
      greaterThan(_tonalDistance(read, page)),
    );
  });

  test('light page and card surfaces use distinct tonal levels', () {
    expect(AppTheme.light.scaffoldBackgroundColor, AppColors.citizenLightPage);
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

  test('cards and inputs use tonal separation with focus-only outlines', () {
    final lightCard = AppTheme.light.cardTheme.shape! as RoundedRectangleBorder;
    final darkCard = AppTheme.dark.cardTheme.shape! as RoundedRectangleBorder;
    final lightInput =
        AppTheme.light.inputDecorationTheme.enabledBorder!
            as OutlineInputBorder;
    final darkInput =
        AppTheme.dark.inputDecorationTheme.enabledBorder! as OutlineInputBorder;
    final lightFocused =
        AppTheme.light.inputDecorationTheme.focusedBorder!
            as OutlineInputBorder;
    final darkFocused =
        AppTheme.dark.inputDecorationTheme.focusedBorder! as OutlineInputBorder;

    expect(lightCard.side.style, BorderStyle.none);
    expect(darkCard.side.style, BorderStyle.none);
    expect(lightInput.borderSide.style, BorderStyle.none);
    expect(darkInput.borderSide.style, BorderStyle.none);
    expect(lightFocused.borderSide.style, BorderStyle.solid);
    expect(darkFocused.borderSide.style, BorderStyle.solid);
  });

  testWidgets('CivicSurface uses elevation without a decorative stroke', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const CivicSurface(child: SizedBox(height: 24)),
      ),
    );

    final material = tester.widget<Material>(find.byType(Material));
    final shape = material.shape! as RoundedRectangleBorder;
    expect(shape.side.style, BorderStyle.none);
  });
}
