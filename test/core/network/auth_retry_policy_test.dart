import 'package:flutter_test/flutter_test.dart';
import 'package:smart_curtain_app/core/network/auth_retry_policy.dart';

void main() {
  final policy = AuthRetryPolicy(refreshPath: '/api/auth/token');

  group('shouldAttemptRefresh', () {
    test('true for a fresh 401 on a protected route', () {
      expect(
        policy.shouldAttemptRefresh(
          statusCode: 401,
          path: '/api/smarthome/devices',
          alreadyRetried: false,
        ),
        isTrue,
      );
    });

    test('false for non-401 responses', () {
      expect(
        policy.shouldAttemptRefresh(
          statusCode: 500,
          path: '/api/smarthome/devices',
          alreadyRetried: false,
        ),
        isFalse,
      );
    });

    test('false on a login/noauth route (bad credentials must not refresh)',
        () {
      expect(
        policy.shouldAttemptRefresh(
          statusCode: 401,
          path: '/api/noauth/smarthome/email/login',
          alreadyRetried: false,
        ),
        isFalse,
      );
    });

    test('false on the refresh endpoint itself (no recursion)', () {
      expect(
        policy.shouldAttemptRefresh(
          statusCode: 401,
          path: '/api/auth/token',
          alreadyRetried: false,
        ),
        isFalse,
      );
    });

    test('false once the request has already been retried', () {
      expect(
        policy.shouldAttemptRefresh(
          statusCode: 401,
          path: '/api/smarthome/devices',
          alreadyRetried: true,
        ),
        isFalse,
      );
    });
  });

  group('isUnrecoverable', () {
    test('true when a retried request still 401s on a protected route', () {
      expect(
        policy.isUnrecoverable(
          statusCode: 401,
          path: '/api/smarthome/devices',
          alreadyRetried: true,
        ),
        isTrue,
      );
    });

    test('false before any retry has happened', () {
      expect(
        policy.isUnrecoverable(
          statusCode: 401,
          path: '/api/smarthome/devices',
          alreadyRetried: false,
        ),
        isFalse,
      );
    });

    test('false for a 401 on a login/noauth route', () {
      expect(
        policy.isUnrecoverable(
          statusCode: 401,
          path: '/api/noauth/smarthome/email/login',
          alreadyRetried: true,
        ),
        isFalse,
      );
    });
  });
}
