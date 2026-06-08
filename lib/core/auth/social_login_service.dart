// lib/core/auth/social_login_service.dart

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';

/// Describes one OAuth2 provider returned by the ThingsBoard mobile API.
class OAuth2ProviderInfo {
  final String name;

  /// The full URL to open in the browser to begin the OAuth2 flow.
  final String authorizationUrl;

  const OAuth2ProviderInfo({required this.name, required this.authorizationUrl});
}

/// Result of a completed social login flow.
class SocialLoginResult {
  final String token;
  final String refreshToken;

  const SocialLoginResult({required this.token, required this.refreshToken});
}

/// Handles the ThingsBoard OAuth2 / social-login flow.
///
/// Flow:
///   1. [fetchAvailableProviders] – GET mobile OAuth2 providers from server.
///   2. [loginWithProvider]       – Build a signed app-token JWT, open the
///      browser via FlutterWebAuth2, then parse the tokens from the callback.
class SocialLoginService {
  final http.Client _httpClient;

  SocialLoginService({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  // -------------------------------------------------------------------------
  // Public API
  // -------------------------------------------------------------------------

  /// Fetches the list of available OAuth2 providers from ThingsBoard.
  ///
  /// Returns an empty list when the server returns no providers or on error,
  /// so callers can gracefully hide the social-login section.
  Future<List<OAuth2ProviderInfo>> fetchAvailableProviders() async {
    final platform = Platform.isIOS ? 'IOS' : 'ANDROID';
    final uri = Uri.parse(
      '${AppConfig.thingsboardBaseUrl}/api/noauth/mobile'
      '?pkgName=${AppConfig.pkgName}&platform=$platform',
    );

    // ignore: avoid_print
    print('[OAuth] fetching providers from $uri');

    try {
      final response = await _httpClient.get(uri);
      // ignore: avoid_print
      print('[OAuth] response ${response.statusCode} body=${response.body.length > 200 ? response.body.substring(0, 200) : response.body}');
      if (response.statusCode != 200) {
        log('SocialLoginService: provider fetch failed (${response.statusCode})',
            name: 'SocialLoginService');
        return [];
      }

      final decoded = jsonDecode(response.body);
      // Server returns { "oAuth2ClientLoginInfos": [...] } or a direct list.
      final List<dynamic> clients;
      if (decoded is Map<String, dynamic>) {
        clients = (decoded['oAuth2ClientLoginInfos'] ?? []) as List<dynamic>;
      } else if (decoded is List) {
        clients = decoded;
      } else {
        // ignore: avoid_print
        print('[OAuth] unexpected response type: ${decoded.runtimeType}');
        return [];
      }
      // ignore: avoid_print
      print('[OAuth] found ${clients.length} providers');
      return clients
          .map((e) => _parseProvider(e as Map<String, dynamic>))
          .whereType<OAuth2ProviderInfo>()
          .toList();
    } catch (e) {
      // ignore: avoid_print
      print('[OAuth] fetchAvailableProviders error: $e');
      return [];
    }
  }

  /// Executes the full OAuth2 login flow for the given [providerAuthUrl].
  ///
  /// Builds a signed JWT app-token, appends it to the provider URL, launches
  /// the browser, then parses [AppConfig.callbackScheme]://* to extract the
  /// ThingsBoard access + refresh tokens.
  ///
  /// Throws a [SocialLoginException] on any failure.
  Future<SocialLoginResult> loginWithProvider(String providerAuthUrl) async {
    final appToken = _buildAppToken();
    final fullUrl = _appendAppToken(providerAuthUrl, appToken);

    log('SocialLoginService: opening browser for OAuth2\nURL: $fullUrl',
        name: 'SocialLoginService');

    try {
      final resultUrl = await FlutterWebAuth2.authenticate(
        url: fullUrl,
        callbackUrlScheme: AppConfig.callbackScheme,
      );

      return _parseCallbackUrl(resultUrl);
    } catch (e) {
      // FlutterWebAuth2 throws a PlatformException when the user cancels, or
      // an ArgumentError for invalid schemes. Wrap both as SocialLoginException.
      throw SocialLoginException('OAuth2 flow error: $e');
    }
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  OAuth2ProviderInfo? _parseProvider(Map<String, dynamic> json) {
    // ThingsBoard returns a list of provider objects. The exact field names
    // may vary by server version; we look for common variants.
    final name = (json['name'] ?? json['providerName'] ?? '') as String;
    final url = (json['url'] ??
            json['authorizationUrl'] ??
            json['loginUri'] ??
            '') as String;

    if (url.isEmpty) return null;
    // Server may return a relative URL like "/oauth2/authorization/..."
    final fullUrl = url.startsWith('http')
        ? url
        : '${AppConfig.thingsboardBaseUrl}$url';
    return OAuth2ProviderInfo(name: name, authorizationUrl: fullUrl);
  }

  /// Creates a short-lived JWT signed with the platform-specific app secret.
  ///
  /// Claims match the ThingsBoard mobile OAuth2 spec:
  ///   - iss  : package name
  ///   - callbackUrlScheme : callback URL scheme registered in the OS
  ///   - exp  : 4 minutes from now (server requires < 5 min)
  String _buildAppToken() {
    final secret = Platform.isIOS
        ? AppConfig.appSecretIos
        : AppConfig.appSecretAndroid;

    if (secret.isEmpty) {
      throw StateError(
        'OAuth app secret is not configured. Build with '
        '--dart-define=APP_SECRET_${Platform.isIOS ? "IOS" : "ANDROID"}=<value>. '
        'See docs/BUILD.md.',
      );
    }

    // Decode base64 secret to raw bytes for HMAC-SHA256.
    final Uint8List secretBytes = base64.decode(secret);

    // Build JWT manually to use raw secret bytes (dart_jsonwebtoken's
    // SecretKey uses utf8.encode internally which corrupts bytes > 127).
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final header = _base64UrlNoPad(utf8.encode(json.encode({
      'alg': 'HS256',
      'typ': 'JWT',
    })));

    final payload = _base64UrlNoPad(utf8.encode(json.encode({
      'callbackUrlScheme': AppConfig.callbackScheme,
      'iss': AppConfig.pkgName,
      'iat': now,
      'exp': now + 240, // 4 minutes
    })));

    final hmac = Hmac(sha256, secretBytes);
    final signature = _base64UrlNoPad(
      Uint8List.fromList(hmac.convert(utf8.encode('$header.$payload')).bytes),
    );

    final token = '$header.$payload.$signature';
    log('SocialLoginService: appToken generated, iss=${AppConfig.pkgName}',
        name: 'SocialLoginService');
    return token;
  }

  String _base64UrlNoPad(List<int> bytes) =>
      base64Url.encode(bytes).replaceAll('=', '');

  /// Appends pkg, platform, and appToken query parameters to [providerAuthUrl].
  String _appendAppToken(String providerAuthUrl, String appToken) {
    final platform = Platform.isIOS ? 'IOS' : 'ANDROID';
    final uri = Uri.parse(providerAuthUrl);
    final params = Map<String, String>.from(uri.queryParameters)
      ..['pkg'] = AppConfig.pkgName
      ..['platform'] = platform
      ..['appToken'] = appToken;
    return uri.replace(queryParameters: params).toString();
  }

  /// Extracts [accessToken] and [refreshToken] from the OAuth2 callback URL.
  ///
  /// ThingsBoard redirects to:
  ///   osprey://<host>?accessToken=<jwt>&refreshToken=<jwt>
  SocialLoginResult _parseCallbackUrl(String callbackUrl) {
    final uri = Uri.parse(callbackUrl);
    final accessToken = uri.queryParameters['accessToken'];
    final refreshToken = uri.queryParameters['refreshToken'];

    if (accessToken == null || accessToken.isEmpty) {
      throw SocialLoginException(
        'No accessToken found in callback URL. URL: $callbackUrl',
      );
    }

    return SocialLoginResult(
      token: accessToken,
      refreshToken: refreshToken ?? '',
    );
  }
}

/// Thrown when the social login flow fails at any step.
class SocialLoginException implements Exception {
  final String message;
  const SocialLoginException(this.message);

  @override
  String toString() => 'SocialLoginException: $message';
}
