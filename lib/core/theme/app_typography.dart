import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography scale built on `Plus Jakarta Sans` — a distinctive geometric sans
/// chosen to read very differently from the default Material/Roboto stack used
/// by typical smart-home templates.
class AppTypography {
  AppTypography._();

  static TextStyle _base({
    required double size,
    required FontWeight weight,
    Color color = AppColors.textPrimary,
    double height = 1.35,
    double? letterSpacing,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  // ─── Display ─────────────────────────────────────────────
  static TextStyle get displayLarge =>
      _base(size: 36, weight: FontWeight.w700, height: 1.15, letterSpacing: -0.5);
  static TextStyle get displayMedium =>
      _base(size: 30, weight: FontWeight.w700, height: 1.2, letterSpacing: -0.4);

  // ─── Headline ────────────────────────────────────────────
  static TextStyle get headlineLarge =>
      _base(size: 24, weight: FontWeight.w700, height: 1.25, letterSpacing: -0.3);
  static TextStyle get headlineMedium =>
      _base(size: 20, weight: FontWeight.w700, height: 1.3);
  static TextStyle get headlineSmall =>
      _base(size: 18, weight: FontWeight.w600, height: 1.3);

  // ─── Title ───────────────────────────────────────────────
  static TextStyle get titleLarge =>
      _base(size: 17, weight: FontWeight.w600, height: 1.35);
  static TextStyle get titleMedium =>
      _base(size: 15, weight: FontWeight.w600, height: 1.4);
  static TextStyle get titleSmall =>
      _base(size: 13, weight: FontWeight.w600, height: 1.4);

  // ─── Body ────────────────────────────────────────────────
  static TextStyle get bodyLarge =>
      _base(size: 16, weight: FontWeight.w400, height: 1.5);
  static TextStyle get bodyMedium =>
      _base(size: 14, weight: FontWeight.w400, height: 1.5);
  static TextStyle get bodySmall =>
      _base(size: 12, weight: FontWeight.w400, height: 1.45);

  // ─── Label ───────────────────────────────────────────────
  static TextStyle get labelLarge => _base(
        size: 14,
        weight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.2,
      );
  static TextStyle get labelMedium => _base(
        size: 12,
        weight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.3,
      );
  static TextStyle get labelSmall => _base(
        size: 11,
        weight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.4,
      );

  // ─── Caption / overline ──────────────────────────────────
  static TextStyle get caption =>
      _base(size: 12, weight: FontWeight.w400, color: AppColors.textMuted);
  static TextStyle get overline => _base(
        size: 10,
        weight: FontWeight.w700,
        color: AppColors.textMuted,
        letterSpacing: 1.2,
      );
}
