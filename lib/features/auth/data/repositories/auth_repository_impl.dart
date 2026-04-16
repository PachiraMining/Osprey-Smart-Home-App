import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
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
      final response = await remoteDataSource.login(
        request.email,
        request.password,
      );

      return Right(response);
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = data is Map ? (data['message'] as String?) : null;
      return Left(ServerFailure(
        e.toString(),
        message: msg ?? 'Server error. Please try again.',
      ));
    } catch (e) {
      return Left(ServerFailure(
        e.toString(),
        message: 'An error occurred. Please try again.',
      ));
    }
  }
}
