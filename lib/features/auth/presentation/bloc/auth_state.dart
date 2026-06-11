// lib/features/auth/presentation/bloc/auth_state.dart

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String token;
  final String refreshToken;

  AuthSuccess({required this.token, required this.refreshToken});
}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}

class AccountDeleted extends AuthState {}
