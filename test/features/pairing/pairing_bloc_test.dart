import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_curtain_app/core/error/failure.dart';
import 'package:smart_curtain_app/features/pairing/domain/entities/discovered_osprey_device.dart';
import 'package:smart_curtain_app/features/pairing/domain/entities/osprey_adv_data.dart';
import 'package:smart_curtain_app/features/pairing/domain/entities/pairing_progress.dart';
import 'package:smart_curtain_app/features/pairing/domain/usecases/pair_osprey_device.dart';
import 'package:smart_curtain_app/features/pairing/presentation/bloc/pairing_bloc.dart';
import 'package:smart_curtain_app/features/pairing/presentation/bloc/pairing_event.dart';
import 'package:smart_curtain_app/features/pairing/presentation/bloc/pairing_state.dart';

class MockPairOspreyDevice extends Mock implements PairOspreyDevice {}

void main() {
  late MockPairOspreyDevice pairDevice;

  const device = DiscoveredOspreyDevice(
    remoteId: 'AA:BB:CC:DD:EE:FF',
    name: 'Osprey-CR-EEFF',
    rssi: -50,
    advData: OspreyAdvData(
      isPaired: false,
      isEncrypted: false,
      protocolVersion: 0,
      productType: 1,
      productIdHashHex: 'a0ce10',
    ),
  );

  setUp(() {
    pairDevice = MockPairOspreyDevice();
  });

  void stubPairStream(Stream<PairingProgress> stream) {
    when(() => pairDevice(
          device: any(named: 'device'),
          ssid: any(named: 'ssid'),
          wifiPassword: any(named: 'wifiPassword'),
          roomId: any(named: 'roomId'),
        )).thenAnswer((_) => stream);
  }

  setUpAll(() {
    registerFallbackValue(device);
  });

  group('PairingBloc', () {
    blocTest<PairingBloc, PairingState>(
      'happy path: progress qua từng bước → PairingSuccess',
      build: () {
        stubPairStream(Stream.fromIterable(const [
          PairingProgress(PairingStep.connecting),
          PairingProgress(PairingStep.requestingToken),
          PairingProgress(PairingStep.authenticating),
          PairingProgress(PairingStep.sendingWifiCredentials),
          PairingProgress(PairingStep.waitingForDevice),
          PairingProgress(PairingStep.done, deviceId: 'dev-99'),
        ]));
        return PairingBloc(pairDevice: pairDevice);
      },
      act: (bloc) => bloc.add(const StartPairingEvent(
          device: device, ssid: 'MyWiFi', wifiPassword: 'pw')),
      expect: () => const [
        PairingInProgress(PairingStep.connecting),
        PairingInProgress(PairingStep.requestingToken),
        PairingInProgress(PairingStep.authenticating),
        PairingInProgress(PairingStep.sendingWifiCredentials),
        PairingInProgress(PairingStep.waitingForDevice),
        PairingSuccess('dev-99'),
      ],
    );

    blocTest<PairingBloc, PairingState>(
      'stream lỗi → PairingFailure với message từ Failure + bước đang chạy',
      build: () {
        stubPairStream(
          () async* {
            yield const PairingProgress(PairingStep.connecting);
            yield const PairingProgress(PairingStep.requestingToken);
            yield const PairingProgress(PairingStep.authenticating);
            throw const ServerFailure('x',
                message: 'Xác thực thiết bị thất bại');
          }(),
        );
        return PairingBloc(pairDevice: pairDevice);
      },
      act: (bloc) => bloc.add(const StartPairingEvent(
          device: device, ssid: 'MyWiFi', wifiPassword: 'pw')),
      expect: () => const [
        PairingInProgress(PairingStep.connecting),
        PairingInProgress(PairingStep.requestingToken),
        PairingInProgress(PairingStep.authenticating),
        PairingFailure('Xác thực thiết bị thất bại',
            failedAtStep: PairingStep.authenticating),
      ],
    );

    blocTest<PairingBloc, PairingState>(
      'ResetPairingEvent → quay về PairingInitial',
      build: () => PairingBloc(pairDevice: pairDevice),
      seed: () => const PairingFailure('lỗi'),
      act: (bloc) => bloc.add(const ResetPairingEvent()),
      expect: () => [isA<PairingInitial>()],
    );
  });
}
