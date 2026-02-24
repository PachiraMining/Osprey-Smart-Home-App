// lib/features/auth/presentation/bloc/auth_event.dart
abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String username;
  final String password;
  LoginRequested(this.username, this.password);
}

// THÊM MỚI
class LogoutEvent extends AuthEvent {}

class CheckAuthStatusEvent extends AuthEvent {}
