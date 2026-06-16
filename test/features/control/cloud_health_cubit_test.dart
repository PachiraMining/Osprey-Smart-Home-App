import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_curtain_app/core/network/mqtt_service.dart';
import 'package:smart_curtain_app/features/control/domain/entities/cloud_health.dart';
import 'package:smart_curtain_app/features/control/presentation/bloc/cloud_health_cubit.dart';

class _MockMqttService extends Mock implements MqttService {}

void main() {
  late _MockMqttService mqtt;
  late StreamController<MqttConnectionState> mqttStateCtrl;

  setUp(() {
    mqtt = _MockMqttService();
    mqttStateCtrl = StreamController<MqttConnectionState>.broadcast();
    when(() => mqtt.state$).thenAnswer((_) => mqttStateCtrl.stream);
    when(() => mqtt.isConnected).thenReturn(true);
  });

  tearDown(() async {
    await mqttStateCtrl.close();
  });

  group('CloudHealthCubit — Rule B: 10s grace trước khi flip down', () {
    test('MQTT disconnect → degraded ngay, down sau 10s', () {
      fakeAsync((async) {
        final cubit = CloudHealthCubit(mqtt);
        async.flushMicrotasks();
        expect(cubit.state, CloudHealth.online);

        // MQTT drops
        mqttStateCtrl.add(MqttConnectionState.disconnected);
        async.flushMicrotasks();
        expect(cubit.state, CloudHealth.degraded);

        // 9s sau vẫn degraded
        async.elapse(const Duration(seconds: 9));
        expect(cubit.state, CloudHealth.degraded);

        // 10s tổng → down
        async.elapse(const Duration(seconds: 2));
        expect(cubit.state, CloudHealth.down);

        cubit.close();
      });
    });

    test('MQTT drop rồi reconnect <10s → ở lại online (no flip)', () {
      fakeAsync((async) {
        final cubit = CloudHealthCubit(mqtt);
        async.flushMicrotasks();

        mqttStateCtrl.add(MqttConnectionState.disconnected);
        async.flushMicrotasks();
        expect(cubit.state, CloudHealth.degraded);

        // 5s sau MQTT back
        async.elapse(const Duration(seconds: 5));
        mqttStateCtrl.add(MqttConnectionState.connected);
        async.flushMicrotasks();
        expect(cubit.state, CloudHealth.online);

        // 10s nữa vẫn online (grace timer đã bị cancel)
        async.elapse(const Duration(seconds: 10));
        expect(cubit.state, CloudHealth.online);

        cubit.close();
      });
    });
  });

  group('CloudHealthCubit — Rule C: MQTT back → online IMMEDIATELY', () {
    test('từ down → online ngay khi MQTT connected (không grace ngược)', () {
      fakeAsync((async) {
        final cubit = CloudHealthCubit(mqtt);
        async.flushMicrotasks();

        mqttStateCtrl.add(MqttConnectionState.disconnected);
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 11));
        expect(cubit.state, CloudHealth.down);

        mqttStateCtrl.add(MqttConnectionState.connected);
        async.flushMicrotasks();
        expect(cubit.state, CloudHealth.online);

        cubit.close();
      });
    });
  });

  group('CloudHealthCubit — Rule D: rate-limit flap ≤ 1/30s', () {
    test('down → online → drop ngay → KHÔNG flip xuống lần 2 trong 30s', () {
      fakeAsync((async) {
        final cubit = CloudHealthCubit(mqtt);
        async.flushMicrotasks();

        // Flip to down
        mqttStateCtrl.add(MqttConnectionState.disconnected);
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 11));
        expect(cubit.state, CloudHealth.down);

        // Back online
        mqttStateCtrl.add(MqttConnectionState.connected);
        async.flushMicrotasks();
        expect(cubit.state, CloudHealth.online);

        // Drop lần nữa trong 10s → bị suppress (Rule D)
        async.elapse(const Duration(seconds: 10));
        mqttStateCtrl.add(MqttConnectionState.disconnected);
        async.flushMicrotasks();
        expect(cubit.state, CloudHealth.online,
            reason: 'Phải giữ online vì flap window 30s chưa qua');

        // Sau 30s mới cho phép flip lại
        async.elapse(const Duration(seconds: 25));
        mqttStateCtrl.add(MqttConnectionState.disconnected);
        async.flushMicrotasks();
        expect(cubit.state, CloudHealth.degraded);

        cubit.close();
      });
    });
  });

  group('CloudHealthCubit — probe()', () {
    test('probe trả false → trigger _markDown sau 10s grace', () {
      fakeAsync((async) {
        final cubit = CloudHealthCubit(mqtt);
        async.flushMicrotasks();

        var calls = 0;
        cubit.setProbe(() async {
          calls++;
          return false;
        });
        async.flushMicrotasks();

        // Tick 15s → probe được gọi
        async.elapse(const Duration(seconds: 15));
        async.flushMicrotasks();
        expect(calls, greaterThanOrEqualTo(1));
        // Probe fail → markDown → degraded
        expect(cubit.state, CloudHealth.degraded);

        // Thêm 10s grace → down
        async.elapse(const Duration(seconds: 11));
        async.flushMicrotasks();
        expect(cubit.state, CloudHealth.down);

        cubit.close();
      });
    });

    test('probe trả true sau khi degraded → back online ngay', () {
      fakeAsync((async) {
        final cubit = CloudHealthCubit(mqtt);
        async.flushMicrotasks();

        mqttStateCtrl.add(MqttConnectionState.disconnected);
        async.flushMicrotasks();
        expect(cubit.state, CloudHealth.degraded);

        cubit.setProbe(() async => true);
        async.elapse(const Duration(seconds: 15));
        async.flushMicrotasks();
        expect(cubit.state, CloudHealth.online);

        cubit.close();
      });
    });
  });
}
