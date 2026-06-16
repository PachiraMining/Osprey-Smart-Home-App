import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../../pairing/pairing_constants.dart';
import '../../domain/entities/ble_control_result.dart';
import 'ble_control_constants.dart';

/// Tầng BLE cho fallback control (spec §5).
///
/// **Vai trò**: scan tìm chip đã pair, WRITE encrypted frame vào
/// `BLE_CONTROL_CMD`, await NOTIFY byte → map kết quả.
///
/// **Không xử lý**: crypto (xem `BleControlCrypto`), session storage
/// (xem `BleSessionStore`), routing (xem `TransportRouter`).
abstract class BleControlDataSource {
  /// True nếu chip với [bleRemoteId] đang advertise trong [timeout].
  ///
  /// Dùng để quyết định fallback có khả thi không trước khi switch transport.
  /// Không connect.
  Future<bool> isInRange(
    String bleRemoteId, {
    Duration timeout = BleControlConstants.inRangeScanTimeout,
  });

  /// Mở session (connect + MTU + discover + subscribe NOTIFY).
  ///
  /// Idempotent: gọi lại trên cùng `bleRemoteId` khi đã open thì no-op.
  Future<BleControlResult> openSession(String bleRemoteId);

  /// WRITE [encryptedFrame] vào BLE_CONTROL_CMD, chờ NOTIFY byte → kết quả.
  ///
  /// Phải gọi `openSession` trước. Trả về [BleControlResult] map từ notify
  /// byte; hoặc `transportTimeout` nếu không nhận được notify trong
  /// [BleControlConstants.notifyTimeout].
  Future<BleControlResult> sendCommand(Uint8List encryptedFrame);

  /// Disconnect (idle hoặc khi cloud back). An toàn gọi nhiều lần.
  Future<void> closeSession();
}

class BleControlDataSourceImpl implements BleControlDataSource {
  BluetoothDevice? _device;
  BluetoothCharacteristic? _cmdChar;
  StreamSubscription<List<int>>? _notifySub;
  StreamController<int>? _notifyController;
  Timer? _idleTimer;

  @override
  Future<bool> isInRange(
    String bleRemoteId, {
    Duration timeout = BleControlConstants.inRangeScanTimeout,
  }) async {
    if (FlutterBluePlus.isScanningNow) {
      await FlutterBluePlus.stopScan();
    }
    final completer = Completer<bool>();
    late final StreamSubscription<List<ScanResult>> sub;
    sub = FlutterBluePlus.scanResults.listen((results) {
      for (final r in results) {
        if (r.device.remoteId.str.toLowerCase() ==
            bleRemoteId.toLowerCase()) {
          if (!completer.isCompleted) completer.complete(true);
          return;
        }
      }
    });
    try {
      await FlutterBluePlus.startScan(
        withServices: [Guid(PairingConstants.brandServiceUuid)],
        timeout: timeout,
        androidUsesFineLocation: true,
      );
      // Chờ tới khi found hoặc timeout
      return await completer.future.timeout(timeout, onTimeout: () => false);
    } catch (e) {
      log('[BLE-CTRL] isInRange error: $e', name: 'BleControl');
      return false;
    } finally {
      await sub.cancel();
      if (FlutterBluePlus.isScanningNow) {
        await FlutterBluePlus.stopScan();
      }
    }
  }

  @override
  Future<BleControlResult> openSession(String bleRemoteId) async {
    // Đã open cho cùng device → no-op
    if (_device?.remoteId.str == bleRemoteId && _cmdChar != null) {
      _resetIdleTimer();
      return BleControlResult.ok;
    }
    await closeSession();

    final device = BluetoothDevice.fromId(bleRemoteId);
    try {
      await device.connect(timeout: PairingConstants.connectTimeout);
    } catch (e) {
      log('[BLE-CTRL] connect fail: $e', name: 'BleControl');
      // Chip đang busy với phone khác (§9 case 1) hoặc out of range
      return BleControlResult.transportTimeout;
    }
    _device = device;

    if (Platform.isAndroid) {
      try {
        await device.requestMtu(PairingConstants.requiredMtu);
      } catch (_) {
        // Frame BLE control ≤ 64 B nên không cần MTU 517; bỏ qua nếu fail
      }
    }

    final List<BluetoothService> services;
    try {
      services = await device.discoverServices();
    } catch (e) {
      log('[BLE-CTRL] discover fail: $e', name: 'BleControl');
      await closeSession();
      return BleControlResult.transportTimeout;
    }

    final svc = _firstWhereOrNull(
      services,
      (s) => s.uuid == Guid(PairingConstants.pairingServiceUuid),
    );
    if (svc == null) {
      await closeSession();
      return BleControlResult.transportTimeout;
    }

    _cmdChar = _firstWhereOrNull(
      svc.characteristics,
      (c) => c.uuid == Guid(BleControlConstants.bleControlCmdCharUuid),
    );
    if (_cmdChar == null) {
      log('[BLE-CTRL] BLE_CONTROL_CMD char not found — firmware too old?',
          name: 'BleControl');
      await closeSession();
      return BleControlResult.transportTimeout;
    }

    // Subscribe NOTIFY TRƯỚC khi write
    _notifyController = StreamController<int>.broadcast();
    _notifySub = _cmdChar!.onValueReceived.listen((value) {
      if (value.isNotEmpty) {
        log('[BLE-CTRL] NOTIFY: 0x${value[0].toRadixString(16)}',
            name: 'BleControl');
        _notifyController?.add(value[0]);
      }
    });
    try {
      await _cmdChar!.setNotifyValue(true);
    } catch (e) {
      log('[BLE-CTRL] CCCD subscribe fail: $e', name: 'BleControl');
      await closeSession();
      return BleControlResult.transportTimeout;
    }
    _resetIdleTimer();
    return BleControlResult.ok;
  }

  @override
  Future<BleControlResult> sendCommand(Uint8List encryptedFrame) async {
    final char = _cmdChar;
    if (char == null) {
      return BleControlResult.transportTimeout;
    }
    _resetIdleTimer();
    try {
      // withoutResponse=false để chip phản hồi qua NOTIFY (write-with-response
      // chỉ ack ATT, NOTIFY mới là kết quả AES-CCM verify).
      await char.write(encryptedFrame, withoutResponse: false);
    } catch (e) {
      log('[BLE-CTRL] write fail: $e', name: 'BleControl');
      return BleControlResult.transportTimeout;
    }

    final controller = _notifyController;
    if (controller == null) {
      return BleControlResult.transportTimeout;
    }
    try {
      final byte = await controller.stream.first
          .timeout(BleControlConstants.notifyTimeout);
      return _mapNotify(byte);
    } on TimeoutException {
      return BleControlResult.transportTimeout;
    }
  }

  @override
  Future<void> closeSession() async {
    _idleTimer?.cancel();
    _idleTimer = null;
    await _notifySub?.cancel();
    _notifySub = null;
    await _notifyController?.close();
    _notifyController = null;
    _cmdChar = null;
    final device = _device;
    _device = null;
    if (device != null) {
      try {
        await device.disconnect();
      } catch (e) {
        log('[BLE-CTRL] disconnect error (ignored): $e', name: 'BleControl');
      }
    }
  }

  void _resetIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(BleControlConstants.idleDisconnect, () {
      log('[BLE-CTRL] idle timeout → disconnect', name: 'BleControl');
      closeSession();
    });
  }

  static BleControlResult _mapNotify(int byte) => switch (byte) {
        0x00 => BleControlResult.ok,
        0x01 => BleControlResult.decryptFailed,
        0x02 => BleControlResult.replayRejected,
        0x03 => BleControlResult.unknownCommand,
        0x04 => BleControlResult.motorBusy,
        _ => BleControlResult.unknownStatus,
      };

  static T? _firstWhereOrNull<T>(List<T> items, bool Function(T) test) {
    for (final item in items) {
      if (test(item)) return item;
    }
    return null;
  }
}
