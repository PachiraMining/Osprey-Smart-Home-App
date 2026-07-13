import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:smart_curtain_app/core/config/app_config.dart';
import 'package:smart_curtain_app/core/network/api_client.dart';
import 'package:smart_curtain_app/features/auth/data/datasources/auth_remote_datasource.dart';

class _MockApiClient extends Mock implements ApiClient {}

Response<dynamic> _resp(Object? data) => Response<dynamic>(
      requestOptions: RequestOptions(path: '/'),
      statusCode: 200,
      data: data,
    );

void main() {
  late _MockApiClient api;
  late AuthRemoteDataSource dataSource;

  setUp(() {
    api = _MockApiClient();
    dataSource = AuthRemoteDataSource(apiClient: api);
  });

  /// Captures the `data` map passed to the most recent `post`.
  Map<String, dynamic> capturedBody() {
    final captured = verify(
      () => api.post(any(), data: captureAny(named: 'data')),
    ).captured;
    return captured.last as Map<String, dynamic>;
  }

  test('login sends appKey and no tenantId', () async {
    when(() => api.post(any(), data: any(named: 'data'))).thenAnswer(
      (_) async => _resp({'token': 't', 'refreshToken': 'r'}),
    );

    await dataSource.login('a@b.com', 'pw');

    final body = capturedBody();
    expect(body['appKey'], AppConfig.appKey);
    expect(body.containsKey('tenantId'), isFalse);
  });

  test('sendSignupVerificationCode sends appKey and no tenantId', () async {
    when(() => api.post(any(), data: any(named: 'data')))
        .thenAnswer((_) async => _resp(null));

    await dataSource.sendSignupVerificationCode('a@b.com');

    final body = capturedBody();
    expect(body['appKey'], AppConfig.appKey);
    expect(body.containsKey('tenantId'), isFalse);
  });

  test('signup sends appKey and no tenantId', () async {
    when(() => api.post(any(), data: any(named: 'data'))).thenAnswer(
      (_) async => _resp({'token': 't', 'refreshToken': 'r'}),
    );

    await dataSource.signup(
      email: 'a@b.com',
      verificationCode: '123456',
      password: 'pw',
    );

    final body = capturedBody();
    expect(body['appKey'], AppConfig.appKey);
    expect(body.containsKey('tenantId'), isFalse);
  });
}
