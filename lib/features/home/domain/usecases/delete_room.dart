import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../repositories/home_repository.dart';

class DeleteRoom {
  final HomeRepository repository;
  DeleteRoom(this.repository);

  Future<Either<Failure, void>> call({
    required String homeId,
    required String roomId,
  }) =>
      repository.deleteRoom(homeId: homeId, roomId: roomId);
}
