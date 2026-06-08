import 'package:equatable/equatable.dart';

import 'osprey_adv_data.dart';
import 'osprey_product.dart';

/// Thiết bị Osprey tìm thấy qua BLE scan, đã match với product catalog.
class DiscoveredOspreyDevice extends Equatable {
  /// Platform device id (MAC trên Android, UUID trên iOS) — dùng để connect.
  final String remoteId;

  /// Local name từ scan response, vd "Osprey-CR-A1B2".
  final String name;

  final int rssi;
  final OspreyAdvData advData;

  /// Product match theo productIdHash; null nếu hash chưa có trong catalog.
  final OspreyProduct? product;

  const DiscoveredOspreyDevice({
    required this.remoteId,
    required this.name,
    required this.rssi,
    required this.advData,
    this.product,
  });

  /// Suffix MAC để user phân biệt device của mình với hàng xóm
  /// (vd "Osprey-CR-A1B2" → "A1B2").
  String get macSuffix {
    final dashIdx = name.lastIndexOf('-');
    if (dashIdx > 0 && dashIdx < name.length - 1) {
      return name.substring(dashIdx + 1);
    }
    final id = remoteId.replaceAll(':', '');
    return id.length >= 4 ? id.substring(id.length - 4).toUpperCase() : id;
  }

  String get displayName => product?.displayName ?? name;

  @override
  List<Object?> get props => [remoteId, name, rssi, advData, product];
}
