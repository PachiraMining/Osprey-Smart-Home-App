/// Decides how the HTTP layer should react to a `401 Unauthorized`.
///
/// Pure decision logic, kept separate from Dio plumbing so the tricky branches
/// (don't refresh on a failed login, don't recurse on the refresh call, give up
/// after one retry) are unit-testable in isolation.
class AuthRetryPolicy {
  const AuthRetryPolicy({required this.refreshPath});

  final String refreshPath;

  /// Routes where a 401 means "bad credentials", not "expired session" — these
  /// must never trigger a token refresh. `/noauth/` is a ThingsBoard path
  /// segment (login/signup/otp); the refresh endpoint is matched exactly so a
  /// sibling like `/api/auth/token/validate` would not be excluded by accident.
  bool isAuthRoute(String path) =>
      path.contains('/noauth/') || path == refreshPath;

  /// First 401 on a protected route → try to refresh the access token.
  bool shouldAttemptRefresh({
    required int? statusCode,
    required String path,
    required bool alreadyRetried,
  }) =>
      statusCode == 401 && !alreadyRetried && !isAuthRoute(path);

  /// A request that already retried with a fresh token and still 401s → the
  /// session is dead; stop and send the user to login.
  bool isUnrecoverable({
    required int? statusCode,
    required String path,
    required bool alreadyRetried,
  }) =>
      statusCode == 401 && alreadyRetried && !isAuthRoute(path);
}
