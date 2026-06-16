import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/datasources/device_wifi_remote_datasource.dart';

/// Form "Add WiFi network" (Màn 2) — chỉ lưu vào backend, KHÔNG chạm chip.
/// Pop với `true` khi thêm thành công để màn list refresh.
class AddWifiNetworkPage extends StatefulWidget {
  final String deviceId;
  const AddWifiNetworkPage({super.key, required this.deviceId});

  @override
  State<AddWifiNetworkPage> createState() => _AddWifiNetworkPageState();
}

class _AddWifiNetworkPageState extends State<AddWifiNetworkPage> {
  final _ssidController = TextEditingController();
  final _passwordController = TextEditingController();
  final _labelController = TextEditingController();

  bool _obscure = true;
  bool _saving = false;
  String? _ssidError;
  String? _passwordError;
  String? _serverError;

  @override
  void initState() {
    super.initState();
    _autofillSsid();
  }

  @override
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  /// Gợi ý SSID = WiFi điện thoại đang nối (best-effort; cần quyền vị trí).
  Future<void> _autofillSsid() async {
    try {
      final raw = await NetworkInfo().getWifiName();
      if (!mounted || raw == null || _ssidController.text.isNotEmpty) return;
      // iOS bọc SSID trong dấu nháy kép.
      final ssid = raw.replaceAll('"', '').trim();
      if (ssid.isNotEmpty) _ssidController.text = ssid;
    } catch (_) {
      // Không có quyền / không lấy được → để trống, user tự nhập.
    }
  }

  bool _validate() {
    final ssid = _ssidController.text.trim();
    final password = _passwordController.text;
    setState(() {
      _ssidError = ssid.isEmpty
          ? 'Enter the WiFi name'
          : (ssid.length > 32 ? 'WiFi name must be 1–32 characters' : null);
      _passwordError = password.length < 8
          ? 'Password must be at least 8 characters'
          : (password.length > 63 ? 'Password must be 8–63 characters' : null);
      _serverError = null;
    });
    return _ssidError == null && _passwordError == null;
  }

  Future<void> _save() async {
    if (_saving || !_validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      await sl<DeviceWifiRemoteDataSource>().addWifi(
        widget.deviceId,
        ssid: _ssidController.text,
        password: _passwordController.text,
        label: _labelController.text,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } on DeviceWifiException catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        if (e.code == DeviceWifiErrorCode.alreadySaved) {
          _serverError =
              'This network is already saved. To change its password, delete it and add it again.';
        } else {
          _serverError = e.message;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _serverError = 'Something went wrong. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add WiFi network',
          style: TextStyle(
              fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          _label('WiFi name (SSID)'),
          TextField(
            controller: _ssidController,
            enabled: !_saving,
            textInputAction: TextInputAction.next,
            maxLength: 32,
            decoration: _decoration(
              hint: 'e.g. Home WiFi 2.4G',
              errorText: _ssidError,
              counter: '',
            ),
            onChanged: (_) {
              if (_ssidError != null) setState(() => _ssidError = null);
            },
          ),
          const SizedBox(height: 12),
          _label('Password'),
          TextField(
            controller: _passwordController,
            enabled: !_saving,
            obscureText: _obscure,
            textInputAction: TextInputAction.next,
            maxLength: 63,
            decoration: _decoration(
              hint: 'At least 8 characters',
              errorText: _passwordError,
              counter: '',
              suffix: IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            onChanged: (_) {
              if (_passwordError != null) setState(() => _passwordError = null);
            },
          ),
          const SizedBox(height: 4),
          const Text(
            'Curtain devices only support 2.4GHz WiFi (WPA2).',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          _label('Label (optional)'),
          TextField(
            controller: _labelController,
            enabled: !_saving,
            textInputAction: TextInputAction.done,
            maxLength: 64,
            decoration: _decoration(
              hint: 'e.g. Home, Office, Hotspot',
              counter: '',
            ),
            onSubmitted: (_) => _save(),
          ),
          if (_serverError != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _serverError!,
                style: const TextStyle(fontSize: 13, color: AppColors.error),
              ),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Save',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(left: 2, bottom: 6),
        child: Text(text,
            style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary)),
      );

  InputDecoration _decoration({
    required String hint,
    String? errorText,
    Widget? suffix,
    String? counter,
  }) {
    return InputDecoration(
      hintText: hint,
      errorText: errorText,
      suffixIcon: suffix,
      counterText: counter,
      filled: true,
      fillColor: AppColors.surface,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.6),
      ),
    );
  }
}
