import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:smart_curtain_app/core/error/failure.dart';
import 'package:smart_curtain_app/features/device/domain/entities/device_entity.dart';
import 'package:smart_curtain_app/features/device/domain/usecases/delete_device.dart';
import 'package:smart_curtain_app/features/device/domain/usecases/get_customer_devices.dart';
import 'package:smart_curtain_app/features/device/presentation/bloc/device_bloc.dart';
import 'package:smart_curtain_app/features/device/presentation/bloc/device_event.dart';
import 'package:smart_curtain_app/features/device/presentation/bloc/device_state.dart';

class _MockGetCustomerDevices extends Mock implements GetCustomerDevices {}

class _MockDeleteDevice extends Mock implements DeleteDevice {}

void main() {
  late _MockGetCustomerDevices getCustomerDevices;
  late _MockDeleteDevice deleteDevice;

  setUp(() {
    getCustomerDevices = _MockGetCustomerDevices();
    deleteDevice = _MockDeleteDevice();
  });

  DeviceBloc buildBloc() => DeviceBloc(
        getCustomerDevices: getCustomerDevices,
        deleteDevice: deleteDevice,
      );

  const tDeviceA = DeviceEntity(
    id: 'dev-a',
    name: 'Curtain A',
    type: 'curtain',
    status: 'online',
  );
  const tDeviceB = DeviceEntity(
    id: 'dev-b',
    name: 'Curtain B',
    type: 'curtain',
    status: 'offline',
  );

  group('initial state', () {
    test('is DeviceInitial', () {
      expect(buildBloc().state, isA<DeviceInitial>());
    });
  });

  group('LoadDevicesEvent', () {
    blocTest<DeviceBloc, DeviceState>(
      'emits [DeviceLoading, DeviceLoaded] when use case returns Right',
      build: () {
        when(() => getCustomerDevices()).thenAnswer(
          (_) async => const Right<Failure, List<DeviceEntity>>(
            [tDeviceA, tDeviceB],
          ),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(LoadDevicesEvent()),
      expect: () => [
        isA<DeviceLoading>(),
        const DeviceLoaded([tDeviceA, tDeviceB]),
      ],
    );

    blocTest<DeviceBloc, DeviceState>(
      'emits [DeviceLoading, DeviceError] when use case returns Left',
      build: () {
        when(() => getCustomerDevices()).thenAnswer(
          (_) async => const Left(ServerFailure('err', message: 'API down')),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(LoadDevicesEvent()),
      expect: () => [
        isA<DeviceLoading>(),
        isA<DeviceError>().having((s) => s.message, 'message', 'API down'),
      ],
    );

    blocTest<DeviceBloc, DeviceState>(
      'emits DeviceLoaded with empty list when no devices exist',
      build: () {
        when(() => getCustomerDevices()).thenAnswer(
          (_) async => const Right<Failure, List<DeviceEntity>>([]),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(LoadDevicesEvent()),
      expect: () => [
        isA<DeviceLoading>(),
        const DeviceLoaded([]),
      ],
    );
  });

  group('RefreshDevicesEvent', () {
    blocTest<DeviceBloc, DeviceState>(
      'emits DeviceLoaded directly without DeviceLoading',
      build: () {
        when(() => getCustomerDevices()).thenAnswer(
          (_) async => const Right<Failure, List<DeviceEntity>>([tDeviceA]),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(RefreshDevicesEvent()),
      expect: () => [
        const DeviceLoaded([tDeviceA]),
      ],
    );

    blocTest<DeviceBloc, DeviceState>(
      'emits DeviceError when refresh fails',
      build: () {
        when(() => getCustomerDevices()).thenAnswer(
          (_) async =>
              const Left(NetworkFailure('err', message: 'No internet')),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(RefreshDevicesEvent()),
      expect: () => [isA<DeviceError>()],
    );
  });

  group('DeleteDeviceEvent', () {
    blocTest<DeviceBloc, DeviceState>(
      'removes device from loaded list on success',
      build: () {
        when(() => deleteDevice('dev-a')).thenAnswer(
          (_) async => const Right<Failure, void>(null),
        );
        return buildBloc();
      },
      seed: () => const DeviceLoaded([tDeviceA, tDeviceB]),
      act: (bloc) => bloc.add(const DeleteDeviceEvent('dev-a')),
      expect: () => [
        const DeviceLoaded([tDeviceB]),
      ],
    );

    blocTest<DeviceBloc, DeviceState>(
      'emits DeviceError when delete fails',
      build: () {
        when(() => deleteDevice(any())).thenAnswer(
          (_) async => const Left(ServerFailure('err', message: 'denied')),
        );
        return buildBloc();
      },
      seed: () => const DeviceLoaded([tDeviceA]),
      act: (bloc) => bloc.add(const DeleteDeviceEvent('dev-a')),
      expect: () => [isA<DeviceError>()],
    );

    blocTest<DeviceBloc, DeviceState>(
      'is a no-op when state is not DeviceLoaded',
      build: () => buildBloc(),
      act: (bloc) => bloc.add(const DeleteDeviceEvent('dev-a')),
      expect: () => <DeviceState>[],
      verify: (_) {
        verifyNever(() => deleteDevice(any()));
      },
    );
  });
}
