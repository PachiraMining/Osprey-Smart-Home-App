import 'package:flutter/material.dart';
import '../../../../l10n/gen/app_l10n.dart';

import '../../../../core/widgets/app_pull_refresh.dart';

import 'package:smart_curtain_app/core/widgets/app_dialog.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/datasources/device_wifi_remote_datasource.dart';
import '../../data/models/device_wifi_models.dart';
import '../../domain/entities/device_entity.dart';
import 'add_wifi_network_page.dart';

/// Màn "Network" trong Device Detail — quản lý nhiều WiFi đã lưu trên chip và
/// chuyển WiFi mà không re-pair (Multi-WiFi Management spec 2026-06-15).
///
/// Nguồn dữ liệu: backend (GET /network-info + GET /wifi-list). `deviceId` là
/// TB DeviceId UUID = [DeviceEntity.id].
class DeviceNetworkPage extends StatefulWidget {
  final DeviceEntity device;
  const DeviceNetworkPage({super.key, required this.device});

  @override
  State<DeviceNetworkPage> createState() => _DeviceNetworkPageState();
}

class _DeviceNetworkPageState extends State<DeviceNetworkPage> {
  String get _deviceId => widget.device.id;
  DeviceWifiRemoteDataSource get _ds => sl<DeviceWifiRemoteDataSource>();

  bool _loading = true;
  String? _loadError;
  DeviceNetworkInfo? _info;
  List<SavedWifiNetwork> _networks = const [];

  // Overlay full-screen khi đang switch.
  bool _switching = false;
  String _switchingToSsid = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ─── Load: network-info + wifi-list song song ────────────────
  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final results = await Future.wait([
        _ds.getNetworkInfo(_deviceId),
        _ds.getWifiList(_deviceId),
      ]);
      if (!mounted) return;
      setState(() {
        _info = results[0] as DeviceNetworkInfo;
        _networks = results[1] as List<SavedWifiNetwork>;
        _loading = false;
      });
    } on DeviceWifiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadError = AppL10n.of(context).couldNotLoadNetworkDetails;
        _loading = false;
      });
    }
  }

  // ─── Switch flow ─────────────────────────────────────────────
  Future<void> _onSwitchTap(SavedWifiNetwork net) async {
    if (net.active) {
      _snack(AppL10n.of(context).alreadyOnThisNetwork);
      return;
    }
    final confirmed = await AppDialog.confirm(
      context,
      title: "Switch to '${net.ssid}'?",
      message: AppL10n.of(context).switchNetworkWarning,
      confirmText: AppL10n.of(context).switchNetwork,
    );
    if (!confirmed || !mounted) return;

    setState(() {
      _switching = true;
      _switchingToSsid = net.ssid;
    });
    WifiSwitchResult result;
    try {
      result = await _ds.switchWifi(_deviceId, net.id);
    } on DeviceWifiException catch (e) {
      if (!mounted) return;
      setState(() => _switching = false);
      _snack(e.message);
      return;
    } catch (_) {
      if (!mounted) return;
      setState(() => _switching = false);
      _snack('Something went wrong. Please try again.');
      return;
    }
    if (!mounted) return;
    setState(() => _switching = false);
    await _handleSwitchResult(result, net);
  }

  Future<void> _handleSwitchResult(
      WifiSwitchResult result, SavedWifiNetwork net) async {
    switch (result.outcome) {
      case WifiSwitchOutcome.switched:
        _snack("Switched to '${result.currentSsid ?? net.ssid}'",
            success: true);
        await _load(); // refresh để xác nhận state thật
        break;
      case WifiSwitchOutcome.failed:
        await _showFailedDialog(result, net);
        break;
      case WifiSwitchOutcome.timeout:
        await _showTimeoutDialog();
        break;
      case WifiSwitchOutcome.offline:
        _snack(AppL10n.of(context).deviceOfflineTryLater);
        break;
    }
  }

  Future<void> _showFailedDialog(
      WifiSwitchResult result, SavedWifiNetwork net) async {
    final reason = _reasonText(result.reason);
    final stayedOn = result.currentSsid ?? net.ssid;
    final tip = result.reason == 'no_ap_found'
        ? AppL10n.of(context).makeSureNetworkInRange(net.ssid)
        : '';
    await AppDialog.alert(
      context,
      title: AppL10n.of(context).couldNotConnect,
      message: AppL10n.of(context)
              .deviceCouldNotConnectTo(net.ssid, reason, stayedOn) +
          tip,
      buttonText: AppL10n.of(context).gotIt,
    );
  }

  Future<void> _showTimeoutDialog() async {
    final refresh = await AppDialog.confirm(
      context,
      title: AppL10n.of(context).timedOut,
      message: AppL10n.of(context).noResponseFromDevice,
      confirmText: AppL10n.of(context).refresh,
      cancelText: AppL10n.of(context).gotIt,
    );
    if (refresh) await _load();
  }

  /// Map mã reason (English debug) → câu ngắn cho người dùng.
  String _reasonText(String? reason) {
    switch (reason) {
      case 'auth_failure':
        return AppL10n.of(context).wrongPassword;
      case 'no_ap_found':
        return AppL10n.of(context).networkNotFound;
      case 'dhcp_timeout':
        return "Couldn't get an IP address";
      default:
        return "Couldn't connect";
    }
  }

  // ─── Delete flow ─────────────────────────────────────────────
  Future<void> _onDeleteTap(SavedWifiNetwork net) async {
    final confirmed = await AppDialog.confirm(
      context,
      title: "Remove '${net.ssid}'?",
      message: AppL10n.of(context).thisSavedNetworkWillBeRemovedFromTheDevice,
      confirmText: AppL10n.of(context).delete,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    try {
      await _ds.deleteWifi(_deviceId, net.id);
      if (!mounted) return;
      _snack(AppL10n.of(context).networkRemoved, success: true);
      await _load();
    } on DeviceWifiException catch (e) {
      if (!mounted) return;
      if (e.code == DeviceWifiErrorCode.notFound) {
        await _load(); // đã bị xóa ở nơi khác
        return;
      }
      _snack(e.message);
    } catch (_) {
      if (!mounted) return;
      _snack('Something went wrong. Please try again.');
    }
  }

  void _onLongPress(SavedWifiNetwork net) {
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
            if (!net.active)
              ListTile(
                leading: const Icon(Icons.swap_horiz, color: AppColors.primary),
                title: Text(AppL10n.of(context).switchToThisNetwork),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _onSwitchTap(net);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: Text(AppL10n.of(context).delete,
                  style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(sheetCtx);
                _onDeleteTap(net);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _onAddTap() async {
    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddWifiNetworkPage(deviceId: _deviceId),
      ),
    );
    if (added == true) await _load();
  }

  void _snack(String message, {bool success = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: success ? AppColors.success : null,
        behavior: SnackBarBehavior.floating,
      ));
  }

  // ─── UI ──────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title:  Text(
          AppL10n.of(context).network,
          style: TextStyle(
              fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      ),
      body: Stack(
        children: [
          _body(),
          if (_switching) _switchingOverlay(),
        ],
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return AppPullRefresh(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          if (_loadError != null) ...[
            _errorBanner(_loadError!),
            const SizedBox(height: 16),
          ],
          _sectionHeader(AppL10n.of(context).connectedTo),
          _card(child: _connectedCard()),
          const SizedBox(height: 24),
          _sectionHeader(AppL10n.of(context).savedNetworks),
          if (_networks.isEmpty)
            _card(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Text(AppL10n.of(context).noSavedNetworksYet,
                    style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
              ),
            )
          else
            _card(child: Column(children: _savedRows())),
          const SizedBox(height: 16),
          _card(
            child: InkWell(
              onTap: _onAddTap,
              borderRadius: BorderRadius.circular(14),
              child:  Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Row(
                  children: [
                    Icon(Icons.add, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      AppL10n.of(context).addANetwork,
                      style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _connectedCard() {
    final info = _info;
    final ssid = info?.currentSsid?.trim() ?? '';
    final hasSsid = ssid.isNotEmpty;
    final level = _signalLevel(info?.rssiDbm);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Icon(
            hasSsid ? Icons.wifi : Icons.wifi_off,
            color: hasSsid ? AppColors.primary : AppColors.textDisabled,
            size: 24,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasSsid ? ssid : AppL10n.of(context).notConnected,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    color:
                        hasSsid ? AppColors.textPrimary : AppColors.textMuted,
                  ),
                ),
                if (hasSsid && info?.rssiDbm != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${info!.rssiDbm} dBm',
                    style: const TextStyle(
                        fontSize: 12.5, color: AppColors.textMuted),
                  ),
                ],
              ],
            ),
          ),
          if (level != null) _SignalBars(level: level),
        ],
      ),
    );
  }

  List<Widget> _savedRows() {
    final rows = <Widget>[];
    for (var i = 0; i < _networks.length; i++) {
      if (i > 0) {
        rows.add(const Divider(height: 1, indent: 16, endIndent: 16));
      }
      rows.add(_savedRow(_networks[i]));
    }
    return rows;
  }

  Widget _savedRow(SavedWifiNetwork net) {
    return InkWell(
      onLongPress: () => _onLongPress(net),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(Icons.wifi,
                size: 22,
                color: net.active ? AppColors.success : AppColors.textSecondary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    net.ssid,
                    style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (net.hasLabel) ...[
                    const SizedBox(height: 2),
                    Text(
                      net.label!,
                      style: const TextStyle(
                          fontSize: 12.5, color: AppColors.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (net.active)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, size: 18, color: AppColors.success),
                  SizedBox(width: 4),
                  Text(AppL10n.of(context).connected,
                      style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success)),
                ],
              )
            else
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  minimumSize: const Size(0, 36),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                ),
                onPressed: () => _onSwitchTap(net),
                child: Text(AppL10n.of(context).switchNetwork,
                    style: TextStyle(
                        fontSize: 13.5, fontWeight: FontWeight.w600)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _switchingOverlay() {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black54,
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 48),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(
                  "Switching to '$_switchingToSsid'…",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                 Text(
                  AppL10n.of(context).pleaseKeepAppOpen,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── building blocks ─────────────────────────────────────────
  /// rssiDbm → mức 1..4 vạch; null nếu không có RSSI (ẩn thanh sóng).
  int? _signalLevel(int? rssi) {
    if (rssi == null) return null;
    if (rssi > -40) return 4;
    if (rssi >= -60) return 3;
    if (rssi >= -75) return 2;
    return 1;
  }

  Widget _errorBanner(String text) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.error.withAlpha(20),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(text,
            style: const TextStyle(fontSize: 13, color: AppColors.error)),
      );

  Widget _sectionHeader(String text) => Padding(
        padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8, top: 4),
        child: Text(text,
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
      );

  Widget _card({required Widget child}) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: child,
      );
}

/// 4 vạch sóng WiFi, tô đầy theo [level] (1..4).
class _SignalBars extends StatelessWidget {
  final int level;
  const _SignalBars({required this.level});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(4, (i) {
        final filled = i < level;
        return Container(
          margin: const EdgeInsetsDirectional.only(start: 3),
          width: 5,
          height: 6.0 + i * 4,
          decoration: BoxDecoration(
            color: filled ? AppColors.primary : AppColors.border,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}
