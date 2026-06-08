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

  OspreyScanBloc({
    required this.scanForDevices,
    required this.getProductCatalog,
  }) : super(OspreyScanInitial()) {
    on<StartOspreyScanEvent>(_onStart);
    on<StopOspreyScanEvent>(_onStop);
    on<OspreyDevicesUpdatedEvent>(_onDevicesUpdated);
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

    await _scanSub?.cancel();
    _scanSub = scanForDevices().listen(
      (devices) => add(OspreyDevicesUpdatedEvent(devices)),
      onError: (Object e) => add(OspreyScanFailedEvent(e.toString())),
    );

    try {
      await scanForDevices.start();
      emit(const OspreyScanning([]));
    } catch (e) {
      emit(OspreyScanError('Không bắt đầu scan được: $e'));
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
    await _scanSub?.cancel();
    await scanForDevices.stop();
    return super.close();
  }
}
