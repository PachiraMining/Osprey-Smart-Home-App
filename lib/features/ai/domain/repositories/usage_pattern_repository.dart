import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/automation_suggestion.dart';

abstract class UsagePatternRepository {
  /// Append a user-initiated device command to the local log.
  Future<Either<Failure, Unit>> logAction({
    required String deviceId,
    required String command,
    required DateTime at,
  });

  /// Analyse the last [lookbackDays] of logs and emit suggestions for
  /// patterns that occurred at least [minOccurrences] times.
  Future<Either<Failure, List<AutomationSuggestion>>> analyzePatterns({
    int lookbackDays = 30,
    int minOccurrences = 10,
  });
}
