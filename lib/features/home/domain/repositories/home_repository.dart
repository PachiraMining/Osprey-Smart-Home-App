import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/home_entity.dart';
import '../entities/home_device_entity.dart';
import '../entities/room_entity.dart';

abstract class HomeRepository {
  // Homes
  Future<Either<Failure, List<HomeEntity>>> getHomes();
  Future<Either<Failure, HomeEntity>> createHome({required String name, String? geoName, double? latitude, double? longitude, String? timezone});
  Future<Either<Failure, HomeEntity>> updateHome({required String homeId, required String name, String? geoName, double? latitude, double? longitude, String? timezone});
  Future<Either<Failure, void>> deleteHome(String homeId);

  // Home Devices
  Future<Either<Failure, List<HomeDeviceEntity>>> getHomeDevices(String homeId);
  Future<Either<Failure, void>> addDeviceToHome({required String homeId, required String deviceId});
  Future<Either<Failure, void>> updateHomeDevice({required String homeId, required String deviceId, String? roomId, String? deviceName, int? sortOrder});
  Future<Either<Failure, void>> removeDeviceFromHome({required String homeId, required String deviceId});

  // Rooms
  Future<Either<Failure, List<RoomEntity>>> getRooms(String homeId);
  Future<Either<Failure, RoomEntity>> createRoom({required String homeId, required String name, String? icon, int? sortOrder});
  Future<Either<Failure, RoomEntity>> updateRoom({required String homeId, required String roomId, required String name, String? icon, int? sortOrder});
  Future<Either<Failure, void>> deleteRoom({required String homeId, required String roomId});
}
