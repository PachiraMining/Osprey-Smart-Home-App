# Automation "When Device Status Changes" Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Cho phép người dùng tạo automation kích hoạt bởi trạng thái thiết bị (`DEVICE_STATUS`), kèm trình sửa khung giờ hiệu lực và ghi toạ độ cho home.

**Architecture:** Thay lớp cụ thể `ScheduleConditionEntity` bằng một `sealed class AutomationConditionEntity` với hai lớp con, để `switch` vét cạn bắt lỗi ở thời điểm biên dịch khi thêm loại điều kiện mới. Tầng data phân giải theo `conditionType`, tầng UI thêm một trang chọn điều kiện thiết bị và một trang sửa `effectiveTime`. Không có API mới — dùng đúng bộ scene API hiện có.

**Tech Stack:** Flutter 3.41.4 (FVM), Dart 3.9.2, flutter_bloc, get_it, dartz, Equatable, flutter_localizations + ARB.

## Global Constraints

- **`sealed` chỉ cho phép kế thừa trong cùng library (cùng file).** Cả ba lớp entity điều kiện PHẢI nằm trong một file. File cũ giữ lại làm re-export.
- **`timeZoneId` luôn để `null`** khi gửi lên, cả trong điều kiện lẫn `effectiveTime` — backend lấy timezone của home. Ghi cứng giá trị sẽ thắng timezone home trong thứ tự ưu tiên backend và gây bug automation không nổ.
- **Không xin quyền vị trí thiết bị.** Toạ độ lấy từ danh sách thành phố nhúng sẵn.
- **14 file ARB** phải đồng bộ: `app_ar app_de app_en app_es app_es_419 app_fr app_it app_ja app_ko app_pt app_pt_BR app_ru app_zh app_zh_Hant`. Thiếu key ở bất kỳ file nào là lỗi lúc `gen-l10n`.
- **Không có tiếng Việt** trong danh sách ngôn ngữ — đừng thêm `app_vi.arb`.
- Chạy test: `fvm flutter test <path>`. Phân tích: `fvm flutter analyze lib/`.
- Sinh l10n: `fvm flutter gen-l10n`.
- **Không commit/push nếu người dùng không yêu cầu.** Các bước "Commit" bên dưới chỉ thực hiện khi được cho phép.

## File Structure

**Tạo mới:**

| File | Trách nhiệm |
|---|---|
| `lib/features/scene/domain/entities/automation_condition_entity.dart` | `sealed AutomationConditionEntity` + `ScheduleConditionEntity` + `DeviceStatusConditionEntity` |
| `lib/features/scene/data/models/automation_condition_model.dart` | `ScheduleConditionModel`, `DeviceStatusConditionModel`, dispatcher `automationConditionFromJson` |
| `lib/features/scene/presentation/pages/automation/device_condition_page.dart` | Chọn thiết bị → DP → toán tử → giá trị |
| `lib/features/scene/presentation/pages/automation/condition_type_sheet.dart` | Sheet chọn loại điều kiện |
| `lib/features/scene/presentation/pages/automation/precondition_page.dart` | Sửa `effectiveTime` |
| `lib/features/home/presentation/pages/city_picker_page.dart` | Danh sách thành phố → `geoName` + toạ độ |
| `lib/features/home/data/city_catalog.dart` | Bảng thành phố nhúng sẵn |

**Sửa:** `schedule_condition_entity.dart` (→ re-export), `schedule_condition_model.dart` (→ re-export), `automation_scene_entity.dart`, `automation_scene_model.dart`, `automation_repository.dart`, `automation_repository_impl.dart`, `create_automation.dart`, `update_automation.dart`, `automation_event.dart`, `automation_bloc.dart`, `automation_detail_page.dart`, `cache_serializers.dart`, `data_point_entity.dart`, `CreateSceneTriggerPage.dart`, `home_settings_page.dart`, `home_management_event.dart`, `home_management_bloc.dart`, 14 file ARB.

---

### Task 1: Chuỗi l10n cho toàn bộ tính năng

Làm trước để các task UI sau dùng ngay, không phải quay lại.

**Files:**
- Modify: `lib/l10n/app_en.arb` và 13 file ARB còn lại

**Interfaces:**
- Produces: các getter trên `AppL10n` — `deviceStatus`, `selectDevice`, `selectFunction`, `condition`, `precondition`, `allDay`, `customTime`, `startTime`, `endTime`, `repeat`, `overnightNote`, `automationDelayNote`, `selectCity`, `searchCity`, `equals`, `notEquals`, `greaterThan`, `greaterOrEqual`, `lessThan`, `lessOrEqual`, `on`, `off`, `noReadableDataPoints`

- [ ] **Step 1: Thêm key vào `app_en.arb`**

Chèn trước dấu `}` cuối file:

```json
  "deviceStatus": "Device status",
  "selectDevice": "Select device",
  "selectFunction": "Select function",
  "condition": "Condition",
  "precondition": "Precondition",
  "allDay": "All day",
  "customTime": "Custom",
  "startTime": "Start time",
  "endTime": "End time",
  "repeat": "Repeat",
  "overnightNote": "This period crosses midnight. It is counted from the day it starts.",
  "automationDelayNote": "Runs within about 5 seconds of the change, then pauses for 60 seconds. A new automation does not run if its condition is already met — only on the next change.",
  "selectCity": "Select city",
  "searchCity": "Search city",
  "equals": "Equals",
  "notEquals": "Does not equal",
  "greaterThan": "Greater than",
  "greaterOrEqual": "Greater than or equal",
  "lessThan": "Less than",
  "lessOrEqual": "Less than or equal",
  "on": "On",
  "off": "Off",
  "noReadableDataPoints": "This device has no readable status to use as a condition."
```

- [ ] **Step 2: Dịch sang 13 ngôn ngữ còn lại**

Thêm đúng 23 key trên vào từng file, dịch tự nhiên theo văn phong đã có trong mỗi file. Giữ nguyên tên key. Với `app_ar.arb` nhớ văn phong RTL.

- [ ] **Step 3: Sinh code và kiểm tra**

Run: `fvm flutter gen-l10n && fvm flutter analyze lib/`
Expected: không lỗi, không cảnh báo thiếu key.

- [ ] **Step 4: Commit** (chỉ khi được phép)

```bash
git add lib/l10n
git commit -m "feat: chuỗi l10n cho automation điều kiện thiết bị"
```

---

### Task 2: Sealed condition entity

**Files:**
- Create: `lib/features/scene/domain/entities/automation_condition_entity.dart`
- Modify: `lib/features/scene/domain/entities/schedule_condition_entity.dart` (thay toàn bộ nội dung bằng re-export)
- Test: `test/features/scene/domain/automation_condition_entity_test.dart`

**Interfaces:**
- Produces:
  - `sealed class AutomationConditionEntity extends Equatable` với `String get conditionType`
  - `class ScheduleConditionEntity extends AutomationConditionEntity` — giữ NGUYÊN mọi field và getter hiện có (`timeZoneId`, `loops`, `time`, `date`, `isOneTime`, `isDaily`, `isWeekdays`, `isWeekends`, `displayLoops`, `displayText`)
  - `class DeviceStatusConditionEntity extends AutomationConditionEntity` với `entityId`, `dpCode`, `operator`, `value` (`Object`), `valueType`, `dpName` (`String?`, chỉ để hiển thị, không gửi lên), `displayText`

- [ ] **Step 1: Viết test thất bại**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_curtain_app/features/scene/domain/entities/automation_condition_entity.dart';

void main() {
  test('DeviceStatusConditionEntity mang đúng conditionType', () {
    const c = DeviceStatusConditionEntity(
      entityId: 'dev-1',
      dpCode: 'control',
      operator: '==',
      value: 'open',
      valueType: 'STRING',
    );
    expect(c.conditionType, 'DEVICE_STATUS');
  });

  test('ScheduleConditionEntity vẫn mang conditionType SCHEDULE', () {
    const c = ScheduleConditionEntity(
      conditionType: 'SCHEDULE',
      loops: '1111111',
      time: '17:00',
    );
    expect(c.conditionType, 'SCHEDULE');
    expect(c.isDaily, isTrue);
  });

  test('switch trên sealed vét cạn được cả hai nhánh', () {
    final list = <AutomationConditionEntity>[
      const ScheduleConditionEntity(
          conditionType: 'SCHEDULE', loops: '1111111', time: '08:00'),
      const DeviceStatusConditionEntity(
          entityId: 'd', dpCode: 'control', operator: '==',
          value: 'open', valueType: 'STRING'),
    ];
    final kinds = list.map((c) => switch (c) {
          ScheduleConditionEntity() => 'schedule',
          DeviceStatusConditionEntity() => 'device',
        });
    expect(kinds, ['schedule', 'device']);
  });

  test('displayText của điều kiện thiết bị đọc được', () {
    const c = DeviceStatusConditionEntity(
      entityId: 'dev-1', dpCode: 'control', operator: '==',
      value: 'open', valueType: 'STRING', dpName: 'Control',
    );
    expect(c.displayText, 'Control : open');
  });
}
```

- [ ] **Step 2: Chạy test để chắc chắn nó hỏng**

Run: `fvm flutter test test/features/scene/domain/automation_condition_entity_test.dart`
Expected: FAIL — `automation_condition_entity.dart` chưa tồn tại.

- [ ] **Step 3: Tạo file entity**

`lib/features/scene/domain/entities/automation_condition_entity.dart`:

```dart
import 'package:equatable/equatable.dart';

/// Điều kiện kích hoạt của một automation.
///
/// `sealed` để `switch` phải vét cạn: thêm loại điều kiện mới (vd Weather)
/// là compiler chỉ ra MỌI chỗ cần sửa, thay vì để sót tới lúc chạy.
/// Vì `sealed` chỉ cho kế thừa trong cùng library, mọi lớp con phải nằm
/// trong file này.
sealed class AutomationConditionEntity extends Equatable {
  const AutomationConditionEntity();

  String get conditionType;

  /// Dòng phụ đề hiển thị trong thẻ If.
  String get displayText;
}

class ScheduleConditionEntity extends AutomationConditionEntity {
  @override
  final String conditionType; // "SCHEDULE"

  /// Null → backend lấy zone từ home.timezone (nên dùng). Chỉ đặt khi muốn
  /// ghi đè zone cho riêng một scene; giá trị ghi cứng ở đây sẽ THẮNG
  /// timezone của home trong thứ tự ưu tiên của ScheduleCalculator.
  final String? timeZoneId;
  final String loops; // 7 ký tự MON-SUN, "1"=bật "0"=bỏ
  final String time; // "HH:mm" 24h
  final String? date; // "yyyyMMdd", bắt buộc khi loops="0000000"

  const ScheduleConditionEntity({
    required this.conditionType,
    this.timeZoneId,
    required this.loops,
    required this.time,
    this.date,
  });

  bool get isOneTime => loops == '0000000';

  bool get isDaily => loops == '1111111';

  bool get isWeekdays => loops == '0111110';

  bool get isWeekends => loops == '0000011';

  String get _formatDate {
    if (date == null || date!.length != 8) return 'Once';
    final m = int.tryParse(date!.substring(4, 6)) ?? 0;
    final d = int.tryParse(date!.substring(6, 8)) ?? 0;
    return '$m/$d';
  }

  String get displayLoops {
    if (isOneTime) return _formatDate;
    if (isDaily) return 'Every day';
    if (isWeekdays) return 'Mon - Fri';
    if (isWeekends) return 'Sat - Sun';

    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final active = <String>[];
    for (var i = 0; i < 7 && i < loops.length; i++) {
      if (loops[i] == '1') active.add(days[i]);
    }
    return active.join(', ');
  }

  @override
  String get displayText => '$time | $displayLoops';

  @override
  List<Object?> get props => [conditionType, timeZoneId, loops, time, date];
}

class DeviceStatusConditionEntity extends AutomationConditionEntity {
  /// UUID thiết bị, phải thuộc cùng home với scene.
  final String entityId;

  /// Mã DP lấy từ GET /api/smarthome/products/{deviceProfileId}/datapoints.
  final String dpCode;

  /// == != > >= < <= — nhóm so sánh số chỉ hợp lệ với valueType NUMBER.
  final String operator;

  /// Giá trị so sánh, đúng kiểu JSON: num, bool hoặc String.
  final Object value;

  /// NUMBER | BOOLEAN | STRING (ENUM dùng STRING).
  final String valueType;

  /// Tên DP hiển thị cho người dùng. Chỉ dùng để vẽ giao diện, KHÔNG gửi
  /// lên backend và KHÔNG tính vào props để so sánh.
  final String? dpName;

  const DeviceStatusConditionEntity({
    required this.entityId,
    required this.dpCode,
    required this.operator,
    required this.value,
    required this.valueType,
    this.dpName,
  });

  @override
  String get conditionType => 'DEVICE_STATUS';

  @override
  String get displayText => '${dpName ?? dpCode} : $value';

  @override
  List<Object?> get props => [entityId, dpCode, operator, value, valueType];
}
```

- [ ] **Step 4: Biến file cũ thành re-export**

Thay TOÀN BỘ nội dung `lib/features/scene/domain/entities/schedule_condition_entity.dart` bằng:

```dart
// ScheduleConditionEntity đã chuyển vào automation_condition_entity.dart —
// `sealed` bắt buộc mọi lớp con nằm cùng library. Giữ file này để 13 chỗ
// import sẵn có không phải sửa.
export 'automation_condition_entity.dart'
    show AutomationConditionEntity, ScheduleConditionEntity,
        DeviceStatusConditionEntity;
```

- [ ] **Step 5: Chạy test và phân tích**

Run: `fvm flutter test test/features/scene/domain/automation_condition_entity_test.dart && fvm flutter analyze lib/`
Expected: 4 test PASS, `analyze` không có `error •`.

- [ ] **Step 6: Commit** (chỉ khi được phép)

```bash
git add lib/features/scene/domain/entities test/features/scene/domain
git commit -m "refactor: sealed AutomationConditionEntity cho điều kiện automation"
```

---

### Task 3: Model + phân giải JSON hai chiều

**Files:**
- Create: `lib/features/scene/data/models/automation_condition_model.dart`
- Modify: `lib/features/scene/data/models/schedule_condition_model.dart` (→ re-export)
- Modify: `lib/features/scene/data/models/automation_scene_model.dart`
- Modify: `lib/features/scene/domain/entities/automation_scene_entity.dart:12`
- Test: `test/features/scene/data/automation_condition_model_test.dart`

**Interfaces:**
- Consumes: `AutomationConditionEntity`, `ScheduleConditionEntity`, `DeviceStatusConditionEntity` (Task 2)
- Produces:
  - `class ScheduleConditionModel extends ScheduleConditionEntity` với `.fromJson(Map<String, dynamic>)` và `Map<String, dynamic> toJson()`
  - `class DeviceStatusConditionModel extends DeviceStatusConditionEntity` với `.fromJson` và `toJson()`
  - `AutomationConditionEntity? automationConditionFromJson(Map<String, dynamic> json)` — trả `null` khi `conditionType` không nhận ra
  - `Map<String, dynamic> automationConditionToJson(AutomationConditionEntity c)`
  - `AutomationSceneEntity.conditions` đổi kiểu thành `List<AutomationConditionEntity>`

- [ ] **Step 1: Viết test thất bại**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_curtain_app/features/scene/data/models/automation_condition_model.dart';
import 'package:smart_curtain_app/features/scene/domain/entities/automation_condition_entity.dart';

void main() {
  test('phân giải điều kiện DEVICE_STATUS', () {
    final c = automationConditionFromJson({
      'conditionType': 'DEVICE_STATUS',
      'entityId': 'dev-1',
      'dpCode': 'control',
      'operator': '==',
      'value': 'open',
      'valueType': 'STRING',
    });
    expect(c, isA<DeviceStatusConditionEntity>());
    final d = c! as DeviceStatusConditionEntity;
    expect(d.entityId, 'dev-1');
    expect(d.value, 'open');
  });

  test('phân giải điều kiện SCHEDULE', () {
    final c = automationConditionFromJson({
      'conditionType': 'SCHEDULE',
      'loops': '1111111',
      'time': '17:00',
    });
    expect(c, isA<ScheduleConditionEntity>());
  });

  test('conditionType lạ trả null chứ KHÔNG ném lỗi', () {
    // Backend có thể thêm loại mới (vd WEATHER) trước khi app kịp cập nhật.
    // Ném lỗi ở đây sẽ làm hỏng cả danh sách automation.
    expect(
      automationConditionFromJson({'conditionType': 'WEATHER', 'city': 'x'}),
      isNull,
    );
  });

  test('giữ nguyên kiểu số khi round-trip', () {
    final json = {
      'conditionType': 'DEVICE_STATUS',
      'entityId': 'dev-1',
      'dpCode': 'temp',
      'operator': '>',
      'value': 30,
      'valueType': 'NUMBER',
    };
    final back = automationConditionToJson(automationConditionFromJson(json)!);
    expect(back['value'], 30);
    expect(back['value'], isA<int>());
    expect(back['valueType'], 'NUMBER');
  });

  test('toJson KHÔNG gửi dpName lên backend', () {
    const c = DeviceStatusConditionEntity(
      entityId: 'd', dpCode: 'control', operator: '==',
      value: 'open', valueType: 'STRING', dpName: 'Control',
    );
    expect(automationConditionToJson(c).containsKey('dpName'), isFalse);
  });

  test('điều kiện lịch KHÔNG gửi timeZoneId khi để trống', () {
    const c = ScheduleConditionEntity(
      conditionType: 'SCHEDULE', loops: '1111111', time: '17:00',
    );
    expect(automationConditionToJson(c).containsKey('timeZoneId'), isFalse);
  });
}
```

- [ ] **Step 2: Chạy test để chắc chắn nó hỏng**

Run: `fvm flutter test test/features/scene/data/automation_condition_model_test.dart`
Expected: FAIL — `automation_condition_model.dart` chưa tồn tại.

- [ ] **Step 3: Tạo model**

`lib/features/scene/data/models/automation_condition_model.dart`:

```dart
import 'dart:developer' as dev;

import '../../domain/entities/automation_condition_entity.dart';

class ScheduleConditionModel extends ScheduleConditionEntity {
  const ScheduleConditionModel({
    required super.conditionType,
    super.timeZoneId,
    required super.loops,
    required super.time,
    super.date,
  });

  factory ScheduleConditionModel.fromJson(Map<String, dynamic> json) {
    return ScheduleConditionModel(
      conditionType: json['conditionType'] as String? ?? 'SCHEDULE',
      timeZoneId: json['timeZoneId'] as String?,
      loops: json['loops'] as String? ?? '0000000',
      time: json['time'] as String? ?? '00:00',
      date: json['date'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'conditionType': conditionType,
      'loops': loops,
      'time': time,
    };
    // Chỉ gửi khi cố ý ghi đè; bỏ trống để backend dùng home.timezone.
    if (timeZoneId != null) map['timeZoneId'] = timeZoneId;
    if (date != null) map['date'] = date;
    return map;
  }
}

class DeviceStatusConditionModel extends DeviceStatusConditionEntity {
  const DeviceStatusConditionModel({
    required super.entityId,
    required super.dpCode,
    required super.operator,
    required super.value,
    required super.valueType,
    super.dpName,
  });

  factory DeviceStatusConditionModel.fromJson(Map<String, dynamic> json) {
    return DeviceStatusConditionModel(
      entityId: json['entityId'] as String? ?? '',
      dpCode: json['dpCode'] as String? ?? '',
      operator: json['operator'] as String? ?? '==',
      value: json['value'] as Object? ?? '',
      valueType: json['valueType'] as String? ?? 'STRING',
    );
  }

  Map<String, dynamic> toJson() => {
        'conditionType': conditionType,
        'entityId': entityId,
        'dpCode': dpCode,
        'operator': operator,
        'value': value,
        'valueType': valueType,
      };
}

/// Phân giải một phần tử `conditions[]` từ backend.
///
/// Trả `null` khi không nhận ra `conditionType` — backend có thể thêm loại
/// mới trước khi app kịp cập nhật, ném lỗi ở đây sẽ làm hỏng cả danh sách.
AutomationConditionEntity? automationConditionFromJson(
    Map<String, dynamic> json) {
  final type = json['conditionType'] as String?;
  switch (type) {
    case 'SCHEDULE':
      return ScheduleConditionModel.fromJson(json);
    case 'DEVICE_STATUS':
      return DeviceStatusConditionModel.fromJson(json);
    default:
      dev.log('Bỏ qua điều kiện không nhận ra: $type',
          name: 'automation_condition');
      return null;
  }
}

Map<String, dynamic> automationConditionToJson(AutomationConditionEntity c) =>
    switch (c) {
      ScheduleConditionEntity() => ScheduleConditionModel(
          conditionType: c.conditionType,
          timeZoneId: c.timeZoneId,
          loops: c.loops,
          time: c.time,
          date: c.date,
        ).toJson(),
      DeviceStatusConditionEntity() => DeviceStatusConditionModel(
          entityId: c.entityId,
          dpCode: c.dpCode,
          operator: c.operator,
          value: c.value,
          valueType: c.valueType,
        ).toJson(),
    };
```

- [ ] **Step 4: Biến model cũ thành re-export**

Thay TOÀN BỘ nội dung `lib/features/scene/data/models/schedule_condition_model.dart` bằng:

```dart
export 'automation_condition_model.dart'
    show ScheduleConditionModel, DeviceStatusConditionModel,
        automationConditionFromJson, automationConditionToJson;
```

- [ ] **Step 5: Nới kiểu trên entity scene**

Trong `lib/features/scene/domain/entities/automation_scene_entity.dart`, đổi import và kiểu:

```dart
import 'automation_condition_entity.dart';
```

```dart
  final List<AutomationConditionEntity> conditions;
```

Và sửa `conditionSummary` để dùng getter chung:

```dart
  String get conditionSummary {
    if (conditions.isEmpty) return 'No condition';
    return conditions.first.displayText;
  }
```

- [ ] **Step 6: Sửa `automation_scene_model.dart`**

Đổi import `schedule_condition_model.dart` → `automation_condition_model.dart`.

Trong `fromJson`, thay khối `conditions:` bằng:

```dart
      conditions: conditionsList
          .whereType<Map<String, dynamic>>()
          .map(automationConditionFromJson)
          .whereType<AutomationConditionEntity>()
          .toList(),
```

Trong `toCreateJson`, thay ép kiểu cứng `(c as ScheduleConditionModel).toJson()` — dòng này sẽ NÉM LỖI với điều kiện thiết bị:

```dart
      'conditions': conditions.map(automationConditionToJson).toList(),
```

- [ ] **Step 7: Chạy test**

Run: `fvm flutter test test/features/scene/data/automation_condition_model_test.dart`
Expected: 6 test PASS.

- [ ] **Step 8: Commit** (chỉ khi được phép)

```bash
git add lib/features/scene test/features/scene/data
git commit -m "feat: phân giải JSON cho điều kiện DEVICE_STATUS"
```

---

### Task 4: Nới kiểu qua toàn bộ đường ống

Không có logic mới — chỉ đổi `List<ScheduleConditionEntity>` thành `List<AutomationConditionEntity>` ở mọi chữ ký, cộng cache.

**Files:**
- Modify: `lib/features/scene/domain/repositories/automation_repository.dart`
- Modify: `lib/features/scene/data/repositories/automation_repository_impl.dart`
- Modify: `lib/features/scene/domain/usecases/create_automation.dart`
- Modify: `lib/features/scene/domain/usecases/update_automation.dart`
- Modify: `lib/features/scene/presentation/bloc/automation/automation_event.dart`
- Modify: `lib/core/cache/cache_serializers.dart:98-113`
- Test: `test/features/scene/presentation/bloc/automation_bloc_test.dart` (cập nhật fake repo)

**Interfaces:**
- Consumes: `AutomationConditionEntity`, `automationConditionFromJson`, `automationConditionToJson` (Task 3)
- Produces: `CreateAutomationEvent.conditions` và `UpdateAutomationEvent.conditions` kiểu `List<AutomationConditionEntity>`; `conditionToJson`/`conditionFromJson` trong cache xử lý cả hai loại

- [ ] **Step 1: Viết test thất bại**

Thêm vào cuối `test/features/scene/presentation/bloc/automation_bloc_test.dart`, trong `main()`:

```dart
  test('create automation chấp nhận điều kiện thiết bị', () async {
    final repo = _FakeAutomationRepository();
    final bloc = AutomationBloc(
      getAutomations: GetAutomations(repo),
      createAutomation: CreateAutomation(repo),
      updateAutomation: UpdateAutomation(repo),
      deleteAutomation: DeleteAutomation(repo),
      toggleAutomation: ToggleAutomation(repo),
    );
    bloc.add(const LoadAutomationsEvent('home-1'));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    bloc.add(const CreateAutomationEvent(
      name: 'Rèm mở thì bật quạt',
      conditions: [
        DeviceStatusConditionEntity(
          entityId: 'dev-1', dpCode: 'control', operator: '==',
          value: 'open', valueType: 'STRING',
        ),
      ],
      actions: [],
    ));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(repo.lastCreateHomeId, 'home-1');
    await bloc.close();
  });
```

Thêm import:

```dart
import 'package:smart_curtain_app/features/scene/domain/entities/automation_condition_entity.dart';
```

- [ ] **Step 2: Chạy test để chắc chắn nó hỏng**

Run: `fvm flutter test test/features/scene/presentation/bloc/automation_bloc_test.dart`
Expected: FAIL — lỗi kiểu, `DeviceStatusConditionEntity` không gán được vào `List<ScheduleConditionEntity>`.

- [ ] **Step 3: Đổi kiểu ở tầng domain và data**

Trong 4 file `automation_repository.dart`, `automation_repository_impl.dart`, `create_automation.dart`, `update_automation.dart`: đổi mọi `List<ScheduleConditionEntity>` thành `List<AutomationConditionEntity>`, và import `automation_condition_entity.dart` thay cho `schedule_condition_entity.dart`.

- [ ] **Step 4: Đổi kiểu ở tầng presentation**

Trong `automation_event.dart`: đổi kiểu hai field `conditions` và đổi import như trên.

- [ ] **Step 5: Sửa cache serializers**

Thay khối `lib/core/cache/cache_serializers.dart:98-113` bằng:

```dart
// ─── Automation condition ───────────────────────────────────────────────
Map<String, dynamic> conditionToJson(AutomationConditionEntity c) =>
    automationConditionToJson(c);

/// Trả null khi bản ghi cache thuộc loại điều kiện app này chưa biết —
/// người gọi lọc bỏ, giống hệt đường phân giải từ mạng.
AutomationConditionEntity? conditionFromJson(Map<String, dynamic> j) =>
    automationConditionFromJson(j);
```

Đổi import trong file này sang `automation_condition_entity.dart` và
`../../features/scene/data/models/automation_condition_model.dart`.

Tìm nơi gọi `conditionFromJson` và lọc `null`:

```dart
      conditions: (j['conditions'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(conditionFromJson)
          .whereType<AutomationConditionEntity>()
          .toList(),
```

- [ ] **Step 6: Sửa fake repo trong test**

Trong `_FakeAutomationRepository`, đổi mọi `List<ScheduleConditionEntity>` thành `List<AutomationConditionEntity>`.

- [ ] **Step 7: Chạy toàn bộ test và phân tích**

Run: `fvm flutter test test/features/scene && fvm flutter analyze lib/`
Expected: tất cả PASS, `analyze` không có `error •`.

- [ ] **Step 8: Commit** (chỉ khi được phép)

```bash
git add lib test
git commit -m "refactor: nới kiểu điều kiện qua repository, usecase, bloc và cache"
```

---

### Task 5: Trang chọn điều kiện thiết bị

**Files:**
- Create: `lib/features/scene/presentation/pages/automation/device_condition_rules.dart`
- Create: `lib/features/scene/presentation/pages/automation/device_condition_page.dart`
- Modify: `lib/features/scene/domain/entities/data_point_entity.dart`
- Test: `test/features/scene/domain/device_condition_rules_test.dart`

**Interfaces:**
- Consumes: `DeviceStatusConditionEntity` (Task 2), `GetDeviceDataPoints` (đã có, nhận `deviceProfileId`), `HomeDeviceEntity.deviceProfileId`, `HomeManagementBloc.state.devices`
- Produces:
  - `DataPointEntity.isReadable` → `bool`
  - `List<String> operatorsFor(String dpType)`
  - `String valueTypeFor(String dpType)`
  - `List<DataPointEntity> conditionDataPoints(List<DataPointEntity> all)`
  - `class DeviceConditionPage extends StatefulWidget` với `const DeviceConditionPage({super.key, this.existing})`, `final DeviceStatusConditionEntity? existing` (đặt tên theo đúng quy ước của `ScheduleConditionPage`). Trả về `DeviceStatusConditionEntity` qua `Navigator.pop`.

Luật ánh xạ tách khỏi widget thành file riêng để test được bằng unit test —
widget test cho trang này sẽ phải dựng cả `HomeManagementBloc` (14 phụ thuộc)
lẫn GetIt, vừa giòn vừa đắt mà không kiểm được nhiều hơn.

- [ ] **Step 1: Viết test thất bại**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_curtain_app/features/scene/domain/entities/data_point_entity.dart';
import 'package:smart_curtain_app/features/scene/presentation/pages/automation/device_condition_rules.dart';

void main() {
  DataPointEntity dp(String mode, {String type = 'ENUM', String code = 'control'}) =>
      DataPointEntity(
        dpId: 1, code: code, name: 'Control',
        dpType: type, mode: mode, constraints: const {},
      );

  test('DP ghi-only không dùng làm điều kiện được', () {
    expect(dp('WO').isReadable, isFalse);
  });

  test('DP đọc-ghi và chỉ-đọc đều dùng được', () {
    expect(dp('RW').isReadable, isTrue);
    expect(dp('RO').isReadable, isTrue);
  });

  test('danh sách chọn loại bỏ DP ghi-only', () {
    final all = [dp('RW', code: 'a'), dp('WO', code: 'b'), dp('RO', code: 'c')];
    expect(conditionDataPoints(all).map((d) => d.code), ['a', 'c']);
  });

  test('chỉ DP số mới có toán tử so sánh lớn/nhỏ', () {
    expect(operatorsFor('VALUE'), ['==', '!=', '>', '>=', '<', '<=']);
    expect(operatorsFor('ENUM'), ['==', '!=']);
    expect(operatorsFor('STRING'), ['==', '!=']);
    // Với toggle, `!= true` trùng nghĩa `== false` — để cả hai chỉ tổ rối.
    expect(operatorsFor('BOOLEAN'), ['==']);
  });

  test('valueType suy từ dpType, ENUM đi đường STRING', () {
    expect(valueTypeFor('VALUE'), 'NUMBER');
    expect(valueTypeFor('BOOLEAN'), 'BOOLEAN');
    expect(valueTypeFor('ENUM'), 'STRING');
    expect(valueTypeFor('STRING'), 'STRING');
  });
}
```

- [ ] **Step 2: Chạy test để chắc chắn nó hỏng**

Run: `fvm flutter test test/features/scene/domain/device_condition_rules_test.dart`
Expected: FAIL — `device_condition_rules.dart` chưa tồn tại, `isReadable` chưa có.

- [ ] **Step 3: Thêm getter và file luật**

Trong `data_point_entity.dart`, ngay dưới `isWritable`:

```dart
  /// Dùng được làm điều kiện automation. DP ghi-only không đọc lại được
  /// trạng thái nên không thể so sánh.
  bool get isReadable => mode == 'RW' || mode == 'RO';
```

Tạo `device_condition_rules.dart`:

```dart
import '../../../domain/entities/data_point_entity.dart';

/// Toán tử hợp lệ theo kiểu DP. Nhóm so sánh lớn/nhỏ chỉ có nghĩa với số.
List<String> operatorsFor(String dpType) => switch (dpType) {
      'VALUE' => const ['==', '!=', '>', '>=', '<', '<='],
      'BOOLEAN' => const ['=='],
      _ => const ['==', '!='],
    };

/// `valueType` gửi lên backend, suy từ `dpType`. ENUM đi đường STRING.
String valueTypeFor(String dpType) => switch (dpType) {
      'VALUE' => 'NUMBER',
      'BOOLEAN' => 'BOOLEAN',
      _ => 'STRING',
    };

/// DP dùng được làm điều kiện — bỏ những DP không đọc lại được trạng thái.
List<DataPointEntity> conditionDataPoints(List<DataPointEntity> all) =>
    all.where((d) => d.isReadable).toList();
```

- [ ] **Step 4: Chạy test**

Run: `fvm flutter test test/features/scene/domain/device_condition_rules_test.dart`
Expected: 5 PASS.

- [ ] **Step 5: Dựng trang**

Tạo `device_condition_page.dart` — `StatefulWidget` ba bước trong một trang, mỗi bước hiện khi bước trước đã chọn:

1. **Thiết bị** — danh sách từ `context.read<HomeManagementBloc>().state.devices`, chỉ lấy máy có `deviceProfileId != null`. Chọn xong gọi `sl<GetDeviceDataPoints>()(deviceProfileId)`.
2. **Chức năng** — lọc qua `conditionDataPoints(...)`. Rỗng thì hiện `AppL10n.of(context).noReadableDataPoints` và chặn Save.
3. **Điều kiện** — render theo `dpType`:

```dart
Widget _valueEditor(DataPointEntity dp) => switch (dp.dpType) {
      'ENUM' => DropdownButton<String>(
          value: _value as String?,
          items: dp.enumOptions
              .map((o) => DropdownMenuItem(value: o, child: Text(o)))
              .toList(),
          onChanged: (v) => setState(() => _value = v),
        ),
      'BOOLEAN' => Switch(
          value: _value == true,
          onChanged: (v) => setState(() => _value = v),
        ),
      'VALUE' => TextField(
          controller: _numController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (t) => setState(() => _value = num.tryParse(t)),
        ),
      _ => TextField(
          controller: _textController,
          onChanged: (t) => setState(() => _value = t),
        ),
    };
```

Toán tử và `valueType` lấy từ `device_condition_rules.dart` (Step 3) —
`operatorsFor(dp.dpType)` và `valueTypeFor(dp.dpType)`. Danh sách DP lọc qua
`conditionDataPoints(...)`. KHÔNG khai lại các luật này trong widget.

Nhãn toán tử dùng `equals`, `notEquals`, `greaterThan`, `greaterOrEqual`, `lessThan`, `lessOrEqual` từ Task 1. Nhãn boolean dùng `on`/`off`.

Save chỉ bật khi đã chọn đủ thiết bị + DP + `_value != null`. Bấm Save:

```dart
Navigator.pop(
  context,
  DeviceStatusConditionEntity(
    entityId: _device!.deviceId,
    dpCode: _dp!.code,
    operator: _operator,
    value: _value!,
    valueType: valueTypeFor(_dp!.dpType),
    dpName: _dp!.name,
  ),
);
```

Màu sắc dùng `context.surfaces.*` (không dùng `AppColors.*` trực tiếp) để chạy đúng ở dark mode.

- [ ] **Step 6: Phân tích**

Run: `fvm flutter analyze lib/features/scene`
Expected: không có `error •`.

- [ ] **Step 7: Commit** (chỉ khi được phép)

```bash
git add lib/features/scene test/features/scene/domain
git commit -m "feat: trang chọn điều kiện trạng thái thiết bị"
```

---

### Task 6: Nối vào luồng tạo và thẻ If

**Files:**
- Create: `lib/features/scene/presentation/pages/automation/condition_type_sheet.dart`
- Modify: `lib/features/scene/presentation/pages/automation/automation_detail_page.dart`
- Modify: `lib/features/home/presentation/pages/CreateSceneTriggerPage.dart:106-110`

**Interfaces:**
- Consumes: `DeviceConditionPage` (Task 5), `AutomationConditionEntity` (Task 2), chuỗi l10n (Task 1)
- Produces: `Future<String?> showConditionTypeSheet(BuildContext context)` → `'schedule'` | `'device'` | `null`

- [ ] **Step 1: Tạo sheet chọn loại**

`condition_type_sheet.dart`:

```dart
/// Sheet chọn loại điều kiện khi bấm + trong thẻ If.
/// Trả 'schedule', 'device', hoặc null khi người dùng huỷ.
Future<String?> showConditionTypeSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: context.surfaces.sheet,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.access_time, color: Color(0xFF42A5F5)),
            title: Text(AppL10n.of(ctx).schedule),
            onTap: () => Navigator.pop(ctx, 'schedule'),
          ),
          ListTile(
            leading: const Icon(Icons.lightbulb, color: Color(0xFF2ECC71)),
            title: Text(AppL10n.of(ctx).deviceStatus),
            onTap: () => Navigator.pop(ctx, 'device'),
          ),
        ],
      ),
    ),
  );
}
```

- [ ] **Step 2: Đổi `_showAddConditionSheet` trong detail page**

Hiện đang đẩy thẳng sang `ScheduleConditionPage`. Thay bằng:

```dart
  Future<void> _showAddConditionSheet() async {
    final kind = await showConditionTypeSheet(context);
    if (kind == null || !mounted) return;
    final AutomationConditionEntity? condition = switch (kind) {
      'device' => await Navigator.push<DeviceStatusConditionEntity>(
          context,
          MaterialPageRoute(builder: (_) => const DeviceConditionPage()),
        ),
      _ => await Navigator.push<ScheduleConditionEntity>(
          context,
          MaterialPageRoute(builder: (_) => const ScheduleConditionPage()),
        ),
    };
    if (condition == null || !mounted) return;
    setState(() => _conditions.add(condition));
  }
```

Đổi khai báo `late List<ScheduleConditionEntity> _conditions;` thành `late List<AutomationConditionEntity> _conditions;`, và `widget.initialCondition` thành kiểu `AutomationConditionEntity?`.

- [ ] **Step 3: Sửa `_editCondition` để mở đúng trang theo loại**

```dart
  Future<void> _editCondition(int index) async {
    final existing = _conditions[index];
    final updated = switch (existing) {
      DeviceStatusConditionEntity() =>
        await Navigator.push<DeviceStatusConditionEntity>(
          context,
          MaterialPageRoute(
            builder: (_) => DeviceConditionPage(existing: existing),
          ),
        ),
      ScheduleConditionEntity() =>
        await Navigator.push<ScheduleConditionEntity>(
          context,
          MaterialPageRoute(
            // Tham số tên là `existing`, KHÔNG phải `initial` — theo đúng
            // chữ ký sẵn có của ScheduleConditionPage.
            builder: (_) => ScheduleConditionPage(existing: existing),
          ),
        ),
    };
    if (updated == null || !mounted) return;
    setState(() => _conditions[index] = updated);
  }
```

- [ ] **Step 4: Sửa `_IfCard` render theo loại và mở dropdown AND/OR**

Đổi `final List<ScheduleConditionEntity> conditions;` thành `List<AutomationConditionEntity>`.

`Dismissible` đang dùng `key: Key('condition_${entry.key}_${c.time}')` — `c.time` KHÔNG tồn tại trên điều kiện thiết bị, sẽ lỗi biên dịch. Thay bằng:

```dart
key: ValueKey('condition_${entry.key}_${c.conditionType}'),
```

Icon dòng điều kiện:

```dart
child: switch (c) {
  ScheduleConditionEntity() =>
    const Icon(Icons.access_time, size: 22, color: AppColors.primary),
  DeviceStatusConditionEntity() =>
    const Icon(Icons.lightbulb_outline, size: 22, color: Color(0xFF2ECC71)),
},
```

Ô icon giữ nền sáng như thẻ automation ở tab Scene — dùng `Colors.white`, không dùng `surfaces.card`, vì icon bên trong vẽ cho nền sáng.

Tiêu đề dòng lấy từ `c.displayText` (đã có trên cả hai loại).

Đổi dòng `conditionLogicText` từ `Text` thành `GestureDetector` mở sheet hai lựa chọn `whenAllConditionsMet` / `whenAnyConditionMet`, gọi callback `onChangeLogic(String logic)` mới thêm vào `_IfCard`, nối tới `setState(() => _conditionLogic = logic)` trong state của trang.

- [ ] **Step 5: Thêm dòng chú thích hành vi**

Ngay dưới danh sách điều kiện trong `_IfCard`, khi có ít nhất một `DeviceStatusConditionEntity`:

```dart
if (conditions.any((c) => c is DeviceStatusConditionEntity))
  Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    child: Text(
      AppL10n.of(context).automationDelayNote,
      style: TextStyle(fontSize: 12, color: context.surfaces.textMuted),
    ),
  ),
```

- [ ] **Step 6: Nối cell ở `CreateSceneTriggerPage`**

Thay `onTap` của cell "When device status changes" (dòng 106-110) bằng khuôn mẫu y hệt cell Schedule đang dùng:

```dart
                    onTap: () async {
                      final navigator = Navigator.of(context);
                      final condition =
                          await navigator.push<DeviceStatusConditionEntity>(
                        MaterialPageRoute(
                          builder: (_) => const DeviceConditionPage(),
                        ),
                      );
                      if (condition == null) return;
                      navigator.pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => AutomationDetailPage(
                            initialCondition: condition,
                          ),
                        ),
                      );
                    },
```

- [ ] **Step 7: Phân tích**

Run: `fvm flutter analyze lib/` và `fvm flutter test test/features/scene`
Expected: không có `error •`, test PASS.

- [ ] **Step 8: Commit** (chỉ khi được phép)

```bash
git add lib/features
git commit -m "feat: nối điều kiện thiết bị vào luồng tạo automation và thẻ If"
```

---

### Task 7: Precondition — trình sửa `effectiveTime`

**Files:**
- Create: `lib/features/scene/presentation/pages/automation/precondition_page.dart`
- Modify: `lib/features/scene/presentation/pages/automation/automation_detail_page.dart`
- Test: `test/features/scene/data/effective_time_model_test.dart`

**Interfaces:**
- Consumes: `EffectiveTimeEntity` (đã có: `type`, `startTime`, `endTime`, `loops`, `timeZoneId`), `EffectiveTimeModel.toJson` (đã có, ánh xạ `startTime`→`start`, `endTime`→`end`)
- Produces: `class PreconditionPage extends StatefulWidget` với `const PreconditionPage({super.key, this.existing})`, `final EffectiveTimeEntity? existing`. Trả `EffectiveTimeEntity` qua `Navigator.pop`.

- [ ] **Step 1: Viết test thất bại**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_curtain_app/features/scene/data/models/effective_time_model.dart';

void main() {
  test('ALL_DAY chỉ gửi type', () {
    const m = EffectiveTimeModel(type: 'ALL_DAY');
    expect(m.toJson(), {'type': 'ALL_DAY'});
  });

  test('CUSTOM gửi start/end/loops, KHÔNG gửi timeZoneId khi để trống', () {
    const m = EffectiveTimeModel(
      type: 'CUSTOM', startTime: '18:00', endTime: '06:00', loops: '1111100',
    );
    final j = m.toJson();
    expect(j['type'], 'CUSTOM');
    expect(j['start'], '18:00');
    expect(j['end'], '06:00');
    expect(j['loops'], '1111100');
    expect(j.containsKey('timeZoneId'), isFalse);
  });

  test('round-trip giữ nguyên khung qua đêm', () {
    const m = EffectiveTimeModel(
      type: 'CUSTOM', startTime: '22:00', endTime: '05:00', loops: '1111111',
    );
    final back = EffectiveTimeModel.fromJson(m.toJson());
    expect(back.startTime, '22:00');
    expect(back.endTime, '05:00');
  });
}
```

- [ ] **Step 2: Chạy test**

Run: `fvm flutter test test/features/scene/data/effective_time_model_test.dart`
Expected: PASS ngay — model đã đúng sẵn. Test này khoá hành vi lại trước khi thêm UI.

- [ ] **Step 3: Dựng `PreconditionPage`**

Hai lựa chọn radio `allDay` / `customTime`. Chọn Custom thì hiện thêm: `startTime` và `endTime` (mở `showTimePicker`), và `repeat` — 7 ô tròn Thứ2…CN bật/tắt, sinh chuỗi `loops` 7 ký tự.

Khi `startTime > endTime`, hiện `AppL10n.of(context).overnightNote` dưới hai ô giờ — backend tính khung theo NGÀY BẮT ĐẦU, người dùng không tự đoán được điều này.

Save trả về:

```dart
Navigator.pop(
  context,
  _allDay
      ? const EffectiveTimeEntity(type: 'ALL_DAY')
      : EffectiveTimeEntity(
          type: 'CUSTOM',
          startTime: _start,
          endTime: _end,
          loops: _loops,
          // Để null: backend lấy timezone của home.
        ),
);
```

- [ ] **Step 4: Nối vào detail page**

Thêm field `late EffectiveTimeEntity? _effectiveTime;` khởi tạo từ `widget.automation?.effectiveTime` (create thì `null`).

Sửa `_effectiveTimeText` để đọc `_effectiveTime` thay vì `widget.automation?.effectiveTime`, trả `AppL10n.of(context).allDay` khi `null` hoặc `type == 'ALL_DAY'`.

Thêm dòng `Precondition` NGAY TRÊN dòng `More Settings` (dùng `_buildOptionRow` sẵn có):

```dart
              _buildOptionRow(
                title: AppL10n.of(context).precondition,
                onTap: () async {
                  final result = await Navigator.push<EffectiveTimeEntity>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PreconditionPage(existing: _effectiveTime),
                    ),
                  );
                  if (result == null || !mounted) return;
                  setState(() => _effectiveTime = result);
                },
              ),
```

Trong `_save`, truyền `effectiveTime: _effectiveTime` cho CẢ `CreateAutomationEvent` (hiện KHÔNG truyền gì) lẫn `UpdateAutomationEvent` (hiện truyền `widget.automation!.effectiveTime`, bỏ qua chỉnh sửa của người dùng).

- [ ] **Step 5: Chạy test và phân tích**

Run: `fvm flutter test test/features/scene && fvm flutter analyze lib/`
Expected: PASS, không `error •`.

- [ ] **Step 6: Commit** (chỉ khi được phép)

```bash
git add lib/features/scene test/features/scene
git commit -m "feat: trình sửa khung giờ hiệu lực cho automation"
```

---

### Task 8: Sửa bug mất toạ độ khi đổi tên home

Làm TRƯỚC Task 9, nếu không toạ độ vừa đặt sẽ bay ngay lần đổi tên đầu tiên.

**Files:**
- Create: `lib/features/home/domain/home_update_merge.dart`
- Modify: `lib/features/home/presentation/bloc/home_management_event.dart:48-61`
- Modify: `lib/features/home/presentation/bloc/home_management_bloc.dart:246-250`
- Test: `test/features/home/home_update_merge_test.dart`

**Interfaces:**
- Produces:
  - `UpdateHomeEvent` thêm `final double? latitude;` và `final double? longitude;`
  - `HomeEntity mergeHomeUpdate({required HomeEntity current, required String name, String? geoName, double? latitude, double? longitude, String? timezone})`

`HomeManagementBloc` cần 14 phụ thuộc bắt buộc, dựng nguyên bộ giả chỉ để
kiểm một phép ghép trường là quá đắt và giòn. Tách phép ghép ra hàm thuần —
vừa test được trực tiếp, vừa là chỗ duy nhất diễn giải quy tắc full-replace.

- [ ] **Step 1: Viết test thất bại**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_curtain_app/features/home/domain/entities/home_entity.dart';
import 'package:smart_curtain_app/features/home/domain/home_update_merge.dart';

void main() {
  const current = HomeEntity(
    id: 'h1', name: 'Cũ', ownerUserId: 'u1', geoName: 'Ho Chi Minh City, Vietnam',
    latitude: 10.8231, longitude: 106.6297, timezone: 'Asia/Ho_Chi_Minh',
  );

  test('đổi mỗi tên thì giữ nguyên toạ độ, geoName và timezone', () {
    // PUT của backend là full-replace: trường nào không gửi sẽ bị XOÁ.
    final merged = mergeHomeUpdate(current: current, name: 'Mới');
    expect(merged.name, 'Mới');
    expect(merged.latitude, 10.8231);
    expect(merged.longitude, 106.6297);
    expect(merged.geoName, 'Ho Chi Minh City, Vietnam');
    expect(merged.timezone, 'Asia/Ho_Chi_Minh');
  });

  test('giá trị mới ghi đè giá trị cũ', () {
    final merged = mergeHomeUpdate(
      current: current, name: 'Cũ',
      geoName: 'Tokyo, Japan', latitude: 35.6762, longitude: 139.6503,
    );
    expect(merged.latitude, 35.6762);
    expect(merged.geoName, 'Tokyo, Japan');
    expect(merged.timezone, 'Asia/Ho_Chi_Minh'); // không đụng tới
  });

  test('giữ nguyên id và ownerUserId', () {
    final merged = mergeHomeUpdate(current: current, name: 'Mới');
    expect(merged.id, 'h1');
    expect(merged.ownerUserId, 'u1');
  });
}
```

- [ ] **Step 2: Chạy test để chắc chắn nó hỏng**

Run: `fvm flutter test test/features/home/home_update_merge_test.dart`
Expected: FAIL — `home_update_merge.dart` chưa tồn tại.

- [ ] **Step 3: Tạo hàm ghép**

`lib/features/home/domain/home_update_merge.dart`:

```dart
import 'entities/home_entity.dart';

/// Ghép giá trị người dùng vừa sửa lên bản ghi home đang có.
///
/// Endpoint PUT của backend là **full-replace**: trường nào không gửi sẽ bị
/// xoá. Màn đổi tên chỉ truyền `name`, nên nếu không lấp lại các trường còn
/// lại từ [current] thì toạ độ và timezone sẽ mất — kéo theo automation thời
/// tiết chết âm thầm.
HomeEntity mergeHomeUpdate({
  required HomeEntity current,
  required String name,
  String? geoName,
  double? latitude,
  double? longitude,
  String? timezone,
}) {
  return HomeEntity(
    id: current.id,
    name: name,
    ownerUserId: current.ownerUserId,
    geoName: geoName ?? current.geoName,
    latitude: latitude ?? current.latitude,
    longitude: longitude ?? current.longitude,
    timezone: timezone ?? current.timezone,
  );
}
```

- [ ] **Step 4: Chạy test**

Run: `fvm flutter test test/features/home/home_update_merge_test.dart`
Expected: 3 PASS.

- [ ] **Step 5: Thêm field vào event**

```dart
class UpdateHomeEvent extends HomeManagementEvent {
  final String homeId;
  final String name;
  final String? geoName;
  final double? latitude;
  final double? longitude;

  /// IANA timezone id. When provided, the backend re-syncs every AUTOMATION
  /// scene of the home to the new zone.
  final String? timezone;
  const UpdateHomeEvent({
    required this.homeId,
    required this.name,
    this.geoName,
    this.latitude,
    this.longitude,
    this.timezone,
  });
```

Nhớ thêm `latitude, longitude` vào `props`.

- [ ] **Step 6: Sửa `_onUpdateHome` dùng hàm ghép**

Thay khối `updateHome(...)` ở `home_management_bloc.dart:246-250`:

```dart
    final current =
        state.homes.where((h) => h.id == event.homeId).firstOrNull;
    // Chưa nạp được bản ghi hiện tại thì gửi nguyên như cũ — thà giữ hành vi
    // cũ còn hơn ghi đè bằng null.
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
```

`firstOrNull` cần `import 'package:collection/collection.dart';` nếu file chưa
có. Thêm `import '../../domain/home_update_merge.dart';`.

- [ ] **Step 7: Chạy test và phân tích**

Run: `fvm flutter test test/features/home && fvm flutter analyze lib/`
Expected: PASS, không `error •`.

- [ ] **Step 8: Commit** (chỉ khi được phép)

```bash
git add lib/features/home test/features/home
git commit -m "fix: giữ toạ độ và timezone khi đổi tên home"
```

---

### Task 9: Chọn thành phố cho home

**Files:**
- Create: `lib/features/home/data/city_catalog.dart`
- Create: `lib/features/home/presentation/pages/city_picker_page.dart`
- Modify: `lib/features/home/presentation/pages/home_settings_page.dart:133-139`
- Test: `test/features/home/city_catalog_test.dart`

**Interfaces:**
- Consumes: `UpdateHomeEvent` có `latitude`/`longitude` (Task 8)
- Produces:
  - `class CityEntry` với `final String name; final String country; final double latitude; final double longitude;`
  - `const List<CityEntry> kCityCatalog`
  - `List<CityEntry> searchCities(String query)`
  - `class CityPickerPage extends StatefulWidget`, trả `CityEntry` qua `Navigator.pop`

- [ ] **Step 1: Viết test thất bại**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_curtain_app/features/home/data/city_catalog.dart';

void main() {
  test('bảng thành phố có toạ độ hợp lệ', () {
    expect(kCityCatalog, isNotEmpty);
    for (final c in kCityCatalog) {
      expect(c.latitude, inInclusiveRange(-90, 90), reason: c.name);
      expect(c.longitude, inInclusiveRange(-180, 180), reason: c.name);
      expect(c.name.trim(), isNotEmpty);
    }
  });

  test('tìm không phân biệt hoa thường và dấu cách thừa', () {
    expect(searchCities('  ho chi  ').map((c) => c.name),
        contains('Ho Chi Minh City'));
  });

  test('không có thành phố trùng tên trong cùng quốc gia', () {
    final keys = kCityCatalog.map((c) => '${c.name}|${c.country}').toList();
    expect(keys.toSet().length, keys.length);
  });
}
```

- [ ] **Step 2: Chạy test để chắc chắn nó hỏng**

Run: `fvm flutter test test/features/home/city_catalog_test.dart`
Expected: FAIL — `city_catalog.dart` chưa tồn tại.

- [ ] **Step 3: Tạo bảng thành phố**

`city_catalog.dart` — danh sách hằng 63 mục, phủ đủ vùng của 14 ngôn ngữ app hỗ trợ cộng các thành phố lớn Việt Nam. Dùng nguyên danh sách dưới đây, không cắt bớt:

```dart
class CityEntry {
  final String name;
  final String country;
  final double latitude;
  final double longitude;
  const CityEntry(this.name, this.country, this.latitude, this.longitude);
}

const List<CityEntry> kCityCatalog = [
  // Việt Nam — thị trường chính
  CityEntry('Ho Chi Minh City', 'Vietnam', 10.8231, 106.6297),
  CityEntry('Hanoi', 'Vietnam', 21.0278, 105.8342),
  CityEntry('Da Nang', 'Vietnam', 16.0544, 108.2022),
  CityEntry('Hai Phong', 'Vietnam', 20.8449, 106.6881),
  CityEntry('Can Tho', 'Vietnam', 10.0452, 105.7469),
  CityEntry('Nha Trang', 'Vietnam', 12.2388, 109.1967),
  // Đông Nam Á
  CityEntry('Singapore', 'Singapore', 1.3521, 103.8198),
  CityEntry('Bangkok', 'Thailand', 13.7563, 100.5018),
  CityEntry('Kuala Lumpur', 'Malaysia', 3.1390, 101.6869),
  CityEntry('Jakarta', 'Indonesia', -6.2088, 106.8456),
  CityEntry('Manila', 'Philippines', 14.5995, 120.9842),
  // Đông Á — ja, ko, zh, zh_Hant
  CityEntry('Tokyo', 'Japan', 35.6762, 139.6503),
  CityEntry('Osaka', 'Japan', 34.6937, 135.5023),
  CityEntry('Seoul', 'South Korea', 37.5665, 126.9780),
  CityEntry('Busan', 'South Korea', 35.1796, 129.0756),
  CityEntry('Beijing', 'China', 39.9042, 116.4074),
  CityEntry('Shanghai', 'China', 31.2304, 121.4737),
  CityEntry('Guangzhou', 'China', 23.1291, 113.2644),
  CityEntry('Shenzhen', 'China', 22.5431, 114.0579),
  CityEntry('Hong Kong', 'Hong Kong', 22.3193, 114.1694),
  CityEntry('Taipei', 'Taiwan', 25.0330, 121.5654),
  CityEntry('Kaohsiung', 'Taiwan', 22.6273, 120.3014),
  // Nam Á
  CityEntry('Mumbai', 'India', 19.0760, 72.8777),
  CityEntry('New Delhi', 'India', 28.6139, 77.2090),
  // Trung Đông — ar
  CityEntry('Dubai', 'United Arab Emirates', 25.2048, 55.2708),
  CityEntry('Abu Dhabi', 'United Arab Emirates', 24.4539, 54.3773),
  CityEntry('Riyadh', 'Saudi Arabia', 24.7136, 46.6753),
  CityEntry('Doha', 'Qatar', 25.2854, 51.5310),
  CityEntry('Cairo', 'Egypt', 30.0444, 31.2357),
  // Châu Âu — de, es, fr, it, pt, ru
  CityEntry('London', 'United Kingdom', 51.5074, -0.1278),
  CityEntry('Paris', 'France', 48.8566, 2.3522),
  CityEntry('Berlin', 'Germany', 52.5200, 13.4050),
  CityEntry('Munich', 'Germany', 48.1351, 11.5820),
  CityEntry('Frankfurt', 'Germany', 50.1109, 8.6821),
  CityEntry('Madrid', 'Spain', 40.4168, -3.7038),
  CityEntry('Barcelona', 'Spain', 41.3874, 2.1686),
  CityEntry('Rome', 'Italy', 41.9028, 12.4964),
  CityEntry('Milan', 'Italy', 45.4642, 9.1900),
  CityEntry('Lisbon', 'Portugal', 38.7223, -9.1393),
  CityEntry('Porto', 'Portugal', 41.1579, -8.6291),
  CityEntry('Amsterdam', 'Netherlands', 52.3676, 4.9041),
  CityEntry('Zurich', 'Switzerland', 47.3769, 8.5417),
  CityEntry('Vienna', 'Austria', 48.2082, 16.3738),
  CityEntry('Moscow', 'Russia', 55.7558, 37.6173),
  CityEntry('Saint Petersburg', 'Russia', 59.9311, 30.3609),
  // Bắc Mỹ — en
  CityEntry('New York', 'United States', 40.7128, -74.0060),
  CityEntry('Los Angeles', 'United States', 34.0522, -118.2437),
  CityEntry('San Francisco', 'United States', 37.7749, -122.4194),
  CityEntry('Chicago', 'United States', 41.8781, -87.6298),
  CityEntry('Seattle', 'United States', 47.6062, -122.3321),
  CityEntry('Toronto', 'Canada', 43.6532, -79.3832),
  CityEntry('Vancouver', 'Canada', 49.2827, -123.1207),
  // Mỹ Latin — es_419, pt_BR
  CityEntry('Mexico City', 'Mexico', 19.4326, -99.1332),
  CityEntry('Bogota', 'Colombia', 4.7110, -74.0721),
  CityEntry('Lima', 'Peru', -12.0464, -77.0428),
  CityEntry('Santiago', 'Chile', -33.4489, -70.6693),
  CityEntry('Buenos Aires', 'Argentina', -34.6037, -58.3816),
  CityEntry('Sao Paulo', 'Brazil', -23.5505, -46.6333),
  CityEntry('Rio de Janeiro', 'Brazil', -22.9068, -43.1729),
  // Châu Đại Dương
  CityEntry('Sydney', 'Australia', -33.8688, 151.2093),
  CityEntry('Melbourne', 'Australia', -37.8136, 144.9631),
  CityEntry('Auckland', 'New Zealand', -36.8485, 174.7633),
];

/// Tìm theo tên hoặc quốc gia, bỏ qua hoa thường và khoảng trắng thừa.
List<CityEntry> searchCities(String query) {
  final q = query.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  if (q.isEmpty) return kCityCatalog;
  return kCityCatalog
      .where((c) =>
          c.name.toLowerCase().contains(q) ||
          c.country.toLowerCase().contains(q))
      .toList();
}
```

- [ ] **Step 4: Chạy test**

Run: `fvm flutter test test/features/home/city_catalog_test.dart`
Expected: 3 PASS.

- [ ] **Step 5: Dựng `CityPickerPage`**

Ô tìm kiếm ở trên (`searchCity`), `ListView.builder` bên dưới hiện `name` và `country`. Bấm một dòng thì `Navigator.pop(context, entry)`. Tiêu đề trang dùng `selectCity`. Màu dùng `context.surfaces.*`.

- [ ] **Step 6: Nối vào Home Settings**

Thay `onTap: () => _notYet(AppL10n.of(context).location)` (dòng 138) bằng:

```dart
                  onTap: () async {
                    final city = await Navigator.of(context).push<CityEntry>(
                      MaterialPageRoute(builder: (_) => const CityPickerPage()),
                    );
                    if (city == null || !mounted) return;
                    context.read<HomeManagementBloc>().add(
                          UpdateHomeEvent(
                            homeId: widget.homeId,
                            name: widget.homeName,
                            geoName: '${city.name}, ${city.country}',
                            latitude: city.latitude,
                            longitude: city.longitude,
                          ),
                        );
                    _load();
                  },
```

- [ ] **Step 7: Chạy toàn bộ test và phân tích**

Run: `fvm flutter test && fvm flutter analyze lib/`
Expected: PASS, không `error •`.

- [ ] **Step 8: Commit** (chỉ khi được phép)

```bash
git add lib/features/home test/features/home
git commit -m "feat: chọn thành phố để ghi toạ độ cho home"
```

---

### Task 10: Kiểm thử trên thiết bị thật

**Files:** không sửa file nào.

- [ ] **Step 1: Build và cài**

```bash
set -a; . ./.env; set +a
fvm flutter build ios --release \
  --dart-define=API_ENV=publish \
  --dart-define=APP_SECRET_IOS="$APP_SECRET_IOS" \
  --dart-define=APP_SECRET_ANDROID="$APP_SECRET_ANDROID" \
  --no-tree-shake-icons
xcrun devicectl device install app \
  --device 00008130-00161D963443001C build/ios/iphoneos/Runner.app
```

- [ ] **Step 2: Đối chiếu checklist**

- Tạo automation với một điều kiện thiết bị, đổi trạng thái thiết bị đó, xác nhận nổ trong ~5 giây.
- Đổi trạng thái lần nữa trong vòng 60 giây, xác nhận KHÔNG nổ lại.
- Tạo automation khi điều kiện ĐANG thoả sẵn, xác nhận không nổ ngay.
- Mở lại scene vừa tạo, xác nhận điều kiện hiển thị đúng và sửa được.
- Đặt Precondition khung qua đêm (22:00→05:00), lưu, mở lại xác nhận giữ nguyên.
- Chọn thành phố cho home, đổi tên home, mở lại xác nhận toạ độ CÒN.
- Kiểm tra scene logs có bản ghi `triggerType: "DEVICE_STATUS"`.
- Xem lại toàn bộ màn mới ở dark mode.

---

## Việc phải làm ngoài code

Trước khi làm **Task 6 Step 4** (cho trộn điều kiện lịch và thiết bị trong cùng một scene), hỏi team backend: khi scene có cả `SCHEDULE` lẫn `DEVICE_STATUS`, backend xử lý ra sao — lịch là khung chặn hay trigger độc lập? Với `AND`, một thời điểm và một trạng thái kéo dài kết hợp thế nào?

Nếu backend chưa xử lý trường hợp này: bỏ bước chọn loại ở Task 6 Step 1-2, khoá mỗi scene về một loại điều kiện, và dùng Precondition (Task 7) để giới hạn khung giờ. Phần còn lại của plan không đổi.
