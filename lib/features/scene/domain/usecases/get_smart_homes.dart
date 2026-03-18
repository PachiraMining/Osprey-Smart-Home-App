import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/smart_home_entity.dart';
import '../repositories/tap_to_run_repository.dart';

class GetSmartHomes {
  final TapToRunRepository repository;
  GetSmartHomes(this.repository);

  Future<Either<Failure, List<SmartHomeEntity>>> call() async {
    return await repository.getSmartHomes();
  }
}
