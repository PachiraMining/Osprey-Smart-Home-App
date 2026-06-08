import 'dart:convert';

import '../../domain/entities/osprey_product.dart';
import '../crypto/hex_utils.dart';

/// Model cho product catalog từ `GET /api/smarthome/products`.
///
/// LƯU Ý encoding (handoff checklist §2.1):
/// - JSON field `productIdHash` là **base64** ("oM4Q" = 0xA0CE10)
/// - URL `/products/by-hash/{hash}` dùng **hex** ("a0ce10")
/// Model này normalize về hex lowercase.
class OspreyProductModel extends OspreyProduct {
  const OspreyProductModel({
    required super.id,
    required super.productCode,
    required super.productType,
    required super.productIdHashHex,
    required super.displayName,
    required super.iconUrl,
    required super.category,
    required super.deviceProfileId,
  });

  factory OspreyProductModel.fromJson(Map<String, dynamic> json) {
    return OspreyProductModel(
      id: _unwrapId(json['id']),
      productCode: (json['productCode'] ?? json['product_code'] ?? '') as String,
      productType: (json['productType'] ?? json['product_type'] ?? 0) as int,
      productIdHashHex: _normalizeHash(
        (json['productIdHash'] ?? json['product_id_hash'] ?? '') as String,
      ),
      displayName: (json['displayName'] ?? json['display_name'] ?? '') as String,
      iconUrl: (json['iconUrl'] ?? json['icon_url'] ?? '') as String,
      category: (json['category'] ?? '') as String,
      deviceProfileId:
          _unwrapId(json['deviceProfileId'] ?? json['device_profile_id']),
    );
  }

  /// Serialize cho local cache (giữ hash dạng hex).
  Map<String, dynamic> toJson() => {
        'id': id,
        'productCode': productCode,
        'productType': productType,
        'productIdHash': productIdHashHex,
        'displayName': displayName,
        'iconUrl': iconUrl,
        'category': category,
        'deviceProfileId': deviceProfileId,
      };

  /// TB trả id dạng `{"entityType": "...", "id": "uuid"}` hoặc string trần.
  static String _unwrapId(dynamic raw) {
    if (raw == null) return '';
    if (raw is String) return raw;
    if (raw is Map) return (raw['id'] ?? '') as String;
    return raw.toString();
  }

  /// Chấp nhận cả base64 ("oM4Q") lẫn hex ("a0ce10") → hex lowercase.
  static String _normalizeHash(String raw) {
    if (raw.isEmpty) return '';
    // Hash 3 bytes: hex luôn 6 ký tự [0-9a-f], base64 luôn 4 ký tự
    final isHex =
        raw.length == 6 && RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(raw);
    if (isHex) return raw.toLowerCase();
    try {
      return HexUtils.encode(base64.decode(raw));
    } on FormatException {
      return raw.toLowerCase();
    }
  }
}
