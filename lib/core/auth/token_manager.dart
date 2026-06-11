// lib/core/auth/token_manager.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../di/injector.dart';
import '../widget/home_widget_service.dart';

class TokenManager {
  final FlutterSecureStorage _storage;

  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _customerIdKey = 'customer_id';
  static const String _emailKey = 'user_email';
  static const String _firstNameKey = 'user_first_name';
  static const String _lastNameKey = 'user_last_name';
  static const String _homeIdKey = 'home_id';

  TokenManager(this._storage);

  Future<void> _safeWrite(String key, String value) async {
    await _storage.delete(key: key);
    await _storage.write(key: key, value: value);
  }

  // Cache in memory
  String? _cachedToken;
  String? _cachedCustomerId;
  String? _cachedEmail;
  String? _cachedFirstName;
  String? _cachedLastName;
  String? _cachedHomeId;

  // Save tokens và customerId
  Future<void> saveTokens({
    required String token,
    required String refreshToken,
    String? customerId,
  }) async {
    await _safeWrite(_tokenKey, token);
    await _safeWrite(_refreshTokenKey, refreshToken);
    if (customerId != null) await _safeWrite(_customerIdKey, customerId);
    _cachedToken = token;
    _cachedCustomerId = customerId;
    _mirrorTokenToWidget(token);
  }

  /// Mirror JWT sang App Group cho iOS widget (extension không đọc được
  /// Keychain của app). Best-effort — không chặn luồng login.
  void _mirrorTokenToWidget(String? token) {
    try {
      if (sl.isRegistered<HomeWidgetService>()) {
        sl<HomeWidgetService>().pushAuthToken(token);
      }
    } catch (_) {}
  }

  Future<void> saveCustomerId(String customerId) async {
    await _safeWrite(_customerIdKey, customerId);
    _cachedCustomerId = customerId;
  }

  Future<void> saveHomeId(String homeId) async {
    await _safeWrite(_homeIdKey, homeId);
    _cachedHomeId = homeId;
  }

  Future<void> saveUserInfo({
    required String email,
    String? firstName,
    String? lastName,
  }) async {
    await _safeWrite(_emailKey, email);
    if (firstName != null) await _safeWrite(_firstNameKey, firstName);
    if (lastName != null) await _safeWrite(_lastNameKey, lastName);
    _cachedEmail = email;
    _cachedFirstName = firstName;
    _cachedLastName = lastName;
  }

  Future<String?> getEmail() async => await _storage.read(key: _emailKey);
  Future<String?> getFirstName() async => await _storage.read(key: _firstNameKey);
  Future<String?> getLastName() async => await _storage.read(key: _lastNameKey);

  String? getEmailSync() => _cachedEmail;
  String? getFirstNameSync() => _cachedFirstName;
  String? getLastNameSync() => _cachedLastName;

  String getDisplayName() {
    final first = _cachedFirstName ?? '';
    final last = _cachedLastName ?? '';
    final full = '$first $last'.trim();
    if (full.isNotEmpty) return full;
    return _cachedEmail ?? 'User';
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

  String? getHomeIdSync() => _cachedHomeId;

  // Clear all
  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _tokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _customerIdKey),
      _storage.delete(key: _emailKey),
      _storage.delete(key: _firstNameKey),
      _storage.delete(key: _lastNameKey),
      _storage.delete(key: _homeIdKey),
    ]);
    _cachedToken = null;
    _cachedCustomerId = null;
    _cachedEmail = null;
    _cachedFirstName = null;
    _cachedLastName = null;
    _cachedHomeId = null;
    _mirrorTokenToWidget(null);
  }

  // Load to cache
  Future<void> loadTokenToCache() async {
    _cachedToken = await getToken();
    _cachedCustomerId = await getCustomerId();
    _cachedEmail = await getEmail();
    _cachedFirstName = await getFirstName();
    _cachedLastName = await getLastName();
    _cachedHomeId = await _storage.read(key: _homeIdKey);
  }

  // Set cached token
  void setCachedToken(String? token) {
    _cachedToken = token;
  }

  // Set cached customerId
  void setCachedCustomerId(String? customerId) {
    _cachedCustomerId = customerId;
  }

}
