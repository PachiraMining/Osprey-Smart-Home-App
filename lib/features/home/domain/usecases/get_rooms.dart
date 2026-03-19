import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/room_entity.dart';
import '../repositories/home_repository.dart';

class GetRooms {
  final HomeRepository repository;
  GetRooms(this.repository);

  Future<Either<Failure, List<RoomEntity>>> call(String homeId) =>
      repository.getRooms(homeId);
}
