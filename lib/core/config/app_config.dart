/// Centralized app configuration.
/// Change these values per environment (dev/staging/prod).
class AppConfig {
  /// TEST/staging domain — the one currently in use, and the default for every
  /// build until the publish domain is provided.
  static const String _testBaseUrl = 'https://performentmarketing.ddnsgeek.com';

  /// PUBLISH/production domain. Overridable via
  /// `--dart-define=PUBLISH_BASE_URL=https://<domain>` if it ever changes.
  static const String _publishBaseUrl = String.fromEnvironment(
    'PUBLISH_BASE_URL',
    defaultValue: 'https://iot.osprey.life',
  );

  /// Which domain to target: `--dart-define=API_ENV=test|publish` (default test).
  static const String apiEnv =
      String.fromEnvironment('API_ENV', defaultValue: 'test');

  static const bool _isPublish = apiEnv == 'publish';

  /// REST API base URL. Switch domains at build time WITHOUT editing code:
  ///   • test (default):    `flutter build apk`
  ///   • publish:           `flutter build apk --dart-define=API_ENV=publish`
  ///                          (→ https://iot.osprey.life)
  ///   • ad-hoc override:   `--dart-define=BASE_URL=https://<any-domain>`
  /// Host/scheme only — every path comes from `ApiEndpoints`.
  static const String thingsboardBaseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: apiEnv == 'publish' ? _publishBaseUrl : _testBaseUrl,
  );

  /// Scheduler API base URL. Defaults to the same host as [thingsboardBaseUrl];
  /// override separately with `--dart-define=SCHEDULER_BASE_URL=...` if it lives
  /// on a different domain.
  static const String schedulerBaseUrl = String.fromEnvironment(
    'SCHEDULER_BASE_URL',
    defaultValue: thingsboardBaseUrl,
  );

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
      'https://osprey.life/policies/privacy-policy';
  static const String userAgreementUrl =
      'https://osprey.life/pages/terms-of-use';

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

  /// MQTT broker host for real-time telemetry. Publish uses `iot.osprey.life`
  /// (TLS on 8883); test uses the ddnsgeek host (plain 1883). Override with
  /// `--dart-define=MQTT_HOST=<host>`.
  static const String mqttHost = String.fromEnvironment(
    'MQTT_HOST',
    defaultValue:
        _isPublish ? 'iot.osprey.life' : 'performentmarketing.ddnsgeek.com',
  );

  /// MQTT broker port. Publish = 8883 (TLS/mqtts), test = 1883 (plain).
  static const int mqttPort =
      int.fromEnvironment('MQTT_PORT', defaultValue: _isPublish ? 8883 : 1883);

  /// Whether the MQTT client must use TLS. Publish broker is mqtts:// → true.
  static const bool mqttUseTls =
      bool.fromEnvironment('MQTT_TLS', defaultValue: _isPublish);

  /// MQTT URL gửi cho DEVICE qua BLE pairing (firmware connect tới đây).
  /// Firmware ≥ v1.0.15 tự chọn giao thức MQTTS theo scheme `ssl://`.
  static const String deviceMqttUrl = String.fromEnvironment(
    'DEVICE_MQTT_URL',
    defaultValue: _isPublish
        ? 'ssl://iot.osprey.life:8883'
        : 'ssl://performentmarketing.ddnsgeek.com',
  );

  /// HTTP API base URL gửi cho DEVICE qua BLE pairing
  /// (firmware gọi /api/v1/provision + /pairing/device-callback).
  /// Firmware ≥ v1.0.15 tự chọn HTTPS theo scheme `https://`.
  static const String deviceHttpApiBaseUrl = String.fromEnvironment(
    'DEVICE_HTTP_API_BASE_URL',
    defaultValue:
        _isPublish ? 'https://iot.osprey.life' : 'https://performentmarketing.ddnsgeek.com',
  );

  /// App key định danh brand ở các endpoint auth (email/phone/guest).
  ///
  /// Thay cho tenantId cũ: tenant UUID không được nằm trong app binary khi
  /// release; appKey thu hồi/cấp lại được. App build cho brand nào dùng appKey
  /// của brand đó — cùng codebase, khác config. Override qua dart-define
  /// `APP_KEY` cho brand khác.
  static const String appKey = String.fromEnvironment(
    'APP_KEY',
    defaultValue: 'ak_osprey_dcac38bd1fa1365c62d7e022734d11ea',
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
