import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_curtain_app/features/scene/domain/entities/tap_to_run_scene_entity.dart';
import 'package:smart_curtain_app/features/scene/domain/entities/scene_action_entity.dart';
import 'package:smart_curtain_app/features/scene/presentation/bloc/tap_to_run/tap_to_run_bloc.dart';
import 'package:smart_curtain_app/features/scene/presentation/bloc/tap_to_run/tap_to_run_event.dart';
import 'package:smart_curtain_app/features/scene/presentation/bloc/tap_to_run/tap_to_run_state.dart';
import 'package:smart_curtain_app/features/scene/presentation/pages/tap_to_run/select_device_function_page.dart';
import 'package:smart_curtain_app/features/scene/presentation/pages/tap_to_run/delay_config_sheet.dart';
import 'package:smart_curtain_app/features/home/presentation/bloc/home_management_bloc.dart';
import 'package:smart_curtain_app/features/home/domain/entities/home_device_entity.dart';

class CreateTapToRunPage extends StatefulWidget {
  final TapToRunSceneEntity? existingScene;

  const CreateTapToRunPage({super.key, this.existingScene});

  @override
  State<CreateTapToRunPage> createState() => _CreateTapToRunPageState();
}

class _CreateTapToRunPageState extends State<CreateTapToRunPage> {
  final _nameController = TextEditingController();
  final List<SceneActionEntity> _actions = [];
  bool _showOnHomePage = true;
  bool get _isEditing => widget.existingScene != null;

  static const _bgColor = Color(0xFFF5F6FA);
  static const _blueAccent = Color(0xFF2196F3);

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.existingScene!.name;
      _actions.addAll(widget.existingScene!.actions);
    } else {
      _nameController.text = 'Scene Name';
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
        backgroundColor: _bgColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: _bgColor,
          elevation: 0,
          leading: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.black87, fontSize: 16),
            ),
          ),
          leadingWidth: 80,
          actions: [
            TextButton(
              onPressed: _saveScene,
              child: const Text(
                'Save',
                style: TextStyle(
                  color: _blueAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Scene name — large bold text with pencil icon
              _SceneNameHeader(
                controller: _nameController,
                onTap: _showNameEditDialog,
              ),
              const SizedBox(height: 20),
              // If card
              _IfCard(),
              const SizedBox(height: 12),
              // Then card
              _ThenCard(
                actions: _actions,
                onAddAction: _showAddActionSheet,
                onRemoveAction: (index) => setState(() => _actions.removeAt(index)),
              ),
              const SizedBox(height: 12),
              // More Settings card
              GestureDetector(
                onTap: _showMoreSettings,
                child: const _MoreSettingsCard(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showNameEditDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Scene Name'),
        content: TextField(
          controller: _nameController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter scene name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {});
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAddActionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Text(
                  'Add Task',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                ),
              ),
              // Control Single Device
              _buildTaskRow(
                icon: Icons.lightbulb_outline,
                iconColor: const Color(0xFFFFB300),
                label: 'Control Single Device',
                onTap: () { Navigator.pop(ctx); _addDeviceAction(); },
              ),
              // Select smart scenes
              _buildTaskRow(
                icon: Icons.wb_sunny_outlined,
                iconColor: const Color(0xFFFF7043),
                label: 'Select smart scenes',
                onTap: () { Navigator.pop(ctx); _addRunSceneAction(); },
              ),
              // Send notification (disabled)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Icon(Icons.sms_outlined, size: 28, color: Colors.grey.shade300),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Send notification',
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade300),
                      ),
                    ),
                    Icon(Icons.error_outline, size: 22, color: Colors.grey.shade300),
                  ],
                ),
              ),
              // Delay the action
              _buildTaskRow(
                icon: Icons.hourglass_bottom,
                iconColor: const Color(0xFF2196F3),
                label: 'Delay the action',
                onTap: () { Navigator.pop(ctx); _addDelayAction(); },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskRow({
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
              child: Text(
                label,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
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

    // All Devices page handles device selection + function selection internally.
    // Back from function page → returns to All Devices (not here).
    // Returns SceneActionEntity only when user completes the full flow.
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
    if (_isEditing) {
      scenes = scenes.where((s) => s.id != widget.existingScene!.id).toList();
    }
    if (scenes.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No other scenes available')),
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
              child: Text(
                'Select Scene',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
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

  void _showMoreSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: StatefulBuilder(
          builder: (ctx, setLocal) => Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            decoration: const BoxDecoration(
              color: Color(0xFFF5F6FA),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header: More Settings + Done
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 8, 12),
                  child: Row(
                    children: [
                      const Spacer(),
                      const Text(
                        'More Settings',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text(
                          'Done',
                          style: TextStyle(color: Color(0xFF2196F3), fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                // Style row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Text('Style', style: TextStyle(fontSize: 16, color: Colors.black87)),
                        const Spacer(),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.play_circle_filled, color: Colors.red.shade400, size: 20),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.chevron_right, color: Colors.grey.shade400),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Show on Home Page
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Text('Show on Home Page', style: TextStyle(fontSize: 16, color: Colors.black87)),
                        const Spacer(),
                        Switch(
                          value: _showOnHomePage,
                          onChanged: (v) {
                            setLocal(() {});
                            setState(() => _showOnHomePage = v);
                          },
                          activeTrackColor: Colors.green,
                          activeThumbColor: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Executed By
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Text('Executed By', style: TextStyle(fontSize: 16, color: Colors.black87)),
                        const Spacer(),
                        Text('Cloud', style: TextStyle(fontSize: 15, color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Delete button (only in edit mode)
                if (_isEditing)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        showDialog(
                          context: context,
                          builder: (dlg) => AlertDialog(
                            title: const Text('Delete scene?'),
                            content: const Text('This action cannot be undone.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(dlg), child: const Text('Cancel')),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(dlg);
                                  context.read<TapToRunBloc>().add(
                                    DeleteTapToRunSceneEvent(widget.existingScene!.id),
                                  );
                                  Navigator.pop(context);
                                },
                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Delete',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveScene() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a scene name')),
      );
      return;
    }
    if (_actions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least 1 action')),
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
      context.read<TapToRunBloc>().add(
            CreateTapToRunSceneEvent(name: name, actions: _actions),
          );
    }
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _SceneNameHeader extends StatelessWidget {
  const _SceneNameHeader({
    required this.controller,
    required this.onTap,
  });

  final TextEditingController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text =
        controller.text.isEmpty ? 'Scene Name' : controller.text;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.edit_outlined, size: 18, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

class _IfCard extends StatelessWidget {
  const _IfCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'If',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade300,
                  ),
                  child: const Icon(Icons.add, size: 18, color: Colors.white),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Launch Tap-to-Run row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(Icons.touch_app,
                    color: Colors.deepOrange.shade300, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Launch Tap-to-Run',
                  style: TextStyle(fontSize: 15, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThenCard extends StatelessWidget {
  const _ThenCard({
    required this.actions,
    required this.onAddAction,
    required this.onRemoveAction,
  });

  final List<SceneActionEntity> actions;
  final VoidCallback onAddAction;
  final void Function(int index) onRemoveAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Then',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onAddAction,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF2196F3),
                    ),
                    child: const Icon(Icons.add, size: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          if (actions.isNotEmpty) ...[
            const Divider(height: 1),
            ...actions.asMap().entries.map(
                  (entry) => _ActionRow(
                    index: entry.key,
                    action: entry.value,
                    totalCount: actions.length,
                    onRemove: () => onRemoveAction(entry.key),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.index,
    required this.action,
    required this.totalCount,
    required this.onRemove,
  });

  final int index;
  final SceneActionEntity action;
  final int totalCount;
  final VoidCallback onRemove;

  (IconData, String, String) _resolveDisplay() {
    switch (action.actionType) {
      case 'DEVICE_CONTROL':
        final dp = action.executorProperty;
        final subtitle = action.functionName != null
            ? '${action.functionName}: ${dp?['dpValue']}'
            : 'dpId ${dp?['dpId']}: ${dp?['dpValue']}';
        return (Icons.devices, action.deviceName ?? 'Device', subtitle);
      case 'DELAY':
        final minutes = action.executorProperty?['minutes'] ?? 0;
        final seconds = action.executorProperty?['seconds'] ?? 0;
        final subtitle =
            minutes > 0 ? '${minutes}m ${seconds}s' : '${seconds}s';
        return (Icons.timer_outlined, 'Wait', subtitle);
      case 'SCENE_RUN':
        return (
          Icons.play_circle_outline,
          'Run Scene',
          action.deviceName ?? action.entityId ?? '',
        );
      default:
        return (Icons.help_outline, action.actionType, '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final (icon, title, subtitle) = _resolveDisplay();
    return Column(
      children: [
        Dismissible(
          key: Key('action_${action.actionType}_$index'),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => onRemove(),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 20, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
        if (index < totalCount - 1)
          Divider(
            height: 1,
            indent: 64,
            color: Colors.grey.shade200,
          ),
      ],
    );
  }
}

class _MoreSettingsCard extends StatelessWidget {
  const _MoreSettingsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            const Text(
              'More Settings',
              style: TextStyle(fontSize: 15, color: Colors.black87),
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

/// Full-page device picker matching Tuya "All Devices" screen.
/// Full-page device picker. Tapping a device navigates to
/// [SelectDeviceFunctionPage]; pressing back there returns here.
/// Only pops with a [SceneActionEntity] when the full flow completes.
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

    // Only pop back to create page if user completed function selection
    if (action != null && context.mounted) {
      Navigator.pop(context, action);
    }
    // Otherwise stays on this page (user pressed back on function page)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'All Devices',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: ListView.separated(
        itemCount: devices.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          indent: 72,
          color: Colors.grey.shade200,
        ),
        itemBuilder: (context, index) {
          final device = devices[index];
          return Material(
            color: Colors.white,
            child: InkWell(
              onTap: () => _onDeviceTap(context, device),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.devices_other,
                        size: 24,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        device.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey.shade400,
                    ),
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
