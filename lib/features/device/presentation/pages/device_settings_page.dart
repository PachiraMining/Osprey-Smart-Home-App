import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/bloc/home_management_bloc.dart';
import '../../../home/presentation/bloc/home_management_event.dart';
import '../../../home/presentation/bloc/home_management_state.dart';
import '../../domain/entities/device_entity.dart';
import 'device_network_page.dart';

/// Màn "Settings" của 1 thiết bị (mở từ nút góc trên phải màn điều khiển).
///
/// Phần lớn là UI tĩnh theo thiết kế; chỉ "Device Network" và "Gỡ bỏ thiết bị"
/// hoạt động thật. "Gỡ bỏ" mở bottom sheet với 2 hành động gọi đúng API như
/// thao tác long-press ở Home: Ngắt kết nối (DELETE) / Hủy liên kết và xóa dữ
/// liệu (POST factory-reset). Gỡ thành công → quay về Home.
class DeviceSettingsPage extends StatefulWidget {
  final DeviceEntity device;
  const DeviceSettingsPage({super.key, required this.device});

  @override
  State<DeviceSettingsPage> createState() => _DeviceSettingsPageState();
}

class _DeviceSettingsPageState extends State<DeviceSettingsPage> {
  bool _offlineNotify = false;

  /// True khi đang chờ kết quả gỡ thiết bị (để BlocListener chỉ bắt mutation
  /// do màn này phát ra, không nhầm mutation của màn khác).
  bool _removing = false;

  void _comingSoon() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Feature coming soon')));
  }

  String get _deviceId => widget.device.id;
  String get _displayName => widget.device.name;

  // ─── Gỡ bỏ thiết bị ──────────────────────────────────────
  void _showRemoveSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            // Nút 1 — Ngắt kết nối (DELETE, thiết bị về pairing sau 1-2 phút)
            ListTile(
              leading: const Icon(Icons.link_off, color: AppColors.warning),
              title: const Text('Disconnect'),
              subtitle: const Text(
                'Removes from home; device returns to pairing mode in 1-2 minutes',
                style: TextStyle(fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(sheetCtx);
                _confirmDisconnect();
              },
            ),
            // Nút 2 — Hủy liên kết và xóa dữ liệu (POST factory-reset)
            ListTile(
              leading: const Icon(Icons.delete_forever, color: AppColors.error),
              title: const Text(
                'Unlink and erase data',
                style: TextStyle(color: AppColors.error),
              ),
              subtitle: const Text(
                'Erases all data, cannot be undone',
                style: TextStyle(fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(sheetCtx);
                _confirmFactoryReset();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDisconnect() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Disconnect device?'),
        content: Text(
          '"$_displayName" will be removed from your home and automatically '
          'return to pairing mode in about 1-2 minutes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.warning),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    _dispatchRemoval(factoryReset: false);
  }

  Future<void> _confirmFactoryReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Erase device data?'),
        content: Text(
          'All data for "$_displayName" will be erased and CANNOT be '
          'recovered. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    _dispatchRemoval(factoryReset: true);
  }

  void _dispatchRemoval({required bool factoryReset}) {
    final bloc = context.read<HomeManagementBloc>();
    final homeId = bloc.state.selectedHomeId;
    if (homeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No home selected, please try again')),
      );
      return;
    }
    setState(() => _removing = true);
    if (factoryReset) {
      bloc.add(FactoryResetDeviceEvent(homeId: homeId, deviceId: _deviceId));
    } else {
      bloc.add(RemoveDeviceFromHomeEvent(homeId: homeId, deviceId: _deviceId));
    }
  }

  void _onMutationResult(BuildContext context, HomeManagementState state) {
    if (!_removing) return;
    if (state.mutationStatus == MutationStatus.success) {
      _removing = false;
      // Lấy messenger gốc trước khi pop để snackbar sống sót qua điều hướng.
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).popUntil((route) => route.isFirst);
      messenger.showSnackBar(const SnackBar(
        content: Text('Device removed from home.'),
        backgroundColor: AppColors.success,
      ));
    } else if (state.mutationStatus == MutationStatus.error) {
      setState(() => _removing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(state.errorMessage ?? 'Something went wrong, please try again'),
        backgroundColor: AppColors.error,
      ));
    }
  }

  // ─── UI ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeManagementBloc, HomeManagementState>(
      listenWhen: (prev, curr) => prev.mutationStatus != curr.mutationStatus,
      listener: _onMutationResult,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios,
                size: 20, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Settings',
            style: TextStyle(
                fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
        ),
        body: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              children: [
                _sectionHeader('Device Settings'),
                _card([
                  _navRow(
                    'Device Network',
                    trailing: _isOnlineText(),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            DeviceNetworkPage(device: widget.device),
                      ),
                    ),
                  ),
                  _divider(),
                  _navRow('Device Review', onTap: _comingSoon),
                  _divider(),
                  _switchRow(
                    'Offline notification',
                    value: _offlineNotify,
                    onChanged: (v) => setState(() => _offlineNotify = v),
                  ),
                ]),
                const SizedBox(height: 24),
                _sectionHeader('General Settings'),
                _card([
                  _navRow('FAQ & feedback', onTap: _comingSoon),
                  _divider(),
                  _navRow('Add to home screen', onTap: _comingSoon),
                  _divider(),
                  _navRow(
                    'Check for updates',
                    trailing: const Text('This is the latest version',
                        style:
                            TextStyle(fontSize: 13, color: AppColors.textMuted)),
                    onTap: _comingSoon,
                  ),
                  _divider(),
                  _navRow('Contact Email', onTap: _comingSoon),
                ]),
              ],
            ),
            // Nút Gỡ bỏ thiết bị cố định đáy màn
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: _removeButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _removeButton() {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: _removing ? null : _showRemoveSheet,
        child: Container(
          height: 54,
          alignment: Alignment.center,
          child: _removing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text(
                  'Remove device',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error),
                ),
        ),
      ),
    );
  }

  Widget _isOnlineText() {
    final online = widget.device.status == 'online';
    return Text(
      online ? 'Connected' : 'Offline',
      style: TextStyle(
        fontSize: 13,
        color: online ? AppColors.success : AppColors.textMuted,
      ),
    );
  }

  // ─── building blocks ─────────────────────────────────────
  Widget _sectionHeader(String text) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
        child: Text(text,
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
      );

  Widget _card(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(children: children),
      );

  Widget _divider() =>
      const Divider(height: 1, indent: 16, endIndent: 16);

  Widget _navRow(String label, {Widget? trailing, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 15.5, color: AppColors.textPrimary)),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              Flexible(child: trailing),
            ],
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right,
                size: 20, color: AppColors.textDisabled),
          ],
        ),
      ),
    );
  }

  Widget _switchRow(String label,
      {required bool value, required ValueChanged<bool> onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 15.5, color: AppColors.textPrimary)),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
