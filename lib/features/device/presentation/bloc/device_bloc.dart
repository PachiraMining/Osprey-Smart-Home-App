import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_curtain_app/features/device/domain/usecases/get_customer_devices.dart';
import 'package:smart_curtain_app/features/device/domain/usecases/delete_device.dart';
import 'device_event.dart';
import 'device_state.dart';

class DeviceBloc extends Bloc<DeviceEvent, DeviceState> {
  final GetCustomerDevices getCustomerDevices;
  final DeleteDevice deleteDevice;

  DeviceBloc({required this.getCustomerDevices, required this.deleteDevice})
    : super(DeviceInitial()) {
    on<LoadDevicesEvent>(_onLoadDevices);
    on<RefreshDevicesEvent>(_onRefreshDevices);
    on<DeleteDeviceEvent>(_onDeleteDevice);
  }

  Future<void> _onLoadDevices(
    LoadDevicesEvent event,
    Emitter<DeviceState> emit,
  ) async {
    emit(DeviceLoading());

    // DEBUG
    print('🔍 DeviceBloc: Loading devices...');
    final result = await getCustomerDevices();

    result.fold(
      (failure) {
        print('❌ Device loading failed: ${failure.message}');
        emit(DeviceError(failure.message));
      },
      (devices) {
        print('✅ Devices loaded: ${devices.length}');
        emit(DeviceLoaded(devices));
      },
    );
  }

  Future<void> _onRefreshDevices(
    RefreshDevicesEvent event,
    Emitter<DeviceState> emit,
  ) async {
    // Keep current state while refreshing
    final result = await getCustomerDevices();

    result.fold(
      (failure) => emit(DeviceError(_mapFailureToMessage(failure))),
      (devices) => emit(DeviceLoaded(devices)),
    );
  }

  Future<void> _onDeleteDevice(
    DeleteDeviceEvent event,
    Emitter<DeviceState> emit,
  ) async {
    if (state is DeviceLoaded) {
      final currentDevices = (state as DeviceLoaded).devices;

      final result = await deleteDevice(event.deviceId);

      result.fold(
        (failure) => emit(DeviceError(_mapFailureToMessage(failure))),
        (_) {
          // Remove device from list
          final updatedDevices = currentDevices
              .where((device) => device.id != event.deviceId)
              .toList();
          emit(DeviceLoaded(updatedDevices));
        },
      );
    }
  }

  String _mapFailureToMessage(failure) {
    return failure.toString();
  }
}
