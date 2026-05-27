import 'package:flutter/material.dart';

/// Osprey Life "Liquid Ocean" brand palette — iOS 26 Liquid Glass ready.
///
/// Deep ocean blues with high translucency. Designed to work with
/// `BackdropFilter` glass surfaces (semi-transparent containers over
/// a frosted gradient background).
class AppColors {
  AppColors._();

  // ─── Brand ────────────────────────────────────────────────
  static const Color primary = Color(0xFF0B5FA8);        // deep ocean
  static const Color primaryDark = Color(0xFF073E70);    // abyss
  static const Color primaryLight = Color(0xFF4D9BD6);   // azure
  static const Color primarySubtle = Color(0xFFDCEBF7);  // sea spray
  static const Color primaryTint = Color(0xFFF0F7FC);    // ice

  static const Color accent = Color(0xFF00B4D8);         // tropic cyan
  static const Color accentDark = Color(0xFF0096B5);     // deep cyan
  static const Color accentSubtle = Color(0xFFE0F7FC);   // pale aqua

  // ─── Neutrals (cool, glass-friendly) ─────────────────────
  static const Color background = Color(0xFFF2F7FC);     // cool mist
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFE8EFF5);   // pale stone
  static const Color surfaceTint = Color(0xFFF8FBFD);

  // Translucent glass surfaces (use with BackdropFilter)
  static Color glassFill = const Color(0xFFFFFFFF).withAlpha(140);   // ~55% opacity
  static Color glassFillStrong = const Color(0xFFFFFFFF).withAlpha(180); // ~70%
  static Color glassFillSubtle = const Color(0xFFFFFFFF).withAlpha(90);  // ~35%
  static Color glassTint = const Color(0xFF0B5FA8).withAlpha(20);
  static Color glassBorder = const Color(0xFFFFFFFF).withAlpha(160);

  // ─── Text ────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0A1929);    // ink
  static const Color textSecondary = Color(0xFF3D5470);  // slate
  static const Color textMuted = Color(0xFF6B8299);      // dust
  static const Color textDisabled = Color(0xFFA8B8CA);
  static const Color textInverse = Color(0xFFFFFFFF);

  // ─── Borders / dividers ──────────────────────────────────
  static const Color border = Color(0xFFCFDDEA);
  static const Color borderSubtle = Color(0xFFE2EAF2);
  static const Color borderStrong = Color(0xFFA9BDD0);
  static const Color divider = Color(0xFFE2EAF2);

  // ─── Semantic ────────────────────────────────────────────
  static const Color success = Color(0xFF2E8B57);
  static const Color warning = Color(0xFFE0922B);
  static const Color error = Color(0xFFD64545);
  static const Color info = Color(0xFF0B5FA8);

  // ─── Status (devices) ────────────────────────────────────
  static const Color statusOnline = Color(0xFF2E8B57);
  static const Color statusOffline = Color(0xFF6B8299);

  // ─── Shadow (deeper blue for ocean theme) ────────────────
  static Color shadow = const Color(0xFF073E70).withAlpha(26);
  static Color shadowSoft = const Color(0xFF073E70).withAlpha(14);
  static Color shadowFocus = const Color(0xFF0B5FA8).withAlpha(60);
}
