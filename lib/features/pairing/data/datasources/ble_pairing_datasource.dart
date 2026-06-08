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
  Future<void> startScan() async {
    if (FlutterBluePlus.isScanningNow) return;
    await FlutterBluePlus.startScan(
      withServices: [Guid(PairingConstants.brandServiceUuid)],
      timeout: PairingConstants.scanTimeout,
      androidUsesFineLocation: true,
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
      throw BlePairingException('Không kết nối được thiết bị: $e');
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
        throw BlePairingException('Không negotiate được MTU 247: $e');
      }
    }
    log('[BLE-PAIR] MTU sau negotiate: ${device.mtuNow}',
        name: 'BlePairing');

    // Discover GATT Pairing Service + 3 characteristics
    final List<BluetoothService> services;
    try {
      services = await device.discoverServices();
    } catch (e) {
      await closeSession();
      throw BlePairingException('Không discover được GATT services: $e');
    }

    final pairingService = _firstWhereOrNull(
      services,
      (s) => s.uuid == Guid(PairingConstants.pairingServiceUuid),
    );
    if (pairingService == null) {
      await closeSession();
      throw BlePairingException(
          'Thiết bị không có Pairing Service — không phải thiết bị Osprey '
          'hoặc firmware chưa đúng');
    }

    _authChar = _findChar(pairingService, PairingConstants.authChallengeCharUuid);
    _dataChar = _findChar(pairingService, PairingConstants.pairingDataCharUuid);
    _statusChar = _findChar(pairingService, PairingConstants.statusNotifyCharUuid);
    // DEVICE_UUID char optional — firmware cũ chưa có (...380)
    _deviceUuidChar =
        _findChar(pairingService, PairingConstants.deviceUuidCharUuid);
    if (_authChar == null || _dataChar == null || _statusChar == null) {
      await closeSession();
      throw BlePairingException('Thiếu characteristic trong Pairing Service');
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
      throw BlePairingException('Không subscribe được STATUS_NOTIFY: $e');
    }
  }

  static final RegExp _uuidPattern = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}'
      r'-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');

  @override
  Future<String> readDeviceUuid() async {
    if (_device == null) {
      throw BlePairingException('Chưa mở BLE session');
    }
    final char = _deviceUuidChar;
    if (char == null) {
      // Vendor yêu cầu hard-error thay vì fallback ngầm: khi backend ship
      // per-device PSK (Phase 2), UUID sai sẽ fail rất khó debug.
      throw BlePairingException(
          'Firmware thiết bị quá cũ — thiếu characteristic DEVICE_UUID '
          '(cần firmware build từ 2026-06-05)');
    }
    final List<int> bytes;
    try {
      bytes = await char.read();
    } catch (e) {
      throw BlePairingException('READ DEVICE_UUID thất bại: $e');
    }
    // Strip null bytes phòng firmware null-terminate, rồi validate format
    final uuid = String.fromCharCodes(bytes.where((b) => b != 0))
        .trim()
        .toLowerCase();
    if (!_uuidPattern.hasMatch(uuid)) {
      // Char tồn tại nhưng value sai format → lỗi firmware, phải surface
      throw BlePairingException(
          'DEVICE_UUID không hợp lệ từ thiết bị: "$uuid" '
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
      throw BlePairingException('Chưa mở BLE session');
    }
    if (payload.length != PairingConstants.authChallengeLength) {
      throw BlePairingException(
          'AUTH_CHALLENGE phải đúng 48 bytes (hiện ${payload.length})');
    }
    try {
      await authChar.write(payload);
    } catch (e) {
      throw BlePairingException('Write AUTH_CHALLENGE thất bại: $e');
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
      throw BlePairingException('Chưa mở BLE session');
    }
    // Sanity check MTU: payload phải nằm gọn trong 1 ATT write
    // (firmware chưa support long-write).
    final mtu = device.mtuNow;
    if (ciphertext.length > mtu - 3) {
      throw BlePairingException(
          'PAIRING_DATA ${ciphertext.length} B vượt quá MTU $mtu — '
          'thiết bị không hỗ trợ MTU 247');
    }
    try {
      await dataChar.write(ciphertext, allowLongWrite: false);
    } catch (e) {
      throw BlePairingException('Write PAIRING_DATA thất bại: $e');
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
        log('[BLE-PAIR] disconnect error (bỏ qua): $e', name: 'BlePairing');
      }
    }
  }

  Future<int> _awaitStatus() async {
    final controller = _statusController;
    if (controller == null) {
      throw BlePairingException('Chưa subscribe STATUS_NOTIFY');
    }
    try {
      return await controller.stream.first
          .timeout(PairingConstants.statusNotifyTimeout);
    } on TimeoutException {
      throw BlePairingException(
          'Thiết bị không phản hồi sau '
          '${PairingConstants.statusNotifyTimeout.inSeconds}s');
    }
  }

  static String _describeStatus(int status) => switch (status) {
        PairingConstants.statusAuthFail =>
          'Xác thực thiết bị thất bại (HMAC mismatch) — thiết bị có thể '
              'không phải hàng chính hãng',
        PairingConstants.statusDecryptError =>
          'Thiết bị không giải mã được dữ liệu (DECRYPT_ERROR)',
        PairingConstants.statusJsonParseError =>
          'Dữ liệu pairing không hợp lệ (JSON_PARSE_ERROR)',
        PairingConstants.statusBadInput =>
          'Payload sai độ dài (BAD_INPUT)',
        PairingConstants.statusInternalError =>
          'Thiết bị gặp lỗi nội bộ (INTERNAL_ERROR)',
        _ => 'Thiết bị trả về mã lỗi không xác định: '
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
