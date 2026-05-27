# Tap-to-Run Smart Scene Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement Tap-to-Run scene feature — users create scenes with multiple sequential actions (device control, delay, run scene), then execute them with one tap.

**Architecture:** New parallel system alongside existing Automation. All new files under `lib/features/scene/` following Clean Architecture (domain → data → presentation). Uses ThingsBoard Smart Home API exclusively (not the scheduler API). Separate TapToRunBloc from existing SceneBloc.

**Tech Stack:** Flutter, flutter_bloc, get_it, dio (ApiClient), dartz (Either), equatable, flutter_secure_storage

**Spec:** `docs/superpowers/specs/2026-03-18-tap-to-run-scene-design.md`

---

## File Map

### New Files (22 total)

| File | Responsibility |
|------|---------------|
| `lib/features/scene/domain/entities/smart_home_entity.dart` | SmartHome domain entity |
| `lib/features/scene/domain/entities/tap_to_run_scene_entity.dart` | TapToRunScene domain entity |
| `lib/features/scene/domain/entities/scene_action_entity.dart` | SceneAction domain entity |
| `lib/features/scene/domain/entities/data_point_entity.dart` | DataPoint domain entity |
| `lib/features/scene/data/models/smart_home_model.dart` | SmartHome JSON model |
| `lib/features/scene/data/models/tap_to_run_scene_model.dart` | TapToRunScene JSON model |
| `lib/features/scene/data/models/scene_action_model.dart` | SceneAction JSON model |
| `lib/features/scene/data/models/data_point_model.dart` | DataPoint JSON model |
| `lib/features/scene/data/datasources/tap_to_run_remote_datasource.dart` | All Smart Home API calls |
| `lib/features/scene/domain/repositories/tap_to_run_repository.dart` | Abstract repository interface |
| `lib/features/scene/data/repositories/tap_to_run_repository_impl.dart` | Repository with Either error handling |
| `lib/features/scene/domain/usecases/get_smart_homes.dart` | GetSmartHomes use case |
| `lib/features/scene/domain/usecases/get_tap_to_run_scenes.dart` | GetTapToRunScenes use case |
| `lib/features/scene/domain/usecases/create_tap_to_run_scene.dart` | CreateTapToRunScene use case |
| `lib/features/scene/domain/usecases/update_tap_to_run_scene.dart` | UpdateTapToRunScene use case |
| `lib/features/scene/domain/usecases/delete_tap_to_run_scene.dart` | DeleteTapToRunScene use case |
| `lib/features/scene/domain/usecases/execute_tap_to_run_scene.dart` | ExecuteTapToRunScene use case |
| `lib/features/scene/domain/usecases/get_device_data_points.dart` | GetDeviceDataPoints use case |
| `lib/features/scene/presentation/bloc/tap_to_run/tap_to_run_bloc.dart` | BLoC logic |
| `lib/features/scene/presentation/bloc/tap_to_run/tap_to_run_event.dart` | BLoC events |
| `lib/features/scene/presentation/bloc/tap_to_run/tap_to_run_state.dart` | BLoC states |
| `lib/features/scene/presentation/pages/tap_to_run/create_tap_to_run_page.dart` | Main create/edit scene page |
| `lib/features/scene/presentation/pages/tap_to_run/select_device_function_page.dart` | DP list + value config per dpType |
| `lib/features/scene/presentation/pages/tap_to_run/delay_config_sheet.dart` | Delay minutes+seconds picker |

### Modified Files (5 total)

| File | Change |
|------|--------|
| `lib/core/network/api_client.dart:54` | Add `put()` and `delete()` methods |
| `lib/core/auth/token_manager.dart` | Add `homeId` storage + cache |
| `lib/features/device/domain/entities/device_entity.dart` | Add `deviceProfileId` field |
| `lib/features/device/data/models/device_model.dart` | Parse `deviceProfileId` from JSON |
| `lib/core/di/injector.dart:227` | Register all Tap-to-Run DI |
| `lib/main.dart:47-59` | Add TapToRunBloc to MultiBlocProvider |
| `lib/features/home/presentation/pages/home_page.dart:671-730` | Replace empty Tap-to-Run content |

---

## Task 0: Prerequisites — Extend Core Infrastructure

These changes to existing files are required before the new feature code.

**Files:**
- Modify: `lib/core/network/api_client.dart:54`
- Modify: `lib/core/auth/token_manager.dart`
- Modify: `lib/features/device/domain/entities/device_entity.dart`
- Modify: `lib/features/device/data/models/device_model.dart`

### 0a: Add `put` and `delete` to ApiClient

- [ ] **Step 1:** Open `lib/core/network/api_client.dart` and add `put` and `delete` methods before the closing brace (replace the comment on line 54):

```dart
  Future<Response> put(String path, {Map<String, dynamic>? data}) async {
    return _dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    return _dio.delete(path);
  }
```

- [ ] **Step 2:** Verify no compile errors:

Run: `cd /Users/thuannguyen/Smart_Home_App && flutter analyze lib/core/network/api_client.dart`
Expected: No issues found

### 0b: Add `homeId` to TokenManager

- [ ] **Step 3:** Open `lib/core/auth/token_manager.dart`. Add storage key constant after line 13:

```dart
  static const String _homeIdKey = 'home_id';
```

- [ ] **Step 4:** Add memory cache field after line 22:

```dart
  String? _cachedHomeId;
```

- [ ] **Step 5:** Add `saveHomeId` method after `saveCustomerId` (after line 44):

```dart
  Future<void> saveHomeId(String homeId) async {
    await _storage.write(key: _homeIdKey, value: homeId);
    _cachedHomeId = homeId;
  }
```

- [ ] **Step 6:** Add sync getter after `getCustomerIdSync` (after line 101):

```dart
  String? getHomeIdSync() => _cachedHomeId;
```

- [ ] **Step 7:** Add to `clearTokens` — add `_storage.delete(key: _homeIdKey),` in the Future.wait list (after line 111), and `_cachedHomeId = null;` in the cache reset section (after line 117).

- [ ] **Step 8:** Add to `loadTokenToCache` — add at end of method (after line 126):

```dart
    _cachedHomeId = await _storage.read(key: _homeIdKey);
```

### 0c: Add `deviceProfileId` to DeviceEntity and DeviceModel

- [ ] **Step 9:** Open `lib/features/device/domain/entities/device_entity.dart`. Add field after `macAddress` (line 11):

```dart
  final String? deviceProfileId;
```

Add to constructor after `this.macAddress,`:

```dart
    this.deviceProfileId,
```

Add to `props` list:

```dart
    deviceProfileId,
```

- [ ] **Step 10:** Open `lib/features/device/data/models/device_model.dart`. Add `super.deviceProfileId` to constructor (after `super.macAddress`):

```dart
    super.deviceProfileId,
```

Add parsing in `fromJson` — add to the return statement:

```dart
      deviceProfileId: json['deviceProfileId']?['id']?.toString(),
```

- [ ] **Step 11:** Run impact check — `deviceProfileId` is a new optional field, so existing code won't break. Verify:

Run: `cd /Users/thuannguyen/Smart_Home_App && flutter analyze lib/features/device/`
Expected: No issues found

- [ ] **Step 12:** Commit prerequisites:

```bash
git add lib/core/network/api_client.dart lib/core/auth/token_manager.dart lib/features/device/domain/entities/device_entity.dart lib/features/device/data/models/device_model.dart
git commit -m "feat(scene): add prerequisites for Tap-to-Run — ApiClient put/delete, TokenManager homeId, DeviceEntity deviceProfileId"
```

---

## Task 1: Domain Entities

**Files:**
- Create: `lib/features/scene/domain/entities/smart_home_entity.dart`
- Create: `lib/features/scene/domain/entities/tap_to_run_scene_entity.dart`
- Create: `lib/features/scene/domain/entities/scene_action_entity.dart`
- Create: `lib/features/scene/domain/entities/data_point_entity.dart`

- [ ] **Step 1:** Create `smart_home_entity.dart`:

```dart
import 'package:equatable/equatable.dart';

class SmartHomeEntity extends Equatable {
  final String id;
  final String name;

  const SmartHomeEntity({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}
```

- [ ] **Step 2:** Create `scene_action_entity.dart`:

```dart
import 'package:equatable/equatable.dart';

class SceneActionEntity extends Equatable {
  final String actionType; // DEVICE_CONTROL, DELAY, SCENE_RUN
  final String? entityId; // device UUID or scene UUID
  final Map<String, dynamic>? executorProperty;

  // Display-only fields (not sent to API, used in UI)
  final String? deviceName;
  final String? functionName;

  const SceneActionEntity({
    required this.actionType,
    this.entityId,
    this.executorProperty,
    this.deviceName,
    this.functionName,
  });

  @override
  List<Object?> get props => [actionType, entityId, executorProperty];
}
```

- [ ] **Step 3:** Create `tap_to_run_scene_entity.dart`:

```dart
import 'package:equatable/equatable.dart';
import 'scene_action_entity.dart';

class TapToRunSceneEntity extends Equatable {
  final String id;
  final String name;
  final String sceneType; // "TAP_TO_RUN"
  final String? icon;
  final bool enabled;
  final List<SceneActionEntity> actions;

  const TapToRunSceneEntity({
    required this.id,
    required this.name,
    required this.sceneType,
    this.icon,
    required this.enabled,
    required this.actions,
  });

  @override
  List<Object?> get props => [id, name, sceneType, icon, enabled, actions];
}
```

- [ ] **Step 4:** Create `data_point_entity.dart`:

```dart
import 'package:equatable/equatable.dart';

class DataPointEntity extends Equatable {
  final int dpId;
  final String code;
  final String name;
  final String dpType; // BOOLEAN, ENUM, VALUE, STRING
  final String mode; // RW, RO, WO
  final Map<String, dynamic> constraints;

  const DataPointEntity({
    required this.dpId,
    required this.code,
    required this.name,
    required this.dpType,
    required this.mode,
    required this.constraints,
  });

  /// Returns true if this DP can be written to (for scene actions)
  bool get isWritable => mode == 'RW' || mode == 'WO';

  /// Get ENUM options from constraints (check both 'range' and 'values')
  List<String> get enumOptions {
    final range = constraints['range'];
    final values = constraints['values'];
    if (range is List) return range.cast<String>();
    if (values is List) return values.cast<String>();
    return [];
  }

  @override
  List<Object?> get props => [dpId, code, name, dpType, mode, constraints];
}
```

- [ ] **Step 5:** Verify entities compile:

Run: `cd /Users/thuannguyen/Smart_Home_App && flutter analyze lib/features/scene/domain/entities/`
Expected: No issues found

- [ ] **Step 6:** Commit:

```bash
git add lib/features/scene/domain/entities/smart_home_entity.dart lib/features/scene/domain/entities/tap_to_run_scene_entity.dart lib/features/scene/domain/entities/scene_action_entity.dart lib/features/scene/domain/entities/data_point_entity.dart
git commit -m "feat(scene): add domain entities for Tap-to-Run — SmartHome, TapToRunScene, SceneAction, DataPoint"
```

---

## Task 2: Data Models (fromJson/toJson)

**Files:**
- Create: `lib/features/scene/data/models/smart_home_model.dart`
- Create: `lib/features/scene/data/models/scene_action_model.dart`
- Create: `lib/features/scene/data/models/tap_to_run_scene_model.dart`
- Create: `lib/features/scene/data/models/data_point_model.dart`

- [ ] **Step 1:** Create `smart_home_model.dart`:

```dart
import '../../domain/entities/smart_home_entity.dart';

class SmartHomeModel extends SmartHomeEntity {
  const SmartHomeModel({
    required super.id,
    required super.name,
  });

  factory SmartHomeModel.fromJson(Map<String, dynamic> json) {
    return SmartHomeModel(
      id: json['id']?['id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}
```

- [ ] **Step 2:** Create `scene_action_model.dart`:

```dart
import '../../domain/entities/scene_action_entity.dart';

class SceneActionModel extends SceneActionEntity {
  const SceneActionModel({
    required super.actionType,
    super.entityId,
    super.executorProperty,
    super.deviceName,
    super.functionName,
  });

  factory SceneActionModel.fromJson(Map<String, dynamic> json) {
    return SceneActionModel(
      actionType: json['actionType'] as String,
      entityId: json['entityId'] as String?,
      executorProperty: json['executorProperty'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'actionType': actionType,
    };
    if (entityId != null) {
      map['entityId'] = entityId;
    }
    if (executorProperty != null) {
      map['executorProperty'] = executorProperty;
    }
    return map;
  }
}
```

- [ ] **Step 3:** Create `tap_to_run_scene_model.dart`:

```dart
import '../../domain/entities/tap_to_run_scene_entity.dart';
import 'scene_action_model.dart';

class TapToRunSceneModel extends TapToRunSceneEntity {
  const TapToRunSceneModel({
    required super.id,
    required super.name,
    required super.sceneType,
    super.icon,
    required super.enabled,
    required super.actions,
  });

  factory TapToRunSceneModel.fromJson(Map<String, dynamic> json) {
    final actionsList = json['actions'] as List<dynamic>? ?? [];
    return TapToRunSceneModel(
      id: json['id']?['id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      sceneType: json['sceneType'] ?? 'TAP_TO_RUN',
      icon: json['icon'] as String?,
      enabled: json['enabled'] ?? true,
      actions: actionsList
          .map((a) => SceneActionModel.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'sceneType': sceneType,
      if (icon != null) 'icon': icon,
      'actions': actions
          .map((a) => (a as SceneActionModel).toJson())
          .toList(),
    };
  }
}
```

- [ ] **Step 4:** Create `data_point_model.dart`:

```dart
import '../../domain/entities/data_point_entity.dart';

class DataPointModel extends DataPointEntity {
  const DataPointModel({
    required super.dpId,
    required super.code,
    required super.name,
    required super.dpType,
    required super.mode,
    required super.constraints,
  });

  factory DataPointModel.fromJson(Map<String, dynamic> json) {
    return DataPointModel(
      dpId: json['dpId'] as int,
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      dpType: json['dpType'] as String? ?? 'STRING',
      mode: json['mode'] as String? ?? 'RO',
      constraints: json['constraints'] as Map<String, dynamic>? ?? {},
    );
  }
}
```

- [ ] **Step 5:** Verify models compile:

Run: `cd /Users/thuannguyen/Smart_Home_App && flutter analyze lib/features/scene/data/models/`
Expected: No issues found

- [ ] **Step 6:** Commit:

```bash
git add lib/features/scene/data/models/smart_home_model.dart lib/features/scene/data/models/scene_action_model.dart lib/features/scene/data/models/tap_to_run_scene_model.dart lib/features/scene/data/models/data_point_model.dart
git commit -m "feat(scene): add data models for Tap-to-Run — fromJson/toJson for SmartHome, Scene, Action, DataPoint"
```

---

## Task 3: Remote Data Source

**Files:**
- Create: `lib/features/scene/data/datasources/tap_to_run_remote_datasource.dart`

- [ ] **Step 1:** Create the data source with all API methods:

```dart
import 'dart:developer';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/error/exceptions.dart';
import '../models/smart_home_model.dart';
import '../models/tap_to_run_scene_model.dart';
import '../models/data_point_model.dart';

abstract class TapToRunRemoteDataSource {
  Future<List<SmartHomeModel>> getSmartHomes();
  Future<List<TapToRunSceneModel>> getScenes(String homeId);
  Future<TapToRunSceneModel> getSceneDetail(String sceneId);
  Future<TapToRunSceneModel> createScene(String homeId, Map<String, dynamic> body);
  Future<TapToRunSceneModel> updateScene(String sceneId, Map<String, dynamic> body);
  Future<void> deleteScene(String sceneId);
  Future<Map<String, dynamic>> executeScene(String sceneId);
  Future<void> enableScene(String sceneId);
  Future<void> disableScene(String sceneId);
  Future<List<DataPointModel>> getDeviceDataPoints(String deviceProfileId);
}

class TapToRunRemoteDataSourceImpl implements TapToRunRemoteDataSource {
  final ApiClient apiClient;

  TapToRunRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<SmartHomeModel>> getSmartHomes() async {
    try {
      final response = await apiClient.get('/api/smarthome/homes');
      final List<dynamic> data = response.data is List ? response.data : [];
      return data
          .map((json) => SmartHomeModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      }
      throw ServerException(message: 'Failed to get homes: ${e.message}');
    }
  }

  @override
  Future<List<TapToRunSceneModel>> getScenes(String homeId) async {
    try {
      final response = await apiClient.get(
        '/api/smarthome/homes/$homeId/scenes',
        queryParameters: {'sceneType': 'TAP_TO_RUN'},
      );
      final List<dynamic> data = response.data is List ? response.data : [];
      return data
          .map((json) => TapToRunSceneModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      }
      throw ServerException(message: 'Failed to get scenes: ${e.message}');
    }
  }

  @override
  Future<TapToRunSceneModel> getSceneDetail(String sceneId) async {
    try {
      final response = await apiClient.get('/api/smarthome/scenes/$sceneId');
      return TapToRunSceneModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      }
      throw ServerException(message: 'Failed to get scene detail: ${e.message}');
    }
  }

  @override
  Future<TapToRunSceneModel> createScene(String homeId, Map<String, dynamic> body) async {
    try {
      final response = await apiClient.post(
        '/api/smarthome/homes/$homeId/scenes',
        data: body,
      );
      return TapToRunSceneModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      }
      throw ServerException(message: 'Failed to create scene: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<TapToRunSceneModel> updateScene(String sceneId, Map<String, dynamic> body) async {
    try {
      final response = await apiClient.put(
        '/api/smarthome/scenes/$sceneId',
        data: body,
      );
      return TapToRunSceneModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      }
      throw ServerException(message: 'Failed to update scene: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<void> deleteScene(String sceneId) async {
    try {
      await apiClient.delete('/api/smarthome/scenes/$sceneId');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      }
      throw ServerException(message: 'Failed to delete scene: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>> executeScene(String sceneId) async {
    try {
      final response = await apiClient.post('/api/smarthome/scenes/$sceneId/execute');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      }
      throw ServerException(message: 'Failed to execute scene: ${e.message}');
    }
  }

  @override
  Future<void> enableScene(String sceneId) async {
    try {
      await apiClient.put('/api/smarthome/scenes/$sceneId/enable');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      }
      throw ServerException(message: 'Failed to enable scene: ${e.message}');
    }
  }

  @override
  Future<void> disableScene(String sceneId) async {
    try {
      await apiClient.put('/api/smarthome/scenes/$sceneId/disable');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      }
      throw ServerException(message: 'Failed to disable scene: ${e.message}');
    }
  }

  @override
  Future<List<DataPointModel>> getDeviceDataPoints(String deviceProfileId) async {
    try {
      final response = await apiClient.get(
        '/api/smarthome/products/$deviceProfileId/datapoints',
      );
      final List<dynamic> data = response.data is List ? response.data : [];
      return data
          .map((json) => DataPointModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      }
      throw ServerException(message: 'Failed to get datapoints: ${e.message}');
    }
  }
}
```

- [ ] **Step 2:** Verify compile:

Run: `cd /Users/thuannguyen/Smart_Home_App && flutter analyze lib/features/scene/data/datasources/tap_to_run_remote_datasource.dart`
Expected: No issues found

- [ ] **Step 3:** Commit:

```bash
git add lib/features/scene/data/datasources/tap_to_run_remote_datasource.dart
git commit -m "feat(scene): add TapToRunRemoteDataSource — all Smart Home API calls"
```

---

## Task 4: Repository Interface + Implementation

**Files:**
- Create: `lib/features/scene/domain/repositories/tap_to_run_repository.dart`
- Create: `lib/features/scene/data/repositories/tap_to_run_repository_impl.dart`

- [ ] **Step 1:** Create abstract repository interface:

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/smart_home_entity.dart';
import '../entities/tap_to_run_scene_entity.dart';
import '../entities/scene_action_entity.dart';
import '../entities/data_point_entity.dart';

abstract class TapToRunRepository {
  Future<Either<Failure, List<SmartHomeEntity>>> getSmartHomes();
  Future<Either<Failure, List<TapToRunSceneEntity>>> getScenes(String homeId);
  Future<Either<Failure, TapToRunSceneEntity>> createScene({
    required String homeId,
    required String name,
    String? icon,
    required List<SceneActionEntity> actions,
  });
  Future<Either<Failure, TapToRunSceneEntity>> updateScene({
    required String sceneId,
    required String name,
    String? icon,
    required List<SceneActionEntity> actions,
  });
  Future<Either<Failure, void>> deleteScene(String sceneId);
  Future<Either<Failure, Map<String, dynamic>>> executeScene(String sceneId);
  Future<Either<Failure, void>> toggleScene(String sceneId, bool enabled);
  Future<Either<Failure, List<DataPointEntity>>> getDeviceDataPoints(String deviceProfileId);
}
```

- [ ] **Step 2:** Create repository implementation:

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/smart_home_entity.dart';
import '../../domain/entities/tap_to_run_scene_entity.dart';
import '../../domain/entities/scene_action_entity.dart';
import '../../domain/entities/data_point_entity.dart';
import '../../domain/repositories/tap_to_run_repository.dart';
import '../datasources/tap_to_run_remote_datasource.dart';
import '../models/scene_action_model.dart';

class TapToRunRepositoryImpl implements TapToRunRepository {
  final TapToRunRemoteDataSource remoteDataSource;

  TapToRunRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<SmartHomeEntity>>> getSmartHomes() async {
    try {
      final homes = await remoteDataSource.getSmartHomes();
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
  Future<Either<Failure, List<TapToRunSceneEntity>>> getScenes(String homeId) async {
    try {
      final scenes = await remoteDataSource.getScenes(homeId);
      return Right(scenes);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Unauthorized', message: 'Phiên đăng nhập hết hạn'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } catch (e) {
      return Left(ServerFailure('$e', message: 'Lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, TapToRunSceneEntity>> createScene({
    required String homeId,
    required String name,
    String? icon,
    required List<SceneActionEntity> actions,
  }) async {
    try {
      final body = {
        'name': name,
        'sceneType': 'TAP_TO_RUN',
        if (icon != null) 'icon': icon,
        'actions': actions.map((a) {
          final model = SceneActionModel(
            actionType: a.actionType,
            entityId: a.entityId,
            executorProperty: a.executorProperty,
          );
          return model.toJson();
        }).toList(),
      };
      final scene = await remoteDataSource.createScene(homeId, body);
      return Right(scene);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Unauthorized', message: 'Phiên đăng nhập hết hạn'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } catch (e) {
      return Left(ServerFailure('$e', message: 'Lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, TapToRunSceneEntity>> updateScene({
    required String sceneId,
    required String name,
    String? icon,
    required List<SceneActionEntity> actions,
  }) async {
    try {
      final body = {
        'name': name,
        'sceneType': 'TAP_TO_RUN',
        if (icon != null) 'icon': icon,
        'actions': actions.map((a) {
          final model = SceneActionModel(
            actionType: a.actionType,
            entityId: a.entityId,
            executorProperty: a.executorProperty,
          );
          return model.toJson();
        }).toList(),
      };
      final scene = await remoteDataSource.updateScene(sceneId, body);
      return Right(scene);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Unauthorized', message: 'Phiên đăng nhập hết hạn'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } catch (e) {
      return Left(ServerFailure('$e', message: 'Lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteScene(String sceneId) async {
    try {
      await remoteDataSource.deleteScene(sceneId);
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
  Future<Either<Failure, Map<String, dynamic>>> executeScene(String sceneId) async {
    try {
      final result = await remoteDataSource.executeScene(sceneId);
      return Right(result);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Unauthorized', message: 'Phiên đăng nhập hết hạn'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } catch (e) {
      return Left(ServerFailure('$e', message: 'Lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleScene(String sceneId, bool enabled) async {
    try {
      if (enabled) {
        await remoteDataSource.enableScene(sceneId);
      } else {
        await remoteDataSource.disableScene(sceneId);
      }
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
  Future<Either<Failure, List<DataPointEntity>>> getDeviceDataPoints(String deviceProfileId) async {
    try {
      final dataPoints = await remoteDataSource.getDeviceDataPoints(deviceProfileId);
      return Right(dataPoints);
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

- [ ] **Step 3:** Verify compile:

Run: `cd /Users/thuannguyen/Smart_Home_App && flutter analyze lib/features/scene/domain/repositories/tap_to_run_repository.dart lib/features/scene/data/repositories/tap_to_run_repository_impl.dart`
Expected: No issues found

- [ ] **Step 4:** Commit:

```bash
git add lib/features/scene/domain/repositories/tap_to_run_repository.dart lib/features/scene/data/repositories/tap_to_run_repository_impl.dart
git commit -m "feat(scene): add TapToRunRepository interface and implementation with Either error handling"
```

---

## Task 5: Use Cases

**Files:**
- Create: `lib/features/scene/domain/usecases/get_smart_homes.dart`
- Create: `lib/features/scene/domain/usecases/get_tap_to_run_scenes.dart`
- Create: `lib/features/scene/domain/usecases/create_tap_to_run_scene.dart`
- Create: `lib/features/scene/domain/usecases/update_tap_to_run_scene.dart`
- Create: `lib/features/scene/domain/usecases/delete_tap_to_run_scene.dart`
- Create: `lib/features/scene/domain/usecases/execute_tap_to_run_scene.dart`
- Create: `lib/features/scene/domain/usecases/get_device_data_points.dart`

- [ ] **Step 1:** Create all 7 use cases. Each follows the same pattern — one file per use case, simple pass-through to repository:

`get_smart_homes.dart`:
```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/smart_home_entity.dart';
import '../repositories/tap_to_run_repository.dart';

class GetSmartHomes {
  final TapToRunRepository repository;
  GetSmartHomes(this.repository);

  Future<Either<Failure, List<SmartHomeEntity>>> call() async {
    return await repository.getSmartHomes();
  }
}
```

`get_tap_to_run_scenes.dart`:
```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/tap_to_run_scene_entity.dart';
import '../repositories/tap_to_run_repository.dart';

class GetTapToRunScenes {
  final TapToRunRepository repository;
  GetTapToRunScenes(this.repository);

  Future<Either<Failure, List<TapToRunSceneEntity>>> call(String homeId) async {
    return await repository.getScenes(homeId);
  }
}
```

`create_tap_to_run_scene.dart`:
```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/tap_to_run_scene_entity.dart';
import '../entities/scene_action_entity.dart';
import '../repositories/tap_to_run_repository.dart';

class CreateTapToRunScene {
  final TapToRunRepository repository;
  CreateTapToRunScene(this.repository);

  Future<Either<Failure, TapToRunSceneEntity>> call({
    required String homeId,
    required String name,
    String? icon,
    required List<SceneActionEntity> actions,
  }) async {
    return await repository.createScene(
      homeId: homeId,
      name: name,
      icon: icon,
      actions: actions,
    );
  }
}
```

`update_tap_to_run_scene.dart`:
```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/tap_to_run_scene_entity.dart';
import '../entities/scene_action_entity.dart';
import '../repositories/tap_to_run_repository.dart';

class UpdateTapToRunScene {
  final TapToRunRepository repository;
  UpdateTapToRunScene(this.repository);

  Future<Either<Failure, TapToRunSceneEntity>> call({
    required String sceneId,
    required String name,
    String? icon,
    required List<SceneActionEntity> actions,
  }) async {
    return await repository.updateScene(
      sceneId: sceneId,
      name: name,
      icon: icon,
      actions: actions,
    );
  }
}
```

`delete_tap_to_run_scene.dart`:
```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../repositories/tap_to_run_repository.dart';

class DeleteTapToRunScene {
  final TapToRunRepository repository;
  DeleteTapToRunScene(this.repository);

  Future<Either<Failure, void>> call(String sceneId) async {
    return await repository.deleteScene(sceneId);
  }
}
```

`execute_tap_to_run_scene.dart`:
```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../repositories/tap_to_run_repository.dart';

class ExecuteTapToRunScene {
  final TapToRunRepository repository;
  ExecuteTapToRunScene(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(String sceneId) async {
    return await repository.executeScene(sceneId);
  }
}
```

`get_device_data_points.dart`:
```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/data_point_entity.dart';
import '../repositories/tap_to_run_repository.dart';

class GetDeviceDataPoints {
  final TapToRunRepository repository;
  GetDeviceDataPoints(this.repository);

  Future<Either<Failure, List<DataPointEntity>>> call(String deviceProfileId) async {
    return await repository.getDeviceDataPoints(deviceProfileId);
  }
}
```

- [ ] **Step 2:** Verify compile:

Run: `cd /Users/thuannguyen/Smart_Home_App && flutter analyze lib/features/scene/domain/usecases/`
Expected: No issues found

- [ ] **Step 3:** Commit:

```bash
git add lib/features/scene/domain/usecases/get_smart_homes.dart lib/features/scene/domain/usecases/get_tap_to_run_scenes.dart lib/features/scene/domain/usecases/create_tap_to_run_scene.dart lib/features/scene/domain/usecases/update_tap_to_run_scene.dart lib/features/scene/domain/usecases/delete_tap_to_run_scene.dart lib/features/scene/domain/usecases/execute_tap_to_run_scene.dart lib/features/scene/domain/usecases/get_device_data_points.dart
git commit -m "feat(scene): add 7 use cases for Tap-to-Run — CRUD, execute, homes, datapoints"
```

---

## Task 6: BLoC — Events, States, Logic

**Files:**
- Create: `lib/features/scene/presentation/bloc/tap_to_run/tap_to_run_event.dart`
- Create: `lib/features/scene/presentation/bloc/tap_to_run/tap_to_run_state.dart`
- Create: `lib/features/scene/presentation/bloc/tap_to_run/tap_to_run_bloc.dart`

- [ ] **Step 1:** Create `tap_to_run_event.dart`:

```dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/scene_action_entity.dart';

abstract class TapToRunEvent extends Equatable {
  const TapToRunEvent();

  @override
  List<Object?> get props => [];
}

class LoadTapToRunScenesEvent extends TapToRunEvent {}

class CreateTapToRunSceneEvent extends TapToRunEvent {
  final String name;
  final String? icon;
  final List<SceneActionEntity> actions;

  const CreateTapToRunSceneEvent({
    required this.name,
    this.icon,
    required this.actions,
  });

  @override
  List<Object?> get props => [name, icon, actions];
}

class UpdateTapToRunSceneEvent extends TapToRunEvent {
  final String sceneId;
  final String name;
  final String? icon;
  final List<SceneActionEntity> actions;

  const UpdateTapToRunSceneEvent({
    required this.sceneId,
    required this.name,
    this.icon,
    required this.actions,
  });

  @override
  List<Object?> get props => [sceneId, name, icon, actions];
}

class DeleteTapToRunSceneEvent extends TapToRunEvent {
  final String sceneId;

  const DeleteTapToRunSceneEvent(this.sceneId);

  @override
  List<Object?> get props => [sceneId];
}

class ExecuteTapToRunSceneEvent extends TapToRunEvent {
  final String sceneId;

  const ExecuteTapToRunSceneEvent(this.sceneId);

  @override
  List<Object?> get props => [sceneId];
}

class ToggleTapToRunSceneEvent extends TapToRunEvent {
  final String sceneId;
  final bool enabled;

  const ToggleTapToRunSceneEvent(this.sceneId, this.enabled);

  @override
  List<Object?> get props => [sceneId, enabled];
}
```

- [ ] **Step 2:** Create `tap_to_run_state.dart`:

```dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/tap_to_run_scene_entity.dart';

abstract class TapToRunState extends Equatable {
  const TapToRunState();

  @override
  List<Object?> get props => [];
}

class TapToRunInitial extends TapToRunState {}

class TapToRunLoading extends TapToRunState {}

class TapToRunLoaded extends TapToRunState {
  final List<TapToRunSceneEntity> scenes;

  const TapToRunLoaded(this.scenes);

  @override
  List<Object?> get props => [scenes];
}

class TapToRunError extends TapToRunState {
  final String message;

  const TapToRunError(this.message);

  @override
  List<Object?> get props => [message];
}

class TapToRunCreating extends TapToRunState {}

class TapToRunCreated extends TapToRunState {}

class TapToRunExecuting extends TapToRunState {
  final String sceneId;
  final List<TapToRunSceneEntity> scenes;

  const TapToRunExecuting(this.sceneId, this.scenes);

  @override
  List<Object?> get props => [sceneId, scenes];
}

class TapToRunExecuteResult extends TapToRunState {
  final String status; // SUCCESS, PARTIAL, FAILURE
  final String details;
  final List<TapToRunSceneEntity> scenes;

  const TapToRunExecuteResult({
    required this.status,
    required this.details,
    required this.scenes,
  });

  @override
  List<Object?> get props => [status, details, scenes];
}
```

- [ ] **Step 3:** Create `tap_to_run_bloc.dart`:

```dart
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/auth/token_manager.dart';
import '../../../../core/di/injector.dart';
import '../../../domain/entities/tap_to_run_scene_entity.dart';
import '../../../domain/usecases/get_smart_homes.dart';
import '../../../domain/usecases/get_tap_to_run_scenes.dart';
import '../../../domain/usecases/create_tap_to_run_scene.dart';
import '../../../domain/usecases/update_tap_to_run_scene.dart';
import '../../../domain/usecases/delete_tap_to_run_scene.dart';
import '../../../domain/usecases/execute_tap_to_run_scene.dart';
import 'tap_to_run_event.dart';
import 'tap_to_run_state.dart';

class TapToRunBloc extends Bloc<TapToRunEvent, TapToRunState> {
  final GetSmartHomes getSmartHomes;
  final GetTapToRunScenes getTapToRunScenes;
  final CreateTapToRunScene createTapToRunScene;
  final UpdateTapToRunScene updateTapToRunScene;
  final DeleteTapToRunScene deleteTapToRunScene;
  final ExecuteTapToRunScene executeTapToRunScene;

  String? _homeId;

  TapToRunBloc({
    required this.getSmartHomes,
    required this.getTapToRunScenes,
    required this.createTapToRunScene,
    required this.updateTapToRunScene,
    required this.deleteTapToRunScene,
    required this.executeTapToRunScene,
  }) : super(TapToRunInitial()) {
    on<LoadTapToRunScenesEvent>(_onLoadScenes);
    on<CreateTapToRunSceneEvent>(_onCreateScene);
    on<UpdateTapToRunSceneEvent>(_onUpdateScene);
    on<DeleteTapToRunSceneEvent>(_onDeleteScene);
    on<ExecuteTapToRunSceneEvent>(_onExecuteScene);
    on<ToggleTapToRunSceneEvent>(_onToggleScene);
  }

  String? get homeId => _homeId;

  Future<String?> _ensureHomeId() async {
    if (_homeId != null) return _homeId;

    // Check cached homeId first
    final cached = sl<TokenManager>().getHomeIdSync();
    if (cached != null && cached.isNotEmpty) {
      _homeId = cached;
      return _homeId;
    }

    // Fetch from API
    final result = await getSmartHomes();
    return result.fold(
      (failure) => null,
      (homes) {
        if (homes.isNotEmpty) {
          _homeId = homes.first.id;
          sl<TokenManager>().saveHomeId(_homeId!);
          return _homeId;
        }
        return null;
      },
    );
  }

  Future<void> _onLoadScenes(
    LoadTapToRunScenesEvent event,
    Emitter<TapToRunState> emit,
  ) async {
    emit(TapToRunLoading());

    final homeId = await _ensureHomeId();
    if (homeId == null) {
      emit(const TapToRunError('Không tìm thấy Home'));
      return;
    }

    final result = await getTapToRunScenes(homeId);
    result.fold(
      (failure) => emit(TapToRunError(failure.message)),
      (scenes) => emit(TapToRunLoaded(scenes)),
    );
  }

  Future<void> _onCreateScene(
    CreateTapToRunSceneEvent event,
    Emitter<TapToRunState> emit,
  ) async {
    emit(TapToRunCreating());

    final homeId = await _ensureHomeId();
    if (homeId == null) {
      emit(const TapToRunError('Không tìm thấy Home'));
      return;
    }

    final result = await createTapToRunScene(
      homeId: homeId,
      name: event.name,
      icon: event.icon,
      actions: event.actions,
    );

    result.fold(
      (failure) => emit(TapToRunError(failure.message)),
      (_) {
        emit(TapToRunCreated());
        add(LoadTapToRunScenesEvent());
      },
    );
  }

  Future<void> _onUpdateScene(
    UpdateTapToRunSceneEvent event,
    Emitter<TapToRunState> emit,
  ) async {
    emit(TapToRunCreating());

    final result = await updateTapToRunScene(
      sceneId: event.sceneId,
      name: event.name,
      icon: event.icon,
      actions: event.actions,
    );

    result.fold(
      (failure) => emit(TapToRunError(failure.message)),
      (_) {
        emit(TapToRunCreated());
        add(LoadTapToRunScenesEvent());
      },
    );
  }

  Future<void> _onDeleteScene(
    DeleteTapToRunSceneEvent event,
    Emitter<TapToRunState> emit,
  ) async {
    // Optimistic delete
    final currentScenes = state is TapToRunLoaded
        ? (state as TapToRunLoaded).scenes
        : <TapToRunSceneEntity>[];

    final updated = currentScenes.where((s) => s.id != event.sceneId).toList();
    emit(TapToRunLoaded(updated));

    final result = await deleteTapToRunScene(event.sceneId);
    result.fold(
      (failure) {
        // Revert on failure
        emit(TapToRunLoaded(currentScenes));
      },
      (_) {},
    );
  }

  Future<void> _onExecuteScene(
    ExecuteTapToRunSceneEvent event,
    Emitter<TapToRunState> emit,
  ) async {
    final currentScenes = state is TapToRunLoaded
        ? (state as TapToRunLoaded).scenes
        : state is TapToRunExecuting
            ? (state as TapToRunExecuting).scenes
            : <TapToRunSceneEntity>[];

    emit(TapToRunExecuting(event.sceneId, currentScenes));

    final result = await executeTapToRunScene(event.sceneId);
    result.fold(
      (failure) => emit(TapToRunLoaded(currentScenes)),
      (data) {
        final status = data['status'] as String? ?? 'FAILURE';
        final details = (data['executionDetails'] as Map<String, dynamic>?)?['details'] as String? ?? '';
        emit(TapToRunExecuteResult(
          status: status,
          details: details,
          scenes: currentScenes,
        ));
      },
    );
  }

  Future<void> _onToggleScene(
    ToggleTapToRunSceneEvent event,
    Emitter<TapToRunState> emit,
  ) async {
    // Note: Tap-to-Run scenes don't have enable/disable in the UI spec,
    // but the API supports it. Keep for future use.
    if (state is TapToRunLoaded) {
      final currentScenes = (state as TapToRunLoaded).scenes;
      final updated = currentScenes.map((s) {
        if (s.id == event.sceneId) {
          return TapToRunSceneEntity(
            id: s.id,
            name: s.name,
            sceneType: s.sceneType,
            icon: s.icon,
            enabled: event.enabled,
            actions: s.actions,
          );
        }
        return s;
      }).toList();
      emit(TapToRunLoaded(updated));
    }
  }
}
```

- [ ] **Step 4:** Verify compile:

Run: `cd /Users/thuannguyen/Smart_Home_App && flutter analyze lib/features/scene/presentation/bloc/tap_to_run/`
Expected: No issues found

- [ ] **Step 5:** Commit:

```bash
git add lib/features/scene/presentation/bloc/tap_to_run/
git commit -m "feat(scene): add TapToRunBloc with events and states — load, create, update, delete, execute"
```

---

## Task 7: DI Registration + main.dart

**Files:**
- Modify: `lib/core/di/injector.dart:227`
- Modify: `lib/main.dart:47-59`

- [ ] **Step 1:** Add imports to `injector.dart` (after line 39, after existing scene imports):

```dart
// Tap-to-Run Scene
import '../../features/scene/data/datasources/tap_to_run_remote_datasource.dart';
import '../../features/scene/data/repositories/tap_to_run_repository_impl.dart';
import '../../features/scene/domain/repositories/tap_to_run_repository.dart';
import '../../features/scene/domain/usecases/get_smart_homes.dart';
import '../../features/scene/domain/usecases/get_tap_to_run_scenes.dart';
import '../../features/scene/domain/usecases/create_tap_to_run_scene.dart';
import '../../features/scene/domain/usecases/update_tap_to_run_scene.dart';
import '../../features/scene/domain/usecases/delete_tap_to_run_scene.dart';
import '../../features/scene/domain/usecases/execute_tap_to_run_scene.dart';
import '../../features/scene/domain/usecases/get_device_data_points.dart';
import '../../features/scene/presentation/bloc/tap_to_run/tap_to_run_bloc.dart';
```

- [ ] **Step 2:** Add registrations in `setupInjector()` — insert before the closing `}` of the function (before line 227):

```dart
  // ========== Tap-to-Run Scene Feature ==========
  // Data sources
  sl.registerLazySingleton<TapToRunRemoteDataSource>(
    () => TapToRunRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // Repositories
  sl.registerLazySingleton<TapToRunRepository>(
    () => TapToRunRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetSmartHomes(sl()));
  sl.registerLazySingleton(() => GetTapToRunScenes(sl()));
  sl.registerLazySingleton(() => CreateTapToRunScene(sl()));
  sl.registerLazySingleton(() => UpdateTapToRunScene(sl()));
  sl.registerLazySingleton(() => DeleteTapToRunScene(sl()));
  sl.registerLazySingleton(() => ExecuteTapToRunScene(sl()));
  sl.registerLazySingleton(() => GetDeviceDataPoints(sl()));

  // BLoC
  sl.registerFactory(
    () => TapToRunBloc(
      getSmartHomes: sl(),
      getTapToRunScenes: sl(),
      createTapToRunScene: sl(),
      updateTapToRunScene: sl(),
      deleteTapToRunScene: sl(),
      executeTapToRunScene: sl(),
    ),
  );
```

- [ ] **Step 3:** Update `main.dart` — add import and BlocProvider. Add import after line 9:

```dart
import 'features/scene/presentation/bloc/tap_to_run/tap_to_run_bloc.dart';
import 'features/scene/presentation/bloc/tap_to_run/tap_to_run_event.dart';
```

Add to MultiBlocProvider `providers` list (after line 58, before the closing `]`):

```dart
        BlocProvider(
          create: (_) => GetIt.instance<TapToRunBloc>()
            ..add(LoadTapToRunScenesEvent()),
        ),
```

- [ ] **Step 4:** Verify compile:

Run: `cd /Users/thuannguyen/Smart_Home_App && flutter analyze lib/core/di/injector.dart lib/main.dart`
Expected: No issues found

- [ ] **Step 5:** Commit:

```bash
git add lib/core/di/injector.dart lib/main.dart
git commit -m "feat(scene): register TapToRunBloc and all dependencies in DI + MultiBlocProvider"
```

---

## Task 8: UI — Scene List (Replace Empty Tap-to-Run Tab)

**Files:**
- Modify: `lib/features/home/presentation/pages/home_page.dart:671-730`

- [ ] **Step 1:** Add imports at the top of `home_page.dart` (with existing imports):

```dart
import 'package:smart_curtain_app/features/scene/presentation/bloc/tap_to_run/tap_to_run_bloc.dart';
import 'package:smart_curtain_app/features/scene/presentation/bloc/tap_to_run/tap_to_run_event.dart';
import 'package:smart_curtain_app/features/scene/presentation/bloc/tap_to_run/tap_to_run_state.dart';
import 'package:smart_curtain_app/features/scene/domain/entities/tap_to_run_scene_entity.dart';
import 'package:smart_curtain_app/features/scene/presentation/pages/tap_to_run/create_tap_to_run_page.dart';
```

- [ ] **Step 2:** Replace the `_buildTapToRunContent()` method (lines 671-730) with:

```dart
  Widget _buildTapToRunContent() {
    return BlocConsumer<TapToRunBloc, TapToRunState>(
      listener: (context, state) {
        if (state is TapToRunExecuteResult) {
          final color = state.status == 'SUCCESS'
              ? Colors.green
              : state.status == 'PARTIAL'
                  ? Colors.orange
                  : Colors.red;
          final message = state.status == 'SUCCESS'
              ? 'Thực thi thành công!'
              : state.status == 'PARTIAL'
                  ? 'Một số action thất bại'
                  : 'Thực thi thất bại';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: color,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is TapToRunLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is TapToRunError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.message, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<TapToRunBloc>().add(LoadTapToRunScenesEvent()),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        final scenes = state is TapToRunLoaded
            ? state.scenes
            : state is TapToRunExecuting
                ? state.scenes
                : state is TapToRunExecuteResult
                    ? state.scenes
                    : <TapToRunSceneEntity>[];

        if (scenes.isEmpty) {
          return _buildEmptyTapToRun();
        }

        return _buildTapToRunList(context, scenes, state);
      },
    );
  }

  Widget _buildEmptyTapToRun() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.touch_app_outlined, size: 64, color: Colors.grey.shade300),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            'Tạo một Tap-to-Run scene để điều khiển thiết bị nhanh chóng chỉ với một chạm.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade500, height: 1.5),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: 200,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            onPressed: () => _navigateToCreateTapToRun(),
            child: const Text('Tạo Scene', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildTapToRunList(BuildContext context, List<TapToRunSceneEntity> scenes, TapToRunState state) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<TapToRunBloc>().add(LoadTapToRunScenesEvent());
            },
            child: ListView.separated(
              itemCount: scenes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final scene = scenes[index];
                final isExecuting = state is TapToRunExecuting && state.sceneId == scene.id;
                return Dismissible(
                  key: Key('tap_to_run_${scene.id}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (_) async {
                    return await showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Xóa scene?'),
                        content: Text('Bạn có chắc muốn xóa "${scene.name}"?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xóa', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    );
                  },
                  onDismissed: (_) {
                    context.read<TapToRunBloc>().add(DeleteTapToRunSceneEvent(scene.id));
                  },
                  child: GestureDetector(
                    onTap: () => _navigateToEditTapToRun(scene),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(200),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFF2196F3).withAlpha(30),
                            child: const Icon(Icons.play_circle_outline, color: Color(0xFF2196F3)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(scene.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text(
                                  '${scene.actions.length} action${scene.actions.length > 1 ? 's' : ''}',
                                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 48,
                            height: 48,
                            child: isExecuting
                                ? const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : IconButton(
                                    icon: const Icon(Icons.play_arrow_rounded, color: Color(0xFF2196F3), size: 28),
                                    onPressed: () {
                                      context.read<TapToRunBloc>().add(ExecuteTapToRunSceneEvent(scene.id));
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            onPressed: () => _navigateToCreateTapToRun(),
            icon: const Icon(Icons.add),
            label: const Text('Thêm Scene', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  void _navigateToCreateTapToRun() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateTapToRunPage()),
    );
    if (result == true && mounted) {
      context.read<TapToRunBloc>().add(LoadTapToRunScenesEvent());
    }
  }

  void _navigateToEditTapToRun(TapToRunSceneEntity scene) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreateTapToRunPage(existingScene: scene)),
    );
    if (result == true && mounted) {
      context.read<TapToRunBloc>().add(LoadTapToRunScenesEvent());
    }
  }
```

- [ ] **Step 3:** Verify compile:

Run: `cd /Users/thuannguyen/Smart_Home_App && flutter analyze lib/features/home/presentation/pages/home_page.dart`
Expected: May show error for missing `CreateTapToRunPage` — that's OK, it will be created in Task 9.

- [ ] **Step 4:** Commit (after Task 9 is done so all references resolve):

*Commit will be done at end of Task 9.*

---

## Task 9: UI — Create/Edit Tap-to-Run Page

**Files:**
- Create: `lib/features/scene/presentation/pages/tap_to_run/create_tap_to_run_page.dart`

This is the main page where users build their scene: name, icon, and THEN action list.

- [ ] **Step 1:** Create `create_tap_to_run_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/tap_to_run_scene_entity.dart';
import '../../../domain/entities/scene_action_entity.dart';
import '../../../data/models/scene_action_model.dart';
import '../../bloc/tap_to_run/tap_to_run_bloc.dart';
import '../../bloc/tap_to_run/tap_to_run_event.dart';
import '../../bloc/tap_to_run/tap_to_run_state.dart';
import 'select_device_function_page.dart';
import 'delay_config_sheet.dart';
import '../../../../../features/device/presentation/bloc/device_bloc.dart';
import '../../../../../features/device/presentation/bloc/device_event.dart';
import '../../../../../features/device/domain/entities/device_entity.dart';

class CreateTapToRunPage extends StatefulWidget {
  final TapToRunSceneEntity? existingScene;

  const CreateTapToRunPage({super.key, this.existingScene});

  @override
  State<CreateTapToRunPage> createState() => _CreateTapToRunPageState();
}

class _CreateTapToRunPageState extends State<CreateTapToRunPage> {
  final _nameController = TextEditingController();
  final List<SceneActionEntity> _actions = [];
  bool get _isEditing => widget.existingScene != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.existingScene!.name;
      _actions.addAll(widget.existingScene!.actions);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TapToRunBloc, TapToRunState>(
      listener: (context, state) {
        if (state is TapToRunCreated) {
          Navigator.pop(context, true);
        } else if (state is TapToRunError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: Text(_isEditing ? 'Sửa Scene' : 'Tạo Tap-to-Run'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0.5,
          actions: [
            TextButton(
              onPressed: _saveScene,
              child: const Text('Lưu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Scene name
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Tên Scene',
                          hintText: 'Ví dụ: Buổi sáng, Đi ngủ...',
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.edit_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // THEN section header
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2196F3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'THEN',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2196F3)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Actions list
                    if (_actions.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.add_circle_outline, size: 48, color: Colors.grey.shade300),
                            const SizedBox(height: 8),
                            Text('Thêm ít nhất 1 action', style: TextStyle(color: Colors.grey.shade500)),
                          ],
                        ),
                      )
                    else
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _actions.length,
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) newIndex--;
                            final item = _actions.removeAt(oldIndex);
                            _actions.insert(newIndex, item);
                          });
                        },
                        itemBuilder: (context, index) {
                          return _buildActionCard(index, key: ValueKey('action_$index'));
                        },
                      ),

                    const SizedBox(height: 12),

                    // Add action button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: const BorderSide(color: Color(0xFF2196F3)),
                        ),
                        onPressed: _showAddActionSheet,
                        icon: const Icon(Icons.add, color: Color(0xFF2196F3)),
                        label: const Text('Thêm Action', style: TextStyle(color: Color(0xFF2196F3), fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(int index, {Key? key}) {
    final action = _actions[index];
    IconData icon;
    String title;
    String subtitle;

    switch (action.actionType) {
      case 'DEVICE_CONTROL':
        icon = Icons.devices;
        title = action.deviceName ?? 'Thiết bị';
        final dp = action.executorProperty;
        final dpId = dp?['dpId'];
        final dpValue = dp?['dpValue'];
        subtitle = action.functionName != null
            ? '${action.functionName}: $dpValue'
            : 'dpId $dpId: $dpValue';
        break;
      case 'DELAY':
        icon = Icons.timer_outlined;
        title = 'Chờ';
        final minutes = action.executorProperty?['minutes'] ?? 0;
        final seconds = action.executorProperty?['seconds'] ?? 0;
        subtitle = minutes > 0 ? '${minutes}m ${seconds}s' : '${seconds}s';
        break;
      case 'SCENE_RUN':
        icon = Icons.play_circle_outline;
        title = 'Chạy Scene';
        subtitle = action.deviceName ?? action.entityId ?? '';
        break;
      default:
        icon = Icons.help_outline;
        title = action.actionType;
        subtitle = '';
    }

    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF2196F3).withAlpha(30),
          child: Icon(icon, color: const Color(0xFF2196F3), size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.drag_handle, color: Colors.grey.shade400),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => setState(() => _actions.removeAt(index)),
              child: const Icon(Icons.close, color: Colors.red, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddActionSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Thêm Action', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE3F2FD),
                child: Icon(Icons.devices, color: Color(0xFF2196F3)),
              ),
              title: const Text('Điều khiển thiết bị'),
              subtitle: const Text('Chọn thiết bị và chức năng'),
              onTap: () {
                Navigator.pop(ctx);
                _addDeviceAction();
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFFF3E0),
                child: Icon(Icons.timer_outlined, color: Colors.orange),
              ),
              title: const Text('Delay'),
              subtitle: const Text('Chờ một khoảng thời gian'),
              onTap: () {
                Navigator.pop(ctx);
                _addDelayAction();
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8F5E9),
                child: Icon(Icons.play_circle_outline, color: Colors.green),
              ),
              title: const Text('Chạy Scene khác'),
              subtitle: const Text('Trigger một Tap-to-Run scene'),
              onTap: () {
                Navigator.pop(ctx);
                _addRunSceneAction();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _addDeviceAction() async {
    // Step 1: Select device from existing DeviceBloc
    final deviceState = context.read<DeviceBloc>().state;
    List<DeviceEntity> devices = [];
    if (deviceState is DeviceLoaded) {
      devices = deviceState.devices;
    }

    if (devices.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có thiết bị nào')),
      );
      return;
    }

    final selectedDevice = await showModalBottomSheet<DeviceEntity>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.8,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Chọn thiết bị', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: devices.length,
                itemBuilder: (_, i) {
                  final device = devices[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: device.isOnline ? Colors.green.withAlpha(30) : Colors.grey.withAlpha(30),
                      child: Icon(
                        Icons.devices,
                        color: device.isOnline ? Colors.green : Colors.grey,
                      ),
                    ),
                    title: Text(device.name),
                    subtitle: Text(device.type),
                    trailing: device.isOnline
                        ? const Icon(Icons.circle, color: Colors.green, size: 10)
                        : const Icon(Icons.circle, color: Colors.grey, size: 10),
                    onTap: () => Navigator.pop(ctx, device),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

    if (selectedDevice == null || !mounted) return;

    // Step 2: Navigate to function selection page
    final profileId = selectedDevice.deviceProfileId;
    if (profileId == null || profileId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thiết bị không có thông tin profile')),
      );
      return;
    }

    final action = await Navigator.push<SceneActionEntity>(
      context,
      MaterialPageRoute(
        builder: (_) => SelectDeviceFunctionPage(
          deviceId: selectedDevice.id,
          deviceName: selectedDevice.name,
          deviceProfileId: profileId,
        ),
      ),
    );

    if (action != null && mounted) {
      setState(() => _actions.add(action));
    }
  }

  Future<void> _addDelayAction() async {
    final result = await showModalBottomSheet<Map<String, int>>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const DelayConfigSheet(),
    );

    if (result != null && mounted) {
      setState(() {
        _actions.add(SceneActionEntity(
          actionType: 'DELAY',
          executorProperty: {
            'minutes': result['minutes'] ?? 0,
            'seconds': result['seconds'] ?? 0,
          },
        ));
      });
    }
  }

  Future<void> _addRunSceneAction() async {
    final bloc = context.read<TapToRunBloc>();
    final state = bloc.state;
    List<TapToRunSceneEntity> scenes = [];
    if (state is TapToRunLoaded) {
      scenes = state.scenes;
    }

    // Filter out self when editing
    if (_isEditing) {
      scenes = scenes.where((s) => s.id != widget.existingScene!.id).toList();
    }

    if (scenes.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có scene nào khác')),
      );
      return;
    }

    final selected = await showModalBottomSheet<TapToRunSceneEntity>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Chọn Scene', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ...scenes.map((s) => ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8F5E9),
                child: Icon(Icons.play_circle_outline, color: Colors.green),
              ),
              title: Text(s.name),
              subtitle: Text('${s.actions.length} actions'),
              onTap: () => Navigator.pop(ctx, s),
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );

    if (selected != null && mounted) {
      setState(() {
        _actions.add(SceneActionEntity(
          actionType: 'SCENE_RUN',
          entityId: selected.id,
          deviceName: selected.name,
        ));
      });
    }
  }

  void _saveScene() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên scene')),
      );
      return;
    }
    if (_actions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng thêm ít nhất 1 action')),
      );
      return;
    }

    if (_isEditing) {
      context.read<TapToRunBloc>().add(UpdateTapToRunSceneEvent(
        sceneId: widget.existingScene!.id,
        name: name,
        actions: _actions,
      ));
    } else {
      context.read<TapToRunBloc>().add(CreateTapToRunSceneEvent(
        name: name,
        actions: _actions,
      ));
    }
  }
}
```

- [ ] **Step 2:** Verify compile (may still have missing pages — that's OK):

Run: `cd /Users/thuannguyen/Smart_Home_App && flutter analyze lib/features/scene/presentation/pages/tap_to_run/create_tap_to_run_page.dart`

- [ ] **Step 3:** Commit with Task 8 changes:

```bash
git add lib/features/home/presentation/pages/home_page.dart lib/features/scene/presentation/pages/tap_to_run/create_tap_to_run_page.dart
git commit -m "feat(scene): add Tap-to-Run scene list UI and create/edit page with action builder"
```

---

## Task 10: UI — Select Device Function Page (DataPoint Config)

**Files:**
- Create: `lib/features/scene/presentation/pages/tap_to_run/select_device_function_page.dart`

This page fetches DataPoints for a device and renders UI per dpType (toggle/dropdown/slider/text). When user selects a function and value, it returns a `SceneActionEntity`.

- [ ] **Step 1:** Create `select_device_function_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../domain/entities/data_point_entity.dart';
import '../../../domain/entities/scene_action_entity.dart';
import '../../../domain/usecases/get_device_data_points.dart';

class SelectDeviceFunctionPage extends StatefulWidget {
  final String deviceId;
  final String deviceName;
  final String deviceProfileId;

  const SelectDeviceFunctionPage({
    super.key,
    required this.deviceId,
    required this.deviceName,
    required this.deviceProfileId,
  });

  @override
  State<SelectDeviceFunctionPage> createState() => _SelectDeviceFunctionPageState();
}

class _SelectDeviceFunctionPageState extends State<SelectDeviceFunctionPage> {
  List<DataPointEntity>? _dataPoints;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDataPoints();
  }

  Future<void> _loadDataPoints() async {
    setState(() { _loading = true; _error = null; });

    final useCase = GetIt.instance<GetDeviceDataPoints>();
    final result = await useCase(widget.deviceProfileId);

    if (!mounted) return;
    result.fold(
      (failure) => setState(() { _error = failure.message; _loading = false; }),
      (dataPoints) {
        // Only show writable DPs (RW or WO)
        final writable = dataPoints.where((dp) => dp.isWritable).toList();
        setState(() { _dataPoints = writable; _loading = false; });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(widget.deviceName),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _loadDataPoints, child: const Text('Thử lại')),
                  ],
                ))
              : _dataPoints == null || _dataPoints!.isEmpty
                  ? const Center(child: Text('Không có chức năng nào'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _dataPoints!.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final dp = _dataPoints![index];
                        return _buildDataPointCard(dp);
                      },
                    ),
    );
  }

  Widget _buildDataPointCard(DataPointEntity dp) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dp.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('${dp.dpType} • dpId: ${dp.dpId}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          const SizedBox(height: 12),
          _buildValueSelector(dp),
        ],
      ),
    );
  }

  Widget _buildValueSelector(DataPointEntity dp) {
    switch (dp.dpType) {
      case 'BOOLEAN':
        return _buildBooleanSelector(dp);
      case 'ENUM':
        return _buildEnumSelector(dp);
      case 'VALUE':
        return _buildValueSlider(dp);
      case 'STRING':
        return _buildStringInput(dp);
      default:
        return Text('Unsupported type: ${dp.dpType}');
    }
  }

  Widget _buildBooleanSelector(DataPointEntity dp) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => _returnAction(dp, true),
            child: const Text('ON'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => _returnAction(dp, false),
            child: const Text('OFF'),
          ),
        ),
      ],
    );
  }

  Widget _buildEnumSelector(DataPointEntity dp) {
    final options = dp.enumOptions;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => _returnAction(dp, option),
          child: Text(option),
        );
      }).toList(),
    );
  }

  Widget _buildValueSlider(DataPointEntity dp) {
    final min = (dp.constraints['min'] as num?)?.toDouble() ?? 0;
    final max = (dp.constraints['max'] as num?)?.toDouble() ?? 100;
    final step = (dp.constraints['step'] as num?)?.toDouble() ?? 1;
    double currentValue = min;

    return StatefulBuilder(
      builder: (context, setLocalState) => Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${min.toInt()}'),
              Text(
                '${currentValue.toInt()}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2196F3)),
              ),
              Text('${max.toInt()}'),
            ],
          ),
          Slider(
            value: currentValue,
            min: min,
            max: max,
            divisions: ((max - min) / step).round(),
            onChanged: (v) => setLocalState(() => currentValue = v),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => _returnAction(dp, currentValue.toInt()),
            child: Text('Đặt ${currentValue.toInt()}'),
          ),
        ],
      ),
    );
  }

  Widget _buildStringInput(DataPointEntity dp) {
    final controller = TextEditingController();
    final maxLen = dp.constraints['maxlen'] as int?;
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            maxLength: maxLen,
            decoration: InputDecoration(
              hintText: 'Nhập giá trị...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            if (controller.text.isNotEmpty) {
              _returnAction(dp, controller.text);
            }
          },
          child: const Text('OK'),
        ),
      ],
    );
  }

  void _returnAction(DataPointEntity dp, dynamic value) {
    final action = SceneActionEntity(
      actionType: 'DEVICE_CONTROL',
      entityId: widget.deviceId,
      executorProperty: {
        'dpId': dp.dpId,
        'dpValue': value,
      },
      deviceName: widget.deviceName,
      functionName: dp.name,
    );
    Navigator.pop(context, action);
  }
}
```

- [ ] **Step 2:** Verify compile:

Run: `cd /Users/thuannguyen/Smart_Home_App && flutter analyze lib/features/scene/presentation/pages/tap_to_run/select_device_function_page.dart`
Expected: No issues found

- [ ] **Step 3:** Commit:

```bash
git add lib/features/scene/presentation/pages/tap_to_run/select_device_function_page.dart
git commit -m "feat(scene): add SelectDeviceFunctionPage — DP-based UI (toggle/enum/slider/text) for device actions"
```

---

## Task 11: UI — Delay Config Sheet

**Files:**
- Create: `lib/features/scene/presentation/pages/tap_to_run/delay_config_sheet.dart`

- [ ] **Step 1:** Create `delay_config_sheet.dart`:

```dart
import 'package:flutter/material.dart';

class DelayConfigSheet extends StatefulWidget {
  const DelayConfigSheet({super.key});

  @override
  State<DelayConfigSheet> createState() => _DelayConfigSheetState();
}

class _DelayConfigSheetState extends State<DelayConfigSheet> {
  int _minutes = 0;
  int _seconds = 5;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Cài đặt Delay', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Tối đa 5 phút', style: TextStyle(color: Colors.grey[500])),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Minutes
                Column(
                  children: [
                    const Text('Phút', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 80,
                      height: 120,
                      child: ListWheelScrollView.useDelegate(
                        itemExtent: 40,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (i) => setState(() {
                          _minutes = i;
                          // Cap total at 5 min
                          if (_minutes == 5) _seconds = 0;
                        }),
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (_, i) => Center(
                            child: Text(
                              '$i',
                              style: TextStyle(
                                fontSize: i == _minutes ? 24 : 18,
                                fontWeight: i == _minutes ? FontWeight.bold : FontWeight.normal,
                                color: i == _minutes ? const Color(0xFF2196F3) : Colors.grey,
                              ),
                            ),
                          ),
                          childCount: 6, // 0-5
                        ),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(':', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                // Seconds
                Column(
                  children: [
                    const Text('Giây', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 80,
                      height: 120,
                      child: ListWheelScrollView.useDelegate(
                        itemExtent: 40,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (i) => setState(() {
                          if (_minutes < 5) _seconds = i;
                        }),
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (_, i) => Center(
                            child: Text(
                              '${i.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: i == _seconds ? 24 : 18,
                                fontWeight: i == _seconds ? FontWeight.bold : FontWeight.normal,
                                color: i == _seconds ? const Color(0xFF2196F3) : Colors.grey,
                              ),
                            ),
                          ),
                          childCount: 60, // 0-59
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _minutes > 0 ? '$_minutes phút $_seconds giây' : '$_seconds giây',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (_minutes == 0 && _seconds == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vui lòng chọn thời gian > 0')),
                    );
                    return;
                  }
                  Navigator.pop(context, {'minutes': _minutes, 'seconds': _seconds});
                },
                child: const Text('Xác nhận', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2:** Verify compile:

Run: `cd /Users/thuannguyen/Smart_Home_App && flutter analyze lib/features/scene/presentation/pages/tap_to_run/delay_config_sheet.dart`
Expected: No issues found

- [ ] **Step 3:** Commit:

```bash
git add lib/features/scene/presentation/pages/tap_to_run/delay_config_sheet.dart
git commit -m "feat(scene): add DelayConfigSheet — minutes/seconds picker with 5-min max"
```

---

## Task 12: Full Integration — Verify and Test

- [ ] **Step 1:** Run full project analysis:

Run: `cd /Users/thuannguyen/Smart_Home_App && flutter analyze`
Expected: No issues (or only pre-existing issues)

- [ ] **Step 2:** Hot reload/restart on device and test the Tap-to-Run tab:

Run: `cd /Users/thuannguyen/Smart_Home_App && flutter run`

**Test checklist:**
1. Open Scene tab → switch to "Tap-to-Run" sub-tab
2. Verify scene list loads (or shows empty state if no scenes)
3. Tap "Tạo Scene" → CreateTapToRunPage opens
4. Enter name "Test Scene"
5. Tap "Thêm Action" → bottom sheet shows 3 options
6. Select "Điều khiển thiết bị" → device list shows
7. Select a device → DataPoint functions load
8. Select a function (e.g., "Control" → "open") → action added to list
9. Tap "Thêm Action" → "Delay" → set 3 seconds → added
10. Tap "Lưu" → scene created, navigates back to list
11. Verify scene appears in the list
12. Tap Execute (play button) → verify toast shows result
13. Swipe scene → delete confirmation → deleted
14. Tap a scene card → edit mode opens with pre-filled data

- [ ] **Step 3:** Final commit:

```bash
git add -A
git commit -m "feat(scene): complete Tap-to-Run smart scene implementation — CRUD, execute, device control, delay, run scene"
```

---

## Summary

| Task | Description | Files | Estimated Steps |
|------|-------------|-------|-----------------|
| 0 | Prerequisites (ApiClient, TokenManager, DeviceEntity) | 4 modified | 12 |
| 1 | Domain Entities | 4 new | 6 |
| 2 | Data Models (fromJson/toJson) | 4 new | 6 |
| 3 | Remote Data Source | 1 new | 3 |
| 4 | Repository Interface + Impl | 2 new | 4 |
| 5 | Use Cases | 7 new | 3 |
| 6 | BLoC (Events, States, Logic) | 3 new | 5 |
| 7 | DI Registration + main.dart | 2 modified | 5 |
| 8 | UI — Scene List (Tap-to-Run tab) | 1 modified | 4 |
| 9 | UI — Create/Edit Page | 1 new | 3 |
| 10 | UI — Select Device Function | 1 new | 3 |
| 11 | UI — Delay Config | 1 new | 3 |
| 12 | Integration Test | 0 | 3 |
| **Total** | | **24 new + 7 modified** | **60 steps** |
