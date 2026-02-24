// wifi_config_page.dart
// Logic lấy từ main.dart đã test thành công
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class WiFiConfigPage extends StatefulWidget {
  final BluetoothDevice device;
  final String deviceName;

  const WiFiConfigPage({
    Key? key,
    required this.device,
    required this.deviceName,
  }) : super(key: key);

  @override
  State<WiFiConfigPage> createState() => _WiFiConfigPageState();
}

class _WiFiConfigPageState extends State<WiFiConfigPage> {
  final _ssidController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSending = false;
  String _statusMessage = '';
  List<BluetoothService> _services = [];
  BluetoothCharacteristic? _rxCharacteristic;
  BluetoothCharacteristic? _txCharacteristic;

  @override
  void initState() {
    super.initState();
    _discoverServices();
  }

  Future<void> _discoverServices() async {
    try {
      setState(() {
        _statusMessage = 'Đang tìm services...';
      });

      _services = await widget.device.discoverServices();

      // Tìm characteristic RX (để gửi dữ liệu)
      for (var service in _services) {
        for (var char in service.characteristics) {
          // RX characteristic (0xFF01) - để gửi dữ liệu
          if (char.uuid.toString().toUpperCase().contains('FF01')) {
            _rxCharacteristic = char;
          }
          // TX characteristic (0xFF02) - để nhận dữ liệu
          if (char.uuid.toString().toUpperCase().contains('FF02')) {
            _txCharacteristic = char;
            // Subscribe để nhận notify
            await char.setNotifyValue(true);
            char.lastValueStream.listen((value) {
              if (value.isNotEmpty) {
                final message = String.fromCharCodes(value);
                setState(() {
                  _statusMessage = 'Smart Curtain: $message';
                });
              }
            });
          }
        }
      }

      if (_rxCharacteristic != null) {
        setState(() {
          _statusMessage = 'Sẵn sàng gửi WiFi credentials';
        });
      } else {
        setState(() {
          _statusMessage = 'Không tìm thấy characteristic phù hợp';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Lỗi: $e';
      });
    }
  }

  Future<void> _sendWiFiCredentials() async {
    if (_ssidController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ SSID và Password')),
      );
      return;
    }

    if (_rxCharacteristic == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa sẵn sàng gửi dữ liệu')),
      );
      return;
    }

    setState(() {
      _isSending = true;
      _statusMessage = 'Đang gửi...';
    });

    try {
      // Tạo chuỗi dữ liệu: SSID:PASSWORD
      final credentials = '${_ssidController.text}:${_passwordController.text}';
      final data = credentials.codeUnits;

      // Gửi dữ liệu (chia nhỏ nếu cần, MTU là 500)
      await _rxCharacteristic!.write(data, withoutResponse: false);

      setState(() {
        _statusMessage = '✓ Đã gửi WiFi credentials đến Smart Curtain';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Đã gửi thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _statusMessage = '✗ Lỗi: $e';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('✗ Lỗi gửi: $e')));
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cấu hình WiFi - ${widget.deviceName}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thông tin kết nối
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Thiết bị: ${widget.deviceName}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'MAC: ${widget.device.remoteId}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _statusMessage,
                      style: TextStyle(
                        fontSize: 12,
                        color: _statusMessage.startsWith('✓')
                            ? Colors.green
                            : (_statusMessage.startsWith('✗')
                                  ? Colors.red
                                  : Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Form nhập WiFi
            Text(
              'Thông tin WiFi',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _ssidController,
              decoration: InputDecoration(
                labelText: 'SSID',
                hintText: 'Nhập tên WiFi',
                prefixIcon: const Icon(Icons.wifi),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Nhập mật khẩu WiFi',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _isSending ? null : _sendWiFiCredentials,
              icon: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send),
              label: Text(_isSending ? 'Đang gửi...' : 'Gửi đến Smart Curtain'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            // Hướng dẫn
            Card(
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: Colors.amber[700]),
                        const SizedBox(width: 8),
                        const Text(
                          'Hướng dẫn',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Nhập SSID và Password của WiFi\n'
                      '2. Nhấn "Gửi đến Smart Curtain"\n',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
