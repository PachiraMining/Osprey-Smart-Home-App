import 'package:equatable/equatable.dart';

/// Một SKU trong catalog Osprey (vd OSPREY_CURTAIN_V1).
class OspreyProduct extends Equatable {
  final String id;
  final String productCode;
  final int productType;

  /// 3 bytes đầu của SHA-256(product_code), dạng hex lowercase (vd "a0ce10").
  final String productIdHashHex;
  final String displayName;
  final String iconUrl;
  final String category;
  final String deviceProfileId;

  const OspreyProduct({
    required this.id,
    required this.productCode,
    required this.productType,
    required this.productIdHashHex,
    required this.displayName,
    required this.iconUrl,
    required this.category,
    required this.deviceProfileId,
  });

  @override
  List<Object?> get props => [
        id,
        productCode,
        productType,
        productIdHashHex,
        displayName,
        iconUrl,
        category,
        deviceProfileId,
      ];
}
