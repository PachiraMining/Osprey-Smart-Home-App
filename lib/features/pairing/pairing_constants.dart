/// Hằng số giao thức BLE pairing Osprey.
///
/// Nguồn: docs/ble-pairing-spec.md (backend) + HANDOFF_APP_TEAM.md
/// (firmware vendor, verified trên chip BK7238 ngày 2026-06-04).
/// Các UUID này CỐ ĐỊNH — không bao giờ đổi.
class PairingConstants {
  PairingConstants._();

  // ─── BLE UUIDs ───────────────────────────────────────────
  /// Brand Service UUID — filter khi BLE scan (advertisement).
  static const String brandServiceUuid =
      'a50133ef-ebd6-4a9b-8497-9d06309bf37b';

  /// GATT Pairing Service (sau khi connect).
  static const String pairingServiceUuid =
      'a50133ef-ebd6-4a9b-8497-9d06309bf37c';

  /// Characteristic AUTH_CHALLENGE — WRITE/READ, max 64 B.
  static const String authChallengeCharUuid =
      'a50133ef-ebd6-4a9b-8497-9d06309bf37d';

  /// Characteristic PAIRING_DATA — WRITE only (encrypted), max 512 B.
  static const String pairingDataCharUuid =
      'a50133ef-ebd6-4a9b-8497-9d06309bf37e';

  /// Characteristic STATUS_NOTIFY — NOTIFY/READ, max 32 B.
  static const String statusNotifyCharUuid =
      'a50133ef-ebd6-4a9b-8497-9d06309bf37f';

  /// Characteristic DEVICE_UUID — READ only, 36-byte ASCII UUID string
  /// (firmware derive từ WiFi MAC, vd "f89d9d07-6664-4000-8000-f89d9d076664").
  ///
  /// QUAN TRỌNG: firmware watchdog 30s (armed lúc connect) được DISARM
  /// ngay khi app READ char này → app phải đọc NGAY sau discover, sau đó
  /// gọi backend bao lâu cũng được. (Vendor confirm 2026-06-05.)
  static const String deviceUuidCharUuid =
      'a50133ef-ebd6-4a9b-8497-9d06309bf380';

  // ─── Advertisement ───────────────────────────────────────
  /// Company ID trong Manufacturer Specific Data (0xFFFF = test/internal).
  static const int manufacturerCompanyId = 0xFFFF;

  // ─── Crypto domain separators ────────────────────────────
  /// Prefix cho HMAC-SHA256: HMAC(PSK, "auth-challenge-v1" || nonce_app).
  static const String hmacDomainSeparator = 'auth-challenge-v1';

  /// HKDF info: HKDF(salt=nonce_app, ikm=PSK, info="osprey-pairing-v1").
  static const String hkdfInfo = 'osprey-pairing-v1';

  // ─── GATT status codes (STATUS_NOTIFY byte đầu tiên) ─────
  static const int statusAuthOk = 0x01;
  static const int statusAuthFail = 0x02;
  static const int statusDataOk = 0x03;
  static const int statusDecryptError = 0x04;
  static const int statusJsonParseError = 0x05;
  static const int statusWifiConnectFail = 0x06;
  static const int statusMqttProvisionFail = 0x07;
  static const int statusBadInput = 0x08;
  static const int statusInternalError = 0xFF;

  // ─── Sizes & timing ──────────────────────────────────────
  /// AUTH_CHALLENGE payload: [nonce_app:16][hmac_expected:32].
  static const int authChallengeLength = 48;
  static const int nonceLength = 16;

  /// MTU bắt buộc trước khi WRITE PAIRING_DATA (~317 B encrypted blob,
  /// firmware chưa support long-write).
  ///
  /// LƯU Ý: phải 517 chứ KHÔNG phải 247 như handoff doc cũ — MTU 247 chỉ
  /// cho phép write 244 B/packet (MTU − 3), không chứa nổi payload ~317 B.
  /// Firmware vendor confirm 517 (2026-06-05).
  static const int requiredMtu = 517;

  static const Duration scanTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration statusNotifyTimeout = Duration(seconds: 5);

  /// Poll backend mỗi 2s, tối đa 45 lần (= 90s).
  static const Duration pollInterval = Duration(seconds: 2);
  static const int pollMaxAttempts = 45;

  // ─── Dev/test ────────────────────────────────────────────
  /// Device UUID test (PSK 0xAA×32 đã seed trong DB backend).
  @Deprecated('Read the UUID from GATT char DEVICE_UUID (...380) — this '
      'constant is for offline debugging only, do NOT use in the production flow')
  static const String devFallbackDeviceUuid =
      '11111111-1111-1111-1111-111111111111';
}
