import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Kinds of in-app events surfaced in the Message Center.
enum AppMessageType { deviceOffline, scene, system }

/// One entry in the Message Center (Tuya-style alarm/notification feed).
class AppMessage {
  final String id;
  final AppMessageType type;
  final String title;
  final String body;
  final String? homeName;
  final DateTime time;
  final bool read;

  const AppMessage({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    this.homeName,
    this.read = false,
  });

  AppMessage copyWith({bool? read}) => AppMessage(
        id: id,
        type: type,
        title: title,
        body: body,
        homeName: homeName,
        time: time,
        read: read ?? this.read,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'body': body,
        if (homeName != null) 'homeName': homeName,
        'time': time.millisecondsSinceEpoch,
        'read': read,
      };

  static AppMessage? fromJson(Map<String, dynamic> json) {
    try {
      return AppMessage(
        id: json['id'] as String,
        type: AppMessageType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => AppMessageType.system,
        ),
        title: json['title'] as String,
        body: json['body'] as String,
        homeName: json['homeName'] as String?,
        time: DateTime.fromMillisecondsSinceEpoch(json['time'] as int),
        read: json['read'] as bool? ?? false,
      );
    } catch (_) {
      return null;
    }
  }
}

/// Device status sample used to detect online → offline transitions.
class MessageDeviceStatus {
  final String id;
  final String name;
  final bool online;

  const MessageDeviceStatus({
    required this.id,
    required this.name,
    required this.online,
  });
}

/// Local in-app event feed backing the Message Center screen.
///
/// Events are logged by the blocs (device offline transitions, scene runs
/// failing, automations created/deleted, ...) and persisted locally so the
/// feed survives restarts. No backend involved.
class MessageCenter extends ChangeNotifier {
  static const _prefsKey = 'message_center_v1';
  static const _cap = 200;
  static const _offlineDedupe = Duration(minutes: 30);

  List<AppMessage> _messages = [];
  bool _loaded = false;

  /// Last seen online flag per deviceId (session-scoped).
  final Map<String, bool> _lastOnline = {};

  /// Last time an offline event was logged per deviceId (spam guard).
  final Map<String, DateTime> _lastOfflineLog = {};

  List<AppMessage> get messages => List.unmodifiable(_messages);

  int get unreadCount => _messages.where((m) => !m.read).length;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null) {
        final list = jsonDecode(raw) as List<dynamic>;
        _messages = list
            .whereType<Map<String, dynamic>>()
            .map(AppMessage.fromJson)
            .whereType<AppMessage>()
            .toList();
        notifyListeners();
      }
    } catch (_) {
      _messages = [];
    }
  }

  Future<void> log({
    required AppMessageType type,
    required String title,
    required String body,
    String? homeName,
  }) async {
    await ensureLoaded();
    final now = DateTime.now();
    _messages.insert(
      0,
      AppMessage(
        id: '${now.microsecondsSinceEpoch}',
        type: type,
        title: title,
        body: body,
        homeName: homeName,
        time: now,
      ),
    );
    if (_messages.length > _cap) {
      _messages = _messages.sublist(0, _cap);
    }
    await _persist();
    notifyListeners();
  }

  /// Feed a fresh device-list snapshot; logs an event for every device that is
  /// offline now and wasn't known-offline before (max one per device per
  /// [_offlineDedupe]).
  Future<void> recordDeviceSnapshot(
    String? homeName,
    List<MessageDeviceStatus> devices,
  ) async {
    for (final d in devices) {
      final prev = _lastOnline[d.id];
      _lastOnline[d.id] = d.online;
      if (d.online || prev == false) continue; // online, or already offline
      final last = _lastOfflineLog[d.id];
      final now = DateTime.now();
      if (last != null && now.difference(last) < _offlineDedupe) continue;
      _lastOfflineLog[d.id] = now;
      await log(
        type: AppMessageType.deviceOffline,
        title: 'Device Offline Notification',
        body: homeName != null && homeName.isNotEmpty
            ? '${d.name} of "$homeName" is offline. Please pay attention.'
            : '${d.name} is offline. Please pay attention.',
        homeName: homeName,
      );
    }
  }

  Future<void> markAllRead() async {
    if (_messages.every((m) => m.read)) return;
    _messages = [for (final m in _messages) m.copyWith(read: true)];
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefsKey,
        jsonEncode([for (final m in _messages) m.toJson()]),
      );
    } catch (_) {
      // Persistence is best-effort; the in-memory feed still works.
    }
  }
}
