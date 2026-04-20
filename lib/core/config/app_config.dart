/// Centralized app configuration.
/// Change these values per environment (dev/staging/prod).
class AppConfig {
  static const String thingsboardBaseUrl =
      'https://performentmarketing.ddnsgeek.com';
  static const String schedulerBaseUrl = 'http://42.118.11.87:8000';
  static const String callbackScheme = 'osprey';
  static const String privacyPolicyUrl =
      'https://pachiramining.github.io/Osprey-Smart-Home-App/privacy-policy/';
  static const String userAgreementUrl =
      'https://pachiramining.github.io/Osprey-Smart-Home-App/terms/';

  /// Package name used as the OAuth2 app identifier sent to ThingsBoard.
  static const String pkgName = 'com.osprey.smarthome';

  // TODO: Move these secrets out of source code.
  // Use --dart-define=APP_SECRET_ANDROID=<value> at build time, or read from
  // a .env file via flutter_dotenv, so the raw secrets are never committed.
  //
  // Example build command:
  //   flutter run \
  //     --dart-define=APP_SECRET_ANDROID=r5OOkrimqZVVR60H/+pcwUKg5bF1CDZ7Z3kdNGytsfc= \
  //     --dart-define=APP_SECRET_IOS=EFK220ARUmZaFNFMaxEGa1y1/HYJApKc2xy4IXofdnI=

  /// Base64-encoded HMAC-SHA256 secret for Android OAuth2 app tokens.
  static const String appSecretAndroid =
      String.fromEnvironment('APP_SECRET_ANDROID',
          defaultValue: 'r5OOkrimqZVVR60H/+pcwUKg5bF1CDZ7Z3kdNGytsfc=');

  /// Base64-encoded HMAC-SHA256 secret for iOS OAuth2 app tokens.
  static const String appSecretIos =
      String.fromEnvironment('APP_SECRET_IOS',
          defaultValue: 'EFK220ARUmZaFNFMaxEGa1y1/HYJApKc2xy4IXofdnI=');
}
