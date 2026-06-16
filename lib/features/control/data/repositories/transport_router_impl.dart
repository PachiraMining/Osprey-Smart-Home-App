import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../device/data/datasources/device_control_data_source.dart';
import '../../domain/entities/ble_control_result.dart';
import '../../domain/entities/cloud_health.dart';
import '../../domain/entities/transport_state.dart';
import '../../domain/repositories/transport_router.dart';
import '../../presentation/bloc/cloud_health_cubit.dart';
import '../crypto/ble_control_crypto.dart';
import '../datasources/ble_control_datasource.dart';
import '../storage/ble_session_store.dart';

/// Failure dành riêng cho transport routing (UI cần phân biệt để show
/// dialog re-pair vs unreachable).
class ReLearnRequiredFailure extends Failure {
  const ReLearnRequiredFailure(super.errorMessage,
      {required super.message, this.tbDeviceId});
  final String? tbDeviceId;
}

class DeviceUnreachableFailure extends Failure {
  const DeviceUnreachableFailure(super.errorMessage,
      {required super.message});
}

class TransportRouterImpl implements TransportRouter {
  TransportRouterImpl({
    required this.cloud,
    required this.ble,
    required this.sessionStore,
    required this.healthCubit,
    required this.crypto,
  }) {
    _healthSub = healthCubit.stream.listen(_onHealthChanged);
    _state = _deriveTransport(healthCubit.state, _bleInRange);
  }

  final DeviceControlDataSource cloud;
  final BleControlDataSource ble;
  final BleSessionStore sessionStore;
  final CloudHealthCubit healthCubit;
  final BleControlCrypto crypto;

  late StreamSubscription<CloudHealth> _healthSub;
  final _transportCtrl = StreamController<TransportState>.broadcast();

  late TransportState _state;
  bool _bleInRange = false;
  String? _watchedDeviceId;
  Timer? _bleScanTimer;

  // Rule E: command in-flight finish trên transport tại thời điểm gọi
  // (snapshot `_state` ở đầu `sendCommand`) — không track count vì Dart
  // single-threaded, không có race với transport flip giữa chừng.

  @override
  Stream<TransportState> get transport$ => _transportCtrl.stream;

  @override
  TransportState get currentTransport => _state;

  @override
  Future<void> watchDevice(String? tbDeviceId) async {
    if (_watchedDeviceId == tbDeviceId) return;
    _watchedDeviceId = tbDeviceId;
    _bleScanTimer?.cancel();
    _bleInRange = false;
    if (tbDeviceId == null) {
      _recomputeTransport();
      return;
    }
    // Probe BLE in-range mỗi 10s khi cloud-down — không scan liên tục để
    // tiết kiệm pin.
    _bleScanTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (healthCubit.state == CloudHealth.online) return;
      await _checkInRange(tbDeviceId);
    });
    // Probe ngay 1 lần nếu đang degraded/down
    if (healthCubit.state != CloudHealth.online) {
      await _checkInRange(tbDeviceId);
    }
  }

  Future<void> _checkInRange(String tbDeviceId) async {
    final session = await sessionStore.read(tbDeviceId);
    final remoteId = session?.bleRemoteId;
    if (remoteId == null) {
      _bleInRange = false;
    } else {
      _bleInRange = await ble.isInRange(remoteId);
    }
    _recomputeTransport();
  }

  /// Reaction khi CloudHealth flip:
  /// - online → reset BLE flag (sẽ probe lại lần tới nếu xuống down).
  /// - degraded/down → probe ngay để biết BLE có khả thi không.
  void _onHealthChanged(CloudHealth h) {
    if (h == CloudHealth.online) {
      _bleInRange = false;
    } else {
      final id = _watchedDeviceId;
      if (id != null) {
        // Fire-and-forget (UI sẽ rebuild khi transport$ emit)
        _checkInRange(id);
      }
    }
    _recomputeTransport();
  }

  void _recomputeTransport() {
    final next = _deriveTransport(healthCubit.state, _bleInRange);
    if (next != _state) {
      _state = next;
      _transportCtrl.add(next);
      log('[TransportRouter] → $next', name: 'TransportRouter');
    }
  }

  static TransportState _deriveTransport(CloudHealth h, bool bleInRange) {
    if (h == CloudHealth.online || h == CloudHealth.degraded) {
      return TransportState.cloud;
    }
    // down
    return bleInRange ? TransportState.bleFallback : TransportState.unreachable;
  }

  @override
  Future<Either<Failure, void>> sendCommand({
    required String tbDeviceId,
    required String command,
  }) async {
    // Rule E: snapshot transport ngay lúc gọi để command finish trên đường cũ.
    final snapshot = _state;
    switch (snapshot) {
      case TransportState.cloud:
        return _sendCloud(tbDeviceId, command);
      case TransportState.bleFallback:
        return _sendBle(tbDeviceId, command);
      case TransportState.unreachable:
        // Thử BLE 1 lần (chip có thể vừa lọt vào tầm) trước khi báo unreachable.
        final session = await sessionStore.read(tbDeviceId);
        if (session?.bleRemoteId != null) {
          final back = await ble.isInRange(session!.bleRemoteId!);
          if (back) {
            _bleInRange = true;
            _recomputeTransport();
            return _sendBle(tbDeviceId, command);
          }
        }
        return const Left(DeviceUnreachableFailure(
          'Device unreachable',
          message:
              'Device is unreachable — check WiFi or move closer for BLE.',
        ));
    }
  }

  @override
  Future<Either<Failure, void>> sendCommandViaBle({
    required String tbDeviceId,
    required String command,
  }) async {
    log('[TransportRouter] sendCommandViaBle (forced) for $tbDeviceId',
        name: 'TransportRouter');
    final result = await _sendBle(tbDeviceId, command);
    // Nếu BLE thành công → đẩy state sang bleFallback để badge UI hiện.
    // Khi cloud back, CloudHealthCubit sẽ tự flip lại online.
    if (result.isRight()) {
      _bleInRange = true;
      if (_state != TransportState.bleFallback) {
        _state = TransportState.bleFallback;
        _transportCtrl.add(_state);
        log('[TransportRouter] forced → bleFallback (cloud HTTP failed)',
            name: 'TransportRouter');
      }
    }
    return result;
  }

  Future<Either<Failure, void>> _sendCloud(
      String tbDeviceId, String command) async {
    try {
      await cloud.sendCommand(tbDeviceId, command);
      return const Right(null);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(
          e.message.isEmpty ? 'Unauthorized' : e.message,
          message: e.message.isEmpty ? 'Unauthorized' : e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } on NetworkException {
      return Left(NetworkFailure('No internet connection',
          message: 'No internet connection'));
    } catch (e) {
      return Left(ServerFailure('$e', message: '$e'));
    }
  }

  Future<Either<Failure, void>> _sendBle(
      String tbDeviceId, String command) async {
    final session = await sessionStore.read(tbDeviceId);
    if (session == null || session.bleRemoteId == null) {
      return Left(ReLearnRequiredFailure(
        'Not paired for local control',
        message: 'Please re-pair this device to enable local control.',
        tbDeviceId: tbDeviceId,
      ));
    }

    final openResult = await ble.openSession(session.bleRemoteId!);
    if (openResult != BleControlResult.ok) {
      return Left(DeviceUnreachableFailure(
        'BLE open fail: $openResult',
        message: 'Could not connect to the device over Bluetooth.',
      ));
    }

    final json = _commandToJson(command);
    if (json == null) {
      return Left(ServerFailure('Unsupported command: $command',
          message: 'Unsupported command: $command'));
    }

    final counter = await sessionStore.nextCounter(tbDeviceId);
    final frame = crypto.encryptCommand(
      sessionKey: session.sessionKey,
      counter: counter,
      plaintext: utf8.encode(json),
    );
    final result = await ble.sendCommand(frame);

    return switch (result) {
      BleControlResult.ok => const Right<Failure, void>(null),
      BleControlResult.decryptFailed ||
      BleControlResult.replayRejected =>
        Left(ReLearnRequiredFailure(
          'BLE rejected: $result',
          message: 'Please re-pair this device to enable local control.',
          tbDeviceId: tbDeviceId,
        )),
      BleControlResult.motorBusy => Left(ServerFailure('Motor busy',
          message: 'The motor is busy — please try again.')),
      BleControlResult.unknownCommand => Left(ServerFailure('Unsupported',
          message: 'Device firmware does not support this command.')),
      BleControlResult.transportTimeout => Left(DeviceUnreachableFailure(
          'BLE timeout',
          message: 'Bluetooth connection timed out.')),
      BleControlResult.notPaired ||
      BleControlResult.unknownStatus =>
        Left(DeviceUnreachableFailure('BLE error: $result',
            message: 'Could not control the device over Bluetooth.')),
    };
  }

  /// App-side command name → JSON cmd theo spec §5.2.
  static String? _commandToJson(String command) {
    final upper = command.toUpperCase().trim();
    if (upper == 'OPEN') return '{"cmd":"open"}';
    if (upper == 'CLOSE') return '{"cmd":"close"}';
    if (upper == 'STOP') return '{"cmd":"stop"}';
    if (upper.startsWith('PCT:')) {
      final v = int.tryParse(upper.substring(4));
      if (v == null || v < 0 || v > 100) return null;
      return '{"cmd":"pct","v":$v}';
    }
    return null;
  }

  Future<void> dispose() async {
    _bleScanTimer?.cancel();
    await _healthSub.cancel();
    await _transportCtrl.close();
    await ble.closeSession();
  }
}
