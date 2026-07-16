import 'package:flutter_timezone/flutter_timezone.dart';

/// Reads the device's IANA timezone id (e.g. `Asia/Ho_Chi_Minh`) so a Home can
/// be stamped with the local zone the scheduler should fire scenes in.
///
/// Always an IANA id — never a numeric offset like `+7`, which the backend
/// (`ZoneId.of()`) can't parse safely across DST.
class DeviceTimezone {
  const DeviceTimezone();

  /// The device's current IANA timezone id, or `null` when the platform can't
  /// report one. Callers should leave `home.timezone` unset on null (the backend
  /// falls back to UTC) rather than stamping a sentinel — a stored `'UTC'` would
  /// be indistinguishable from a real zone and would block a later retry once
  /// detection works.
  Future<String?> current() async {
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      final id = info.identifier.trim();
      return id.isEmpty ? null : id;
    } catch (_) {
      return null;
    }
  }

  /// Every IANA timezone id the platform knows about, sorted, for a picker.
  /// Empty on failure so callers can fall back gracefully.
  Future<List<String>> available() async {
    try {
      final list = await FlutterTimezone.getAvailableTimezones();
      final ids = list
          .map((t) => t.identifier)
          // Keep real Region/City IANA ids (+ UTC); drop deprecated 3-letter
          // Java aliases (ACT, AET, PST, …) the platform also reports.
          .where((id) => id.contains('/') || id == 'UTC')
          .toList()
        ..sort();
      return ids;
    } catch (_) {
      return const <String>[];
    }
  }
}
