import 'package:flutter/material.dart';
import '../../../../../l10n/gen/app_l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_curtain_app/core/theme/app_colors.dart';
import 'package:smart_curtain_app/core/widgets/app_dialog.dart';
import 'package:smart_curtain_app/features/home/presentation/bloc/home_management_bloc.dart';
import 'package:smart_curtain_app/features/home/presentation/bloc/home_management_event.dart';
import 'package:smart_curtain_app/features/scene/domain/entities/automation_scene_entity.dart';
import 'package:smart_curtain_app/features/scene/domain/entities/scene_action_entity.dart';
import 'package:smart_curtain_app/features/scene/domain/entities/schedule_condition_entity.dart';
import 'package:smart_curtain_app/features/scene/domain/entities/tap_to_run_scene_entity.dart';
import 'package:smart_curtain_app/features/scene/presentation/bloc/automation/automation_bloc.dart';
import 'package:smart_curtain_app/features/scene/presentation/bloc/automation/automation_event.dart';
import 'package:smart_curtain_app/features/scene/presentation/bloc/automation/automation_state.dart';
import 'package:smart_curtain_app/features/scene/presentation/bloc/tap_to_run/tap_to_run_bloc.dart';
import 'package:smart_curtain_app/features/scene/presentation/bloc/tap_to_run/tap_to_run_state.dart';
import 'package:smart_curtain_app/features/scene/presentation/pages/tap_to_run/select_device_function_page.dart';
import 'package:smart_curtain_app/features/scene/presentation/pages/tap_to_run/delay_config_sheet.dart';
import 'package:smart_curtain_app/features/home/domain/entities/home_device_entity.dart';
import 'package:smart_curtain_app/features/scene/domain/entities/effective_time_entity.dart';
import 'package:smart_curtain_app/features/scene/presentation/pages/automation/condition_type_sheet.dart';
import 'package:smart_curtain_app/features/scene/presentation/pages/automation/precondition_page.dart';
import 'package:smart_curtain_app/features/scene/presentation/pages/automation/device_condition_page.dart';
import 'package:smart_curtain_app/features/scene/presentation/pages/automation/schedule_condition_page.dart';
import '../../../../../core/theme/app_surfaces.dart';

/// A device-control action only carries `deviceName` in memory (set by the
/// device picker). After a save + reload the backend returns just `entityId`
/// (name/function aren't persisted), so resolve the display name from the
/// home's current device list. Falls back to `'Device'` when the id is unknown
/// (e.g. the device was removed).
/// Finds the home device an action targets (entityId is normally the TB
/// deviceId; older records may carry the home-device row id).
HomeDeviceEntity? deviceForAction(
    SceneActionEntity action, List<HomeDeviceEntity> devices) {
  for (final d in devices) {
    if (d.deviceId == action.entityId || d.id == action.entityId) return d;
  }
  return null;
}

String resolveActionDeviceName(
    SceneActionEntity action, List<HomeDeviceEntity> devices) {
  final inMemory = action.deviceName;
  if (inMemory != null && inMemory.isNotEmpty) return inMemory;
  final device = deviceForAction(action, devices);
  if (device != null) return device.displayName;
  return 'Device';
}

class AutomationDetailPage extends StatefulWidget {
  /// Pass existing automation to edit, or null to create new.
  final AutomationSceneEntity? automation;

  /// Pre-populated condition (from Schedule picker when creating).
  final AutomationConditionEntity? initialCondition;

  const AutomationDetailPage({
    super.key,
    this.automation,
    this.initialCondition,
  });

  @override
  State<AutomationDetailPage> createState() => _AutomationDetailPageState();
}

class _AutomationDetailPageState extends State<AutomationDetailPage> {
  late TextEditingController _nameController;
  late List<AutomationConditionEntity> _conditions;
  late String _conditionLogic;
  late List<SceneActionEntity> _actions;
  late bool _enabled;
  EffectiveTimeEntity? _effectiveTime;

  bool get _isCreating => widget.automation == null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final hm = context.read<HomeManagementBloc>();
      final homeId = hm.state.selectedHomeId;
      if (hm.state.devices.isEmpty && homeId != null) {
        hm.add(LoadHomeDevicesEvent(homeId));
      }
    });
    final a = widget.automation;
    if (a != null) {
      // Edit mode
      _nameController = TextEditingController(text: a.name);
      _conditions = List.of(a.conditions);
      _conditionLogic = a.conditionLogic;
      _actions = List.of(a.actions);
      _enabled = a.enabled;
      _effectiveTime = a.effectiveTime;
    } else {
      // Create mode
      _nameController = TextEditingController();
      _conditions = [];
      if (widget.initialCondition != null) {
        _conditions.add(widget.initialCondition!);
      }
      _conditionLogic = 'AND';
      _actions = [];
      _enabled = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String get _effectiveTimeText {
    final et = _effectiveTime;
    if (et == null || et.isAllDay) return AppL10n.of(context).allDay;
    return '${et.startTime ?? ''} - ${et.endTime ?? ''}';
  }

  Future<void> _editPrecondition() async {
    final navigator = Navigator.of(context);
    final result = await navigator.push<EffectiveTimeEntity>(
      MaterialPageRoute(
        builder: (_) => PreconditionPage(existing: _effectiveTime),
      ),
    );
    if (result != null && mounted) {
      setState(() => _effectiveTime = result);
    }
  }

  String get _conditionLogicText {
    return _conditionLogic == 'OR'
        ? AppL10n.of(context).whenAnyConditionMet
        : AppL10n.of(context).whenAllConditionsMet;
  }

  // ─── Save ───
  void _save() {
    if (_conditions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppL10n.of(context).pleaseAddAtLeast1Condition)),
      );
      return;
    }
    if (_actions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppL10n.of(context).pleaseAddAtLeast1Action)),
      );
      return;
    }

    final name = _nameController.text.trim();

    if (_isCreating) {
      if (name.isEmpty) {
        _showNameInputDialog();
        return;
      }
      context.read<AutomationBloc>().add(CreateAutomationEvent(
            name: name,
            conditions: _conditions,
            conditionLogic: _conditionLogic,
            effectiveTime: _effectiveTime,
            actions: _actions,
          ));
    } else {
      if (name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppL10n.of(context).pleaseEnterAName)),
        );
        return;
      }
      context.read<AutomationBloc>().add(UpdateAutomationEvent(
            sceneId: widget.automation!.id,
            name: name,
            icon: widget.automation!.icon,
            enabled: _enabled,
            conditions: _conditions,
            conditionLogic: _conditionLogic,
            effectiveTime: _effectiveTime,
            actions: _actions,
          ));
    }
  }

  // ─── Rename ───
  Future<void> _showRenameDialog() async {
    final name = await AppDialog.prompt(
      context,
      title: AppL10n.of(context).rename,
      initialValue: _nameController.text,
      hintText: AppL10n.of(context).enterName,
      confirmText: AppL10n.of(context).ok,
    );
    if (name != null && mounted) {
      setState(() => _nameController.text = name);
    }
  }

  // ─── Name input (create mode) ───
  Future<void> _showNameInputDialog() async {
    final name = await AppDialog.prompt(
      context,
      title: AppL10n.of(context).sceneName,
      hintText: AppL10n.of(context).enterSceneName,
      confirmText: AppL10n.of(context).confirm,
    );
    if (name != null && mounted) {
      _nameController.text = name;
      _save();
    }
  }

  // ─── Add Condition ───
  void _showAddConditionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          decoration: BoxDecoration(
            color: context.surfaces.card,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Text(AppL10n.of(context).addCondition,
                    style: const TextStyle(fontSize: 16, color: AppColors.textSecondary)),
              ),
              // Launch Tap-to-Run — disabled
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    const Icon(Icons.touch_app, size: 28, color: AppColors.textMuted),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(AppL10n.of(context).launchTapToRun,
                          style: TextStyle(
                              fontSize: 16, color: AppColors.textMuted)),
                    ),
                    const Icon(Icons.error_outline,
                        size: 22, color: AppColors.textMuted),
                  ],
                ),
              ),
              _buildConditionRow(
                ctx: ctx,
                icon: Icons.access_time,
                iconColor: AppColors.primary,
                label: AppL10n.of(context).schedule,
                onTap: () {
                  Navigator.pop(ctx);
                  _addScheduleCondition();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConditionRow({
    required BuildContext ctx,
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 28, color: iconColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary)),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Future<void> _editCondition(int index) async {
    final existing = _conditions[index];
    final navigator = Navigator.of(context);
    final AutomationConditionEntity? updated = switch (existing) {
      DeviceStatusConditionEntity() =>
        await navigator.push<DeviceStatusConditionEntity>(
          MaterialPageRoute(
            builder: (_) => DeviceConditionPage(existing: existing),
          ),
        ),
      ScheduleConditionEntity() =>
        await navigator.push<ScheduleConditionEntity>(
          MaterialPageRoute(
            builder: (_) => ScheduleConditionPage(existing: existing),
          ),
        ),
    };
    if (updated != null && mounted) {
      setState(() => _conditions[index] = updated);
    }
  }

  Future<void> _addScheduleCondition() async {
    final navigator = Navigator.of(context);
    final kind = await showConditionTypeSheet(context);
    if (kind == null || !mounted) return;
    final AutomationConditionEntity? condition = kind == 'device'
        ? await navigator.push<DeviceStatusConditionEntity>(
            MaterialPageRoute(builder: (_) => const DeviceConditionPage()),
          )
        : await navigator.push<ScheduleConditionEntity>(
            MaterialPageRoute(builder: (_) => const ScheduleConditionPage()),
          );
    if (condition != null && mounted) {
      setState(() => _conditions.add(condition));
    }
  }

  /// Đổi giữa AND và OR cho danh sách điều kiện.
  Future<void> _pickConditionLogic() async {
    final l10n = AppL10n.of(context);
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: context.surfaces.sheet,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              title: Text(l10n.whenAllConditionsMet,
                  style: TextStyle(color: ctx.surfaces.textPrimary)),
              trailing: _conditionLogic == 'AND'
                  ? Icon(Icons.check, color: ctx.surfaces.navActive)
                  : null,
              onTap: () => Navigator.pop(ctx, 'AND'),
            ),
            ListTile(
              title: Text(l10n.whenAnyConditionMet,
                  style: TextStyle(color: ctx.surfaces.textPrimary)),
              trailing: _conditionLogic == 'OR'
                  ? Icon(Icons.check, color: ctx.surfaces.navActive)
                  : null,
              onTap: () => Navigator.pop(ctx, 'OR'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (picked != null && mounted) {
      setState(() => _conditionLogic = picked);
    }
  }

  // ─── Add Action (reuse Tap-to-Run flow) ───
  void _showAddActionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          decoration: BoxDecoration(
            color: context.surfaces.card,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Text(AppL10n.of(context).addTask,
                    style: const TextStyle(fontSize: 16, color: AppColors.textSecondary)),
              ),
              _buildTaskRow(
                ctx: ctx,
                icon: Icons.lightbulb_outline,
                iconColor: const Color(0xFFFFB300),
                label: AppL10n.of(context).controlSingleDevice,
                onTap: () {
                  Navigator.pop(ctx);
                  _addDeviceAction();
                },
              ),
              _buildTaskRow(
                ctx: ctx,
                icon: Icons.wb_sunny_outlined,
                iconColor: const Color(0xFFFF7043),
                label: AppL10n.of(context).selectSmartScenes,
                onTap: () {
                  Navigator.pop(ctx);
                  _addRunSceneAction();
                },
              ),
              _buildTaskRow(
                ctx: ctx,
                icon: Icons.hourglass_bottom,
                iconColor: AppColors.primary,
                label: AppL10n.of(context).delayTheAction,
                onTap: () {
                  Navigator.pop(ctx);
                  _addDelayAction();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskRow({
    required BuildContext ctx,
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 28, color: iconColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary)),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Future<void> _addDeviceAction() async {
    final homeState = context.read<HomeManagementBloc>().state;
    final devices = homeState.devices;
    if (devices.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppL10n.of(context).noDevicesAvailable)),
      );
      return;
    }

    final action = await Navigator.push<SceneActionEntity>(
      context,
      MaterialPageRoute(
        builder: (_) => _AllDevicesPage(devices: devices),
      ),
    );

    if (action != null && mounted) {
      setState(() => _actions.add(action));
    }
  }

  Future<void> _addDelayAction() async {
    final result = await Navigator.push<Map<String, int>>(
      context,
      MaterialPageRoute(builder: (_) => const DelayConfigPage()),
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
    if (scenes.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppL10n.of(context).noScenesAvailable)),
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
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(AppL10n.of(context).selectScene,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ...scenes.map(
              (s) => ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE8F5E9),
                  child: Icon(Icons.play_circle_outline, color: Colors.green),
                ),
                title: Text(s.name),
                subtitle: Text('${s.actions.length} actions'),
                onTap: () => Navigator.pop(ctx, s),
              ),
            ),
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

  // ─── Edit Action ───
  Future<void> _editAction(int index) async {
    final action = _actions[index];
    switch (action.actionType) {
      case 'DEVICE_CONTROL':
        final homeState = context.read<HomeManagementBloc>().state;
        final devices = homeState.devices;
        if (devices.isEmpty) return;
        final newAction = await Navigator.push<SceneActionEntity>(
          context,
          MaterialPageRoute(
            builder: (_) => _AllDevicesPage(devices: devices),
          ),
        );
        if (newAction != null && mounted) {
          setState(() => _actions[index] = newAction);
        }
      case 'DELAY':
        final result = await Navigator.push<Map<String, int>>(
          context,
          MaterialPageRoute(builder: (_) => const DelayConfigPage()),
        );
        if (result != null && mounted) {
          setState(() {
            _actions[index] = SceneActionEntity(
              actionType: 'DELAY',
              executorProperty: {
                'minutes': result['minutes'] ?? 0,
                'seconds': result['seconds'] ?? 0,
              },
            );
          });
        }
      default:
        break;
    }
  }

  // ─── More Settings ───
  void _showMoreSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.85,
        child: Container(
          decoration:  BoxDecoration(
            color: context.surfaces.pageBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 8, 12),
                  child: Row(
                    children: [
                      const Spacer(),
                      Text(AppL10n.of(context).moreSettings,
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(AppL10n.of(context).done,
                            style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // Executed By
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: context.surfaces.card,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Text(AppL10n.of(context).executedBy,
                                  style: TextStyle(fontSize: 16, color: AppColors.textPrimary)),
                              const Spacer(),
                              // Automation chạy bằng scheduler PHÍA SERVER, không
                              // đẩy xuống gateway — nhãn "Local Association" chép
                              // từ app tham chiếu là sai, mất mạng là automation
                              // dừng (đúng như banner offline đang nói).
                              Text(AppL10n.of(context).cloud,
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Delete (edit mode only)
                        if (!_isCreating) GestureDetector(
                          onTap: () {
                            Navigator.pop(ctx);
                            _showDeleteConfirmation();
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: context.surfaces.card,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(AppL10n.of(context).delete,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textSecondary)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation() async {
    final name = _nameController.text.trim();
    final ok = await AppDialog.confirm(
      context,
      title: "Are you sure you want to remove '$name'?",
      message:
          AppL10n.of(context).deleteSceneWarning,
      confirmText: AppL10n.of(context).confirm,
      destructive: true,
    );
    if (ok && mounted) {
      context
          .read<AutomationBloc>()
          .add(DeleteAutomationEvent(widget.automation!.id));
      Navigator.pop(context, true);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return BlocListener<AutomationBloc, AutomationState>(
      listener: (context, state) {
        // AutomationBloc là singleton toàn cục: mọi màn dùng chung nó. Chỉ phản
        // ứng khi màn này đang trên cùng, nếu không sẽ pop nhầm route của màn
        // khác — và pop quá tay thì Navigator rỗng, ra màn hình đen.
        if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;
        if (state is AutomationCreated) {
          Navigator.pop(context, true);
        } else if (state is AutomationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: context.surfaces.pageBg,
        appBar: AppBar(
          backgroundColor: context.surfaces.pageBg,
          elevation: 0,
          leadingWidth: 80,
          leading: TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppL10n.of(context).cancel,
                style: TextStyle(fontSize: 16, color: AppColors.textPrimary)),
          ),
          actions: [
            if (!_isCreating)
              TextButton(
                onPressed: _save,
                child: Text(AppL10n.of(context).save,
                    style: TextStyle(
                        fontSize: 16,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600)),
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),

              // ── Name ──
              if (_isCreating)
                Text(AppL10n.of(context).createScene,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
              else
                GestureDetector(
                  onTap: _showRenameDialog,
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          _nameController.text,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.edit_outlined,
                          size: 18, color: AppColors.textMuted),
                    ],
                  ),
                ),
              const SizedBox(height: 4),

              // ── Subtitle ──
              Text(_effectiveTimeText,
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),

              const SizedBox(height: 20),

              // ── IF Section ──
              _IfCard(
                conditionLogicText: _conditionLogicText,
                conditions: _conditions,
                onChangeLogic: _pickConditionLogic,
                onAdd: _showAddConditionSheet,
                onRemoveCondition: (index) =>
                    setState(() => _conditions.removeAt(index)),
                onTapCondition: _editCondition,
              ),

              const SizedBox(height: 12),

              // ── THEN Section ──
              _ThenCard(
                actions: _actions,
                onAddAction: _showAddActionSheet,
                onRemoveAction: (index) =>
                    setState(() => _actions.removeAt(index)),
                onTapAction: _editAction,
              ),

              const SizedBox(height: 10),

              // ── Precondition (khung giờ hiệu lực) ──
              _buildOptionRow(
                title: AppL10n.of(context).precondition,
                onTap: _editPrecondition,
              ),

              // ── More Settings ──
              _buildOptionRow(
                title: AppL10n.of(context).moreSettings,
                onTap: _showMoreSettings,
              ),

              // ── Save button (create mode) ──
              if (_isCreating) ...[
                const SizedBox(height: 40),
                SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0097A7),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      child: Text(AppL10n.of(context).save,
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ] else
                const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionRow({
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: context.surfaces.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            const Spacer(),
            const Icon(Icons.chevron_right, size: 20, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// IF Card — shows schedule conditions
// ─────────────────────────────────────────────────────────────────────────────
class _IfCard extends StatelessWidget {
  final String conditionLogicText;
  final List<AutomationConditionEntity> conditions;
  final VoidCallback onChangeLogic;
  final VoidCallback onAdd;
  final void Function(int index) onRemoveCondition;
  final void Function(int index) onTapCondition;

  const _IfCard({
    required this.conditionLogicText,
    required this.conditions,
    required this.onChangeLogic,
    required this.onAdd,
    required this.onRemoveCondition,
    required this.onTapCondition,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaces.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(AppL10n.of(context).conditionIf,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const Spacer(),
                GestureDetector(
                  onTap: onAdd,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                    child:
                        const Icon(Icons.add, size: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onChangeLogic,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(conditionLogicText,
                      style: TextStyle(
                          fontSize: 13,
                          color: context.surfaces.textSecondary)),
                  Icon(Icons.keyboard_arrow_down_rounded,
                      size: 18, color: context.surfaces.textSecondary),
                ],
              ),
            ),
          ),
          if (conditions.isNotEmpty) ...[
            const Divider(height: 1, color: AppColors.borderSubtle),
            ...conditions.asMap().entries.map((entry) {
              final c = entry.value;
              return Dismissible(
                key: ValueKey('condition_${entry.key}_${c.conditionType}'),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => onRemoveCondition(entry.key),
                background: Container(
                  alignment: AlignmentDirectional.centerEnd,
                  padding: const EdgeInsetsDirectional.only(end: 16),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: GestureDetector(
                  onTap: () => onTapCondition(entry.key),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            // Trắng cố định kể cả dark mode — icon bên trong
                            // vẽ cho nền sáng, giống ô icon thẻ automation.
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: switch (c) {
                            ScheduleConditionEntity() => const Icon(
                                Icons.access_time,
                                size: 22,
                                color: AppColors.primary),
                            DeviceStatusConditionEntity() => const Icon(
                                Icons.lightbulb_outline,
                                size: 22,
                                color: Color(0xFF2ECC71)),
                          },
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                switch (c) {
                                  ScheduleConditionEntity() =>
                                    AppL10n.of(context).schedule,
                                  DeviceStatusConditionEntity() =>
                                    AppL10n.of(context).deviceStatus,
                                },
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: context.surfaces.textPrimary)),
                            const SizedBox(height: 2),
                            Text(c.displayText,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: context.surfaces.textSecondary)),
                          ],
                        ),
                      ),
                        const Icon(Icons.chevron_right,
                            size: 20, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                ),
              );
            }),
            // Ba hành vi người dùng không thể tự đoán: độ trễ ~5s, nghỉ 60s,
            // và automation mới không nổ khi điều kiện đang thoả sẵn.
            if (conditions.any((c) => c is DeviceStatusConditionEntity))
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Text(
                  AppL10n.of(context).automationDelayNote,
                  style: TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: context.surfaces.textMuted),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// THEN Card — shows actions (reuse same pattern as Tap-to-Run)
// ─────────────────────────────────────────────────────────────────────────────
class _ThenCard extends StatelessWidget {
  final List<SceneActionEntity> actions;
  final VoidCallback onAddAction;
  final void Function(int index) onRemoveAction;
  final void Function(int index) onTapAction;

  const _ThenCard({
    required this.actions,
    required this.onAddAction,
    required this.onRemoveAction,
    required this.onTapAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaces.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(AppL10n.of(context).conditionThen,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const Spacer(),
                GestureDetector(
                  onTap: onAddAction,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                    child:
                        const Icon(Icons.add, size: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          if (actions.isNotEmpty) ...[
            const Divider(height: 1, color: AppColors.borderSubtle),
            ...actions.asMap().entries.map((entry) {
              final action = entry.value;
              return _ActionRow(
                index: entry.key,
                action: action,
                onRemove: () => onRemoveAction(entry.key),
                onTap: () => onTapAction(entry.key),
              );
            }),
          ] else
            // "Add Task" placeholder with dashed border
            GestureDetector(
              onTap: onAddAction,
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.textMuted,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Center(
                  child: Text(AppL10n.of(context).addTask,
                      style: TextStyle(
                          fontSize: 15, color: AppColors.textMuted)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final int index;
  final SceneActionEntity action;
  final VoidCallback onRemove;

  final VoidCallback onTap;

  const _ActionRow({
    required this.index,
    required this.action,
    required this.onRemove,
    required this.onTap,
  });

  (IconData, Color, String, String) _resolveDisplay(
      List<HomeDeviceEntity> devices, AppL10n l10n) {
    switch (action.actionType) {
      case 'DEVICE_CONTROL':
        final dp = action.executorProperty;
        final title = resolveActionDeviceName(action, devices);
        final subtitle = action.functionName != null
            ? '${action.functionName}: ${dp?['dpValue']}'
            : dp != null
                ? 'dpId ${dp['dpId']}: ${dp['dpValue']}'
                : '';
        return (Icons.devices_other, Colors.grey, title, subtitle);
      case 'DELAY':
        final m = action.executorProperty?['minutes'] ?? 0;
        final s = action.executorProperty?['seconds'] ?? 0;
        final subtitle = m > 0 ? '${m}m ${s}s' : '${s}s';
        return (
          Icons.hourglass_bottom,
          AppColors.primary,
          l10n.delayTheAction,
          subtitle
        );
      case 'SCENE_RUN':
        return (
          Icons.play_circle_outline,
          Colors.orange,
          l10n.runScene,
          action.deviceName ?? ''
        );
      case 'SCENE_TOGGLE':
        final en = action.executorProperty?['enabled'] ?? true;
        return (
          Icons.toggle_on_outlined,
          Colors.teal,
          l10n.toggleAutomation,
          en == true ? l10n.enable : l10n.disable
        );
      default:
        return (Icons.help_outline, Colors.grey, action.actionType, '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final devices = context.watch<HomeManagementBloc>().state.devices;
    final (icon, iconColor, title, subtitle) =
        _resolveDisplay(devices, AppL10n.of(context));
    final actionDevice = deviceForAction(action, devices);
    final showCurtainArt = action.actionType == 'DEVICE_CONTROL' &&
        (actionDevice?.isCurtainTrack ?? false);
    final Widget leading = showCurtainArt
        ? Padding(
            padding: const EdgeInsets.all(5),
            child: Image.asset(
              'assets/icons/curtain_track.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  Icon(icon, size: 22, color: iconColor),
            ),
          )
        : Icon(icon, size: 22, color: iconColor);
    return Dismissible(
      key: Key('action_${action.actionType}_$index'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: 16),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: showCurtainArt
                      ? Colors.white
                      : AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: leading,
              ),
              const SizedBox(width: 14),
              Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondary)),
                  ],
                ],
              ),
            ),
              const Icon(Icons.chevron_right, size: 20, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// All Devices Page — select device → select function (reuse from Tap-to-Run)
// ─────────────────────────────────────────────────────────────────────────────
class _AllDevicesPage extends StatelessWidget {
  final List<HomeDeviceEntity> devices;

  const _AllDevicesPage({required this.devices});

  Future<void> _onDeviceTap(BuildContext context, HomeDeviceEntity device) async {
    final profileId = device.deviceProfileId;
    if (profileId == null || profileId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppL10n.of(context).deviceHasNoProfileInformation)),
      );
      return;
    }

    final action = await Navigator.push<SceneActionEntity>(
      context,
      MaterialPageRoute(
        builder: (_) => SelectDeviceFunctionPage(
          deviceId: device.deviceId,
          deviceName: device.displayName,
          deviceProfileId: profileId,
        ),
      ),
    );

    if (action != null && context.mounted) {
      Navigator.pop(context, action);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaces.pageBg,
      appBar: AppBar(
        title: Text(AppL10n.of(context).allDevices,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: ListView.separated(
        itemCount: devices.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, indent: 72, color: AppColors.borderSubtle),
        itemBuilder: (context, index) {
          final device = devices[index];
          return Material(
            color: context.surfaces.card,
            child: InkWell(
              onTap: () => _onDeviceTap(context, device),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        // Ô icon giữ trắng ở cả hai chế độ (ảnh PNG nền trắng).
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: device.isCurtainTrack
                          ? Padding(
                              padding: const EdgeInsets.all(6),
                              child: Image.asset(
                                'assets/icons/curtain_track.png',
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Icon(
                                    Icons.devices_other,
                                    size: 24,
                                    color: AppColors.textSecondary),
                              ),
                            )
                          : const Icon(Icons.devices_other,
                              size: 24, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(device.displayName,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                    ),
                    const Icon(Icons.chevron_right,
                        size: 20, color: AppColors.textMuted),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
