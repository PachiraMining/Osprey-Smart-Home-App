import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_challenge_response_model.dart';
import '../models/osprey_product_model.dart';
import '../models/pairing_token_model.dart';

/// REST API cho pairing flow — endpoints dưới `/api/smarthome/`
/// (backend branch `feature/ble-provisioning`, đã live trên dev server).
abstract class PairingRemoteDataSource {
  /// `GET /products` — toàn bộ catalog SKU (app pre-cache).
  Future<List<OspreyProductModel>> getProducts();

  /// `GET /products/by-hash/{hex}` — fallback khi hash chưa có trong cache.
  /// Trả null nếu 404 (product chưa đăng ký).
  Future<OspreyProductModel?> getProductByHash(String hashHex);

  /// `POST /pairing/auth-challenge` — lấy HMAC + session key.
  Future<AuthChallengeResponseModel> requestAuthChallenge({
    required String deviceUuid,
    required String nonceAppHex,
  });

  /// `POST /pairing/token` — sinh pairing token 8 ký tự (TTL 15 phút).
  Future<PairingTokenModel> createPairingToken({
    required String deviceProfileId,
    required String smartHomeId,
    String? roomId,
    required String deviceUuid,
  });

  /// `GET /pairing/token/{token}` — poll status PENDING → PAIRED.
  Future<PairingTokenModel> getPairingTokenStatus(String token);
}

class PairingRemoteDataSourceImpl implements PairingRemoteDataSource {
  final ApiClient apiClient;

  PairingRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<OspreyProductModel>> getProducts() async {
    try {
      final response = await apiClient.get('/api/smarthome/products');
      final List<dynamic> data = response.data is List ? response.data : [];
      return data
          .map((json) =>
              OspreyProductModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapError(e, 'Không tải được danh sách sản phẩm');
    }
  }

  @override
  Future<OspreyProductModel?> getProductByHash(String hashHex) async {
    try {
      final response =
          await apiClient.get('/api/smarthome/products/by-hash/$hashHex');
      return OspreyProductModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _mapError(e, 'Không tra cứu được sản phẩm');
    }
  }

  @override
  Future<AuthChallengeResponseModel> requestAuthChallenge({
    required String deviceUuid,
    required String nonceAppHex,
  }) async {
    try {
      final response = await apiClient.post(
        '/api/smarthome/pairing/auth-challenge',
        data: {
          'deviceUuid': deviceUuid,
          'nonceApp': nonceAppHex,
        },
      );
      return AuthChallengeResponseModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw ServerException(
            message: 'Thiết bị chưa được đăng ký trong hệ thống '
                '(DEVICE_NOT_REGISTERED)');
      }
      if (e.response?.statusCode == 429) {
        throw ServerException(
            message: 'Thử lại quá nhiều lần — vui lòng đợi 1 phút');
      }
      throw _mapError(e, 'Không lấy được mã xác thực thiết bị');
    }
  }

  @override
  Future<PairingTokenModel> createPairingToken({
    required String deviceProfileId,
    required String smartHomeId,
    String? roomId,
    required String deviceUuid,
  }) async {
    try {
      final response = await apiClient.post(
        '/api/smarthome/pairing/token',
        data: {
          'deviceProfileId': {
            'entityType': 'DEVICE_PROFILE',
            'id': deviceProfileId,
          },
          'smartHomeId': {
            'entityType': 'SMART_HOME',
            'id': smartHomeId,
          },
          if (roomId != null && roomId.isNotEmpty) 'roomId': roomId,
          'pairingData': {'deviceUuid': deviceUuid},
        },
      );
      return PairingTokenModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e, 'Không tạo được pairing token');
    }
  }

  @override
  Future<PairingTokenModel> getPairingTokenStatus(String token) async {
    try {
      final response =
          await apiClient.get('/api/smarthome/pairing/token/$token');
      return PairingTokenModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e, 'Không kiểm tra được trạng thái pairing');
    }
  }

  Exception _mapError(DioException e, String prefix) {
    if (e.response?.statusCode == 401) {
      return UnauthorizedException();
    }
    return ServerException(
        message: '$prefix: ${e.response?.data ?? e.message}');
  }
}
