import 'package:flutter/material.dart';

/// Osprey "Open Ocean" brand palette.
///
/// A refined sea-blue system: a vivid ocean primary with a warm sand accent.
/// Tuned to read distinctly from typical bright Material blue (#2196F3) used
/// by smart-home templates.
class AppColors {
  AppColors._();

  // ─── Brand ────────────────────────────────────────────────
  static const Color primary = Color(0xFF0A6CB8);        // vivid ocean
  static const Color primaryDark = Color(0xFF074C82);    // deep ocean
  static const Color primaryLight = Color(0xFF3D90D2);   // cerulean
  static const Color primarySubtle = Color(0xFFE0EEF8);  // sea mist
  static const Color primaryTint = Color(0xFFF1F7FC);    // foam

  static const Color accent = Color(0xFFFFB347);         // warm sand
  static const Color accentDark = Color(0xFFE0922B);     // amber
  static const Color accentSubtle = Color(0xFFFFF3E0);   // cream

  // ─── Neutrals ────────────────────────────────────────────
  static const Color background = Color(0xFFF5F8FB);     // cool off-white
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEEF3F8);   // pale stone
  static const Color surfaceTint = Color(0xFFF9FBFD);

  // ─── Text ────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0F1419);
  static const Color textSecondary = Color(0xFF52606D);
  static const Color textMuted = Color(0xFF7B8794);
  static const Color textDisabled = Color(0xFFB0B8C1);
  static const Color textInverse = Color(0xFFFFFFFF);

  // ─── Borders / dividers ──────────────────────────────────
  static const Color border = Color(0xFFD7E0EA);
  static const Color borderSubtle = Color(0xFFE6ECF2);
  static const Color borderStrong = Color(0xFFB7C5D2);
  static const Color divider = Color(0xFFE6ECF2);

  // ─── Semantic ────────────────────────────────────────────
  static const Color success = Color(0xFF1F8B4C);
  static const Color warning = Color(0xFFE0922B);
  static const Color error = Color(0xFFD64545);
  static const Color info = Color(0xFF0A6CB8);

  // ─── Status (devices) ────────────────────────────────────
  static const Color statusOnline = Color(0xFF1F8B4C);
  static const Color statusOffline = Color(0xFF7B8794);

  // ─── Shadow ──────────────────────────────────────────────
  static Color shadow = const Color(0xFF0A6CB8).withAlpha(26);
  static Color shadowSoft = const Color(0xFF0A6CB8).withAlpha(14);
  static Color shadowFocus = const Color(0xFF0A6CB8).withAlpha(60);
}
