import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:smart_curtain_app/core/auth/session_manager.dart';
import 'package:smart_curtain_app/core/auth/token_manager.dart';

class _MockTokenManager extends Mock implements TokenManager {}

void main() {
  late _MockTokenManager tokenManager;
  late SessionManager sessionManager;

  setUp(() {
    tokenManager = _MockTokenManager();
    when(() => tokenManager.clearTokens()).thenAnswer((_) async {});
    sessionManager = SessionManager(tokenManager);
  });

  tearDown(() => sessionManager.dispose());

  test('notifyExpired clears tokens and emits one event', () async {
    final events = <void>[];
    sessionManager.onSessionExpired.listen(events.add);

    await sessionManager.notifyExpired();
    await Future<void>.delayed(Duration.zero); // let the stream flush

    verify(() => tokenManager.clearTokens()).called(1);
    expect(events, hasLength(1));
    expect(sessionManager.isExpired, isTrue);
  });

  test('repeated notifyExpired only clears and emits once (debounced)',
      () async {
    final events = <void>[];
    sessionManager.onSessionExpired.listen(events.add);

    await sessionManager.notifyExpired();
    await sessionManager.notifyExpired();
    await sessionManager.notifyExpired();
    await Future<void>.delayed(Duration.zero);

    verify(() => tokenManager.clearTokens()).called(1);
    expect(events, hasLength(1));
  });

  test('reset re-arms the manager so a later expiry fires again', () async {
    final events = <void>[];
    sessionManager.onSessionExpired.listen(events.add);

    await sessionManager.notifyExpired();
    sessionManager.reset();
    expect(sessionManager.isExpired, isFalse);
    await sessionManager.notifyExpired();
    await Future<void>.delayed(Duration.zero);

    verify(() => tokenManager.clearTokens()).called(2);
    expect(events, hasLength(2));
  });
}
