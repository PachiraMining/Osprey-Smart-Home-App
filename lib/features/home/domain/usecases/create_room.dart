import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/room_entity.dart';
import '../repositories/home_repository.dart';

class CreateRoom {
  final HomeRepository repository;
  CreateRoom(this.repository);

  Future<Either<Failure, RoomEntity>> call({
    required String homeId,
    required String name,
    String? icon,
    int? sortOrder,
  }) =>
      repository.createRoom(
        homeId: homeId,
        name: name,
        icon: icon,
        sortOrder: sortOrder,
      );
}
