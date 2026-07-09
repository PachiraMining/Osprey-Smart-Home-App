import 'dart:async';

import 'token_manager.dart';

/// Single source of truth for "the session is dead — send the user to login".
///
/// The network layer calls [notifyExpired] only after token refresh has been
/// exhausted. A root listener reacts to [onSessionExpired] to wipe navigation
/// and show the login screen. The flag is debounced so a burst of concurrent
/// 401s logs the user out exactly once.
class SessionManager {
  SessionManager(this._tokenManager);

  final TokenManager _tokenManager;
  final StreamController<void> _controller = StreamController<void>.broadcast();
  bool _expired = false;

  /// Fires once each time the session transitions to expired.
  Stream<void> get onSessionExpired => _controller.stream;

  bool get isExpired => _expired;

  /// Clears stored credentials and signals listeners — at most once until
  /// [reset] is called.
  Future<void> notifyExpired() async {
    if (_expired) return;
    _expired = true;
    await _tokenManager.clearTokens();
    if (!_controller.isClosed) _controller.add(null);
  }

  /// Re-arms the manager after a fresh login so a future expiry fires again.
  void reset() => _expired = false;

  void dispose() => _controller.close();
}
