import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_curtain_app/core/theme/app_colors.dart';
import 'package:smart_curtain_app/features/home/presentation/bloc/home_management_bloc.dart';
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
import 'package:smart_curtain_app/features/scene/presentation/pages/automation/schedule_condition_page.dart';

/// A device-control action only carries `deviceName` in memory (set by the
/// device picker). After a save + reload the backend returns just `entityId`
/// (name/function aren't persisted), so resolve the display name from the
/// home's current device list. Falls back to `'Device'` when the id is unknown
/// (e.g. the device was removed).
String resolveActionDeviceName(
    SceneActionEntity action, List<HomeDeviceEntity> devices) {
  final inMemory = action.deviceName;
  if (inMemory != null && inMemory.isNotEmpty) return inMemory;
  for (final d in devices) {
    if (d.deviceId == action.entityId) return d.displayName;
  }
  return 'Device';
}

class AutomationDetailPage extends StatefulWidget {
  /// Pass existing automation to edit, or null to create new.
  final AutomationSceneEntity? automation;

  /// Pre-populated condition (from Schedule picker when creating).
  final ScheduleConditionEntity? initialCondition;

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
  late List<ScheduleConditionEntity> _conditions;
  late String _conditionLogic;
  late List<SceneActionEntity> _actions;
  late bool _enabled;

  bool get _isCreating => widget.automation == null;

  @override
  void initState() {
    super.initState();
    final a = widget.automation;
    if (a != null) {
      // Edit mode
      _nameController = TextEditingController(text: a.name);
      _conditions = List.of(a.conditions);
      _conditionLogic = a.conditionLogic;
      _actions = List.of(a.actions);
      _enabled = a.enabled;
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
    final et = widget.automation?.effectiveTime;
    if (et == null || et.isAllDay) return 'All day';
    return '${et.startTime ?? ''} - ${et.endTime ?? ''}';
  }

  String get _conditionLogicText {
    return _conditionLogic == 'OR'
        ? 'When any condition is met'
        : 'When all conditions are met';
  }

  // ─── Save ───
  void _save() {
    if (_conditions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least 1 condition')),
      );
      return;
    }
    if (_actions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least 1 action')),
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
            actions: _actions,
          ));
    } else {
      if (name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a name')),
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
            effectiveTime: widget.automation!.effectiveTime,
            actions: _actions,
          ));
    }
  }

  // ─── Rename ───
  void _showRenameDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Rename',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        content: TextField(
          controller: _nameController,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Enter name',
            hintStyle: const TextStyle(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.surfaceMuted,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(ctx);
            },
            child: const Text('OK',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ─── Name input (create mode) ───
  void _showNameInputDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Center(
          child: Text('Scene Name',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Enter scene name',
            hintStyle: const TextStyle(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.surfaceMuted,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              final n = controller.text.trim();
              if (n.isEmpty) return;
              Navigator.pop(ctx);
              _nameController.text = n;
              _save();
            },
            child: const Text('Confirm',
                style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
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
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Text('Add Condition',
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
                    const Expanded(
                      child: Text('Launch Tap-to-Run',
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
                label: 'Schedule',
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
    final updated = await Navigator.push<ScheduleConditionEntity>(
      context,
      MaterialPageRoute(
        builder: (_) => ScheduleConditionPage(existing: existing),
      ),
    );
    if (updated != null && mounted) {
      setState(() => _conditions[index] = updated);
    }
  }

  Future<void> _addScheduleCondition() async {
    final condition = await Navigator.push<ScheduleConditionEntity>(
      context,
      MaterialPageRoute(builder: (_) => const ScheduleConditionPage()),
    );
    if (condition != null && mounted) {
      setState(() => _conditions.add(condition));
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
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Text('Add Task',
                    style: const TextStyle(fontSize: 16, color: AppColors.textSecondary)),
              ),
              _buildTaskRow(
                ctx: ctx,
                icon: Icons.lightbulb_outline,
                iconColor: const Color(0xFFFFB300),
                label: 'Control Single Device',
                onTap: () {
                  Navigator.pop(ctx);
                  _addDeviceAction();
                },
              ),
              _buildTaskRow(
                ctx: ctx,
                icon: Icons.wb_sunny_outlined,
                iconColor: const Color(0xFFFF7043),
                label: 'Select smart scenes',
                onTap: () {
                  Navigator.pop(ctx);
                  _addRunSceneAction();
                },
              ),
              _buildTaskRow(
                ctx: ctx,
                icon: Icons.hourglass_bottom,
                iconColor: AppColors.primary,
                label: 'Delay the action',
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
        const SnackBar(content: Text('No devices available')),
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
        const SnackBar(content: Text('No scenes available')),
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
              child: Text('Select Scene',
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
          decoration: const BoxDecoration(
            color: AppColors.background,
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
                      const Text('More Settings',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Done',
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
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Text('Executed By',
                                  style: TextStyle(fontSize: 16, color: AppColors.textPrimary)),
                              const Spacer(),
                              const Text('Local Association',
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
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text('Delete',
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

  void _showDeleteConfirmation() {
    final name = _nameController.text.trim();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Are you sure you want to remove '$name'?",
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'After the scenario is deleted, the device tasks can no longer be executed properly.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(fontSize: 16, color: AppColors.textPrimary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context
                  .read<AutomationBloc>()
                  .add(DeleteAutomationEvent(widget.automation!.id));
              Navigator.pop(context, true);
            },
            child: const Text('Confirm',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return BlocListener<AutomationBloc, AutomationState>(
      listener: (context, state) {
        if (state is AutomationCreated) {
          Navigator.pop(context, true);
        } else if (state is AutomationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leadingWidth: 80,
          leading: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(fontSize: 16, color: AppColors.textPrimary)),
          ),
          actions: [
            if (!_isCreating)
              TextButton(
                onPressed: _save,
                child: const Text('Save',
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
                const Text('Create Scene',
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

              // ── More Settings ──
              _buildOptionRow(
                title: 'More Settings',
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
                      child: const Text('Save',
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
          color: AppColors.surface,
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
  final List<ScheduleConditionEntity> conditions;
  final VoidCallback onAdd;
  final void Function(int index) onRemoveCondition;
  final void Function(int index) onTapCondition;

  const _IfCard({
    required this.conditionLogicText,
    required this.conditions,
    required this.onAdd,
    required this.onRemoveCondition,
    required this.onTapCondition,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('If',
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(conditionLogicText,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ),
          if (conditions.isNotEmpty) ...[
            const Divider(height: 1, color: AppColors.borderSubtle),
            ...conditions.asMap().entries.map((entry) {
              final c = entry.value;
              return Dismissible(
                key: Key('condition_${entry.key}_${c.time}'),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => onRemoveCondition(entry.key),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
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
                            color: AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.access_time,
                              size: 22, color: AppColors.primary),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Schedule',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary)),
                            const SizedBox(height: 2),
                            Text(c.displayText,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary)),
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('Then',
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
                child: const Center(
                  child: Text('Add Task',
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
      List<HomeDeviceEntity> devices) {
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
          'Delay the action',
          subtitle
        );
      case 'SCENE_RUN':
        return (
          Icons.play_circle_outline,
          Colors.orange,
          'Run Scene',
          action.deviceName ?? ''
        );
      case 'SCENE_TOGGLE':
        final en = action.executorProperty?['enabled'] ?? true;
        return (
          Icons.toggle_on_outlined,
          Colors.teal,
          'Toggle Automation',
          en == true ? 'Enable' : 'Disable'
        );
      default:
        return (Icons.help_outline, Colors.grey, action.actionType, '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final devices = context.read<HomeManagementBloc>().state.devices;
    final (icon, iconColor, title, subtitle) = _resolveDisplay(devices);
    return Dismissible(
      key: Key('action_${action.actionType}_$index'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
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
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 22, color: iconColor),
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
        const SnackBar(content: Text('Device has no profile information')),
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('All Devices',
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
            color: AppColors.surface,
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
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.devices_other,
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
