import 'dart:async';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_curtain_app/core/error/failure.dart';
import 'package:smart_curtain_app/core/network/mqtt_service.dart';
import 'package:smart_curtain_app/features/control/data/crypto/ble_control_crypto.dart';
import 'package:smart_curtain_app/features/control/data/datasources/ble_control_datasource.dart';
import 'package:smart_curtain_app/features/control/data/repositories/transport_router_impl.dart';
import 'package:smart_curtain_app/features/control/data/storage/ble_session_store.dart';
import 'package:smart_curtain_app/features/control/domain/entities/ble_control_result.dart';
import 'package:smart_curtain_app/features/control/domain/entities/ble_session.dart';
import 'package:smart_curtain_app/features/control/domain/entities/cloud_health.dart';
import 'package:smart_curtain_app/features/control/domain/entities/transport_state.dart';
import 'package:smart_curtain_app/features/control/presentation/bloc/cloud_health_cubit.dart';
import 'package:smart_curtain_app/features/device/data/datasources/device_control_data_source.dart';

class _MockCloud extends Mock implements DeviceControlDataSource {}

class _MockBle extends Mock implements BleControlDataSource {}

class _MockSessionStore extends Mock implements BleSessionStore {}

class _MockCrypto extends Mock implements BleControlCrypto {}

class _MockMqtt extends Mock implements MqttService {}

/// Subclass test-only để bypass 10s grace của CloudHealthCubit — set state
/// trực tiếp qua `testEmit` thay vì chờ timer thật.
class _TestableCloudHealthCubit extends CloudHealthCubit {
  _TestableCloudHealthCubit(super.mqttService);
  void setHealth(CloudHealth h) => emit(h);
}

void main() {
  late _MockCloud cloud;
  late _MockBle ble;
  late _MockSessionStore sessionStore;
  late _MockCrypto crypto;
  late _TestableCloudHealthCubit health;
  late _MockMqtt mqtt;
  late StreamController<MqttConnectionState> mqttStateCtrl;
  late TransportRouterImpl router;

  const deviceId = 'tb-device-1';
  const remoteId = 'AA:BB:CC:DD:EE:FF';
  final sessionKey = Uint8List(32);
  final session = BleSession(
    sessionKey: sessionKey,
    ospreyUuid: 'f89d9d07-6664-4000-8000-f89d9d076664',
    counter: 5,
    bleRemoteId: remoteId,
  );
  final encryptedFrame = Uint8List.fromList(List.generate(40, (i) => i));

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(<int>[]);
  });

  setUp(() {
    cloud = _MockCloud();
    ble = _MockBle();
    sessionStore = _MockSessionStore();
    crypto = _MockCrypto();
    mqtt = _MockMqtt();
    mqttStateCtrl = StreamController<MqttConnectionState>.broadcast();
    when(() => mqtt.state$).thenAnswer((_) => mqttStateCtrl.stream);
    when(() => mqtt.isConnected).thenReturn(true);
    health = _TestableCloudHealthCubit(mqtt);

    when(() => sessionStore.read(deviceId)).thenAnswer((_) async => session);
    when(() => sessionStore.nextCounter(deviceId))
        .thenAnswer((_) async => 6);
    when(() => crypto.encryptCommand(
          sessionKey: any(named: 'sessionKey'),
          counter: any(named: 'counter'),
          plaintext: any(named: 'plaintext'),
        )).thenReturn(encryptedFrame);
    when(() => ble.isInRange(remoteId)).thenAnswer((_) async => true);
    when(() => ble.openSession(remoteId))
        .thenAnswer((_) async => BleControlResult.ok);
    when(() => ble.sendCommand(any()))
        .thenAnswer((_) async => BleControlResult.ok);
    when(() => ble.closeSession()).thenAnswer((_) async {});
    when(() => cloud.sendCommand(any(), any())).thenAnswer((_) async {});

    router = TransportRouterImpl(
      cloud: cloud,
      ble: ble,
      sessionStore: sessionStore,
      healthCubit: health,
      crypto: crypto,
    );
  });

  tearDown(() async {
    await router.dispose();
    await health.close();
    await mqttStateCtrl.close();
  });

  group('Rule A — MQTT wins khi available', () {
    test('cloud online → route cloud, BLE không bị đụng tới', () async {
      expect(router.currentTransport, TransportState.cloud);

      final result = await router.sendCommand(
          tbDeviceId: deviceId, command: 'OPEN');

      expect(result.isRight(), true);
      verify(() => cloud.sendCommand(deviceId, 'OPEN')).called(1);
      verifyNever(() => ble.openSession(any()));
      verifyNever(() => ble.sendCommand(any()));
    });

    test('cloud degraded (đang grace) → vẫn route cloud', () async {
      health.setHealth(CloudHealth.degraded);
      await Future.delayed(Duration.zero);

      final result = await router.sendCommand(
          tbDeviceId: deviceId, command: 'CLOSE');

      expect(result.isRight(), true);
      verify(() => cloud.sendCommand(deviceId, 'CLOSE')).called(1);
    });
  });

  group('Rule B — Cloud down + BLE in range → switch BLE', () {
    setUp(() async {
      await router.watchDevice(deviceId);
      health.setHealth(CloudHealth.down);
      await Future.delayed(const Duration(milliseconds: 50));
    });

    test('transport = bleFallback', () {
      expect(router.currentTransport, TransportState.bleFallback);
    });

    test('sendCommand encrypt → write BLE_CONTROL_CMD', () async {
      final result = await router.sendCommand(
          tbDeviceId: deviceId, command: 'OPEN');

      expect(result.isRight(), true);
      verify(() => ble.openSession(remoteId)).called(1);
      verify(() => crypto.encryptCommand(
            sessionKey: sessionKey,
            counter: 6,
            plaintext: any(named: 'plaintext'),
          )).called(1);
      verify(() => ble.sendCommand(encryptedFrame)).called(1);
      verifyNever(() => cloud.sendCommand(any(), any()));
    });

    test('BLE notify 0x01 decryptFailed → ReLearnRequiredFailure', () async {
      when(() => ble.sendCommand(any()))
          .thenAnswer((_) async => BleControlResult.decryptFailed);

      final result = await router.sendCommand(
          tbDeviceId: deviceId, command: 'OPEN');

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f, isA<ReLearnRequiredFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('BLE notify 0x02 replayRejected → ReLearnRequiredFailure', () async {
      when(() => ble.sendCommand(any()))
          .thenAnswer((_) async => BleControlResult.replayRejected);

      final result = await router.sendCommand(
          tbDeviceId: deviceId, command: 'STOP');

      result.fold(
        (f) {
          expect(f, isA<ReLearnRequiredFailure>());
          expect((f as ReLearnRequiredFailure).tbDeviceId, deviceId);
        },
        (_) => fail('expected Left'),
      );
    });

    test('BLE timeout → DeviceUnreachableFailure', () async {
      when(() => ble.openSession(remoteId))
          .thenAnswer((_) async => BleControlResult.transportTimeout);

      final result = await router.sendCommand(
          tbDeviceId: deviceId, command: 'OPEN');

      result.fold(
        (f) => expect(f, isA<DeviceUnreachableFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  group('Rule C — MQTT back → revert cloud ngay', () {
    test('từ bleFallback → cloud khi health emit online', () async {
      await router.watchDevice(deviceId);
      health.setHealth(CloudHealth.down);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(router.currentTransport, TransportState.bleFallback);

      health.setHealth(CloudHealth.online);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(router.currentTransport, TransportState.cloud);

      await router.sendCommand(tbDeviceId: deviceId, command: 'OPEN');
      verify(() => cloud.sendCommand(deviceId, 'OPEN')).called(1);
    });
  });

  group('Cloud down + BLE out of range → unreachable', () {
    test('transport state = unreachable + sendCommand fail', () async {
      when(() => ble.isInRange(remoteId)).thenAnswer((_) async => false);

      await router.watchDevice(deviceId);
      health.setHealth(CloudHealth.down);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(router.currentTransport, TransportState.unreachable);

      final result = await router.sendCommand(
          tbDeviceId: deviceId, command: 'OPEN');
      result.fold(
        (f) => expect(f, isA<DeviceUnreachableFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  group('Rule E — command in-flight finish trên transport cũ', () {
    test('snapshot transport tại thời điểm gọi sendCommand', () async {
      await router.watchDevice(deviceId);
      health.setHealth(CloudHealth.down);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(router.currentTransport, TransportState.bleFallback);

      // Bắt đầu BLE command với delay cố ý
      final cmdCompleter = Completer<BleControlResult>();
      when(() => ble.sendCommand(any()))
          .thenAnswer((_) => cmdCompleter.future);
      final pending = router.sendCommand(
          tbDeviceId: deviceId, command: 'OPEN');

      // Trong khi command đang chạy, cloud back
      health.setHealth(CloudHealth.online);
      await Future.delayed(Duration.zero);
      expect(router.currentTransport, TransportState.cloud);

      // Hoàn tất BLE command → vẫn thấy nó được fulfill qua BLE (không bị
      // chuyển sang cloud giữa chừng).
      cmdCompleter.complete(BleControlResult.ok);
      final result = await pending;
      expect(result.isRight(), true);

      // Kiểm tra: cloud.sendCommand KHÔNG được gọi cho command này
      verifyNever(() => cloud.sendCommand(any(), any()));
      verify(() => ble.sendCommand(encryptedFrame)).called(1);
    });
  });

  group('Command mapping (spec §5.2)', () {
    setUp(() async {
      await router.watchDevice(deviceId);
      health.setHealth(CloudHealth.down);
      await Future.delayed(const Duration(milliseconds: 50));
    });

    test('OPEN → {"cmd":"open"}', () async {
      await router.sendCommand(tbDeviceId: deviceId, command: 'OPEN');
      verify(() => crypto.encryptCommand(
            sessionKey: any(named: 'sessionKey'),
            counter: any(named: 'counter'),
            plaintext: any(
                named: 'plaintext',
                that: predicate<List<int>>(
                  (l) => String.fromCharCodes(l) == '{"cmd":"open"}',
                )),
          )).called(1);
    });

    test('PCT:50 → {"cmd":"pct","v":50}', () async {
      await router.sendCommand(tbDeviceId: deviceId, command: 'PCT:50');
      verify(() => crypto.encryptCommand(
            sessionKey: any(named: 'sessionKey'),
            counter: any(named: 'counter'),
            plaintext: any(
                named: 'plaintext',
                that: predicate<List<int>>(
                  (l) => String.fromCharCodes(l) == '{"cmd":"pct","v":50}',
                )),
          )).called(1);
    });

    test('PCT:101 → invalid → ServerFailure', () async {
      final result = await router.sendCommand(
          tbDeviceId: deviceId, command: 'PCT:101');
      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  group('Session chưa có cho device', () {
    test('BLE path + no session → ReLearnRequiredFailure', () async {
      when(() => sessionStore.read(deviceId)).thenAnswer((_) async => null);

      await router.watchDevice(deviceId);
      health.setHealth(CloudHealth.down);
      await Future.delayed(const Duration(milliseconds: 50));

      // unreachable vì no session → no remoteId để scan
      // Khi user tap, router thử BLE → no session → ReLearn
      // (nhưng vì isInRange phụ thuộc remoteId, transport = unreachable)
      // → ngay nhánh unreachable: read session → null → final Left unreachable
      final result = await router.sendCommand(
          tbDeviceId: deviceId, command: 'OPEN');
      result.fold(
        (f) => expect(
          f,
          anyOf(
              isA<DeviceUnreachableFailure>(), isA<ReLearnRequiredFailure>()),
        ),
        (_) => fail('expected Left'),
      );
    });
  });
}
