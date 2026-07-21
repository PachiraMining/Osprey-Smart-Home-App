import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/bloc/home_management_bloc.dart';
import '../../../home/presentation/bloc/home_management_event.dart';
import '../../domain/entities/discovered_osprey_device.dart';
import '../bloc/osprey_scan_bloc.dart';
import '../bloc/osprey_scan_event.dart';
import '../bloc/osprey_scan_state.dart';
import 'osprey_pairing_page.dart';

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

class _OspreyAddDeviceViewState extends State<_OspreyAddDeviceView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _requestAndScan());
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
    ).then((paired) {
      if (!mounted) return;
      // Pairing succeeded → refresh the home's devices right away so the new
      // device is already in the list when the user lands back on Home.
      if (paired == true) {
        final hm = context.read<HomeManagementBloc>();
        final homeId = hm.state.selectedHomeId;
        if (homeId != null) {
          hm.add(LoadHomeDevicesEvent(homeId));
          hm.add(LoadRoomsEvent(homeId));
        }
      }
      context.read<OspreyScanBloc>().add(const StartOspreyScanEvent());
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
                _buildRadar(devices),
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
          'is in pairing mode.';
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
                fontSize: 12,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Scan area (Tuya-style): a small radar sweep while nothing is found;
  /// once devices appear the radar gives way to a grid of product avatars
  /// that fade in — tap one to pair.
  Widget _buildRadar(List<DiscoveredOspreyDevice> devices) {
    return Container(
      color: AppColors.surface,
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 230),
      padding: const EdgeInsets.only(top: 10, bottom: 18),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: devices.isEmpty
            ? Center(
                key: const ValueKey('radar'),
                child: Lottie.asset(
                  'assets/lottie/blue_radar.lottie',
                  width: 190,
                  height: 190,
                  fit: BoxFit.contain,
                  repeat: true,
                  decoder: _dotLottieDecoder,
                ),
              )
            : Align(
                key: const ValueKey('found'),
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 8),
                  child: Wrap(
                    spacing: 22,
                    runSpacing: 16,
                    children: [
                      for (final d in devices)
                        _FoundDevice(
                          key: ValueKey(d.remoteId),
                          device: d,
                          onTap: () => _openPairing(d),
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  /// dotLottie (.lottie) = zip: pick the real animation json, NOT
  /// manifest.json (parsing the manifest trips lottie's
  /// startFrame == endFrame assertion). Images resolve from the archive.
  static Future<LottieComposition?> _dotLottieDecoder(List<int> bytes) {
    return LottieComposition.decodeZip(bytes, filePicker: (files) {
      return files.firstWhere(
        (f) => f.name.startsWith('animations/') && f.name.endsWith('.json'),
      );
    });
  }


}

/// Found-device avatar (Tuya style): circular bordered chip with the
/// product artwork and the name below; fades/scales in when it first
/// appears. Tap to start pairing.
class _FoundDevice extends StatelessWidget {
  final DiscoveredOspreyDevice device;
  final VoidCallback onTap;

  const _FoundDevice({super.key, required this.device, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.scale(scale: 0.85 + 0.15 * t, child: child),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 84,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderSubtle, width: 1.5),
                ),
                child: Image.asset(
                  'assets/icons/curtain_track.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                      Icons.curtains_outlined,
                      size: 28,
                      color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                device.displayName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.2,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                device.macSuffix,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
