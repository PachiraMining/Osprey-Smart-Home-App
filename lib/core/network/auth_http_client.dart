import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../auth/session_manager.dart';
import '../config/app_config.dart';
import 'auth_retry_policy.dart';
import 'token_refresher.dart';

/// An [http.Client] wrapper that brings the Dio interceptor's silent
/// refresh-on-401 to data sources still on the `http` package (device list /
/// control, curtain page, ...).
///
/// It shares the SAME [TokenRefresher] singleton as the Dio stack, so a burst
/// of 401s across both stacks triggers exactly one refresh (single-flight); the
/// rest await that result and replay with the fresh token.
class AuthHttpClient extends http.BaseClient {
  AuthHttpClient({
    required http.Client inner,
    required TokenRefresher refresher,
    required SessionManager sessionManager,
    required String Function() freshToken,
    required String authHost,
    AuthRetryPolicy retryPolicy =
        const AuthRetryPolicy(refreshPath: AppConfig.refreshTokenPath),
  })  : _inner = inner,
        _refresher = refresher,
        _sessionManager = sessionManager,
        _freshToken = freshToken,
        _authHost = authHost,
        _retryPolicy = retryPolicy;

  final http.Client _inner;
  final TokenRefresher _refresher;
  final SessionManager _sessionManager;
  final String Function() _freshToken;

  /// Only 401s to this host trigger a refresh — external calls (e.g. weather)
  /// pass through untouched.
  final String _authHost;
  final AuthRetryPolicy _retryPolicy;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Buffer the body so the request can be replayed byte-for-byte after a
    // refresh (a finalized BaseRequest streams its body only once).
    final bodyBytes = await request.finalize().toBytes();

    final first = await _inner.send(_rebuild(request, bodyBytes));

    // Only step in for an expired-token 401 on our own backend. A 401 on a
    // login/refresh route means bad credentials, not an expired session.
    if (first.statusCode != 401 ||
        request.url.host != _authHost ||
        _retryPolicy.isAuthRoute(request.url.path)) {
      return first;
    }

    // Free the socket before replaying.
    await first.stream.drain<void>();

    // Pass the token this request actually used so a refresh already done by
    // another concurrent 401 isn't repeated (single-flight across both stacks).
    final refreshed =
        await _refresher.tryRefresh(staleToken: _usedToken(request));
    if (!refreshed) {
      // Refresh token expired/revoked → the session is truly dead.
      await _sessionManager.notifyExpired();
      return _synthetic401(request);
    }

    // Replay once with the fresh token; a second 401 is unrecoverable.
    final retry = await _inner.send(_rebuild(request, bodyBytes, replay: true));
    if (retry.statusCode == 401) {
      await retry.stream.drain<void>();
      await _sessionManager.notifyExpired();
      return _synthetic401(request);
    }
    return retry;
  }

  /// Rebuilds a fresh [http.Request] from [original] + buffered [body]. On a
  /// [replay] it overwrites `X-Authorization` with the freshly refreshed token.
  http.Request _rebuild(
    http.BaseRequest original,
    Uint8List body, {
    bool replay = false,
  }) {
    final req = http.Request(original.method, original.url)
      ..headers.addAll(original.headers)
      ..followRedirects = original.followRedirects
      ..maxRedirects = original.maxRedirects
      ..persistentConnection = original.persistentConnection
      ..bodyBytes = body;
    if (replay) {
      final token = _freshToken();
      if (token.isNotEmpty) req.headers['X-Authorization'] = 'Bearer $token';
    }
    return req;
  }

  /// The bearer token [request] sent, looked up case-insensitively since the
  /// `http` package may normalise header casing.
  String? _usedToken(http.BaseRequest request) {
    for (final entry in request.headers.entries) {
      if (entry.key.toLowerCase() == 'x-authorization') {
        const prefix = 'Bearer ';
        final v = entry.value;
        return v.startsWith(prefix) ? v.substring(prefix.length) : v;
      }
    }
    return null;
  }

  http.StreamedResponse _synthetic401(http.BaseRequest request) =>
      http.StreamedResponse(
        const Stream<List<int>>.empty(),
        401,
        request: request,
        reasonPhrase: 'Unauthorized',
      );

  @override
  void close() => _inner.close();
}
