import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/widgets/app_popup.dart';
import '../../domain/usecases/get_device_status.dart';
import '../../domain/usecases/send_dp_command.dart';

/// Màn "Setting" mở từ liên kết `more` ở trang điều khiển rèm.
class CurtainMoreSettingsPage extends StatefulWidget {
  final String deviceId;

  const CurtainMoreSettingsPage({super.key, required this.deviceId});

  @override
  State<CurtainMoreSettingsPage> createState() =>
      _CurtainMoreSettingsPageState();
}

class _CurtainMoreSettingsPageState extends State<CurtainMoreSettingsPage> {
  static const _pageBg = Color(0xFFF5F6F7);

  /// dpId 5 — `forward` / `back`.
  static const _motorDpId = 5;
  static const _motorOptions = [('forward', 'Forward'), ('back', 'Back')];

  String? _motorDirection;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  Future<void> _fetchStatus() async {
    final result = await GetIt.instance<GetDeviceStatus>()(widget.deviceId);
    if (!mounted) return;
    setState(() {
      result.fold(
        (_) {},
        // Thiết bị chưa từng đặt chiều quay → mặc định `forward` như firmware.
        (status) => _motorDirection =
            status['control_back'] as String? ?? 'forward',
      );
      _loading = false;
    });
  }

  String get _motorLabel {
    for (final (value, label) in _motorOptions) {
      if (value == _motorDirection) return label;
    }
    return _loading ? '' : 'Forward';
  }

  Future<void> _pickMotorDirection() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 10,
          right: 10,
          bottom: 10 + MediaQuery.of(ctx).padding.bottom,
        ),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Motor Direction',
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
                ),
              ),
              for (final (value, label) in _motorOptions)
                InkWell(
                  onTap: () => Navigator.pop(ctx, value),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(label,
                              style: const TextStyle(fontSize: 16)),
                        ),
                        if (value == _motorDirection)
                          const Icon(Icons.check,
                              color: Color(0xFF1B4332), size: 22),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );

    if (picked == null || picked == _motorDirection || !mounted) return;

    final result = await GetIt.instance<SendDpCommand>()(
      widget.deviceId,
      _motorDpId,
      picked,
    );
    if (!mounted) return;
    result.fold(
      (_) => AppPopup.error(
        context,
        title: 'Failed',
        message: 'Could not change the motor direction. Please try again.',
      ),
      // Đọc lại từ thiết bị thay vì tin giá trị vừa gửi — lệnh có thể bị
      // firmware từ chối trong khi rèm đang chạy.
      (_) => _fetchStatus(),
    );
  }

  void _notYet(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature is coming soon.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black87,
        title: const Text(
          'Setting',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 10),
          Container(
            color: Colors.white,
            child: _SettingRow(
              label: 'Motor Direction',
              value: _motorLabel,
              onTap: _loading ? null : _pickMotorDirection,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            color: Colors.white,
            child: _SettingRow(
              label: 'Schedule',
              onTap: () => _notYet('Schedule'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback? onTap;

  const _SettingRow({required this.label, this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 17, color: Colors.black87),
              ),
            ),
            if (value != null && value!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  value!,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                ),
              ),
            Icon(Icons.chevron_right, size: 22, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }
}
