import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:home_widget/home_widget.dart';

import 'core/config/app_config.dart';
import 'core/di/injector.dart';
import 'core/base/bloc_observer.dart';
import 'core/auth/session_manager.dart';
import 'core/widget/home_widget_service.dart';
import 'core/widget/widget_interactivity.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/control/presentation/bloc/cloud_health_cubit.dart';
import 'features/device/presentation/bloc/device_bloc.dart';
import 'features/scene/presentation/bloc/scene_bloc.dart';
import 'smart_splash.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/device/presentation/bloc/device_event.dart';
import 'features/scene/presentation/bloc/tap_to_run/tap_to_run_bloc.dart';
import 'features/home/presentation/bloc/home_management_bloc.dart';
import 'features/home/presentation/bloc/home_management_event.dart';
import 'features/ai/presentation/bloc/ai_chat_bloc.dart';
import 'features/ai/presentation/bloc/ai_suggestion_bloc.dart';
import 'features/ai/presentation/bloc/voice_command_bloc.dart';
import 'features/ai/presentation/bloc/weather_ai_bloc.dart';

Future<void> _bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupInjector();
  Bloc.observer = SimpleBlocObserver();

  // Home-screen widget: app group (iOS) + callback nút bấm chạy nền (Android)
  await GetIt.instance<HomeWidgetService>().init();
  await HomeWidget.registerInteractivityCallback(ospreyWidgetCallback);
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

class SmartApp extends StatefulWidget {
  const SmartApp({super.key});

  @override
  State<SmartApp> createState() => _SmartAppState();
}

class _SmartAppState extends State<SmartApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldMessengerState> _messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  StreamSubscription<void>? _sessionSub;

  /// Guards against repeated redirects while a logout burst settles; cleared on
  /// the next successful login.
  bool _redirectingToLogin = false;

  @override
  void initState() {
    super.initState();
    if (GetIt.instance.isRegistered<SessionManager>()) {
      _sessionSub = GetIt.instance<SessionManager>()
          .onSessionExpired
          .listen((_) => _onSessionExpired());
    }
  }

  /// The session died and could not be refreshed: tokens are already cleared by
  /// [SessionManager]; wipe the navigation stack down to a fresh login screen
  /// and tell the user why.
  void _onSessionExpired() {
    if (_redirectingToLogin) return;
    _redirectingToLogin = true;
    // Defer to after the current frame so the navigator/messenger keys are
    // guaranteed attached, even if the triggering 401 resolves during the
    // cold-start window before the first frame renders.
    WidgetsBinding.instance.addPostFrameCallback((_) => _redirectToLogin());
  }

  void _redirectToLogin() {
    final navigator = _navigatorKey.currentState;
    if (navigator == null) {
      // Navigator not mounted yet — release the guard so a later signal retries
      // instead of locking the app out of the login screen permanently.
      _redirectingToLogin = false;
      return;
    }
    _messengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.'),
        ),
      );
    navigator.pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _sessionSub?.cancel();
    super.dispose();
  }

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
        // KHÔNG dispatch LoadScenesEvent ở đây: lúc khởi động chưa login/
        // chưa có homeId → SceneError kẹt ở nút Retry. SceneTab tự load
        // khi đã có home (initState + listener selectedHomeId).
        BlocProvider(create: (_) => GetIt.instance<SceneBloc>()),
        BlocProvider(create: (_) => GetIt.instance<TapToRunBloc>()),
        BlocProvider(create: (_) => GetIt.instance<VoiceCommandBloc>()),
        BlocProvider(create: (_) => GetIt.instance<AiSuggestionBloc>()),
        BlocProvider(create: (_) => GetIt.instance<WeatherAiBloc>()),
        BlocProvider(create: (_) => GetIt.instance<AiChatBloc>()),
        // BLE Control Fallback — cloud-down detector cho badge + scenes banner.
        // `BlocProvider.value`: cubit là LazySingleton trong GetIt (TransportRouter
        // dùng chung). BlocProvider(create:) sẽ `close()` cubit khi widget tree
        // rebuild → GetIt vẫn cache instance đã closed → stream subs vỡ.
        BlocProvider.value(value: GetIt.instance<CloudHealthCubit>()),
      ],
      // Re-arm the session guard whenever the user (re)authenticates so a
      // future expiry triggers the redirect again. Placed above MaterialApp so
      // the AuthBloc provider lookup is unambiguous.
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (_, current) => current is AuthSuccess,
        listener: (_, __) {
          _redirectingToLogin = false;
          if (GetIt.instance.isRegistered<SessionManager>()) {
            GetIt.instance<SessionManager>().reset();
          }
        },
        child: MaterialApp(
          title: 'osprey.life',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          navigatorKey: _navigatorKey,
          scaffoldMessengerKey: _messengerKey,
          home: const SmartSplashScreen(),
          routes: {
            '/home': (_) =>
                const HomePage(initialIndex: HomePageState.tabChat),
          },
        ),
      ),
    );
  }
}
