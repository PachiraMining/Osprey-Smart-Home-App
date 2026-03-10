// add_device_page.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_curtain_app/features/home/presentation/pages/bluetooth_controller.dart';
import 'package:smart_curtain_app/features/home/presentation/pages/wifi_config_page.dart';
import 'package:smart_curtain_app/features/home/presentation/pages/qr_scanner_page.dart';

class AddDevicePage extends StatefulWidget {
  const AddDevicePage({Key? key}) : super(key: key);

  @override
  State<AddDevicePage> createState() => _AddDevicePageState();
}

class _AddDevicePageState extends State<AddDevicePage>
    with TickerProviderStateMixin {
  late BluetoothController _bluetoothController;
  late AnimationController _radarController;
  late AnimationController _pulseController;
  bool _autoStarted = false;

  @override
  void initState() {
    super.initState();
    _bluetoothController = BluetoothController();
    _bluetoothController.initialize();

    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScanning();
    });
  }

  Future<void> _startScanning() async {
    if (_autoStarted) return;
    _autoStarted = true;

    final success = await _bluetoothController.startScan();
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_bluetoothController.errorMessage ?? 'Lỗi khi quét'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _radarController.dispose();
    _pulseController.dispose();
    _bluetoothController.dispose();
    super.dispose();
  }

  Future<void> _connectAndNavigate(device, String deviceName) async {
    if (_bluetoothController.isConnecting) return;

    try {
      final success = await _bluetoothController.connectToDevice(device);

      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(_bluetoothController.errorMessage ?? 'Lỗi kết nối'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã kết nối với $deviceName'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                WiFiConfigPage(device: device, deviceName: deviceName),
          ),
        ).then((_) {
          setState(() {});
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi kết nối: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _bluetoothController,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: const Text(
            'Add Device',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          actions: [
            Consumer<BluetoothController>(
              builder: (context, controller, child) {
                if (controller.connectedDevice != null) {
                  return IconButton(
                    icon: const Icon(Icons.link_off, color: Colors.red),
                    onPressed: () async {
                      await controller.disconnect();
                    },
                  );
                }
                return IconButton(
                  icon: const Icon(Icons.qr_code_scanner, color: Colors.black87),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const QrScannerPage()),
                    );
                  },
                );
              },
            ),
          ],
        ),
        body: Consumer<BluetoothController>(
          builder: (context, controller, child) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  // Connected banner
                  if (controller.connectedDevice != null)
                    _buildConnectedBanner(controller),

                  // Searching header
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: Row(
                      children: [
                        if (controller.isScanning)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                            ),
                          )
                        else
                          const Icon(Icons.bluetooth_searching, color: Color(0xFF2196F3), size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                height: 1.5,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Searching for nearby devices. Make sure your device has entered ',
                                ),
                                TextSpan(
                                  text: 'pairing mode',
                                  style: const TextStyle(
                                    color: Color(0xFF2196F3),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const TextSpan(text: '.'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Radar animation section
                  Container(
                    color: Colors.white,
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 10, bottom: 30),
                    child: Center(
                      child: SizedBox(
                        width: 240,
                        height: 240,
                        child: AnimatedBuilder(
                          animation: Listenable.merge([_radarController, _pulseController]),
                          builder: (context, child) {
                            return CustomPaint(
                              painter: RadarPainter(
                                sweepAngle: _radarController.value * 2 * pi,
                                pulseValue: _pulseController.value,
                                foundDevices: controller.scanResults.length,
                              ),
                              size: const Size(240, 240),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // Found devices list (if any)
                  if (controller.scanResults.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildFoundDevicesList(controller),
                  ],

                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildConnectedBanner(BluetoothController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200, width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Đã kết nối',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'MAC: ${controller.connectedDevice!.remoteId}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.green),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WiFiConfigPage(
                    device: controller.connectedDevice!,
                    deviceName: 'ESP32',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFoundDevicesList(BluetoothController controller) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'Found Devices (${controller.scanResults.length})',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          ...controller.scanResults.map((result) {
            final device = result.device;
            final deviceName = controller.getDeviceName(result);
            final rssi = result.rssi;
            final isConnected =
                controller.connectedDevice?.remoteId == device.remoteId;
            final isConnecting = controller.isConnecting &&
                controller.connectedDevice?.remoteId == device.remoteId;

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isConnected
                      ? Colors.green.shade50
                      : const Color(0xFFF0F4FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: isConnecting
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        isConnected ? Icons.bluetooth_connected : Icons.sensors,
                        size: 24,
                        color: isConnected ? Colors.green : const Color(0xFF2196F3),
                      ),
              ),
              title: Text(
                deviceName,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isConnected ? Colors.green.shade800 : Colors.black87,
                ),
              ),
              subtitle: Row(
                children: [
                  Icon(
                    Icons.signal_cellular_alt,
                    size: 14,
                    color: rssi > -70 ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$rssi dBm',
                    style: TextStyle(
                      fontSize: 12,
                      color: rssi > -70 ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
              trailing: isConnected
                  ? const Icon(Icons.check_circle, color: Colors.green, size: 24)
                  : Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 22),
              onTap: isConnecting || isConnected
                  ? null
                  : () => _connectAndNavigate(device, deviceName),
            );
          }),
        ],
      ),
    );
  }

}

/// Custom painter for the radar scanning animation
class RadarPainter extends CustomPainter {
  final double sweepAngle;
  final double pulseValue;
  final int foundDevices;

  RadarPainter({
    required this.sweepAngle,
    required this.pulseValue,
    required this.foundDevices,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2 - 10;

    // Draw concentric circles
    final circlePaint = Paint()
      ..color = const Color(0xFF2196F3).withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (int i = 1; i <= 4; i++) {
      final radius = maxRadius * i / 4;
      canvas.drawCircle(center, radius, circlePaint);
    }

    // Draw cross lines (axes)
    final axisPaint = Paint()
      ..color = const Color(0xFF2196F3).withOpacity(0.08)
      ..strokeWidth = 0.8;

    canvas.drawLine(
      Offset(center.dx, center.dy - maxRadius),
      Offset(center.dx, center.dy + maxRadius),
      axisPaint,
    );
    canvas.drawLine(
      Offset(center.dx - maxRadius, center.dy),
      Offset(center.dx + maxRadius, center.dy),
      axisPaint,
    );

    // Draw radar sweep (gradient cone)
    final sweepRect = Rect.fromCircle(center: center, radius: maxRadius);
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        startAngle: sweepAngle - 0.8,
        endAngle: sweepAngle,
        colors: [
          const Color(0xFF2196F3).withOpacity(0.0),
          const Color(0xFF2196F3).withOpacity(0.25),
        ],
        transform: GradientRotation(0),
      ).createShader(sweepRect)
      ..style = PaintingStyle.fill;

    // Draw sweep arc
    canvas.save();
    final path = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(sweepRect, sweepAngle - 0.8, 0.8, false)
      ..close();
    canvas.drawPath(path, sweepPaint);
    canvas.restore();

    // Draw the sweep line
    final linePaint = Paint()
      ..color = const Color(0xFF2196F3).withOpacity(0.6)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final lineEnd = Offset(
      center.dx + maxRadius * cos(sweepAngle),
      center.dy + maxRadius * sin(sweepAngle),
    );
    canvas.drawLine(center, lineEnd, linePaint);

    // Draw center dot
    final centerDotPaint = Paint()
      ..color = const Color(0xFF2196F3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 5, centerDotPaint);

    // Draw outer glow on center
    final glowPaint = Paint()
      ..color = const Color(0xFF2196F3).withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 8, glowPaint);

    // Draw pulsing ring
    final pulseRadius = maxRadius * 0.3 + (maxRadius * 0.7 * pulseValue);
    final pulsePaint = Paint()
      ..color = const Color(0xFF2196F3).withOpacity(0.15 * (1 - pulseValue))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 * (1 - pulseValue);
    canvas.drawCircle(center, pulseRadius, pulsePaint);

    // Draw small dots for "found devices" along the circles
    if (foundDevices > 0) {
      final dotPaint = Paint()
        ..color = const Color(0xFF2196F3)
        ..style = PaintingStyle.fill;

      final positions = [
        Offset(center.dx + maxRadius * 0.5 * cos(0.8), center.dy + maxRadius * 0.5 * sin(0.8)),
        Offset(center.dx + maxRadius * 0.75 * cos(2.5), center.dy + maxRadius * 0.75 * sin(2.5)),
        Offset(center.dx + maxRadius * 0.6 * cos(4.2), center.dy + maxRadius * 0.6 * sin(4.2)),
      ];

      for (int i = 0; i < min(foundDevices, positions.length); i++) {
        // Glow
        canvas.drawCircle(
          positions[i],
          6,
          Paint()..color = const Color(0xFF2196F3).withOpacity(0.2),
        );
        canvas.drawCircle(positions[i], 3.5, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant RadarPainter oldDelegate) =>
      oldDelegate.sweepAngle != sweepAngle ||
      oldDelegate.pulseValue != pulseValue ||
      oldDelegate.foundDevices != foundDevices;
}
