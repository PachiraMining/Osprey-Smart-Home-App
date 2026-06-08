import 'package:equatable/equatable.dart';

/// Dữ liệu parse từ Manufacturer Specific Data trong BLE advertisement
/// của thiết bị Osprey.
///
/// Format (sau Company ID 0xFFFF):
/// `frameCtrl(1) + productType BE(2) + productIdHash(3)`
class OspreyAdvData extends Equatable {
  /// bit 0 của frame control: 1 = đã paired → ẩn khỏi "Add Device".
  final bool isPaired;

  /// bit 1 của frame control: 1 = encrypted.
  final bool isEncrypted;

  /// bit 2-7 của frame control (hiện tại = 0x01... per spec).
  final int protocolVersion;

  /// 2 bytes big-endian (vd 0x0001 = curtain).
  final int productType;

  /// 3 bytes hash dạng hex lowercase (vd "a0ce10").
  final String productIdHashHex;

  const OspreyAdvData({
    required this.isPaired,
    required this.isEncrypted,
    required this.protocolVersion,
    required this.productType,
    required this.productIdHashHex,
  });

  @override
  List<Object?> get props =>
      [isPaired, isEncrypted, protocolVersion, productType, productIdHashHex];
}
