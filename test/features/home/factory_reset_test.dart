import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_curtain_app/core/error/exceptions.dart';
import 'package:smart_curtain_app/core/error/failure.dart';
import 'package:smart_curtain_app/features/home/data/datasources/home_remote_datasource.dart';
import 'package:smart_curtain_app/features/home/data/models/factory_reset_result_model.dart';
import 'package:smart_curtain_app/features/home/data/repositories/home_repository_impl.dart';

class MockHomeRemoteDataSource extends Mock implements HomeRemoteDataSource {}

void main() {
  group('FactoryResetResultModel', () {
    test('fromJson parse đầy đủ field (spec response)', () {
      final model = FactoryResetResultModel.fromJson({
        'status': 'OK',
        'deviceWasOnline': true,
        'deviceUuid': 'f89d9d07-6664-4000-8000-f89d9d076664',
        'cleanedUpAt': 1780000000000,
      });
      expect(model.deviceWasOnline, true);
      expect(model.deviceUuid, 'f89d9d07-6664-4000-8000-f89d9d076664');
    });

    test('fromJson default an toàn khi thiếu field', () {
      final model = FactoryResetResultModel.fromJson(const {});
      expect(model.deviceWasOnline, false);
      expect(model.deviceUuid, '');
    });
  });

  group('HomeRepositoryImpl — gỡ thiết bị', () {
    late MockHomeRemoteDataSource ds;
    late HomeRepositoryImpl repo;
    const homeId = 'home-1';
    const deviceId = 'dev-1';

    setUp(() {
      ds = MockHomeRemoteDataSource();
      repo = HomeRepositoryImpl(remoteDataSource: ds);
    });

    group('Nút 1 — removeDeviceFromHome (DELETE)', () {
      test('success → Right(null)', () async {
        when(() => ds.removeDeviceFromHome(homeId, deviceId))
            .thenAnswer((_) async {});

        final result =
            await repo.removeDeviceFromHome(homeId: homeId, deviceId: deviceId);

        expect(result.isRight(), true);
        verify(() => ds.removeDeviceFromHome(homeId, deviceId)).called(1);
      });

      test('401 → UnauthorizedFailure', () async {
        when(() => ds.removeDeviceFromHome(homeId, deviceId))
            .thenThrow(UnauthorizedException());

        final result =
            await repo.removeDeviceFromHome(homeId: homeId, deviceId: deviceId);

        expect(result.fold((l) => l, (r) => null), isA<UnauthorizedFailure>());
      });

      test('403/404/500 → ServerFailure giữ message', () async {
        when(() => ds.removeDeviceFromHome(homeId, deviceId)).thenThrow(
            ServerException(message: 'Bạn không có quyền ngắt kết nối'));

        final result =
            await repo.removeDeviceFromHome(homeId: homeId, deviceId: deviceId);

        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<ServerFailure>());
        expect(failure!.message, contains('không có quyền'));
      });
    });

    group('Nút 2 — factoryResetDevice (POST)', () {
      const resultModel = FactoryResetResultModel(
        deviceWasOnline: true,
        deviceUuid: 'f89d9d07-6664-4000-8000-f89d9d076664',
      );

      test('success → Right(FactoryResetResult) giữ deviceWasOnline', () async {
        when(() => ds.factoryResetDevice(homeId, deviceId))
            .thenAnswer((_) async => resultModel);

        final result =
            await repo.factoryResetDevice(homeId: homeId, deviceId: deviceId);

        expect(result.isRight(), true);
        expect(result.fold((l) => null, (r) => r.deviceWasOnline), true);
        verify(() => ds.factoryResetDevice(homeId, deviceId)).called(1);
      });

      test('401 → UnauthorizedFailure', () async {
        when(() => ds.factoryResetDevice(homeId, deviceId))
            .thenThrow(UnauthorizedException());

        final result =
            await repo.factoryResetDevice(homeId: homeId, deviceId: deviceId);

        expect(result.fold((l) => l, (r) => r), isA<UnauthorizedFailure>());
      });

      test('500 → ServerFailure', () async {
        when(() => ds.factoryResetDevice(homeId, deviceId)).thenThrow(
            ServerException(message: 'Máy chủ gặp lỗi — vui lòng thử lại'));

        final result =
            await repo.factoryResetDevice(homeId: homeId, deviceId: deviceId);

        expect(result.fold((l) => l, (r) => r), isA<ServerFailure>());
      });
    });
  });
}
