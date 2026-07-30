import 'package:flutter/material.dart';
import '../../../../l10n/gen/app_l10n.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/widgets/app_popup.dart';
import '../../domain/usecases/get_device_status.dart';
import '../../domain/usecases/send_dp_command.dart';
import 'device_schedule_page.dart';

/// Màn "Setting" mở từ liên kết `more` ở trang điều khiển rèm.
class CurtainMoreSettingsPage extends StatefulWidget {
  final String deviceId;
  final String deviceName;

  const CurtainMoreSettingsPage({
    super.key,
    required this.deviceId,
    required this.deviceName,
  });

  @override
  State<CurtainMoreSettingsPage> createState() =>
      _CurtainMoreSettingsPageState();
}

class _CurtainMoreSettingsPageState extends State<CurtainMoreSettingsPage> {
  static const _pageBg = Color(0xFFF5F6F7);

  /// dpId 5 — `forward` / `back`.
  static const _motorDpId = 5;
  /// Giá trị gửi lên server là `forward`/`back`; nhãn thì dịch theo ngôn ngữ.
  List<(String, String)> _motorOptions(AppL10n l10n) =>
      [('forward', l10n.forward), ('back', l10n.back)];

  String? _motorDirection;
  bool _loading = true;

  /// Đang gửi lệnh đổi chiều — chặn bấm trùng, vì mỗi lần bấm là một lệnh
  /// THẬT xuống rèm (trước đây user bấm 3–4 lần trong lúc chờ ⇒ 3–4 lệnh).
  bool _sendingMotor = false;

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

  /// Rỗng khi CHƯA đọc được trạng thái — thà để trống hơn là hiện "Forward"
  /// đoán bừa rồi nói sai với người dùng.
  String get _motorLabel {
    for (final (value, label) in _motorOptions(AppL10n.of(context))) {
      if (value == _motorDirection) return label;
    }
    return '';
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
                  AppL10n.of(context).motorDirection,
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
                ),
              ),
              for (final (value, label) in _motorOptions(AppL10n.of(context)))
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

    // Cập nhật lạc quan: lệnh + đọc lại trạng thái mất ~2.5s, nếu chờ mới đổi
    // nhãn thì user tưởng không ăn và bấm lại.
    final previous = _motorDirection;
    setState(() {
      _motorDirection = picked;
      _sendingMotor = true;
    });

    final result = await GetIt.instance<SendDpCommand>()(
      widget.deviceId,
      _motorDpId,
      picked,
    );
    if (!mounted) return;
    setState(() => _sendingMotor = false);
    result.fold(
      (_) {
        // Trả lại giá trị cũ để nhãn không nói sai.
        setState(() => _motorDirection = previous);
        AppPopup.error(
          context,
          title: AppL10n.of(context).failed,
          message: AppL10n.of(context).couldNotChangeTheMotorDirectionPleaseTryAgai,
        );
      },
      // KHÔNG đọc lại trạng thái ở đây: endpoint status có thể còn trả giá trị
      // cũ ngay sau khi ghi, làm nhãn nhảy sang giá trị mới rồi giật về cũ.
      // Response 200 của lệnh đã echo lại `direction` nên coi là xác nhận.
      (_) {},
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
        title:  Text(
          AppL10n.of(context).setting,
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
              label: AppL10n.of(context).motorDirection,
              value: _motorLabel,
              busy: _sendingMotor,
              onTap: (_loading || _sendingMotor) ? null : _pickMotorDirection,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            color: Colors.white,
            child: _SettingRow(
              label: AppL10n.of(context).schedule,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => DeviceSchedulePage(
                    deviceId: widget.deviceId,
                    deviceName: widget.deviceName,
                  ),
                ),
              ),
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

  /// Đang gửi lệnh → hiện vòng xoay thay cho chevron.
  final bool busy;
  final VoidCallback? onTap;

  const _SettingRow({
    required this.label,
    this.value,
    this.busy = false,
    this.onTap,
  });

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
                padding: const EdgeInsetsDirectional.only(end: 6),
                child: Text(
                  value!,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                ),
              ),
            if (busy)
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.grey.shade500,
                ),
              )
            else
              Icon(Icons.chevron_right, size: 22, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }
}
