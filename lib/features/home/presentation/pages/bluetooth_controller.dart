// bluetooth_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothController extends ChangeNotifier {
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  BluetoothDevice? _connectedDevice;
  bool _isConnecting = false;
  String? _errorMessage;

  // Getters
  List<ScanResult> get scanResults => _scanResults;
  bool get isScanning => _isScanning;
  BluetoothDevice? get connectedDevice => _connectedDevice;
  bool get isConnecting => _isConnecting;
  String? get errorMessage => _errorMessage;

  // Khởi tạo listeners
  void initialize() {
    // Lắng nghe kết quả scan
    FlutterBluePlus.scanResults.listen((results) {
      _scanResults = results;
      // Sắp xếp theo RSSI (tín hiệu mạnh trước)
      _scanResults.sort((a, b) => b.rssi.compareTo(a.rssi));
      notifyListeners();
    });

    // Lắng nghe trạng thái scan
    FlutterBluePlus.isScanning.listen((scanning) {
      _isScanning = scanning;
      notifyListeners();
    });
  }

  // Kiểm tra và yêu cầu quyền
  Future<bool> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  // Kiểm tra Bluetooth có được hỗ trợ không
  Future<bool> isBluetoothSupported() async {
    return await FlutterBluePlus.isSupported;
  }

  // Bắt đầu scan thiết bị BLE
  Future<bool> startScan() async {
    _errorMessage = null;

    // Kiểm tra quyền
    if (!await requestPermissions()) {
      _errorMessage = 'Cần cấp quyền Bluetooth và Location';
      notifyListeners();
      return false;
    }

    // Kiểm tra hỗ trợ BLE
    if (!await isBluetoothSupported()) {
      _errorMessage = 'Thiết bị không hỗ trợ Bluetooth';
      notifyListeners();
      return false;
    }

    try {
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15),
        androidUsesFineLocation: true,
        androidScanMode: AndroidScanMode.lowLatency,
      );
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi khi scan: $e';
      notifyListeners();
      return false;
    }
  }

  // Dừng scan
  Future<void> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
    } catch (e) {
      _errorMessage = 'Lỗi khi dừng scan: $e';
      notifyListeners();
    }
  }

  // Kết nối với thiết bị
  Future<bool> connectToDevice(BluetoothDevice device) async {
    if (_isConnecting) return false;

    _isConnecting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Ngắt kết nối thiết bị cũ nếu có
      if (_connectedDevice != null) {
        await _connectedDevice!.disconnect();
      }

      // Kết nối thiết bị mới
      await device.connect(timeout: const Duration(seconds: 15));

      _connectedDevice = device;
      _isConnecting = false;
      notifyListeners();

      // Lắng nghe trạng thái kết nối
      device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _connectedDevice = null;
          notifyListeners();
        }
      });

      return true;
    } catch (e) {
      _errorMessage = 'Lỗi kết nối: $e';
      _isConnecting = false;
      notifyListeners();
      return false;
    }
  }

  // Ngắt kết nối
  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      try {
        await _connectedDevice!.disconnect();
        _connectedDevice = null;
        notifyListeners();
      } catch (e) {
        _errorMessage = 'Lỗi ngắt kết nối: $e';
        notifyListeners();
      }
    }
  }

  // Lấy tên thiết bị
  String getDeviceName(ScanResult result) {
    // Ưu tiên advName
    if (result.advertisementData.advName.isNotEmpty) {
      return result.advertisementData.advName;
    }

    // localName
    if (result.advertisementData.localName.isNotEmpty) {
      return result.advertisementData.localName;
    }

    // platformName
    if (result.device.platformName.isNotEmpty) {
      return result.device.platformName;
    }

    // Hiển thị MAC cuối nếu không có tên
    final mac = result.device.remoteId.toString();
    final macShort = mac.length > 8 ? mac.substring(mac.length - 8) : mac;
    return 'Unknown ($macShort)';
  }

  // Gửi WiFi credentials qua BLE (cần implement theo protocol của bạn)
  Future<bool> sendWiFiCredentials(String ssid, String password) async {
    if (_connectedDevice == null) {
      _errorMessage = 'Chưa kết nối thiết bị';
      notifyListeners();
      return false;
    }

    try {
      // Discover services
      List<BluetoothService> services = await _connectedDevice!
          .discoverServices();

      // TODO: Tìm service và characteristic để gửi WiFi
      // Ví dụ: UUID service và characteristic của bạn
      // const serviceUuid = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
      // const characteristicUuid = "beb5483e-36e1-4688-b7f5-ea07361b26a8";

      // BluetoothService? targetService = services.firstWhere(
      //   (s) => s.uuid.toString() == serviceUuid,
      //   orElse: () => null,
      // );

      // if (targetService != null) {
      //   BluetoothCharacteristic? characteristic = targetService.characteristics.firstWhere(
      //     (c) => c.uuid.toString() == characteristicUuid,
      //     orElse: () => null,
      //   );

      //   if (characteristic != null) {
      //     // Gửi SSID
      //     await characteristic.write(utf8.encode(ssid));
      //     // Gửi Password
      //     await characteristic.write(utf8.encode(password));
      //     return true;
      //   }
      // }

      // Placeholder - cần implement theo protocol của bạn
      await Future.delayed(const Duration(seconds: 2));
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi gửi WiFi credentials: $e';
      notifyListeners();
      return false;
    }
  }

  // Lấy MAC address của thiết bị
  String? getMacAddress() {
    return _connectedDevice?.remoteId.toString();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Cleanup
  @override
  void dispose() {
    stopScan();
    disconnect();
    super.dispose();
  }
}
