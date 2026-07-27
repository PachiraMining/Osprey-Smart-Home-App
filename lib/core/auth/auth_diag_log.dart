import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persistent, timestamped ring buffer of auth-critical events.
///
/// The old `print('🔑[AUTH-DIAG] …')` lines only reach logcat, which rotates
/// within hours — useless for the "logged out the next day" bug where the
/// evidence must survive a 24h+ gap, an app restart AND the logout itself.
///
/// This log is written to SharedPreferences, is NOT cleared on logout, and is
/// viewable in-app (Settings → Auth Diagnostics) after the user logs back in.
/// So the exact event that ended the session — with wall-clock time and reason
/// — is still there to read.
class AuthDiagLog {
  AuthDiagLog._();
  static final AuthDiagLog instance = AuthDiagLog._();

  static const _key = 'auth_diag_v1';
  static const _cap = 200;

  /// Append one event. Best-effort — never throws into the auth path.
  Future<void> add(String tag, [String? detail]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_key) ?? <String>[];
      final entry = jsonEncode({
        't': DateTime.now().toIso8601String(),
        'tag': tag,
        if (detail != null && detail.isNotEmpty) 'd': detail,
      });
      list.add(entry);
      if (list.length > _cap) {
        list.removeRange(0, list.length - _cap);
      }
      await prefs.setStringList(_key, list);
    } catch (_) {
      // Diagnostics must never break authentication.
    }
  }

  /// Newest-first decoded entries for the viewer.
  Future<List<AuthDiagEntry>> entries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_key) ?? <String>[];
      final out = <AuthDiagEntry>[];
      for (final raw in list) {
        try {
          final m = jsonDecode(raw) as Map<String, dynamic>;
          out.add(AuthDiagEntry(
            time: DateTime.tryParse(m['t'] as String? ?? '') ?? DateTime(0),
            tag: m['tag'] as String? ?? '?',
            detail: m['d'] as String?,
          ));
        } catch (_) {}
      }
      return out.reversed.toList();
    } catch (_) {
      return const [];
    }
  }

  /// Plain-text dump for copy/share.
  Future<String> asText() async {
    final e = await entries();
    return e
        .map((x) => '${x.time.toIso8601String()}  ${x.tag}'
            '${x.detail != null ? '  ${x.detail}' : ''}')
        .join('\n');
  }

  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (_) {}
  }
}

class AuthDiagEntry {
  final DateTime time;
  final String tag;
  final String? detail;

  const AuthDiagEntry({required this.time, required this.tag, this.detail});
}
