import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// Material để gửi command BLE đến chip đã pair, lưu sau mỗi lần pair thành công.
///
/// `sessionKey` (32B) derive từ HKDF tại pairing (xem `PairingCrypto.deriveSessionKey`).
/// `ospreyUuid` là UUID firmware advertise (đọc từ char DEVICE_UUID), dùng để
/// match advertisement khi scan tìm đúng chip lúc fallback.
/// `counter` là monotonic uint64, chip persist song song để chống replay.
class BleSession extends Equatable {
  final Uint8List sessionKey;
  final String ospreyUuid;
  final int counter;

  /// BLE remoteId (Android: MAC; iOS: CBPeripheral UUID) captured tại pair time.
  /// Optional vì session pair từ build cũ chưa lưu — fallback sẽ scan + READ
  /// char DEVICE_UUID để match `ospreyUuid` nếu thiếu.
  final String? bleRemoteId;

  const BleSession({
    required this.sessionKey,
    required this.ospreyUuid,
    required this.counter,
    this.bleRemoteId,
  });

  BleSession copyWith({
    Uint8List? sessionKey,
    String? ospreyUuid,
    int? counter,
    String? bleRemoteId,
  }) {
    return BleSession(
      sessionKey: sessionKey ?? this.sessionKey,
      ospreyUuid: ospreyUuid ?? this.ospreyUuid,
      counter: counter ?? this.counter,
      bleRemoteId: bleRemoteId ?? this.bleRemoteId,
    );
  }

  @override
  List<Object?> get props => [sessionKey, ospreyUuid, counter, bleRemoteId];
}
