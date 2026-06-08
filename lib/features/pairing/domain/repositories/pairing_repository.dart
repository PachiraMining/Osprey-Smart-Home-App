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
