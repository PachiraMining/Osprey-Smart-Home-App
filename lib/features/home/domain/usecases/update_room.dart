import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/room_entity.dart';
import '../repositories/home_repository.dart';

class UpdateRoom {
  final HomeRepository repository;
  UpdateRoom(this.repository);

  Future<Either<Failure, RoomEntity>> call({
    required String homeId,
    required String roomId,
    required String name,
    String? icon,
    int? sortOrder,
  }) =>
      repository.updateRoom(
        homeId: homeId,
        roomId: roomId,
        name: name,
        icon: icon,
        sortOrder: sortOrder,
      );
}
