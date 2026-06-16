import 'dart:async';
import 'dart:developer';

import 'package:clock/clock.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/mqtt_service.dart';
import '../../domain/entities/cloud_health.dart';

/// Theo dõi `CloudHealth` cho toàn app — drive cả transport router và UI badge.
///
/// **Tín hiệu**:
/// 1. `MqttService.state$` — primary signal. MQTT disconnected = cloud-down
///    sau 10s grace (Rule B).
/// 2. `probe()` (optional) — gọi mỗi 15s khi MQTT đang online để bắt case
///    backend silent nhưng MQTT chưa drop. Set ngoài qua `setProbe`.
///
/// **Quy tắc**:
/// - Rule B: 10s grace trước khi flip xuống `down` (tránh false-positive
///   từ mesh handoff / router restart ngắn).
/// - Rule C: ngay khi nhận MQTT connected HOẶC probe success → emit `online`
///   ngay lập tức (không grace ngược lại).
/// - Rule D: rate-limit transition online→down xuống tối đa 1 lần / 30s
///   để tránh flapping badge.
class CloudHealthCubit extends Cubit<CloudHealth> {
  CloudHealthCubit(this._mqttService) : super(CloudHealth.online) {
    _mqttSub = _mqttService.state$.listen(_onMqttState);
    // Tình trạng ban đầu: nếu MQTT chưa connect, coi như đang degraded.
    if (!_mqttService.isConnected) {
      _onMqttState(MqttConnectionState.disconnected);
    }
  }

  final MqttService _mqttService;
  late final StreamSubscription<MqttConnectionState> _mqttSub;

  Timer? _degradedTimer;
  Timer? _pollTimer;
  DateTime? _lastDownAt;

  Future<bool> Function()? _probe;

  static const _gracePeriod = Duration(seconds: 10);
  static const _pollInterval = Duration(seconds: 15);
  static const _flapWindow = Duration(seconds: 30);

  /// Đăng ký probe (ví dụ `/network-info` cho device đang focus).
  /// Cubit sẽ gọi probe mỗi 15s — kể cả khi đang degraded, vì probe có thể
  /// recover state về online sớm hơn MQTT (Rule C).
  void setProbe(Future<bool> Function()? probe) {
    _probe = probe;
    _pollTimer?.cancel();
    if (probe != null) {
      _startPolling();
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) async {
      final probe = _probe;
      if (probe == null) return;
      try {
        final ok = await probe().timeout(const Duration(seconds: 8));
        if (ok) {
          _markUp();
        } else {
          _markDown();
        }
      } catch (e) {
        log('[CloudHealth] probe error: $e', name: 'CloudHealth');
        _markDown();
      }
    });
  }

  void _onMqttState(MqttConnectionState s) {
    switch (s) {
      case MqttConnectionState.connected:
        _markUp();
      case MqttConnectionState.disconnected:
      case MqttConnectionState.reconnecting:
        _markDown();
      case MqttConnectionState.connecting:
        // Trung gian, giữ nguyên state
        break;
    }
  }

  void _markUp() {
    _degradedTimer?.cancel();
    _degradedTimer = null;
    if (state != CloudHealth.online) {
      emit(CloudHealth.online);
    }
  }

  void _markDown() {
    // Đã down rồi → no-op
    if (state == CloudHealth.down) return;

    // Đang online → vào degraded + start 10s grace
    if (state == CloudHealth.online) {
      // Rule D: nếu vừa rời `down` trong vòng 30s → không cho flip lại
      // để tránh flapping badge.
      final lastDown = _lastDownAt;
      if (lastDown != null &&
          clock.now().difference(lastDown) < _flapWindow) {
        log('[CloudHealth] suppress flap (last down was '
            '${clock.now().difference(lastDown).inSeconds}s ago)',
            name: 'CloudHealth');
        return;
      }
      emit(CloudHealth.degraded);
    }

    // Start hoặc reuse degraded timer
    _degradedTimer?.cancel();
    _degradedTimer = Timer(_gracePeriod, () {
      if (state != CloudHealth.online) {
        _lastDownAt = clock.now();
        emit(CloudHealth.down);
      }
    });
  }

  @override
  Future<void> close() async {
    await _mqttSub.cancel();
    _degradedTimer?.cancel();
    _pollTimer?.cancel();
    return super.close();
  }
}
