import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../../../../core/cache/cache_serializers.dart';

import '../../../../core/auth/token_manager.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/time/device_timezone.dart';
import '../../../../core/notifications/message_center.dart';
import '../../../../core/widget/home_widget_service.dart';
import '../../data/datasources/home_remote_datasource.dart';
import '../../domain/entities/home_entity.dart';
import '../../domain/home_update_merge.dart';
import '../../domain/usecases/get_homes.dart';
import '../../domain/usecases/create_home.dart';
import '../../domain/usecases/update_home.dart';
import '../../domain/usecases/delete_home.dart';
import '../../domain/usecases/get_home_devices.dart';
import '../../domain/usecases/add_device_to_home.dart';
import '../../domain/usecases/update_home_device.dart';
import '../../domain/usecases/remove_device_from_home.dart';
import '../../domain/usecases/factory_reset_device.dart';
import '../../domain/usecases/get_rooms.dart';
import '../../domain/usecases/create_room.dart';
import '../../domain/usecases/update_room.dart';
import '../../domain/usecases/delete_room.dart';
import 'home_management_event.dart';
import 'home_management_state.dart';

class HomeManagementBloc extends Bloc<HomeManagementEvent, HomeManagementState>
    with HydratedMixin<HomeManagementState> {
  final GetHomes getHomes;
  final CreateHome createHome;
  final UpdateHome updateHome;
  final DeleteHome deleteHome;
  final GetHomeDevices getHomeDevices;
  final AddDeviceToHome addDeviceToHome;
  final UpdateHomeDevice updateHomeDevice;
  final RemoveDeviceFromHome removeDeviceFromHome;
  final FactoryResetDevice factoryResetDevice;
  final GetRooms getRooms;
  final CreateRoom createRoom;
  final UpdateRoom updateRoom;
  final DeleteRoom deleteRoom;
  final HomeRemoteDataSource homeRemoteDataSource;

  /// Thiết bị vừa pair xong đang được coi là online (optimistic) cho tới khi
  /// ThingsBoard xác nhận hoặc hết thời gian chờ. LoadHomeDevices enrich tôn
  /// trọng danh sách này để tile không nháy offline ở lần render đầu.
  final Set<String> _optimisticOnlineIds = {};

  HomeManagementBloc({
    required this.getHomes,
    required this.createHome,
    required this.updateHome,
    required this.deleteHome,
    required this.getHomeDevices,
    required this.addDeviceToHome,
    required this.updateHomeDevice,
    required this.removeDeviceFromHome,
    required this.factoryResetDevice,
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
    on<FactoryResetDeviceEvent>(_onFactoryResetDevice);
    on<WaitDeviceOnlineEvent>(_onWaitDeviceOnline);
    on<LoadRoomsEvent>(_onLoadRooms);
    on<CreateRoomEvent>(_onCreateRoom);
    on<UpdateRoomEvent>(_onUpdateRoom);
    on<DeleteRoomEvent>(_onDeleteRoom);
    hydrate();
  }

  @override
  HomeManagementState? fromJson(Map<String, dynamic> json) {
    final homes = (json['homes'] as List?) ?? const [];
    if (homes.isEmpty) return null;
    return HomeManagementState(
      status: HomeStatus.loaded,
      homes: homes
          .whereType<Map>()
          .map((e) => homeFromJson(e.cast<String, dynamic>()))
          .toList(),
      selectedHomeId: json['selectedHomeId'] as String?,
      selectedRoomId: json['selectedRoomId'] as String?,
      devices: ((json['devices'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => deviceFromJson(e.cast<String, dynamic>()))
          .toList(),
      rooms: ((json['rooms'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => roomFromJson(e.cast<String, dynamic>()))
          .toList(),
    );
  }

  @override
  Map<String, dynamic>? toJson(HomeManagementState state) {
    // Persist only fully-loaded data (never loading/error) so the cache always
    // restores a usable snapshot.
    if (state.status != HomeStatus.loaded || state.homes.isEmpty) return null;
    return {
      'homes': state.homes.map(homeToJson).toList(),
      'selectedHomeId': state.selectedHomeId,
      'selectedRoomId': state.selectedRoomId,
      'devices': state.devices.map(deviceToJson).toList(),
      'rooms': state.rooms.map(roomToJson).toList(),
    };
  }

  // ---------------------------------------------------------------------------
  // Homes
  // ---------------------------------------------------------------------------

  Future<void> _onLoadHomes(
    LoadHomesEvent event,
    Emitter<HomeManagementState> emit,
  ) async {
    // Coalesce: nếu một lượt load đang chạy thì bỏ qua lượt trùng (chống
    // double-dispatch lúc khởi động → từng nhân đôi 11 API call mỗi lần mở app).
    if (state.status == HomeStatus.loading) return;
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

        // Auto-create a default home when the user has none — stamp the
        // device timezone so its scheduler fires scenes in local time.
        if (homeList.isEmpty) {
          final tz = await sl<DeviceTimezone>().current();
          final createResult = await createHome(name: 'My Home', timezone: tz);
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

        // Backfill timezone for a home created before timezone support (null
        // timezone → backend falls back to UTC → scenes fire at the wrong hour).
        homeList = await _backfillTimezone(homeList, selectedId);

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

    final tz = event.timezone ?? await sl<DeviceTimezone>().current();
    final result = await createHome(
      name: event.name,
      geoName: event.geoName,
      timezone: tz,
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

  Future<void> _onUpdateHome(
    UpdateHomeEvent event,
    Emitter<HomeManagementState> emit,
  ) async {
    emit(state.copyWith(mutationStatus: MutationStatus.loading));

    // PUT là full-replace — lấp lại các trường event không nói tới từ bản ghi
    // hiện tại, nếu không đổi tên sẽ xoá sạch toạ độ và timezone.
    final current =
        state.homes.where((h) => h.id == event.homeId).firstOrNull;
    final merged = current == null
        ? null
        : mergeHomeUpdate(
            current: current,
            name: event.name,
            geoName: event.geoName,
            latitude: event.latitude,
            longitude: event.longitude,
            timezone: event.timezone,
          );
    final result = await updateHome(
      homeId: event.homeId,
      name: event.name,
      geoName: merged?.geoName ?? event.geoName,
      latitude: merged?.latitude ?? event.latitude,
      longitude: merged?.longitude ?? event.longitude,
      timezone: merged?.timezone ?? event.timezone,
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

  /// PUTs the device timezone onto [selectedId] when that home has none yet, so
  /// existing users (whose home predates timezone support) get correct scene
  /// scheduling without touching settings. Returns [homes] with the refreshed
  /// entity swapped in; on any failure the list is returned unchanged.
  Future<List<HomeEntity>> _backfillTimezone(
    List<HomeEntity> homes,
    String selectedId,
  ) async {
    final idx = homes.indexWhere((h) => h.id == selectedId);
    if (idx == -1) return homes;
    final home = homes[idx];
    if ((home.timezone ?? '').isNotEmpty) return homes;

    final tz = await sl<DeviceTimezone>().current();
    if (tz == null) return homes; // detection failed — retry on next app open
    final result = await updateHome(
      homeId: home.id,
      name: home.name,
      geoName: home.geoName,
      latitude: home.latitude,
      longitude: home.longitude,
      timezone: tz,
    );
    return result.fold(
      (_) => homes,
      (updated) => [...homes]..[idx] = updated,
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
                isOnline: info['active'] == true ||
                    _optimisticOnlineIds.contains(d.deviceId),
              );
            } catch (_) {
              return d; // swallow individual enrichment errors
            }
          }),
        );
        emit(state.copyWith(devices: enriched));

        // Message Center: log online→offline transitions for this snapshot.
        // Guarded so unit tests without DI keep working.
        if (sl.isRegistered<MessageCenter>()) {
          sl<MessageCenter>().recordDeviceSnapshot(
          state.selectedHome?.name,
          [
            for (final d in enriched)
              MessageDeviceStatus(
                id: d.deviceId,
                name: d.displayName,
                online: d.isOnline ?? false,
              ),
          ],
          );
        }

        // Đẩy danh sách thiết bị lên home-screen widget
        // (iOS: Edit Widget chọn thiết bị, mặc định là thiết bị đầu tiên).
        if (enriched.isNotEmpty) {
          sl<HomeWidgetService>().pushDevices(
            enriched
                .map((d) => WidgetDevice(
                      id: d.deviceId,
                      name: d.displayName,
                      isOnline: d.isOnline ?? false,
                    ))
                .toList(),
          );
        }
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

  /// Chờ ThingsBoard flip `active=true` cho thiết bị mới pair rồi patch state.
  /// PAIRED (backend) đến trước khi TB thấy device connect MQTT, nên lần
  /// enrich đầu tiên luôn ra offline — đây là nửa "revalidate" cho 1 thiết bị.
  Future<void> _onWaitDeviceOnline(
    WaitDeviceOnlineEvent event,
    Emitter<HomeManagementState> emit,
  ) async {
    var optimisticShown = false;
    // Đăng ký TRƯỚC mọi await — enrichment của LoadHomeDevices (đang chạy
    // song song) sẽ thấy và emit online ngay từ lần đầu.
    if (event.optimistic) _optimisticOnlineIds.add(event.deviceId);

    bool deviceInList() =>
        state.devices.any((d) => d.deviceId == event.deviceId);

    void patchOnline(bool online) {
      if (!deviceInList()) return;
      emit(state.copyWith(
        devices: [
          for (final d in state.devices)
            d.deviceId == event.deviceId
                ? d.copyWithDeviceInfo(isOnline: online)
                : d,
        ],
      ));
    }

    for (var attempt = 0; attempt < event.maxAttempts; attempt++) {
      // Optimistic: hiện online ngay khi thiết bị xuất hiện trong list —
      // PAIRED nghĩa là nó vừa gọi backend qua WiFi thành công. Poll bên
      // dưới chỉ để xác nhận (hoặc revert nếu TB không bao giờ thấy nó).
      if (event.optimistic && !optimisticShown && deviceInList()) {
        patchOnline(true);
        optimisticShown = true;
      }

      await Future<void>.delayed(event.interval);
      if (isClosed) return;

      final current =
          state.devices.where((d) => d.deviceId == event.deviceId).firstOrNull;
      if (!event.optimistic && current != null && current.isOnline == true) {
        return; // đã online (nguồn khác xác nhận)
      }

      try {
        final info = await homeRemoteDataSource.getDeviceInfo(event.deviceId);
        if (info['active'] != true) continue;
        if (isClosed) return;
        // LoadHomeDevices có thể về chậm hơn poll — chưa có trong list thì
        // đợi vòng sau rồi patch.
        if (!deviceInList()) continue;
        _optimisticOnlineIds.remove(event.deviceId); // TB đã xác nhận
        final confirmed = state.devices
            .where((d) => d.deviceId == event.deviceId)
            .firstOrNull;
        if (confirmed?.isOnline != true) patchOnline(true);
        return;
      } catch (_) {
        // Lỗi mạng lẻ tẻ — thử lại vòng sau.
      }
    }

    // Hết attempts mà TB chưa xác nhận → trả tile về sự thật.
    _optimisticOnlineIds.remove(event.deviceId);
    if (!isClosed &&
        (optimisticShown ||
            state.devices
                    .where((d) => d.deviceId == event.deviceId)
                    .firstOrNull
                    ?.isOnline ==
                true)) {
      patchOnline(false);
    }
  }

  Future<void> _onUpdateHomeDevice(
    UpdateHomeDeviceEvent event,
    Emitter<HomeManagementState> emit,
  ) async {
    // Optimistic: apply rename/room/sortOrder to the local list IMMEDIATELY so
    // the UI (esp. Home ordering after "Move to Top") reflects the change at
    // once. The prod server is in the US and has read-after-write lag — a
    // reload right after the PUT often returns the *old* order, so we do NOT
    // reload here; we trust the value we just sent (and revert if it fails).
    final previous = state.devices;
    final optimistic = previous
        .map((d) => d.deviceId == event.deviceId
            ? d.copyWith(
                roomId: event.roomId,
                deviceName: event.deviceName,
                sortOrder: event.sortOrder,
              )
            : d)
        .toList();
    emit(state.copyWith(
      devices: optimistic,
      mutationStatus: MutationStatus.loading,
    ));

    final result = await updateHomeDevice(
      homeId: event.homeId,
      deviceId: event.deviceId,
      roomId: event.roomId,
      deviceName: event.deviceName,
      sortOrder: event.sortOrder,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        devices: previous, // revert the optimistic change
        mutationStatus: MutationStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(mutationStatus: MutationStatus.success)),
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

  Future<void> _onFactoryResetDevice(
    FactoryResetDeviceEvent event,
    Emitter<HomeManagementState> emit,
  ) async {
    emit(state.copyWith(mutationStatus: MutationStatus.loading));

    final result = await factoryResetDevice(
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
      sortOrder: event.sortOrder,
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
