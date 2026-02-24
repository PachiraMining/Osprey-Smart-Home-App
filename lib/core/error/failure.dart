// lib/core/error/failures.dart

import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(String string, {required this.message});

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.string, {required super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure(
    super.string, {
    super.message = 'Không có kết nối internet',
  });
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(
    super.string, {
    super.message = 'Phiên đăng nhập hết hạn',
  });
}
