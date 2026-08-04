import 'package:flutter/material.dart';
import '../../../../l10n/gen/app_l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/widgets/app_dialog.dart';
import '../../../home/presentation/bloc/home_management_bloc.dart';
import '../../../scene/domain/entities/automation_scene_entity.dart';
import '../../../scene/domain/usecases/delete_automation.dart';
import '../../../scene/domain/usecases/get_automations.dart';
import '../../../scene/domain/usecases/toggle_automation.dart';
import 'device_schedule_edit_page.dart';
import '../../../../core/theme/app_surfaces.dart';

/// Danh sách hẹn giờ của MỘT thiết bị.
///
/// Backend chưa có API timer riêng nên lịch được lưu dưới dạng scene
/// AUTOMATION; ở đây lọc ra những scene chỉ tác động lên đúng thiết bị này.
class DeviceSchedulePage extends StatefulWidget {
  final String deviceId;
  final String deviceName;

  const DeviceSchedulePage({
    super.key,
    required this.deviceId,
    required this.deviceName,
  });

  @override
  State<DeviceSchedulePage> createState() => _DeviceSchedulePageState();
}

class _DeviceSchedulePageState extends State<DeviceSchedulePage> {
  static const _link = Color(0xFF0D7AC4);

  List<AutomationSceneEntity> _schedules = const [];
  bool _loading = true;
  String? _homeId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  /// Lịch của thiết bị này = automation có ĐÚNG một điều kiện giờ và ĐÚNG một
  /// action điều khiển chính thiết bị đó.
  bool _belongsToDevice(AutomationSceneEntity a) =>
      a.conditions.length == 1 &&
      a.actions.length == 1 &&
      a.actions.first.actionType == 'DEVICE_CONTROL' &&
      a.actions.first.entityId == widget.deviceId;

  Future<void> _load() async {
    if (!mounted) return;
    final homeId = context.read<HomeManagementBloc>().state.selectedHomeId;
    if (homeId == null) {
      setState(() => _loading = false);
      return;
    }
    final result = await GetIt.instance<GetAutomations>()(homeId);
    if (!mounted) return;
    setState(() {
      _homeId = homeId;
      result.fold(
        (_) {},
        (list) => _schedules = list.where(_belongsToDevice).toList(),
      );
      _loading = false;
    });
  }

  Future<void> _openEditor([AutomationSceneEntity? existing]) async {
    final homeId = _homeId;
    if (homeId == null) return;
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => DeviceScheduleEditPage(
          homeId: homeId,
          deviceId: widget.deviceId,
          deviceName: widget.deviceName,
          existing: existing,
        ),
      ),
    );
    if (saved == true) _load();
  }

  Future<void> _toggle(AutomationSceneEntity schedule, bool enabled) async {
    // Cập nhật lạc quan để switch không khựng; hỏng thì trả về trạng thái cũ.
    setState(() => _schedules = [
          for (final s in _schedules)
            if (s.id == schedule.id) _copyEnabled(s, enabled) else s,
        ]);
    final result =
        await GetIt.instance<ToggleAutomation>()(schedule.id, enabled);
    if (!mounted) return;
    result.fold((failure) {
      setState(() => _schedules = [
            for (final s in _schedules)
              if (s.id == schedule.id) _copyEnabled(s, !enabled) else s,
          ]);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message), backgroundColor: Colors.red),
      );
    }, (_) {});
  }

  static AutomationSceneEntity _copyEnabled(
          AutomationSceneEntity s, bool enabled) =>
      AutomationSceneEntity(
        id: s.id,
        name: s.name,
        sceneType: s.sceneType,
        icon: s.icon,
        enabled: enabled,
        conditions: s.conditions,
        conditionLogic: s.conditionLogic,
        effectiveTime: s.effectiveTime,
        actions: s.actions,
      );

  Future<void> _delete(AutomationSceneEntity schedule) async {
    final confirmed = await AppDialog.confirm(
      context,
      title: AppL10n.of(context).deleteSchedule,
      message: AppL10n.of(context).deleteThisSchedule,
      confirmText: AppL10n.of(context).delete,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    final result = await GetIt.instance<DeleteAutomation>()(schedule.id);
    if (!mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message), backgroundColor: Colors.red),
      ),
      (_) => _load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaces.pageBg,
      appBar: AppBar(
        backgroundColor: context.surfaces.pageBg,
        elevation: 0,
        centerTitle: true,
        foregroundColor: context.surfaces.textPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppL10n.of(context).schedule,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _schedules.isEmpty
              ? _EmptyState(onAdd: _openEditor)
              : _buildList(),
      bottomNavigationBar: _schedules.isEmpty
          ? null
          : SafeArea(
              child: Material(
                color: context.surfaces.card,
                child: InkWell(
                  onTap: _openEditor,
                  child:  Padding(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: Center(
                      child: Text(
                        AppL10n.of(context).addSchedule,
                        style:
                            TextStyle(fontSize: 17, color: context.surfaces.textPrimary),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildList() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
          child: Text(
            AppL10n.of(context).timeVarianceHint,
            style: TextStyle(fontSize: 15, color: context.surfaces.textSecondary),
          ),
        ),
        Container(
          color: context.surfaces.card,
          child: Column(
            children: [
              for (var i = 0; i < _schedules.length; i++) ...[
                if (i > 0)
                  Divider(height: 1, indent: 20, color: context.surfaces.divider),
                _ScheduleRow(
                  schedule: _schedules[i],
                  onTap: () => _openEditor(_schedules[i]),
                  onToggle: (v) => _toggle(_schedules[i], v),
                  onDelete: () => _delete(_schedules[i]),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  final AutomationSceneEntity schedule;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const _ScheduleRow({
    required this.schedule,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  /// `dpValue` từ server -> nhãn hiển thị theo ngôn ngữ.
  static String _controlLabel(String? dpValue, AppL10n l10n) => switch (dpValue) {
        'open' => l10n.open,
        'stop' => l10n.stop,
        'close' => l10n.close,
        _ => dpValue ?? '',
      };

  @override
  Widget build(BuildContext context) {
    final condition = schedule.conditions.firstOrNull;
    final time = condition?.time ?? '--:--';
    final repeat = condition == null
        ? ''
        : (condition.isOneTime ? AppL10n.of(context).once : condition.displayLoops);
    final raw =
        schedule.actions.firstOrNull?.executorProperty?['dpValue'] as String?;
    final control = _controlLabel(raw, AppL10n.of(context));

    return Dismissible(
      key: ValueKey(schedule.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        onDelete();
        return false; // xoá thật do _delete lo, tránh biến mất khi user huỷ
      },
      background: Container(
        color: Colors.red,
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      time,
                      style:  TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w500,
                        color: context.surfaces.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      repeat,
                      style:
                          TextStyle(fontSize: 15, color: context.surfaces.textSecondary),
                    ),
                    if (control.isNotEmpty)
                      Text(
                        'Control:$control',
                        style: TextStyle(
                            fontSize: 15, color: context.surfaces.textSecondary),
                      ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: schedule.enabled,
                activeThumbColor: Colors.white,
                activeTrackColor: const Color(0xFF2ECC71),
                onChanged: onToggle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: context.surfaces.textMuted),
          const SizedBox(height: 12),
          Text(
            AppL10n.of(context).noTimerData,
            style: TextStyle(fontSize: 17, color: context.surfaces.textSecondary),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: 230,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D7AC4),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              onPressed: onAdd,
              child: Text(
                AppL10n.of(context).add,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
