import '../../domain/entities/osprey_adv_data.dart';
import '../crypto/hex_utils.dart';

/// Parse Manufacturer Specific Data từ BLE advertisement Osprey (spec §3.2).
///
/// flutter_blue_plus trả `manufacturerData` dạng `Map<companyId, bytes>`
/// (đã tách sẵn 2 bytes Company ID little-endian). Phần còn lại:
///
/// ```
/// [0]   frameCtrl   bit0=paired, bit1=encrypted, bit2-7=protocol version
/// [1-2] productType big-endian (LƯU Ý: ngược với UUID little-endian)
/// [3-5] productIdHash (nguyên bytes như adv)
/// ```
class OspreyAdvParser {
  OspreyAdvParser._();

  /// Trả null nếu payload không đúng format Osprey (quá ngắn).
  static OspreyAdvData? parse(List<int> manufacturerBytes) {
    if (manufacturerBytes.length < 6) return null;

    final frameControl = manufacturerBytes[0];
    // productType: 2 bytes BIG-endian (high byte trước)
    final productType =
        (manufacturerBytes[1] << 8) | manufacturerBytes[2];
    final productIdHashHex =
        HexUtils.encode(manufacturerBytes.sublist(3, 6));

    return OspreyAdvData(
      isPaired: (frameControl & 0x01) != 0,
      isEncrypted: (frameControl & 0x02) != 0,
      protocolVersion: (frameControl >> 2) & 0x3F,
      productType: productType,
      productIdHashHex: productIdHashHex,
    );
  }
}
