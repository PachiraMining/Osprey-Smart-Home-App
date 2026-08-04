import 'package:flutter/material.dart';
import '../../../../l10n/gen/app_l10n.dart';
import 'package:get_it/get_it.dart';

import '../../data/device_info_service.dart';
import '../../../../core/theme/app_surfaces.dart';

/// Trạng thái firmware của thiết bị.
///
/// Backend chỉ có MỘT phiên bản firmware (`fw_version`) và cờ `updateAvailable`;
/// không có phiên bản MCU riêng, cũng không có tuỳ chọn tự động cập nhật — nên
/// hai mục đó không hiển thị thay vì bịa ra.
class DeviceUpdatePage extends StatefulWidget {
  final String deviceId;

  const DeviceUpdatePage({super.key, required this.deviceId});

  @override
  State<DeviceUpdatePage> createState() => _DeviceUpdatePageState();
}

class _DeviceUpdatePageState extends State<DeviceUpdatePage> {
  static const _green = Color(0xFF2ECC71);

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

  @override
  Widget build(BuildContext context) {
    final info = _info;
    final hasUpdate = info?.updateAvailable ?? false;

    return Scaffold(
      backgroundColor: context.surfaces.pageBg,
      appBar: AppBar(
        backgroundColor: context.surfaces.pageBg,
        elevation: 0,
        centerTitle: true,
        foregroundColor: context.surfaces.textPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title:  Text(
          AppL10n.of(context).deviceUpdate,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: context.surfaces.card,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 44),
                  child: Column(
                    children: [
                      Container(
                        width: 86,
                        height: 86,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: hasUpdate
                              ? const Color(0xFF2D7DD2)
                              : _green,
                        ),
                        child: Icon(
                          hasUpdate
                              ? Icons.arrow_downward_rounded
                              : Icons.check,
                          size: 46,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        hasUpdate
                            ? AppL10n.of(context).updateAvailable
                            : AppL10n.of(context).noUpdatesAvailable,
                        style:  TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: context.surfaces.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppL10n.of(context).mainModuleVersion(
                            info?.firmwareVersion ?? AppL10n.of(context).unknown),
                        style: TextStyle(
                          fontSize: 16,
                          color: context.surfaces.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasUpdate) ...[
                  const SizedBox(height: 16),
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
                      // Việc xác nhận cập nhật do backend/firmware lo qua
                      // endpoint riêng — chưa nối vào đây.
                      onPressed: () => ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(SnackBar(
                          content: Text(AppL10n.of(context).firmwareUpdateIsComingSoon),
                        )),
                      child:  Text(
                        AppL10n.of(context).updateNow,
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
