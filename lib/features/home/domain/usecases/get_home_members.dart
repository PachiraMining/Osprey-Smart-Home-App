import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/home_member_entity.dart';
import '../repositories/home_repository.dart';

class GetHomeMembers {
  final HomeRepository repository;

  GetHomeMembers(this.repository);

  Future<Either<Failure, List<HomeMemberEntity>>> call(String homeId) =>
      repository.getHomeMembers(homeId);
}
