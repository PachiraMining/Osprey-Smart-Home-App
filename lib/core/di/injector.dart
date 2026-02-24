// lib/core/di/injector.dart

import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smart_curtain_app/features/auth/presentation/bloc/auth_state.dart';
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
    () => ApiClient(baseUrl: 'https://performentmarketing.ddnsgeek.com'),
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
      baseUrl: 'https://performentmarketing.ddnsgeek.com',
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

        print('⚠️ CustomerId not found in cache');
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
      baseUrl: 'https://performentmarketing.ddnsgeek.com',
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
        } catch (e) {}

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
      schedulerBaseUrl: 'http://1.55.30.61:8000',
      thingsboardBaseUrl: 'https://performentmarketing.ddnsgeek.com',
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
        } catch (e) {}
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
}
