// lib/core/di/injector.dart

import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smart_curtain_app/features/auth/presentation/bloc/auth_state.dart';
import '../../core/config/app_config.dart';
import '../../core/network/api_client.dart';
import '../../core/auth/token_manager.dart';

// Auth
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

// Device
import '../../features/device/data/datasources/device_remote_data_source.dart';
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
import '../../features/home/domain/usecases/get_rooms.dart';
import '../../features/home/domain/usecases/create_room.dart';
import '../../features/home/domain/usecases/update_room.dart';
import '../../features/home/domain/usecases/delete_room.dart';
import '../../features/home/presentation/bloc/home_management_bloc.dart';

final sl = GetIt.instance;

Future<void> setupInjector() async {
  // ========== Core ==========
  // Secure Storage
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  // Token Manager
  sl.registerLazySingleton(() => TokenManager(sl()));

  // Load token vào cache
  final tokenManager = sl<TokenManager>();
  await tokenManager.loadTokenToCache();

  // API Client
  sl.registerLazySingleton(
    () => ApiClient(baseUrl: AppConfig.thingsboardBaseUrl),
  );

  // HTTP Client
  sl.registerLazySingleton(() => http.Client());

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
      tokenManager: sl(), // Inject TokenManager
      authDataSource: sl(),
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

  // Use cases
  sl.registerLazySingleton(() => GetCustomerDevices(sl()));
  sl.registerLazySingleton(() => DeleteDevice(sl()));

  // BLoC
  sl.registerFactory(
    () => DeviceBloc(getCustomerDevices: sl(), deleteDevice: sl()),
  );
  // ========== Device Control Feature ==========
  // Device Control Repository
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

  sl.registerLazySingleton<DeviceControlRepository>(
    () => DeviceControlRepositoryImpl(dataSource: sl()),
  );

  // Device Control Use Case
  sl.registerLazySingleton(() => SendDeviceCommand(sl()));

  // ========== Scene Feature ==========
  // Data sources
  sl.registerLazySingleton<SceneRemoteDataSource>(
    () => SceneRemoteDataSourceImpl(
      client: sl<http.Client>(),
      schedulerBaseUrl: AppConfig.schedulerBaseUrl,
      thingsboardBaseUrl: AppConfig.thingsboardBaseUrl,
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
  sl.registerLazySingleton<SceneRepository>(
    () => SceneRepositoryImpl(
      remoteDataSource: sl(),
      getCustomerId: () {
        final customerId = sl<TokenManager>().getCustomerIdSync();
        if (customerId != null && customerId.isNotEmpty) {
          return customerId;
        }
        return '';
      },
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
      getRooms: sl(),
      createRoom: sl(),
      updateRoom: sl(),
      deleteRoom: sl(),
      homeRemoteDataSource: sl(),
    ),
  );
}
