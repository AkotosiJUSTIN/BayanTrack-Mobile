import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// BayanTrack theme configuration for light and dark modes.
abstract final class AppTheme {
  // ─────────────────────────────────────────────────────────
  // LIGHT THEME
  // ─────────────────────────────────────────────────────────

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: _lightColorScheme,
      scaffoldBackgroundColor: AppColors.citizenLightPage,
      textTheme: _textTheme(
        AppColors.lightTextPrimary,
        AppColors.lightTextSecondary,
        AppColors.lightTextTertiary,
      ),
      disabledColor: AppColors.lightTextDisabled,
      appBarTheme: _appBarTheme(isLight: true),
      inputDecorationTheme: _inputDecorationTheme(isLight: true),
      elevatedButtonTheme: _elevatedButtonTheme(),
      filledButtonTheme: _filledButtonTheme(isLight: true),
      outlinedButtonTheme: _outlinedButtonTheme(isLight: true),
      textButtonTheme: _textButtonTheme(),
      cardTheme: _cardTheme(isLight: true),
      chipTheme: _chipTheme(isLight: true),
      segmentedButtonTheme: _segmentedButtonTheme(isLight: true),
      bottomNavigationBarTheme: _bottomNavTheme(isLight: true),
      floatingActionButtonTheme: _fabTheme(),
      dividerTheme: DividerThemeData(
        color: AppColors.lightBorder.withValues(alpha: 0.58),
        thickness: 1,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: AppColors.lightBorder, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return AppColors.lightTextSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.lightBorder;
        }),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // DARK THEME
  // ─────────────────────────────────────────────────────────

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: _darkColorScheme,
      scaffoldBackgroundColor: AppColors.citizenDarkPage,
      textTheme: _textTheme(
        AppColors.darkTextPrimary,
        AppColors.darkTextSecondary,
        AppColors.darkTextTertiary,
      ),
      disabledColor: AppColors.darkTextDisabled,
      appBarTheme: _appBarTheme(isLight: false),
      inputDecorationTheme: _inputDecorationTheme(isLight: false),
      elevatedButtonTheme: _elevatedButtonTheme(),
      filledButtonTheme: _filledButtonTheme(isLight: false),
      outlinedButtonTheme: _outlinedButtonTheme(isLight: false),
      textButtonTheme: _textButtonTheme(),
      cardTheme: _cardTheme(isLight: false),
      chipTheme: _chipTheme(isLight: false),
      segmentedButtonTheme: _segmentedButtonTheme(isLight: false),
      bottomNavigationBarTheme: _bottomNavTheme(isLight: false),
      floatingActionButtonTheme: _fabTheme(),
      dividerTheme: DividerThemeData(
        color: AppColors.darkBorder.withValues(alpha: 0.52),
        thickness: 1,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryLight;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: AppColors.darkBorder, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return AppColors.darkTextSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryLight;
          }
          return AppColors.darkBorder;
        }),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // COLOR SCHEMES
  // ─────────────────────────────────────────────────────────

  static const ColorScheme _lightColorScheme = ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFDCE8FF),
    onPrimaryContainer: Color(0xFF0B3D96),
    secondary: AppColors.accent,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFFFE4D4),
    onSecondaryContainer: Color(0xFF6F2800),
    tertiary: Color(0xFF0F766E),
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFC8F2EA),
    onTertiaryContainer: Color(0xFF064E49),
    surface: AppColors.lightBackground,
    onSurface: AppColors.lightTextPrimary,
    surfaceDim: Color(0xFFE2E7EE),
    surfaceBright: Colors.white,
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: AppColors.citizenLightSurface,
    surfaceContainer: Color(0xFFF2F5F9),
    surfaceContainerHigh: Color(0xFFECF1F6),
    surfaceContainerHighest: AppColors.citizenLightInput,
    onSurfaceVariant: AppColors.lightTextSecondary,
    error: AppColors.alertHigh,
    onError: Colors.white,
    errorContainer: Color(0xFFFFE4E4),
    onErrorContainer: Color(0xFF8C1D18),
    outline: AppColors.lightBorder,
    outlineVariant: Color(0xFFE0E6EE),
    shadow: Color(0xFF152238),
    surfaceTint: Colors.transparent,
  );

  static const ColorScheme _darkColorScheme = ColorScheme.dark(
    primary: AppColors.primaryLight,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFF17356E),
    onPrimaryContainer: Color(0xFFDCE8FF),
    secondary: AppColors.accentLight,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFF653010),
    onSecondaryContainer: Color(0xFFFFDCC6),
    tertiary: Color(0xFF65D8CB),
    onTertiary: Color(0xFF003733),
    tertiaryContainer: Color(0xFF0A4F4A),
    onTertiaryContainer: Color(0xFFC8F2EA),
    surface: AppColors.citizenDarkSurface,
    onSurface: AppColors.darkTextPrimary,
    surfaceDim: AppColors.darkBackground,
    surfaceBright: Color(0xFF313A47),
    surfaceContainerLowest: Color(0xFF0A0E13),
    surfaceContainerLow: AppColors.citizenDarkSurface,
    surfaceContainer: Color(0xFF1D242E),
    surfaceContainerHigh: Color(0xFF242C37),
    surfaceContainerHighest: AppColors.citizenDarkInput,
    onSurfaceVariant: AppColors.darkTextSecondary,
    error: AppColors.alertHighLight,
    onError: Colors.white,
    errorContainer: Color(0xFF6E2020),
    onErrorContainer: Color(0xFFFFDAD6),
    outline: AppColors.darkBorder,
    outlineVariant: Color(0xFF3B4654),
    shadow: Colors.black,
    surfaceTint: Colors.transparent,
  );

  // ─────────────────────────────────────────────────────────
  // TEXT THEME
  // ─────────────────────────────────────────────────────────

  static TextTheme _textTheme(Color primary, Color secondary, Color tertiary) {
    final base = Typography.material2021(
      platform: defaultTargetPlatform,
    ).black.apply(bodyColor: primary, displayColor: primary);
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: primary,
        letterSpacing: -0.6,
        height: 1.12,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: primary,
        letterSpacing: -0.4,
        height: 1.14,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: primary,
        letterSpacing: -0.2,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16,
        color: primary,
        height: 1.45,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14,
        color: primary,
        height: 1.45,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 13,
        color: secondary,
        height: 1.35,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: tertiary,
        letterSpacing: 0.2,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // APP BAR THEME
  // ─────────────────────────────────────────────────────────

  static AppBarTheme _appBarTheme({required bool isLight}) {
    return AppBarTheme(
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: isLight
          ? AppColors.citizenLightPage
          : AppColors.citizenDarkPage,
      foregroundColor: isLight
          ? AppColors.lightTextPrimary
          : AppColors.darkTextPrimary,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: isLight ? AppColors.lightTextPrimary : AppColors.darkTextPrimary,
      ),
      iconTheme: IconThemeData(
        color: isLight ? AppColors.lightTextPrimary : AppColors.darkTextPrimary,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // INPUT DECORATION THEME
  // ─────────────────────────────────────────────────────────

  static InputDecorationTheme _inputDecorationTheme({required bool isLight}) {
    final borderRadius = BorderRadius.circular(14);
    final focusColor = isLight ? AppColors.primary : AppColors.primaryLight;
    final errorColor = isLight ? AppColors.alertHigh : AppColors.alertHighLight;
    final fillColor = isLight
        ? AppColors.citizenLightInput
        : AppColors.citizenDarkInput;
    final hintColor = isLight
        ? AppColors.lightTextSecondary
        : AppColors.darkTextSecondary;
    final quietBorder = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide.none,
    );

    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      hintStyle: TextStyle(color: hintColor, fontSize: 14),
      labelStyle: TextStyle(color: hintColor, fontSize: 14),
      floatingLabelStyle: TextStyle(
        color: focusColor,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      prefixIconColor: hintColor,
      suffixIconColor: hintColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: quietBorder,
      enabledBorder: quietBorder,
      disabledBorder: quietBorder,
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: focusColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: errorColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: errorColor, width: 1.5),
      ),
      errorStyle: TextStyle(color: errorColor, fontSize: 12),
    );
  }

  // ─────────────────────────────────────────────────────────
  // BUTTON THEMES
  // ─────────────────────────────────────────────────────────

  static ElevatedButtonThemeData _elevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }

  static FilledButtonThemeData _filledButtonTheme({required bool isLight}) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: isLight
            ? AppColors.lightSurfaceVariant
            : AppColors.darkSurfaceVariant,
        disabledForegroundColor: isLight
            ? AppColors.lightTextDisabled
            : AppColors.darkTextDisabled,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme({required bool isLight}) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: isLight
            ? AppColors.lightTextPrimary
            : AppColors.darkTextPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        minimumSize: const Size(double.infinity, 52),
        side: BorderSide(
          color: (isLight ? AppColors.lightBorder : AppColors.darkBorder)
              .withValues(alpha: 0.78),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // CARD THEME
  // ─────────────────────────────────────────────────────────

  static CardThemeData _cardTheme({required bool isLight}) {
    return CardThemeData(
      elevation: isLight ? 1 : 0,
      color: isLight ? AppColors.lightBackground : AppColors.darkSurface,
      shadowColor: isLight
          ? AppColors.lightTextPrimary.withValues(alpha: 0.08)
          : Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
    );
  }

  static ChipThemeData _chipTheme({required bool isLight}) {
    final scheme = isLight ? _lightColorScheme : _darkColorScheme;
    return ChipThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      selectedColor: scheme.primaryContainer,
      disabledColor: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
      checkmarkColor: scheme.onPrimaryContainer,
      labelStyle: TextStyle(
        color: scheme.onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      secondaryLabelStyle: TextStyle(color: scheme.onSurfaceVariant),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      labelPadding: EdgeInsets.zero,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  static SegmentedButtonThemeData _segmentedButtonTheme({
    required bool isLight,
  }) {
    final scheme = isLight ? _lightColorScheme : _darkColorScheme;
    return SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? scheme.primaryContainer
              : scheme.surfaceContainerLow;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? scheme.onPrimaryContainer
              : scheme.onSurface;
        }),
        side: WidgetStatePropertyAll(
          BorderSide(color: scheme.outlineVariant, width: 1),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // BOTTOM NAVIGATION THEME
  // ─────────────────────────────────────────────────────────

  static BottomNavigationBarThemeData _bottomNavTheme({required bool isLight}) {
    return BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: isLight
          ? AppColors.lightBackground
          : AppColors.darkBackground,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: isLight
          ? AppColors.lightTextSecondary
          : AppColors.darkTextSecondary,
      selectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      elevation: 8,
    );
  }

  // ─────────────────────────────────────────────────────────
  // FAB THEME (Orange CTA)
  // ─────────────────────────────────────────────────────────

  static FloatingActionButtonThemeData _fabTheme() {
    return const FloatingActionButtonThemeData(
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: CircleBorder(),
      sizeConstraints: BoxConstraints.tightFor(width: 60, height: 60),
    );
  }
}
