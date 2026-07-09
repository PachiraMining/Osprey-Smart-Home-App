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
  Future<bool> tryRefresh() =>
      _inFlight ??= _doRefresh().whenComplete(() => _inFlight = null);

  Future<bool> _doRefresh() async {
    final refreshToken = await _tokenManager.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;
    try {
      final response = await _dio.post(
        _refreshPath,
        data: {'refreshToken': refreshToken},
      );
      final data = response.data;
      final newToken = data is Map ? data['token'] as String? : null;
      final newRefresh = data is Map ? data['refreshToken'] as String? : null;
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
    } catch (_) {
      return false;
    }
  }
}
