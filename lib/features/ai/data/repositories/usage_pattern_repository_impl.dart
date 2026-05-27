import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/automation_suggestion.dart';
import '../../domain/repositories/usage_pattern_repository.dart';
import '../datasources/usage_pattern_local_datasource.dart';

class UsagePatternRepositoryImpl implements UsagePatternRepository {
  final UsagePatternLocalDataSource _ds;

  UsagePatternRepositoryImpl(this._ds);

  @override
  Future<Either<Failure, Unit>> logAction({
    required String deviceId,
    required String command,
    required DateTime at,
  }) async {
    try {
      await _ds.insert(deviceId: deviceId, command: command, at: at);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('LOG_FAILED', message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AutomationSuggestion>>> analyzePatterns({
    int lookbackDays = 30,
    int minOccurrences = 10,
  }) async {
    try {
      final rows = await _ds.queryRecent(lookbackDays: lookbackDays);
      // Group by (device_id, command, weekday, hour-bucket).
      final counts = <String, _Bucket>{};
      for (final r in rows) {
        final key = '${r['device_id']}|${r['command']}|${r['weekday']}|${r['hour']}';
        counts.update(
          key,
          (b) => b.copyAddOne(),
          ifAbsent: () => _Bucket(
            deviceId: r['device_id'] as String,
            command: r['command'] as String,
            weekday: r['weekday'] as int,
            hour: r['hour'] as int,
          ),
        );
      }

      final suggestions = counts.values
          .where((b) => b.count >= minOccurrences)
          .map((b) => AutomationSuggestion(
                deviceId: b.deviceId,
                deviceLabel: b.deviceId, // resolved in UI layer
                weekdays: [b.weekday],
                hour: b.hour,
                action: b.command,
                occurrences: b.count,
                confidence: (b.count / (lookbackDays * 1.0)).clamp(0.0, 1.0),
              ))
          .toList()
        ..sort((a, b) => b.occurrences.compareTo(a.occurrences));

      return Right(suggestions);
    } catch (e) {
      return Left(ServerFailure('ANALYZE_FAILED', message: e.toString()));
    }
  }
}

class _Bucket {
  final String deviceId;
  final String command;
  final int weekday;
  final int hour;
  final int count;

  _Bucket({
    required this.deviceId,
    required this.command,
    required this.weekday,
    required this.hour,
    this.count = 1,
  });

  _Bucket copyAddOne() => _Bucket(
        deviceId: deviceId,
        command: command,
        weekday: weekday,
        hour: hour,
        count: count + 1,
      );
}
