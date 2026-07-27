import 'package:flutter/material.dart';

/// Letter avatar derived from the user's email (Gmail/Tuya style): the first
/// letter of the email's local part on a circle whose color is a stable hash
/// of the email — so the same account always gets the same avatar, no image
/// asset needed.
class EmailAvatar extends StatelessWidget {
  final String? email;

  /// Fallback used only when [email] is empty (e.g. a display name).
  final String? fallback;
  final double size;

  const EmailAvatar({
    super.key,
    required this.email,
    this.fallback,
    this.size = 60,
  });

  /// Muted, high-contrast palette (white letter sits well on all of them).
  static const _palette = [
    Color(0xFF5B8DEF), Color(0xFF2FB4A6), Color(0xFF7D6BE0),
    Color(0xFFE07A5F), Color(0xFFEBA13B), Color(0xFF3AA76D),
    Color(0xFFD1568C), Color(0xFF4C6EF5), Color(0xFF6C8A3B),
    Color(0xFF5A7A84), Color(0xFFCF6679), Color(0xFF2D8FB0),
  ];

  String get _seed {
    final e = email?.trim() ?? '';
    if (e.isNotEmpty) return e.toLowerCase();
    return (fallback ?? 'user').toLowerCase();
  }

  String get _letter {
    final source = (email != null && email!.contains('@'))
        ? email!.split('@').first
        : (email?.isNotEmpty == true ? email! : (fallback ?? 'U'));
    final trimmed = source.trim();
    return trimmed.isEmpty ? 'U' : trimmed[0].toUpperCase();
  }

  Color get _color {
    var h = 0;
    for (final c in _seed.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return _palette[h % _palette.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
      child: Text(
        _letter,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.42,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
