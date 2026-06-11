import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/device_network_store.dart';
import '../../domain/entities/device_entity.dart';

/// Màn "Device Network" — xem mạng WiFi của thiết bị + thêm mạng dự phòng.
///
/// Dữ liệu:
///  - SSID: đọc từ [DeviceNetworkStore] (app lưu lúc pairing). Firmware KHÔNG
///    báo SSID/RSSI lên backend nên đây là nguồn thật duy nhất; thiết bị pair
///    trước khi có tính năng lưu sẽ hiện "—".
///  - Trạng thái: Online/Offline thật từ [DeviceEntity.status].
///  - Tín hiệu (RSSI) không có nguồn → không hiển thị thanh signal giả.
class DeviceNetworkPage extends StatefulWidget {
  final DeviceEntity device;
  const DeviceNetworkPage({super.key, required this.device});

  @override
  State<DeviceNetworkPage> createState() => _DeviceNetworkPageState();
}

class _DeviceNetworkPageState extends State<DeviceNetworkPage> {
  /// Cam đỏ theo thiết kế (checkmark + Add Alternative Network).
  static const Color _orange = Color(0xFFF1502F);

  String? _ssid;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSsid();
  }

  Future<void> _loadSsid() async {
    final ssid = await sl<DeviceNetworkStore>().getSsid(widget.device.id);
    if (!mounted) return;
    setState(() {
      _ssid = ssid;
      _loading = false;
    });
  }

  bool get _isOnline => widget.device.status == 'online';
  String get _ssidDisplay => (_ssid?.isNotEmpty ?? false) ? _ssid! : '—';

  void _comingSoon() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Feature coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Device Network',
          style: TextStyle(
              fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: _comingSoon,
            child: const Text('Edit',
                style: TextStyle(fontSize: 16, color: AppColors.primary)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _sectionHeader('Current Connection'),
          _card(child: _currentConnection()),
          const SizedBox(height: 24),
          _sectionHeader('Alternative Network'),
          const SizedBox(height: 4),
          const Text(
            'When the current network is unavailable, devices will automatically '
            'join another network.',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.4),
          ),
          const SizedBox(height: 12),
          _card(child: _alternativeRow()),
          const SizedBox(height: 16),
          _card(
            child: InkWell(
              onTap: _comingSoon,
              borderRadius: BorderRadius.circular(14),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Text(
                  'Add Alternative Network',
                  style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                      color: _orange),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _currentConnection() {
    return Column(
      children: [
        _kvRow(
          'SSID',
          _loading
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text(_ssidDisplay,
                  style: const TextStyle(
                      fontSize: 15, color: AppColors.textSecondary)),
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
        _kvRow(
          'Status',
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isOnline ? AppColors.success : AppColors.textDisabled,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _isOnline ? 'Connected' : 'Offline',
                style: TextStyle(
                  fontSize: 15,
                  color: _isOnline ? AppColors.success : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _alternativeRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _ssidDisplay,
              style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
            ),
          ),
          if (!_loading && (_ssid?.isNotEmpty ?? false))
            const Icon(Icons.check, color: _orange, size: 22),
        ],
      ),
    );
  }

  // ─── building blocks ─────────────────────────────────────
  Widget _sectionHeader(String text) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
        child: Text(
          text,
          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
      );

  Widget _card({required Widget child}) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: child,
      );

  Widget _kvRow(String label, Widget value) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            value,
          ],
        ),
      );
}
