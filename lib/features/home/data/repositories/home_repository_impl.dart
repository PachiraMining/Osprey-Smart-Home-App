import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/home_entity.dart';
import '../../domain/entities/home_device_entity.dart';
import '../../domain/entities/room_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';
import '../models/home_model.dart';
import '../models/room_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<HomeEntity>>> getHomes() async {
    try {
      final homes = await remoteDataSource.getHomes();
      return Right(homes);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Unauthorized', message: 'Session expired'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } catch (e) {
      return Left(ServerFailure('$e', message: 'Unknown error'));
    }
  }

  @override
  Future<Either<Failure, HomeEntity>> createHome({
    required String name,
    String? geoName,
    double? latitude,
    double? longitude,
    String? timezone,
  }) async {
    try {
      final body = HomeModel(
        id: '',
        name: name,
        geoName: geoName,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      ).toJson();
      final home = await remoteDataSource.createHome(body);
      return Right(home);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Unauthorized', message: 'Session expired'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } catch (e) {
      return Left(ServerFailure('$e', message: 'Unknown error'));
    }
  }

  @override
  Future<Either<Failure, HomeEntity>> updateHome({
    required String homeId,
    required String name,
    String? geoName,
    double? latitude,
    double? longitude,
    String? timezone,
  }) async {
    try {
      final body = HomeModel(
        id: homeId,
        name: name,
        geoName: geoName,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      ).toJson();
      final home = await remoteDataSource.updateHome(homeId, body);
      return Right(home);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Unauthorized', message: 'Session expired'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } catch (e) {
      return Left(ServerFailure('$e', message: 'Unknown error'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteHome(String homeId) async {
    try {
      await remoteDataSource.deleteHome(homeId);
      return const Right(null);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Unauthorized', message: 'Session expired'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } catch (e) {
      return Left(ServerFailure('$e', message: 'Unknown error'));
    }
  }

  @override
  Future<Either<Failure, List<HomeDeviceEntity>>> getHomeDevices(String homeId) async {
    try {
      final devices = await remoteDataSource.getHomeDevices(homeId);
      return Right(devices);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Unauthorized', message: 'Session expired'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } catch (e) {
      return Left(ServerFailure('$e', message: 'Unknown error'));
    }
  }

  @override
  Future<Either<Failure, void>> addDeviceToHome({
    required String homeId,
    required String deviceId,
  }) async {
    try {
      final body = {
        'deviceId': {'id': deviceId, 'entityType': 'DEVICE'},
      };
      await remoteDataSource.addDeviceToHome(homeId, body);
      return const Right(null);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Unauthorized', message: 'Session expired'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } catch (e) {
      return Left(ServerFailure('$e', message: 'Unknown error'));
    }
  }

  @override
  Future<Either<Failure, void>> updateHomeDevice({
    required String homeId,
    required String deviceId,
    String? roomId,
    String? deviceName,
    int? sortOrder,
  }) async {
    try {
      final body = <String, dynamic>{
        if (roomId != null) 'roomId': {'id': roomId, 'entityType': 'ROOM'},
        if (deviceName != null) 'deviceName': deviceName,
        if (sortOrder != null) 'sortOrder': sortOrder,
      };
      await remoteDataSource.updateHomeDevice(homeId, deviceId, body);
      return const Right(null);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Unauthorized', message: 'Session expired'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } catch (e) {
      return Left(ServerFailure('$e', message: 'Unknown error'));
    }
  }

  @override
  Future<Either<Failure, void>> removeDeviceFromHome({
    required String homeId,
    required String deviceId,
  }) async {
    try {
      await remoteDataSource.removeDeviceFromHome(homeId, deviceId);
      return const Right(null);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Unauthorized', message: 'Session expired'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } catch (e) {
      return Left(ServerFailure('$e', message: 'Unknown error'));
    }
  }

  @override
  Future<Either<Failure, List<RoomEntity>>> getRooms(String homeId) async {
    try {
      final rooms = await remoteDataSource.getRooms(homeId);
      return Right(rooms);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Unauthorized', message: 'Session expired'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } catch (e) {
      return Left(ServerFailure('$e', message: 'Unknown error'));
    }
  }

  @override
  Future<Either<Failure, RoomEntity>> createRoom({
    required String homeId,
    required String name,
    String? icon,
    int? sortOrder,
  }) async {
    try {
      final body = RoomModel(
        id: '',
        name: name,
        icon: icon,
        sortOrder: sortOrder ?? 0,
      ).toJson();
      final room = await remoteDataSource.createRoom(homeId, body);
      return Right(room);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Unauthorized', message: 'Session expired'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } catch (e) {
      return Left(ServerFailure('$e', message: 'Unknown error'));
    }
  }

  @override
  Future<Either<Failure, RoomEntity>> updateRoom({
    required String homeId,
    required String roomId,
    required String name,
    String? icon,
    int? sortOrder,
  }) async {
    try {
      final body = RoomModel(
        id: roomId,
        name: name,
        icon: icon,
        sortOrder: sortOrder ?? 0,
      ).toJson();
      final room = await remoteDataSource.updateRoom(homeId, roomId, body);
      return Right(room);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Unauthorized', message: 'Session expired'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } catch (e) {
      return Left(ServerFailure('$e', message: 'Unknown error'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRoom({
    required String homeId,
    required String roomId,
  }) async {
    try {
      await remoteDataSource.deleteRoom(homeId, roomId);
      return const Right(null);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Unauthorized', message: 'Session expired'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, message: e.message));
    } catch (e) {
      return Left(ServerFailure('$e', message: 'Unknown error'));
    }
  }
}
