import 'dart:convert';

/// Helpers for inspecting JWT access tokens locally (no signature check).
class JwtUtils {
  const JwtUtils._();

  /// Decodes the claims segment of [token], or returns null if [token] is not
  /// a structurally valid JWT.
  static Map<String, dynamic>? decodePayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return null;
    try {
      final decoded = utf8.decode(base64Url.decode(_pad(parts[1])));
      final payload = json.decode(decoded);
      return payload is Map<String, dynamic> ? payload : null;
    } catch (_) {
      return null;
    }
  }

  /// Whether [token] is already expired, or will expire within [leeway].
  ///
  /// Fails open (`false`) for tokens we cannot decode or that omit `exp`, so a
  /// real 401 is still left for the network layer to catch — we never lock a
  /// user out on a parsing quirk.
  static bool isExpired(
    String token, {
    Duration leeway = const Duration(seconds: 10),
  }) {
    final exp = decodePayload(token)?['exp'];
    // `exp` is seconds since epoch. Accept any JSON number — some token issuers
    // emit it as a double (e.g. 1.7e9) rather than an int.
    if (exp is! num) return false;
    final expiry = DateTime.fromMillisecondsSinceEpoch(
      (exp * 1000).toInt(),
      isUtc: true,
    );
    return DateTime.now().toUtc().add(leeway).isAfter(expiry);
  }

  /// Restores base64url padding stripped by JWT encoders so [base64Url.decode]
  /// accepts the segment.
  static String _pad(String segment) {
    final mod = segment.length % 4;
    return mod == 0 ? segment : segment + ('=' * (4 - mod));
  }
}
