import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../pairing_constants.dart';

/// Lỗi tầng BLE trong pairing flow, message hiển thị được cho user.
class BlePairingException implements Exception {
  final String message;

  /// Status byte từ STATUS_NOTIFY (nếu lỗi do device báo về).
  final int? statusCode;

  BlePairingException(this.message, {this.statusCode});

  @override
  String toString() => 'BlePairingException: $message';
}

/// Tầng BLE cho pairing: scan filter Brand UUID + GATT session.
///
/// Thứ tự BẮT BUỘC trong session (HANDOFF_APP_TEAM.md + update Option 2):
/// 1. connect → requestMtu(517) (Android; iOS tự negotiate)
/// 2. discover services
/// 3. subscribe STATUS_NOTIFY (CCCD) **TRƯỚC** khi write AUTH_CHALLENGE
/// 4. READ DEVICE_UUID (...380) → **disarm firmware watchdog 30s**
/// 5. (backend calls — tự do thời gian sau khi disarm)
/// 6. write AUTH_CHALLENGE → chờ notify AUTH_OK
/// 7. write PAIRING_DATA (encrypted) → chờ notify DATA_OK
/// 8. disconnect
abstract class BlePairingDataSource {
  /// Scan results đã filter theo Brand Service UUID (Active Scan để nhận
  /// scan response chứa local name "Osprey-CR-XXXX").
  Stream<List<ScanResult>> get scanResults;

  /// Trạng thái Bluetooth adapter (on/off/unknown...) — FBP replay giá trị
  /// hiện tại cho listener mới.
  Stream<BluetoothAdapterState> get adapterStates;

  /// Scan đang chạy? — FBP tự dừng khi hết scanTimeout, stream này là cách
  /// duy nhất để UI biết điều đó.
  Stream<bool> get scanningStates;

  Future<void> startScan();
  Future<void> stopScan();

  /// Connect + MTU + discover + subscribe STATUS_NOTIFY.
  Future<void> openSession(String remoteId);

  /// READ characteristic DEVICE_UUID (...380) — trả về UUID string 36 ký tự.
  ///
  /// Gọi NGAY sau [openSession]: READ này disarm firmware watchdog 30s,
  /// sau đó app gọi backend bao lâu cũng được.
  ///
  /// Throw [BlePairingException] nếu firmware cũ chưa có characteristic
  /// (cần build ≥ 2026-06-05) hoặc value không đúng format UUID.
  Future<String> readDeviceUuid();

  /// WRITE 48 bytes vào AUTH_CHALLENGE, chờ notify. Throw nếu != AUTH_OK.
  Future<void> writeAuthChallengeAndAwaitOk(Uint8List payload);

  /// WRITE ciphertext vào PAIRING_DATA, chờ notify. Throw nếu != DATA_OK.
  Future<void> writePairingDataAndAwaitOk(Uint8List ciphertext);

  /// Disconnect và giải phóng session (an toàn gọi nhiều lần).
  Future<void> closeSession();
}

class BlePairingDataSourceImpl implements BlePairingDataSource {
  BluetoothDevice? _device;
  BluetoothCharacteristic? _authChar;
  BluetoothCharacteristic? _dataChar;
  BluetoothCharacteristic? _statusChar;
  BluetoothCharacteristic? _deviceUuidChar;
  StreamSubscription<List<int>>? _statusSub;
  StreamController<int>? _statusController;

  @override
  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;

  @override
  Stream<BluetoothAdapterState> get adapterStates =>
      FlutterBluePlus.adapterState;

  @override
  Stream<bool> get scanningStates => FlutterBluePlus.isScanning;

  @override
  Future<void> startScan() async {
    if (FlutterBluePlus.isScanningNow) return;
    await FlutterBluePlus.startScan(
      withServices: [Guid(PairingConstants.brandServiceUuid)],
      timeout: PairingConstants.scanTimeout,
      androidUsesFineLocation: true,
      // BẮT BUỘC cho bộ lọc stale: mặc định FBP chỉ ghi timeStamp lần đầu
      // thấy device — không bật thì device đang phát sóng vẫn bị coi là
      // stale sau scanStaleAfter. removeIfGone để FBP tự loại entry chết.
      continuousUpdates: true,
      removeIfGone: PairingConstants.scanStaleAfter,
    );
  }

  @override
  Future<void> stopScan() async {
    if (FlutterBluePlus.isScanningNow) {
      await FlutterBluePlus.stopScan();
    }
  }

  @override
  Future<void> openSession(String remoteId) async {
    await closeSession();
    await stopScan();

    final device = BluetoothDevice.fromId(remoteId);
    try {
      await device.connect(timeout: PairingConstants.connectTimeout);
    } catch (e) {
      throw BlePairingException('Could not connect to device: $e');
    }
    _device = device;

    // MTU 247 BẮT BUỘC trước khi write PAIRING_DATA (~317 B encrypted,
    // default MTU 23 sẽ force long-write mà firmware chưa support).
    // requestMtu chỉ có trên Android; iOS tự negotiate trong lúc connect.
    if (Platform.isAndroid) {
      try {
        await device.requestMtu(PairingConstants.requiredMtu);
      } catch (e) {
        await closeSession();
        throw BlePairingException('Could not negotiate MTU 247: $e');
      }
    }
    log('[BLE-PAIR] MTU after negotiation: ${device.mtuNow}',
        name: 'BlePairing');

    // Discover GATT Pairing Service + 3 characteristics
    final List<BluetoothService> services;
    try {
      services = await device.discoverServices();
    } catch (e) {
      await closeSession();
      throw BlePairingException('Could not discover GATT services: $e');
    }

    final pairingService = _firstWhereOrNull(
      services,
      (s) => s.uuid == Guid(PairingConstants.pairingServiceUuid),
    );
    if (pairingService == null) {
      await closeSession();
      throw BlePairingException(
          'Device has no Pairing Service — not an Osprey device '
          'or incorrect firmware');
    }

    _authChar = _findChar(pairingService, PairingConstants.authChallengeCharUuid);
    _dataChar = _findChar(pairingService, PairingConstants.pairingDataCharUuid);
    _statusChar = _findChar(pairingService, PairingConstants.statusNotifyCharUuid);
    // DEVICE_UUID char optional — firmware cũ chưa có (...380)
    _deviceUuidChar =
        _findChar(pairingService, PairingConstants.deviceUuidCharUuid);
    if (_authChar == null || _dataChar == null || _statusChar == null) {
      await closeSession();
      throw BlePairingException('Missing characteristic in Pairing Service');
    }

    // Subscribe CCCD TRƯỚC khi write AUTH_CHALLENGE — nếu sai thứ tự
    // app sẽ miss notification AUTH_OK → timeout.
    _statusController = StreamController<int>.broadcast();
    _statusSub = _statusChar!.onValueReceived.listen((value) {
      if (value.isNotEmpty) {
        log('[BLE-PAIR] STATUS_NOTIFY: 0x${value[0].toRadixString(16)}',
            name: 'BlePairing');
        _statusController?.add(value[0]);
      }
    });
    try {
      await _statusChar!.setNotifyValue(true);
    } catch (e) {
      await closeSession();
      throw BlePairingException('Could not subscribe to STATUS_NOTIFY: $e');
    }
  }

  static final RegExp _uuidPattern = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}'
      r'-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');

  @override
  Future<String> readDeviceUuid() async {
    if (_device == null) {
      throw BlePairingException('BLE session not opened');
    }
    final char = _deviceUuidChar;
    if (char == null) {
      // Vendor yêu cầu hard-error thay vì fallback ngầm: khi backend ship
      // per-device PSK (Phase 2), UUID sai sẽ fail rất khó debug.
      throw BlePairingException(
          'Device firmware is too old — missing DEVICE_UUID characteristic '
          '(requires firmware build from 2026-06-05)');
    }
    final List<int> bytes;
    try {
      bytes = await char.read();
    } catch (e) {
      throw BlePairingException('READ DEVICE_UUID failed: $e');
    }
    // Strip null bytes phòng firmware null-terminate, rồi validate format
    final uuid = String.fromCharCodes(bytes.where((b) => b != 0))
        .trim()
        .toLowerCase();
    if (!_uuidPattern.hasMatch(uuid)) {
      // Char tồn tại nhưng value sai format → lỗi firmware, phải surface
      throw BlePairingException(
          'Invalid DEVICE_UUID from device: "$uuid" '
          '(${bytes.length} bytes)');
    }
    log('[BLE-PAIR] DEVICE_UUID: $uuid (watchdog disarmed)',
        name: 'BlePairing');
    return uuid;
  }

  @override
  Future<void> writeAuthChallengeAndAwaitOk(Uint8List payload) async {
    final authChar = _authChar;
    if (authChar == null) {
      throw BlePairingException('BLE session not opened');
    }
    if (payload.length != PairingConstants.authChallengeLength) {
      throw BlePairingException(
          'AUTH_CHALLENGE must be exactly 48 bytes (got ${payload.length})');
    }
    try {
      await authChar.write(payload);
    } catch (e) {
      throw BlePairingException('Write AUTH_CHALLENGE failed: $e');
    }
    final status = await _awaitStatus();
    if (status != PairingConstants.statusAuthOk) {
      throw BlePairingException(
        _describeStatus(status),
        statusCode: status,
      );
    }
  }

  @override
  Future<void> writePairingDataAndAwaitOk(Uint8List ciphertext) async {
    final dataChar = _dataChar;
    final device = _device;
    if (dataChar == null || device == null) {
      throw BlePairingException('BLE session not opened');
    }
    // Sanity check MTU: payload phải nằm gọn trong 1 ATT write
    // (firmware chưa support long-write).
    final mtu = device.mtuNow;
    if (ciphertext.length > mtu - 3) {
      throw BlePairingException(
          'PAIRING_DATA ${ciphertext.length} B exceeds MTU $mtu — '
          'device does not support MTU 247');
    }
    try {
      await dataChar.write(ciphertext, allowLongWrite: false);
    } catch (e) {
      throw BlePairingException('Write PAIRING_DATA failed: $e');
    }
    final status = await _awaitStatus();
    if (status != PairingConstants.statusDataOk) {
      throw BlePairingException(
        _describeStatus(status),
        statusCode: status,
      );
    }
  }

  @override
  Future<void> closeSession() async {
    await _statusSub?.cancel();
    _statusSub = null;
    await _statusController?.close();
    _statusController = null;
    _authChar = null;
    _dataChar = null;
    _statusChar = null;
    _deviceUuidChar = null;
    final device = _device;
    _device = null;
    if (device != null) {
      try {
        await device.disconnect();
      } catch (e) {
        log('[BLE-PAIR] disconnect error (ignored): $e', name: 'BlePairing');
      }
    }
  }

  Future<int> _awaitStatus() async {
    final controller = _statusController;
    if (controller == null) {
      throw BlePairingException('STATUS_NOTIFY not subscribed');
    }
    try {
      return await controller.stream.first
          .timeout(PairingConstants.statusNotifyTimeout);
    } on TimeoutException {
      throw BlePairingException(
          'Device did not respond after '
          '${PairingConstants.statusNotifyTimeout.inSeconds}s');
    }
  }

  static String _describeStatus(int status) => switch (status) {
        PairingConstants.statusAuthFail =>
          'Device authentication failed (HMAC mismatch) — the device may '
              'not be genuine',
        PairingConstants.statusDecryptError =>
          'Device could not decrypt the data (DECRYPT_ERROR)',
        PairingConstants.statusJsonParseError =>
          'Invalid pairing data (JSON_PARSE_ERROR)',
        PairingConstants.statusBadInput =>
          'Payload has wrong length (BAD_INPUT)',
        PairingConstants.statusInternalError =>
          'Device encountered an internal error (INTERNAL_ERROR)',
        _ => 'Device returned an unknown error code: '
            '0x${status.toRadixString(16)}',
      };

  static BluetoothCharacteristic? _findChar(
    BluetoothService service,
    String uuid,
  ) =>
      _firstWhereOrNull(service.characteristics, (c) => c.uuid == Guid(uuid));

  static T? _firstWhereOrNull<T>(List<T> items, bool Function(T) test) {
    for (final item in items) {
      if (test(item)) return item;
    }
    return null;
  }
}
