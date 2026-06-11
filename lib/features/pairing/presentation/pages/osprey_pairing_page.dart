import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../device/data/device_network_store.dart';
import '../../domain/entities/discovered_osprey_device.dart';
import '../../domain/entities/pairing_progress.dart';
import '../bloc/pairing_bloc.dart';
import '../bloc/pairing_event.dart';
import '../bloc/pairing_state.dart';

/// Nhập WiFi credentials + theo dõi tiến trình ghép nối (spec §8.3).
class OspreyPairingPage extends StatelessWidget {
  final DiscoveredOspreyDevice device;

  const OspreyPairingPage({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PairingBloc>(),
      child: _OspreyPairingView(device: device),
    );
  }
}

class _OspreyPairingView extends StatefulWidget {
  final DiscoveredOspreyDevice device;

  const _OspreyPairingView({required this.device});

  @override
  State<_OspreyPairingView> createState() => _OspreyPairingViewState();
}

class _OspreyPairingViewState extends State<_OspreyPairingView> {
  final _formKey = GlobalKey<FormState>();
  final _ssidController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  /// SSID detect được từ WiFi điện thoại đang kết nối (null = chưa/không
  /// detect được → cho nhập tay).
  String? _detectedSsid;
  bool _detectingWifi = true;

  @override
  void initState() {
    super.initState();
    _detectCurrentWifi();
  }

  @override
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Tự đọc SSID WiFi điện thoại đang kết nối (pattern Tuya/Mi Home).
  ///
  /// iOS 13+ và Android đều yêu cầu quyền Location mới đọc được SSID;
  /// iOS thêm entitlement "Access WiFi Information" (Runner.entitlements).
  Future<void> _detectCurrentWifi() async {
    setState(() => _detectingWifi = true);
    try {
      // Quyền location bắt buộc để đọc SSID trên cả 2 platform
      final status = await Permission.locationWhenInUse.request();
      String? ssid;
      if (status.isGranted || status.isLimited) {
        ssid = await NetworkInfo().getWifiName();
      }
      // Android trả SSID kèm dấu nháy ("MyWiFi") — strip đi
      ssid = ssid?.replaceAll('"', '').trim();
      if (ssid != null && (ssid.isEmpty || ssid == '<unknown ssid>')) {
        ssid = null;
      }
      if (!mounted) return;
      setState(() {
        _detectedSsid = ssid;
        _detectingWifi = false;
        if (ssid != null) _ssidController.text = ssid;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _detectingWifi = false);
    }
  }

  /// Heuristic cảnh báo mạng 5GHz (thiết bị chỉ hỗ trợ 2.4GHz).
  bool get _looksLike5Ghz {
    final ssid = _ssidController.text.toUpperCase();
    return ssid.contains('5G') && !ssid.contains('2.4');
  }

  void _startPairing() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    context.read<PairingBloc>().add(StartPairingEvent(
          device: widget.device,
          ssid: _ssidController.text.trim(),
          wifiPassword: _passwordController.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: BlocBuilder<PairingBloc, PairingState>(
          builder: (context, state) => IconButton(
            icon: const Icon(Icons.arrow_back_ios,
                size: 20, color: AppColors.textPrimary),
            // Không cho back giữa chừng khi đang pair
            onPressed:
                state is PairingInProgress ? null : () => Navigator.pop(context),
          ),
        ),
        centerTitle: true,
        title: Text(
          widget.device.displayName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: BlocConsumer<PairingBloc, PairingState>(
        listener: (context, state) {
          if (state is PairingSuccess) {
            // Lưu SSID đã provision để màn Device Network hiển thị lại sau
            // (firmware không báo SSID lên backend — đây là nguồn thật duy nhất).
            sl<DeviceNetworkStore>()
                .saveSsid(state.deviceId, _ssidController.text.trim());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pairing successful! Device is ready.'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state is PairingInitial) _buildWifiForm(),
                if (state is PairingInProgress) _buildProgress(state.step),
                if (state is PairingSuccess) _buildSuccess(),
                if (state is PairingFailure) _buildFailure(state),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── WiFi form ─────────────────────────────────────────────
  Widget _buildWifiForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.wifi, color: AppColors.primary),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'The device will connect to the WiFi your phone is using. '
                    'Only 2.4GHz networks are supported.',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSsidField(),
          if (_looksLike5Ghz) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    size: 16, color: AppColors.warning),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'This network looks like 5GHz — switch your phone to a '
                    '2.4GHz network, then tap refresh.',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.warning.withAlpha(230)),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'WiFi password',
              prefixIcon: const Icon(Icons.lock_outline),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword
                    ? Icons.visibility_off
                    : Icons.visibility),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Enter the WiFi password' : null,
          ),
          const SizedBox(height: 28),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: _startPairing,
            child: const Text('Start pairing',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  /// SSID field: tự detect từ WiFi đang kết nối; chỉ cho sửa tay khi
  /// không detect được (quyền location bị từ chối, WiFi tắt...).
  Widget _buildSsidField() {
    if (_detectingWifi) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 14),
            Text(
              'Detecting current WiFi...',
              style: TextStyle(fontSize: 15, color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    final detected = _detectedSsid != null;
    return TextFormField(
      controller: _ssidController,
      // Detect được → readonly (đúng mạng điện thoại đang dùng);
      // không detect được → fallback cho nhập tay
      readOnly: detected,
      decoration: InputDecoration(
        labelText: 'WiFi name (SSID)',
        helperText: detected
            ? 'Auto-detected from the WiFi your phone is connected to'
            : 'Could not detect WiFi — enter the network name manually',
        prefixIcon: Icon(
          detected ? Icons.wifi : Icons.router_outlined,
          color: detected ? AppColors.success : null,
        ),
        suffixIcon: IconButton(
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh),
          onPressed: _detectCurrentWifi,
        ),
        border: const OutlineInputBorder(),
      ),
      onChanged: (_) => setState(() {}), // refresh cảnh báo 5GHz
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Enter the WiFi name' : null,
    );
  }

  // ─── Progress stepper ──────────────────────────────────────
  // Option 2: connect + đọc DEVICE_UUID trước (disarm watchdog), backend sau
  static const _steps = [
    (PairingStep.connecting, 'Connecting via Bluetooth'),
    (PairingStep.requestingToken, 'Registering with server'),
    (PairingStep.authenticating, 'Authenticating device'),
    (PairingStep.sendingWifiCredentials, 'Sending WiFi credentials'),
    (PairingStep.waitingForDevice, 'Waiting for device to come online'),
  ];

  Widget _buildProgress(PairingStep currentStep) {
    final currentIndex =
        _steps.indexWhere((s) => s.$1 == currentStep).clamp(0, _steps.length);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        ..._steps.asMap().entries.map((entry) {
          final i = entry.key;
          final (_, label) = entry.value;
          final isDone = i < currentIndex;
          final isCurrent = i == currentIndex;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                if (isDone)
                  const Icon(Icons.check_circle,
                      color: AppColors.success, size: 26)
                else if (isCurrent)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                else
                  const Icon(Icons.radio_button_unchecked,
                      color: AppColors.textDisabled, size: 26),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                        isCurrent ? FontWeight.w600 : FontWeight.w400,
                    color: isCurrent || isDone
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 20),
        if (currentStep == PairingStep.waitingForDevice)
          const Text(
            'The device is restarting and connecting to WiFi — '
            'this can take up to 90 seconds.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
      ],
    );
  }

  // ─── Success / failure ─────────────────────────────────────
  Widget _buildSuccess() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          width: 96,
          height: 96,
          decoration: const BoxDecoration(
            color: AppColors.primarySubtle,
            shape: BoxShape.circle,
          ),
          child:
              const Icon(Icons.check_rounded, size: 56, color: AppColors.success),
        ),
        const SizedBox(height: 24),
        const Text(
          'Pairing successful!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${widget.device.displayName} has been added to your home.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 32),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
          ),
          // Trả true để trang trước refresh danh sách thiết bị
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Done'),
        ),
      ],
    );
  }

  Widget _buildFailure(PairingFailure state) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: AppColors.error.withAlpha(24),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.close_rounded,
              size: 56, color: AppColors.error),
        ),
        const SizedBox(height: 24),
        const Text(
          'Pairing failed',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          state.message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 32),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
          ),
          onPressed: () =>
              context.read<PairingBloc>().add(const ResetPairingEvent()),
          child: const Text('Retry'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Go back',
              style: TextStyle(color: AppColors.textMuted)),
        ),
      ],
    );
  }
}
