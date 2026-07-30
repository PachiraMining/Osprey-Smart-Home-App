import 'package:flutter/material.dart';
import '../../../../l10n/gen/app_l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../home/presentation/bloc/home_management_bloc.dart';
import '../../../home/presentation/bloc/home_management_event.dart';
import '../../../home/presentation/bloc/home_management_state.dart';
import '../../domain/entities/device_entity.dart';
import '../../../home/presentation/pages/alexa_linking_page.dart';
import 'device_edit_page.dart';
import 'device_information_page.dart';
import 'device_scenes_page.dart';
import '../../../home/presentation/pages/in_app_web_page.dart';
import 'create_group_page.dart';
import 'device_network_info_page.dart';
import 'device_update_page.dart';

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

  /// Mở trang trợ giúp "Add to Home Screen" trong trình duyệt ngoài.
  ///
  /// Trang này của nhà cung cấp panel (smart321) tự dựng shortcut Safari; tên
  /// thiết bị và ngôn ngữ được truyền theo thiết bị đang xem. `schemeUrl` giữ
  /// nguyên scheme của panel — shortcut tạo ra sẽ mở panel đó, KHÔNG mở app này.
  Future<void> _openAddToHomeScreen() async {
    final uri = Uri.https('app-support.smart321.com', '/screen', {
      'icon': _addToHomeScreenIcon,
      'lang': Localizations.localeOf(context).languageCode,
      'devName': _displayName,
      'schemeUrl': 'g01g01://panelEx?devId=$_deviceId',
    });
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(AppL10n.of(context).couldNotOpenTheBrowser),
        ));
    }
  }

  static const _addToHomeScreenIcon =
      'https://d1448c85ulz2o4.cdn5th.com/smart/icon/bay1676357614061UPpS/'
      'b132ea62f1be3360afa5125704e886d7.png';

  void _comingSoon() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(AppL10n.of(context).featureComingSoon)));
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
              title: Text(AppL10n.of(context).disconnect),
              subtitle:  Text(
                AppL10n.of(context).removesFromHomeHint,
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
              title:  Text(
                AppL10n.of(context).unlinkAndEraseData,
                style: TextStyle(color: AppColors.error),
              ),
              subtitle:  Text(
                AppL10n.of(context).erasesAllDataHint,
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
    final confirmed = await AppDialog.confirm(
      context,
      title: AppL10n.of(context).disconnectDevice,
      message: AppL10n.of(context).removeDeviceConfirm(_displayName),
      confirmText: AppL10n.of(context).disconnect,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    _dispatchRemoval(factoryReset: false);
  }

  Future<void> _confirmFactoryReset() async {
    final confirmed = await AppDialog.confirm(
      context,
      title: AppL10n.of(context).eraseDeviceData,
      message: AppL10n.of(context).eraseDeviceConfirm(_displayName),
      confirmText: AppL10n.of(context).delete,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    _dispatchRemoval(factoryReset: true);
  }

  void _dispatchRemoval({required bool factoryReset}) {
    final bloc = context.read<HomeManagementBloc>();
    final homeId = bloc.state.selectedHomeId;
    if (homeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppL10n.of(context).noHomeSelectedPleaseTryAgain)),
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
      messenger.showSnackBar(SnackBar(
        content: Text(AppL10n.of(context).deviceRemovedFromHome),
        backgroundColor: AppColors.success,
      ));
    } else if (state.mutationStatus == MutationStatus.error) {
      setState(() => _removing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(state.errorMessage ?? AppL10n.of(context).somethingWentWrongTryAgain),
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
          title:  Text(
            AppL10n.of(context).settingsTitle,
            style: TextStyle(
                fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            // ── Đầu trang: ảnh thiết bị + tên + phòng ─────────────────
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => DeviceEditPage(
                          deviceId: widget.device.id,
                          deviceName: _displayName,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 52,
                            height: 52,
                            child: Image.asset(
                              'assets/icons/curtain_track_hero.png',
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.devices_other,
                                size: 28,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _roomLabel,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.edit_outlined,
                              size: 22, color: Colors.grey.shade800),
                          const SizedBox(width: 6),
                          Icon(Icons.chevron_right,
                              size: 22, color: Colors.grey.shade400),
                        ],
                      ),
                    ),
                  ),
                  Divider(height: 1, indent: 20, color: Colors.grey.shade200),
                  _row(
                    AppL10n.of(context).deviceInformation,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            DeviceInformationPage(deviceId: widget.device.id),
                      ),
                    ),
                  ),
                  _row(
                    AppL10n.of(context).deviceNetwork,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            DeviceNetworkInfoPage(device: widget.device),
                      ),
                    ),
                  ),
                  _row(
                    AppL10n.of(context).tapToRunAndAutomation,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => DeviceScenesPage(
                          deviceId: widget.device.id,
                          deviceName: _displayName,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            _sectionHeader(AppL10n.of(context).thirdPartyControl),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  _ThirdParty(
                    asset: 'assets/icons/alexa_logo.png',
                    label: AppL10n.of(context).alexa,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const AlexaLinkingPage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 34),
                  _ThirdParty(
                    asset: 'assets/icons/google_assistant_logo.png',
                    label: AppL10n.of(context).googleAssistant,
                    onTap: _comingSoon,
                  ),
                ],
              ),
            ),

            _sectionHeader(AppL10n.of(context).deviceOfflineNotification),
            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(AppL10n.of(context).offlineNotification,
                          style:
                              TextStyle(fontSize: 17, color: Colors.black87)),
                    ),
                    Switch.adaptive(
                      value: _offlineNotify,
                      activeThumbColor: Colors.white,
                      activeTrackColor: const Color(0xFF2ECC71),
                      onChanged: (v) => setState(() => _offlineNotify = v),
                    ),
                  ],
                ),
              ),
            ),

            _sectionHeader(AppL10n.of(context).others),
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _row(AppL10n.of(context).shareDevice, onTap: _comingSoon),
                  _row(
                    AppL10n.of(context).createGroup,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<bool>(
                        builder: (_) =>
                            CreateGroupPage(deviceId: widget.device.id),
                      ),
                    ),
                  ),
                  _row(
                    AppL10n.of(context).faqFeedback,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => InAppWebPage(
                          title: AppL10n.of(context).faqFeedback,
                          url: 'https://osprey.life/pages/main-faqs',
                        ),
                      ),
                    ),
                  ),
                  _row(AppL10n.of(context).addToHomeScreen, onTap: _openAddToHomeScreen),
                  _row(AppL10n.of(context).checkDeviceNetwork,
                      value: AppL10n.of(context).checkNow, onTap: _comingSoon),
                  _row(
                    AppL10n.of(context).deviceUpdate,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            DeviceUpdatePage(deviceId: widget.device.id),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Container(
              color: Colors.white,
              child: InkWell(
                onTap: _removing ? null : _showRemoveSheet,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Center(
                    child: _removing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            AppL10n.of(context).removeDevice,
                            style: TextStyle(
                                fontSize: 17, color: AppColors.error),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// "Room:Sảnh" — tra phòng của thiết bị từ state của home đang chọn.
  String get _roomLabel {
    final state = context.watch<HomeManagementBloc>().state;
    String? roomId;
    for (final d in state.devices) {
      if (d.deviceId == widget.device.id) {
        roomId = d.roomId;
        break;
      }
    }
    if (roomId == null) return 'Room:Unassigned';
    for (final r in state.rooms) {
      if (r.id == roomId) return 'Room:${r.name}';
    }
    return 'Room:Unassigned';
  }

  Widget _row(String label, {String? value, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style:
                      const TextStyle(fontSize: 17, color: Colors.black87)),
            ),
            if (value != null)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 6),
                child: Text(value,
                    style: TextStyle(
                        fontSize: 16, color: Colors.grey.shade500)),
              ),
            Icon(Icons.chevron_right, size: 22, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        child: Text(text,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
      );

}

/// Ô logo trợ lý giọng nói ở mục "Third-party Control".
class _ThirdParty extends StatelessWidget {
  final String asset;
  final String label;
  final VoidCallback onTap;

  const _ThirdParty({
    required this.asset,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 54,
            height: 54,
            child: Image.asset(
              asset,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                Icons.mic_none_rounded,
                size: 28,
                color: Colors.grey.shade400,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
