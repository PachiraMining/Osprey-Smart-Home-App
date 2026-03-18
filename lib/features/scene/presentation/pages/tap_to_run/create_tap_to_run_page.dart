import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_curtain_app/features/scene/domain/entities/tap_to_run_scene_entity.dart';
import 'package:smart_curtain_app/features/scene/domain/entities/scene_action_entity.dart';
import 'package:smart_curtain_app/features/scene/presentation/bloc/tap_to_run/tap_to_run_bloc.dart';
import 'package:smart_curtain_app/features/scene/presentation/bloc/tap_to_run/tap_to_run_event.dart';
import 'package:smart_curtain_app/features/scene/presentation/bloc/tap_to_run/tap_to_run_state.dart';
import 'package:smart_curtain_app/features/scene/presentation/pages/tap_to_run/select_device_function_page.dart';
import 'package:smart_curtain_app/features/scene/presentation/pages/tap_to_run/delay_config_sheet.dart';
import 'package:smart_curtain_app/features/device/presentation/bloc/device_bloc.dart';
import 'package:smart_curtain_app/features/device/presentation/bloc/device_state.dart';
import 'package:smart_curtain_app/features/device/domain/entities/device_entity.dart';

class CreateTapToRunPage extends StatefulWidget {
  final TapToRunSceneEntity? existingScene;

  const CreateTapToRunPage({super.key, this.existingScene});

  @override
  State<CreateTapToRunPage> createState() => _CreateTapToRunPageState();
}

class _CreateTapToRunPageState extends State<CreateTapToRunPage> {
  final _nameController = TextEditingController();
  final List<SceneActionEntity> _actions = [];
  bool get _isEditing => widget.existingScene != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.existingScene!.name;
      _actions.addAll(widget.existingScene!.actions);
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
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: Text(_isEditing ? 'Sửa Scene' : 'Tạo Tap-to-Run'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0.5,
          actions: [
            TextButton(
              onPressed: _saveScene,
              child: const Text('Lưu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Scene name
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Tên Scene',
                          hintText: 'Ví dụ: Buổi sáng, Đi ngủ...',
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.edit_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // THEN header
                    Row(
                      children: [
                        Container(width: 4, height: 20, decoration: BoxDecoration(color: const Color(0xFF2196F3), borderRadius: BorderRadius.circular(2))),
                        const SizedBox(width: 8),
                        const Text('THEN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2196F3))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Actions list
                    if (_actions.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.add_circle_outline, size: 48, color: Colors.grey.shade300),
                            const SizedBox(height: 8),
                            Text('Thêm ít nhất 1 action', style: TextStyle(color: Colors.grey.shade500)),
                          ],
                        ),
                      )
                    else
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _actions.length,
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) newIndex--;
                            final item = _actions.removeAt(oldIndex);
                            _actions.insert(newIndex, item);
                          });
                        },
                        itemBuilder: (context, index) {
                          return _buildActionCard(index, key: ValueKey('action_$index'));
                        },
                      ),
                    const SizedBox(height: 12),
                    // Add action button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: const BorderSide(color: Color(0xFF2196F3)),
                        ),
                        onPressed: _showAddActionSheet,
                        icon: const Icon(Icons.add, color: Color(0xFF2196F3)),
                        label: const Text('Thêm Action', style: TextStyle(color: Color(0xFF2196F3), fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(int index, {Key? key}) {
    final action = _actions[index];
    IconData icon;
    String title;
    String subtitle;

    switch (action.actionType) {
      case 'DEVICE_CONTROL':
        icon = Icons.devices;
        title = action.deviceName ?? 'Thiết bị';
        final dp = action.executorProperty;
        subtitle = action.functionName != null
            ? '${action.functionName}: ${dp?['dpValue']}'
            : 'dpId ${dp?['dpId']}: ${dp?['dpValue']}';
        break;
      case 'DELAY':
        icon = Icons.timer_outlined;
        title = 'Chờ';
        final minutes = action.executorProperty?['minutes'] ?? 0;
        final seconds = action.executorProperty?['seconds'] ?? 0;
        subtitle = minutes > 0 ? '${minutes}m ${seconds}s' : '${seconds}s';
        break;
      case 'SCENE_RUN':
        icon = Icons.play_circle_outline;
        title = 'Chạy Scene';
        subtitle = action.deviceName ?? action.entityId ?? '';
        break;
      default:
        icon = Icons.help_outline;
        title = action.actionType;
        subtitle = '';
    }

    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF2196F3).withAlpha(30),
          child: Icon(icon, color: const Color(0xFF2196F3), size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.drag_handle, color: Colors.grey.shade400),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => setState(() => _actions.removeAt(index)),
              child: const Icon(Icons.close, color: Colors.red, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddActionSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Thêm Action', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFE3F2FD), child: Icon(Icons.devices, color: Color(0xFF2196F3))),
              title: const Text('Điều khiển thiết bị'),
              subtitle: const Text('Chọn thiết bị và chức năng'),
              onTap: () { Navigator.pop(ctx); _addDeviceAction(); },
            ),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFFFF3E0), child: Icon(Icons.timer_outlined, color: Colors.orange)),
              title: const Text('Delay'),
              subtitle: const Text('Chờ một khoảng thời gian'),
              onTap: () { Navigator.pop(ctx); _addDelayAction(); },
            ),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFE8F5E9), child: Icon(Icons.play_circle_outline, color: Colors.green)),
              title: const Text('Chạy Scene khác'),
              subtitle: const Text('Trigger một Tap-to-Run scene'),
              onTap: () { Navigator.pop(ctx); _addRunSceneAction(); },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _addDeviceAction() async {
    final deviceState = context.read<DeviceBloc>().state;
    List<DeviceEntity> devices = [];
    if (deviceState is DeviceLoaded) {
      devices = deviceState.devices;
    }
    if (devices.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không có thiết bị nào')));
      return;
    }

    final selectedDevice = await showModalBottomSheet<DeviceEntity>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.8,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            const Padding(padding: EdgeInsets.all(16), child: Text('Chọn thiết bị', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: devices.length,
                itemBuilder: (_, i) {
                  final device = devices[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: device.isOnline ? Colors.green.withAlpha(30) : Colors.grey.withAlpha(30),
                      child: Icon(Icons.devices, color: device.isOnline ? Colors.green : Colors.grey),
                    ),
                    title: Text(device.name),
                    subtitle: Text(device.type),
                    trailing: Icon(Icons.circle, color: device.isOnline ? Colors.green : Colors.grey, size: 10),
                    onTap: () => Navigator.pop(ctx, device),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

    if (selectedDevice == null || !mounted) return;

    final profileId = selectedDevice.deviceProfileId;
    if (profileId == null || profileId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thiết bị không có thông tin profile')));
      return;
    }

    final action = await Navigator.push<SceneActionEntity>(
      context,
      MaterialPageRoute(builder: (_) => SelectDeviceFunctionPage(deviceId: selectedDevice.id, deviceName: selectedDevice.name, deviceProfileId: profileId)),
    );

    if (action != null && mounted) {
      setState(() => _actions.add(action));
    }
  }

  Future<void> _addDelayAction() async {
    final result = await showModalBottomSheet<Map<String, int>>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => const DelayConfigSheet(),
    );
    if (result != null && mounted) {
      setState(() {
        _actions.add(SceneActionEntity(
          actionType: 'DELAY',
          executorProperty: {'minutes': result['minutes'] ?? 0, 'seconds': result['seconds'] ?? 0},
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không có scene nào khác')));
      return;
    }

    final selected = await showModalBottomSheet<TapToRunSceneEntity>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(padding: EdgeInsets.all(16), child: Text('Chọn Scene', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            ...scenes.map((s) => ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFE8F5E9), child: Icon(Icons.play_circle_outline, color: Colors.green)),
              title: Text(s.name),
              subtitle: Text('${s.actions.length} actions'),
              onTap: () => Navigator.pop(ctx, s),
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
    if (selected != null && mounted) {
      setState(() {
        _actions.add(SceneActionEntity(actionType: 'SCENE_RUN', entityId: selected.id, deviceName: selected.name));
      });
    }
  }

  void _saveScene() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tên scene')));
      return;
    }
    if (_actions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng thêm ít nhất 1 action')));
      return;
    }
    if (_isEditing) {
      context.read<TapToRunBloc>().add(UpdateTapToRunSceneEvent(sceneId: widget.existingScene!.id, name: name, actions: _actions));
    } else {
      context.read<TapToRunBloc>().add(CreateTapToRunSceneEvent(name: name, actions: _actions));
    }
  }
}
