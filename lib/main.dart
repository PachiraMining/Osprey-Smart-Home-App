import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'core/config/app_config.dart';
import 'core/di/injector.dart';
import 'core/base/bloc_observer.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/device/presentation/bloc/device_bloc.dart';
import 'features/scene/presentation/bloc/scene_bloc.dart';
import 'features/scene/presentation/bloc/scene_event.dart';
import 'smart_splash.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/device/presentation/bloc/device_event.dart';
import 'features/scene/presentation/bloc/tap_to_run/tap_to_run_bloc.dart';
import 'features/home/presentation/bloc/home_management_bloc.dart';
import 'features/home/presentation/bloc/home_management_event.dart';

Future<void> _bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupInjector();
  Bloc.observer = SimpleBlocObserver();
}

void main() async {
  if (AppConfig.sentryDsn.isEmpty) {
    await _bootstrap();
    runApp(const SmartApp());
    return;
  }

  await SentryFlutter.init(
    (options) {
      options.dsn = AppConfig.sentryDsn;
      options.environment = AppConfig.environment;
      options.tracesSampleRate = AppConfig.environment == 'prod' ? 0.2 : 1.0;
      options.attachScreenshot = true;
      options.attachViewHierarchy = true;
      options.sendDefaultPii = false;
    },
    appRunner: () async {
      await _bootstrap();
      runApp(
        DefaultAssetBundle(
          bundle: SentryAssetBundle(),
          child: const SmartApp(),
        ),
      );
    },
  );
}

// class SmartApp extends StatelessWidget {
//   const SmartApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       // ✅ Bọc toàn bộ app trong BlocProvider<AuthBloc>
//       create: (_) => GetIt.instance<AuthBloc>(),
//       child: MaterialApp(
//         title: 'Osprey',
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData(primarySwatch: Colors.teal),
//         home: const SmartSplashScreen(),
//         routes: {'/home': (_) => const HomePage()},
//       ),
//     );
//   }
// }

class SmartApp extends StatelessWidget {
  const SmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => GetIt.instance<HomeManagementBloc>()
            ..add(const LoadHomesEvent()),
        ),
        BlocProvider(create: (_) => GetIt.instance<AuthBloc>()),
        // Thêm DeviceBloc vào đây để toàn app dùng chung được
        BlocProvider(
          create: (_) => GetIt.instance<DeviceBloc>()
            ..add(LoadDevicesEvent()), // tự động load luôn khi app khởi động
        ),
        BlocProvider(
          create: (_) => GetIt.instance<SceneBloc>()
            ..add(LoadScenesEvent()),
        ),
        BlocProvider(create: (_) => GetIt.instance<TapToRunBloc>()),
      ],
      child: MaterialApp(
        title: 'Osprey',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const SmartSplashScreen(),
        routes: {'/home': (_) => const HomePage()},
      ),
    );
  }
}
