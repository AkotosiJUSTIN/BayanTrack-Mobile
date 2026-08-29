import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      scaffoldBackgroundColor: AppColors.lightSurfaceVariant,
      textTheme: _textTheme(
        AppColors.lightTextPrimary,
        AppColors.lightTextSecondary,
        AppColors.lightTextTertiary,
      ),
      disabledColor: AppColors.lightTextDisabled,
      appBarTheme: _appBarTheme(isLight: true),
      inputDecorationTheme: _inputDecorationTheme(isLight: true),
      elevatedButtonTheme: _elevatedButtonTheme(),
      outlinedButtonTheme: _outlinedButtonTheme(isLight: true),
      textButtonTheme: _textButtonTheme(),
      cardTheme: _cardTheme(isLight: true),
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
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: _textTheme(
        AppColors.darkTextPrimary,
        AppColors.darkTextSecondary,
        AppColors.darkTextTertiary,
      ),
      disabledColor: AppColors.darkTextDisabled,
      appBarTheme: _appBarTheme(isLight: false),
      inputDecorationTheme: _inputDecorationTheme(isLight: false),
      elevatedButtonTheme: _elevatedButtonTheme(),
      outlinedButtonTheme: _outlinedButtonTheme(isLight: false),
      textButtonTheme: _textButtonTheme(),
      cardTheme: _cardTheme(isLight: false),
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
    secondary: AppColors.accent,
    onSecondary: Colors.white,
    surface: AppColors.lightBackground,
    onSurface: AppColors.lightTextPrimary,
    onSurfaceVariant: AppColors.lightTextSecondary,
    error: AppColors.alertHigh,
    onError: Colors.white,
    outline: AppColors.lightBorder,
  );

  static const ColorScheme _darkColorScheme = ColorScheme.dark(
    primary: AppColors.primaryLight,
    onPrimary: Colors.white,
    secondary: AppColors.accentLight,
    onSecondary: Colors.white,
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkTextPrimary,
    onSurfaceVariant: AppColors.darkTextSecondary,
    error: AppColors.alertHighLight,
    onError: Colors.white,
    outline: AppColors.darkBorder,
  );

  // ─────────────────────────────────────────────────────────
  // TEXT THEME
  // ─────────────────────────────────────────────────────────

  static TextTheme _textTheme(Color primary, Color secondary, Color tertiary) {
    return GoogleFonts.manropeTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: primary,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: primary,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleMedium: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleSmall: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      bodyLarge: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: primary,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: primary,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: secondary,
      ),
      labelLarge: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      labelSmall: GoogleFonts.manrope(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: tertiary,
        letterSpacing: 0.5,
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
      backgroundColor: isLight
          ? AppColors.lightSurface
          : AppColors.darkBackground,
      foregroundColor: isLight
          ? AppColors.lightTextPrimary
          : AppColors.darkTextPrimary,
      titleTextStyle: GoogleFonts.inter(
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
    final borderRadius = BorderRadius.circular(12);
    final borderColor = isLight ? AppColors.lightBorder : AppColors.darkBorder;
    final fillColor = isLight
        ? AppColors.lightBackground
        : AppColors.darkInputFill;
    final hintColor = isLight
        ? AppColors.lightTextSecondary
        : AppColors.darkTextSecondary;

    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      hintStyle: GoogleFonts.manrope(color: hintColor, fontSize: 14),
      labelStyle: GoogleFonts.manrope(fontSize: 14),
      prefixIconColor: hintColor,
      suffixIconColor: hintColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: isLight ? AppColors.primary : AppColors.primaryLight,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: AppColors.alertHigh),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: AppColors.alertHigh, width: 2),
      ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.manrope(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
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
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.manrope(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
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
          ? AppColors.lightTextPrimary.withValues(alpha: 0.1)
          : Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: (isLight ? AppColors.lightBorder : AppColors.darkBorder)
              .withValues(alpha: isLight ? 0.42 : 0.28),
          width: 1,
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      selectedLabelStyle: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelStyle: GoogleFonts.manrope(
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
    );
  }
}
