// lib/features/auth/data/datasources/auth_remote_data_source.dart

import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_client.dart';
import '../models/login_response_model.dart';
import '../models/user_response_model.dart';

class AuthRemoteDataSource {
  final ApiClient apiClient;
  AuthRemoteDataSource({required this.apiClient});

  /// Đăng nhập CUSTOMER_USER theo brand (Tuya-pattern, multi-tenant).
  /// 401 "Invalid email or password" khi sai thông tin.
  Future<LoginResponseModel> login(String username, String password) async {
    final response = await apiClient.post(
      '/api/noauth/smarthome/email/login',
      data: {
        'email': username,
        'password': password,
        'tenantId': AppConfig.brandTenantId,
      },
    );

    return LoginResponseModel.fromJson(response.data);
  }

  Future<UserResponseModel> getCurrentUser() async {
    final response = await apiClient.get('/api/auth/user');
    return UserResponseModel.fromJson(response.data);
  }

  /// Gửi OTP 6 số tới [email] — bước 1 đăng ký CUSTOMER_USER của brand.
  /// 400 "Email is already registered for this brand" nếu email đã có.
  Future<void> sendSignupVerificationCode(String email) async {
    await apiClient.post(
      '/api/noauth/smarthome/email/send-otp',
      data: {'email': email, 'tenantId': AppConfig.brandTenantId},
    );
  }

  /// Verify OTP + tạo tài khoản CUSTOMER_USER, trả về JWT luôn
  /// (không cần login lần 2).
  Future<LoginResponseModel> signup({
    required String email,
    required String verificationCode,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    final response = await apiClient.post(
      '/api/noauth/smarthome/email/signup',
      data: {
        'email': email,
        'otp': verificationCode,
        'tenantId': AppConfig.brandTenantId,
        'password': password,
        if (firstName != null && firstName.isNotEmpty) 'firstName': firstName,
        if (lastName != null && lastName.isNotEmpty) 'lastName': lastName,
      },
    );
    return LoginResponseModel.fromJson(response.data);
  }

  /// Gửi email đặt lại mật khẩu. Backend luôn trả 200 (kể cả email không
  /// tồn tại) để tránh dò tài khoản.
  Future<void> requestPasswordReset(String email) async {
    await apiClient.post(
      '/api/noauth/resetPasswordByEmail',
      data: {'email': email},
    );
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
