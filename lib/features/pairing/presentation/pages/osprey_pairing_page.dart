import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_popup.dart';
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
      // Nút Done to, ghim đáy — chỉ hiện khi đã pair xong (giống Tuya).
      bottomNavigationBar: BlocBuilder<PairingBloc, PairingState>(
        builder: (context, state) {
          if (state is! PairingSuccess) return const SizedBox.shrink();
          return SafeArea(
            minimum: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                // Trả true để trang trước refresh danh sách thiết bị.
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Done',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          );
        },
      ),
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
            AppPopup.success(
              context,
              title: 'Pairing successful',
              message: 'Device is ready.',
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

  /// Target fill (0–1) of the progress ring for each pairing step. The ring
  /// grows as the 5 steps advance (Tuya-style) instead of spinning.
  static double _progressFor(PairingStep step) {
    switch (step) {
      case PairingStep.connecting:
        return 0.15;
      case PairingStep.requestingToken:
        return 0.35;
      case PairingStep.authenticating:
        return 0.55;
      case PairingStep.sendingWifiCredentials:
        return 0.72;
      case PairingStep.waitingForDevice:
        return 0.97; // creeps up slowly during the long device-online wait
      default:
        return 0.1;
    }
  }

  /// Tuya-style result screen (single device). The 5-step pairing logic is
  /// unchanged underneath — it just drives the DETERMINATE progress ring
  /// (fills as steps advance) instead of an indeterminate spinner.
  Widget _buildProgress(PairingStep currentStep) {
    final target = _progressFor(currentStep);
    // The "waiting for device" step can take up to ~90s → animate the ring
    // slowly toward its target so it keeps visibly filling; other steps snap.
    final duration = currentStep == PairingStep.waitingForDevice
        ? const Duration(seconds: 60)
        : const Duration(milliseconds: 500);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text(
          '1 device(s) being added',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        _resultCard(
          done: false,
          status: 'Being added',
          trailing: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: target),
            duration: duration,
            curve: Curves.easeOut,
            builder: (context, value, _) => SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: 3,
                backgroundColor: AppColors.borderSubtle,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Result cell shared by both states: product thumbnail (+ green check badge
  /// when done), device name, status line, and an optional trailing widget.
  Widget _resultCard({
    required bool done,
    required String status,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Image.asset(
                      'assets/icons/curtain_track.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.curtains_outlined,
                        size: 30,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                if (done)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.check_circle,
                          size: 22, color: AppColors.success),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.device.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  status,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing,
          ],
        ],
      ),
    );
  }

  // ─── Success / failure ─────────────────────────────────────
  Widget _buildSuccess() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text(
          '1 device(s) added successfully',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        _resultCard(done: true, status: 'Added successfully'),
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
