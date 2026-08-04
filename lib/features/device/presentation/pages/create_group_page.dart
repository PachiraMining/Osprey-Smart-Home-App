import 'package:flutter/material.dart';
import '../../../../l10n/gen/app_l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/widgets/app_dialog.dart';
import '../../../home/domain/entities/home_device_entity.dart';
import '../../../home/presentation/bloc/home_management_bloc.dart';
import '../../data/device_group_service.dart';
import '../../../../core/theme/app_surfaces.dart';

/// Tạo nhóm thiết bị, bắt đầu từ thiết bị đang xem.
///
/// Backend gắn `deviceProfileId` lên nhóm nên CHỈ thiết bị **cùng loại** mới
/// ghép được — danh sách "Devices to Be Added" vì thế đã lọc sẵn theo profile
/// của thiết bị gốc.
class CreateGroupPage extends StatefulWidget {
  final String deviceId;

  const CreateGroupPage({super.key, required this.deviceId});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  static const _link = Color(0xFF007AFF);

  /// Thiết bị đã chọn vào nhóm, theo thứ tự thêm.
  late final List<String> _selected = [widget.deviceId];
  bool _saving = false;

  List<HomeDeviceEntity> get _homeDevices =>
      context.watch<HomeManagementBloc>().state.devices;

  HomeDeviceEntity? _deviceById(String id) {
    for (final d in _homeDevices) {
      if (d.deviceId == id) return d;
    }
    return null;
  }

  /// Profile của thiết bị gốc — điều kiện để nhóm được với nhau.
  String? get _profileId => _deviceById(widget.deviceId)?.deviceProfileId;

  List<HomeDeviceEntity> get _candidates {
    final profile = _profileId;
    return [
      for (final d in _homeDevices)
        if (!_selected.contains(d.deviceId) &&
            profile != null &&
            d.deviceProfileId == profile)
          d,
    ];
  }

  String get _homeName =>
      context.watch<HomeManagementBloc>().state.selectedHome?.name ?? '';

  Future<void> _save() async {
    if (_saving) return;
    final homeId = context.read<HomeManagementBloc>().state.selectedHomeId;
    final profile = _profileId;
    if (homeId == null || profile == null) return;

    if (_selected.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppL10n.of(context).addAtLeastTwoDevicesToAGroup)),
      );
      return;
    }

    final name = await AppDialog.prompt(
      context,
      title: AppL10n.of(context).groupName,
      hintText: AppL10n.of(context).enterAGroupName,
      confirmText: AppL10n.of(context).save,
    );
    if (name == null || name.trim().isEmpty || !mounted) return;

    setState(() => _saving = true);
    final group = await GetIt.instance<DeviceGroupService>().createGroup(
      homeId: homeId,
      name: name.trim(),
      deviceProfileId: profile,
      deviceIds: _selected,
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (group == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppL10n.of(context).couldNotCreateTheGroupPleaseTryAgain),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final selectedDevices = [
      for (final id in _selected)
        if (_deviceById(id) != null) _deviceById(id)!,
    ];

    return Scaffold(
      backgroundColor: context.surfaces.pageBg,
      appBar: AppBar(
        backgroundColor: context.surfaces.pageBg,
        elevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 90,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppL10n.of(context).cancel,
              style: TextStyle(fontSize: 17, color: context.surfaces.textPrimary)),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(
              AppL10n.of(context).save,
              style: TextStyle(
                fontSize: 17,
                color: _saving ? Colors.grey : _link,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
        children: [
           Center(
            child: Text(
              AppL10n.of(context).createGroup,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 18, color: context.surfaces.textSecondary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  AppL10n.of(context).groupControlHint,
                  style:
                      TextStyle(fontSize: 15, color: context.surfaces.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Card([
            for (final device in selectedDevices)
              _DeviceRow(
                device: device,
                homeName: _homeName,
                // Thiết bị gốc không bỏ ra được — nhóm phải có nó.
                onAction: device.deviceId == widget.deviceId
                    ? null
                    : () => setState(() => _selected.remove(device.deviceId)),
                adding: false,
              ),
          ]),
          const SizedBox(height: 22),
          Text(
            AppL10n.of(context).devicesToBeAdded,
            style: TextStyle(fontSize: 15, color: context.surfaces.textSecondary),
          ),
          const SizedBox(height: 10),
          if (_candidates.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                AppL10n.of(context).noSameTypeDevices,
                style: TextStyle(fontSize: 15, color: context.surfaces.textSecondary),
              ),
            )
          else
            _Card([
              for (final device in _candidates)
                _DeviceRow(
                  device: device,
                  homeName: _homeName,
                  adding: true,
                  onAction: () =>
                      setState(() => _selected.add(device.deviceId)),
                ),
            ]),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;

  const _Card(this.children);

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        color: context.surfaces.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: children),
    );
  }
}

class _DeviceRow extends StatelessWidget {
  final HomeDeviceEntity device;
  final String homeName;

  /// `true` → nút xanh dấu cộng, `false` → nút đỏ dấu trừ.
  final bool adding;
  final VoidCallback? onAction;

  const _DeviceRow({
    required this.device,
    required this.homeName,
    required this.adding,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: onAction,
            child: Icon(
              adding ? Icons.add_circle : Icons.remove_circle,
              size: 28,
              color: onAction == null
                  ? context.surfaces.divider
                  : (adding
                      ? const Color(0xFF2ECC71)
                      : const Color(0xFFFF3B30)),
            ),
          ),
          const SizedBox(width: 14),
          SizedBox(
            width: 46,
            height: 46,
            child: Image.asset(
              'assets/icons/curtain_track_hero.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(Icons.devices_other,
                  size: 24, color: context.surfaces.textMuted),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  device.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:  TextStyle(
                      fontSize: 17, color: context.surfaces.textPrimary),
                ),
                const SizedBox(height: 3),
                Text(
                  homeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      TextStyle(fontSize: 15, color: context.surfaces.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
