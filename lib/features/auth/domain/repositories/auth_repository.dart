import '../entities/user_entity.dart';
import 'package:smart_curtain_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:smart_curtain_app/features/auth/data/models/login_request_model.dart';
import 'package:smart_curtain_app/features/auth/data/models/login_response_model.dart';
import '../../../../core/error/failure.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  Future<Either<Failure, LoginResponseModel>> login(LoginRequestModel request);
}
