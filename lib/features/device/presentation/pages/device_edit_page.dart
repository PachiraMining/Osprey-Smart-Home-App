import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_dialog.dart';
import '../../../home/domain/entities/room_entity.dart';
import '../../../home/presentation/bloc/home_management_bloc.dart';
import '../../../home/presentation/bloc/home_management_event.dart';

/// Sửa thông tin trưng bày của thiết bị: ảnh, tên, phòng.
///
/// Tên và phòng lưu qua `PUT /homes/{homeId}/devices/{deviceId}`. Hàng "Icon"
/// chưa lưu được vì API thiết bị-trong-home không có field icon (chỉ Room mới
/// có), nên nó chỉ báo chưa hỗ trợ thay vì âm thầm mất dữ liệu.
class DeviceEditPage extends StatefulWidget {
  final String deviceId;
  final String deviceName;

  const DeviceEditPage({
    super.key,
    required this.deviceId,
    required this.deviceName,
  });

  @override
  State<DeviceEditPage> createState() => _DeviceEditPageState();
}

class _DeviceEditPageState extends State<DeviceEditPage> {
  static const _pageBg = Color(0xFFF2F4F7);

  late String _name = widget.deviceName;

  String? get _homeId =>
      context.read<HomeManagementBloc>().state.selectedHomeId;

  /// Phòng hiện tại của thiết bị, đọc từ state của home đang chọn.
  RoomEntity? get _room {
    final state = context.watch<HomeManagementBloc>().state;
    String? roomId;
    for (final d in state.devices) {
      if (d.deviceId == widget.deviceId) {
        roomId = d.roomId;
        break;
      }
    }
    if (roomId == null) return null;
    for (final r in state.rooms) {
      if (r.id == roomId) return r;
    }
    return null;
  }

  Future<void> _rename() async {
    final name = await AppDialog.prompt(
      context,
      title: 'Name',
      initialValue: _name,
      hintText: 'Enter device name',
      confirmText: 'Save',
    );
    final homeId = _homeId;
    if (name == null || name.trim().isEmpty || homeId == null || !mounted) {
      return;
    }
    final trimmed = name.trim();
    context.read<HomeManagementBloc>().add(UpdateHomeDeviceEvent(
          homeId: homeId,
          deviceId: widget.deviceId,
          deviceName: trimmed,
        ));
    setState(() => _name = trimmed);
  }

  Future<void> _pickRoom() async {
    final state = context.read<HomeManagementBloc>().state;
    final rooms = state.rooms;
    final homeId = _homeId;
    if (homeId == null) return;
    if (rooms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create a room first.')),
      );
      return;
    }

    final picked = await showModalBottomSheet<RoomEntity>(
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
                child: Text('Location',
                    style:
                        TextStyle(fontSize: 15, color: Colors.grey.shade500)),
              ),
              for (final room in rooms)
                InkWell(
                  onTap: () => Navigator.pop(ctx, room),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(room.name,
                              style: const TextStyle(fontSize: 16)),
                        ),
                        if (room.id == _room?.id)
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

    if (picked == null || !mounted) return;
    context.read<HomeManagementBloc>().add(UpdateHomeDeviceEvent(
          homeId: homeId,
          deviceId: widget.deviceId,
          roomId: picked.id,
        ));
  }

  void _iconNotSupported() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(
        content: Text('Custom device icons are not supported yet.'),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(
        backgroundColor: _pageBg,
        elevation: 0,
        foregroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 26),
            alignment: Alignment.center,
            child: SizedBox(
              height: 160,
              child: Image.asset(
                'assets/icons/curtain_track_hero.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.devices_other,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          ),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                _EditRow(label: 'Icon', onTap: _iconNotSupported),
                _EditRow(label: 'Name', value: _name, onTap: _rename),
                _EditRow(
                  label: 'Location',
                  value: _room?.name ?? 'Unassigned',
                  onTap: _pickRoom,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditRow extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;

  const _EditRow({required this.label, this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Text(label,
                style: const TextStyle(fontSize: 17, color: Colors.black87)),
            const Spacer(),
            if (value != null && value!.isNotEmpty)
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 6),
                  child: Text(
                    value!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 17, color: Colors.black87),
                  ),
                ),
              ),
            Icon(Icons.chevron_right, size: 22, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
