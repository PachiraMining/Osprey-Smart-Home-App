import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_curtain_app/core/error/failure.dart';
import 'package:smart_curtain_app/features/ai/domain/repositories/foundation_model_repository.dart';
import 'package:smart_curtain_app/features/ai/domain/usecases/send_chat_message.dart';

class _MockFm extends Mock implements FoundationModelRepository {}

void main() {
  late _MockFm fm;
  late SendChatMessage usecase;

  setUp(() {
    fm = _MockFm();
    usecase = SendChatMessage(fm);
  });

  test('forwards reply from Foundation Models when available', () async {
    when(() => fm.isAvailable()).thenAnswer((_) async => true);
    when(() => fm.complete(any()))
        .thenAnswer((_) async => const Right('Sure — try the voice button.'));

    final result = await usecase('How do I open the curtains?');

    expect(result.isRight(), isTrue);
    expect(result.getOrElse(() => ''), contains('voice button'));
  });

  test('returns deterministic fallback when FM unavailable', () async {
    when(() => fm.isAvailable()).thenAnswer((_) async => false);

    final result = await usecase('hello');

    expect(result.isRight(), isTrue);
    expect(
      result.getOrElse(() => ''),
      contains('On-device AI'),
    );
    verifyNever(() => fm.complete(any()));
  });

  test('surfaces FM failure', () async {
    when(() => fm.isAvailable()).thenAnswer((_) async => true);
    when(() => fm.complete(any()))
        .thenAnswer((_) async => const Left(ServerFailure('X', message: 'rate limited')));

    final result = await usecase('hi');

    expect(result.isLeft(), isTrue);
  });
}
