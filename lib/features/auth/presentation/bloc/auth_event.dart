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

class DeleteAccountEvent extends AuthEvent {
  final String? reason;
  DeleteAccountEvent({this.reason});
}

/// Signup trả JWT ngay trong response — lưu phiên luôn, không cần
/// gọi login lần 2.
class SessionTokensReceived extends AuthEvent {
  final String token;
  final String refreshToken;
  SessionTokensReceived({required this.token, required this.refreshToken});
}

/// Dispatched when the user taps a social login button (e.g. Google).
///
/// [providerUrl] is the authorization URL returned by the server's
/// /api/noauth/mobile endpoint for the chosen provider.
class SocialLoginRequested extends AuthEvent {
  final String providerUrl;
  SocialLoginRequested(this.providerUrl);
}
