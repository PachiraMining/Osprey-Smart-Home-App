import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/discovered_osprey_device.dart';
import '../entities/osprey_product.dart';
import '../entities/pairing_progress.dart';

abstract class PairingRepository {
  /// Catalog SKU (cache 24h, fallback cache cũ khi offline).
  Future<Either<Failure, List<OspreyProduct>>> getProductCatalog({
    bool forceRefresh = false,
  });

  /// Scan BLE filter theo Brand UUID; emit danh sách device pairable
  /// (đã skip device paired, đã match product theo hash).
  Stream<List<DiscoveredOspreyDevice>> scanForDevices();

  /// Bluetooth adapter đang bật? Bỏ qua trạng thái `unknown` lúc khởi động
  /// (iOS) — chỉ emit khi đã biết chắc on/off.
  Stream<bool> bluetoothOn();

  /// Scan BLE có đang chạy không (FBP tự dừng sau scanTimeout).
  Stream<bool> scanning();

  Future<void> startScan();
  Future<void> stopScan();

  /// Pairing flow đầy đủ (spec §4.2). Emit từng bước qua stream;
  /// lỗi emit qua stream error với [Failure].
  Stream<PairingProgress> pairDevice({
    required DiscoveredOspreyDevice device,
    required String ssid,
    required String wifiPassword,
    String? roomId,
  });
}
