import 'package:smart_curtain_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../../../../core/error/failure.dart';
import 'package:smart_curtain_app/features/auth/data/models/login_request_model.dart';
import 'package:smart_curtain_app/features/auth/data/models/login_response_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, LoginResponseModel>> login(
    LoginRequestModel request,
  ) async {
    try {
      // Gọi datasource
      final response = await remoteDataSource.login(
        request.email,
        request.password,
      );

      // Chuyển UserModel thành LoginResponseModel

      return Right(response);
    } catch (e) {
      return Left(ServerFailure(e.toString(), message: ''));
    }
  }
}
