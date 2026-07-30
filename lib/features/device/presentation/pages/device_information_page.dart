import 'package:flutter/material.dart';
import '../../../../l10n/gen/app_l10n.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../home/presentation/bloc/home_management_bloc.dart';
import '../../data/device_info_service.dart';

/// Thông tin kỹ thuật của thiết bị.
///
/// Chỉ hiện field backend thật sự có. IP và MAC KHÔNG hiển thị vì server không
/// lưu (đã kiểm chứng: `/network-info` không trả IP/MAC, `label` và
/// `additionalInfo` của device đều null).
class DeviceInformationPage extends StatefulWidget {
  final String deviceId;

  const DeviceInformationPage({super.key, required this.deviceId});

  @override
  State<DeviceInformationPage> createState() => _DeviceInformationPageState();
}

class _DeviceInformationPageState extends State<DeviceInformationPage> {
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
        await GetIt.instance<DeviceInfoService>().fetch(widget.deviceId);
    if (!mounted) return;
    setState(() {
      _info = info;
      _loading = false;
    });
  }

  /// Múi giờ dùng cho hẹn giờ là múi giờ của HOME, không phải của thiết bị.
  String get _timeZone {
    final home = context.watch<HomeManagementBloc>().state.selectedHome;
    final tz = home?.timezone;
    return (tz == null || tz.isEmpty) ? AppL10n.of(context).notSet : tz;
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
        title:  Text(
          AppL10n.of(context).deviceInformation,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _InfoRow(
                    label: AppL10n.of(context).virtualId,
                    value: info?.deviceUuid ?? '—',
                    copyable: info?.deviceUuid != null,
                  ),
                  _InfoRow(
                    label: AppL10n.of(context).wiFi,
                    value: info?.currentSsid ?? AppL10n.of(context).unknown,
                  ),
                  _InfoRow(
                    label: AppL10n.of(context).signalStrength,
                    value: info?.rssiDbm == null
                        ? AppL10n.of(context).notReported
                        : '${info!.rssiDbm}dBm',
                  ),
                  _InfoRow(
                    label: AppL10n.of(context).firmware,
                    value: info?.firmwareVersion ?? AppL10n.of(context).unknown,
                  ),
                  _InfoRow(label: AppL10n.of(context).timeZone, value: _timeZone),
                ],
              ),
            ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool copyable;

  const _InfoRow({
    required this.label,
    required this.value,
    this.copyable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding
      (padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ',
              style: const TextStyle(fontSize: 17, color: Colors.black87)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 17, color: Colors.black87),
            ),
          ),
          if (copyable)
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                      SnackBar(content: Text(AppL10n.of(context).copiedToClipboard)));
              },
              child: Padding(
                padding: EdgeInsetsDirectional.only(start: 10),
                child: Text(
                  AppL10n.of(context).copy,
                  style: TextStyle(fontSize: 17, color: Color(0xFF007AFF)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
