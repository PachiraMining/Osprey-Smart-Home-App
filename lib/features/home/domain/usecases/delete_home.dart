import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../repositories/home_repository.dart';

class DeleteHome {
  final HomeRepository repository;
  DeleteHome(this.repository);

  Future<Either<Failure, void>> call(String homeId) =>
      repository.deleteHome(homeId);
}
