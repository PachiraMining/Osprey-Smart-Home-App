import 'package:flutter/material.dart';

/// Shared visual identity for Tap-to-Run scenes: the 12-color palette used by
/// the create page, plus the stable per-scene fallback so a scene without a
/// stored style keeps the SAME "random" color across reloads.
class SceneStyle {
  SceneStyle._();

  static const palette = [
    Color(0xFFE85D5D), Color(0xFFF5A623), Color(0xFF7ED321),
    Color(0xFF2EAD4B), Color(0xFF1FBCB5), Color(0xFF1B4332),
    Color(0xFF2D7DD2), Color(0xFF5B4FCF), Color(0xFF8B47BF),
    Color(0xFFD14B8F), Color(0xFFC78B6D), Color(0xFF5A7A84),
  ];

  /// Content-based fold hash (no per-run seed) → palette pick that never
  /// changes for a given scene id.
  static Color colorFor(String seed) {
    var h = 0;
    for (final c in seed.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return palette[h % palette.length];
  }

  /// Decode "#RRGGBB|codePoint" → (Color, IconData); falls back to
  /// [colorFor] + a play icon when no style is stored.
  static (Color, IconData) decode(String? iconStr, String seedId) {
    final defaultColor = colorFor(seedId);
    const defaultIcon = Icons.play_arrow_rounded;
    if (iconStr == null || !iconStr.contains('|')) {
      return (defaultColor, defaultIcon);
    }
    try {
      final parts = iconStr.split('|');
      final hex = parts[0].replaceFirst('#', '');
      final color = Color(int.parse('FF$hex', radix: 16));
      final icon = IconData(int.parse(parts[1]), fontFamily: 'MaterialIcons');
      return (color, icon);
    } catch (_) {
      return (defaultColor, defaultIcon);
    }
  }
}
