import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_curtain_app/core/error/exceptions.dart';
import 'package:smart_curtain_app/core/error/failure.dart';
import 'package:smart_curtain_app/features/control/data/storage/ble_session_store.dart';
import 'package:smart_curtain_app/features/control/domain/entities/ble_session.dart';
import 'package:smart_curtain_app/features/pairing/data/crypto/pairing_crypto.dart';
import 'package:smart_curtain_app/features/pairing/data/datasources/ble_pairing_datasource.dart';
import 'package:smart_curtain_app/features/pairing/data/datasources/pairing_remote_datasource.dart';
import 'package:smart_curtain_app/features/pairing/data/datasources/product_catalog_cache.dart';
import 'package:smart_curtain_app/features/pairing/data/models/auth_challenge_response_model.dart';
import 'package:smart_curtain_app/features/pairing/data/models/osprey_product_model.dart';
import 'package:smart_curtain_app/features/pairing/data/models/pairing_token_model.dart';
import 'package:smart_curtain_app/features/pairing/data/repositories/pairing_repository_impl.dart';
import 'package:smart_curtain_app/features/pairing/domain/entities/discovered_osprey_device.dart';
import 'package:smart_curtain_app/features/pairing/domain/entities/osprey_adv_data.dart';
import 'package:smart_curtain_app/features/pairing/domain/entities/pairing_progress.dart';

class MockPairingRemoteDataSource extends Mock
    implements PairingRemoteDataSource {}

class MockBlePairingDataSource extends Mock implements BlePairingDataSource {}

class MockProductCatalogCache extends Mock implements ProductCatalogCache {}

class MockBleSessionStore extends Mock implements BleSessionStore {}

void main() {
  late MockPairingRemoteDataSource remote;
  late MockBlePairingDataSource ble;
  late MockProductCatalogCache cache;
  late MockBleSessionStore bleSessionStore;
  late PairingRepositoryImpl repository;
  String smartHomeId = 'home-1';

  const product = OspreyProductModel(
    id: 'prod-1',
    productCode: 'OSPREY_CURTAIN_V1',
    productType: 1,
    productIdHashHex: 'a0ce10',
    displayName: 'Smart Curtain Track',
    iconUrl: '',
    category: 'CURTAIN',
    deviceProfileId: 'dp-1',
  );

  const advData = OspreyAdvData(
    isPaired: false,
    isEncrypted: false,
    protocolVersion: 0,
    productType: 1,
    productIdHashHex: 'a0ce10',
  );

  const device = DiscoveredOspreyDevice(
    remoteId: 'AA:BB:CC:DD:EE:FF',
    name: 'Osprey-CR-EEFF',
    rssi: -50,
    advData: advData,
    product: product,
  );

  // Session key 32 bytes hex (reference value từ handoff §3)
  const sessionKeyHex =
      '08df2a1f3972b6157fbbc66434f520d5ba24d64657fe66d0fc2f784d097a9bfa';

  const authResponse = AuthChallengeResponseModel(
    hmacExpectedHex:
        '3dde8f263a33d1c9b077e2caa9851d2e6722e4db5dabfbd835dc33a03b048513',
    sessionKeyHex: sessionKeyHex,
    tbProvisionKey: 'OSPREY_CURTAIN_V1',
    tbProvisionSecret: 'secret',
    deviceProfileId: 'dp-1',
  );

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(
      BleSession(sessionKey: Uint8List(32), ospreyUuid: '', counter: 0),
    );
  });

  setUp(() {
    remote = MockPairingRemoteDataSource();
    ble = MockBlePairingDataSource();
    cache = MockProductCatalogCache();
    bleSessionStore = MockBleSessionStore();
    smartHomeId = 'home-1';
    when(() => bleSessionStore.save(any(), any())).thenAnswer((_) async {});
    repository = PairingRepositoryImpl(
      remoteDataSource: remote,
      bleDataSource: ble,
      catalogCache: cache,
      crypto: PairingCrypto(), // crypto thật — deterministic, đã có golden test
      bleSessionStore: bleSessionStore,
      getSmartHomeId: () => smartHomeId,
    );
  });

  void stubHappyPath() {
    when(() => ble.openSession(any())).thenAnswer((_) async {});
    when(() => ble.readDeviceUuid()).thenAnswer(
        (_) async => 'f89d9d07-6664-4000-8000-f89d9d076664');
    when(() => ble.writeAuthChallengeAndAwaitOk(any()))
        .thenAnswer((_) async {});
    when(() => ble.writePairingDataAndAwaitOk(any()))
        .thenAnswer((_) async {});
    when(() => ble.closeSession()).thenAnswer((_) async {});
    when(() => remote.requestAuthChallenge(
          deviceUuid: any(named: 'deviceUuid'),
          nonceAppHex: any(named: 'nonceAppHex'),
        )).thenAnswer((_) async => authResponse);
    when(() => remote.createPairingToken(
          deviceProfileId: any(named: 'deviceProfileId'),
          smartHomeId: any(named: 'smartHomeId'),
          roomId: any(named: 'roomId'),
          deviceUuid: any(named: 'deviceUuid'),
        )).thenAnswer((_) async =>
        const PairingTokenModel(token: 'ABCD1234', status: 'PENDING'));
    when(() => remote.getPairingTokenStatus('ABCD1234')).thenAnswer(
        (_) async => const PairingTokenModel(
            token: 'ABCD1234', status: 'PAIRED', deviceId: 'dev-99'));
  }

  group('pairDevice', () {
    test('happy path: emit đủ 6 bước theo thứ tự spec §4.2', () async {
      stubHappyPath();

      final steps = await repository
          .pairDevice(device: device, ssid: 'MyWiFi', wifiPassword: 'pw')
          .toList();

      // Option 2: connect + READ DEVICE_UUID trước (disarm watchdog),
      // backend sau.
      expect(steps, const [
        PairingProgress(PairingStep.connecting),
        PairingProgress(PairingStep.requestingToken),
        PairingProgress(PairingStep.authenticating),
        PairingProgress(PairingStep.sendingWifiCredentials),
        PairingProgress(PairingStep.waitingForDevice),
        PairingProgress(PairingStep.done, deviceId: 'dev-99'),
      ]);

      // deviceUuid gửi backend phải là UUID đọc từ GATT char
      verify(() => remote.requestAuthChallenge(
            deviceUuid: 'f89d9d07-6664-4000-8000-f89d9d076664',
            nonceAppHex: any(named: 'nonceAppHex'),
          )).called(1);

      // AUTH_CHALLENGE đúng 48 bytes
      final captured = verify(
              () => ble.writeAuthChallengeAndAwaitOk(captureAny()))
          .captured
          .single as Uint8List;
      expect(captured.length, 48);

      // PAIRING_DATA = ciphertext + tag 16 bytes
      final cipher =
          verify(() => ble.writePairingDataAndAwaitOk(captureAny()))
              .captured
              .single as Uint8List;
      expect(cipher.length, greaterThan(16));

      // BLE session đóng trước khi poll
      verify(() => ble.closeSession()).called(1);
    });

    test('firmware cũ không có char DEVICE_UUID → lỗi rõ, không gọi backend',
        () async {
      stubHappyPath();
      when(() => ble.readDeviceUuid()).thenThrow(BlePairingException(
          'Firmware thiết bị quá cũ — thiếu characteristic DEVICE_UUID'));

      await expectLater(
        repository.pairDevice(
            device: device, ssid: 'MyWiFi', wifiPassword: 'pw'),
        emitsInOrder([
          const PairingProgress(PairingStep.connecting),
          emitsError(isA<ServerFailure>()),
        ]),
      );
      verifyNever(() => remote.requestAuthChallenge(
            deviceUuid: any(named: 'deviceUuid'),
            nonceAppHex: any(named: 'nonceAppHex'),
          ));
      verify(() => ble.closeSession()).called(greaterThanOrEqualTo(1));
    });

    test('AUTH_FAIL từ device → ServerFailure + đóng session', () async {
      stubHappyPath();
      when(() => ble.writeAuthChallengeAndAwaitOk(any())).thenThrow(
          BlePairingException('Xác thực thiết bị thất bại',
              statusCode: 0x02));

      await expectLater(
        repository.pairDevice(
            device: device, ssid: 'MyWiFi', wifiPassword: 'pw'),
        emitsInOrder([
          const PairingProgress(PairingStep.connecting),
          const PairingProgress(PairingStep.requestingToken),
          const PairingProgress(PairingStep.authenticating),
          emitsError(isA<ServerFailure>()),
        ]),
      );
      verify(() => ble.closeSession()).called(greaterThanOrEqualTo(1));
    });

    test('chưa chọn nhà (homeId rỗng) → lỗi rõ ràng', () async {
      stubHappyPath();
      smartHomeId = '';

      await expectLater(
        repository.pairDevice(
            device: device, ssid: 'MyWiFi', wifiPassword: 'pw'),
        emitsThrough(emitsError(isA<ServerFailure>())),
      );
    });

    test('token EXPIRED khi poll → lỗi hết hạn', () async {
      stubHappyPath();
      when(() => remote.getPairingTokenStatus('ABCD1234')).thenAnswer(
          (_) async => const PairingTokenModel(
              token: 'ABCD1234', status: 'EXPIRED'));

      await expectLater(
        repository.pairDevice(
            device: device, ssid: 'MyWiFi', wifiPassword: 'pw'),
        emitsThrough(emitsError(isA<ServerFailure>())),
      );
    });

    test('401 từ backend → UnauthorizedFailure', () async {
      stubHappyPath();
      when(() => remote.requestAuthChallenge(
            deviceUuid: any(named: 'deviceUuid'),
            nonceAppHex: any(named: 'nonceAppHex'),
          )).thenThrow(UnauthorizedException());

      await expectLater(
        repository.pairDevice(
            device: device, ssid: 'MyWiFi', wifiPassword: 'pw'),
        emitsThrough(emitsError(isA<UnauthorizedFailure>())),
      );
    });
  });

  group('getProductCatalog', () {
    test('cache fresh → không gọi backend', () async {
      when(() => cache.getFresh()).thenReturn([product]);

      final result = await repository.getProductCatalog();

      expect(result.getOrElse(() => []), [product]);
      verifyNever(() => remote.getProducts());
    });

    test('cache miss → fetch backend + save cache', () async {
      when(() => cache.getFresh()).thenReturn(null);
      when(() => remote.getProducts()).thenAnswer((_) async => [product]);
      when(() => cache.save(any())).thenAnswer((_) async {});

      final result = await repository.getProductCatalog();

      expect(result.isRight(), true);
      verify(() => cache.save([product])).called(1);
    });

    test('backend lỗi → fallback cache cũ (stale)', () async {
      when(() => cache.getFresh()).thenReturn(null);
      when(() => remote.getProducts())
          .thenThrow(ServerException(message: 'offline'));
      when(() => cache.getStale()).thenReturn([product]);

      final result = await repository.getProductCatalog();

      expect(result.isRight(), true);
    });

    test('backend lỗi + không có cache → Left(ServerFailure)', () async {
      when(() => cache.getFresh()).thenReturn(null);
      when(() => remote.getProducts())
          .thenThrow(ServerException(message: 'offline'));
      when(() => cache.getStale()).thenReturn(null);

      final result = await repository.getProductCatalog();

      expect(result.isLeft(), true);
    });
  });

  group('scanForDevices', () {
    ScanResult buildScanResult({
      required List<int> manufacturerBytes,
      String name = 'Osprey-CR-A1B2',
      int rssi = -50,
      DateTime? timeStamp,
    }) {
      return ScanResult(
        device: BluetoothDevice.fromId('AA:BB:CC:DD:EE:FF'),
        advertisementData: AdvertisementData(
          advName: name,
          txPowerLevel: 4,
          appearance: null,
          connectable: true,
          manufacturerData: {0xFFFF: manufacturerBytes},
          serviceData: const {},
          serviceUuids: const [],
        ),
        rssi: rssi,
        timeStamp: timeStamp ?? DateTime.now(),
      );
    }

    setUp(() async {
      // Nạp catalog vào RAM của repository
      when(() => cache.getFresh()).thenReturn([product]);
      await repository.getProductCatalog();
    });

    test('match product theo hash + giữ device pairable', () async {
      when(() => ble.scanResults).thenAnswer((_) => Stream.value([
            buildScanResult(
                manufacturerBytes: [0x00, 0x00, 0x01, 0xA0, 0xCE, 0x10]),
          ]));

      final devices = await repository.scanForDevices().first;

      expect(devices.length, 1);
      expect(devices.first.product, product);
      expect(devices.first.displayName, 'Smart Curtain Track');
      expect(devices.first.macSuffix, 'A1B2');
    });

    test('device đã paired (bit 0 = 1) bị skip', () async {
      when(() => ble.scanResults).thenAnswer((_) => Stream.value([
            buildScanResult(
                manufacturerBytes: [0x01, 0x00, 0x01, 0xA0, 0xCE, 0x10]),
          ]));

      final devices = await repository.scanForDevices().first;

      expect(devices, isEmpty);
    });

    test('manufacturer data không phải Osprey bị skip', () async {
      when(() => ble.scanResults).thenAnswer((_) => Stream.value([
            buildScanResult(manufacturerBytes: [0x00, 0x01]), // quá ngắn
          ]));

      final devices = await repository.scanForDevices().first;

      expect(devices, isEmpty);
    });

    test('sort theo RSSI mạnh trước', () async {
      when(() => remote.getProductByHash(any()))
          .thenAnswer((_) async => null);
      when(() => ble.scanResults).thenAnswer((_) => Stream.value([
            buildScanResult(
                manufacturerBytes: [0x00, 0x00, 0x01, 0xA0, 0xCE, 0x10],
                rssi: -80,
                name: 'Osprey-CR-1111'),
            buildScanResult(
                manufacturerBytes: [0x00, 0x00, 0x01, 0xA0, 0xCE, 0x10],
                rssi: -40,
                name: 'Osprey-CR-2222'),
          ]));

      final devices = await repository.scanForDevices().first;

      expect(devices.length, 2);
      expect(devices.first.rssi, -40);
    });

    test('kết quả scan cũ hơn scanStaleAfter bị lọc bỏ (entry stale)',
        () async {
      when(() => ble.scanResults).thenAnswer((_) => Stream.value([
            // Advertisement cuối cùng thấy từ 20s trước — device đã tắt
            // hoặc rời pairing mode, bấm vào chỉ ăn connect timeout.
            buildScanResult(
              manufacturerBytes: [0x00, 0x00, 0x01, 0xA0, 0xCE, 0x10],
              timeStamp:
                  DateTime.now().subtract(const Duration(seconds: 20)),
            ),
          ]));

      final devices = await repository.scanForDevices().first;

      expect(devices, isEmpty);
    });

    test('kết quả scan mới (trong ngưỡng stale) vẫn hiển thị', () async {
      when(() => ble.scanResults).thenAnswer((_) => Stream.value([
            buildScanResult(
              manufacturerBytes: [0x00, 0x00, 0x01, 0xA0, 0xCE, 0x10],
              timeStamp:
                  DateTime.now().subtract(const Duration(seconds: 5)),
            ),
          ]));

      final devices = await repository.scanForDevices().first;

      expect(devices.length, 1);
    });
  });

  group('pairDevice — retry connect', () {
    test('connect fail 2 lần đầu → tự retry và pair thành công', () async {
      stubHappyPath();
      var attempts = 0;
      when(() => ble.openSession(any())).thenAnswer((_) async {
        attempts++;
        if (attempts < 3) {
          throw BlePairingException('Could not connect: timed out');
        }
      });

      final steps = await repository
          .pairDevice(device: device, ssid: 'MyWiFi', wifiPassword: 'pw')
          .toList();

      expect(steps.last.step, PairingStep.done);
      verify(() => ble.openSession(any())).called(3);
    });

    test('connect fail cả 3 lần → báo lỗi, không retry thêm', () async {
      stubHappyPath();
      when(() => ble.openSession(any())).thenThrow(
          BlePairingException('Could not connect: timed out'));

      await expectLater(
        repository.pairDevice(
            device: device, ssid: 'MyWiFi', wifiPassword: 'pw'),
        emitsInOrder([
          const PairingProgress(PairingStep.connecting),
          emitsError(isA<ServerFailure>()),
        ]),
      );
      verify(() => ble.openSession(any())).called(3);
    });
  });

  group('pairDevice — poll PAIRED chịu lỗi mạng lẻ', () {
    test('1 request rớt giữa lúc chờ device → poll tiếp, pair vẫn thành công',
        () async {
      stubHappyPath();
      var calls = 0;
      when(() => remote.getPairingTokenStatus('ABCD1234'))
          .thenAnswer((_) async {
        calls++;
        if (calls == 1) throw ServerException(message: 'network blip');
        return const PairingTokenModel(
            token: 'ABCD1234', status: 'PAIRED', deviceId: 'dev-99');
      });

      final steps = await repository
          .pairDevice(device: device, ssid: 'MyWiFi', wifiPassword: 'pw')
          .toList();

      expect(steps.last.step, PairingStep.done);
      verify(() => remote.getPairingTokenStatus('ABCD1234')).called(2);
    });

    test('401 trong lúc poll → fail ngay, không được nuốt', () async {
      stubHappyPath();
      when(() => remote.getPairingTokenStatus('ABCD1234'))
          .thenThrow(UnauthorizedException());

      await expectLater(
        repository.pairDevice(
            device: device, ssid: 'MyWiFi', wifiPassword: 'pw'),
        emitsThrough(emitsError(isA<UnauthorizedFailure>())),
      );
    });
  });
}
