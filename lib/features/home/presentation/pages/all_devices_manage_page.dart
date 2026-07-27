import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cache/hidden_device_store.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_popup.dart';
import '../../domain/entities/home_device_entity.dart';
import '../bloc/home_management_bloc.dart';
import '../bloc/home_management_event.dart';
import '../bloc/home_management_state.dart';

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
      title: targets.length == 1
          ? 'Remove device?'
          : 'Remove ${targets.length} devices?',
      message:
          'They will be removed from this home and returned to pairing mode.',
      confirmText: 'Remove',
      destructive: true,
    );
    if (!ok || !context.mounted) return;

    for (final d in targets) {
      bloc.add(RemoveDeviceFromHomeEvent(homeId: homeId, deviceId: d.deviceId));
    }
    setState(_selected.clear);
    AppPopup.success(
      context,
      title: 'Removed',
      message: targets.length == 1
          ? '1 device removed'
          : '${targets.length} devices removed',
    );
  }

  Future<void> _changeRoom(
      BuildContext context, List<HomeDeviceEntity> devices, List rooms) async {
    if (_selected.isEmpty) return;
    if (rooms.isEmpty) {
      AppPopup.error(context,
          title: 'No rooms', message: 'Create a room first.');
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
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Move to room',
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
    AppPopup.success(context, title: 'Moved', message: 'Room updated');
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
        title: 'Moved to top',
        message: targets.length == 1
            ? '1 device'
            : '${targets.length} devices');
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
      title: wasAllHidden ? 'Shown' : 'Hidden',
      message: wasAllHidden
          ? 'Devices are back on Home'
          : 'Hidden from Home',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F4F7),
        elevation: 0,
        centerTitle: true,
        leadingWidth: 88,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
        ),
        title: const Text('All Devices',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done',
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
            return const Center(
              child: Text('No devices in this home.',
                  style: TextStyle(color: AppColors.textMuted)),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            itemCount: devices.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final d = devices[i];
              final selected = _selected.contains(d.deviceId);
              final online = d.isOnline ?? false;
              final isHidden = HiddenDeviceStore.instance
                  .isHidden(state.selectedHomeId, d.deviceId);
              final subtitle = [
                if (roomName(d.roomId).isNotEmpty) roomName(d.roomId),
                if (!online) 'Offline',
                if (isHidden) 'Hidden',
              ].join(' · ');
              return _DeviceRow(
                device: d,
                selected: selected,
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
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                    top: BorderSide(color: Color(0xFFE2EAF2), width: 0.5)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ToolbarItem(
                    icon: Icons.vertical_align_top,
                    label: 'Move to Top',
                    enabled: enabled,
                    onTap: () => _moveToTop(context, state.devices),
                  ),
                  _ToolbarItem(
                    icon: Icons.meeting_room_outlined,
                    label: 'Change Room',
                    enabled: enabled,
                    onTap: () =>
                        _changeRoom(context, state.devices, state.rooms),
                  ),
                  _ToolbarItem(
                    icon: allHidden
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    label: allHidden ? 'Show' : 'Hide',
                    enabled: enabled,
                    onTap: () => _toggleHide(context),
                  ),
                  _ToolbarItem(
                    icon: Icons.delete_outline,
                    label: 'Remove Device',
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFEDF1F6)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: device.isCurtainTrack
                    ? Padding(
                        padding: const EdgeInsets.all(3),
                        child: Image.asset('assets/icons/curtain_track.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                                Icons.curtains_outlined,
                                color: AppColors.primary)),
                      )
                    : const Icon(Icons.devices_other,
                        color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12.5, color: AppColors.textMuted)),
                  ],
                ],
              ),
            ),
            // Circular checkbox (Tuya style).
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: selected ? AppColors.primary : const Color(0xFFC7D2DE),
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
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
