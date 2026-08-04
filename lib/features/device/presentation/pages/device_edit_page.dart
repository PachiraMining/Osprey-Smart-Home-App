import 'package:flutter/material.dart';
import '../../../../l10n/gen/app_l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_dialog.dart';
import '../../../home/domain/entities/room_entity.dart';
import '../../../home/presentation/bloc/home_management_bloc.dart';
import '../../../home/presentation/bloc/home_management_event.dart';
import '../../../../core/theme/app_surfaces.dart';

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
      title: AppL10n.of(context).name,
      initialValue: _name,
      hintText: AppL10n.of(context).enterDeviceName,
      confirmText: AppL10n.of(context).save,
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
        SnackBar(content: Text(AppL10n.of(context).createARoomFirst)),
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
            color: context.surfaces.card,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(AppL10n.of(context).location,
                    style:
                        TextStyle(fontSize: 15, color: context.surfaces.textSecondary)),
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
      ..showSnackBar(SnackBar(
        content: Text(AppL10n.of(context).customDeviceIconsAreNotSupportedYet),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaces.pageBg,
      appBar: AppBar(
        backgroundColor: context.surfaces.pageBg,
        elevation: 0,
        foregroundColor: context.surfaces.textPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            color: context.surfaces.card,
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
                  color: context.surfaces.textMuted,
                ),
              ),
            ),
          ),
          Container(
            color: context.surfaces.card,
            child: Column(
              children: [
                _EditRow(label: AppL10n.of(context).icon, onTap: _iconNotSupported),
                _EditRow(label: AppL10n.of(context).name, value: _name, onTap: _rename),
                _EditRow(
                  label: AppL10n.of(context).location,
                  value: _room?.name ?? AppL10n.of(context).unassigned,
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
                style:  TextStyle(fontSize: 17, color: context.surfaces.textPrimary)),
            const Spacer(),
            if (value != null && value!.isNotEmpty)
              Flexible(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 12, end: 6),
                  child: Text(
                    value!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style:  TextStyle(fontSize: 17, color: context.surfaces.textPrimary),
                  ),
                ),
              ),
            Icon(Icons.chevron_right, size: 22, color: context.surfaces.textMuted),
          ],
        ),
      ),
    );
  }
}
