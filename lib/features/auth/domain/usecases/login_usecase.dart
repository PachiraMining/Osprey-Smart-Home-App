import '../entities/user_entity.dart';
import 'package:dartz/dartz.dart';
import '../repositories/auth_repository.dart';
import '../../data/models/login_request_model.dart';
import '../../data/models/login_response_model.dart';
import '../../../../core/error/failure.dart';

class LoginUseCase {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  Future<Either<Failure, LoginResponseModel>> call(LoginRequestModel request) {
    return repository.login(request);
  }
}
