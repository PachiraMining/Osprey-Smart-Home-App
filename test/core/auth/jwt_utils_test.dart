import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_curtain_app/core/auth/jwt_utils.dart';

/// Builds a fake-but-structurally-valid JWT (`header.payload.sig`) carrying
/// [payload] as its claims. Signature is irrelevant for expiry decoding.
String _jwt(Map<String, dynamic> payload) {
  String seg(Map<String, dynamic> m) =>
      base64Url.encode(utf8.encode(json.encode(m))).replaceAll('=', '');
  final header = seg({'alg': 'HS256', 'typ': 'JWT'});
  return '$header.${seg(payload)}.sig';
}

int _epoch(Duration fromNow) =>
    (DateTime.now().add(fromNow).millisecondsSinceEpoch ~/ 1000);

void main() {
  group('JwtUtils.isExpired', () {
    test('returns true when exp is in the past', () {
      final token = _jwt({'exp': _epoch(const Duration(hours: -1))});
      expect(JwtUtils.isExpired(token), isTrue);
    });

    test('returns false when exp is comfortably in the future', () {
      final token = _jwt({'exp': _epoch(const Duration(hours: 1))});
      expect(JwtUtils.isExpired(token), isFalse);
    });

    test('treats a token expiring within the leeway window as expired', () {
      final token = _jwt({'exp': _epoch(const Duration(seconds: 5))});
      expect(
        JwtUtils.isExpired(token, leeway: const Duration(seconds: 30)),
        isTrue,
      );
    });

    test('handles an exp claim encoded as a double', () {
      final token = _jwt({'exp': _epoch(const Duration(hours: -1)).toDouble()});
      expect(JwtUtils.isExpired(token), isTrue);
    });

    test('fails open (false) for a malformed, non-JWT string', () {
      expect(JwtUtils.isExpired('not-a-jwt'), isFalse);
    });

    test('fails open (false) for an empty string', () {
      expect(JwtUtils.isExpired(''), isFalse);
    });

    test('fails open (false) when payload has no exp claim', () {
      final token = _jwt({'sub': 'user-123'});
      expect(JwtUtils.isExpired(token), isFalse);
    });
  });
}
