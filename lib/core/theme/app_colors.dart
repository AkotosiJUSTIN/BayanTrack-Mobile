import 'package:flutter/material.dart';

/// BayanTrack color palette for light and dark modes.
/// Extracted from design mockups.
abstract final class AppColors {
  // ─────────────────────────────────────────────────────────
  // PRIMARY PALETTE
  // ─────────────────────────────────────────────────────────

  /// Primary blue - buttons, links, active states
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1D4ED8);

  /// Accent orange - Report CTA, FAB
  static const Color accent = Color(0xFFF97316);
  static const Color accentLight = Color(0xFFFB923C);

  /// Auth / onboarding brand palette (splash, onboarding, login, register).
  /// Intentionally richer than [primary]/[accent] for the marketing-style
  /// authentication surfaces; centralized here to avoid duplicated literals.
  static const Color brandBlue = Color(0xFF064BEE);
  static const Color brandOrange = Color(0xFFF86A05);

  /// Primary variant for AI features
  static const Color primaryVariant = Color(0xFF7C3AED); // Violet 600

  /// Success green
  static const Color success = Color(0xFF22C55E); // Green 500

  // ─────────────────────────────────────────────────────────
  // ALERT / STATUS COLORS
  // ─────────────────────────────────────────────────────────

  /// Low priority / Resolved
  static const Color alertLow = Color(0xFF22C55E);
  static const Color alertLowLight = Color(0xFF4ADE80);

  /// Medium priority / In Progress
  static const Color alertMedium = Color(0xFFF59E0B);
  static const Color alertMediumLight = Color(0xFFFBBF24);

  /// High priority / Urgent
  static const Color alertHigh = Color(0xFFEF4444);
  static const Color alertHighLight = Color(0xFFF87171);

  // ─────────────────────────────────────────────────────────
  // LIGHT MODE COLORS
  // ─────────────────────────────────────────────────────────

  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF8FAFC); // Slate 50
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9); // Slate 100
  static const Color lightTextPrimary = Color(0xFF0F172A); // Slate 900
  static const Color lightTextSecondary = Color(0xFF475569); // Slate 600
  static const Color lightTextTertiary = Color(0xFF5B6B82); // Blue slate 550
  static const Color lightTextDisabled = Color(0xFF94A3B8); // Slate 400
  static const Color lightBorder = Color(0xFFCBD5E1); // Slate 300
  static const Color lightInputFill = Color(0xFFF1F5F9); // Slate 100

  /// Citizen surfaces are intentionally separate from auth/onboarding tokens.
  static const Color citizenLightPage = Color(0xFFF2F5F9);
  static const Color citizenLightSurface = Color(0xFFF9FBFD);
  static const Color citizenLightInput = Color(0xFFEAF0F6);

  // ─────────────────────────────────────────────────────────
  // DARK MODE COLORS
  // ─────────────────────────────────────────────────────────

  static const Color darkBackground = Color(0xFF0F172A); // Slate 900
  static const Color darkSurface = Color(0xFF1E293B); // Slate 800
  static const Color darkSurfaceVariant = Color(0xFF334155); // Slate 700
  static const Color darkTextPrimary = Color(0xFFF8FAFC); // Slate 50
  static const Color darkTextSecondary = Color(0xFFCBD5E1); // Slate 300
  static const Color darkTextTertiary = Color(0xFF94A3B8); // Slate 400
  static const Color darkTextDisabled = Color(0xFF64748B); // Slate 500
  static const Color darkBorder = Color(0xFF475569); // Slate 600
  static const Color darkInputFill = Color(0xFF1E293B); // Slate 800

  static const Color citizenDarkPage = Color(0xFF0D1117);
  static const Color citizenDarkSurface = Color(0xFF171C24);
  static const Color citizenDarkSurfaceVariant = Color(0xFF232B36);
  static const Color citizenDarkInput = Color(0xFF232B36);

  // ─────────────────────────────────────────────────────────
  // STATUS BADGE COLORS (Background / Text pairs)
  // ─────────────────────────────────────────────────────────

  // Pending - Amber
  static const Color pendingBg = Color(0xFFFEF3C7); // Amber 100
  static const Color pendingText = Color(0xFFB45309); // Amber 700
  static const Color pendingBgDark = Color(0xFF78350F); // Amber 900
  static const Color pendingTextDark = Color(0xFFFCD34D); // Amber 300

  // In Progress - Blue
  static const Color inProgressBg = Color(0xFFDBEAFE); // Blue 100
  static const Color inProgressText = Color(0xFF1D4ED8); // Blue 700
  static const Color inProgressBgDark = Color(0xFF1E3A8A); // Blue 900
  static const Color inProgressTextDark = Color(0xFF93C5FD); // Blue 300

  // Resolved - Green
  static const Color resolvedBg = Color(0xFFDCFCE7); // Green 100
  static const Color resolvedText = Color(0xFF15803D); // Green 700
  static const Color resolvedBgDark = Color(0xFF14532D); // Green 900
  static const Color resolvedTextDark = Color(0xFF86EFAC); // Green 300

  // Rejected - Red
  static const Color rejectedBg = Color(0xFFFEE2E2); // Red 100
  static const Color rejectedText = Color(0xFFB91C1C); // Red 700
  static const Color rejectedBgDark = Color(0xFF7F1D1D); // Red 900
  static const Color rejectedTextDark = Color(0xFFFCA5A5); // Red 300
}
