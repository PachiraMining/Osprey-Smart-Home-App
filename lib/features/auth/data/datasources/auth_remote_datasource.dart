// lib/features/auth/data/datasources/auth_remote_data_source.dart

import '../../../../core/network/api_client.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import '../models/user_model.dart';
import '../models/user_response_model.dart';

class AuthRemoteDataSource {
  final ApiClient apiClient;
  AuthRemoteDataSource({required this.apiClient});

  Future<LoginResponseModel> login(String username, String password) async {
    final response = await apiClient.post(
      '/api/auth/login',
      data: {"username": username, "password": password},
    );

    return LoginResponseModel.fromJson(response.data);
  }

  Future<UserResponseModel> getCurrentUser() async {
    final response = await apiClient.get('/api/auth/user');
    return UserResponseModel.fromJson(response.data);
  }
}
