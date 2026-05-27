import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../repositories/usage_pattern_repository.dart';

/// Records a single device action into the local usage log.
/// Called from device control pages immediately after a successful command.
class LogDeviceAction {
  final UsagePatternRepository _repo;

  LogDeviceAction(this._repo);

  Future<Either<Failure, Unit>> call({
    required String deviceId,
    required String command,
  }) {
    return _repo.logAction(
      deviceId: deviceId,
      command: command,
      at: DateTime.now(),
    );
  }
}
