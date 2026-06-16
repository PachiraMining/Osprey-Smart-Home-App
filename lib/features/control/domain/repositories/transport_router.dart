import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/transport_state.dart';

/// Route lệnh control device qua MQTT/RPC (cloud) hoặc BLE (fallback).
///
/// **Switching rules** (spec §4.1 + backend note §3):
/// - Rule A: MQTT wins khi available.
/// - Rule B: Cloud-down >10s → switch BLE.
/// - Rule C: Cloud-up → switch MQTT ngay (silent).
/// - Rule D: Debounce flap (handled trong CloudHealthCubit).
/// - Rule E: Command in-flight tại thời điểm switch → finish trên transport cũ.
/// - Rule F: Chip không cần biết mode — fully owned bởi app.
abstract class TransportRouter {
  /// Stream phát transport hiện tại cho UI (badge "Local control" / unreachable).
  Stream<TransportState> get transport$;

  /// Snapshot transport hiện tại.
  TransportState get currentTransport;

  /// Bind device đang focus để router track BLE in-range cho riêng nó.
  ///
  /// Gọi từ Curtain/Device Control page khi user mở. `null` để unbind.
  Future<void> watchDevice(String? tbDeviceId);

  /// Gửi 1 command (OPEN/CLOSE/STOP) đến device — router tự chọn transport.
  Future<Either<Failure, void>> sendCommand({
    required String tbDeviceId,
    required String command,
  });

  /// Force BLE path bypass state machine — dùng khi UI vừa thấy cloud HTTP
  /// fail SocketException (CloudHealthCubit chưa kịp flip vì MQTT TCP
  /// keep-alive 60s). Có side-effect: nếu BLE thành công, signal cho
  /// CloudHealthCubit biết cloud đang lỗi để badge "Local control" hiện ra.
  Future<Either<Failure, void>> sendCommandViaBle({
    required String tbDeviceId,
    required String command,
  });
}
