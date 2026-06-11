import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/pages/add_device_page.dart' show RadarPainter;
import '../../domain/entities/discovered_osprey_device.dart';
import '../bloc/osprey_scan_bloc.dart';
import '../bloc/osprey_scan_event.dart';
import '../bloc/osprey_scan_state.dart';
import 'osprey_pairing_page.dart';
import 'api_debug_page.dart';
import 'osprey_scan_debug_page.dart';

/// Trang "Thêm thiết bị" Osprey — BLE scan filter theo Brand Service UUID,
/// chỉ hiện thiết bị Osprey đang ở pairing mode (spec §8.2).
class OspreyAddDevicePage extends StatelessWidget {
  const OspreyAddDevicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OspreyScanBloc>(),
      child: const _OspreyAddDeviceView(),
    );
  }
}

class _OspreyAddDeviceView extends StatefulWidget {
  const _OspreyAddDeviceView();

  @override
  State<_OspreyAddDeviceView> createState() => _OspreyAddDeviceViewState();
}

class _OspreyAddDeviceViewState extends State<_OspreyAddDeviceView>
    with TickerProviderStateMixin {
  late final AnimationController _radarController;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) => _requestAndScan());
  }

  @override
  void dispose() {
    _radarController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _requestAndScan() async {
    // iOS: chỉ cần quyền Bluetooth (BLE scan không yêu cầu Location).
    // Android 12+: cần BLUETOOTH_SCAN + BLUETOOTH_CONNECT + Location.
    final permissions = Platform.isIOS
        ? [Permission.bluetooth]
        : [
            Permission.bluetoothScan,
            Permission.bluetoothConnect,
            Permission.location,
          ];
    final statuses = await permissions.request();
    if (!mounted) return;

    final granted = statuses.values
        .every((s) => s.isGranted || s.isLimited || s.isProvisional);
    if (!granted) {
      final permanentlyDenied =
          statuses.values.any((s) => s.isPermanentlyDenied);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Platform.isIOS
              ? 'Bluetooth permission is required to find devices'
              : 'Bluetooth and Location permissions are required to find devices'),
          backgroundColor: AppColors.error,
          action: permanentlyDenied
              ? SnackBarAction(
                  label: 'Open Settings',
                  textColor: Colors.white,
                  onPressed: openAppSettings,
                )
              : null,
        ),
      );
      return;
    }
    context.read<OspreyScanBloc>().add(const StartOspreyScanEvent());
  }

  void _openPairing(DiscoveredOspreyDevice device) {
    context.read<OspreyScanBloc>().add(const StopOspreyScanEvent());
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OspreyPairingPage(device: device)),
    ).then((_) {
      if (mounted) {
        context.read<OspreyScanBloc>().add(const StartOspreyScanEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              size: 20, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Add device',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          // Debug: gọi API thủ công (xem request/response thật)
          IconButton(
            tooltip: 'Debug API',
            icon: const Icon(Icons.api_outlined, color: AppColors.textMuted),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ApiDebugPage()),
            ),
          ),
          // Debug: quét KHÔNG lọc để so sánh với nRF Connect
          IconButton(
            tooltip: 'BLE scan debug',
            icon: const Icon(Icons.bug_report_outlined,
                color: AppColors.textMuted),
            onPressed: () {
              final bloc = context.read<OspreyScanBloc>();
              bloc.add(const StopOspreyScanEvent());
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const OspreyScanDebugPage()),
              ).then((_) {
                if (mounted) bloc.add(const StartOspreyScanEvent());
              });
            },
          ),
        ],
      ),
      body: BlocBuilder<OspreyScanBloc, OspreyScanState>(
        builder: (context, state) {
          final devices = switch (state) {
            OspreyScanning(:final devices) => devices,
            OspreyScanStopped(:final devices) => devices,
            _ => const <DiscoveredOspreyDevice>[],
          };
          final isScanning =
              state is OspreyScanning || state is OspreyScanStarting;

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(isScanning, state),
                _buildRadar(devices.length),
                if (devices.isNotEmpty) _buildDeviceList(devices),
                if (!isScanning)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 14),
                      ),
                      onPressed: _requestAndScan,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Rescan'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isScanning, OspreyScanState state) {
    final String text;
    if (state is OspreyScanError) {
      text = state.message;
    } else if (isScanning) {
      text = 'Searching for nearby Osprey devices. Make sure the device '
          'is in pairing mode (hold the reset button for 5 seconds).';
    } else {
      text = 'Scanning stopped.';
    }

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          if (isScanning)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          else
            Icon(
              state is OspreyScanError
                  ? Icons.error_outline
                  : Icons.bluetooth_searching,
              color:
                  state is OspreyScanError ? AppColors.error : AppColors.primary,
              size: 22,
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadar(int foundCount) {
    return Container(
      color: AppColors.surface,
      width: double.infinity,
      padding: const EdgeInsets.only(top: 10, bottom: 30),
      child: Center(
        child: SizedBox(
          width: 220,
          height: 220,
          child: AnimatedBuilder(
            animation: Listenable.merge([_radarController, _pulseController]),
            builder: (context, child) {
              return CustomPaint(
                painter: RadarPainter(
                  sweepAngle: _radarController.value * 2 * pi,
                  pulseValue: _pulseController.value,
                  foundDevices: foundCount,
                ),
                size: const Size(220, 220),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceList(List<DiscoveredOspreyDevice> devices) {
    return Container(
      color: AppColors.surface,
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'Devices found (${devices.length})',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          ...devices.map((d) => _DeviceTile(
                device: d,
                onTap: () => _openPairing(d),
              )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  final DiscoveredOspreyDevice device;
  final VoidCallback onTap;

  const _DeviceTile({required this.device, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final strongSignal = device.rssi > -70;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primarySubtle,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.curtains_outlined,
            size: 24, color: AppColors.primary),
      ),
      title: Text(
        device.displayName,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Row(
        children: [
          // MAC suffix giúp user phân biệt device của mình với hàng xóm
          Text(
            device.macSuffix,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(width: 10),
          Icon(
            Icons.signal_cellular_alt,
            size: 14,
            color: strongSignal ? AppColors.success : AppColors.warning,
          ),
          const SizedBox(width: 4),
          Text(
            '${device.rssi} dBm',
            style: TextStyle(
              fontSize: 12,
              color: strongSignal ? AppColors.success : AppColors.warning,
            ),
          ),
        ],
      ),
      trailing:
          const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 22),
      onTap: onTap,
    );
  }
}
