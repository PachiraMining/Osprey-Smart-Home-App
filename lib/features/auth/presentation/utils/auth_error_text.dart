import 'package:dio/dio.dart';

/// Rút message thân thiện từ lỗi API auth (ThingsBoard trả
/// `{"status":..,"message":".."}`); fallback theo loại lỗi mạng.
String authErrorText(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return 'Network error. Check your connection and try again.';
      default:
        break;
    }
  }
  return 'Something went wrong. Please try again.';
}
