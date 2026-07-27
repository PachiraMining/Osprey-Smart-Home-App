import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local (device-only) store of which devices the user has hidden from the
/// Home dashboard, keyed per home. There is no backend "hidden" field — this
/// is purely an app-side presentation preference.
///
/// A [ChangeNotifier] so the Home list and the manage screen rebuild the
/// moment a device is hidden/shown.
class HiddenDeviceStore extends ChangeNotifier {
  HiddenDeviceStore._();
  static final HiddenDeviceStore instance = HiddenDeviceStore._();

  static const _key = 'hidden_devices_v1';

  // homeId -> set of hidden deviceIds.
  Map<String, Set<String>> _byHome = {};
  bool _loaded = false;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        _byHome = map.map((home, ids) => MapEntry(
              home,
              (ids as List).whereType<String>().toSet(),
            ));
      }
    } catch (_) {
      _byHome = {};
    }
    _loaded = true;
    notifyListeners();
  }

  Set<String> hiddenFor(String? homeId) =>
      homeId == null ? const {} : (_byHome[homeId] ?? const {});

  bool isHidden(String? homeId, String deviceId) =>
      homeId != null && (_byHome[homeId]?.contains(deviceId) ?? false);

  Future<void> hide(String homeId, Iterable<String> deviceIds) async {
    (_byHome[homeId] ??= {}).addAll(deviceIds);
    await _persist();
    notifyListeners();
  }

  Future<void> show(String homeId, Iterable<String> deviceIds) async {
    _byHome[homeId]?.removeAll(deviceIds);
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key,
        jsonEncode(_byHome.map((h, ids) => MapEntry(h, ids.toList()))),
      );
    } catch (_) {}
  }
}
