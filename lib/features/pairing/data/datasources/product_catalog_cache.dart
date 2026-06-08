import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/osprey_product_model.dart';

/// Cache product catalog vào SharedPreferences, TTL 24h (spec §8.4).
///
/// App gọi `GET /products` 1 lần mỗi session; nếu offline hoặc backend lỗi
/// vẫn dùng được cache cũ để hiển thị tên thiết bị khi scan.
class ProductCatalogCache {
  static const String cacheKey = 'osprey_product_catalog';
  static const String cacheTimestampKey = 'osprey_product_catalog_at';
  static const Duration ttl = Duration(hours: 24);

  final SharedPreferences prefs;

  ProductCatalogCache({required this.prefs});

  /// Trả null nếu chưa có cache hoặc cache đã quá TTL.
  List<OspreyProductModel>? getFresh() {
    final raw = _read();
    if (raw == null) return null;
    final cachedAt = prefs.getInt(cacheTimestampKey) ?? 0;
    final age = DateTime.now().millisecondsSinceEpoch - cachedAt;
    if (age > ttl.inMilliseconds) return null;
    return raw;
  }

  /// Trả cache bất kể TTL — fallback khi backend không gọi được.
  List<OspreyProductModel>? getStale() => _read();

  Future<void> save(List<OspreyProductModel> products) async {
    await prefs.setString(
      cacheKey,
      jsonEncode(products.map((p) => p.toJson()).toList()),
    );
    await prefs.setInt(
      cacheTimestampKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  List<OspreyProductModel>? _read() {
    final cached = prefs.getString(cacheKey);
    if (cached == null) return null;
    try {
      final List<dynamic> data = jsonDecode(cached) as List<dynamic>;
      return data
          .map((json) =>
              OspreyProductModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on FormatException {
      return null;
    }
  }
}
