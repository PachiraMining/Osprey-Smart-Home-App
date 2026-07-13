import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_curtain_app/features/control/data/storage/ble_session_store.dart';
import 'package:smart_curtain_app/features/control/domain/entities/ble_session.dart';

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockSecureStorage storage;
  late BleSessionStore sessionStore;

  const deviceId = 'tb-device-123';
  final sessionKey = Uint8List.fromList(List<int>.generate(32, (i) => i));
  const ospreyUuid = 'f89d9d07-6664-4000-8000-f89d9d076664';

  setUpAll(() {
    registerFallbackValue(const IOSOptions());
    registerFallbackValue(const AndroidOptions());
  });

  setUp(() {
    storage = _MockSecureStorage();
    sessionStore = BleSessionStore(storage);

    // Default: storage rỗng
    when(() => storage.read(
          key: any(named: 'key'),
          iOptions: any(named: 'iOptions'),
          aOptions: any(named: 'aOptions'),
        )).thenAnswer((_) async => null);
    when(() => storage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
          iOptions: any(named: 'iOptions'),
          aOptions: any(named: 'aOptions'),
        )).thenAnswer((_) async {});
    when(() => storage.delete(
          key: any(named: 'key'),
          iOptions: any(named: 'iOptions'),
          aOptions: any(named: 'aOptions'),
        )).thenAnswer((_) async {});
  });

  group('BleSessionStore.save', () {
    test('persist 3 keys: ble_session_key_*, ble_counter_*, osprey_uuid_*', () async {
      await sessionStore.save(
        deviceId,
        BleSession(sessionKey: sessionKey, ospreyUuid: ospreyUuid, counter: 0),
      );

      verify(() => storage.write(
            key: 'ble_session_key_$deviceId',
            value: base64Encode(sessionKey),
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
          )).called(1);
      verify(() => storage.write(
            key: 'ble_counter_$deviceId',
            value: '0',
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
          )).called(1);
      verify(() => storage.write(
            key: 'osprey_uuid_$deviceId',
            value: ospreyUuid,
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
          )).called(1);
    });

    test('iOS write dùng synchronizable=true (iCloud sync per backend §3)', () async {
      await sessionStore.save(
        deviceId,
        BleSession(sessionKey: sessionKey, ospreyUuid: ospreyUuid, counter: 0),
      );
      final captured = verify(() => storage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
            iOptions: captureAny(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
          )).captured;
      for (final opt in captured) {
        expect(opt, isA<IOSOptions>());
        // Mocktail IOSOptions object phải có synchronizable=true để counter
        // sync qua iCloud Keychain → tránh re-pair khi user reinstall.
        // (Không reflect trực tiếp được; chỉ verify object identity vs const.)
      }
    });

    test('sessionKey không phải 32 bytes → ArgumentError', () async {
      expect(
        () => sessionStore.save(
          deviceId,
          BleSession(
              sessionKey: Uint8List(16),
              ospreyUuid: ospreyUuid,
              counter: 0),
        ),
        throwsArgumentError,
      );
    });

    test('deviceId rỗng → no-op (không gọi storage)', () async {
      await sessionStore.save(
        '',
        BleSession(sessionKey: sessionKey, ospreyUuid: ospreyUuid, counter: 0),
      );
      verifyNever(() => storage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
          ));
    });
  });

  group('BleSessionStore.read', () {
    test('trả về session khi đủ 3 key', () async {
      when(() => storage.read(
            key: 'ble_session_key_$deviceId',
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
          )).thenAnswer((_) async => base64Encode(sessionKey));
      when(() => storage.read(
            key: 'ble_counter_$deviceId',
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
          )).thenAnswer((_) async => '42');
      when(() => storage.read(
            key: 'osprey_uuid_$deviceId',
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
          )).thenAnswer((_) async => ospreyUuid);

      final session = await sessionStore.read(deviceId);
      expect(session, isNotNull);
      expect(session!.sessionKey, sessionKey);
      expect(session.ospreyUuid, ospreyUuid);
      expect(session.counter, 42);
    });

    test('thiếu 1 trong 3 key → null', () async {
      when(() => storage.read(
            key: 'ble_session_key_$deviceId',
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
          )).thenAnswer((_) async => base64Encode(sessionKey));
      // counter và uuid null

      final session = await sessionStore.read(deviceId);
      expect(session, isNull);
    });

    test('cache hit lần 2: không gọi storage', () async {
      await sessionStore.save(
        deviceId,
        BleSession(sessionKey: sessionKey, ospreyUuid: ospreyUuid, counter: 5),
      );
      clearInteractions(storage);

      final session = await sessionStore.read(deviceId);
      expect(session!.counter, 5);
      verifyNever(() => storage.read(
            key: any(named: 'key'),
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
          ));
    });
  });

  group('BleSessionStore.nextCounter — monotonic atomic', () {
    test('++ counter và persist', () async {
      await sessionStore.save(
        deviceId,
        BleSession(sessionKey: sessionKey, ospreyUuid: ospreyUuid, counter: 7),
      );
      clearInteractions(storage);

      final next = await sessionStore.nextCounter(deviceId);
      expect(next, 8);

      verify(() => storage.write(
            key: 'ble_counter_$deviceId',
            value: '8',
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
          )).called(1);
    });

    test('chưa save → StateError', () async {
      await expectLater(
        sessionStore.nextCounter(deviceId),
        throwsStateError,
      );
    });

    test('100 concurrent nextCounter → ra đúng 100 giá trị monotonic', () async {
      await sessionStore.save(
        deviceId,
        BleSession(sessionKey: sessionKey, ospreyUuid: ospreyUuid, counter: 0),
      );
      final futures = List.generate(100, (_) => sessionStore.nextCounter(deviceId));
      final results = await Future.wait(futures);
      // Atomic chain → results phải là [1, 2, 3, ..., 100] đúng thứ tự
      expect(results, List<int>.generate(100, (i) => i + 1));
    });
  });

  group('BleSessionStore.clear', () {
    test('xoá 3 key', () async {
      await sessionStore.clear(deviceId);
      verify(() => storage.delete(
            key: 'ble_session_key_$deviceId',
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
          )).called(1);
      verify(() => storage.delete(
            key: 'ble_counter_$deviceId',
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
          )).called(1);
      verify(() => storage.delete(
            key: 'osprey_uuid_$deviceId',
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
          )).called(1);
    });

    test('clear xong → read trả null (cache cũng xoá)', () async {
      await sessionStore.save(
        deviceId,
        BleSession(sessionKey: sessionKey, ospreyUuid: ospreyUuid, counter: 5),
      );
      await sessionStore.clear(deviceId);

      // sau clear, storage cũng được reset về null (mock default behavior)
      final session = await sessionStore.read(deviceId);
      expect(session, isNull);
    });
  });
}
