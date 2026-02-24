// add_device_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_curtain_app/features/home/presentation/pages/bluetooth_controller.dart';
import 'package:smart_curtain_app/features/home/presentation/pages/wifi_config_page.dart';

class AddDevicePage extends StatefulWidget {
  const AddDevicePage({Key? key}) : super(key: key);

  @override
  State<AddDevicePage> createState() => _AddDevicePageState();
}

class _AddDevicePageState extends State<AddDevicePage> {
  late BluetoothController _bluetoothController;
  bool _autoStarted = false;

  @override
  void initState() {
    super.initState();
    _bluetoothController = BluetoothController();
    _bluetoothController.initialize();

    // Tự động bắt đầu scan khi vào trang
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
    _bluetoothController.dispose();
    super.dispose();
  }

  // Logic kết nối CHÍNH XÁC từ main.dart đã test thành công
  Future<void> _connectAndNavigate(device, String deviceName) async {
    if (_bluetoothController.isConnecting) return;

    try {
      // Kết nối với thiết bị
      final success = await _bluetoothController.connectToDevice(device);

      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_bluetoothController.errorMessage ?? 'Lỗi kết nối'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Hiển thị thông báo thành công
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Đã kết nối với $deviceName'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Chuyển sang màn hình WiFi config - GIỐNG MAIN.DART
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                WiFiConfigPage(device: device, deviceName: deviceName),
          ),
        ).then((_) {
          // Quay lại thì kiểm tra kết nối
          setState(() {});
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✗ Lỗi kết nối: $e'),
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
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Add Device',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            // Nút disconnect nếu đã kết nối
            Consumer<BluetoothController>(
              builder: (context, controller, child) {
                if (controller.connectedDevice != null) {
                  return IconButton(
                    icon: const Icon(Icons.link_off, color: Colors.red),
                    tooltip: 'Ngắt kết nối',
                    onPressed: () async {
                      await controller.disconnect();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã ngắt kết nối')),
                      );
                    },
                  );
                }
                return IconButton(
                  icon: const Icon(Icons.qr_code_scanner, color: Colors.black),
                  onPressed: () {
                    // TODO: QR code scanner
                  },
                );
              },
            ),
          ],
        ),
        body: Consumer<BluetoothController>(
          builder: (context, controller, child) {
            return Column(
              children: [
                // Banner "Đã kết nối" nếu có thiết bị đang kết nối - GIỐNG MAIN.DART
                if (controller.connectedDevice != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.green.shade200,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 24,
                        ),
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
                          icon: const Icon(Icons.settings),
                          tooltip: 'Cấu hình WiFi',
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
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () async {
                            await controller.disconnect();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đã ngắt kết nối')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                // Header thông báo
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: controller.isScanning
                            ? const Padding(
                                padding: EdgeInsets.all(10),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                Icons.bluetooth_searching,
                                color: Colors.blue.shade600,
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                            children: [
                              const TextSpan(
                                text:
                                    'Searching for nearby devices. Make sure your device has entered ',
                              ),
                              TextSpan(
                                text: 'pairing mode',
                                style: TextStyle(
                                  color: Colors.blue.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Danh sách thiết bị
                Expanded(
                  child: controller.scanResults.isEmpty
                      ? _buildEmptyState(controller)
                      : _buildDeviceList(controller),
                ),

                // Bottom info
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Tap device to connect. ',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Cancel (${controller.scanResults.length})',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BluetoothController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bluetooth_searching, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            controller.isScanning
                ? 'Đang tìm kiếm thiết bị...'
                : 'Không tìm thấy thiết bị',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          if (!controller.isScanning) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _bluetoothController.startScan(),
              icon: const Icon(Icons.refresh),
              label: const Text('Quét lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeviceList(BluetoothController controller) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: controller.scanResults.length,
      itemBuilder: (context, index) {
        final result = controller.scanResults[index];
        final device = result.device;
        final deviceName = controller.getDeviceName(result);
        final rssi = result.rssi;

        // Kiểm tra xem thiết bị có đang kết nối không - GIỐNG MAIN.DART
        final isConnected =
            controller.connectedDevice?.remoteId == device.remoteId;
        final isConnecting =
            controller.isConnecting &&
            controller.connectedDevice?.remoteId == device.remoteId;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            // Màu xanh nếu đã kết nối - GIỐNG MAIN.DART
            color: isConnected ? Colors.green.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: isConnected
                ? Border.all(color: Colors.green.shade200, width: 2)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isConnected ? Colors.green.shade100 : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: isConnecting
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      // Icon khác nếu đã kết nối
                      isConnected ? Icons.bluetooth_connected : Icons.sensors,
                      size: 32,
                      color: isConnected ? Colors.green : Colors.grey,
                    ),
            ),
            title: Text(
              deviceName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                // Màu xanh nếu đã kết nối
                color: isConnected ? Colors.green.shade800 : Colors.black,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  device.remoteId.toString(),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Row(
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
              ],
            ),
            trailing: isConnected
                // Icon check nếu đã kết nối - GIỐNG MAIN.DART
                ? const Icon(Icons.check_circle, color: Colors.green, size: 28)
                : (isConnecting
                      ? null
                      : Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey[400],
                        )),
            onTap: isConnecting || isConnected
                ? null
                : () => _connectAndNavigate(device, deviceName),
          ),
        );
      },
    );
  }
}
