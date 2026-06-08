import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/discovered_osprey_device.dart';
import '../../domain/entities/osprey_product.dart';
import '../../domain/entities/pairing_progress.dart';
import '../../domain/repositories/pairing_repository.dart';
import '../../pairing_constants.dart';
import '../crypto/hex_utils.dart';
import '../crypto/pairing_crypto.dart';
import '../datasources/ble_pairing_datasource.dart';
import '../datasources/osprey_adv_parser.dart';
import '../datasources/pairing_remote_datasource.dart';
import '../datasources/product_catalog_cache.dart';
import '../models/osprey_product_model.dart';

/// Orchestrate pairing flow đầy đủ theo sequence diagram spec §4.2.
class PairingRepositoryImpl implements PairingRepository {
  final PairingRemoteDataSource remoteDataSource;
  final BlePairingDataSource bleDataSource;
  final ProductCatalogCache catalogCache;
  final PairingCrypto crypto;

  /// Lấy smartHomeId hiện tại (TokenManager.getHomeIdSync qua DI).
  final String Function() getSmartHomeId;

  PairingRepositoryImpl({
    required this.remoteDataSource,
    required this.bleDataSource,
    required this.catalogCache,
    required this.crypto,
    required this.getSmartHomeId,
  });

  // Catalog đang giữ trong RAM cho phiên scan hiện tại.
  List<OspreyProductModel> _catalog = const [];

  @override
  Future<Either<Failure, List<OspreyProduct>>> getProductCatalog({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final fresh = catalogCache.getFresh();
      if (fresh != null) {
        _catalog = fresh;
        return Right(fresh);
      }
    }
    try {
      final products = await remoteDataSource.getProducts();
      await catalogCache.save(products);
      _catalog = products;
      return Right(products);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message, message: e.message));
    } on ServerException catch (e) {
      // Backend lỗi/offline → fallback cache cũ nếu có
      final stale = catalogCache.getStale();
      if (stale != null) {
        _catalog = stale;
        return Right(stale);
      }
      return Left(ServerFailure(e.message, message: e.message));
    }
  }

  @override
  Future<void> startScan() => bleDataSource.startScan();

  @override
  Future<void> stopScan() => bleDataSource.stopScan();

  @override
  Stream<List<DiscoveredOspreyDevice>> scanForDevices() {
    return bleDataSource.scanResults.map((results) {
      final devices = <DiscoveredOspreyDevice>[];
      for (final r in results) {
        final raw = r.advertisementData
            .manufacturerData[PairingConstants.manufacturerCompanyId];
        if (raw == null) continue;

        final advData = OspreyAdvParser.parse(raw);
        if (advData == null) continue;
        // Device đã paired → skip khỏi danh sách "Add Device"
        if (advData.isPaired) continue;

        final product = _findProductByHash(advData.productIdHashHex);
        devices.add(DiscoveredOspreyDevice(
          remoteId: r.device.remoteId.str,
          name: r.advertisementData.advName.isNotEmpty
              ? r.advertisementData.advName
              : r.device.platformName,
          rssi: r.rssi,
          advData: advData,
          product: product,
        ));
      }
      // Tín hiệu mạnh hiển thị trước
      devices.sort((a, b) => b.rssi.compareTo(a.rssi));
      return devices;
    });
  }

  @override
  Stream<PairingProgress> pairDevice({
    required DiscoveredOspreyDevice device,
    required String ssid,
    required String wifiPassword,
    String? roomId,
  }) async* {
    try {
      final smartHomeId = getSmartHomeId();
      if (smartHomeId.isEmpty) {
        throw ServerException(
            message: 'Chưa chọn nhà — vui lòng tạo/chọn nhà trước khi '
                'thêm thiết bị');
      }

      // ── 1. Connect + READ DEVICE_UUID (disarm watchdog) ──────
      // Firmware watchdog 30s armed lúc connect, DISARM ngay khi app
      // READ char DEVICE_UUID — sau đó gọi backend bao lâu cũng được.
      yield const PairingProgress(PairingStep.connecting);
      await bleDataSource.openSession(device.remoteId);
      final deviceUuid = await bleDataSource.readDeviceUuid();

      // ── 2. Backend: auth-challenge + pairing token ───────────
      yield const PairingProgress(PairingStep.requestingToken);
      final nonceApp = crypto.generateNonce();
      final authResp = await remoteDataSource.requestAuthChallenge(
        deviceUuid: deviceUuid,
        nonceAppHex: HexUtils.encode(nonceApp),
      );
      final deviceProfileId = authResp.deviceProfileId.isNotEmpty
          ? authResp.deviceProfileId
          : (device.product?.deviceProfileId ?? '');
      if (deviceProfileId.isEmpty) {
        throw ServerException(
            message: 'Không xác định được device profile của sản phẩm');
      }
      final tokenResp = await remoteDataSource.createPairingToken(
        deviceProfileId: deviceProfileId,
        smartHomeId: smartHomeId,
        roomId: roomId,
        deviceUuid: deviceUuid,
      );

      // ── 3. Mutual auth qua AUTH_CHALLENGE ────────────────────
      yield const PairingProgress(PairingStep.authenticating);
      final authPayload = crypto.buildAuthChallengePayload(
        nonceApp: nonceApp,
        hmacExpected: HexUtils.decode(authResp.hmacExpectedHex),
      );
      await bleDataSource.writeAuthChallengeAndAwaitOk(authPayload);

      // ── 4. Encrypt + gửi WiFi credentials ────────────────────
      yield const PairingProgress(PairingStep.sendingWifiCredentials);
      final pairingJson = <String, dynamic>{
        'token': tokenResp.token,
        'ssid': ssid,
        'password': wifiPassword,
        'mqtt_url': AppConfig.deviceMqttUrl,
        'http_api_base_url': AppConfig.deviceHttpApiBaseUrl,
        'tb_provision_key': authResp.tbProvisionKey,
        'tb_provision_secret': authResp.tbProvisionSecret,
      };
      final ciphertext = crypto.encryptPairingData(
        sessionKey: HexUtils.decode(authResp.sessionKeyHex),
        plaintext: utf8.encode(jsonEncode(pairingJson)),
      );
      await bleDataSource.writePairingDataAndAwaitOk(ciphertext);

      // ── 5. Disconnect BLE, poll backend đến khi PAIRED ───────
      await bleDataSource.closeSession();
      yield const PairingProgress(PairingStep.waitingForDevice);
      final deviceId = await _pollUntilPaired(tokenResp.token);

      yield PairingProgress(PairingStep.done, deviceId: deviceId);
    } on BlePairingException catch (e) {
      await bleDataSource.closeSession();
      yield* Stream.error(ServerFailure(e.message, message: e.message));
    } on UnauthorizedException catch (e) {
      await bleDataSource.closeSession();
      yield* Stream.error(UnauthorizedFailure(e.message, message: e.message));
    } on ServerException catch (e) {
      await bleDataSource.closeSession();
      yield* Stream.error(ServerFailure(e.message, message: e.message));
    } catch (e) {
      log('[PAIRING] lỗi không xác định: $e', name: 'PairingRepository');
      await bleDataSource.closeSession();
      yield* Stream.error(ServerFailure(
        e.toString(),
        message: 'Lỗi không xác định khi ghép nối: $e',
      ));
    }
  }

  /// Poll `GET /pairing/token/{token}` mỗi 2s, timeout 90s (spec §6.5).
  Future<String> _pollUntilPaired(String token) async {
    for (var i = 0; i < PairingConstants.pollMaxAttempts; i++) {
      final status = await remoteDataSource.getPairingTokenStatus(token);
      if (status.isPaired) {
        return status.deviceId ?? '';
      }
      if (status.isExpired) {
        throw ServerException(
            message: 'Pairing token đã hết hạn — vui lòng thử lại');
      }
      await Future.delayed(PairingConstants.pollInterval);
    }
    throw ServerException(
        message: 'Thiết bị chưa lên cloud sau 90 giây — kiểm tra lại '
            'WiFi (thiết bị chỉ hỗ trợ mạng 2.4GHz) rồi thử lại');
  }

  OspreyProductModel? _findProductByHash(String hashHex) {
    for (final p in _catalog) {
      if (p.productIdHashHex == hashHex) return p;
    }
    // Hash lạ → thử fallback lookup backend (fire-and-forget, lần scan
    // sau sẽ match nhờ catalog đã được refresh)
    _lookupUnknownHash(hashHex);
    return null;
  }

  // Các hash đã lookup trong phiên này — tránh spam backend mỗi adv frame.
  final Set<String> _lookedUpHashes = {};

  void _lookupUnknownHash(String hashHex) {
    if (_lookedUpHashes.contains(hashHex)) return;
    _lookedUpHashes.add(hashHex);
    remoteDataSource.getProductByHash(hashHex).then((product) {
      if (product != null) {
        _catalog = [..._catalog, product];
        catalogCache.save(_catalog);
      }
    }).catchError((Object e) {
      log('[PAIRING] by-hash lookup fail ($hashHex): $e',
          name: 'PairingRepository');
    });
  }
}
