import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';

import '../../../../core/error/failure.dart';
import '../../domain/repositories/foundation_model_repository.dart';
import '../datasources/foundation_models_datasource.dart';

class FoundationModelRepositoryImpl implements FoundationModelRepository {
  final FoundationModelsDataSource _ds;

  FoundationModelRepositoryImpl(this._ds);

  @override
  Future<bool> isAvailable() => _ds.isAvailable();

  @override
  Future<Either<Failure, String>> complete(String prompt) async {
    try {
      final out = await _ds.complete(prompt);
      return Right(out);
    } on PlatformException catch (e) {
      return Left(
        ServerFailure('FM_PLATFORM', message: e.message ?? 'Platform error'),
      );
    } on MissingPluginException {
      return const Left(
        ServerFailure('FM_MISSING', message: 'Foundation Models bridge not registered'),
      );
    }
  }
}
