import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:network_info_plus/network_info_plus.dart';

import '../../../../core/config/app_config.dart';
import '../../../../l10n/gen/app_l10n.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../control/domain/entities/transport_state.dart';
import '../../../control/domain/repositories/transport_router.dart';

enum _CheckState { running, pass, warn, fail }

class _CheckResult {
  final String label;
  final _CheckState state;
  final String detail;

  const _CheckResult(this.label, this.state, this.detail);
}

/// Chẩn đoán kết nối: Wi-Fi → DNS → server → xác thực → kênh điều khiển.
///
/// Chạy hoàn toàn phía client, không cần endpoint riêng của backend.
class NetworkDiagnosisPage extends StatefulWidget {
  const NetworkDiagnosisPage({super.key});

  @override
  State<NetworkDiagnosisPage> createState() => _NetworkDiagnosisPageState();
}

class _NetworkDiagnosisPageState extends State<NetworkDiagnosisPage> {
  static const _pageBg = Color(0xFFF2F4F7);

  final List<_CheckResult> _results = [];
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _run();
  }

  void _push(_CheckResult r) {
    if (mounted) setState(() => _results.add(r));
  }

  Future<void> _run() async {
    if (_running) return;
    final l10n = AppL10n.of(context);
    setState(() {
      _running = true;
      _results.clear();
    });

    final host = Uri.parse(AppConfig.thingsboardBaseUrl).host;

    // 1. Mạng cục bộ
    try {
      final ssid = await NetworkInfo().getWifiName();
      final clean = (ssid ?? '').replaceAll('"', '');
      _push(clean.isEmpty
          ? _CheckResult(l10n.diagLocalNetwork, _CheckState.warn,
              l10n.diagLocalNetworkNoWifi)
          : _CheckResult(l10n.diagLocalNetwork, _CheckState.pass, clean));
    } catch (e) {
      _push(_CheckResult(l10n.diagLocalNetwork, _CheckState.warn,
          l10n.diagLocalNetworkUnreadable));
    }

    // 2. Phân giải tên miền
    try {
      final addresses = await InternetAddress.lookup(host);
      _push(_CheckResult(l10n.diagDnsLookup, _CheckState.pass,
          addresses.map((a) => a.address).join(', ')));
    } catch (e) {
      _push(_CheckResult(
          l10n.diagDnsLookup, _CheckState.fail, l10n.diagDnsFailed(host)));
      _finish();
      return;
    }

    // 3. Tới được server (endpoint không cần token)
    final sw = Stopwatch()..start();
    try {
      final res = await http
          .get(Uri.parse('${AppConfig.thingsboardBaseUrl}/api/noauth/mobile'))
          .timeout(const Duration(seconds: 8));
      sw.stop();
      // Bất kỳ phản hồi HTTP nào cũng chứng minh đã tới được server.
      _push(_CheckResult(
          l10n.diagServerReachable,
          _CheckState.pass,
          l10n.diagServerLatency(
              '${sw.elapsedMilliseconds}', '${res.statusCode}')));
    } catch (e) {
      sw.stop();
      _push(_CheckResult(l10n.diagServerReachable, _CheckState.fail,
          l10n.diagServerNoResponse));
      _finish();
      return;
    }

    // 4. Xác thực — token còn dùng được không
    try {
      final client = GetIt.instance<http.Client>();
      final res = await client
          .get(
            Uri.parse('${AppConfig.thingsboardBaseUrl}${ApiEndpoints.currentUser}'),
            headers: const {'accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 8));
      _push(res.statusCode == 200
          ? _CheckResult(
              l10n.diagSignedIn, _CheckState.pass, l10n.diagSessionValid)
          : _CheckResult(l10n.diagSignedIn, _CheckState.fail,
              l10n.diagSessionInvalid('${res.statusCode}')));
    } catch (e) {
      _push(_CheckResult(
          l10n.diagSignedIn, _CheckState.warn, l10n.diagSessionUnverified));
    }

    // 5. Kênh điều khiển thiết bị (cloud MQTT hay BLE dự phòng)
    try {
      final transport = GetIt.instance<TransportRouter>().currentTransport;
      _push(switch (transport) {
        TransportState.cloud => _CheckResult(l10n.diagControlChannel,
            _CheckState.pass, l10n.diagCloudConnected),
        TransportState.bleFallback => _CheckResult(l10n.diagControlChannel,
            _CheckState.warn, l10n.diagBleFallback),
        TransportState.unreachable => _CheckResult(l10n.diagControlChannel,
            _CheckState.fail, l10n.diagUnreachable),
      });
    } catch (e) {
      _push(_CheckResult(
          l10n.diagControlChannel, _CheckState.warn, l10n.diagStatusUnknown));
    }

    _finish();
  }

  void _finish() {
    if (mounted) setState(() => _running = false);
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text(AppL10n.of(context).networkDiagnosis,
            style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                for (final r in _results) _CheckRow(result: r),
                if (_running)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D7AC4),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              onPressed: _running ? null : _run,
              child: Text(AppL10n.of(context).runAgain,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final _CheckResult result;

  const _CheckRow({required this.result});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (result.state) {
      _CheckState.pass => (Icons.check_circle, const Color(0xFF2ECC71)),
      _CheckState.warn => (Icons.error_outline, const Color(0xFFF5A623)),
      _CheckState.fail => (Icons.cancel, const Color(0xFFFF3B30)),
      _CheckState.running => (Icons.more_horiz, Colors.grey),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(result.label,
                    style: const TextStyle(
                        fontSize: 16, color: Colors.black87)),
                const SizedBox(height: 3),
                Text(
                  result.detail,
                  style:
                      TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
