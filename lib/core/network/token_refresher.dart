import 'dart:convert';

import 'package:dio/dio.dart';

import '../auth/token_manager.dart';
import '../config/app_config.dart';

/// Exchanges the stored refresh token for a fresh ThingsBoard access token.
///
/// Uses its own bare [Dio] (no auth interceptor) so the refresh request can
/// never recurse back into the 401 handler. Concurrent callers share a single
/// in-flight request (single-flight), so a burst of 401s triggers one refresh.
class TokenRefresher {
  TokenRefresher({
    required TokenManager tokenManager,
    Dio? dio,
    String? refreshPath,
    String? baseUrl,
    void Function(String newToken)? onRefreshed,
  })  : _tokenManager = tokenManager,
        _dio = dio ??
            Dio(BaseOptions(baseUrl: baseUrl ?? AppConfig.thingsboardBaseUrl)),
        _refreshPath = refreshPath ?? AppConfig.refreshTokenPath,
        _onRefreshed = onRefreshed;

  final Dio _dio;
  final TokenManager _tokenManager;
  final String _refreshPath;

  /// Notified with the fresh access token after every successful refresh, so
  /// long-lived connections that authenticate with the JWT (e.g. the MQTT
  /// telemetry socket) can re-authenticate without waiting for their own 401.
  final void Function(String newToken)? _onRefreshed;

  Future<bool>? _inFlight;

  /// Attempts a refresh, returning whether a new valid access token is now
  /// stored. Never throws — any failure resolves to `false`.
  ///
  /// [staleToken] is the access token the calling request actually sent. If the
  /// stored token has already moved past it, another request already refreshed
  /// — we skip a redundant network round-trip and just tell the caller to retry
  /// with the current token. Combined with the in-flight coalescing below, this
  /// makes single-flight hold for 401s that arrive *sequentially* (after an
  /// earlier refresh finished), not only for ones that overlap in time.
  Future<bool> tryRefresh({String? staleToken}) {
    if (staleToken != null && staleToken.isNotEmpty) {
      final current = _tokenManager.getTokenSync();
      if (current != null && current.isNotEmpty && current != staleToken) {
        return Future.value(true);
      }
    }
    return _inFlight ??= _doRefresh().whenComplete(() => _inFlight = null);
  }

  Future<bool> _doRefresh() async {
    final refreshToken = await _tokenManager.getRefreshToken();
    // TEMP-AUTH-DIAG: reveal whether the refresh token survived cold start and
    // its real server TTL (decoded exp). Remove once the next-day-logout cause
    // is pinned down.
    _diagToken('refresh-token(read)', refreshToken);
    if (refreshToken == null || refreshToken.isEmpty) {
      print('🔑[AUTH-DIAG] refresh ABORT: no refresh token in storage');
      return false;
    }
    try {
      final response = await _dio.post(
        _refreshPath,
        data: {'refreshToken': refreshToken},
      );
      final data = response.data;
      final newToken = data is Map ? data['token'] as String? : null;
      final newRefresh = data is Map ? data['refreshToken'] as String? : null;
      print('🔑[AUTH-DIAG] refresh POST $_refreshPath → status=${response.statusCode} '
          'hasToken=${newToken != null && newToken.isNotEmpty} '
          'hasNewRefresh=${newRefresh != null && newRefresh.isNotEmpty}');
      if (newToken == null || newToken.isEmpty) return false;
      await _tokenManager.saveTokens(
        token: newToken,
        refreshToken: newRefresh == null || newRefresh.isEmpty
            ? refreshToken
            : newRefresh,
      );
      _tokenManager.setCachedToken(newToken);
      _onRefreshed?.call(newToken);
      return true;
    } catch (e) {
      // TEMP-AUTH-DIAG: capture WHY the refresh was rejected (status + body).
      if (e is DioException) {
        print('🔑[AUTH-DIAG] refresh FAILED status=${e.response?.statusCode} '
            'type=${e.type.name} body=${e.response?.data} msg=${e.message}');
      } else {
        print('🔑[AUTH-DIAG] refresh FAILED (non-Dio): $e');
      }
      return false;
    }
  }

  /// TEMP-AUTH-DIAG: decode a JWT's `exp`/`iat` and print its lifetime + how
  /// long until it expires, so we can see the refresh token's real server TTL.
  void _diagToken(String label, String? token) {
    if (token == null || token.isEmpty) {
      print('🔑[AUTH-DIAG] $label = <empty>');
      return;
    }
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        print('🔑[AUTH-DIAG] $label = not-a-jwt (len=${token.length})');
        return;
      }
      var seg = parts[1].replaceAll('-', '+').replaceAll('_', '/');
      seg = seg.padRight(seg.length + (4 - seg.length % 4) % 4, '=');
      final payload = jsonDecode(utf8.decode(base64.decode(seg))) as Map;
      final exp = payload['exp'];
      final iat = payload['iat'];
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      if (exp is num) {
        final ttlDays = iat is num
            ? ((exp - iat) / 86400).toStringAsFixed(2)
            : '?';
        final leftHours = ((exp - now) / 3600).toStringAsFixed(1);
        print('🔑[AUTH-DIAG] $label exp=$exp iat=$iat '
            'issuedTTL=${ttlDays}d expiresIn=${leftHours}h '
            '(${exp < now ? "EXPIRED" : "valid"})');
      } else {
        print('🔑[AUTH-DIAG] $label has no numeric exp (keys=${payload.keys.toList()})');
      }
    } catch (e) {
      print('🔑[AUTH-DIAG] $label decode-error: $e');
    }
  }
}
