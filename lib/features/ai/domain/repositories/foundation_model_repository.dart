import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';

/// Bridges to Apple Foundation Models (iOS 26+) for on-device LLM completion.
///
/// Implementations must:
///   - return [false] from [isAvailable] on non-Apple-Intelligence-capable
///     hardware so the UI can fall back to deterministic logic;
///   - never throw — wrap errors as [ServerFailure] in the Either return.
abstract class FoundationModelRepository {
  Future<bool> isAvailable();

  Future<Either<Failure, String>> complete(String prompt);
}
