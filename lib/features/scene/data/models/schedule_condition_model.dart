// ScheduleConditionModel đã chuyển vào automation_condition_model.dart để nằm
// cạnh dispatcher phân giải theo conditionType. Giữ file này làm re-export.
export 'automation_condition_model.dart'
    show
        ScheduleConditionModel,
        DeviceStatusConditionModel,
        automationConditionFromJson,
        automationConditionToJson;
