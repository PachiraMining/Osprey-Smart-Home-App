import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/home_entity.dart';
import '../repositories/home_repository.dart';

class GetHomes {
  final HomeRepository repository;
  GetHomes(this.repository);

  Future<Either<Failure, List<HomeEntity>>> call() =>
      repository.getHomes();
}
