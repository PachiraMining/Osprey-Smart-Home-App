import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:smart_curtain_app/core/auth/social_login_service.dart';
import 'package:smart_curtain_app/core/auth/token_manager.dart';
import 'package:smart_curtain_app/core/error/failure.dart';
import 'package:smart_curtain_app/core/network/token_refresher.dart';
import 'package:smart_curtain_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:smart_curtain_app/features/auth/data/models/login_response_model.dart';
import 'package:smart_curtain_app/features/auth/data/models/user_response_model.dart';
import 'package:smart_curtain_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:smart_curtain_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_curtain_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:smart_curtain_app/features/auth/presentation/bloc/auth_state.dart';

import '../../../../helpers/fallback_values.dart';

class _MockLoginUseCase extends Mock implements LoginUseCase {}

class _MockTokenManager extends Mock implements TokenManager {}

class _MockAuthDataSource extends Mock implements AuthRemoteDataSource {}

class _MockSocialLoginService extends Mock implements SocialLoginService {}

class _MockTokenRefresher extends Mock implements TokenRefresher {}

/// Builds a fake JWT carrying [payload]; signature is irrelevant for expiry.
String _jwt(Map<String, dynamic> payload) {
  String seg(Map<String, dynamic> m) =>
      base64Url.encode(utf8.encode(json.encode(m))).replaceAll('=', '');
  return '${seg({'alg': 'HS256', 'typ': 'JWT'})}.${seg(payload)}.sig';
}

int _epoch(Duration fromNow) =>
    DateTime.now().add(fromNow).millisecondsSinceEpoch ~/ 1000;

void main() {
  setUpAll(registerCommonFallbacks);

  late _MockLoginUseCase loginUseCase;
  late _MockTokenManager tokenManager;
  late _MockAuthDataSource authDataSource;
  late _MockSocialLoginService socialLoginService;
  late _MockTokenRefresher tokenRefresher;

  AuthBloc buildBloc() => AuthBloc(
        loginUseCase: loginUseCase,
        tokenManager: tokenManager,
        authDataSource: authDataSource,
        socialLoginService: socialLoginService,
        tokenRefresher: tokenRefresher,
      );

  setUp(() {
    loginUseCase = _MockLoginUseCase();
    tokenManager = _MockTokenManager();
    authDataSource = _MockAuthDataSource();
    socialLoginService = _MockSocialLoginService();
    tokenRefresher = _MockTokenRefresher();

    when(() => tokenManager.saveTokens(
          token: any(named: 'token'),
          refreshToken: any(named: 'refreshToken'),
          customerId: any(named: 'customerId'),
        )).thenAnswer((_) async {});
    when(() => tokenManager.saveCustomerId(any())).thenAnswer((_) async {});
    when(() => tokenManager.saveUserInfo(
          email: any(named: 'email'),
          firstName: any(named: 'firstName'),
          lastName: any(named: 'lastName'),
        )).thenAnswer((_) async {});
    when(() => tokenManager.clearTokens()).thenAnswer((_) async {});
    when(() => tokenManager.loadTokenToCache()).thenAnswer((_) async {});
    when(() => tokenManager.setCachedToken(any())).thenReturn(null);
    when(() => tokenManager.setCachedCustomerId(any())).thenReturn(null);
  });

  const tToken = 'jwt-token';
  const tRefreshToken = 'refresh-token';
  const tCustomerId = 'customer-uuid';
  const tEmail = 'user@example.com';

  final tLoginResponse = LoginResponseModel(
    token: tToken,
    refreshToken: tRefreshToken,
  );
  final tUserResponse = UserResponseModel(
    userId: 'user-uuid',
    customerId: tCustomerId,
    email: tEmail,
    firstName: 'Thuan',
    lastName: 'Nguyen',
  );

  group('initial state', () {
    test('is AuthInitial', () {
      expect(buildBloc().state, isA<AuthInitial>());
    });
  });

  group('LoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSuccess] when login succeeds and profile fetch succeeds',
      build: () {
        when(() => loginUseCase(any()))
            .thenAnswer((_) async => Right(tLoginResponse));
        when(() => authDataSource.getCurrentUser())
            .thenAnswer((_) async => tUserResponse);
        return buildBloc();
      },
      act: (bloc) => bloc.add(LoginRequested(tEmail, 'pw')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthSuccess>()
            .having((s) => s.token, 'token', tToken)
            .having((s) => s.refreshToken, 'refreshToken', tRefreshToken),
      ],
      verify: (_) {
        verify(() => tokenManager.saveTokens(
              token: tToken,
              refreshToken: tRefreshToken,
            )).called(1);
        verify(() => tokenManager.saveCustomerId(tCustomerId)).called(1);
        verify(() => tokenManager.saveUserInfo(
              email: tEmail,
              firstName: 'Thuan',
              lastName: 'Nguyen',
            )).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'still emits AuthSuccess when profile fetch fails after successful login',
      build: () {
        when(() => loginUseCase(any()))
            .thenAnswer((_) async => Right(tLoginResponse));
        when(() => authDataSource.getCurrentUser())
            .thenThrow(Exception('profile fetch failed'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(LoginRequested(tEmail, 'pw')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthSuccess>(),
      ],
      verify: (_) {
        verify(() => tokenManager.saveTokens(
              token: tToken,
              refreshToken: tRefreshToken,
            )).called(1);
        verifyNever(() => tokenManager.saveCustomerId(any()));
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when use case returns Left',
      build: () {
        when(() => loginUseCase(any())).thenAnswer((_) async =>
            const Left(ServerFailure('err', message: 'invalid creds')));
        return buildBloc();
      },
      act: (bloc) => bloc.add(LoginRequested(tEmail, 'wrong')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthFailure>().having((s) => s.message, 'message', 'invalid creds'),
      ],
      verify: (_) {
        verifyNever(() => tokenManager.saveTokens(
              token: any(named: 'token'),
              refreshToken: any(named: 'refreshToken'),
            ));
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when use case throws',
      build: () {
        when(() => loginUseCase(any())).thenThrow(Exception('boom'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(LoginRequested(tEmail, 'pw')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthFailure>(),
      ],
    );
  });

  group('LogoutEvent', () {
    blocTest<AuthBloc, AuthState>(
      'clears tokens and emits AuthInitial',
      build: () => buildBloc(),
      act: (bloc) => bloc.add(LogoutEvent()),
      expect: () => [isA<AuthInitial>()],
      verify: (_) => verify(() => tokenManager.clearTokens()).called(1),
    );

    blocTest<AuthBloc, AuthState>(
      'emits AuthFailure when clearTokens throws',
      build: () {
        when(() => tokenManager.clearTokens())
            .thenThrow(Exception('storage error'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(LogoutEvent()),
      expect: () => [isA<AuthFailure>()],
    );
  });

  group('CheckAuthStatusEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits AuthSuccess when valid token exists and customerId is cached',
      build: () {
        when(() => tokenManager.getToken()).thenAnswer((_) async => tToken);
        when(() => tokenManager.getRefreshToken())
            .thenAnswer((_) async => tRefreshToken);
        when(() => tokenManager.getCustomerId())
            .thenAnswer((_) async => tCustomerId);
        return buildBloc();
      },
      act: (bloc) => bloc.add(CheckAuthStatusEvent()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthSuccess>().having((s) => s.token, 'token', tToken),
      ],
      verify: (_) {
        verifyNever(() => authDataSource.getCurrentUser());
      },
    );

    blocTest<AuthBloc, AuthState>(
      'fetches profile when customerId is missing but token exists',
      build: () {
        when(() => tokenManager.getToken()).thenAnswer((_) async => tToken);
        when(() => tokenManager.getRefreshToken())
            .thenAnswer((_) async => tRefreshToken);
        when(() => tokenManager.getCustomerId()).thenAnswer((_) async => null);
        when(() => authDataSource.getCurrentUser())
            .thenAnswer((_) async => tUserResponse);
        return buildBloc();
      },
      act: (bloc) => bloc.add(CheckAuthStatusEvent()),
      expect: () => [isA<AuthLoading>(), isA<AuthSuccess>()],
      verify: (_) {
        verify(() => tokenManager.saveCustomerId(tCustomerId)).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits AuthInitial when no token exists',
      build: () {
        when(() => tokenManager.getToken()).thenAnswer((_) async => null);
        when(() => tokenManager.getRefreshToken())
            .thenAnswer((_) async => null);
        when(() => tokenManager.getCustomerId())
            .thenAnswer((_) async => null);
        return buildBloc();
      },
      act: (bloc) => bloc.add(CheckAuthStatusEvent()),
      expect: () => [isA<AuthLoading>(), isA<AuthInitial>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits AuthInitial when storage throws',
      build: () {
        when(() => tokenManager.getToken()).thenThrow(Exception('storage'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(CheckAuthStatusEvent()),
      expect: () => [isA<AuthLoading>(), isA<AuthInitial>()],
    );

    blocTest<AuthBloc, AuthState>(
      'refreshes an expired token on startup and emits AuthSuccess with the new token',
      build: () {
        final expired = _jwt({'exp': _epoch(const Duration(hours: -1))});
        const freshToken = 'fresh-jwt';
        final returns = <String>[expired, freshToken];
        when(() => tokenManager.getToken())
            .thenAnswer((_) async => returns.removeAt(0));
        when(() => tokenManager.getRefreshToken())
            .thenAnswer((_) async => tRefreshToken);
        when(() => tokenManager.getCustomerId())
            .thenAnswer((_) async => tCustomerId);
        when(() => tokenRefresher.tryRefresh()).thenAnswer((_) async => true);
        return buildBloc();
      },
      act: (bloc) => bloc.add(CheckAuthStatusEvent()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthSuccess>().having((s) => s.token, 'token', 'fresh-jwt'),
      ],
      verify: (_) {
        verify(() => tokenRefresher.tryRefresh()).called(1);
        verifyNever(() => tokenManager.clearTokens());
      },
    );

    blocTest<AuthBloc, AuthState>(
      'clears tokens and emits AuthInitial when an expired token cannot be refreshed',
      build: () {
        final expired = _jwt({'exp': _epoch(const Duration(hours: -1))});
        when(() => tokenManager.getToken()).thenAnswer((_) async => expired);
        when(() => tokenManager.getRefreshToken())
            .thenAnswer((_) async => tRefreshToken);
        when(() => tokenManager.getCustomerId())
            .thenAnswer((_) async => tCustomerId);
        when(() => tokenRefresher.tryRefresh()).thenAnswer((_) async => false);
        return buildBloc();
      },
      act: (bloc) => bloc.add(CheckAuthStatusEvent()),
      expect: () => [isA<AuthLoading>(), isA<AuthInitial>()],
      verify: (_) {
        verify(() => tokenRefresher.tryRefresh()).called(1);
        verify(() => tokenManager.clearTokens()).called(1);
      },
    );
  });

  group('DeleteAccountEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AccountDeleted] on success',
      build: () {
        when(() => authDataSource.requestAccountDeletion(reason: 'test'))
            .thenAnswer((_) async => {'status': 'pending'});
        return buildBloc();
      },
      act: (bloc) => bloc.add(DeleteAccountEvent(reason: 'test')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AccountDeleted>(),
      ],
      verify: (_) {
        verify(() => tokenManager.clearTokens()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when deletion API throws',
      build: () {
        when(() => authDataSource.requestAccountDeletion(reason: any(named: 'reason')))
            .thenThrow(Exception('server error'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(DeleteAccountEvent()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthFailure>(),
      ],
      verify: (_) {
        verifyNever(() => tokenManager.clearTokens());
      },
    );
  });

  group('SocialLoginRequested', () {
    const tProviderUrl = 'https://oauth.example.com/google';

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSuccess] on successful social login',
      build: () {
        when(() => socialLoginService.loginWithProvider(tProviderUrl))
            .thenAnswer((_) async => const SocialLoginResult(
                  token: tToken,
                  refreshToken: tRefreshToken,
                ));
        when(() => authDataSource.getCurrentUser())
            .thenAnswer((_) async => tUserResponse);
        return buildBloc();
      },
      act: (bloc) => bloc.add(SocialLoginRequested(tProviderUrl)),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthSuccess>().having((s) => s.token, 'token', tToken),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'maps SocialLoginException.message to AuthFailure',
      build: () {
        when(() => socialLoginService.loginWithProvider(tProviderUrl))
            .thenThrow(const SocialLoginException('user cancelled'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(SocialLoginRequested(tProviderUrl)),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthFailure>()
            .having((s) => s.message, 'message', 'user cancelled'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits AuthFailure with generic message on unknown error',
      build: () {
        when(() => socialLoginService.loginWithProvider(tProviderUrl))
            .thenThrow(StateError('boom'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(SocialLoginRequested(tProviderUrl)),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthFailure>(),
      ],
    );
  });
}
