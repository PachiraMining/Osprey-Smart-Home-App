# Home Management Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Home Management feature (homes, rooms, home-devices) and integrate with existing Tap-to-Run scenes so devices come from selected home instead of customer-level API.

**Architecture:** Clean Architecture per feature — domain entities/repos/usecases → data models/datasources/repos → presentation BLoC/pages. Uses ApiClient (Dio) with auto token injection. Single `HomeManagementBloc` with copyWith state pattern. Deprecates `SmartHomeEntity`/`GetSmartHomes` from scene feature.

**Tech Stack:** Flutter, flutter_bloc, get_it, dio, dartz, equatable

**Spec:** `docs/superpowers/specs/2026-03-19-home-management-design.md`

---

### Task 1: Domain Entities

**Files:**
- Create: `lib/features/home/domain/entities/home_entity.dart`
- Create: `lib/features/home/domain/entities/home_device_entity.dart`
- Create: `lib/features/home/domain/entities/room_entity.dart`

- [ ] **Step 1: Create HomeEntity**

```dart
// lib/features/home/domain/entities/home_entity.dart
import 'package:equatable/equatable.dart';

class HomeEntity extends Equatable {
  final String id;
  final String name;
  final String? ownerUserId;
  final String? geoName;
  final double? latitude;
  final double? longitude;
  final String? timezone;

  const HomeEntity({
    required this.id,
    required this.name,
    this.ownerUserId,
    this.geoName,
    this.latitude,
    this.longitude,
    this.timezone,
  });

  @override
  List<Object?> get props => [id, name, ownerUserId, geoName, latitude, longitude, timezone];
}
```

- [ ] **Step 2: Create HomeDeviceEntity**

```dart
// lib/features/home/domain/entities/home_device_entity.dart
import 'package:equatable/equatable.dart';

class HomeDeviceEntity extends Equatable {
  final String id;
  final String smartHomeId;
  final String deviceId;
  final String? roomId;
  final String? deviceName;
  final int sortOrder;
  // Enriched fields (from GET /api/device/{deviceId})
  final String? originalName;
  final String? deviceProfileId;
  final String? type;
  final bool? isOnline;

  const HomeDeviceEntity({
    required this.id,
    required this.smartHomeId,
    required this.deviceId,
    this.roomId,
    this.deviceName,
    this.sortOrder = 0,
    this.originalName,
    this.deviceProfileId,
    this.type,
    this.isOnline,
  });

  /// Display name: custom name > original name > deviceId
  String get displayName => deviceName ?? originalName ?? deviceId;

  HomeDeviceEntity copyWithDeviceInfo({
    String? originalName,
    String? deviceProfileId,
    String? type,
    bool? isOnline,
  }) => HomeDeviceEntity(
    id: id,
    smartHomeId: smartHomeId,
    deviceId: deviceId,
    roomId: roomId,
    deviceName: deviceName,
    sortOrder: sortOrder,
    originalName: originalName ?? this.originalName,
    deviceProfileId: deviceProfileId ?? this.deviceProfileId,
    type: type ?? this.type,
    isOnline: isOnline ?? this.isOnline,
  );

  @override
  List<Object?> get props => [id, smartHomeId, deviceId, roomId, deviceName, sortOrder, originalName, deviceProfileId, type, isOnline];
}
```

- [ ] **Step 3: Create RoomEntity**

```dart
// lib/features/home/domain/entities/room_entity.dart
import 'package:equatable/equatable.dart';

class RoomEntity extends Equatable {
  final String id;
  final String name;
  final String? icon;
  final int sortOrder;

  const RoomEntity({
    required this.id,
    required this.name,
    this.icon,
    this.sortOrder = 0,
  });

  @override
  List<Object?> get props => [id, name, icon, sortOrder];
}
```

- [ ] **Step 4: Verify no compile errors**

Run: `dart analyze lib/features/home/domain/entities/`
Expected: No issues found

- [ ] **Step 5: Commit**

```bash
git add lib/features/home/domain/entities/
git commit -m "feat(home): add domain entities — HomeEntity, HomeDeviceEntity, RoomEntity"
```

---

### Task 2: Repository Interface + Use Cases

**Files:**
- Create: `lib/features/home/domain/repositories/home_repository.dart`
- Create: `lib/features/home/domain/usecases/get_homes.dart`
- Create: `lib/features/home/domain/usecases/create_home.dart`
- Create: `lib/features/home/domain/usecases/update_home.dart`
- Create: `lib/features/home/domain/usecases/delete_home.dart`
- Create: `lib/features/home/domain/usecases/get_home_devices.dart`
- Create: `lib/features/home/domain/usecases/add_device_to_home.dart`
- Create: `lib/features/home/domain/usecases/update_home_device.dart`
- Create: `lib/features/home/domain/usecases/remove_device_from_home.dart`
- Create: `lib/features/home/domain/usecases/get_rooms.dart`
- Create: `lib/features/home/domain/usecases/create_room.dart`
- Create: `lib/features/home/domain/usecases/update_room.dart`
- Create: `lib/features/home/domain/usecases/delete_room.dart`

- [ ] **Step 1: Create HomeRepository interface**

```dart
// lib/features/home/domain/repositories/home_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/home_entity.dart';
import '../entities/home_device_entity.dart';
import '../entities/room_entity.dart';

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

- [ ] **Step 2: Create all 12 use cases**

Each use case follows this pattern (example for GetHomes):

```dart
// lib/features/home/domain/usecases/get_homes.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/home_entity.dart';
import '../repositories/home_repository.dart';

class GetHomes {
  final HomeRepository repository;
  GetHomes(this.repository);

  Future<Either<Failure, List<HomeEntity>>> call() =>
      repository.getHomes();
}
```

Create all 12 files following this pattern:
- `get_homes.dart` — `call()` → `repository.getHomes()`
- `create_home.dart` — `call({required String name, ...})` → `repository.createHome(...)`
- `update_home.dart` — `call({required String homeId, required String name, ...})` → `repository.updateHome(...)`
- `delete_home.dart` — `call(String homeId)` → `repository.deleteHome(homeId)`
- `get_home_devices.dart` — `call(String homeId)` → `repository.getHomeDevices(homeId)`
- `add_device_to_home.dart` — `call({required String homeId, required String deviceId})` → `repository.addDeviceToHome(...)`
- `update_home_device.dart` — `call({required String homeId, required String deviceId, ...})` → `repository.updateHomeDevice(...)`
- `remove_device_from_home.dart` — `call({required String homeId, required String deviceId})` → `repository.removeDeviceFromHome(...)`
- `get_rooms.dart` — `call(String homeId)` → `repository.getRooms(homeId)`
- `create_room.dart` — `call({required String homeId, required String name, ...})` → `repository.createRoom(...)`
- `update_room.dart` — `call({required String homeId, required String roomId, required String name, ...})` → `repository.updateRoom(...)`
- `delete_room.dart` — `call({required String homeId, required String roomId})` → `repository.deleteRoom(...)`

- [ ] **Step 3: Verify no compile errors**

Run: `dart analyze lib/features/home/domain/`
Expected: No issues found

- [ ] **Step 4: Commit**

```bash
git add lib/features/home/domain/
git commit -m "feat(home): add repository interface and 12 use cases"
```

---

### Task 3: Data Models

**Files:**
- Create: `lib/features/home/data/models/home_model.dart`
- Create: `lib/features/home/data/models/home_device_model.dart`
- Create: `lib/features/home/data/models/room_model.dart`

- [ ] **Step 1: Create HomeModel**

```dart
// lib/features/home/data/models/home_model.dart
import '../../domain/entities/home_entity.dart';

class HomeModel extends HomeEntity {
  const HomeModel({
    required super.id,
    required super.name,
    super.ownerUserId,
    super.geoName,
    super.latitude,
    super.longitude,
    super.timezone,
  });

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(
      id: json['id']?['id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      ownerUserId: json['ownerUserId']?['id'],
      geoName: json['geoName'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      timezone: json['timezone'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    if (geoName != null) 'geoName': geoName,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
    if (timezone != null) 'timezone': timezone,
  };
}
```

- [ ] **Step 2: Create HomeDeviceModel**

```dart
// lib/features/home/data/models/home_device_model.dart
import '../../domain/entities/home_device_entity.dart';

class HomeDeviceModel extends HomeDeviceEntity {
  const HomeDeviceModel({
    required super.id,
    required super.smartHomeId,
    required super.deviceId,
    super.roomId,
    super.deviceName,
    super.sortOrder,
    super.originalName,
    super.deviceProfileId,
    super.type,
    super.isOnline,
  });

  factory HomeDeviceModel.fromJson(Map<String, dynamic> json) {
    return HomeDeviceModel(
      id: json['id'] is Map ? json['id']['id'] : (json['id'] ?? ''),
      smartHomeId: json['smartHomeId']?['id'] ?? '',
      deviceId: json['deviceId']?['id'] ?? json['deviceId'] ?? '',
      roomId: json['roomId']?['id'],
      deviceName: json['deviceName'],
      sortOrder: json['sortOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    if (roomId != null) 'roomId': {'id': roomId, 'entityType': 'ROOM'} else 'roomId': null,
    if (deviceName != null) 'deviceName': deviceName,
    'sortOrder': sortOrder,
  };
}
```

- [ ] **Step 3: Create RoomModel**

```dart
// lib/features/home/data/models/room_model.dart
import '../../domain/entities/room_entity.dart';

class RoomModel extends RoomEntity {
  const RoomModel({
    required super.id,
    required super.name,
    super.icon,
    super.sortOrder,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id']?['id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'],
      sortOrder: json['sortOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    if (icon != null) 'icon': icon,
    'sortOrder': sortOrder,
  };
}
```

- [ ] **Step 4: Verify no compile errors**

Run: `dart analyze lib/features/home/data/models/`
Expected: No issues found

- [ ] **Step 5: Commit**

```bash
git add lib/features/home/data/models/
git commit -m "feat(home): add data models — HomeModel, HomeDeviceModel, RoomModel"
```

---

### Task 4: Remote Data Source

**Files:**
- Create: `lib/features/home/data/datasources/home_remote_datasource.dart`

Reference: `lib/features/scene/data/datasources/tap_to_run_remote_datasource.dart` — follow same DioException/401 pattern.

- [ ] **Step 1: Create HomeRemoteDataSource interface + implementation**

```dart
// lib/features/home/data/datasources/home_remote_datasource.dart
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/error/exceptions.dart';
import '../models/home_model.dart';
import '../models/home_device_model.dart';
import '../models/room_model.dart';

abstract class HomeRemoteDataSource {
  // Homes
  Future<List<HomeModel>> getHomes();
  Future<HomeModel> createHome(Map<String, dynamic> body);
  Future<HomeModel> updateHome(String homeId, Map<String, dynamic> body);
  Future<void> deleteHome(String homeId);
  // Home Devices
  Future<List<HomeDeviceModel>> getHomeDevices(String homeId);
  Future<void> addDeviceToHome(String homeId, String deviceId);
  Future<void> updateHomeDevice(String homeId, String deviceId, Map<String, dynamic> body);
  Future<void> removeDeviceFromHome(String homeId, String deviceId);
  // Rooms
  Future<List<RoomModel>> getRooms(String homeId);
  Future<RoomModel> createRoom(String homeId, Map<String, dynamic> body);
  Future<RoomModel> updateRoom(String homeId, String roomId, Map<String, dynamic> body);
  Future<void> deleteRoom(String homeId, String roomId);
  // Device info enrichment
  Future<Map<String, dynamic>> getDeviceInfo(String deviceId);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final ApiClient apiClient;
  HomeRemoteDataSourceImpl({required this.apiClient});

  // ── Homes ──

  @override
  Future<List<HomeModel>> getHomes() async {
    try {
      final response = await apiClient.get('/api/smarthome/homes');
      final List<dynamic> data = response.data is List ? response.data : [];
      return data.map((json) => HomeModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(message: 'Failed to get homes: ${e.message}');
    }
  }

  @override
  Future<HomeModel> createHome(Map<String, dynamic> body) async {
    try {
      final response = await apiClient.post('/api/smarthome/homes', data: body);
      return HomeModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(message: 'Failed to create home: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<HomeModel> updateHome(String homeId, Map<String, dynamic> body) async {
    try {
      final response = await apiClient.put('/api/smarthome/homes/$homeId', data: body);
      return HomeModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(message: 'Failed to update home: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<void> deleteHome(String homeId) async {
    try {
      await apiClient.delete('/api/smarthome/homes/$homeId');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(message: 'Failed to delete home: ${e.message}');
    }
  }

  // ── Home Devices ──

  @override
  Future<List<HomeDeviceModel>> getHomeDevices(String homeId) async {
    try {
      final response = await apiClient.get('/api/smarthome/homes/$homeId/devices');
      final List<dynamic> data = response.data is List ? response.data : [];
      return data.map((json) => HomeDeviceModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(message: 'Failed to get home devices: ${e.message}');
    }
  }

  @override
  Future<void> addDeviceToHome(String homeId, String deviceId) async {
    try {
      await apiClient.post('/api/smarthome/homes/$homeId/devices', data: {
        'deviceId': {'id': deviceId, 'entityType': 'DEVICE'},
      });
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(message: 'Failed to add device: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<void> updateHomeDevice(String homeId, String deviceId, Map<String, dynamic> body) async {
    try {
      await apiClient.put('/api/smarthome/homes/$homeId/devices/$deviceId', data: body);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(message: 'Failed to update device: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<void> removeDeviceFromHome(String homeId, String deviceId) async {
    try {
      await apiClient.delete('/api/smarthome/homes/$homeId/devices/$deviceId');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(message: 'Failed to remove device: ${e.message}');
    }
  }

  // ── Rooms ──

  @override
  Future<List<RoomModel>> getRooms(String homeId) async {
    try {
      final response = await apiClient.get('/api/smarthome/homes/$homeId/rooms');
      final List<dynamic> data = response.data is List ? response.data : [];
      return data.map((json) => RoomModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(message: 'Failed to get rooms: ${e.message}');
    }
  }

  @override
  Future<RoomModel> createRoom(String homeId, Map<String, dynamic> body) async {
    try {
      final response = await apiClient.post('/api/smarthome/homes/$homeId/rooms', data: body);
      return RoomModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(message: 'Failed to create room: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<RoomModel> updateRoom(String homeId, String roomId, Map<String, dynamic> body) async {
    try {
      final response = await apiClient.put('/api/smarthome/homes/$homeId/rooms/$roomId', data: body);
      return RoomModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(message: 'Failed to update room: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<void> deleteRoom(String homeId, String roomId) async {
    try {
      await apiClient.delete('/api/smarthome/homes/$homeId/rooms/$roomId');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(message: 'Failed to delete room: ${e.message}');
    }
  }

  // ── Device info enrichment ──

  @override
  Future<Map<String, dynamic>> getDeviceInfo(String deviceId) async {
    try {
      final response = await apiClient.get('/api/device/$deviceId');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(message: 'Failed to get device info: ${e.message}');
    }
  }
}
```

- [ ] **Step 2: Verify no compile errors**

Run: `dart analyze lib/features/home/data/datasources/`
Expected: No issues found

- [ ] **Step 3: Commit**

```bash
git add lib/features/home/data/datasources/
git commit -m "feat(home): add HomeRemoteDataSource — all 12 API methods + device info enrichment"
```

---

### Task 5: Repository Implementation

**Files:**
- Create: `lib/features/home/data/repositories/home_repository_impl.dart`

Reference: `lib/features/scene/data/repositories/tap_to_run_repository_impl.dart` — same Either wrapping pattern.

- [ ] **Step 1: Create HomeRepositoryImpl**

```dart
// lib/features/home/data/repositories/home_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/home_entity.dart';
import '../../domain/entities/home_device_entity.dart';
import '../../domain/entities/room_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';
import '../models/home_model.dart';
import '../models/home_device_model.dart';
import '../models/room_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  HomeRepositoryImpl({required this.remoteDataSource});

  // ── Homes ──

  @override
  Future<Either<Failure, List<HomeEntity>>> getHomes() async {
    try {
      final homes = await remoteDataSource.getHomes();
      return Right(homes);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Unauthorized', message: 'Phiên đăng nhập hết hạn'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } catch (e) {
      return Left(ServerFailure('$e', message: 'Lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, HomeEntity>> createHome({
    required String name,
    String? geoName,
    double? latitude,
    double? longitude,
    String? timezone,
  }) async {
    try {
      final body = HomeModel(id: '', name: name, geoName: geoName, latitude: latitude, longitude: longitude, timezone: timezone).toJson();
      final home = await remoteDataSource.createHome(body);
      return Right(home);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Unauthorized', message: 'Phiên đăng nhập hết hạn'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } catch (e) {
      return Left(ServerFailure('$e', message: 'Lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, HomeEntity>> updateHome({
    required String homeId,
    required String name,
    String? geoName,
    double? latitude,
    double? longitude,
    String? timezone,
  }) async {
    try {
      final body = HomeModel(id: '', name: name, geoName: geoName, latitude: latitude, longitude: longitude, timezone: timezone).toJson();
      final home = await remoteDataSource.updateHome(homeId, body);
      return Right(home);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Unauthorized', message: 'Phiên đăng nhập hết hạn'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } catch (e) {
      return Left(ServerFailure('$e', message: 'Lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteHome(String homeId) async {
    try {
      await remoteDataSource.deleteHome(homeId);
      return const Right(null);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Unauthorized', message: 'Phiên đăng nhập hết hạn'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } catch (e) {
      return Left(ServerFailure('$e', message: 'Lỗi không xác định'));
    }
  }

  // ── Home Devices ──

  @override
  Future<Either<Failure, List<HomeDeviceEntity>>> getHomeDevices(String homeId) async {
    try {
      final devices = await remoteDataSource.getHomeDevices(homeId);
      return Right(devices);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Unauthorized', message: 'Phiên đăng nhập hết hạn'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } catch (e) {
      return Left(ServerFailure('$e', message: 'Lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, void>> addDeviceToHome({required String homeId, required String deviceId}) async {
    try {
      await remoteDataSource.addDeviceToHome(homeId, deviceId);
      return const Right(null);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Unauthorized', message: 'Phiên đăng nhập hết hạn'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } catch (e) {
      return Left(ServerFailure('$e', message: 'Lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, void>> updateHomeDevice({
    required String homeId,
    required String deviceId,
    String? roomId,
    String? deviceName,
    int? sortOrder,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (roomId != null) {
        body['roomId'] = {'id': roomId, 'entityType': 'ROOM'};
      }
      if (deviceName != null) body['deviceName'] = deviceName;
      if (sortOrder != null) body['sortOrder'] = sortOrder;
      await remoteDataSource.updateHomeDevice(homeId, deviceId, body);
      return const Right(null);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Unauthorized', message: 'Phiên đăng nhập hết hạn'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } catch (e) {
      return Left(ServerFailure('$e', message: 'Lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, void>> removeDeviceFromHome({required String homeId, required String deviceId}) async {
    try {
      await remoteDataSource.removeDeviceFromHome(homeId, deviceId);
      return const Right(null);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Unauthorized', message: 'Phiên đăng nhập hết hạn'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } catch (e) {
      return Left(ServerFailure('$e', message: 'Lỗi không xác định'));
    }
  }

  // ── Rooms ──

  @override
  Future<Either<Failure, List<RoomEntity>>> getRooms(String homeId) async {
    try {
      final rooms = await remoteDataSource.getRooms(homeId);
      return Right(rooms);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Unauthorized', message: 'Phiên đăng nhập hết hạn'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } catch (e) {
      return Left(ServerFailure('$e', message: 'Lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, RoomEntity>> createRoom({
    required String homeId,
    required String name,
    String? icon,
    int? sortOrder,
  }) async {
    try {
      final body = RoomModel(id: '', name: name, icon: icon, sortOrder: sortOrder ?? 0).toJson();
      final room = await remoteDataSource.createRoom(homeId, body);
      return Right(room);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Unauthorized', message: 'Phiên đăng nhập hết hạn'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } catch (e) {
      return Left(ServerFailure('$e', message: 'Lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, RoomEntity>> updateRoom({
    required String homeId,
    required String roomId,
    required String name,
    String? icon,
    int? sortOrder,
  }) async {
    try {
      final body = RoomModel(id: '', name: name, icon: icon, sortOrder: sortOrder ?? 0).toJson();
      final room = await remoteDataSource.updateRoom(homeId, roomId, body);
      return Right(room);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Unauthorized', message: 'Phiên đăng nhập hết hạn'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } catch (e) {
      return Left(ServerFailure('$e', message: 'Lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRoom({required String homeId, required String roomId}) async {
    try {
      await remoteDataSource.deleteRoom(homeId, roomId);
      return const Right(null);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Unauthorized', message: 'Phiên đăng nhập hết hạn'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } catch (e) {
      return Left(ServerFailure('$e', message: 'Lỗi không xác định'));
    }
  }
}
```

- [ ] **Step 2: Verify no compile errors**

Run: `dart analyze lib/features/home/data/repositories/`
Expected: No issues found

- [ ] **Step 3: Commit**

```bash
git add lib/features/home/data/repositories/
git commit -m "feat(home): add HomeRepositoryImpl — Either wrapping for all 12 methods"
```

---

### Task 6: HomeManagementBloc — Events, State, BLoC

**Files:**
- Create: `lib/features/home/presentation/bloc/home_management_event.dart`
- Create: `lib/features/home/presentation/bloc/home_management_state.dart`
- Create: `lib/features/home/presentation/bloc/home_management_bloc.dart`

- [ ] **Step 1: Create events**

```dart
// lib/features/home/presentation/bloc/home_management_event.dart
import 'package:equatable/equatable.dart';

abstract class HomeManagementEvent extends Equatable {
  const HomeManagementEvent();
  @override
  List<Object?> get props => [];
}

class LoadHomesEvent extends HomeManagementEvent {}

class SelectHomeEvent extends HomeManagementEvent {
  final String homeId;
  const SelectHomeEvent(this.homeId);
  @override
  List<Object?> get props => [homeId];
}

class SelectRoomEvent extends HomeManagementEvent {
  final String? roomId; // null = "Tat ca"
  const SelectRoomEvent(this.roomId);
  @override
  List<Object?> get props => [roomId];
}

class CreateHomeEvent extends HomeManagementEvent {
  final String name;
  final String? geoName;
  const CreateHomeEvent({required this.name, this.geoName});
  @override
  List<Object?> get props => [name, geoName];
}

class UpdateHomeEvent extends HomeManagementEvent {
  final String homeId;
  final String name;
  final String? geoName;
  const UpdateHomeEvent({required this.homeId, required this.name, this.geoName});
  @override
  List<Object?> get props => [homeId, name, geoName];
}

class DeleteHomeEvent extends HomeManagementEvent {
  final String homeId;
  const DeleteHomeEvent(this.homeId);
  @override
  List<Object?> get props => [homeId];
}

class LoadHomeDevicesEvent extends HomeManagementEvent {
  final String homeId;
  const LoadHomeDevicesEvent(this.homeId);
  @override
  List<Object?> get props => [homeId];
}

class AddDeviceToHomeEvent extends HomeManagementEvent {
  final String homeId;
  final String deviceId;
  const AddDeviceToHomeEvent({required this.homeId, required this.deviceId});
  @override
  List<Object?> get props => [homeId, deviceId];
}

class UpdateHomeDeviceEvent extends HomeManagementEvent {
  final String homeId;
  final String deviceId;
  final String? roomId;
  final String? deviceName;
  const UpdateHomeDeviceEvent({required this.homeId, required this.deviceId, this.roomId, this.deviceName});
  @override
  List<Object?> get props => [homeId, deviceId, roomId, deviceName];
}

class RemoveDeviceFromHomeEvent extends HomeManagementEvent {
  final String homeId;
  final String deviceId;
  const RemoveDeviceFromHomeEvent({required this.homeId, required this.deviceId});
  @override
  List<Object?> get props => [homeId, deviceId];
}

class LoadRoomsEvent extends HomeManagementEvent {
  final String homeId;
  const LoadRoomsEvent(this.homeId);
  @override
  List<Object?> get props => [homeId];
}

class CreateRoomEvent extends HomeManagementEvent {
  final String homeId;
  final String name;
  final String? icon;
  const CreateRoomEvent({required this.homeId, required this.name, this.icon});
  @override
  List<Object?> get props => [homeId, name, icon];
}

class UpdateRoomEvent extends HomeManagementEvent {
  final String homeId;
  final String roomId;
  final String name;
  final String? icon;
  const UpdateRoomEvent({required this.homeId, required this.roomId, required this.name, this.icon});
  @override
  List<Object?> get props => [homeId, roomId, name, icon];
}

class DeleteRoomEvent extends HomeManagementEvent {
  final String homeId;
  final String roomId;
  const DeleteRoomEvent({required this.homeId, required this.roomId});
  @override
  List<Object?> get props => [homeId, roomId];
}
```

- [ ] **Step 2: Create state**

```dart
// lib/features/home/presentation/bloc/home_management_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/home_entity.dart';
import '../../domain/entities/home_device_entity.dart';
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

  HomeEntity? get selectedHome =>
      homes.where((h) => h.id == selectedHomeId).firstOrNull;

  List<HomeDeviceEntity> get filteredDevices =>
      selectedRoomId == null
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
  }) => HomeManagementState(
    homes: homes ?? this.homes,
    selectedHomeId: selectedHomeId ?? this.selectedHomeId,
    devices: devices ?? this.devices,
    rooms: rooms ?? this.rooms,
    status: status ?? this.status,
    mutationStatus: mutationStatus ?? this.mutationStatus,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    selectedRoomId: clearSelectedRoomId ? null : (selectedRoomId ?? this.selectedRoomId),
  );

  @override
  List<Object?> get props => [homes, selectedHomeId, devices, rooms, status, mutationStatus, errorMessage, selectedRoomId];
}
```

- [ ] **Step 3: Create HomeManagementBloc**

The BLoC handles:
- `LoadHomesEvent` → fetch homes, auto-create if empty, select home, load devices + rooms
- `SelectHomeEvent` → save homeId to TokenManager, reload devices + rooms
- `SelectRoomEvent` → update selectedRoomId (local filter only)
- CRUD events for homes, devices, rooms → set mutationStatus, call use case, refresh list
- Device enrichment → after loading devices, call `getDeviceInfo` for each to fill originalName, deviceProfileId, type, isOnline

Key imports needed:
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/auth/token_manager.dart';
import '../../../../core/di/injector.dart';
import '../../domain/usecases/get_homes.dart';
import '../../domain/usecases/create_home.dart';
// ... all 12 use cases
import '../../../home/data/datasources/home_remote_datasource.dart';
import 'home_management_event.dart';
import 'home_management_state.dart';
```

Constructor takes all 12 use cases + `HomeRemoteDataSource` (for device enrichment).

Event handlers:
- `_onLoadHomes`: emit loading → getHomes → if empty, createHome("Nhà của tôi") → select first/cached home → add LoadHomeDevicesEvent + LoadRoomsEvent
- `_onSelectHome`: save to TokenManager → copyWith(selectedHomeId, clear devices/rooms/selectedRoomId) → add LoadHomeDevicesEvent + LoadRoomsEvent
- `_onSelectRoom`: copyWith(selectedRoomId)
- `_onLoadHomeDevices`: getHomeDevices → enrich each with getDeviceInfo → copyWith(devices)
- Mutation handlers: set mutationStatus=loading → call use case → on success: refresh list + mutationStatus=success → on error: mutationStatus=error + errorMessage

- [ ] **Step 4: Verify no compile errors**

Run: `dart analyze lib/features/home/presentation/bloc/`
Expected: No issues found

- [ ] **Step 5: Commit**

```bash
git add lib/features/home/presentation/bloc/
git commit -m "feat(home): add HomeManagementBloc with events and state — copyWith pattern"
```

---

### Task 7: DI Registration + main.dart

**Files:**
- Modify: `lib/core/di/injector.dart`
- Modify: `lib/main.dart`

- [ ] **Step 1: Register Home Management in injector.dart**

Add after the Tap-to-Run section (line ~271):

```dart
// ========== Home Management Feature ==========
import '../../features/home/data/datasources/home_remote_datasource.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_homes.dart';
import '../../features/home/domain/usecases/create_home.dart';
import '../../features/home/domain/usecases/update_home.dart';
import '../../features/home/domain/usecases/delete_home.dart';
import '../../features/home/domain/usecases/get_home_devices.dart';
import '../../features/home/domain/usecases/add_device_to_home.dart';
import '../../features/home/domain/usecases/update_home_device.dart';
import '../../features/home/domain/usecases/remove_device_from_home.dart';
import '../../features/home/domain/usecases/get_rooms.dart';
import '../../features/home/domain/usecases/create_room.dart';
import '../../features/home/domain/usecases/update_room.dart';
import '../../features/home/domain/usecases/delete_room.dart';
import '../../features/home/presentation/bloc/home_management_bloc.dart';

// Data source
sl.registerLazySingleton<HomeRemoteDataSource>(
  () => HomeRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
);

// Repository
sl.registerLazySingleton<HomeRepository>(
  () => HomeRepositoryImpl(remoteDataSource: sl()),
);

// Use cases
sl.registerLazySingleton(() => GetHomes(sl()));
sl.registerLazySingleton(() => CreateHome(sl()));
sl.registerLazySingleton(() => UpdateHome(sl()));
sl.registerLazySingleton(() => DeleteHome(sl()));
sl.registerLazySingleton(() => GetHomeDevices(sl()));
sl.registerLazySingleton(() => AddDeviceToHome(sl()));
sl.registerLazySingleton(() => UpdateHomeDevice(sl()));
sl.registerLazySingleton(() => RemoveDeviceFromHome(sl()));
sl.registerLazySingleton(() => GetRooms(sl()));
sl.registerLazySingleton(() => CreateRoom(sl()));
sl.registerLazySingleton(() => UpdateRoom(sl()));
sl.registerLazySingleton(() => DeleteRoom(sl()));

// BLoC
sl.registerFactory(() => HomeManagementBloc(
  getHomes: sl(),
  createHome: sl(),
  updateHome: sl(),
  deleteHome: sl(),
  getHomeDevices: sl(),
  addDeviceToHome: sl(),
  updateHomeDevice: sl(),
  removeDeviceFromHome: sl(),
  getRooms: sl(),
  createRoom: sl(),
  updateRoom: sl(),
  deleteRoom: sl(),
  homeRemoteDataSource: sl(),
));
```

- [ ] **Step 2: Update main.dart — add HomeManagementBloc, remove TapToRun auto-load**

In `main.dart`, add HomeManagementBloc to MultiBlocProvider and remove `..add(LoadTapToRunScenesEvent())`:

```dart
// Add import
import 'features/home/presentation/bloc/home_management_bloc.dart';
import 'features/home/presentation/bloc/home_management_event.dart';

// In MultiBlocProvider.providers:
BlocProvider(create: (_) => GetIt.instance<HomeManagementBloc>()..add(LoadHomesEvent())),
// ... keep existing providers ...
// Change TapToRunBloc to NOT auto-load:
BlocProvider(create: (_) => GetIt.instance<TapToRunBloc>()),  // removed ..add(LoadTapToRunScenesEvent())
```

- [ ] **Step 3: Verify no compile errors**

Run: `dart analyze lib/core/di/injector.dart lib/main.dart`
Expected: No issues found (or only warnings about unused imports which will be resolved in later tasks)

- [ ] **Step 4: Commit**

```bash
git add lib/core/di/injector.dart lib/main.dart
git commit -m "feat(home): register HomeManagement in DI + add to MultiBlocProvider"
```

---

### Task 8: Tap-to-Run Integration — Update BLoC and Events

**Files:**
- Modify: `lib/features/scene/presentation/bloc/tap_to_run/tap_to_run_event.dart`
- Modify: `lib/features/scene/presentation/bloc/tap_to_run/tap_to_run_bloc.dart`

- [ ] **Step 1: Update LoadTapToRunScenesEvent to require homeId**

In `tap_to_run_event.dart`, change `LoadTapToRunScenesEvent`:

```dart
// From:
class LoadTapToRunScenesEvent extends TapToRunEvent {}

// To:
class LoadTapToRunScenesEvent extends TapToRunEvent {
  final String homeId;
  const LoadTapToRunScenesEvent(this.homeId);
  @override
  List<Object?> get props => [homeId];
}
```

- [ ] **Step 2: Update TapToRunBloc — remove getSmartHomes + _ensureHomeId**

In `tap_to_run_bloc.dart`:
1. Remove `import get_smart_homes.dart`
2. Remove `final GetSmartHomes getSmartHomes;` field
3. Remove `getSmartHomes` from constructor
4. Remove `String? _homeId;` and `get homeId`
5. Remove entire `_ensureHomeId()` method
6. Update `_onLoadScenes` to use `event.homeId` directly
7. Update `_onCreateScene` to require homeId from event or add homeId parameter
8. Update internal `add(LoadTapToRunScenesEvent())` calls — these need homeId now. Store homeId in a field set during load.

The simplest approach: keep a `_homeId` field but set it from events rather than fetching internally:

```dart
class TapToRunBloc extends Bloc<TapToRunEvent, TapToRunState> {
  final GetTapToRunScenes getTapToRunScenes;
  final CreateTapToRunScene createTapToRunScene;
  final UpdateTapToRunScene updateTapToRunScene;
  final DeleteTapToRunScene deleteTapToRunScene;
  final ExecuteTapToRunScene executeTapToRunScene;

  String? _homeId;

  TapToRunBloc({
    required this.getTapToRunScenes,
    required this.createTapToRunScene,
    required this.updateTapToRunScene,
    required this.deleteTapToRunScene,
    required this.executeTapToRunScene,
  }) : super(TapToRunInitial()) {
    // ... same event handlers
  }

  // _onLoadScenes now uses event.homeId:
  Future<void> _onLoadScenes(LoadTapToRunScenesEvent event, Emitter<TapToRunState> emit) async {
    _homeId = event.homeId;
    emit(TapToRunLoading());
    final result = await getTapToRunScenes(event.homeId);
    result.fold(
      (failure) => emit(TapToRunError(failure.message)),
      (scenes) => emit(TapToRunLoaded(scenes)),
    );
  }

  // _onCreateScene uses cached _homeId:
  // Replace `await _ensureHomeId()` with `_homeId`
  // Replace `add(LoadTapToRunScenesEvent())` with `add(LoadTapToRunScenesEvent(_homeId!))`
```

- [ ] **Step 3: Update DI — remove GetSmartHomes from TapToRunBloc constructor**

In `injector.dart`, update TapToRunBloc registration:

```dart
// Remove: getSmartHomes: sl(),
sl.registerFactory(
  () => TapToRunBloc(
    getTapToRunScenes: sl(),
    createTapToRunScene: sl(),
    updateTapToRunScene: sl(),
    deleteTapToRunScene: sl(),
    executeTapToRunScene: sl(),
  ),
);
```

- [ ] **Step 4: Update home_page.dart SceneTab — dispatch with homeId**

In the `SceneTab` and `_SceneTabState`, wherever `LoadTapToRunScenesEvent()` is dispatched, change to pass homeId from `HomeManagementBloc`:

```dart
// Import
import 'package:smart_curtain_app/features/home/presentation/bloc/home_management_bloc.dart';
import 'package:smart_curtain_app/features/home/presentation/bloc/home_management_state.dart';

// In _buildTapToRunContent error retry button:
final homeId = context.read<HomeManagementBloc>().state.selectedHomeId;
if (homeId != null) {
  context.read<TapToRunBloc>().add(LoadTapToRunScenesEvent(homeId));
}

// In _navigateToCreateTapToRun after pop:
final homeId = context.read<HomeManagementBloc>().state.selectedHomeId;
if (homeId != null) {
  context.read<TapToRunBloc>().add(LoadTapToRunScenesEvent(homeId));
}

// Same for _navigateToEditTapToRun
```

Also add a BlocListener on HomeManagementBloc in SceneTab to auto-load scenes when home is loaded:
```dart
// In SceneTab.initState or build:
// When HomeManagement finishes loading, load tap-to-run scenes
```

- [ ] **Step 5: Verify no compile errors**

Run: `dart analyze lib/features/scene/presentation/ lib/features/home/presentation/pages/home_page.dart lib/core/di/injector.dart`
Expected: No issues found

- [ ] **Step 6: Commit**

```bash
git add lib/features/scene/presentation/bloc/tap_to_run/ lib/features/home/presentation/pages/home_page.dart lib/core/di/injector.dart
git commit -m "feat(scene): update TapToRunBloc — homeId from event, remove getSmartHomes dependency"
```

---

### Task 9: Update CreateTapToRunPage — Use Home Devices

**Files:**
- Modify: `lib/features/scene/presentation/pages/tap_to_run/create_tap_to_run_page.dart`

- [ ] **Step 1: Replace DeviceBloc with HomeManagementBloc in _addDeviceAction**

Change the `_addDeviceAction` method:

```dart
// Replace DeviceBloc import with HomeManagementBloc:
import 'package:smart_curtain_app/features/home/presentation/bloc/home_management_bloc.dart';
import 'package:smart_curtain_app/features/home/presentation/bloc/home_management_state.dart';
import 'package:smart_curtain_app/features/home/domain/entities/home_device_entity.dart';
// Remove: DeviceBloc, DeviceState, DeviceEntity imports

// In _addDeviceAction():
final homeState = context.read<HomeManagementBloc>().state;
final devices = homeState.devices;
if (devices.isEmpty) { ... }

// Device selector shows HomeDeviceEntity:
final selectedDevice = await showModalBottomSheet<HomeDeviceEntity>(...);
// Use selectedDevice.displayName, selectedDevice.deviceProfileId, selectedDevice.deviceId
// Navigate to SelectDeviceFunctionPage with these values
```

- [ ] **Step 2: Verify no compile errors**

Run: `dart analyze lib/features/scene/presentation/pages/tap_to_run/create_tap_to_run_page.dart`
Expected: No issues found

- [ ] **Step 3: Commit**

```bash
git add lib/features/scene/presentation/pages/tap_to_run/create_tap_to_run_page.dart
git commit -m "feat(scene): CreateTapToRunPage uses HomeManagementBloc devices instead of DeviceBloc"
```

---

### Task 10: Deprecation Cleanup — Remove SmartHomeEntity & GetSmartHomes

**Files:**
- Delete: `lib/features/scene/domain/entities/smart_home_entity.dart`
- Delete: `lib/features/scene/data/models/smart_home_model.dart`
- Delete: `lib/features/scene/domain/usecases/get_smart_homes.dart`
- Modify: `lib/features/scene/domain/repositories/tap_to_run_repository.dart` — remove getSmartHomes
- Modify: `lib/features/scene/data/datasources/tap_to_run_remote_datasource.dart` — remove getSmartHomes
- Modify: `lib/features/scene/data/repositories/tap_to_run_repository_impl.dart` — remove getSmartHomes
- Modify: `lib/core/di/injector.dart` — remove GetSmartHomes registration

- [ ] **Step 1: Remove getSmartHomes from TapToRunRepository interface**

In `tap_to_run_repository.dart`, remove:
```dart
// Remove this line:
Future<Either<Failure, List<SmartHomeEntity>>> getSmartHomes();
// Remove the SmartHomeEntity import
```

- [ ] **Step 2: Remove getSmartHomes from TapToRunRemoteDataSource**

In `tap_to_run_remote_datasource.dart`:
- Remove `Future<List<SmartHomeModel>> getSmartHomes();` from abstract class
- Remove the `getSmartHomes()` implementation method
- Remove `import '../models/smart_home_model.dart';`

- [ ] **Step 3: Remove getSmartHomes from TapToRunRepositoryImpl**

In `tap_to_run_repository_impl.dart`:
- Remove the `getSmartHomes()` method
- Remove `import '../../domain/entities/smart_home_entity.dart';`

- [ ] **Step 4: Remove GetSmartHomes from injector.dart**

In `injector.dart`:
- Remove `import get_smart_homes.dart`
- Remove `sl.registerLazySingleton(() => GetSmartHomes(sl()));`

- [ ] **Step 5: Delete deprecated files**

```bash
rm lib/features/scene/domain/entities/smart_home_entity.dart
rm lib/features/scene/data/models/smart_home_model.dart
rm lib/features/scene/domain/usecases/get_smart_homes.dart
```

- [ ] **Step 6: Verify no compile errors**

Run: `dart analyze lib/`
Expected: No issues found. No remaining references to SmartHomeEntity or GetSmartHomes.

- [ ] **Step 7: Commit**

```bash
git add -A
git commit -m "refactor(scene): remove deprecated SmartHomeEntity, SmartHomeModel, GetSmartHomes"
```

---

### Task 11: UI — Home Tab (simple, replaceable)

**Files:**
- Create: `lib/features/home/presentation/pages/home_tab.dart`
- Create: `lib/features/home/presentation/pages/home_selector_sheet.dart`
- Modify: `lib/features/home/presentation/pages/home_page.dart` — replace HomeTab widget

- [ ] **Step 1: Create home_selector_sheet.dart**

Bottom sheet that:
- Lists all homes from `HomeManagementBloc.state.homes`
- Highlights current `selectedHomeId`
- Gear icon on each row → navigate to ManageHomePage
- "Tạo nhà mới" button at bottom → dispatch CreateHomeEvent
- Tap home → dispatch SelectHomeEvent → Navigator.pop

- [ ] **Step 2: Create home_tab.dart**

New HomeTab widget that replaces the existing one in home_page.dart:
- BlocBuilder on HomeManagementBloc
- Header: selectedHome name (GestureDetector → show HomeSelectorSheet)
- Room filter chips: "Tất cả" + rooms from state
- Device ListView: filteredDevices from state
- Each device card: displayName, isOnline indicator, tap → CurtainControlPage
- RefreshIndicator → dispatch LoadHomeDevicesEvent + LoadRoomsEvent
- Empty state: "Chưa có thiết bị" with button

- [ ] **Step 3: Update home_page.dart — replace HomeTab**

In `home_page.dart`:
- Replace the existing `HomeTab` class (lines 311-425) and `_DeviceListCard` class (lines 428-503) with import of new home_tab.dart
- Keep all other classes (SceneTab, MallTab, ProfileTab) unchanged
- Add import: `import 'package:smart_curtain_app/features/home/presentation/pages/home_tab.dart';`

- [ ] **Step 4: Verify no compile errors**

Run: `dart analyze lib/features/home/presentation/pages/`
Expected: No issues found

- [ ] **Step 5: Commit**

```bash
git add lib/features/home/presentation/pages/home_tab.dart lib/features/home/presentation/pages/home_selector_sheet.dart lib/features/home/presentation/pages/home_page.dart
git commit -m "feat(home): add Home tab UI with home selector and room filter"
```

---

### Task 12: UI — Manage Home + Rooms Pages

**Files:**
- Create: `lib/features/home/presentation/pages/manage_home_page.dart`
- Create: `lib/features/home/presentation/pages/manage_rooms_page.dart`

- [ ] **Step 1: Create manage_home_page.dart**

Simple page:
- AppBar: "Quản lý nhà"
- TextField to edit home name (pre-filled with current name)
- "Lưu" button → dispatch UpdateHomeEvent
- ListTile "Quản lý phòng" → navigate to ManageRoomsPage
- "Xóa nhà" button (red, with AlertDialog confirmation) → dispatch DeleteHomeEvent → pop back

- [ ] **Step 2: Create manage_rooms_page.dart**

Simple page:
- AppBar: "Quản lý phòng" with "+" action button
- ListView of rooms from HomeManagementBloc.state.rooms
- Each room row: name, icon, edit (tap) and delete (swipe Dismissible)
- Tap room → show dialog with TextField to edit name → dispatch UpdateRoomEvent
- "+" button → show dialog with TextField → dispatch CreateRoomEvent
- Swipe to delete → confirm → dispatch DeleteRoomEvent

- [ ] **Step 3: Verify no compile errors**

Run: `dart analyze lib/features/home/presentation/pages/manage_home_page.dart lib/features/home/presentation/pages/manage_rooms_page.dart`
Expected: No issues found

- [ ] **Step 4: Commit**

```bash
git add lib/features/home/presentation/pages/manage_home_page.dart lib/features/home/presentation/pages/manage_rooms_page.dart
git commit -m "feat(home): add ManageHomePage and ManageRoomsPage UI"
```

---

### Task 13: UI — Add Device to Home Page

**Files:**
- Create: `lib/features/home/presentation/pages/add_device_to_home_page.dart`

- [ ] **Step 1: Create add_device_to_home_page.dart**

Page that:
- Loads customer devices from DeviceBloc (legacy, still needed for "all devices" list)
- Shows devices NOT already in any home (or at least allows user to pick)
- Checkbox multi-select
- "Thêm" button → dispatch AddDeviceToHomeEvent for each selected device
- Handle error: "Device is already assigned to a home" → show snackbar

- [ ] **Step 2: Verify no compile errors**

Run: `dart analyze lib/features/home/presentation/pages/add_device_to_home_page.dart`
Expected: No issues found

- [ ] **Step 3: Commit**

```bash
git add lib/features/home/presentation/pages/add_device_to_home_page.dart
git commit -m "feat(home): add AddDeviceToHomePage — multi-select customer devices"
```

---

### Task 14: Full Integration Test — Analyze + Run

- [ ] **Step 1: Run full static analysis**

Run: `dart analyze lib/`
Expected: No errors. Fix any remaining issues.

- [ ] **Step 2: Verify the app builds**

Run: `flutter build apk --debug 2>&1 | tail -5`
Expected: Build succeeds.

- [ ] **Step 3: Final commit if any fixes were needed**

```bash
git add -A
git commit -m "fix: resolve remaining analysis issues from home management integration"
```

---

### Task Summary

| Task | Description | Files | Depends On |
|------|-------------|-------|------------|
| 1 | Domain entities | 3 new | — |
| 2 | Repository interface + 12 use cases | 13 new | 1 |
| 3 | Data models | 3 new | 1 |
| 4 | Remote data source | 1 new | 3 |
| 5 | Repository implementation | 1 new | 2, 4 |
| 6 | HomeManagementBloc | 3 new | 2, 5 |
| 7 | DI + main.dart | 2 modified | 6 |
| 8 | TapToRun BLoC integration | 3 modified | 7 |
| 9 | CreateTapToRunPage update | 1 modified | 7 |
| 10 | Deprecation cleanup | 3 deleted, 4 modified | 8 |
| 11 | Home Tab + Selector UI | 2 new, 1 modified | 7 |
| 12 | Manage Home + Rooms UI | 2 new | 11 |
| 13 | Add Device to Home UI | 1 new | 11 |
| 14 | Full integration verify | — | all |

**Parallelizable tasks:** Tasks 1-3 (entities + usecases + models) can run in parallel. Tasks 8-9 can run in parallel. Tasks 11-13 can run in parallel after Task 7.
