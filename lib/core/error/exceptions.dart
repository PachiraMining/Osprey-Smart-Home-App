// lib/core/error/exceptions.dart

class ServerException implements Exception {
  final String message;

  ServerException({this.message = 'Server error occurred'});
}

class NetworkException implements Exception {
  final String message;

  NetworkException({this.message = 'Network error occurred'});
}

class CacheException implements Exception {
  final String message;

  CacheException({this.message = 'Cache error occurred'});
}

class UnauthorizedException implements Exception {
  final String message;

  UnauthorizedException({this.message = 'Unauthorized access'});
}

/// Backend trả 400 "Scene is disabled" (errorCode 31) khi execute scene
/// đang tắt — caller có thể enable rồi thử lại đúng MỘT lần.
class SceneDisabledException implements Exception {
  final String message;

  SceneDisabledException({this.message = 'Scene is disabled'});
}
