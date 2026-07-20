import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:smart_curtain_app/core/auth/token_manager.dart';
import 'package:smart_curtain_app/core/network/token_refresher.dart';
import 'package:smart_curtain_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:smart_curtain_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:smart_curtain_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_curtain_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:smart_curtain_app/features/auth/presentation/bloc/auth_state.dart';

class _MockTokenManager extends Mock implements TokenManager {}

class _MockTokenRefresher extends Mock implements TokenRefresher {}

class _MockLoginUseCase extends Mock implements LoginUseCase {}

class _MockAuthDataSource extends Mock implements AuthRemoteDataSource {}

/// Builds a structurally valid JWT whose `exp` is [secondsFromNow] away, so
/// JwtUtils.isExpired() (used by the bloc) treats it as valid/expired for real.
String _jwt(int secondsFromNow) {
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  String seg(String s) =>
      base64Url.encode(utf8.encode(s)).replaceAll('=', '');
  final header = seg('{"alg":"HS256","typ":"JWT"}');
  final payload = seg('{"exp":${now + secondsFromNow},"iat":$now}');
  return '$header.$payload.sig';
}

void main() {
  late _MockTokenManager tm;
  late _MockTokenRefresher refresher;

  AuthBloc build() => AuthBloc(
        loginUseCase: _MockLoginUseCase(),
        tokenManager: tm,
        authDataSource: _MockAuthDataSource(),
        tokenRefresher: refresher,
      );

  setUp(() {
    tm = _MockTokenManager();
    refresher = _MockTokenRefresher();
    // Neutral stubs shared by the happy paths.
    when(() => tm.getCustomerId()).thenAnswer((_) async => 'cid');
    when(() => tm.setCachedToken(any())).thenReturn(null);
    when(() => tm.setCachedCustomerId(any())).thenReturn(null);
    when(() => tm.loadTokenToCache()).thenAnswer((_) async {});
    when(() => tm.clearTokens()).thenAnswer((_) async {});
  });

  blocTest<AuthBloc, AuthState>(
    'cold start with NULL access token but a valid refresh token → refreshes '
    'via the API and enters the app (previously forced re-login)',
    build: () {
      var getTokenCalls = 0;
      when(() => tm.getToken()).thenAnswer((_) async =>
          getTokenCalls++ == 0 ? null : _jwt(3600)); // null, then fresh
      when(() => tm.getRefreshToken()).thenAnswer((_) async => 'valid-rt');
      when(() => refresher.tryRefresh(staleToken: any(named: 'staleToken')))
          .thenAnswer((_) async => true);
      when(() => refresher.tryRefresh()).thenAnswer((_) async => true);
      return build();
    },
    act: (bloc) => bloc.add(CheckAuthStatusEvent()),
    expect: () => [isA<AuthSuccess>()],
    verify: (_) {
      verify(() => refresher.tryRefresh()).called(1);
      verifyNever(() => tm.clearTokens());
    },
  );

  blocTest<AuthBloc, AuthState>(
    'cold start with expired access token + valid refresh → refreshes, no logout',
    build: () {
      var getTokenCalls = 0;
      when(() => tm.getToken()).thenAnswer((_) async =>
          getTokenCalls++ == 0 ? _jwt(-3600) : _jwt(3600)); // expired, then fresh
      when(() => tm.getRefreshToken()).thenAnswer((_) async => 'valid-rt');
      when(() => refresher.tryRefresh()).thenAnswer((_) async => true);
      return build();
    },
    act: (bloc) => bloc.add(CheckAuthStatusEvent()),
    expect: () => [isA<AuthSuccess>()],
    verify: (_) => verifyNever(() => tm.clearTokens()),
  );

  blocTest<AuthBloc, AuthState>(
    'refresh token present but server REJECTS refresh → clears tokens + login',
    build: () {
      when(() => tm.getToken()).thenAnswer((_) async => _jwt(-3600)); // expired
      when(() => tm.getRefreshToken()).thenAnswer((_) async => 'stale-rt');
      when(() => refresher.tryRefresh()).thenAnswer((_) async => false);
      return build();
    },
    act: (bloc) => bloc.add(CheckAuthStatusEvent()),
    expect: () => [isA<AuthInitial>()],
    verify: (_) => verify(() => tm.clearTokens()).called(1),
  );

  blocTest<AuthBloc, AuthState>(
    'no access AND no refresh token → login WITHOUT wiping (transient-read safe)',
    build: () {
      when(() => tm.getToken()).thenAnswer((_) async => null);
      when(() => tm.getRefreshToken()).thenAnswer((_) async => null);
      return build();
    },
    act: (bloc) => bloc.add(CheckAuthStatusEvent()),
    expect: () => [isA<AuthInitial>()],
    verify: (_) {
      verifyNever(() => refresher.tryRefresh());
      verifyNever(() => tm.clearTokens());
    },
  );
}
