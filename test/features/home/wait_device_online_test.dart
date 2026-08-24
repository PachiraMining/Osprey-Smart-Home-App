import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:smart_curtain_app/core/di/injector.dart';
import 'package:smart_curtain_app/core/widget/home_widget_service.dart';
import 'package:smart_curtain_app/features/home/data/datasources/home_remote_datasource.dart';
import 'package:smart_curtain_app/features/home/domain/entities/home_device_entity.dart';
import 'package:smart_curtain_app/features/home/domain/usecases/add_device_to_home.dart';
import 'package:smart_curtain_app/features/home/domain/usecases/create_home.dart';
import 'package:smart_curtain_app/features/home/domain/usecases/create_room.dart';
import 'package:smart_curtain_app/features/home/domain/usecases/delete_home.dart';
import 'package:smart_curtain_app/features/home/domain/usecases/delete_room.dart';
import 'package:smart_curtain_app/features/home/domain/usecases/factory_reset_device.dart';
import 'package:smart_curtain_app/features/home/domain/usecases/get_home_devices.dart';
import 'package:smart_curtain_app/features/home/domain/usecases/get_homes.dart';
import 'package:smart_curtain_app/features/home/domain/usecases/get_rooms.dart';
import 'package:smart_curtain_app/features/home/domain/usecases/remove_device_from_home.dart';
import 'package:smart_curtain_app/features/home/domain/usecases/update_home.dart';
import 'package:smart_curtain_app/features/home/domain/usecases/update_home_device.dart';
import 'package:smart_curtain_app/features/home/domain/usecases/update_room.dart';
import 'package:smart_curtain_app/features/home/presentation/bloc/home_management_bloc.dart';
import 'package:smart_curtain_app/features/home/presentation/bloc/home_management_event.dart';

class _MockGetHomes extends Mock implements GetHomes {}

class _MockCreateHome extends Mock implements CreateHome {}

class _MockUpdateHome extends Mock implements UpdateHome {}

class _MockDeleteHome extends Mock implements DeleteHome {}

class _MockGetHomeDevices extends Mock implements GetHomeDevices {}

class _MockAddDeviceToHome extends Mock implements AddDeviceToHome {}

class _MockUpdateHomeDevice extends Mock implements UpdateHomeDevice {}

class _MockRemoveDeviceFromHome extends Mock implements RemoveDeviceFromHome {}

class _MockFactoryResetDevice extends Mock implements FactoryResetDevice {}

class _MockGetRooms extends Mock implements GetRooms {}

class _MockCreateRoom extends Mock implements CreateRoom {}

class _MockUpdateRoom extends Mock implements UpdateRoom {}

class _MockDeleteRoom extends Mock implements DeleteRoom {}

class _MockHomeRemoteDataSource extends Mock implements HomeRemoteDataSource {}

class _MockHomeWidgetService extends Mock implements HomeWidgetService {}

/// In-memory HydratedStorage để bloc dùng HydratedMixin chạy được trong test.
class _InMemoryStorage implements Storage {
  final _data = <String, dynamic>{};
  @override
  dynamic read(String key) => _data[key];
  @override
  Future<void> write(String key, dynamic value) async => _data[key] = value;
  @override
  Future<void> delete(String key) async => _data.remove(key);
  @override
  Future<void> clear() async => _data.clear();
  @override
  Future<void> close() async {}
}

void main() {
  const homeId = 'home-1';
  const deviceId = 'dev-new';

  const device = HomeDeviceEntity(
    id: 'rel-1',
    smartHomeId: homeId,
    deviceId: deviceId,
    deviceName: 'Rèm mới',
  );

  late _MockGetHomeDevices getHomeDevices;
  late _MockHomeRemoteDataSource dataSource;

  setUpAll(() {
    HydratedBloc.storage = _InMemoryStorage();
    registerFallbackValue(const <WidgetDevice>[]);
  });

  HomeManagementBloc buildBloc() => HomeManagementBloc(
        getHomes: _MockGetHomes(),
        createHome: _MockCreateHome(),
        updateHome: _MockUpdateHome(),
        deleteHome: _MockDeleteHome(),
        getHomeDevices: getHomeDevices,
        addDeviceToHome: _MockAddDeviceToHome(),
        updateHomeDevice: _MockUpdateHomeDevice(),
        removeDeviceFromHome: _MockRemoveDeviceFromHome(),
        factoryResetDevice: _MockFactoryResetDevice(),
        getRooms: _MockGetRooms(),
        createRoom: _MockCreateRoom(),
        updateRoom: _MockUpdateRoom(),
        deleteRoom: _MockDeleteRoom(),
        homeRemoteDataSource: dataSource,
      );

  setUp(() async {
    await HydratedBloc.storage.clear();
    getHomeDevices = _MockGetHomeDevices();
    dataSource = _MockHomeRemoteDataSource();

    when(() => getHomeDevices(homeId))
        .thenAnswer((_) async => const Right([device]));

    if (sl.isRegistered<HomeWidgetService>()) {
      sl.unregister<HomeWidgetService>();
    }
    final widgetService = _MockHomeWidgetService();
    when(() => widgetService.pushDevices(any())).thenAnswer((_) async {});
    sl.registerLazySingleton<HomeWidgetService>(() => widgetService);
  });

  tearDown(() {
    if (sl.isRegistered<HomeWidgetService>()) {
      sl.unregister<HomeWidgetService>();
    }
  });

  group('WaitDeviceOnlineEvent — poll active sau khi pair', () {
    test('active=false rồi active=true → patch isOnline=true vào state',
        () async {
      var calls = 0;
      when(() => dataSource.getDeviceInfo(deviceId)).thenAnswer((_) async {
        calls++;
        return {'name': 'Rèm mới', 'active': calls >= 3};
      });

      final bloc = buildBloc();
      bloc.add(const LoadHomeDevicesEvent(homeId));
      await bloc.stream
          .firstWhere((s) => s.devices.isNotEmpty)
          .timeout(const Duration(seconds: 5));
      expect(bloc.state.devices.single.isOnline, false);

      bloc.add(const WaitDeviceOnlineEvent(
        deviceId,
        interval: Duration(milliseconds: 1),
      ));
      await bloc.stream
          .firstWhere((s) => s.devices.single.isOnline == true)
          .timeout(const Duration(seconds: 5));

      expect(bloc.state.devices.single.isOnline, true);
      await bloc.close();
    });

    test('không bao giờ active → dừng sau maxAttempts, state giữ offline',
        () async {
      when(() => dataSource.getDeviceInfo(deviceId))
          .thenAnswer((_) async => {'name': 'Rèm mới', 'active': false});

      final bloc = buildBloc();
      bloc.add(const LoadHomeDevicesEvent(homeId));
      await bloc.stream
          .firstWhere((s) => s.devices.isNotEmpty)
          .timeout(const Duration(seconds: 5));

      bloc.add(const WaitDeviceOnlineEvent(
        deviceId,
        interval: Duration(milliseconds: 1),
        maxAttempts: 3,
      ));
      // 1 lần enrich của LoadHomeDevices + đúng 3 lần poll.
      await Future<void>.delayed(const Duration(milliseconds: 200));

      verify(() => dataSource.getDeviceInfo(deviceId)).called(1 + 3);
      expect(bloc.state.devices.single.isOnline, false);
      await bloc.close();
    });

    test('lỗi mạng giữa chừng được nuốt và poll tiếp cho tới khi active',
        () async {
      var polls = 0;
      when(() => dataSource.getDeviceInfo(deviceId)).thenAnswer((_) async {
        polls++;
        if (polls == 1) return {'name': 'Rèm mới', 'active': false}; // enrich
        if (polls == 2) throw Exception('timeout');
        return {'name': 'Rèm mới', 'active': true};
      });

      final bloc = buildBloc();
      bloc.add(const LoadHomeDevicesEvent(homeId));
      await bloc.stream
          .firstWhere((s) => s.devices.isNotEmpty)
          .timeout(const Duration(seconds: 5));

      bloc.add(const WaitDeviceOnlineEvent(
        deviceId,
        interval: Duration(milliseconds: 1),
      ));
      await bloc.stream
          .firstWhere((s) => s.devices.single.isOnline == true)
          .timeout(const Duration(seconds: 5));

      expect(bloc.state.devices.single.isOnline, true);
      await bloc.close();
    });
  });

  group('WaitDeviceOnlineEvent — optimistic (hiện online ngay)', () {
    test('online ngay khi thiết bị có trong list, TB confirm sau → giữ online',
        () async {
      var calls = 0;
      when(() => dataSource.getDeviceInfo(deviceId)).thenAnswer((_) async {
        calls++;
        return {'name': 'Rèm mới', 'active': calls >= 2};
      });

      final bloc = buildBloc();
      bloc.add(const LoadHomeDevicesEvent(homeId));
      await bloc.stream
          .firstWhere((s) => s.devices.isNotEmpty)
          .timeout(const Duration(seconds: 5));
      expect(bloc.state.devices.single.isOnline, false);

      bloc.add(const WaitDeviceOnlineEvent(
        deviceId,
        interval: Duration(milliseconds: 1),
        optimistic: true,
      ));
      // Optimistic: phải online NGAY, trước cả khi poll xác nhận.
      await bloc.stream
          .firstWhere((s) => s.devices.single.isOnline == true)
          .timeout(const Duration(seconds: 5));

      // Chờ vòng poll xác nhận chạy xong — vẫn phải giữ online.
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(bloc.state.devices.single.isOnline, true);
      await bloc.close();
    });

    test('optimistic nhưng TB không bao giờ confirm → trả về offline',
        () async {
      when(() => dataSource.getDeviceInfo(deviceId))
          .thenAnswer((_) async => {'name': 'Rèm mới', 'active': false});

      final bloc = buildBloc();
      bloc.add(const LoadHomeDevicesEvent(homeId));
      await bloc.stream
          .firstWhere((s) => s.devices.isNotEmpty)
          .timeout(const Duration(seconds: 5));

      bloc.add(const WaitDeviceOnlineEvent(
        deviceId,
        interval: Duration(milliseconds: 1),
        maxAttempts: 2,
        optimistic: true,
      ));
      // Lên online optimistic trước…
      await bloc.stream
          .firstWhere((s) => s.devices.single.isOnline == true)
          .timeout(const Duration(seconds: 5));
      // …rồi hết maxAttempts không confirm → revert về offline.
      await bloc.stream
          .firstWhere((s) => s.devices.single.isOnline == false)
          .timeout(const Duration(seconds: 5));

      expect(bloc.state.devices.single.isOnline, false);
      await bloc.close();
    });

    test('Load về sau khi Wait đã chạy → emit ĐẦU TIÊN của list đã online '
        '(không nháy offline giây nào)', () async {
      when(() => dataSource.getDeviceInfo(deviceId))
          .thenAnswer((_) async => {'name': 'Rèm mới', 'active': false});

      final bloc = buildBloc();
      // Thứ tự thật trên UI: add page dispatch cả 2 gần như cùng lúc,
      // enrichment của Load luôn về SAU vì phải chờ network.
      bloc.add(const WaitDeviceOnlineEvent(
        deviceId,
        interval: Duration(milliseconds: 50),
        maxAttempts: 2,
        optimistic: true,
      ));
      bloc.add(const LoadHomeDevicesEvent(homeId));

      final first = await bloc.stream
          .firstWhere((s) => s.devices.isNotEmpty)
          .timeout(const Duration(seconds: 5));
      expect(first.devices.single.isOnline, true,
          reason: 'tile phải online ngay từ frame đầu tiên');
      await bloc.close();
    });
  });
}
