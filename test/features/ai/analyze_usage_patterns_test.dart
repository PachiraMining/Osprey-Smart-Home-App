import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_curtain_app/features/ai/domain/entities/automation_suggestion.dart';
import 'package:smart_curtain_app/features/ai/domain/repositories/usage_pattern_repository.dart';
import 'package:smart_curtain_app/features/ai/domain/usecases/analyze_usage_patterns.dart';

class _MockRepo extends Mock implements UsagePatternRepository {}

void main() {
  late _MockRepo repo;
  late AnalyzeUsagePatterns usecase;

  setUp(() {
    repo = _MockRepo();
    usecase = AnalyzeUsagePatterns(repo);
  });

  test('delegates to repository with defaults', () async {
    when(() => repo.analyzePatterns(
          lookbackDays: any(named: 'lookbackDays'),
          minOccurrences: any(named: 'minOccurrences'),
        )).thenAnswer((_) async => const Right(<AutomationSuggestion>[]));

    final result = await usecase();

    expect(result.isRight(), isTrue);
    verify(() => repo.analyzePatterns(lookbackDays: 30, minOccurrences: 10))
        .called(1);
  });

  test('passes custom thresholds through', () async {
    when(() => repo.analyzePatterns(
          lookbackDays: any(named: 'lookbackDays'),
          minOccurrences: any(named: 'minOccurrences'),
        )).thenAnswer((_) async => const Right(<AutomationSuggestion>[]));

    await usecase(lookbackDays: 7, minOccurrences: 3);

    verify(() => repo.analyzePatterns(lookbackDays: 7, minOccurrences: 3))
        .called(1);
  });
}
