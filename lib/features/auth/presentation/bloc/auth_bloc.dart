import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_curtain_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:smart_curtain_app/features/auth/data/models/login_request_model.dart';
import 'package:smart_curtain_app/features/auth/data/datasources/auth_remote_datasource.dart';
import '../../../../core/auth/token_manager.dart';
import '../../../../core/di/injector.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final TokenManager? tokenManager;
  final AuthRemoteDataSource? authDataSource;

  AuthBloc({required this.loginUseCase, this.tokenManager, this.authDataSource})
    : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      print('🔐 Step 1: Calling login API...');
      final result = await loginUseCase(
        LoginRequestModel(email: event.username, password: event.password),
      );

      await result.fold(
        (failure) async {
          emit(AuthFailure(failure.message));
        },
        (response) async {
          print('✅ Step 2: Login success, got token');
          final tokenMgr = tokenManager ?? sl<TokenManager>();
          await tokenMgr.saveTokens(
            token: response.token,
            refreshToken: response.refreshToken,
          );
          tokenMgr.setCachedToken(response.token);
          print('✅ Step 3: Token saved');
          try {
            print('🔍 Step 4: Fetching customerId...');
            final dataSource = authDataSource ?? sl<AuthRemoteDataSource>();
            final userResponse = await dataSource.getCurrentUser();
            print('✅ Step 5: Got customerId: ${userResponse.customerId}');
            await tokenMgr.saveCustomerId(userResponse.customerId);
            tokenMgr.setCachedCustomerId(userResponse.customerId);
            print('✅ Step 6: CustomerId saved');
            print('✅ Login success - CustomerId: ${userResponse.customerId}');
          } catch (e) {
            print('❌ Step 4-6 FAILED: Could not fetch customerId: $e');
            print('❌ Error type: ${e.runtimeType}');
            print('❌ Error details: $e');
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
      print('❌ Unexpected error in login: $e');
      emit(AuthFailure('Đã xảy ra lỗi: ${e.toString()}'));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    try {
      final tokenMgr = tokenManager ?? sl<TokenManager>();
      await tokenMgr.clearTokens();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthFailure('Lỗi khi đăng xuất: ${e.toString()}'));
    }
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final tokenMgr = tokenManager ?? sl<TokenManager>();
      final token = await tokenMgr.getToken();
      final refreshToken = await tokenMgr.getRefreshToken();
      final customerId = await tokenMgr.getCustomerId();

      if (token != null && token.isNotEmpty) {
        tokenMgr.setCachedToken(token);

        if (customerId == null || customerId.isEmpty) {
          try {
            final dataSource = authDataSource ?? sl<AuthRemoteDataSource>();
            final userResponse = await dataSource.getCurrentUser();
            await tokenMgr.saveCustomerId(userResponse.customerId);
            tokenMgr.setCachedCustomerId(userResponse.customerId);
          } catch (e) {
            print('⚠️ Could not fetch customerId on app start');
          }
        } else {
          tokenMgr.setCachedCustomerId(customerId);
        }

        emit(AuthSuccess(token: token, refreshToken: refreshToken ?? ''));
      } else {
        emit(AuthInitial());
      }
    } catch (e) {
      emit(AuthInitial());
    }
  }
}
