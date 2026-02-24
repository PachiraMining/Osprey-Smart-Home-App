// lib/core/network/api_client.dart
import 'package:dio/dio.dart';
import '../../core/auth/token_manager.dart';
import '../../core/di/injector.dart';

class ApiClient {
  final Dio _dio;
  ApiClient({required String baseUrl})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Content-Type': 'application/json',
            'accept': 'application/json',
          },
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = sl<TokenManager>().getTokenSync();
          if (token != null && token.isNotEmpty) {
            options.headers['X-Authorization'] = 'Bearer $token';
            print('Auto added token to request: ${options.uri}');
          } else {
            print('No token found for request: ${options.uri}');
          }
          handler.next(options);
        },
        onError: (error, handler) {
          print(
            'Dio Error: ${error.response?.statusCode} ${error.requestOptions.uri}',
          );
          print('Response body: ${error.response?.data}');
          handler.next(error);
        },
      ),
    );
  }

  Future<Response> post(String path, {Map<String, dynamic>? data}) async {
    return _dio.post(path, data: data);
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.get(path, queryParameters: queryParameters);
  }

  // thêm patch/put/delete nếu cần
}
