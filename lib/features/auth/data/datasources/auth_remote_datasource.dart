// lib/features/auth/data/datasources/auth_remote_data_source.dart

import '../../../../core/network/api_client.dart';
import '../models/login_response_model.dart';
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

  Future<Map<String, dynamic>> requestAccountDeletion({String? reason}) async {
    final response = await apiClient.post(
      '/api/smarthome/auth/account/delete',
      data: {if (reason != null) 'reason': reason},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> cancelAccountDeletion() async {
    await apiClient.post('/api/smarthome/auth/account/delete/cancel');
  }

  Future<Map<String, dynamic>> getAccountDeletionStatus() async {
    final response = await apiClient.get('/api/smarthome/auth/account/delete/status');
    return response.data as Map<String, dynamic>;
  }
}
