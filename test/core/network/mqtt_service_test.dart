import 'package:flutter_test/flutter_test.dart';

import 'package:smart_curtain_app/core/network/mqtt_service.dart';

void main() {
  group('MqttService.updateToken', () {
    late MqttService service;

    setUp(() {
      service = MqttService(host: 'broker.invalid', port: 1883);
    });

    tearDown(() async {
      await service.dispose();
    });

    test('is a no-op when never connected (no client to bounce)', () async {
      // No connect() has happened, so there is nothing to reconnect. This must
      // not throw and must not open a connection on its own.
      await service.updateToken('fresh-jwt');
      expect(service.isConnected, isFalse);
    });

    test('ignores an empty token', () async {
      await service.updateToken('');
      expect(service.isConnected, isFalse);
    });

    test('does not throw after dispose', () async {
      await service.dispose();
      await service.updateToken('fresh-jwt');
      expect(service.isConnected, isFalse);
    });
  });
}
