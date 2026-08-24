import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_product_catalog.dart';
import '../../domain/usecases/scan_for_osprey_devices.dart';
import 'osprey_scan_event.dart';
import 'osprey_scan_state.dart';

/// Scan BLE tìm thiết bị Osprey pairable (filter Brand UUID).
class OspreyScanBloc extends Bloc<OspreyScanEvent, OspreyScanState> {
  final ScanForOspreyDevices scanForDevices;
  final GetProductCatalog getProductCatalog;

  StreamSubscription? _scanSub;
  StreamSubscription<bool>? _btSub;
  StreamSubscription<bool>? _isScanningSub;

  /// Trạng thái BT đã biết gần nhất (null = chưa có event nào).
  bool? _btOn;

  OspreyScanBloc({
    required this.scanForDevices,
    required this.getProductCatalog,
  }) : super(OspreyScanInitial()) {
    on<StartOspreyScanEvent>(_onStart);
    on<StopOspreyScanEvent>(_onStop);
    on<OspreyDevicesUpdatedEvent>(_onDevicesUpdated);
    on<OspreyBluetoothChangedEvent>(_onBluetoothChanged);
    on<OspreyScanningChangedEvent>(_onScanningChanged);
    on<OspreyScanFailedEvent>(_onScanFailed);
  }

  Future<void> _onStart(
    StartOspreyScanEvent event,
    Emitter<OspreyScanState> emit,
  ) async {
    emit(OspreyScanStarting());

    // Pre-cache catalog để map productIdHash → tên sản phẩm khi scan.
    // Catalog lỗi không chặn scan (device hiện "Unknown" thay vì tên).
    await getProductCatalog();

    // Nghe adapter Bluetooth: tắt giữa chừng → báo user; bật lại → tự
    // scan tiếp, không bắt user bấm Rescan.
    _btSub ??= scanForDevices
        .bluetoothOn()
        .listen((on) => add(OspreyBluetoothChangedEvent(on)));
    _isScanningSub ??= scanForDevices
        .scanning()
        .listen((s) => add(OspreyScanningChangedEvent(s)));
    if (_btOn == null) {
      // Chưa biết trạng thái → hỏi thẳng (FBP replay giá trị hiện tại).
      // Timeout đề phòng platform im lặng: coi như bật, đi tiếp như cũ.
      try {
        _btOn = await scanForDevices
            .bluetoothOn()
            .first
            .timeout(const Duration(seconds: 2));
      } on TimeoutException {
        _btOn = true;
      }
    }
    if (_btOn == false) {
      emit(OspreyScanBluetoothOff());
      return;
    }

    await _scanSub?.cancel();
    _scanSub = scanForDevices().listen(
      (devices) => add(OspreyDevicesUpdatedEvent(devices)),
      onError: (Object e) => add(OspreyScanFailedEvent(e.toString())),
    );

    try {
      await scanForDevices.start();
      emit(const OspreyScanning([]));
    } catch (e) {
      // BT vừa tắt đúng lúc startScan → hiện state thân thiện thay vì
      // nhả nguyên PlatformException lên UI.
      emit(_btOn == false
          ? OspreyScanBluetoothOff()
          : OspreyScanError('Could not start scan: $e'));
    }
  }

  Future<void> _onBluetoothChanged(
    OspreyBluetoothChangedEvent event,
    Emitter<OspreyScanState> emit,
  ) async {
    _btOn = event.on;
    if (!event.on) {
      if (state is OspreyScanning ||
          state is OspreyScanStarting ||
          state is OspreyScanError) {
        await scanForDevices.stop();
        emit(OspreyScanBluetoothOff());
      }
    } else if (state is OspreyScanBluetoothOff) {
      add(const StartOspreyScanEvent());
    }
  }

  void _onScanningChanged(
    OspreyScanningChangedEvent event,
    Emitter<OspreyScanState> emit,
  ) {
    // FBP tự dừng khi hết scanTimeout — phản ánh lên UI (radar ngừng quay,
    // nút Rescan hiện ra) thay vì "Searching..." vô hạn. Các state khác
    // (BluetoothOff/Stopped/Error) đã tự mô tả đúng, không đụng vào.
    if (!event.scanning && state is OspreyScanning) {
      emit(OspreyScanStopped((state as OspreyScanning).devices));
    }
  }

  Future<void> _onStop(
    StopOspreyScanEvent event,
    Emitter<OspreyScanState> emit,
  ) async {
    await scanForDevices.stop();
    final current = state;
    emit(OspreyScanStopped(
        current is OspreyScanning ? current.devices : const []));
  }

  void _onDevicesUpdated(
    OspreyDevicesUpdatedEvent event,
    Emitter<OspreyScanState> emit,
  ) {
    if (state is OspreyScanning || state is OspreyScanStarting) {
      emit(OspreyScanning(event.devices));
    }
  }

  void _onScanFailed(
    OspreyScanFailedEvent event,
    Emitter<OspreyScanState> emit,
  ) {
    emit(OspreyScanError(event.message));
  }

  @override
  Future<void> close() async {
    await _btSub?.cancel();
    await _isScanningSub?.cancel();
    await _scanSub?.cancel();
    await scanForDevices.stop();
    return super.close();
  }
}
