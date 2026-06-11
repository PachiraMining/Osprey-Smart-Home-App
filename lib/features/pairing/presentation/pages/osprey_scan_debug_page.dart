import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/crypto/hex_utils.dart';
import '../../data/datasources/osprey_adv_parser.dart';
import '../../domain/entities/osprey_adv_data.dart';
import '../../pairing_constants.dart';

/// Màn DEBUG quét BLE — **KHÔNG lọc** theo Brand UUID, hiển thị mọi thiết
/// bị đang phát sóng + lý do app nhận/loại từng cái.
///
/// Dùng để so sánh với nRF Connect: nếu nRF thấy 2 mà app chỉ thấy 1,
/// màn này sẽ chỉ ra thiết bị thứ 2 bị loại ở đâu (BLE filter, thiếu
/// manufacturer 0xFFFF, hay đã paired).
class OspreyScanDebugPage extends StatefulWidget {
  const OspreyScanDebugPage({super.key});

  @override
  State<OspreyScanDebugPage> createState() => _OspreyScanDebugPageState();
}

/// Phân loại 1 thiết bị theo logic filter thật của app.
enum _Verdict {
  wouldShow, // Hiện trong "Add Device"
  hiddenPaired, // App ẩn: đã paired
  hiddenNoMfg, // App ẩn: thiếu manufacturer 0xFFFF
  hiddenShortMfg, // App ẩn: manufacturer < 6 bytes
  hiddenNoBrandUuid, // BLE filter ẩn: không quảng bá Brand UUID
  notOsprey, // Không phải Osprey (tham khảo)
}

class _SeenDevice {
  final ScanResult result;
  final bool advertisesBrandUuid;
  final OspreyAdvData? advData;
  final _Verdict verdict;

  _SeenDevice({
    required this.result,
    required this.advertisesBrandUuid,
    required this.advData,
    required this.verdict,
  });
}

class _OspreyScanDebugPageState extends State<OspreyScanDebugPage> {
  final Map<String, _SeenDevice> _seen = {};
  StreamSubscription<List<ScanResult>>? _sub;
  bool _ospreyOnly = false;
  String _status = 'Chuẩn bị quét...';

  static final Guid _brandGuid = Guid(PairingConstants.brandServiceUuid);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void dispose() {
    _sub?.cancel();
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  Future<void> _start() async {
    final permissions = Platform.isIOS
        ? [Permission.bluetooth]
        : [
            Permission.bluetoothScan,
            Permission.bluetoothConnect,
            Permission.location,
          ];
    final statuses = await permissions.request();
    final granted = statuses.values
        .every((s) => s.isGranted || s.isLimited || s.isProvisional);
    if (!granted) {
      setState(() => _status = 'Thiếu quyền Bluetooth/Vị trí');
      return;
    }

    _seen.clear();
    setState(() => _status = 'Đang quét (không lọc)...');
    _sub?.cancel();
    _sub = FlutterBluePlus.scanResults.listen(_onResults);

    try {
      if (FlutterBluePlus.isScanningNow) {
        await FlutterBluePlus.stopScan();
      }
      // KHÔNG truyền withServices → thấy MỌI thiết bị (như nRF Connect)
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 30),
        androidUsesFineLocation: true,
        androidScanMode: AndroidScanMode.lowLatency,
      );
    } catch (e) {
      setState(() => _status = 'Lỗi quét: $e');
    }
  }

  void _onResults(List<ScanResult> results) {
    for (final r in results) {
      final adv = r.advertisementData;
      final advertisesBrand = adv.serviceUuids
          .any((g) => g.str.toLowerCase() == _brandGuid.str.toLowerCase());
      final raw =
          adv.manufacturerData[PairingConstants.manufacturerCompanyId];
      final advData = raw != null ? OspreyAdvParser.parse(raw) : null;

      final verdict = _classify(
        advertisesBrand: advertisesBrand,
        raw: raw,
        advData: advData,
      );

      final entry = _SeenDevice(
        result: r,
        advertisesBrandUuid: advertisesBrand,
        advData: advData,
        verdict: verdict,
      );
      final id = r.device.remoteId.str;
      // Log mỗi khi verdict/RSSI đổi để không spam
      final prev = _seen[id];
      if (prev == null || prev.verdict != verdict) {
        dev.log(_oneLine(entry), name: 'BLE-DEBUG');
      }
      _seen[id] = entry;
    }
    if (mounted) setState(() {});
  }

  _Verdict _classify({
    required bool advertisesBrand,
    required List<int>? raw,
    required OspreyAdvData? advData,
  }) {
    // Thứ tự đúng theo filter thật:
    // 1. BLE-level withServices → cần quảng bá Brand UUID
    if (!advertisesBrand) {
      // Có thể vẫn là Osprey nếu có 0xFFFF nhưng UUID nằm ở scan response
      return raw != null ? _Verdict.hiddenNoBrandUuid : _Verdict.notOsprey;
    }
    // 2. App-level: cần manufacturer 0xFFFF
    if (raw == null) return _Verdict.hiddenNoMfg;
    if (advData == null) return _Verdict.hiddenShortMfg;
    // 3. App-level: ẩn nếu đã paired
    if (advData.isPaired) return _Verdict.hiddenPaired;
    return _Verdict.wouldShow;
  }

  String _oneLine(_SeenDevice d) {
    final r = d.result;
    final name = _name(r);
    final mfg = r.advertisementData.manufacturerData.entries
        .map((e) =>
            '0x${e.key.toRadixString(16).padLeft(4, '0')}=${HexUtils.encode(e.value)}')
        .join(',');
    return '[${_verdictLabel(d.verdict)}] "$name" id=${r.device.remoteId.str} '
        'rssi=${r.rssi} brandUuid=${d.advertisesBrandUuid} '
        'svcUuids=${r.advertisementData.serviceUuids.map((g) => g.str).toList()} '
        'mfg={$mfg}';
  }

  // ─── UI ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final all = _seen.values.toList()
      ..sort((a, b) => b.result.rssi.compareTo(a.result.rssi));
    final osprey = all
        .where((d) => d.verdict != _Verdict.notOsprey)
        .toList(growable: false);
    final shown = _ospreyOnly ? osprey : all;

    final wouldShow =
        all.where((d) => d.verdict == _Verdict.wouldShow).length;
    final brandCount = all.where((d) => d.advertisesBrandUuid).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Debug quét BLE',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            tooltip: 'Sao chép log',
            icon: const Icon(Icons.copy_all),
            onPressed: () => _copyAll(all),
          ),
          IconButton(
            tooltip: 'Quét lại',
            icon: const Icon(Icons.refresh),
            onPressed: _start,
          ),
        ],
      ),
      body: Column(
        children: [
          _summary(all.length, brandCount, osprey.length, wouldShow),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(_status,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMuted)),
                ),
                const Text('Chỉ Osprey',
                    style: TextStyle(fontSize: 12)),
                Switch(
                  value: _ospreyOnly,
                  onChanged: (v) => setState(() => _ospreyOnly = v),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: shown.isEmpty
                ? const Center(
                    child: Text('Chưa thấy thiết bị nào',
                        style: TextStyle(color: AppColors.textMuted)))
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: shown.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _DeviceDebugCard(device: shown[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _summary(int total, int brand, int osprey, int wouldShow) {
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _stat('Tổng', '$total', AppColors.textPrimary),
          _stat('Quảng bá Brand UUID', '$brand', AppColors.primary),
          _stat('Osprey', '$osprey', AppColors.accent),
          _stat('Sẽ hiện', '$wouldShow', AppColors.success),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text('$label: $value',
          style: TextStyle(
              fontSize: 12, color: color, fontWeight: FontWeight.w600)),
    );
  }

  void _copyAll(List<_SeenDevice> all) {
    final buf = StringBuffer()
      ..writeln('Osprey BLE scan debug — ${all.length} devices')
      ..writeln('Brand UUID: ${PairingConstants.brandServiceUuid}')
      ..writeln('');
    for (final d in all) {
      buf.writeln(_oneLine(d));
    }
    Clipboard.setData(ClipboardData(text: buf.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã sao chép log vào clipboard')),
    );
  }

  static String _name(ScanResult r) {
    final adv = r.advertisementData;
    if (adv.advName.isNotEmpty) return adv.advName;
    if (r.device.platformName.isNotEmpty) return r.device.platformName;
    return '(không tên)';
  }

  String _verdictLabel(_Verdict v) => switch (v) {
        _Verdict.wouldShow => 'SẼ HIỆN',
        _Verdict.hiddenPaired => 'ẨN: đã paired',
        _Verdict.hiddenNoMfg => 'ẨN: thiếu mfg 0xFFFF',
        _Verdict.hiddenShortMfg => 'ẨN: mfg < 6 bytes',
        _Verdict.hiddenNoBrandUuid => 'ẨN: BLE filter (không có Brand UUID)',
        _Verdict.notOsprey => 'không phải Osprey',
      };
}

class _DeviceDebugCard extends StatelessWidget {
  final _SeenDevice device;
  const _DeviceDebugCard({required this.device});

  @override
  Widget build(BuildContext context) {
    final r = device.result;
    final adv = r.advertisementData;
    final (color, label) = _verdictStyle(device.verdict);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _OspreyScanDebugPageState._name(r),
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withAlpha(28),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        color: color,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _kv('ID', r.device.remoteId.str),
          _kv('RSSI', '${r.rssi} dBm   •   connectable: ${adv.connectable}'),
          _kv('Quảng bá Brand UUID', device.advertisesBrandUuid ? 'CÓ' : 'KHÔNG'),
          if (adv.serviceUuids.isNotEmpty)
            _kv('Service UUIDs',
                adv.serviceUuids.map((g) => g.str).join('\n')),
          if (adv.manufacturerData.isNotEmpty)
            _kv(
              'Manufacturer',
              adv.manufacturerData.entries
                  .map((e) =>
                      '0x${e.key.toRadixString(16).padLeft(4, '0')}: ${HexUtils.encode(e.value)}')
                  .join('\n'),
            ),
          if (device.advData != null) _ospreyDetail(device.advData!),
        ],
      ),
    );
  }

  Widget _ospreyDetail(OspreyAdvData d) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primarySubtle,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _kv('  paired', '${d.isPaired}'),
            _kv('  encrypted', '${d.isEncrypted}'),
            _kv('  protocol v', '${d.protocolVersion}'),
            _kv('  productType', '0x${d.productType.toRadixString(16)}'),
            _kv('  productHash', d.productIdHashHex),
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(k,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textMuted)),
          ),
          Expanded(
            child: SelectableText(v,
                style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  (Color, String) _verdictStyle(_Verdict v) => switch (v) {
        _Verdict.wouldShow => (AppColors.success, 'SẼ HIỆN'),
        _Verdict.hiddenPaired => (AppColors.warning, 'ẨN: đã paired'),
        _Verdict.hiddenNoMfg => (AppColors.error, 'ẨN: thiếu 0xFFFF'),
        _Verdict.hiddenShortMfg => (AppColors.error, 'ẨN: mfg ngắn'),
        _Verdict.hiddenNoBrandUuid =>
          (AppColors.error, 'ẨN: BLE filter'),
        _Verdict.notOsprey => (AppColors.textMuted, 'khác'),
      };
}
