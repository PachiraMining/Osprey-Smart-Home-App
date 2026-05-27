import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_curtain_app/core/error/failure.dart';
import 'package:smart_curtain_app/features/ai/domain/entities/voice_intent.dart';
import 'package:smart_curtain_app/features/ai/domain/repositories/foundation_model_repository.dart';
import 'package:smart_curtain_app/features/ai/domain/usecases/parse_voice_intent.dart';

class _MockFm extends Mock implements FoundationModelRepository {}

void main() {
  late _MockFm fm;
  late ParseVoiceIntent usecase;

  setUp(() {
    fm = _MockFm();
    usecase = ParseVoiceIntent(fm);
  });

  group('with Foundation Models available', () {
    setUp(() {
      when(() => fm.isAvailable()).thenAnswer((_) async => true);
    });

    test('parses LLM JSON output into VoiceIntent', () async {
      when(() => fm.complete(any())).thenAnswer((_) async => const Right(
            '{"device_hint":"bedroom","action":"set_position","position":50}',
          ));

      final result = await usecase('Open bedroom curtain fifty percent');

      expect(result.isRight(), isTrue);
      final intent = result.getOrElse(() => throw StateError('no intent'));
      expect(intent.deviceHint, 'bedroom');
      expect(intent.action, VoiceAction.setPosition);
      expect(intent.position, 50);
    });

    test('falls back to keyword parser when LLM returns garbage', () async {
      when(() => fm.complete(any())).thenAnswer((_) async => const Right('not json'));

      final result = await usecase('close the living room curtain');

      final intent = result.getOrElse(() => throw StateError('no intent'));
      expect(intent.action, VoiceAction.close);
      expect(intent.deviceHint, 'living room');
    });

    test('falls back when LLM call fails', () async {
      when(() => fm.complete(any()))
          .thenAnswer((_) async => const Left(ServerFailure('X', message: 'fail')));

      final result = await usecase('open');

      final intent = result.getOrElse(() => throw StateError('no intent'));
      expect(intent.action, VoiceAction.open);
    });
  });

  group('with Foundation Models unavailable', () {
    setUp(() {
      when(() => fm.isAvailable()).thenAnswer((_) async => false);
    });

    test('uses keyword fallback for set_position with %', () async {
      final result = await usecase('open bedroom 75%');
      final intent = result.getOrElse(() => throw StateError('no intent'));
      expect(intent.action, VoiceAction.setPosition);
      expect(intent.position, 75);
      expect(intent.deviceHint, 'bedroom');
      verifyNever(() => fm.complete(any()));
    });

    test('returns unknown action for empty transcript', () async {
      final result = await usecase('');
      final intent = result.getOrElse(() => throw StateError('no intent'));
      expect(intent.action, VoiceAction.unknown);
    });
  });
}
