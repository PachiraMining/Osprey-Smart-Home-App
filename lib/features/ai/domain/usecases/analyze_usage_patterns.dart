import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/automation_suggestion.dart';
import '../repositories/usage_pattern_repository.dart';

class AnalyzeUsagePatterns {
  final UsagePatternRepository _repo;

  AnalyzeUsagePatterns(this._repo);

  Future<Either<Failure, List<AutomationSuggestion>>> call({
    int lookbackDays = 30,
    int minOccurrences = 10,
  }) {
    return _repo.analyzePatterns(
      lookbackDays: lookbackDays,
      minOccurrences: minOccurrences,
    );
  }
}
