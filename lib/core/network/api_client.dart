// lib/core/network/api_client.dart
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

import '../../core/auth/session_manager.dart';
import '../../core/auth/token_manager.dart';
import '../../core/network/auth_retry_policy.dart';
import '../../core/network/token_refresher.dart';
import '../../core/config/app_config.dart';
import '../../core/di/injector.dart';

class ApiClient {
  final Dio _dio;
  final AuthRetryPolicy _retryPolicy;

  /// Marks a request that has already been re-sent once after a token refresh,
  /// so a second 401 is treated as a dead session rather than looping forever.
  static const String _retriedKey = '__auth_retried';

  ApiClient({required String baseUrl, AuthRetryPolicy? retryPolicy})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          // Không đặt sendTimeout thì Dio để mặc, request có body sẽ treo theo
          // timeout của hệ điều hành nếu mạng chập chờn giữa chừng.
          sendTimeout: const Duration(seconds: 10),
          headers: {
            'Content-Type': 'application/json',
            'accept': 'application/json',
          },
        ),
      ),
      _retryPolicy =
          retryPolicy ??
          const AuthRetryPolicy(refreshPath: AppConfig.refreshTokenPath) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = sl<TokenManager>().getTokenSync();
          if (token != null && token.isNotEmpty) {
            options.headers['X-Authorization'] = 'Bearer $token';
          }
          // TEMP-NET-AUDIT: đếm call khi mở app (print → logcat). Gỡ sau.
          // ignore: avoid_print
          print('🌐 [NET] ${options.method} ${options.path}');
          _log('→ ${options.method} ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          _log('← ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.path}');
          handler.next(response);
        },
        onError: (error, handler) async {
          final requestOptions = error.requestOptions;
          final status = error.response?.statusCode;
          final path = requestOptions.path;
          final alreadyRetried = requestOptions.extra[_retriedKey] == true;

          // Expired access token on a protected route → refresh once, then
          // replay the original request transparently.
          if (_retryPolicy.shouldAttemptRefresh(
            statusCode: status,
            path: path,
            alreadyRetried: alreadyRetried,
          )) {
            final refresher = _refresher;
            final usedToken = _bearerOf(requestOptions.headers['X-Authorization']);
            final refreshed = refresher != null &&
                await refresher.tryRefresh(staleToken: usedToken);
            if (refreshed) {
              requestOptions.extra[_retriedKey] = true;
              // Carry the fresh token explicitly so the replay never depends on
              // the onRequest cache read order.
              final freshToken = sl<TokenManager>().getTokenSync();
              if (freshToken != null && freshToken.isNotEmpty) {
                requestOptions.headers['X-Authorization'] = 'Bearer $freshToken';
              }
              try {
                final retried = await _dio.fetch<dynamic>(requestOptions);
                return handler.resolve(retried);
              } on DioException catch (retryError) {
                // The replayed request re-enters this handler; a repeat 401 is
                // dealt with there as unrecoverable. Here we just propagate.
                _logError(retryError);
                return handler.next(retryError);
              }
            }
            // Refresh impossible (no/blank refresh token, or refresh rejected):
            // the session is dead → route the user to login.
            await _notifySessionExpired();
          } else if (_retryPolicy.isUnrecoverable(
            statusCode: status,
            path: path,
            alreadyRetried: alreadyRetried,
          )) {
            await _notifySessionExpired();
          }

          _logError(error);
          handler.next(error);
        },
      ),
    );
  }

  /// Resolved lazily so [ApiClient] can be constructed before these singletons
  /// are registered; null-safe for unit tests with no DI container.
  TokenRefresher? get _refresher =>
      sl.isRegistered<TokenRefresher>() ? sl<TokenRefresher>() : null;

  /// Strips the `Bearer ` prefix from an auth header value, so the refresher can
  /// tell whether the token this request used is still the current one.
  static String? _bearerOf(dynamic header) {
    if (header is! String || header.isEmpty) return null;
    const prefix = 'Bearer ';
    return header.startsWith(prefix) ? header.substring(prefix.length) : header;
  }

  Future<void> _notifySessionExpired() async {
    if (sl.isRegistered<SessionManager>()) {
      await sl<SessionManager>().notifyExpired();
    }
  }

  /// Debug-only diagnostic line. Never emitted in release builds, so request
  /// paths / IDs never reach device logs in production.
  void _log(String message) {
    if (kDebugMode) developer.log(message, name: 'API');
  }

  /// Logs the shape of a failed request — status only, never the response body
  /// (bodies can carry tokens, e.g. the refresh response).
  void _logError(DioException error) {
    if (!kDebugMode) return;
    developer.log(
      '✗ ${error.type.name} ${error.requestOptions.method} '
      '${error.requestOptions.path} '
      '— status=${error.response?.statusCode} ${error.message}',
      name: 'API',
    );
  }

  Future<Response> post(
    String path, {
    Map<String, dynamic>? data,
    Options? options,
  }) async {
    return _dio.post(path, data: data, options: options);
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.get(path, queryParameters: queryParameters, options: options);
  }

  Future<Response> put(String path, {Map<String, dynamic>? data}) async {
    return _dio.put(path, data: data);
  }

  Future<Response> delete(String path, {Options? options}) async {
    return _dio.delete(path, options: options);
  }
}
