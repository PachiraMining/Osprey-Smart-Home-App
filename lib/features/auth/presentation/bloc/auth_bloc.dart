import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_curtain_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:smart_curtain_app/features/auth/data/models/login_request_model.dart';
import 'package:smart_curtain_app/features/auth/data/datasources/auth_remote_datasource.dart';
import '../../../../core/auth/jwt_utils.dart';
import '../../../../core/auth/token_manager.dart';
import '../../../../core/auth/social_login_service.dart';
import '../../../../core/network/token_refresher.dart';
import '../../../../core/di/injector.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final TokenManager? tokenManager;
  final AuthRemoteDataSource? authDataSource;
  final SocialLoginService? socialLoginService;
  final TokenRefresher? tokenRefresher;

  AuthBloc({
    required this.loginUseCase,
    this.tokenManager,
    this.authDataSource,
    this.socialLoginService,
    this.tokenRefresher,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<DeleteAccountEvent>(_onDeleteAccount);
    on<SocialLoginRequested>(_onSocialLoginRequested);
    on<SessionTokensReceived>(_onSessionTokensReceived);
  }

  /// Lưu phiên từ JWT có sẵn (signup trả token ngay) rồi fetch profile.
  Future<void> _onSessionTokensReceived(
    SessionTokensReceived event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final tokenMgr = tokenManager ?? sl<TokenManager>();
      await tokenMgr.saveTokens(
        token: event.token,
        refreshToken: event.refreshToken,
      );
      tokenMgr.setCachedToken(event.token);

      try {
        final dataSource = authDataSource ?? sl<AuthRemoteDataSource>();
        final userResponse = await dataSource.getCurrentUser();
        await tokenMgr.saveCustomerId(userResponse.customerId);
        tokenMgr.setCachedCustomerId(userResponse.customerId);
        await tokenMgr.saveUserInfo(
          email: userResponse.email,
          firstName: userResponse.firstName,
          lastName: userResponse.lastName,
        );
      } catch (e) {
        // Profile fetch failure is non-fatal; tokens are already saved.
      }

      emit(AuthSuccess(token: event.token, refreshToken: event.refreshToken));
    } catch (e) {
      emit(AuthFailure('An error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await loginUseCase(
        LoginRequestModel(email: event.username, password: event.password),
      );

      await result.fold(
        (failure) async {
          emit(AuthFailure(failure.message));
        },
        (response) async {
          final tokenMgr = tokenManager ?? sl<TokenManager>();
          await tokenMgr.saveTokens(
            token: response.token,
            refreshToken: response.refreshToken,
          );
          tokenMgr.setCachedToken(response.token);
          try {
            final dataSource = authDataSource ?? sl<AuthRemoteDataSource>();
            final userResponse = await dataSource.getCurrentUser();
            await tokenMgr.saveCustomerId(userResponse.customerId);
            tokenMgr.setCachedCustomerId(userResponse.customerId);
            await tokenMgr.saveUserInfo(
              email: userResponse.email,
              firstName: userResponse.firstName,
              lastName: userResponse.lastName,
            );
          } catch (e) {
            // Could not fetch customerId after login
          }

          // TEMPORARY FIX - HARDCODE CUSTOMER ID ĐỂ TEST
          // print('⚠️ TEMPORARY: Hardcoding customerId for testing');
          // final testCustomerId =
          //     'ebbf0ff0-d000-11f0-aead-45eb9fccb1a3'; // ← Thay bằng customerId thật
          // await tokenMgr.saveCustomerId(testCustomerId);
          // tokenMgr.setCachedCustomerId(testCustomerId);
          // print('✅ Saved hardcoded customerId: $testCustomerId');

          emit(
            AuthSuccess(
              token: response.token,
              refreshToken: response.refreshToken,
            ),
          );
        },
      );
    } catch (e) {
      emit(AuthFailure('An error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    try {
      final tokenMgr = tokenManager ?? sl<TokenManager>();
      await tokenMgr.clearTokens();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthFailure('Logout error: ${e.toString()}'));
    }
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final tokenMgr = tokenManager ?? sl<TokenManager>();
      var token = await tokenMgr.getToken();

      final storedRefresh = await tokenMgr.getRefreshToken();

      // TEMP-AUTH-DIAG: on every cold start, log both tokens' expiry so we can
      // see (a) whether they survived storage and (b) their real server TTLs.
      print('🔑[AUTH-DIAG] cold-start access=${_diagExp(token)} '
          'refresh=${_diagExp(storedRefresh)}');

      // The REFRESH token — not the access token — is what decides whether the
      // session is still alive. The access token is short-lived (2.5h) and is
      // *expected* to be missing or expired on a cold start the next day; on
      // Android it can even read back null when EncryptedSharedPreferences hits
      // a transient decrypt miss after the process is killed. In all of those
      // cases we must recover through the refresh API rather than force a
      // re-login. Only a genuinely absent refresh token, or a refresh the server
      // rejects, means the session is truly over.
      final accessUsable =
          token != null && token.isNotEmpty && !JwtUtils.isExpired(token);

      if (!accessUsable) {
        final hasRefresh = storedRefresh != null && storedRefresh.isNotEmpty;
        final refresher = _resolveRefresher();
        final refreshed =
            hasRefresh && refresher != null && await refresher.tryRefresh();
        if (!refreshed) {
          // Wipe credentials only when we actually held a refresh token that the
          // server rejected — a transient storage read miss must not nuke
          // recoverable tokens (the next launch may read them fine).
          if (hasRefresh) await tokenMgr.clearTokens();
          emit(AuthInitial());
          return;
        }
        token = await tokenMgr.getToken();
        if (token == null || token.isEmpty) {
          emit(AuthInitial());
          return;
        }
      }

      final refreshToken = await tokenMgr.getRefreshToken();
      final customerId = await tokenMgr.getCustomerId();

      tokenMgr.setCachedToken(token);
      await tokenMgr.loadTokenToCache();

      if (customerId == null || customerId.isEmpty) {
        try {
          final dataSource = authDataSource ?? sl<AuthRemoteDataSource>();
          final userResponse = await dataSource.getCurrentUser();
          await tokenMgr.saveCustomerId(userResponse.customerId);
          tokenMgr.setCachedCustomerId(userResponse.customerId);
        } catch (e) {
          // Could not fetch customerId on app start
        }
      } else {
        tokenMgr.setCachedCustomerId(customerId);
      }

      emit(AuthSuccess(token: token, refreshToken: refreshToken ?? ''));
    } catch (e) {
      emit(AuthInitial());
    }
  }

  /// TEMP-AUTH-DIAG: compact "<state> ttl=Xd left=Yh" for a JWT, so cold-start
  /// logs show whether a token is expired and its real server lifetime.
  String _diagExp(String? token) {
    if (token == null || token.isEmpty) return '<empty>';
    final p = JwtUtils.decodePayload(token);
    if (p == null) return 'not-a-jwt';
    final exp = p['exp'];
    final iat = p['iat'];
    if (exp is! num) return 'no-exp';
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final ttl = iat is num ? ((exp - iat) / 86400).toStringAsFixed(2) : '?';
    final left = ((exp - now) / 3600).toStringAsFixed(1);
    return '${exp < now ? "EXPIRED" : "valid"}(ttl=${ttl}d,left=${left}h)';
  }

  /// Prefers the injected refresher (tests); falls back to the DI container.
  TokenRefresher? _resolveRefresher() {
    if (tokenRefresher != null) return tokenRefresher;
    return sl.isRegistered<TokenRefresher>() ? sl<TokenRefresher>() : null;
  }

  Future<void> _onDeleteAccount(
    DeleteAccountEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final tokenMgr = tokenManager ?? sl<TokenManager>();
      final dataSource = authDataSource ?? sl<AuthRemoteDataSource>();
      await dataSource.requestAccountDeletion(reason: event.reason);
      await tokenMgr.clearTokens();
      emit(AccountDeleted());
    } catch (e) {
      emit(AuthFailure('Failed to delete account: ${e.toString()}'));
    }
  }

  Future<void> _onSocialLoginRequested(
    SocialLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final service = socialLoginService ?? sl<SocialLoginService>();
      final result = await service.loginWithProvider(event.providerUrl);

      final tokenMgr = tokenManager ?? sl<TokenManager>();
      await tokenMgr.saveTokens(
        token: result.token,
        refreshToken: result.refreshToken,
      );
      tokenMgr.setCachedToken(result.token);

      // Fetch user profile (customerId, email, name) using the new token.
      try {
        final dataSource = authDataSource ?? sl<AuthRemoteDataSource>();
        final userResponse = await dataSource.getCurrentUser();
        await tokenMgr.saveCustomerId(userResponse.customerId);
        tokenMgr.setCachedCustomerId(userResponse.customerId);
        await tokenMgr.saveUserInfo(
          email: userResponse.email,
          firstName: userResponse.firstName,
          lastName: userResponse.lastName,
        );
      } catch (e) {
        // Profile fetch failure is non-fatal; tokens are already saved.
      }

      emit(AuthSuccess(token: result.token, refreshToken: result.refreshToken));
    } on SocialLoginException catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      emit(AuthFailure('Social login error: ${e.toString()}'));
    }
  }
}
