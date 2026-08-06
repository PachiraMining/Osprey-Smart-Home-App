# Automation "When Device Status Changes" — Thiết kế

**Ngày:** 2026-08-06
**Trạng thái:** Đã duyệt thiết kế, chưa triển khai
**Backend:** Đã live trên staging + production từ 2026-08-06, verified E2E trên thiết bị thật. Không có API mới.

## Mục tiêu

Cho phép người dùng tạo automation kích hoạt bởi trạng thái thiết bị (`DEVICE_STATUS`), bổ sung vào loại điều kiện `SCHEDULE` đã có. Kèm hai phần phụ trợ: trình sửa khung giờ hiệu lực (`effectiveTime`) và ghi toạ độ cho home.

Phạm vi đợt này gồm cả ba phần:

| | Việc | Ghi chú |
|---|---|---|
| A | Điều kiện `DEVICE_STATUS` + trừu tượng hoá điều kiện | Phần chính |
| B | UI sửa `effectiveTime` ("Precondition") | Entity đã có, thiếu UI |
| C | Ghi `latitude`/`longitude` cho home | Điều kiện tiên quyết cho Weather trigger |

## Hiện trạng codebase

Khảo sát trước khi thiết kế:

- `CreateSceneTriggerPage` **đã có** cell "When device status changes", hiện gọi `_comingSoon`. Chuỗi đã dịch đủ 14 ngôn ngữ.
- Toàn bộ tầng automation **khoá cứng** vào `ScheduleConditionEntity` (lớp cụ thể, không phải trừu tượng): entity, model, event, bloc, `AutomationDetailPage`, `_IfCard`.
- `GetDeviceDataPoints(deviceProfileId)` **đã có và đang chạy** cho phần chọn action. `HomeDeviceEntity.deviceProfileId` có sẵn.
- `EffectiveTimeEntity` **đã hỗ trợ đủ** `ALL_DAY`/`CUSTOM` + `startTime`/`endTime`/`loops`/`timeZoneId`, nhưng `AutomationDetailPage` chỉ đọc ra hiển thị rồi truyền lại nguyên si — không có UI sửa.
- `conditionLogic` được lưu và hiển thị nhưng **không có UI đổi**; luôn `AND` khi tạo.
- `home_settings_page.dart` **đã có** dòng `Location`, hiện gọi `_notYet`, hiển thị "To be set" khi `geoName` rỗng.
- `createHome`/`updateHome` ở tầng repository **đã nhận** `geoName`, `latitude`, `longitude`, `timezone`.

### Bug chặn phần C

`_onUpdateHome` trong `home_management_bloc.dart` gọi `updateHome(homeId, name, geoName, timezone)` — **thiếu `latitude` và `longitude`**. Endpoint PUT là full-replace, nên đổi tên home sẽ xoá sạch toạ độ vừa đặt. Phải sửa cùng phần C, nếu không automation thời tiết sẽ chết âm thầm sau lần đổi tên đầu tiên.

Lưu ý: hàm backfill timezone ngay bên dưới (`_backfillTimezone`) **có** truyền đủ `latitude`/`longitude` — nên đây là thiếu sót riêng của `_onUpdateHome`, không phải quy ước chung.

## A. Trừu tượng hoá điều kiện

### Lựa chọn

**Sealed class** (chọn) — `sealed class AutomationConditionEntity` với hai lớp con. Dart 3 bắt `switch` phải vét cạn, nên khi thêm loại thứ ba (Weather) compiler sẽ chỉ ra mọi chỗ cần sửa thay vì để sót lúc chạy. Khớp với quy ước dự án trong CLAUDE.md ("use switch expressions and pattern matching where appropriate").

Đã cân nhắc và loại:
- *Một entity phẳng với field nullable cho cả hai loại* — ít file hơn nhưng mọi nơi dùng phải tự nhớ field nào hợp lệ với loại nào, đúng kiểu lỗi âm thầm.
- *Hai danh sách riêng* — vỡ ngay, vì backend trả một mảng `conditions` chung và `conditionLogic` áp lên toàn bộ.

### Entity

```
sealed class AutomationConditionEntity {
  String get conditionType;
}

class ScheduleConditionEntity extends AutomationConditionEntity   // giữ nguyên field hiện có
class DeviceStatusConditionEntity extends AutomationConditionEntity {
  String entityId;    // UUID thiết bị, cùng home
  String dpCode;      // lấy từ GET /products/{deviceProfileId}/datapoints, field `code`
  String operator;    // == != > >= < <=
  Object value;       // số, bool, hoặc chuỗi — đúng kiểu JSON
  String valueType;   // NUMBER | BOOLEAN | STRING (ENUM dùng STRING)
}
```

`ScheduleConditionEntity` giữ nguyên toàn bộ field và getter hiện có để không phá phần lịch đang chạy.

### Model

`AutomationSceneModel.fromJson` phân giải theo `conditionType`:

- `"SCHEDULE"` → `ScheduleConditionModel`
- `"DEVICE_STATUS"` → `DeviceStatusConditionModel`
- Không nhận ra → **bỏ qua điều kiện đó**, ghi log, không ném lỗi. Backend có thể thêm loại mới (Weather) trước khi app kịp cập nhật; ném lỗi ở đây sẽ làm hỏng cả danh sách automation.

`toJson` gửi đúng schema mục 3 của spec backend.

### Các file phải sửa theo

`automation_scene_entity.dart`, `automation_scene_model.dart`, `automation_event.dart`, `automation_bloc.dart`, `automation_detail_page.dart`, `_IfCard`, `CreateSceneTriggerPage`.

## A. Luồng tạo điều kiện thiết bị

Nút `+` trong thẻ `If` hiện nhảy **thẳng** vào `ScheduleConditionPage`. Chèn thêm bước chọn loại:

```
[+] → sheet chọn loại
        ├── Schedule        → ScheduleConditionPage (đã có)
        └── Device status   → DeviceConditionPage (mới)
                                ├── chọn thiết bị trong home
                                ├── nạp datapoints theo deviceProfileId
                                ├── chọn DP
                                └── chọn toán tử + nhập giá trị
```

`CreateSceneTriggerPage` cell "When device status changes" trỏ vào cùng `DeviceConditionPage`, rồi `pushReplacement` sang `AutomationDetailPage` với điều kiện đã điền sẵn — đúng khuôn mẫu cell Schedule đang dùng.

### Render ô nhập theo `dpType`

| `dpType` | Toán tử cho phép | Ô nhập | `valueType` gửi lên |
|---|---|---|---|
| `ENUM` | `==` `!=` | dropdown từ `constraints.range` | `STRING` |
| `BOOLEAN` | `==` | toggle On/Off | `BOOLEAN` |
| `VALUE` | `==` `!=` `>` `>=` `<` `<=` | ô số, chặn theo `min`/`max`/`step` | `NUMBER` |
| `STRING` | `==` `!=` | ô chữ | `STRING` |

**Lọc bỏ DP có `mode: "WO"`** — ghi được nhưng không đọc được thì không dùng làm điều kiện được. `DataPointEntity.isWritable` hiện có sẵn cho chiều ngược lại (chọn action); cần thêm getter `isReadable` (`mode == 'RW' || mode == 'RO'`).

`enumOptions` đã có sẵn trên `DataPointEntity`, đọc cả `constraints.range` lẫn `constraints.values`.

## A. Thẻ If

Dòng `When all/any condition is met` hiện là chữ chết → thành dropdown bấm được, đổi `conditionLogic` giữa `AND`/`OR`.

Mỗi dòng điều kiện render theo loại:
- `SCHEDULE` — icon đồng hồ xanh, tiêu đề `Schedule: HH:mm`, phụ đề là ngày/thứ lặp
- `DEVICE_STATUS` — ảnh thiết bị, tiêu đề là tên thiết bị, phụ đề `<Tên DP> : <giá trị>`

Khớp với bố cục bản tham chiếu.

### Cho phép trộn loại điều kiện

Bản tham chiếu **cho trộn** — ảnh chụp cho thấy cùng một thẻ `If` chứa cả `Schedule: 11:43` lẫn `Osprey Smart Curtain Track / Control : Continue`, với `When any condition is met`. Thiết kế này theo hướng đó.

> **Việc cần xác minh với team backend trước khi làm phần này.** Spec backend im lặng hoàn toàn về trường hợp trộn. Khi một scene có cả `SCHEDULE` lẫn `DEVICE_STATUS`, backend xử lý ra sao — lịch đóng vai trò khung chặn, hay là trigger độc lập? Với `AND`, một *thời điểm* và một *trạng thái kéo dài* kết hợp thế nào? Bản tham chiếu chạy backend Tuya nên không suy ra được. Nếu backend chưa xử lý trường hợp này, lùi về phương án "một loại một scene" và dùng `effectiveTime` (phần B) để giới hạn khung giờ — đúng ngữ nghĩa hơn và không tạo scene chết.

## A. Câu chữ giải thích hành vi backend

Ba hành vi người dùng không thể tự đoán, cần nói rõ trong UI:

1. Automation nổ trong **~5 giây** sau khi trạng thái đổi, không tức thì tuyệt đối.
2. Sau khi nổ có **60 giây nghỉ** — bật/tắt liên tục trong một phút chỉ kích hoạt lần đầu.
3. Automation vừa tạo mà điều kiện **đang thoả sẵn sẽ không nổ ngay** — chỉ nổ ở lần chuyển trạng thái tiếp theo.

Hiển thị bằng một dòng chú thích dưới thẻ `If` khi scene có điều kiện thiết bị, không dùng popup. Popup chặn thao tác và người dùng sẽ bấm bỏ qua mà không đọc.

## B. Precondition — `effectiveTime`

Thêm dòng `Precondition` dưới thẻ `Then` trong `AutomationDetailPage`, mở trang chọn:

- **All day** → `{ "type": "ALL_DAY" }`
- **Custom** → giờ bắt đầu, giờ kết thúc, chọn thứ trong tuần

```
{ "type": "CUSTOM", "start": "18:00", "end": "06:00",
  "loops": "1111100", "timeZoneId": null }
```

`loops` là 7 ký tự Thứ2…CN, `1` = bật. Khung qua đêm (`start > end`) backend hỗ trợ đầy đủ, tính theo **ngày bắt đầu** khung — UI cần nói rõ điều này khi người dùng chọn khung vắt qua nửa đêm.

**`timeZoneId` để trống** để backend lấy timezone của home. Đây là cùng nguyên tắc đã áp cho `ScheduleConditionModel.toJson` — ghi cứng giá trị ở đây sẽ thắng timezone của home trong thứ tự ưu tiên của backend, đúng thứ đã gây ra bug automation không nổ hồi trước.

Tóm tắt khung giờ hiện ở đầu trang cạnh tên scene ("All day"), như bản tham chiếu.

## C. Vị trí home

Dòng `Location` trong `home_settings_page.dart` (đang gọi `_notYet`) mở danh sách thành phố nhúng sẵn trong app. Chọn xong ghi cả ba: `geoName`, `latitude`, `longitude`.

**Không xin quyền vị trí thiết bị.** Thời tiết chỉ cần độ chính xác cấp thành phố. Xin quyền GPS sẽ kéo theo purpose string trong Info.plist, khai báo privacy manifest, và câu hỏi từ App Review về việc tại sao app điều khiển rèm cần vị trí — rủi ro không đáng, xét cả lịch sử 4.3(a) của app này.

Kèm **sửa bug** `_onUpdateHome`: bổ sung `latitude`/`longitude` vào lời gọi `updateHome`, và thêm hai field tương ứng vào `UpdateHomeEvent`. Không sửa thì toạ độ bay mỗi lần đổi tên home.

## Kiểm thử

- **Unit — model:** `fromJson` phân giải đúng cả hai loại điều kiện; round-trip `toJson`→`fromJson` giữ nguyên dữ liệu; `conditionType` lạ bị bỏ qua chứ không ném lỗi.
- **Unit — bloc:** create và update automation với điều kiện trộn gửi đúng payload; `conditionLogic` truyền đúng.
- **Unit — regression:** `_onUpdateHome` giữ nguyên `latitude`/`longitude` khi chỉ đổi tên. Đây là bug đã biết, phải có test khoá lại.
- **Widget:** ô nhập giá trị render đúng theo từng `dpType`; DP `mode: WO` không xuất hiện trong danh sách chọn.

## Việc phải làm ngoài code

Hỏi team backend về ngữ nghĩa trộn `SCHEDULE` + `DEVICE_STATUS` (xem mục "Cho phép trộn loại điều kiện"). Câu trả lời quyết định giữ hay bỏ phần trộn.
