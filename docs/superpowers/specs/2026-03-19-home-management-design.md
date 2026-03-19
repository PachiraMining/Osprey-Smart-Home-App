# Home Management + Tap-to-Run Integration — Design Spec

**Date:** 2026-03-19
**Branch:** `feat/ui-redesign-osprey`
**Scope:** Home Management (A2-A4) + Tap-to-Run scene integration

---

## 1. Overview

Add Home Management feature following Tuya Smart architecture: users manage homes, rooms, and devices within homes. Tap-to-Run scenes integrate with home-based device lists. Members (A5) deferred to later.

### Architecture Rules (from spec)
- 1 device belongs to exactly 1 home
- 1 user can own/join multiple homes
- Devices in a home can optionally be assigned to a room
- Switching homes shows different devices
- Scenes belong to a home and only use devices within that home

### Permissions (for future reference)
- OWNER: full control
- ADMIN: manage devices, rooms, scenes
- MEMBER: view and control only

---

## 2. Feature Structure

```
lib/features/home/
├── data/
│   ├── datasources/home_remote_datasource.dart
│   ├── models/
│   │   ├── home_model.dart
│   │   ├── home_device_model.dart
│   │   └── room_model.dart
│   └── repositories/home_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── home_entity.dart
│   │   ├── home_device_entity.dart
│   │   └── room_entity.dart
│   ├── repositories/home_repository.dart
│   └── usecases/
│       ├── get_homes.dart
│       ├── create_home.dart
│       ├── update_home.dart
│       ├── delete_home.dart
│       ├── get_home_devices.dart
│       ├── add_device_to_home.dart
│       ├── update_home_device.dart
│       ├── remove_device_from_home.dart
│       ├── get_rooms.dart
│       ├── create_room.dart
│       ├── update_room.dart
│       └── delete_room.dart
└── presentation/
    ├── bloc/
    │   ├── home_management_bloc.dart
    │   ├── home_management_event.dart
    │   └── home_management_state.dart
    └── pages/
        ├── home_tab.dart
        ├── home_selector_sheet.dart
        ├── manage_home_page.dart
        ├── manage_rooms_page.dart
        └── add_device_to_home_page.dart
```

---

## 3. Domain Layer

### 3.1 Entities

**HomeEntity:**
```dart
class HomeEntity extends Equatable {
  final String id;
  final String name;
  final String? ownerUserId;
  final String? geoName;
  final double? latitude;
  final double? longitude;
  final String? timezone;
}
```

**HomeDeviceEntity:**
```dart
class HomeDeviceEntity extends Equatable {
  final String id;           // smart home device mapping id
  final String smartHomeId;
  final String deviceId;     // actual device id (for commands/scenes)
  final String? roomId;
  final String? deviceName;  // custom name (null = use original)
  final int sortOrder;
}
```

**RoomEntity:**
```dart
class RoomEntity extends Equatable {
  final String id;
  final String name;
  final String? icon;
  final int sortOrder;
}
```

### 3.2 Repository Interface

```dart
abstract class HomeRepository {
  // Homes
  Future<Either<Failure, List<HomeEntity>>> getHomes();
  Future<Either<Failure, HomeEntity>> createHome({required String name, String? geoName, double? latitude, double? longitude, String? timezone});
  Future<Either<Failure, HomeEntity>> updateHome({required String homeId, required String name, String? geoName, double? latitude, double? longitude, String? timezone});
  Future<Either<Failure, void>> deleteHome(String homeId);

  // Home Devices
  Future<Either<Failure, List<HomeDeviceEntity>>> getHomeDevices(String homeId);
  Future<Either<Failure, void>> addDeviceToHome({required String homeId, required String deviceId});
  Future<Either<Failure, void>> updateHomeDevice({required String homeId, required String deviceId, String? roomId, String? deviceName, int? sortOrder});
  Future<Either<Failure, void>> removeDeviceFromHome({required String homeId, required String deviceId});

  // Rooms
  Future<Either<Failure, List<RoomEntity>>> getRooms(String homeId);
  Future<Either<Failure, RoomEntity>> createRoom({required String homeId, required String name, String? icon, int? sortOrder});
  Future<Either<Failure, RoomEntity>> updateRoom({required String homeId, required String roomId, required String name, String? icon, int? sortOrder});
  Future<Either<Failure, void>> deleteRoom({required String homeId, required String roomId});
}
```

### 3.3 Use Cases

12 use cases, each a single-method class with `call()`:

| Use Case | Input | Output |
|----------|-------|--------|
| GetHomes | — | Either<Failure, List<HomeEntity>> |
| CreateHome | name, geoName?, lat?, lng?, tz? | Either<Failure, HomeEntity> |
| UpdateHome | homeId, name, ... | Either<Failure, HomeEntity> |
| DeleteHome | homeId | Either<Failure, void> |
| GetHomeDevices | homeId | Either<Failure, List<HomeDeviceEntity>> |
| AddDeviceToHome | homeId, deviceId | Either<Failure, void> |
| UpdateHomeDevice | homeId, deviceId, roomId?, name?, sort? | Either<Failure, void> |
| RemoveDeviceFromHome | homeId, deviceId | Either<Failure, void> |
| GetRooms | homeId | Either<Failure, List<RoomEntity>> |
| CreateRoom | homeId, name, icon?, sort? | Either<Failure, void> |
| UpdateRoom | homeId, roomId, name, icon?, sort? | Either<Failure, void> |
| DeleteRoom | homeId, roomId | Either<Failure, void> |

---

## 4. Data Layer

### 4.1 API Endpoints

All use `ApiClient` (Dio) with automatic `X-Authorization: Bearer <token>` injection.

**Homes:**
- `GET /api/smarthome/homes` — list homes
- `POST /api/smarthome/homes` — create home
- `PUT /api/smarthome/homes/{homeId}` — update home
- `DELETE /api/smarthome/homes/{homeId}` — delete home

**Home Devices:**
- `GET /api/smarthome/homes/{homeId}/devices` — list devices in home
- `POST /api/smarthome/homes/{homeId}/devices` — add device to home
- `PUT /api/smarthome/homes/{homeId}/devices/{deviceId}` — update device (assign room, rename)
- `DELETE /api/smarthome/homes/{homeId}/devices/{deviceId}` — remove device from home

**Rooms:**
- `GET /api/smarthome/homes/{homeId}/rooms` — list rooms
- `POST /api/smarthome/homes/{homeId}/rooms` — create room
- `PUT /api/smarthome/homes/{homeId}/rooms/{roomId}` — update room
- `DELETE /api/smarthome/homes/{homeId}/rooms/{roomId}` — delete room

### 4.2 Models

**HomeModel** extends HomeEntity:
- `fromJson()`: parse nested id (`json['id']['id']`), name, geoName, lat, lng, timezone, ownerUserId
- `toJson()`: for create/update body

**HomeDeviceModel** extends HomeDeviceEntity:
- `fromJson()`: parse id, smartHomeId (`json['smartHomeId']['id']`), deviceId (`json['deviceId']['id']`), roomId (`json['roomId']?['id']`), deviceName, sortOrder

**RoomModel** extends RoomEntity:
- `fromJson()`: parse nested id (`json['id']['id']`), name, icon, sortOrder
- `toJson()`: for create/update body

### 4.3 Remote Data Source

Single class `HomeRemoteDataSource` with all 12 API methods.
- Uses `ApiClient` (Dio) for all HTTP calls
- Throws `UnauthorizedException` on 401, `ServerException` otherwise
- Consistent with existing `TapToRunRemoteDataSource` pattern

### 4.4 Repository Implementation

Wraps datasource in `Either<Failure, T>`:
- `UnauthorizedException` → `AuthFailure`
- `ServerException` → `ServerFailure`
- Generic `Exception` → `ServerFailure` with generic message

---

## 5. Presentation Layer

### 5.1 BLoC

**Single state class** with `copyWith` (not subclasses):

```dart
enum HomeStatus { initial, loading, loaded, error }

class HomeManagementState extends Equatable {
  final List<HomeEntity> homes;
  final String? selectedHomeId;
  final List<HomeDeviceEntity> devices;
  final List<RoomEntity> rooms;
  final HomeStatus status;
  final String? errorMessage;

  HomeEntity? get selectedHome => homes.where((h) => h.id == selectedHomeId).firstOrNull;
}
```

**Events:** LoadHomes, SelectHome, CreateHome, UpdateHome, DeleteHome, LoadHomeDevices, AddDeviceToHome, UpdateHomeDevice, RemoveDeviceFromHome, LoadRooms, CreateRoom, UpdateRoom, DeleteRoom.

**App startup flow:**
1. `LoadHomesEvent` dispatched from `main.dart`
2. BLoC fetches homes → if empty, auto-creates "Nha cua toi"
3. Selects home from TokenManager cache or first home
4. Auto-dispatches `LoadHomeDevicesEvent` + `LoadRoomsEvent`
5. State = loaded with homes + devices + rooms

### 5.2 UI Pages (simple, replaceable)

**home_tab.dart:**
- Header: home name (tap to open selector sheet)
- Room filter: horizontal chips ("Tat ca" + rooms)
- Device list: ListView of devices, filtered by selected room
- Tap device → navigate to control page

**home_selector_sheet.dart:**
- Bottom sheet with list of homes
- Current home highlighted
- "Tao nha moi" button at bottom
- Tap home → SelectHomeEvent

**manage_home_page.dart:**
- Edit home name (TextField)
- "Quan ly phong" navigation
- "Xoa nha" button (with confirmation dialog)

**manage_rooms_page.dart:**
- List of rooms with edit/delete
- "Them phong" button → dialog with name input
- Swipe to delete room

**add_device_to_home_page.dart:**
- List of available devices (from customer devices not yet in a home)
- Checkbox selection → add to home

---

## 6. Integration Changes

### 6.1 DI (injector.dart)
Register all Home Management dependencies:
- HomeRemoteDataSource (LazySingleton)
- HomeRepository (LazySingleton)
- 12 use cases (LazySingleton)
- HomeManagementBloc (Factory)

### 6.2 main.dart
Add `HomeManagementBloc` to `MultiBlocProvider`:
```dart
BlocProvider(create: (_) => sl<HomeManagementBloc>()..add(LoadHomesEvent())),
```

### 6.3 Tap-to-Run Updates

**tap_to_run_bloc.dart:**
- Remove `_ensureHomeId()` method (no longer self-manages homeId)
- `LoadTapToRunScenesEvent` now requires `homeId` parameter
- homeId passed from UI which reads `HomeManagementBloc.state.selectedHomeId`

**create_tap_to_run_page.dart:**
- Device list from `HomeManagementBloc.state.devices` (not DeviceBloc)
- homeId from `HomeManagementBloc.state.selectedHomeId`
- When selecting device for DEVICE_CONTROL action: use homeDevice.deviceId

### 6.4 TokenManager
No changes needed. `saveHomeId()` / `getHomeIdSync()` already exist for selected home persistence.

---

## 7. File Summary

| Category | New Files | Modified Files |
|----------|-----------|----------------|
| Domain (entities) | 3 | 0 |
| Domain (repository) | 1 | 0 |
| Domain (use cases) | 12 | 0 |
| Data (models) | 3 | 0 |
| Data (datasource) | 1 | 0 |
| Data (repository impl) | 1 | 0 |
| BLoC | 3 | 0 |
| UI Pages | 5 | 0 |
| DI | 0 | 1 (injector.dart) |
| main.dart | 0 | 1 |
| Tap-to-Run | 0 | 2 (bloc + create page) |
| **Total** | **29** | **4** |

---

## 8. Out of Scope

- Members management (A5) — deferred
- Device control from home tab (tap navigates to existing control page)
- Fancy UI — simple/functional now, redesign later with design mockup
- Migration of Device feature from http.Client to ApiClient
