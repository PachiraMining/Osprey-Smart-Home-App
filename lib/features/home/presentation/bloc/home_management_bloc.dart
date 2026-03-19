import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/auth/token_manager.dart';
import '../../../../core/di/injector.dart';
import '../../data/datasources/home_remote_datasource.dart';
import '../../domain/usecases/get_homes.dart';
import '../../domain/usecases/create_home.dart';
import '../../domain/usecases/update_home.dart';
import '../../domain/usecases/delete_home.dart';
import '../../domain/usecases/get_home_devices.dart';
import '../../domain/usecases/add_device_to_home.dart';
import '../../domain/usecases/update_home_device.dart';
import '../../domain/usecases/remove_device_from_home.dart';
import '../../domain/usecases/get_rooms.dart';
import '../../domain/usecases/create_room.dart';
import '../../domain/usecases/update_room.dart';
import '../../domain/usecases/delete_room.dart';
import 'home_management_event.dart';
import 'home_management_state.dart';

class HomeManagementBloc
    extends Bloc<HomeManagementEvent, HomeManagementState> {
  final GetHomes getHomes;
  final CreateHome createHome;
  final UpdateHome updateHome;
  final DeleteHome deleteHome;
  final GetHomeDevices getHomeDevices;
  final AddDeviceToHome addDeviceToHome;
  final UpdateHomeDevice updateHomeDevice;
  final RemoveDeviceFromHome removeDeviceFromHome;
  final GetRooms getRooms;
  final CreateRoom createRoom;
  final UpdateRoom updateRoom;
  final DeleteRoom deleteRoom;
  final HomeRemoteDataSource homeRemoteDataSource;

  HomeManagementBloc({
    required this.getHomes,
    required this.createHome,
    required this.updateHome,
    required this.deleteHome,
    required this.getHomeDevices,
    required this.addDeviceToHome,
    required this.updateHomeDevice,
    required this.removeDeviceFromHome,
    required this.getRooms,
    required this.createRoom,
    required this.updateRoom,
    required this.deleteRoom,
    required this.homeRemoteDataSource,
  }) : super(const HomeManagementState()) {
    on<LoadHomesEvent>(_onLoadHomes);
    on<SelectHomeEvent>(_onSelectHome);
    on<SelectRoomEvent>(_onSelectRoom);
    on<CreateHomeEvent>(_onCreateHome);
    on<UpdateHomeEvent>(_onUpdateHome);
    on<DeleteHomeEvent>(_onDeleteHome);
    on<LoadHomeDevicesEvent>(_onLoadHomeDevices);
    on<AddDeviceToHomeEvent>(_onAddDeviceToHome);
    on<UpdateHomeDeviceEvent>(_onUpdateHomeDevice);
    on<RemoveDeviceFromHomeEvent>(_onRemoveDeviceFromHome);
    on<LoadRoomsEvent>(_onLoadRooms);
    on<CreateRoomEvent>(_onCreateRoom);
    on<UpdateRoomEvent>(_onUpdateRoom);
    on<DeleteRoomEvent>(_onDeleteRoom);
  }

  // ---------------------------------------------------------------------------
  // Homes
  // ---------------------------------------------------------------------------

  Future<void> _onLoadHomes(
    LoadHomesEvent event,
    Emitter<HomeManagementState> emit,
  ) async {
    emit(state.copyWith(status: HomeStatus.loading, clearError: true));

    final result = await getHomes();
    await result.fold(
      (failure) async {
        emit(state.copyWith(
          status: HomeStatus.error,
          errorMessage: failure.message,
        ));
      },
      (homes) async {
        var homeList = homes;

        // Auto-create a default home when the user has none
        if (homeList.isEmpty) {
          final createResult = await createHome(name: 'My Home');
          final created = createResult.fold(
            (failure) => null,
            (home) => home,
          );
          if (created == null) {
            emit(state.copyWith(
              status: HomeStatus.error,
              errorMessage: 'Unable to create default home',
            ));
            return;
          }
          homeList = [created];
        }

        // Determine which home to select
        final cachedHomeId = sl<TokenManager>().getHomeIdSync();
        final selectedId =
            homeList.any((h) => h.id == cachedHomeId) && cachedHomeId != null
                ? cachedHomeId
                : homeList.first.id;

        // Persist selection
        sl<TokenManager>().saveHomeId(selectedId);

        emit(state.copyWith(
          homes: homeList,
          selectedHomeId: selectedId,
          status: HomeStatus.loaded,
          clearSelectedRoomId: true,
        ));

        // Trigger child loads
        add(LoadHomeDevicesEvent(selectedId));
        add(LoadRoomsEvent(selectedId));
      },
    );
  }

  Future<void> _onSelectHome(
    SelectHomeEvent event,
    Emitter<HomeManagementState> emit,
  ) async {
    // Fire-and-forget persist
    sl<TokenManager>().saveHomeId(event.homeId);

    emit(state.copyWith(
      selectedHomeId: event.homeId,
      devices: const [],
      rooms: const [],
      clearSelectedRoomId: true,
    ));

    add(LoadHomeDevicesEvent(event.homeId));
    add(LoadRoomsEvent(event.homeId));
  }

  Future<void> _onSelectRoom(
    SelectRoomEvent event,
    Emitter<HomeManagementState> emit,
  ) async {
    if (event.roomId == null) {
      emit(state.copyWith(clearSelectedRoomId: true));
    } else {
      emit(state.copyWith(selectedRoomId: event.roomId));
    }
  }

  Future<void> _onCreateHome(
    CreateHomeEvent event,
    Emitter<HomeManagementState> emit,
  ) async {
    emit(state.copyWith(mutationStatus: MutationStatus.loading));

    final result = await createHome(name: event.name, geoName: event.geoName);
    result.fold(
      (failure) => emit(state.copyWith(
        mutationStatus: MutationStatus.error,
        errorMessage: failure.message,
      )),
      (_) {
        emit(state.copyWith(mutationStatus: MutationStatus.success));
        add(const LoadHomesEvent());
      },
    );
  }

  Future<void> _onUpdateHome(
    UpdateHomeEvent event,
    Emitter<HomeManagementState> emit,
  ) async {
    emit(state.copyWith(mutationStatus: MutationStatus.loading));

    final result = await updateHome(
      homeId: event.homeId,
      name: event.name,
      geoName: event.geoName,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        mutationStatus: MutationStatus.error,
        errorMessage: failure.message,
      )),
      (_) {
        emit(state.copyWith(mutationStatus: MutationStatus.success));
        add(const LoadHomesEvent());
      },
    );
  }

  Future<void> _onDeleteHome(
    DeleteHomeEvent event,
    Emitter<HomeManagementState> emit,
  ) async {
    emit(state.copyWith(mutationStatus: MutationStatus.loading));

    final result = await deleteHome(event.homeId);
    result.fold(
      (failure) => emit(state.copyWith(
        mutationStatus: MutationStatus.error,
        errorMessage: failure.message,
      )),
      (_) {
        // If deleted home was the selected one, we'll pick the first remaining
        final remaining =
            state.homes.where((h) => h.id != event.homeId).toList();
        if (state.selectedHomeId == event.homeId && remaining.isNotEmpty) {
          final newSelectedId = remaining.first.id;
          sl<TokenManager>().saveHomeId(newSelectedId);
          emit(state.copyWith(
            homes: remaining,
            selectedHomeId: newSelectedId,
            mutationStatus: MutationStatus.success,
            devices: const [],
            rooms: const [],
            clearSelectedRoomId: true,
          ));
          add(LoadHomeDevicesEvent(newSelectedId));
          add(LoadRoomsEvent(newSelectedId));
        } else {
          emit(state.copyWith(mutationStatus: MutationStatus.success));
          add(const LoadHomesEvent());
        }
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Devices
  // ---------------------------------------------------------------------------

  Future<void> _onLoadHomeDevices(
    LoadHomeDevicesEvent event,
    Emitter<HomeManagementState> emit,
  ) async {
    final result = await getHomeDevices(event.homeId);
    await result.fold(
      (failure) async {
        emit(state.copyWith(errorMessage: failure.message));
      },
      (devices) async {
        // Enrich with device info in parallel
        final enriched = await Future.wait(
          devices.map((d) async {
            try {
              final info =
                  await homeRemoteDataSource.getDeviceInfo(d.deviceId);
              return d.copyWithDeviceInfo(
                originalName:
                    info['name'] as String? ?? info['label'] as String?,
                deviceProfileId:
                    (info['deviceProfileId'] as Map<String, dynamic>?)?['id']
                        as String?,
                type: info['type'] as String?,
                isOnline: info['active'] == true,
              );
            } catch (_) {
              return d; // swallow individual enrichment errors
            }
          }),
        );
        emit(state.copyWith(devices: enriched));
      },
    );
  }

  Future<void> _onAddDeviceToHome(
    AddDeviceToHomeEvent event,
    Emitter<HomeManagementState> emit,
  ) async {
    emit(state.copyWith(mutationStatus: MutationStatus.loading));

    final result = await addDeviceToHome(
      homeId: event.homeId,
      deviceId: event.deviceId,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        mutationStatus: MutationStatus.error,
        errorMessage: failure.message,
      )),
      (_) {
        emit(state.copyWith(mutationStatus: MutationStatus.success));
        add(LoadHomeDevicesEvent(event.homeId));
      },
    );
  }

  Future<void> _onUpdateHomeDevice(
    UpdateHomeDeviceEvent event,
    Emitter<HomeManagementState> emit,
  ) async {
    emit(state.copyWith(mutationStatus: MutationStatus.loading));

    final result = await updateHomeDevice(
      homeId: event.homeId,
      deviceId: event.deviceId,
      roomId: event.roomId,
      deviceName: event.deviceName,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        mutationStatus: MutationStatus.error,
        errorMessage: failure.message,
      )),
      (_) {
        emit(state.copyWith(mutationStatus: MutationStatus.success));
        add(LoadHomeDevicesEvent(event.homeId));
      },
    );
  }

  Future<void> _onRemoveDeviceFromHome(
    RemoveDeviceFromHomeEvent event,
    Emitter<HomeManagementState> emit,
  ) async {
    emit(state.copyWith(mutationStatus: MutationStatus.loading));

    final result = await removeDeviceFromHome(
      homeId: event.homeId,
      deviceId: event.deviceId,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        mutationStatus: MutationStatus.error,
        errorMessage: failure.message,
      )),
      (_) {
        emit(state.copyWith(mutationStatus: MutationStatus.success));
        add(LoadHomeDevicesEvent(event.homeId));
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Rooms
  // ---------------------------------------------------------------------------

  Future<void> _onLoadRooms(
    LoadRoomsEvent event,
    Emitter<HomeManagementState> emit,
  ) async {
    final result = await getRooms(event.homeId);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (rooms) => emit(state.copyWith(rooms: rooms)),
    );
  }

  Future<void> _onCreateRoom(
    CreateRoomEvent event,
    Emitter<HomeManagementState> emit,
  ) async {
    emit(state.copyWith(mutationStatus: MutationStatus.loading));

    final result = await createRoom(
      homeId: event.homeId,
      name: event.name,
      icon: event.icon,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        mutationStatus: MutationStatus.error,
        errorMessage: failure.message,
      )),
      (_) {
        emit(state.copyWith(mutationStatus: MutationStatus.success));
        add(LoadRoomsEvent(event.homeId));
      },
    );
  }

  Future<void> _onUpdateRoom(
    UpdateRoomEvent event,
    Emitter<HomeManagementState> emit,
  ) async {
    emit(state.copyWith(mutationStatus: MutationStatus.loading));

    final result = await updateRoom(
      homeId: event.homeId,
      roomId: event.roomId,
      name: event.name,
      icon: event.icon,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        mutationStatus: MutationStatus.error,
        errorMessage: failure.message,
      )),
      (_) {
        emit(state.copyWith(mutationStatus: MutationStatus.success));
        add(LoadRoomsEvent(event.homeId));
      },
    );
  }

  Future<void> _onDeleteRoom(
    DeleteRoomEvent event,
    Emitter<HomeManagementState> emit,
  ) async {
    emit(state.copyWith(mutationStatus: MutationStatus.loading));

    final result = await deleteRoom(
      homeId: event.homeId,
      roomId: event.roomId,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        mutationStatus: MutationStatus.error,
        errorMessage: failure.message,
      )),
      (_) {
        emit(state.copyWith(mutationStatus: MutationStatus.success));
        add(LoadRoomsEvent(event.homeId));
      },
    );
  }
}
