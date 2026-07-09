/// Centralized app configuration.
/// Change these values per environment (dev/staging/prod).
class AppConfig {
  static const String thingsboardBaseUrl =
      'https://performentmarketing.ddnsgeek.com';
  static const String schedulerBaseUrl = 'https://performentmarketing.ddnsgeek.com';

  /// Endpoint that exchanges a refresh token for a fresh access token.
  /// ThingsBoard standard: `POST /api/auth/token` with `{"refreshToken": "..."}`
  /// → `{"token": "...", "refreshToken": "..."}`. Override via dart-define if
  /// the backend exposes a branded path.
  static const String refreshTokenPath = String.fromEnvironment(
    'REFRESH_TOKEN_PATH',
    defaultValue: '/api/auth/token',
  );
  static const String callbackScheme = 'osprey';
  static const String privacyPolicyUrl =
      'https://pachiramining.github.io/Osprey-Smart-Home-App/privacy-policy/';
  static const String userAgreementUrl =
      'https://pachiramining.github.io/Osprey-Smart-Home-App/terms/';

  /// Package name used as the OAuth2 app identifier sent to ThingsBoard.
  static const String pkgName = 'io.dracaena.curtainai';

  /// Base64-encoded HMAC-SHA256 secret for Android OAuth2 app tokens.
  /// MUST be passed via --dart-define=APP_SECRET_ANDROID=<value> at build time.
  /// See build instructions in docs/BUILD.md.
  static const String appSecretAndroid =
      String.fromEnvironment('APP_SECRET_ANDROID');

  /// Base64-encoded HMAC-SHA256 secret for iOS OAuth2 app tokens.
  /// MUST be passed via --dart-define=APP_SECRET_IOS=<value> at build time.
  static const String appSecretIos =
      String.fromEnvironment('APP_SECRET_IOS');

  /// Sentry DSN for crash reporting.
  /// Pass via --dart-define=SENTRY_DSN=<value> at build time. Empty disables Sentry.
  static const String sentryDsn = String.fromEnvironment('SENTRY_DSN');

  /// MQTT broker host for ThingsBoard real-time telemetry.
  /// Pass via --dart-define=MQTT_HOST=<host> (default: same host as ThingsBoard REST).
  static const String mqttHost = String.fromEnvironment(
    'MQTT_HOST',
    defaultValue: 'performentmarketing.ddnsgeek.com',
  );

  /// MQTT broker port. Default 1883 (plain), use 8883 for TLS.
  static const int mqttPort =
      int.fromEnvironment('MQTT_PORT', defaultValue: 1883);

  /// MQTT URL gửi cho DEVICE qua BLE pairing (firmware connect tới đây).
  /// Firmware ≥ v1.0.15 tự chọn giao thức MQTTS theo scheme `ssl://`.
  static const String deviceMqttUrl =
      'ssl://performentmarketing.ddnsgeek.com';

  /// HTTP API base URL gửi cho DEVICE qua BLE pairing
  /// (firmware gọi /api/v1/provision + /pairing/device-callback).
  /// Firmware ≥ v1.0.15 tự chọn HTTPS theo scheme `https://`.
  static const String deviceHttpApiBaseUrl =
      'https://performentmarketing.ddnsgeek.com';

  /// Tenant ID của brand Osprey trên backend multi-tenant.
  ///
  /// Dùng cho email signup/login kiểu Tuya (CUSTOMER_USER): app build cho
  /// brand nào dùng tenantId của brand đó — cùng codebase, khác config.
  static const String brandTenantId = String.fromEnvironment(
    'BRAND_TENANT_ID',
    defaultValue: '15e19c90-d000-11f0-ab7e-c31cfe647037',
  );

  /// Build environment: dev | staging | prod. Used for Sentry and analytics tagging.
  static const String environment =
      String.fromEnvironment('APP_ENV', defaultValue: 'dev');

  /// Throws StateError if any required secret is missing at runtime.
  /// Call from main.dart before runApp to fail-fast on misconfigured builds.
  static void assertSecretsConfigured() {
    if (appSecretAndroid.isEmpty || appSecretIos.isEmpty) {
      throw StateError(
        'Missing OAuth secrets. Build with --dart-define=APP_SECRET_ANDROID=... '
        'and --dart-define=APP_SECRET_IOS=...',
      );
    }
  }
}
