import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/widgets/app_dialog.dart';
import '../../../scene/domain/entities/automation_scene_entity.dart';
import '../../../scene/domain/entities/scene_action_entity.dart';
import '../../../scene/domain/entities/schedule_condition_entity.dart';
import '../../../scene/domain/usecases/create_automation.dart';
import '../../../scene/domain/usecases/update_automation.dart';
import '../../../scene/presentation/pages/automation/schedule_condition_page.dart'
    show oneTimeDateString;
import 'schedule_repeat_page.dart';

/// Thêm / sửa một lịch hẹn giờ của thiết bị.
///
/// Lưu dưới dạng scene AUTOMATION: một điều kiện SCHEDULE + một action
/// DEVICE_CONTROL trỏ đúng thiết bị này (backend chưa có API timer riêng).
class DeviceScheduleEditPage extends StatefulWidget {
  final String homeId;
  final String deviceId;
  final String deviceName;

  /// Null = tạo mới.
  final AutomationSceneEntity? existing;

  const DeviceScheduleEditPage({
    super.key,
    required this.homeId,
    required this.deviceId,
    required this.deviceName,
    this.existing,
  });

  @override
  State<DeviceScheduleEditPage> createState() => _DeviceScheduleEditPageState();
}

class _DeviceScheduleEditPageState extends State<DeviceScheduleEditPage> {
  static const _pageBg = Color(0xFFF2F4F7);
  static const _link = Color(0xFF007AFF);

  /// dpId 1 — lệnh điều khiển rèm.
  static const _controlDpId = 1;
  static const _controlOptions = [
    ('open', 'Open'),
    ('stop', 'Stop'),
    ('close', 'Close'),
  ];

  late int _hour;
  late int _minute;
  late String _loops;
  late String _control;
  late bool _notify;
  String _note = '';
  bool _saving = false;

  late final FixedExtentScrollController _hourCtrl;
  late final FixedExtentScrollController _minuteCtrl;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    final condition = existing?.conditions.firstOrNull;
    final now = DateTime.now();

    final parts = (condition?.time ?? '').split(':');
    _hour = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? now.hour;
    _minute = int.tryParse(parts.length > 1 ? parts[1] : '') ?? now.minute;
    _loops = condition?.loops ?? '0000000';
    _control =
        existing?.actions.firstOrNull?.executorProperty?['dpValue'] as String? ??
            'open';
    _note = existing?.name ?? '';
    _notify = (existing?.icon ?? '').contains('notify=1');

    _hourCtrl = FixedExtentScrollController(initialItem: _hour);
    _minuteCtrl = FixedExtentScrollController(initialItem: _minute);
  }

  @override
  void dispose() {
    _hourCtrl.dispose();
    _minuteCtrl.dispose();
    super.dispose();
  }

  String get _repeatLabel {
    final condition = ScheduleConditionEntity(
      conditionType: 'SCHEDULE',
      loops: _loops,
      time: '00:00',
    );
    return _loops == '0000000' ? 'Once' : condition.displayLoops;
  }

  String get _controlLabel {
    for (final (value, label) in _controlOptions) {
      if (value == _control) return label;
    }
    return 'Open';
  }

  /// "Using GMT +07:00 time zone time setting" — lấy từ múi giờ máy.
  String get _timezoneNote {
    final offset = DateTime.now().timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final h = offset.inHours.abs().toString().padLeft(2, '0');
    final m = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    return 'Using GMT $sign$h:$m time zone time setting';
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    final time =
        '${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}';
    final condition = ScheduleConditionEntity(
      conditionType: 'SCHEDULE',
      loops: _loops,
      time: time,
      // Lịch chạy một lần bắt buộc có ngày; hôm nay nếu giờ chưa qua, không
      // thì ngày mai.
      date: _loops == '0000000'
          ? oneTimeDateString(DateTime.now(), _hour, _minute)
          : null,
    );
    final action = SceneActionEntity(
      actionType: 'DEVICE_CONTROL',
      entityId: widget.deviceId,
      executorProperty: {'dpId': _controlDpId, 'dpValue': _control},
      deviceName: widget.deviceName,
      functionName: 'Control',
    );
    final name = _note.trim().isEmpty ? 'Schedule' : _note.trim();
    final icon = 'devsched|notify=${_notify ? 1 : 0}';

    final result = _isEditing
        ? await GetIt.instance<UpdateAutomation>()(
            sceneId: widget.existing!.id,
            name: name,
            icon: icon,
            enabled: widget.existing!.enabled,
            conditions: [condition],
            conditionLogic: 'AND',
            actions: [action],
          )
        : await GetIt.instance<CreateAutomation>()(
            homeId: widget.homeId,
            name: name,
            icon: icon,
            conditions: [condition],
            conditionLogic: 'AND',
            actions: [action],
          );

    if (!mounted) return;
    setState(() => _saving = false);
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message), backgroundColor: Colors.red),
      ),
      (_) => Navigator.pop(context, true),
    );
  }

  Future<void> _editNote() async {
    final note = await AppDialog.prompt(
      context,
      title: 'Note',
      initialValue: _note,
      hintText: 'Enter a note',
      confirmText: 'Save',
    );
    if (note != null && mounted) setState(() => _note = note.trim());
  }

  Future<void> _pickRepeat() async {
    final loops = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => ScheduleRepeatPage(loops: _loops)),
    );
    if (loops != null && mounted) setState(() => _loops = loops);
  }

  Future<void> _pickControl() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 10,
          right: 10,
          bottom: 10 + MediaQuery.of(ctx).padding.bottom,
        ),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text('Control',
                    style:
                        TextStyle(fontSize: 15, color: Colors.grey.shade500)),
              ),
              for (final (value, label) in _controlOptions)
                InkWell(
                  onTap: () => Navigator.pop(ctx, value),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(label,
                                style: const TextStyle(fontSize: 16))),
                        if (value == _control)
                          const Icon(Icons.check,
                              color: Color(0xFF1B4332), size: 22),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
    if (picked != null && mounted) setState(() => _control = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(
        backgroundColor: _pageBg,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Edit Schedule' : 'Add Schedule',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(
              'Save',
              style: TextStyle(
                fontSize: 17,
                color: _saving ? Colors.grey : _link,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
            child: Center(
              child: Text(
                _timezoneNote,
                style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
              ),
            ),
          ),
          Container(
            color: Colors.white,
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: _WheelColumn(
                    controller: _hourCtrl,
                    count: 24,
                    onChanged: (v) => _hour = v,
                  ),
                ),
                Expanded(
                  child: _WheelColumn(
                    controller: _minuteCtrl,
                    count: 60,
                    onChanged: (v) => _minute = v,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                _Row(label: 'Repeat', value: _repeatLabel, onTap: _pickRepeat),
                _Row(
                  label: 'Note',
                  value: _note.isEmpty ? null : _note,
                  onTap: _editNote,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text('Notification',
                            style: TextStyle(
                                fontSize: 17, color: Colors.black87)),
                      ),
                      Switch.adaptive(
                        value: _notify,
                        activeThumbColor: Colors.white,
                        activeTrackColor: const Color(0xFF2ECC71),
                        onChanged: (v) => setState(() => _notify = v),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            color: Colors.white,
            child: _Row(
              label: 'Control',
              value: _controlLabel,
              onTap: _pickControl,
            ),
          ),
        ],
      ),
    );
  }
}

/// Một cột bánh xe số 0..count-1, hiện 2 chữ số.
class _WheelColumn extends StatelessWidget {
  final FixedExtentScrollController controller;
  final int count;
  final ValueChanged<int> onChanged;

  const _WheelColumn({
    required this.controller,
    required this.count,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPicker(
      scrollController: controller,
      itemExtent: 46,
      squeeze: 1.1,
      diameterRatio: 1.6,
      selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(
        background: Color(0x00000000),
      ),
      onSelectedItemChanged: onChanged,
      children: [
        for (var i = 0; i < count; i++)
          Center(
            child: Text(
              i.toString().padLeft(2, '0'),
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;

  const _Row({required this.label, this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style:
                      const TextStyle(fontSize: 17, color: Colors.black87)),
            ),
            if (value != null && value!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  value!,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                ),
              ),
            Icon(Icons.chevron_right, size: 22, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
