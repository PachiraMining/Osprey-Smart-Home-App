import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../data/device_info_service.dart';
import '../../domain/entities/device_entity.dart';
import 'device_network_page.dart';

/// Tóm tắt mạng của thiết bị: mạng đang nối + cường độ sóng, và lối vào danh
/// sách mạng dự phòng (trang [DeviceNetworkPage] sẵn có).
class DeviceNetworkInfoPage extends StatefulWidget {
  final DeviceEntity device;

  const DeviceNetworkInfoPage({super.key, required this.device});

  @override
  State<DeviceNetworkInfoPage> createState() => _DeviceNetworkInfoPageState();
}

class _DeviceNetworkInfoPageState extends State<DeviceNetworkInfoPage> {
  static const _pageBg = Color(0xFFF2F4F7);

  DeviceTechInfo? _info;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final info =
        await GetIt.instance<DeviceInfoService>().fetch(widget.device.id);
    if (!mounted) return;
    setState(() {
      _info = info;
      _loading = false;
    });
  }

  Future<void> _openNetworks() async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => DeviceNetworkPage(device: widget.device),
      ),
    );
    // Đổi mạng xong thì SSID/sóng có thể khác.
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final info = _info;
    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(
        backgroundColor: _pageBg,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Device Network Information',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.zero,
              children: [
                Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      _Row(
                        label: 'Device Network',
                        value: info?.currentSsid ?? 'Unknown',
                        onTap: _openNetworks,
                      ),
                      _Row(
                        label: 'Signal strength',
                        // Firmware chưa báo RSSI → nói thẳng, không hiện số giả.
                        value: info?.rssiDbm == null
                            ? 'Not reported'
                            : '${info!.rssiDbm}dbm',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  color: Colors.white,
                  child: _Row(
                    label: 'Alternate Network',
                    onTap: _openNetworks,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Text(
                    'If the current network is unavailable, the device will be '
                    'automatically connected to an alternate network.',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback? onTap;

  const _Row({required this.label, this.value, this.onTap});

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
            if (value != null)
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    value!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontSize: 16, color: Colors.grey.shade500),
                  ),
                ),
              ),
            if (onTap != null) ...[
              const SizedBox(width: 6),
              Icon(Icons.chevron_right, size: 22, color: Colors.grey.shade400),
            ],
          ],
        ),
      ),
    );
  }
}
