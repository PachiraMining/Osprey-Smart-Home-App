import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_curtain_app/features/pairing/domain/entities/discovered_osprey_device.dart';
import 'package:smart_curtain_app/features/pairing/domain/usecases/get_product_catalog.dart';
import 'package:smart_curtain_app/features/pairing/domain/usecases/scan_for_osprey_devices.dart';
import 'package:smart_curtain_app/features/pairing/presentation/bloc/osprey_scan_bloc.dart';
import 'package:smart_curtain_app/features/pairing/presentation/bloc/osprey_scan_event.dart';
import 'package:smart_curtain_app/features/pairing/presentation/bloc/osprey_scan_state.dart';

class _MockScanForOspreyDevices extends Mock implements ScanForOspreyDevices {}

class _MockGetProductCatalog extends Mock implements GetProductCatalog {}

void main() {
  late _MockScanForOspreyDevices scan;
  late _MockGetProductCatalog catalog;

  setUp(() {
    scan = _MockScanForOspreyDevices();
    catalog = _MockGetProductCatalog();

    when(() => catalog(forceRefresh: any(named: 'forceRefresh')))
        .thenAnswer((_) async => const Right([]));
    when(() => scan()).thenAnswer(
        (_) => Stream.value(const <DiscoveredOspreyDevice>[]));
    when(() => scan.start()).thenAnswer((_) async {});
    when(() => scan.scanning()).thenAnswer((_) => const Stream.empty());
    when(() => scan.stop()).thenAnswer((_) async {});
  });

  OspreyScanBloc buildBloc() =>
      OspreyScanBloc(scanForDevices: scan, getProductCatalog: catalog);

  group('OspreyScanBloc — adapterState (Bluetooth on/off)', () {
    test('BT đang tắt → StartScan emit BluetoothOff, KHÔNG gọi startScan',
        () async {
      when(() => scan.bluetoothOn())
          .thenAnswer((_) => Stream.value(false));

      final bloc = buildBloc();
      bloc.add(const StartOspreyScanEvent());

      await expectLater(
        bloc.stream,
        emitsThrough(isA<OspreyScanBluetoothOff>()),
      );
      verifyNever(() => scan.start());
      await bloc.close();
    });

    test('BT đang bật → scan chạy bình thường', () async {
      when(() => scan.bluetoothOn()).thenAnswer((_) => Stream.value(true));

      final bloc = buildBloc();
      bloc.add(const StartOspreyScanEvent());

      await expectLater(
        bloc.stream,
        emitsThrough(isA<OspreyScanning>()),
      );
      verify(() => scan.start()).called(1);
      await bloc.close();
    });

    test('đang BluetoothOff, user bật BT → tự động scan lại', () async {
      final bt = StreamController<bool>.broadcast();
      addTearDown(bt.close);
      when(() => scan.bluetoothOn()).thenAnswer((_) => bt.stream);

      final bloc = buildBloc();
      bloc.add(const StartOspreyScanEvent());
      // Đợi bloc subscribe xong rồi mới báo BT off
      await Future<void>.delayed(const Duration(milliseconds: 20));
      bt.add(false);
      await expectLater(
          bloc.stream, emitsThrough(isA<OspreyScanBluetoothOff>()));

      // User bật Bluetooth → bloc phải tự scan lại, không cần bấm gì
      bt.add(true);
      await expectLater(bloc.stream, emitsThrough(isA<OspreyScanning>()));
      verify(() => scan.start()).called(1);
      await bloc.close();
    });

    test('đang scan mà BT tắt giữa chừng → dừng scan, emit BluetoothOff',
        () async {
      final bt = StreamController<bool>.broadcast();
      addTearDown(bt.close);
      when(() => scan.bluetoothOn()).thenAnswer((_) => bt.stream);

      final bloc = buildBloc();
      bloc.add(const StartOspreyScanEvent());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      bt.add(true);
      await expectLater(bloc.stream, emitsThrough(isA<OspreyScanning>()));

      bt.add(false);
      await expectLater(
          bloc.stream, emitsThrough(isA<OspreyScanBluetoothOff>()));
      verify(() => scan.stop()).called(1);
      await bloc.close();
    });
  });

  group('OspreyScanBloc — scan tự dừng (isScanning)', () {
    test('FBP hết scanTimeout tự dừng → emit ScanStopped, radar ngừng quay',
        () async {
      final scanning = StreamController<bool>.broadcast();
      addTearDown(scanning.close);
      when(() => scan.bluetoothOn()).thenAnswer((_) => Stream.value(true));
      when(() => scan.scanning()).thenAnswer((_) => scanning.stream);

      final bloc = buildBloc();
      bloc.add(const StartOspreyScanEvent());
      await expectLater(bloc.stream, emitsThrough(isA<OspreyScanning>()));

      scanning.add(false); // FBP tự dừng sau 30s — trước đây UI không hề biết
      await expectLater(
          bloc.stream, emitsThrough(isA<OspreyScanStopped>()));
      await bloc.close();
    });

    test('isScanning=false khi KHÔNG ở trạng thái Scanning → bỏ qua',
        () async {
      final scanning = StreamController<bool>.broadcast();
      addTearDown(scanning.close);
      when(() => scan.bluetoothOn()).thenAnswer((_) => Stream.value(false));
      when(() => scan.scanning()).thenAnswer((_) => scanning.stream);

      final bloc = buildBloc();
      bloc.add(const StartOspreyScanEvent());
      await expectLater(
          bloc.stream, emitsThrough(isA<OspreyScanBluetoothOff>()));

      scanning.add(false);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      // Vẫn phải là BluetoothOff, không bị ghi đè thành Stopped
      expect(bloc.state, isA<OspreyScanBluetoothOff>());
      await bloc.close();
    });
  });
}
