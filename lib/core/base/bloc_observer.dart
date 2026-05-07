import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../config/app_config.dart';

class SimpleBlocObserver extends BlocObserver {
  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    developer.log(
      'BLoC error in ${bloc.runtimeType}',
      name: 'bloc',
      error: error,
      stackTrace: stackTrace,
    );
    if (AppConfig.sentryDsn.isNotEmpty) {
      Sentry.captureException(
        error,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setTag('bloc', bloc.runtimeType.toString());
        },
      );
    }
  }
}
