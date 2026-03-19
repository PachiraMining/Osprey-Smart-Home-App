import 'package:equatable/equatable.dart';

import '../../domain/entities/home_device_entity.dart';
import '../../domain/entities/home_entity.dart';
import '../../domain/entities/room_entity.dart';

enum HomeStatus { initial, loading, loaded, error }

enum MutationStatus { idle, loading, success, error }

class HomeManagementState extends Equatable {
  final List<HomeEntity> homes;
  final String? selectedHomeId;
  final List<HomeDeviceEntity> devices;
  final List<RoomEntity> rooms;
  final HomeStatus status;
  final MutationStatus mutationStatus;
  final String? errorMessage;
  final String? selectedRoomId;

  const HomeManagementState({
    this.homes = const [],
    this.selectedHomeId,
    this.devices = const [],
    this.rooms = const [],
    this.status = HomeStatus.initial,
    this.mutationStatus = MutationStatus.idle,
    this.errorMessage,
    this.selectedRoomId,
  });

  /// The currently selected home, or null if none selected
  HomeEntity? get selectedHome =>
      homes.where((h) => h.id == selectedHomeId).firstOrNull;

  /// Devices filtered by selectedRoomId — null means show all
  List<HomeDeviceEntity> get filteredDevices => selectedRoomId == null
      ? devices
      : devices.where((d) => d.roomId == selectedRoomId).toList();

  HomeManagementState copyWith({
    List<HomeEntity>? homes,
    String? selectedHomeId,
    List<HomeDeviceEntity>? devices,
    List<RoomEntity>? rooms,
    HomeStatus? status,
    MutationStatus? mutationStatus,
    String? errorMessage,
    String? selectedRoomId,
    bool clearSelectedRoomId = false,
    bool clearError = false,
  }) =>
      HomeManagementState(
        homes: homes ?? this.homes,
        selectedHomeId: selectedHomeId ?? this.selectedHomeId,
        devices: devices ?? this.devices,
        rooms: rooms ?? this.rooms,
        status: status ?? this.status,
        mutationStatus: mutationStatus ?? this.mutationStatus,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        selectedRoomId: clearSelectedRoomId
            ? null
            : (selectedRoomId ?? this.selectedRoomId),
      );

  @override
  List<Object?> get props => [
        homes,
        selectedHomeId,
        devices,
        rooms,
        status,
        mutationStatus,
        errorMessage,
        selectedRoomId,
      ];
}
