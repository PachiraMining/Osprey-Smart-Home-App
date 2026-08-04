import 'package:flutter/material.dart';
import '../../../../l10n/gen/app_l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cache/hidden_device_store.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_popup.dart';
import '../../domain/entities/home_device_entity.dart';
import '../bloc/home_management_bloc.dart';
import '../bloc/home_management_event.dart';
import '../bloc/home_management_state.dart';
import '../../../../core/theme/app_surfaces.dart';

/// Tuya-style "All Devices" management screen (opened by long-pressing a device
/// on Home): multi-select with a bottom toolbar. Remove Device is wired to the
/// real DELETE API (RemoveDeviceFromHomeEvent → DELETE /homes/{id}/devices/{id});
/// Change Room reuses UpdateHomeDeviceEvent. Move to Top / Hide are placeholders.
class AllDevicesManagePage extends StatefulWidget {
  const AllDevicesManagePage({super.key});

  @override
  State<AllDevicesManagePage> createState() => _AllDevicesManagePageState();
}

class _AllDevicesManagePageState extends State<AllDevicesManagePage> {
  final Set<String> _selected = {};

  @override
  void initState() {
    super.initState();
    HiddenDeviceStore.instance.ensureLoaded();
  }

  void _toggle(String deviceId) {
    setState(() {
      if (!_selected.remove(deviceId)) _selected.add(deviceId);
    });
  }

  Future<void> _removeSelected(
      BuildContext context, List<HomeDeviceEntity> devices) async {
    final bloc = context.read<HomeManagementBloc>();
    final homeId = bloc.state.selectedHomeId;
    if (homeId == null || _selected.isEmpty) return;

    final targets =
        devices.where((d) => _selected.contains(d.deviceId)).toList();
    final ok = await AppDialog.confirm(
      context,
      title: AppL10n.of(context).removeDevicesQ(targets.length),
      message:
          AppL10n.of(context).removeDevicesWarning,
      confirmText: AppL10n.of(context).remove,
      destructive: true,
    );
    if (!ok || !context.mounted) return;

    for (final d in targets) {
      bloc.add(RemoveDeviceFromHomeEvent(homeId: homeId, deviceId: d.deviceId));
    }
    setState(_selected.clear);
    AppPopup.success(
      context,
      title: AppL10n.of(context).removed,
      message: AppL10n.of(context).devicesRemoved(targets.length),
    );
  }

  Future<void> _changeRoom(
      BuildContext context, List<HomeDeviceEntity> devices, List rooms) async {
    if (_selected.isEmpty) return;
    if (rooms.isEmpty) {
      AppPopup.error(context,
          title: AppL10n.of(context).noRooms, message: AppL10n.of(context).createARoomFirst);
      return;
    }
    final bloc = context.read<HomeManagementBloc>();
    final homeId = bloc.state.selectedHomeId;
    if (homeId == null) return;

    final roomId = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(AppL10n.of(context).moveToRoom,
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            for (final r in rooms)
              ListTile(
                leading: const Icon(Icons.meeting_room_outlined,
                    color: AppColors.primary),
                title: Text(r.name as String),
                onTap: () => Navigator.pop(sheetCtx, r.id as String),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (roomId == null || !context.mounted) return;

    final targets =
        devices.where((d) => _selected.contains(d.deviceId)).toList();
    for (final d in targets) {
      // Keep deviceName + sortOrder — the PUT is a full update, omitting them
      // would reset the values server-side.
      bloc.add(UpdateHomeDeviceEvent(
        homeId: homeId,
        deviceId: d.deviceId,
        roomId: roomId,
        deviceName: d.deviceName,
        sortOrder: d.sortOrder,
      ));
    }
    setState(_selected.clear);
    AppPopup.success(context, title: AppL10n.of(context).moved, message: AppL10n.of(context).roomUpdated);
  }

  /// Move to Top: rewrite sortOrder of the selected devices to below the
  /// current minimum so they render first on Home (which sorts by sortOrder).
  Future<void> _moveToTop(
      BuildContext context, List<HomeDeviceEntity> devices) async {
    if (_selected.isEmpty) return;
    final bloc = context.read<HomeManagementBloc>();
    final homeId = bloc.state.selectedHomeId;
    if (homeId == null) return;

    final targets =
        devices.where((d) => _selected.contains(d.deviceId)).toList();
    final minOrder =
        devices.map((d) => d.sortOrder).fold<int>(0, (m, s) => s < m ? s : m);
    var order = minOrder - targets.length;
    for (final d in targets) {
      bloc.add(UpdateHomeDeviceEvent(
        homeId: homeId,
        deviceId: d.deviceId,
        roomId: d.roomId,
        deviceName: d.deviceName,
        sortOrder: order,
      ));
      order++;
    }
    setState(_selected.clear);
    AppPopup.success(context,
        title: AppL10n.of(context).movedToTop,
        message: AppL10n.of(context).deviceCount(targets.length));
  }

  bool _allSelectedHidden(String? homeId) =>
      _selected.isNotEmpty &&
      _selected.every((id) => HiddenDeviceStore.instance.isHidden(homeId, id));

  /// Hide/Show toggle: if every selected device is already hidden → un-hide
  /// them; otherwise hide them. Local preference (no backend).
  Future<void> _toggleHide(BuildContext context) async {
    if (_selected.isEmpty) return;
    final homeId = context.read<HomeManagementBloc>().state.selectedHomeId;
    if (homeId == null) return;
    final store = HiddenDeviceStore.instance;
    final ids = _selected.toList();
    final wasAllHidden = _allSelectedHidden(homeId);
    if (wasAllHidden) {
      await store.show(homeId, ids);
    } else {
      await store.hide(homeId, ids);
    }
    if (!context.mounted) return;
    setState(_selected.clear);
    AppPopup.success(
      context,
      title: wasAllHidden ? AppL10n.of(context).shown : AppL10n.of(context).hidden,
      message: wasAllHidden
          ? AppL10n.of(context).devicesBackOnHome
          : AppL10n.of(context).hiddenFromHome,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaces.pageBg,
      appBar: AppBar(
        backgroundColor: context.surfaces.sheet,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(AppL10n.of(context).deviceManagement,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: context.surfaces.textPrimary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppL10n.of(context).done,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary)),
          ),
        ],
      ),
      body: BlocBuilder<HomeManagementBloc, HomeManagementState>(
        builder: (context, state) {
          final devices = state.devices;
          final rooms = state.rooms;
          // Drop selections for devices that no longer exist (after removal).
          final ids = devices.map((d) => d.deviceId).toSet();
          _selected.removeWhere((s) => !ids.contains(s));

          String roomName(String? roomId) {
            if (roomId == null) return '';
            for (final r in rooms) {
              if (r.id == roomId) return r.name;
            }
            return '';
          }

          if (devices.isEmpty) {
            return Center(
              child: Text(AppL10n.of(context).noDevicesInThisHome,
                  style: TextStyle(color: AppColors.textMuted)),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.05,
            ),
            itemCount: devices.length,
            itemBuilder: (context, i) {
              final d = devices[i];
              final isHidden = HiddenDeviceStore.instance
                  .isHidden(state.selectedHomeId, d.deviceId);
              final subtitle = [
                if (roomName(d.roomId).isNotEmpty) roomName(d.roomId),
                if (isHidden) AppL10n.of(context).hidden,
              ].join(' · ');
              return _DeviceRow(
                device: d,
                selected: _selected.contains(d.deviceId),
                subtitle: subtitle,
                onTap: () => _toggle(d.deviceId),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<HomeManagementBloc, HomeManagementState>(
        builder: (context, state) {
          final enabled = _selected.isNotEmpty;
          // When every selected device is already hidden, the Hide button flips
          // to "Show" (un-hide).
          final allHidden = _allSelectedHidden(state.selectedHomeId);
          return SafeArea(
            child: Container(
              decoration:  BoxDecoration(
                color: context.surfaces.card,
                border: Border(
                    top: BorderSide(color: Color(0xFFE2EAF2), width: 0.5)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ToolbarItem(
                    icon: Icons.vertical_align_top,
                    label: AppL10n.of(context).moveToTop,
                    enabled: enabled,
                    onTap: () => _moveToTop(context, state.devices),
                  ),
                  _ToolbarItem(
                    icon: Icons.meeting_room_outlined,
                    label: AppL10n.of(context).changeRoom,
                    enabled: enabled,
                    onTap: () =>
                        _changeRoom(context, state.devices, state.rooms),
                  ),
                  _ToolbarItem(
                    icon: allHidden
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    label: allHidden ? AppL10n.of(context).show : AppL10n.of(context).hide,
                    enabled: enabled,
                    onTap: () => _toggleHide(context),
                  ),
                  _ToolbarItem(
                    icon: Icons.delete_outline,
                    label: AppL10n.of(context).removeDevice,
                    enabled: enabled,
                    destructive: true,
                    onTap: () => _removeSelected(context, state.devices),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Thẻ vuông trong lưới chọn thiết bị: vòng chọn ở góc TRÊN-PHẢI, thiết bị
/// offline mờ hẳn đi để phân biệt ngay bằng mắt.
class _DeviceRow extends StatelessWidget {
  final HomeDeviceEntity device;
  final bool selected;
  final String subtitle;
  final VoidCallback onTap;

  const _DeviceRow({
    required this.device,
    required this.selected,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final online = device.isOnline ?? false;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Opacity(
        // Offline: cả thẻ nhạt đi, giống app tham chiếu.
        opacity: online ? 1.0 : 0.45,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.surfaces.card,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      // Ô icon giữ trắng ở cả hai chế độ (ảnh PNG nền trắng).
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFEDF1F6)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: device.isCurtainTrack
                          ? Padding(
                              padding: const EdgeInsets.all(3),
                              child: Image.asset(
                                  'assets/icons/curtain_track.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(
                                      Icons.curtains_outlined,
                                      color: AppColors.primary)),
                            )
                          : const Icon(Icons.devices_other,
                              color: AppColors.textSecondary),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? AppColors.primary : Colors.transparent,
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : const Color(0xFFC7D2DE),
                        width: 2,
                      ),
                    ),
                    child: selected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                device.displayName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:  TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.surfaces.textPrimary),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12.5, color: AppColors.textMuted)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolbarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final bool destructive;
  final VoidCallback onTap;

  const _ToolbarItem({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = !enabled
        ? const Color(0xFFB8C4D0)
        : destructive
            ? const Color(0xFFE05252)
            : AppColors.textPrimary;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: color)),
        ],
      ),
    );
  }
}
