// ScheduleConditionEntity đã chuyển vào automation_condition_entity.dart —
// `sealed` bắt buộc mọi lớp con nằm cùng library. Giữ file này làm re-export để
// các chỗ import sẵn có không phải sửa.
export 'automation_condition_entity.dart'
    show
        AutomationConditionEntity,
        ScheduleConditionEntity,
        DeviceStatusConditionEntity;
