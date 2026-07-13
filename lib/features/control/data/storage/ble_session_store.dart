import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/ble_session.dart';

/// Lưu material BLE session (key + counter + osprey UUID) per ThingsBoard
/// deviceId vào secure storage.
///
/// **iOS**: bật `synchronizable: true` để counter được iCloud Keychain sync
/// qua thiết bị (backend §3) — wipe app data trên 1 máy nhưng iCloud còn
/// counter mới nhất → chip vẫn accept lệnh kế tiếp, user không phải re-pair.
///
/// **Android**: `flutter_secure_storage` 9.x dùng `EncryptedSharedPreferences`
/// mặc định. Để counter sống qua reinstall, AndroidManifest cần
/// `android:allowBackup="true"` và whitelist mã hoá trong `backup_rules.xml`
/// (gắn vào `android:fullBackupContent` / `android:dataExtractionRules`).
///
/// Counter `nextCounter` atomic qua một Future chain in-memory — flutter_secure_storage
/// không có CAS, nên cache trong RAM + serialize ghi để tránh race khi user spam tap.
class BleSessionStore {
  BleSessionStore(this._storage);

  final FlutterSecureStorage _storage;

  // RAM cache để tránh đọc keychain mỗi command + serialize counter increment.
  final Map<String, BleSession> _cache = {};
  Future<void> _writeChain = Future.value();

  static const _keyPrefix = 'ble_session_key_';
  static const _counterPrefix = 'ble_counter_';
  static const _uuidPrefix = 'osprey_uuid_';
  static const _remoteIdPrefix = 'ble_remoteid_';

  static String _keyKey(String tbDeviceId) => '$_keyPrefix$tbDeviceId';
  static String _counterKey(String tbDeviceId) => '$_counterPrefix$tbDeviceId';
  static String _uuidKey(String tbDeviceId) => '$_uuidPrefix$tbDeviceId';
  static String _remoteIdKey(String tbDeviceId) =>
      '$_remoteIdPrefix$tbDeviceId';

  // iCloud sync + lock to keychain only after first device unlock (per backend §3).
  static const _iosOpts = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
    synchronizable: true,
  );
  static const _androidOpts = AndroidOptions(encryptedSharedPreferences: true);

  /// Lưu session ngay sau pair thành công.
  Future<void> save(String tbDeviceId, BleSession session) async {
    if (tbDeviceId.isEmpty) return;
    if (session.sessionKey.length != 32) {
      throw ArgumentError('sessionKey must be exactly 32 bytes');
    }
    _cache[tbDeviceId] = session;
    await _storage.write(
      key: _keyKey(tbDeviceId),
      value: base64Encode(session.sessionKey),
      iOptions: _iosOpts,
      aOptions: _androidOpts,
    );
    await _storage.write(
      key: _counterKey(tbDeviceId),
      value: session.counter.toString(),
      iOptions: _iosOpts,
      aOptions: _androidOpts,
    );
    await _storage.write(
      key: _uuidKey(tbDeviceId),
      value: session.ospreyUuid,
      iOptions: _iosOpts,
      aOptions: _androidOpts,
    );
    if (session.bleRemoteId != null && session.bleRemoteId!.isNotEmpty) {
      await _storage.write(
        key: _remoteIdKey(tbDeviceId),
        value: session.bleRemoteId!,
        iOptions: _iosOpts,
        aOptions: _androidOpts,
      );
    }
  }

  /// Đọc session, hoặc null nếu device chưa từng pair (hoặc đã `clear`).
  Future<BleSession?> read(String tbDeviceId) async {
    if (tbDeviceId.isEmpty) return null;
    final cached = _cache[tbDeviceId];
    if (cached != null) return cached;

    final keyB64 = await _storage.read(
      key: _keyKey(tbDeviceId),
      iOptions: _iosOpts,
      aOptions: _androidOpts,
    );
    final counterStr = await _storage.read(
      key: _counterKey(tbDeviceId),
      iOptions: _iosOpts,
      aOptions: _androidOpts,
    );
    final uuid = await _storage.read(
      key: _uuidKey(tbDeviceId),
      iOptions: _iosOpts,
      aOptions: _androidOpts,
    );
    if (keyB64 == null || counterStr == null || uuid == null) return null;

    final remoteId = await _storage.read(
      key: _remoteIdKey(tbDeviceId),
      iOptions: _iosOpts,
      aOptions: _androidOpts,
    );

    final session = BleSession(
      sessionKey: Uint8List.fromList(base64Decode(keyB64)),
      ospreyUuid: uuid,
      counter: int.tryParse(counterStr) ?? 0,
      bleRemoteId: remoteId,
    );
    _cache[tbDeviceId] = session;
    return session;
  }

  /// Atomic increment counter + persist. Trả về giá trị mới (nguyên dương).
  ///
  /// Throw [StateError] nếu chưa có session lưu cho device — caller phải
  /// `save()` trước (sau pair).
  Future<int> nextCounter(String tbDeviceId) async {
    final completer = Completer<int>();
    _writeChain = _writeChain.then((_) async {
      try {
        final session = await read(tbDeviceId);
        if (session == null) {
          throw StateError('No BLE session for device $tbDeviceId');
        }
        final next = session.counter + 1;
        final updated = session.copyWith(counter: next);
        _cache[tbDeviceId] = updated;
        await _storage.write(
          key: _counterKey(tbDeviceId),
          value: next.toString(),
          iOptions: _iosOpts,
          aOptions: _androidOpts,
        );
        completer.complete(next);
      } catch (e, st) {
        completer.completeError(e, st);
      }
    });
    return completer.future;
  }

  /// Xoá session — dùng khi re-pair sau notify 0x01/0x02 hoặc factory reset.
  Future<void> clear(String tbDeviceId) async {
    if (tbDeviceId.isEmpty) return;
    _cache.remove(tbDeviceId);
    await _storage.delete(
      key: _keyKey(tbDeviceId),
      iOptions: _iosOpts,
      aOptions: _androidOpts,
    );
    await _storage.delete(
      key: _counterKey(tbDeviceId),
      iOptions: _iosOpts,
      aOptions: _androidOpts,
    );
    await _storage.delete(
      key: _uuidKey(tbDeviceId),
      iOptions: _iosOpts,
      aOptions: _androidOpts,
    );
    await _storage.delete(
      key: _remoteIdKey(tbDeviceId),
      iOptions: _iosOpts,
      aOptions: _androidOpts,
    );
  }
}
