# Tap-to-Run Smart Scene Feature Design

**Date:** 2026-03-18
**Status:** Approved
**Branch:** feat/ui-redesign-osprey

## Overview

Implement Tap-to-Run scene feature for the Osprey Smart Home app, similar to Tuya Smart's scene system. Users create scenes with multiple sequential actions (device control, delay, run another scene), then execute them with one tap.

**Decision:** Tap-to-Run is a NEW parallel system alongside existing Automation (schedule-based). No changes to existing SceneBloc or scheduler API.

## API Endpoints

All use ThingsBoard Smart Home API (`https://performentmarketing.ddnsgeek.com`) with `X-Authorization: Bearer <token>` header.

| Operation | Method | Endpoint |
|-----------|--------|----------|
| List homes | GET | `/api/smarthome/homes` |
| List devices | GET | `/api/tenant/devices?pageSize=50&page=0` |
| Get device DPs | GET | `/api/smarthome/products/{deviceProfileId}/datapoints` |
| List scenes | GET | `/api/smarthome/homes/{homeId}/scenes?sceneType=TAP_TO_RUN` |
| Get scene detail | GET | `/api/smarthome/scenes/{sceneId}` |
| Create scene | POST | `/api/smarthome/homes/{homeId}/scenes` |
| Update scene | PUT | `/api/smarthome/scenes/{sceneId}` |
| Delete scene | DELETE | `/api/smarthome/scenes/{sceneId}` |
| Execute scene | POST | `/api/smarthome/scenes/{sceneId}/execute` |
| Enable scene | PUT | `/api/smarthome/scenes/{sceneId}/enable` |
| Disable scene | PUT | `/api/smarthome/scenes/{sceneId}/disable` |
| Scene logs | GET | `/api/smarthome/scenes/{sceneId}/logs` |

## Action Types

### DEVICE_CONTROL
```json
{
  "actionType": "DEVICE_CONTROL",
  "entityId": "<device-uuid>",
  "executorProperty": {
    "dpId": 1,
    "dpValue": "open"
  }
}
```
- dpValue type depends on dpType: BOOLEAN (true/false), ENUM (string), VALUE (number), STRING (text)
- Use dpId (int), NOT dpCode (string)

### DELAY
```json
{
  "actionType": "DELAY",
  "executorProperty": {
    "minutes": 0,
    "seconds": 5
  }
}
```
- Max 5 minutes (300 seconds total)

### SCENE_RUN
```json
{
  "actionType": "SCENE_RUN",
  "entityId": "<scene-uuid>"
}
```
- Cannot select self (prevent infinite loop)

### SCENE_TOGGLE (future, not implemented now)
```json
{
  "actionType": "SCENE_TOGGLE",
  "entityId": "<automation-uuid>",
  "executorProperty": { "enabled": true }
}
```

## DataPoint UI Rendering

| dpType | UI Component | Constraints |
|--------|-------------|-------------|
| BOOLEAN | Toggle switch (ON/OFF) | — |
| ENUM | Dropdown / Radio buttons | `constraints.range` OR `constraints.values` (check both) |
| VALUE | Slider | `constraints.min`, `constraints.max`, `constraints.step` |
| STRING | Text input | `constraints.maxlen` |

- Only show DPs with mode = "RW" or "WO" (hide "RO")

## Execute Response

```json
{
  "status": "SUCCESS",
  "executionDetails": {
    "sceneName": "...",
    "actionCount": 3,
    "details": "Action 1: DEVICE_CONTROL → OK; ..."
  }
}
```
- SUCCESS → all actions OK
- PARTIAL → some failed
- FAILURE → all failed

## Architecture

### File Structure

All new files under `lib/features/scene/` — no changes to existing Automation code.

```
lib/features/scene/
├── data/
│   ├── datasources/
│   │   └── tap_to_run_remote_datasource.dart      # NEW - all Smart Home API calls
│   ├── models/
│   │   ├── smart_home_model.dart                   # NEW
│   │   ├── tap_to_run_scene_model.dart             # NEW
│   │   ├── scene_action_model.dart                 # NEW
│   │   └── data_point_model.dart                   # NEW
│   └── repositories/
│       └── tap_to_run_repository_impl.dart         # NEW
├── domain/
│   ├── entities/
│   │   ├── smart_home_entity.dart                  # NEW
│   │   ├── tap_to_run_scene_entity.dart            # NEW
│   │   ├── scene_action_entity.dart                # NEW
│   │   └── data_point_entity.dart                  # NEW
│   ├── repositories/
│   │   └── tap_to_run_repository.dart              # NEW - abstract interface
│   └── usecases/
│       ├── get_smart_homes.dart                    # NEW
│       ├── get_tap_to_run_scenes.dart              # NEW
│       ├── create_tap_to_run_scene.dart            # NEW
│       ├── update_tap_to_run_scene.dart            # NEW
│       ├── delete_tap_to_run_scene.dart            # NEW
│       ├── execute_tap_to_run_scene.dart           # NEW
│       ├── toggle_tap_to_run_scene.dart            # NEW
│       └── get_device_data_points.dart             # NEW
└── presentation/
    ├── bloc/
    │   └── tap_to_run/
    │       ├── tap_to_run_bloc.dart                # NEW
    │       ├── tap_to_run_event.dart               # NEW
    │       └── tap_to_run_state.dart               # NEW
    └── pages/
        └── tap_to_run/
            ├── create_tap_to_run_page.dart         # NEW - main create/edit page
            ├── select_action_type_sheet.dart        # NEW - bottom sheet
            ├── select_device_page.dart              # NEW - device list
            ├── select_device_function_page.dart     # NEW - DP list + value config
            ├── delay_config_sheet.dart              # NEW - minutes/seconds picker
            └── select_scene_page.dart               # NEW - pick scene for SCENE_RUN
```

### Domain Entities

```dart
class SmartHomeEntity extends Equatable {
  final String id;
  final String name;
}

class TapToRunSceneEntity extends Equatable {
  final String id;
  final String name;
  final String sceneType;  // "TAP_TO_RUN"
  final String? icon;
  final bool enabled;
  final List<SceneActionEntity> actions;
}

class SceneActionEntity extends Equatable {
  final String actionType;  // DEVICE_CONTROL, DELAY, SCENE_RUN
  final String? entityId;
  final Map<String, dynamic>? executorProperty;
}

class DataPointEntity extends Equatable {
  final int dpId;
  final String code;
  final String name;
  final String dpType;     // BOOLEAN, ENUM, VALUE, STRING
  final String mode;       // RW, RO, WO
  final Map<String, dynamic> constraints;
}
```

### BLoC

```dart
// Events
abstract class TapToRunEvent extends Equatable {}
class LoadTapToRunScenesEvent extends TapToRunEvent { final String homeId; }
class CreateTapToRunSceneEvent extends TapToRunEvent {
  final String homeId;
  final String name;
  final String? icon;
  final List<SceneActionEntity> actions;
}
class UpdateTapToRunSceneEvent extends TapToRunEvent {
  final String sceneId;
  final String name;
  final String? icon;
  final List<SceneActionEntity> actions;
}
class DeleteTapToRunSceneEvent extends TapToRunEvent { final String sceneId; }
class ExecuteTapToRunSceneEvent extends TapToRunEvent { final String sceneId; }
class ToggleTapToRunSceneEvent extends TapToRunEvent {
  final String sceneId;
  final bool enabled;
}

// States
abstract class TapToRunState extends Equatable {}
class TapToRunInitial extends TapToRunState {}
class TapToRunLoading extends TapToRunState {}
class TapToRunLoaded extends TapToRunState {
  final List<TapToRunSceneEntity> scenes;
}
class TapToRunError extends TapToRunState { final String message; }
class TapToRunExecuting extends TapToRunState {
  final String sceneId;
  final List<TapToRunSceneEntity> scenes;  // preserve list while executing
}
class TapToRunExecuteResult extends TapToRunState {
  final String status;  // SUCCESS, PARTIAL, FAILURE
  final String details;
  final List<TapToRunSceneEntity> scenes;
}
```

### Data Source

Single `TapToRunRemoteDataSource` class using existing `ApiClient` (Dio with auth interceptor):

- `getSmartHomes()` → GET /api/smarthome/homes
- `getScenes(homeId)` → GET /api/smarthome/homes/{homeId}/scenes?sceneType=TAP_TO_RUN
- `getSceneDetail(sceneId)` → GET /api/smarthome/scenes/{sceneId}
- `createScene(homeId, body)` → POST /api/smarthome/homes/{homeId}/scenes
- `updateScene(sceneId, body)` → PUT /api/smarthome/scenes/{sceneId}
- `deleteScene(sceneId)` → DELETE /api/smarthome/scenes/{sceneId}
- `executeScene(sceneId)` → POST /api/smarthome/scenes/{sceneId}/execute
- `enableScene(sceneId)` → PUT /api/smarthome/scenes/{sceneId}/enable
- `disableScene(sceneId)` → PUT /api/smarthome/scenes/{sceneId}/disable
- `getSceneLogs(sceneId)` → GET /api/smarthome/scenes/{sceneId}/logs
- `getDeviceDataPoints(profileId)` → GET /api/smarthome/products/{profileId}/datapoints

### homeId Management

- Fetch homes when TapToRunBloc loads for the first time
- Cache homeId in TokenManager (add `homeId` field + secure storage key)
- If 1 home → auto-select
- If multiple → show selection dialog

### DI Registration (injector.dart)

Add to existing `setupInjector()`:
- TapToRunRemoteDataSource (LazySingleton) — uses existing ApiClient
- TapToRunRepository (LazySingleton)
- 8 use cases (LazySingleton)
- TapToRunBloc (Factory)

### Integration Points

**home_page.dart SceneTab:** Replace empty "Tap-to-Run" sub-tab content with `BlocBuilder<TapToRunBloc, TapToRunState>` showing scene list.

**main.dart:** Add `TapToRunBloc` to `MultiBlocProvider`.

**No changes to:** SceneBloc, DeviceBloc, existing scene data/domain/presentation files.

## UI Flow

```
SceneTab → "Tap-to-Run" sub-tab
├── Scene list (cards with icon + name + Execute button)
│   ├── Tap Execute → POST execute → toast with status
│   ├── Tap card → Edit (CreateTapToRunPage in edit mode)
│   └── Swipe → Delete confirmation
└── [+] FAB → CreateTapToRunPage
    ├── Name TextField
    ├── Icon picker (optional grid)
    ├── "THEN" section
    │   ├── Action cards (draggable to reorder)
    │   │   ├── DEVICE_CONTROL: "📱 DeviceName — FunctionName: Value"
    │   │   ├── DELAY: "⏱ Wait Xm Ys"
    │   │   └── SCENE_RUN: "▶ SceneName"
    │   └── [+ Add Action] → Bottom sheet
    │       ├── "Run the device" → SelectDevicePage → SelectDeviceFunctionPage
    │       ├── "Delay" → DelayConfigSheet
    │       └── "Run the scene" → SelectScenePage
    └── [Save] → validate (≥1 action + name) → create/update API
```

## Key Rules from Spec

1. Use dpId (number), NOT dpCode (string)
2. Only show DPs with mode RW or WO
3. ENUM: check both `constraints.range` AND `constraints.values`
4. Actions execute sequentially (array order = execution order)
5. Delay max 5 minutes
6. SCENE_RUN: filter out self to prevent infinite loops
7. Execute status toast: SUCCESS/PARTIAL/FAILURE
