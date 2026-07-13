import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:smart_curtain_app/core/auth/token_manager.dart';
import 'package:smart_curtain_app/core/network/token_refresher.dart';

class _MockDio extends Mock implements Dio {}

class _MockTokenManager extends Mock implements TokenManager {}

Response<dynamic> _resp(Object? data, {int status = 200}) => Response<dynamic>(
      requestOptions: RequestOptions(path: '/api/auth/token'),
      statusCode: status,
      data: data,
    );

void main() {
  late _MockDio dio;
  late _MockTokenManager tokenManager;
  late TokenRefresher refresher;

  setUp(() {
    dio = _MockDio();
    tokenManager = _MockTokenManager();
    when(() => tokenManager.setCachedToken(any())).thenReturn(null);
    when(() => tokenManager.saveTokens(
          token: any(named: 'token'),
          refreshToken: any(named: 'refreshToken'),
        )).thenAnswer((_) async {});
    refresher = TokenRefresher(
      dio: dio,
      tokenManager: tokenManager,
      refreshPath: '/api/auth/token',
    );
  });

  test('returns false and makes no HTTP call when refresh token is empty',
      () async {
    when(() => tokenManager.getRefreshToken()).thenAnswer((_) async => '');

    final ok = await refresher.tryRefresh();

    expect(ok, isFalse);
    verifyNever(() => dio.post(any(), data: any(named: 'data')));
  });

  test('on success saves the new tokens and returns true', () async {
    when(() => tokenManager.getRefreshToken()).thenAnswer((_) async => 'old-rt');
    when(() => dio.post(any(), data: any(named: 'data'))).thenAnswer(
      (_) async => _resp({'token': 'new-jwt', 'refreshToken': 'new-rt'}),
    );

    final ok = await refresher.tryRefresh();

    expect(ok, isTrue);
    verify(() => tokenManager.saveTokens(
          token: 'new-jwt',
          refreshToken: 'new-rt',
        )).called(1);
    verify(() => tokenManager.setCachedToken('new-jwt')).called(1);
  });

  test('returns false when the server response carries no token', () async {
    when(() => tokenManager.getRefreshToken()).thenAnswer((_) async => 'old-rt');
    when(() => dio.post(any(), data: any(named: 'data')))
        .thenAnswer((_) async => _resp({'somethingElse': true}));

    final ok = await refresher.tryRefresh();

    expect(ok, isFalse);
    verifyNever(() => tokenManager.saveTokens(
          token: any(named: 'token'),
          refreshToken: any(named: 'refreshToken'),
        ));
  });

  test('returns false when the refresh request throws (e.g. 401)', () async {
    when(() => tokenManager.getRefreshToken()).thenAnswer((_) async => 'old-rt');
    when(() => dio.post(any(), data: any(named: 'data'))).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/api/auth/token'),
        response: _resp({'error': 'expired'}, status: 401),
      ),
    );

    final ok = await refresher.tryRefresh();

    expect(ok, isFalse);
  });

  test('invokes onRefreshed with the new access token after a successful refresh',
      () async {
    String? notified;
    final withCallback = TokenRefresher(
      dio: dio,
      tokenManager: tokenManager,
      refreshPath: '/api/auth/token',
      onRefreshed: (token) => notified = token,
    );
    when(() => tokenManager.getRefreshToken()).thenAnswer((_) async => 'old-rt');
    when(() => dio.post(any(), data: any(named: 'data'))).thenAnswer(
      (_) async => _resp({'token': 'new-jwt', 'refreshToken': 'new-rt'}),
    );

    final ok = await withCallback.tryRefresh();

    expect(ok, isTrue);
    expect(notified, 'new-jwt');
  });

  test('does not invoke onRefreshed when the refresh fails', () async {
    var called = false;
    final withCallback = TokenRefresher(
      dio: dio,
      tokenManager: tokenManager,
      refreshPath: '/api/auth/token',
      onRefreshed: (_) => called = true,
    );
    when(() => tokenManager.getRefreshToken()).thenAnswer((_) async => 'old-rt');
    when(() => dio.post(any(), data: any(named: 'data')))
        .thenAnswer((_) async => _resp({'somethingElse': true}));

    final ok = await withCallback.tryRefresh();

    expect(ok, isFalse);
    expect(called, isFalse);
  });

  test('skips the network refresh when the token already moved past staleToken',
      () async {
    // Another request already refreshed: the stored token differs from the one
    // this caller used, so no second POST /api/auth/token should be sent.
    when(() => tokenManager.getTokenSync()).thenReturn('already-new-jwt');

    final ok = await refresher.tryRefresh(staleToken: 'old-jwt');

    expect(ok, isTrue);
    verifyNever(() => dio.post(any(), data: any(named: 'data')));
  });

  test('still refreshes when staleToken matches the current token', () async {
    when(() => tokenManager.getTokenSync()).thenReturn('old-jwt');
    when(() => tokenManager.getRefreshToken()).thenAnswer((_) async => 'old-rt');
    when(() => dio.post(any(), data: any(named: 'data'))).thenAnswer(
      (_) async => _resp({'token': 'new-jwt', 'refreshToken': 'new-rt'}),
    );

    final ok = await refresher.tryRefresh(staleToken: 'old-jwt');

    expect(ok, isTrue);
    verify(() => dio.post(any(), data: any(named: 'data'))).called(1);
  });

  test('sequential 401s after a completed refresh trigger only one network call',
      () async {
    // First caller refreshes; once done, the cached token is the new one.
    var stored = 'old-jwt';
    when(() => tokenManager.getTokenSync()).thenAnswer((_) => stored);
    when(() => tokenManager.getRefreshToken()).thenAnswer((_) async => 'old-rt');
    when(() => tokenManager.setCachedToken(any())).thenAnswer((inv) {
      stored = inv.positionalArguments.first as String;
    });
    when(() => dio.post(any(), data: any(named: 'data'))).thenAnswer(
      (_) async => _resp({'token': 'new-jwt', 'refreshToken': 'new-rt'}),
    );

    // Caller A refreshes (token used == stored 'old-jwt').
    final a = await refresher.tryRefresh(staleToken: 'old-jwt');
    // Caller B's 401 arrives AFTER A finished; its token is now stale.
    final b = await refresher.tryRefresh(staleToken: 'old-jwt');

    expect(a, isTrue);
    expect(b, isTrue);
    verify(() => dio.post(any(), data: any(named: 'data'))).called(1);
  });

  test('coalesces concurrent calls into a single refresh request (single-flight)',
      () async {
    when(() => tokenManager.getRefreshToken()).thenAnswer((_) async => 'old-rt');
    when(() => dio.post(any(), data: any(named: 'data'))).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      return _resp({'token': 'new-jwt', 'refreshToken': 'new-rt'});
    });

    final results = await Future.wait([
      refresher.tryRefresh(),
      refresher.tryRefresh(),
      refresher.tryRefresh(),
    ]);

    expect(results, everyElement(isTrue));
    verify(() => dio.post(any(), data: any(named: 'data'))).called(1);
  });
}
