// lib/core/di/injector.dart

import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_curtain_app/features/auth/presentation/bloc/auth_state.dart';
import '../../core/config/app_config.dart';
import '../../core/network/api_client.dart';
import '../../core/network/auth_http_client.dart';
import '../../core/network/mqtt_service.dart';
import '../../core/network/token_refresher.dart';
import '../../core/auth/token_manager.dart';
import '../../core/auth/session_manager.dart';
import '../../core/auth/social_login_service.dart';
import '../../core/time/device_timezone.dart';

// Auth
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

// Device
import '../widget/home_widget_service.dart';
import '../../features/device/data/device_network_store.dart';
import '../../features/device/data/datasources/device_remote_data_source.dart';
import '../../features/device/data/datasources/device_wifi_remote_datasource.dart';
import '../../features/device/data/repositories/device_repository_impl.dart';
import '../../features/device/domain/repositories/device_repository.dart';
import '../../features/device/domain/usecases/get_customer_devices.dart';
import '../../features/device/domain/usecases/delete_device.dart';
import '../../features/device/presentation/bloc/device_bloc.dart';

// Device Control
import '../../features/device/data/datasources/device_control_data_source.dart';
import '../../features/device/data/repositories/device_control_repository_impl.dart';
import '../../features/device/domain/repositories/device_control_repository.dart';
import '../../features/device/domain/usecases/send_device_command.dart';

// Scene
import '../../features/scene/data/datasources/scene_remote_datasource.dart';
import '../../features/scene/data/repositories/scene_repository_impl.dart';
import '../../features/scene/domain/repositories/scene_repository.dart';
import '../../features/scene/domain/usecases/get_scenes.dart';
import '../../features/scene/domain/usecases/create_scene.dart';
import '../../features/scene/domain/usecases/delete_scene.dart';
import '../../features/scene/domain/usecases/toggle_scene.dart';
import '../../features/scene/presentation/bloc/scene_bloc.dart';

// Tap-to-Run Scene
import '../../features/scene/data/datasources/tap_to_run_remote_datasource.dart';
import '../../features/scene/data/repositories/tap_to_run_repository_impl.dart';
import '../../features/scene/domain/repositories/tap_to_run_repository.dart';
import '../../features/scene/domain/usecases/get_tap_to_run_scenes.dart';
import '../../features/scene/domain/usecases/create_tap_to_run_scene.dart';
import '../../features/scene/domain/usecases/update_tap_to_run_scene.dart';
import '../../features/scene/domain/usecases/delete_tap_to_run_scene.dart';
import '../../features/scene/domain/usecases/execute_tap_to_run_scene.dart';
import '../../features/scene/domain/usecases/get_device_data_points.dart';
import '../../features/scene/presentation/bloc/tap_to_run/tap_to_run_bloc.dart';

// Automation Scene (rich schedule/condition automations)
import '../../features/scene/data/datasources/automation_remote_datasource.dart';
import '../../features/scene/data/repositories/automation_repository_impl.dart';
import '../../features/scene/domain/repositories/automation_repository.dart';
import '../../features/scene/domain/usecases/get_automations.dart';
import '../../features/scene/domain/usecases/create_automation.dart';
import '../../features/scene/domain/usecases/update_automation.dart';
import '../../features/scene/domain/usecases/delete_automation.dart';
import '../../features/scene/domain/usecases/toggle_automation.dart';
import '../../features/scene/presentation/bloc/automation/automation_bloc.dart';

// Home Management
import '../../features/home/data/datasources/home_remote_datasource.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_homes.dart';
import '../../features/home/domain/usecases/create_home.dart';
import '../../features/home/domain/usecases/update_home.dart';
import '../../features/home/domain/usecases/delete_home.dart';
import '../../features/home/domain/usecases/get_home_devices.dart';
import '../../features/home/domain/usecases/add_device_to_home.dart';
import '../../features/home/domain/usecases/update_home_device.dart';
import '../../features/home/domain/usecases/remove_device_from_home.dart';
import '../../features/home/domain/usecases/factory_reset_device.dart';
import '../../features/home/domain/usecases/get_rooms.dart';
import '../../features/home/domain/usecases/create_room.dart';
import '../../features/home/domain/usecases/update_room.dart';
import '../../features/home/domain/usecases/delete_room.dart';
import '../../features/home/presentation/bloc/home_management_bloc.dart';

// BLE Pairing
import '../../features/pairing/data/crypto/pairing_crypto.dart';
import '../../features/pairing/data/datasources/ble_pairing_datasource.dart';
import '../../features/pairing/data/datasources/pairing_remote_datasource.dart';
import '../../features/pairing/data/datasources/product_catalog_cache.dart';
import '../../features/pairing/data/repositories/pairing_repository_impl.dart';
import '../../features/pairing/domain/repositories/pairing_repository.dart';
import '../../features/pairing/domain/usecases/get_product_catalog.dart';
import '../../features/pairing/domain/usecases/pair_osprey_device.dart';
import '../../features/pairing/domain/usecases/scan_for_osprey_devices.dart';
import '../../features/pairing/presentation/bloc/osprey_scan_bloc.dart';
import '../../features/pairing/presentation/bloc/pairing_bloc.dart';

// BLE Control Fallback
import '../../features/control/data/crypto/ble_control_crypto.dart';
import '../../features/control/data/datasources/ble_control_datasource.dart';
import '../../features/control/data/repositories/transport_router_impl.dart';
import '../../features/control/data/storage/ble_session_store.dart';
import '../../features/control/domain/repositories/transport_router.dart';
import '../../features/control/presentation/bloc/cloud_health_cubit.dart';

// AI Feature
import '../../features/ai/data/datasources/foundation_models_datasource.dart';
import '../../features/ai/data/datasources/speech_to_text_datasource.dart';
import '../../features/ai/data/datasources/usage_pattern_local_datasource.dart';
import '../../features/ai/data/datasources/weather_remote_datasource.dart';
import '../../features/ai/data/repositories/foundation_model_repository_impl.dart';
import '../../features/ai/data/repositories/usage_pattern_repository_impl.dart';
import '../../features/ai/data/repositories/weather_repository_impl.dart';
import '../../features/ai/domain/repositories/foundation_model_repository.dart';
import '../../features/ai/domain/repositories/usage_pattern_repository.dart';
import '../../features/ai/domain/repositories/weather_repository.dart';
import '../../features/ai/domain/usecases/analyze_usage_patterns.dart';
import '../../features/ai/domain/usecases/get_weather_recommendation.dart';
import '../../features/ai/domain/usecases/log_device_action.dart';
import '../../features/ai/domain/usecases/parse_voice_intent.dart';
import '../../features/ai/domain/usecases/send_chat_message.dart';
import '../../features/ai/presentation/bloc/ai_chat_bloc.dart';
import '../../features/ai/presentation/bloc/ai_suggestion_bloc.dart';
import '../../features/ai/presentation/bloc/voice_command_bloc.dart';
import '../../features/ai/presentation/bloc/weather_ai_bloc.dart';

final sl = GetIt.instance;

Future<void> setupInjector() async {
  // ========== Core ==========
  // Secure Storage
  //
  // Android: `encryptedSharedPreferences: true` uses AndroidX Security
  // (EncryptedSharedPreferences) instead of the legacy KeyStore-per-value
  // backend, which intermittently fails to decrypt after a reboot / OS keystore
  // change — surfacing as a null read of the refresh token and silently logging
  // the user out the next day even though the refresh token is still valid.
  // iOS: `first_unlock` keeps the item readable across lock/unlock after the
  // first unlock post-boot. Matches the options already used by BleSessionStore.
  sl.registerLazySingleton(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    ),
  );

  // Device timezone (IANA id) — used to stamp a Home's timezone so the
  // scheduler fires scenes in the Home's local time.
  sl.registerLazySingleton(() => const DeviceTimezone());

  // Device network store (SSID đã provision per device)
  sl.registerLazySingleton(() => DeviceNetworkStore(sl()));

  // BLE Control Fallback — session key + counter + osprey UUID per device
  sl.registerLazySingleton(() => BleSessionStore(sl()));
  sl.registerLazySingleton(() => BleControlCrypto());

  // Home-screen widget bridge (iOS WidgetKit + Android AppWidget)
  sl.registerLazySingleton(() => HomeWidgetService());

  // Token Manager
  sl.registerLazySingleton(() => TokenManager(sl()));

  // Load token vào cache
  final tokenManager = sl<TokenManager>();
  await tokenManager.loadTokenToCache();

  // Session expiry coordinator: clears tokens + signals the UI to re-login
  // once a 401 can no longer be recovered by refreshing.
  sl.registerLazySingleton(
    () => SessionManager(sl()),
    dispose: (manager) => manager.dispose(),
  );

  // Token refresher: exchanges the stored refresh token for a fresh access
  // token (own bare Dio, so it never recurses into the 401 interceptor).
  // On success it re-authenticates the live MQTT telemetry socket so it doesn't
  // die when the old access token expires (reconnect only if actually connected).
  sl.registerLazySingleton(
    () => TokenRefresher(
      tokenManager: sl(),
      onRefreshed: (newToken) {
        if (sl.isRegistered<MqttService>()) {
          final mqtt = sl<MqttService>();
          if (mqtt.isConnected) mqtt.updateToken(newToken);
        }
      },
    ),
  );

  // API Client
  sl.registerLazySingleton(
    () => ApiClient(baseUrl: AppConfig.thingsboardBaseUrl),
  );

  // HTTP Client — wrapped so `http`-package data sources (device list/control,
  // curtain page, ...) get the SAME silent refresh-on-401 as the Dio stack.
  // Shares the TokenRefresher singleton, so the single-flight lock spans both.
  sl.registerLazySingleton<http.Client>(
    () => AuthHttpClient(
      inner: http.Client(),
      refresher: sl<TokenRefresher>(),
      sessionManager: sl<SessionManager>(),
      freshToken: () => sl<TokenManager>().getTokenSync() ?? '',
      authHost: Uri.parse(AppConfig.thingsboardBaseUrl).host,
    ),
  );

  // Social Login Service
  sl.registerLazySingleton(() => SocialLoginService(httpClient: sl()));

  // MQTT Real-time Service (connect after login by calling .connect(jwtToken: ...))
  sl.registerLazySingleton(() => MqttService());

  // ========== Auth Feature ==========
  // Data sources
  sl.registerLazySingleton(() => AuthRemoteDataSource(apiClient: sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      tokenManager: sl(),
      authDataSource: sl(),
      socialLoginService: sl(),
      tokenRefresher: sl(),
    ),
  );

  // ========== Device Feature ==========
  // Data sources
  sl.registerLazySingleton<DeviceRemoteDataSource>(
    () => DeviceRemoteDataSourceImpl(
      client: sl<http.Client>(),
      baseUrl: AppConfig.thingsboardBaseUrl,
      getToken: () {
        // Lấy token từ TokenManager (cached in memory)
        final token = sl<TokenManager>().getTokenSync();
        if (token != null && token.isNotEmpty) {
          return token;
        }

        // Fallback: lấy từ AuthBloc nếu có
        try {
          final authBloc = sl<AuthBloc>();
          final state = authBloc.state;
          if (state is AuthSuccess) {
            return state.token;
          }
        } catch (e) {
          // Ignore if AuthBloc not available
        }

        return '';
      },
      getCustomerId: () {
        final customerId = sl<TokenManager>().getCustomerIdSync();
        if (customerId != null && customerId.isNotEmpty) {
          return customerId;
        }

        return '';
      },
    ),
  );

  // Repositories
  sl.registerLazySingleton<DeviceRepository>(
    () => DeviceRepositoryImpl(remoteDataSource: sl()),
  );

  // Multi-WiFi management (network-info / wifi-list / add / delete / switch)
  sl.registerLazySingleton(
    () => DeviceWifiRemoteDataSource(apiClient: sl<ApiClient>()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetCustomerDevices(sl()));
  sl.registerLazySingleton(() => DeleteDevice(sl()));

  // BLoC
  sl.registerFactory(
    () => DeviceBloc(getCustomerDevices: sl(), deleteDevice: sl()),
  );
  // ========== Device Control Feature ==========
  // Cloud datasource (MQTT/RPC qua REST)
  sl.registerLazySingleton<DeviceControlDataSource>(
    () => DeviceControlDataSourceImpl(
      client: sl<http.Client>(),
      baseUrl: AppConfig.thingsboardBaseUrl,
      getToken: () {
        final token = sl<TokenManager>().getTokenSync();
        if (token != null && token.isNotEmpty) {
          return token;
        }

        try {
          final authBloc = sl<AuthBloc>();
          final state = authBloc.state;
          if (state is AuthSuccess) {
            return state.token;
          }
        } catch (_) {}

        return '';
      },
    ),
  );

  // BLE datasource cho fallback (scan + connect + write BLE_CONTROL_CMD)
  sl.registerLazySingleton<BleControlDataSource>(
    () => BleControlDataSourceImpl(),
  );

  // Cloud health monitor (single instance — share across device pages)
  sl.registerLazySingleton(() => CloudHealthCubit(sl<MqttService>()));

  // Transport router — chọn MQTT vs BLE cho từng command
  sl.registerLazySingleton<TransportRouter>(
    () => TransportRouterImpl(
      cloud: sl(),
      ble: sl(),
      sessionStore: sl(),
      healthCubit: sl(),
      crypto: sl(),
    ),
  );

  sl.registerLazySingleton<DeviceControlRepository>(
    () => DeviceControlRepositoryImpl(router: sl<TransportRouter>()),
  );

  // Device Control Use Case
  sl.registerLazySingleton(() => SendDeviceCommand(sl()));

  // ========== Scene Feature ==========
  // Data sources
  sl.registerLazySingleton<SceneRemoteDataSource>(
    () => SceneRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // Repositories
  sl.registerLazySingleton<SceneRepository>(
    () => SceneRepositoryImpl(
      remoteDataSource: sl(),
      getHomeId: () => sl<TokenManager>().getHomeIdSync() ?? '',
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetScenes(sl()));
  sl.registerLazySingleton(() => CreateScene(sl()));
  sl.registerLazySingleton(() => DeleteScene(sl()));
  sl.registerLazySingleton(() => ToggleScene(sl()));

  // BLoC
  sl.registerFactory(
    () => SceneBloc(
      getScenes: sl(),
      createScene: sl(),
      deleteScene: sl(),
      toggleScene: sl(),
    ),
  );

  // ========== Tap-to-Run Scene Feature ==========
  // Data sources
  sl.registerLazySingleton<TapToRunRemoteDataSource>(
    () => TapToRunRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // Repositories
  sl.registerLazySingleton<TapToRunRepository>(
    () => TapToRunRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetTapToRunScenes(sl()));
  sl.registerLazySingleton(() => CreateTapToRunScene(sl()));
  sl.registerLazySingleton(() => UpdateTapToRunScene(sl()));
  sl.registerLazySingleton(() => DeleteTapToRunScene(sl()));
  sl.registerLazySingleton(() => ExecuteTapToRunScene(sl()));
  sl.registerLazySingleton(() => GetDeviceDataPoints(sl()));

  // BLoC
  sl.registerFactory(
    () => TapToRunBloc(
      getTapToRunScenes: sl(),
      createTapToRunScene: sl(),
      updateTapToRunScene: sl(),
      deleteTapToRunScene: sl(),
      executeTapToRunScene: sl(),
      repository: sl(),
    ),
  );

  // ========== Automation Feature ==========
  // Data source
  sl.registerLazySingleton<AutomationRemoteDataSource>(
    () => AutomationRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // Repository
  sl.registerLazySingleton<AutomationRepository>(
    () => AutomationRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAutomations(sl()));
  sl.registerLazySingleton(() => CreateAutomation(sl()));
  sl.registerLazySingleton(() => UpdateAutomation(sl()));
  sl.registerLazySingleton(() => DeleteAutomation(sl()));
  sl.registerLazySingleton(() => ToggleAutomation(sl()));

  // BLoC
  sl.registerFactory(
    () => AutomationBloc(
      getAutomations: sl(),
      createAutomation: sl(),
      updateAutomation: sl(),
      deleteAutomation: sl(),
      toggleAutomation: sl(),
    ),
  );

  // ========== Home Management Feature ==========
  // Data source
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // Repository
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases (12)
  sl.registerLazySingleton(() => GetHomes(sl()));
  sl.registerLazySingleton(() => CreateHome(sl()));
  sl.registerLazySingleton(() => UpdateHome(sl()));
  sl.registerLazySingleton(() => DeleteHome(sl()));
  sl.registerLazySingleton(() => GetHomeDevices(sl()));
  sl.registerLazySingleton(() => AddDeviceToHome(sl()));
  sl.registerLazySingleton(() => UpdateHomeDevice(sl()));
  sl.registerLazySingleton(() => RemoveDeviceFromHome(sl()));
  sl.registerLazySingleton(() => FactoryResetDevice(sl()));
  sl.registerLazySingleton(() => GetRooms(sl()));
  sl.registerLazySingleton(() => CreateRoom(sl()));
  sl.registerLazySingleton(() => UpdateRoom(sl()));
  sl.registerLazySingleton(() => DeleteRoom(sl()));

  // BLoC
  sl.registerFactory(
    () => HomeManagementBloc(
      getHomes: sl(),
      createHome: sl(),
      updateHome: sl(),
      deleteHome: sl(),
      getHomeDevices: sl(),
      addDeviceToHome: sl(),
      updateHomeDevice: sl(),
      removeDeviceFromHome: sl(),
      factoryResetDevice: sl(),
      getRooms: sl(),
      createRoom: sl(),
      updateRoom: sl(),
      deleteRoom: sl(),
      homeRemoteDataSource: sl(),
    ),
  );

  // ========== BLE Pairing Feature ==========
  // SharedPreferences (product catalog cache)
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => prefs);

  // Crypto + data sources
  sl.registerLazySingleton(() => PairingCrypto());
  sl.registerLazySingleton(() => ProductCatalogCache(prefs: sl()));
  sl.registerLazySingleton<PairingRemoteDataSource>(
    () => PairingRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<BlePairingDataSource>(
    () => BlePairingDataSourceImpl(),
  );

  // Repository
  sl.registerLazySingleton<PairingRepository>(
    () => PairingRepositoryImpl(
      remoteDataSource: sl(),
      bleDataSource: sl(),
      catalogCache: sl(),
      crypto: sl(),
      bleSessionStore: sl(),
      getSmartHomeId: () => sl<TokenManager>().getHomeIdSync() ?? '',
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetProductCatalog(sl()));
  sl.registerLazySingleton(() => ScanForOspreyDevices(sl()));
  sl.registerLazySingleton(() => PairOspreyDevice(sl()));

  // BLoCs
  sl.registerFactory(
    () => OspreyScanBloc(scanForDevices: sl(), getProductCatalog: sl()),
  );
  sl.registerFactory(() => PairingBloc(pairDevice: sl()));

  // ========== AI Feature ==========
  // Data sources
  sl.registerLazySingleton(() => FoundationModelsDataSource());
  sl.registerLazySingleton(() => SpeechToTextDataSource());
  sl.registerLazySingleton(() => UsagePatternLocalDataSource());
  sl.registerLazySingleton(() => WeatherRemoteDataSource(sl<http.Client>()));

  // Repositories
  sl.registerLazySingleton<FoundationModelRepository>(
    () => FoundationModelRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<UsagePatternRepository>(
    () => UsagePatternRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<WeatherRepository>(
    () => WeatherRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => ParseVoiceIntent(sl()));
  sl.registerLazySingleton(() => LogDeviceAction(sl()));
  sl.registerLazySingleton(() => AnalyzeUsagePatterns(sl()));
  sl.registerLazySingleton(() => GetWeatherRecommendation(sl()));
  sl.registerLazySingleton(() => SendChatMessage(sl()));

  // BLoCs (Factory — fresh state each provider)
  sl.registerFactory(
    () => VoiceCommandBloc(stt: sl(), parse: sl()),
  );
  sl.registerFactory(() => AiSuggestionBloc(sl()));
  sl.registerFactory(() => WeatherAiBloc(sl()));
  sl.registerFactory(() => AiChatBloc(sl(), sl(), sl()));
}
