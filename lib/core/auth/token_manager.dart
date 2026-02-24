// lib/core/auth/token_manager.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  final FlutterSecureStorage _storage;

  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _customerIdKey = 'customer_id'; // THÊM

  TokenManager(this._storage);

  // Cache in memory
  String? _cachedToken;
  String? _cachedCustomerId; // THÊM

  // Save tokens và customerId
  Future<void> saveTokens({
    required String token,
    required String refreshToken,
    String? customerId, // THÊM - optional vì có thể lưu sau
  }) async {
    await Future.wait([
      _storage.write(key: _tokenKey, value: token),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
      if (customerId != null)
        _storage.write(key: _customerIdKey, value: customerId),
    ]);
    _cachedToken = token;
    _cachedCustomerId = customerId;
  }

  // Save customerId riêng
  Future<void> saveCustomerId(String customerId) async {
    await _storage.write(key: _customerIdKey, value: customerId);
    _cachedCustomerId = customerId;
  }

  // Get token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Get refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  // Get customerId
  Future<String?> getCustomerId() async {
    return await _storage.read(key: _customerIdKey);
  }

  // Get token sync
  String? getTokenSync() {
    return _cachedToken;
  }

  // Get customerId sync
  String? getCustomerIdSync() {
    return _cachedCustomerId;
  }

  // Clear all
  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _tokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _customerIdKey),
    ]);
    _cachedToken = null;
    _cachedCustomerId = null;
  }

  // Load to cache
  Future<void> loadTokenToCache() async {
    _cachedToken = await getToken();
    _cachedCustomerId = await getCustomerId();
  }

  // Set cached token
  void setCachedToken(String? token) {
    _cachedToken = token;
  }

  // Set cached customerId
  void setCachedCustomerId(String? customerId) {
    _cachedCustomerId = customerId;
  }

  // Thêm method debug
  void debugPrint() {
    print('🔍 TokenManager Debug:');
    print('  - Token cached: ${_cachedToken?.substring(0, 20) ?? "NULL"}...');
    print('  - CustomerId cached: ${_cachedCustomerId ?? "NULL"}');
  }
}
