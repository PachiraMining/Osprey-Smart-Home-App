import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

import 'package:smart_curtain_app/core/auth/session_manager.dart';
import 'package:smart_curtain_app/core/network/auth_http_client.dart';
import 'package:smart_curtain_app/core/network/token_refresher.dart';

class _MockRefresher extends Mock implements TokenRefresher {}

class _MockSessionManager extends Mock implements SessionManager {}

/// Inner client that returns queued responses in order and records what it got.
class _FakeInner extends http.BaseClient {
  _FakeInner(this._responses);
  final List<http.Response> _responses;
  final List<http.Request> sent = [];
  int _i = 0;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    sent.add(request as http.Request);
    final r = _responses[_i++];
    return http.StreamedResponse(
      Stream.value(utf8.encode(r.body)),
      r.statusCode,
      request: request,
      reasonPhrase: r.reasonPhrase,
    );
  }
}

const _host = 'performentmarketing.ddnsgeek.com';
Uri _protected() => Uri.parse('https://$_host/api/rpc/oneway/dev1');

void main() {
  late _MockRefresher refresher;
  late _MockSessionManager session;

  setUp(() {
    refresher = _MockRefresher();
    session = _MockSessionManager();
    when(() => session.notifyExpired()).thenAnswer((_) async {});
  });

  AuthHttpClient build(_FakeInner inner) => AuthHttpClient(
        inner: inner,
        refresher: refresher,
        sessionManager: session,
        freshToken: () => 'new-jwt',
        authHost: _host,
      );

  test('passes a 200 through without refreshing', () async {
    final inner = _FakeInner([http.Response('ok', 200)]);
    final client = build(inner);

    final resp = await client.post(_protected(), body: 'x');

    expect(resp.statusCode, 200);
    verifyNever(() => refresher.tryRefresh(staleToken: any(named: 'staleToken')));
    expect(inner.sent.length, 1);
  });

  test('on 401 refreshes once and replays with the fresh token', () async {
    when(() => refresher.tryRefresh(staleToken: any(named: 'staleToken'))).thenAnswer((_) async => true);
    final inner = _FakeInner([
      http.Response('nope', 401),
      http.Response('done', 200),
    ]);
    final client = build(inner);

    final resp = await client.post(
      _protected(),
      headers: {'X-Authorization': 'Bearer stale'},
      body: 'x',
    );

    expect(resp.statusCode, 200);
    verify(() => refresher.tryRefresh(staleToken: any(named: 'staleToken'))).called(1);
    expect(inner.sent.length, 2);
    // Retry carries the refreshed token, not the stale one.
    expect(inner.sent[1].headers['X-Authorization'], 'Bearer new-jwt');
    // Original body is preserved on replay.
    expect(inner.sent[1].body, 'x');
    verifyNever(() => session.notifyExpired());
  });

  test('when refresh fails, notifies session expiry and returns 401', () async {
    when(() => refresher.tryRefresh(staleToken: any(named: 'staleToken'))).thenAnswer((_) async => false);
    final inner = _FakeInner([http.Response('nope', 401)]);
    final client = build(inner);

    final resp = await client.post(_protected(), body: 'x');

    expect(resp.statusCode, 401);
    verify(() => refresher.tryRefresh(staleToken: any(named: 'staleToken'))).called(1);
    verify(() => session.notifyExpired()).called(1);
    expect(inner.sent.length, 1);
  });

  test('when the replay still 401s, notifies expiry (unrecoverable)', () async {
    when(() => refresher.tryRefresh(staleToken: any(named: 'staleToken'))).thenAnswer((_) async => true);
    final inner = _FakeInner([
      http.Response('nope', 401),
      http.Response('still nope', 401),
    ]);
    final client = build(inner);

    final resp = await client.post(_protected(), body: 'x');

    expect(resp.statusCode, 401);
    verify(() => session.notifyExpired()).called(1);
    expect(inner.sent.length, 2);
  });

  test('does not refresh a 401 on a noauth/login route', () async {
    final inner = _FakeInner([http.Response('bad creds', 401)]);
    final client = build(inner);

    final resp = await client.post(
      Uri.parse('https://$_host/api/noauth/smarthome/email/login'),
      body: 'x',
    );

    expect(resp.statusCode, 401);
    verifyNever(() => refresher.tryRefresh(staleToken: any(named: 'staleToken')));
    verifyNever(() => session.notifyExpired());
  });

  test('does not refresh a 401 from a different host', () async {
    final inner = _FakeInner([http.Response('nope', 401)]);
    final client = build(inner);

    final resp =
        await client.get(Uri.parse('https://weather.example.com/api/current'));

    expect(resp.statusCode, 401);
    verifyNever(() => refresher.tryRefresh(staleToken: any(named: 'staleToken')));
  });
}
