/// Single source of truth for every backend path the app calls.
///
/// Paths are RELATIVE — the host/scheme comes from the `baseUrl` configured on
/// the HTTP client (see [ApiClient] / `AppConfig`), so switching the publish vs
/// test domain never touches this file. Fixed paths are `static const`;
/// parameterised paths are pure functions so call sites can't typo the shape.
///
/// The token-refresh path lives in `AppConfig.refreshTokenPath` because it is
/// overridable at build time via `--dart-define=REFRESH_TOKEN_PATH=...`.
class ApiEndpoints {
  ApiEndpoints._();

  // ── Auth (brand email flow) ──────────────────────────────────────────────
  static const emailLogin = '/api/noauth/smarthome/email/login';
  static const emailSendOtp = '/api/noauth/smarthome/email/send-otp';
  static const emailSignup = '/api/noauth/smarthome/email/signup';
  static const resetPasswordByEmail = '/api/noauth/resetPasswordByEmail';
  static const currentUser = '/api/auth/user';
  static const accountDelete = '/api/smarthome/auth/account/delete';
  static const accountDeleteCancel = '/api/smarthome/auth/account/delete/cancel';
  static const accountDeleteStatus = '/api/smarthome/auth/account/delete/status';

  // ── Home / rooms ─────────────────────────────────────────────────────────
  static const homes = '/api/smarthome/homes';
  static String home(String homeId) => '/api/smarthome/homes/$homeId';
  static String homeDevices(String homeId) =>
      '/api/smarthome/homes/$homeId/devices';
  static String homeDevice(String homeId, String deviceId) =>
      '/api/smarthome/homes/$homeId/devices/$deviceId';
  static String homeDeviceFactoryReset(String homeId, String deviceId) =>
      '/api/smarthome/homes/$homeId/devices/$deviceId/factory-reset';
  static String homeRooms(String homeId) => '/api/smarthome/homes/$homeId/rooms';
  static String homeMembers(String homeId) =>
      '/api/smarthome/homes/$homeId/members';
  static String homeMember(String homeId, String memberId) =>
      '/api/smarthome/homes/$homeId/members/$memberId';

  /// Hồ sơ user — `SmartHomeMember` chỉ trả `userId`, phải tra thêm để có
  /// tên + email hiển thị trong danh sách thành viên.
  static String user(String userId) => '/api/user/$userId';
  static String homeRoom(String homeId, String roomId) =>
      '/api/smarthome/homes/$homeId/rooms/$roomId';

  // ── Scene / Automation / Tap-to-Run (shared scene resource) ──────────────
  static String homeScenes(String homeId) =>
      '/api/smarthome/homes/$homeId/scenes';
  static String scene(String sceneId) => '/api/smarthome/scenes/$sceneId';
  static String sceneEnable(String sceneId) =>
      '/api/smarthome/scenes/$sceneId/enable';
  static String sceneDisable(String sceneId) =>
      '/api/smarthome/scenes/$sceneId/disable';
  static String sceneExecute(String sceneId) =>
      '/api/smarthome/scenes/$sceneId/execute';
  static String sceneLogs(String sceneId) =>
      '/api/smarthome/scenes/$sceneId/logs';
  static String productDatapoints(String deviceProfileId) =>
      '/api/smarthome/products/$deviceProfileId/datapoints';

  // ── Pairing (Osprey) ─────────────────────────────────────────────────────
  static const products = '/api/smarthome/products';
  static String productByHash(String hashHex) =>
      '/api/smarthome/products/by-hash/$hashHex';
  static const pairingAuthChallenge = '/api/smarthome/pairing/auth-challenge';
  static const pairingToken = '/api/smarthome/pairing/token';
  static String pairingTokenStatus(String token) =>
      '/api/smarthome/pairing/token/$token';

  // ── Device ───────────────────────────────────────────────────────────────
  /// SmartHome device root; WiFi endpoints append `/network-info`, `/wifi-list`,
  /// `/wifi-add`, `/wifi/{id}`, ... to this.
  static String smartHomeDevice(String deviceId) =>
      '/api/smarthome/devices/$deviceId';
  static String deviceCommands(String deviceId) =>
      '/api/smarthome/devices/$deviceId/commands';
  /// Thông tin mạng của thiết bị: deviceUuid, SSID đang nối, RSSI.
  static String deviceNetworkInfo(String deviceId) =>
      '/api/smarthome/devices/$deviceId/network-info';

  /// Attributes ThingsBoard (fw_version, …) — dùng cho trang Device Information.
  static String deviceAttributes(String deviceId) =>
      '/api/plugins/telemetry/DEVICE/$deviceId/values/attributes';

  static String deviceStatus(String deviceId) =>
      '/api/smarthome/devices/$deviceId/status';
  static String deviceInfo(String deviceId) => '/api/device/info/$deviceId';

  // ── OAuth / social login + smart-assistant account linking ───────────────
  static const noauthMobile = '/api/noauth/mobile';
  static const alexaLinkStatus = '/api/alexa/app-linking/status';
  static const alexaLinkStart = '/api/alexa/app-linking/start';
  static const alexaLinkComplete = '/api/alexa/app-linking/complete';
  static const googleLinkStatus = '/api/google/app-linking/status';
  static const googleLinkStart = '/api/google/app-linking/start';

  // ── ThingsBoard core (device control via http package) ───────────────────
  static String rpcOneway(String deviceId) => '/api/rpc/oneway/$deviceId';
  static String customerDeviceInfos(String customerId) =>
      '/api/customer/$customerId/deviceInfos';
  static String device(String deviceId) => '/api/device/$deviceId';
}
