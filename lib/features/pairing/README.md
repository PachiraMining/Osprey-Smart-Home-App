# BLE Pairing (Osprey)

Implement theo `docs/ble-pairing-spec.md` (backend repo, branch
`feature/ble-provisioning`) + `HANDOFF_APP_TEAM.md` (firmware vendor,
verified trên chip BK7238 ngày 2026-06-04).

## Flow (Option 2 — DEVICE_UUID qua GATT, từ 2026-06-05)

Firmware watchdog 30s armed lúc connect, **disarm ngay khi app READ
char DEVICE_UUID** → sau READ, backend calls thoải mái thời gian:

```
Scan (filter Brand UUID a50133ef-...37b, skip paired flag)
  → GATT connect + requestMtu(517) (Android; iOS tự negotiate)
  → subscribe STATUS_NOTIFY (CCCD) ← BẮT BUỘC trước khi write
  → READ DEVICE_UUID (...380) — 36-byte ASCII, disarm watchdog
      (firmware cũ không có char này → BÁO LỖI "firmware quá cũ",
       không fallback ngầm — vendor verified char qua bleak 2026-06-05)
  → POST /pairing/auth-challenge {deviceUuid, nonceApp}
  → POST /pairing/token (token 8 ký tự, TTL 15 phút)
  → WRITE AUTH_CHALLENGE [nonce:16][hmac:32] → chờ notify 0x01 AUTH_OK
  → AES-128-CCM encrypt {token, ssid, password, mqtt_url,
      http_api_base_url, tb_provision_key, tb_provision_secret}
      key=sessionKey[0:16], iv=sessionKey[16:28], tag 16B
  → WRITE PAIRING_DATA → chờ notify 0x03 DATA_OK
  → disconnect → poll GET /pairing/token/{token} mỗi 2s (max 90s)
  → PAIRED → done
```

**MTU phải 517, KHÔNG phải 247** như handoff doc cũ: payload ~317 B >
244 B khả dụng của MTU 247 (MTU − 3). Vendor confirm 517 (2026-06-05).

**DEVICE_UUID**: firmware derive từ WiFi MAC (vd MAC `f8:9d:9d:07:66:64`
→ `f89d9d07-6664-4000-8000-f89d9d076664`) — app KHÔNG tự derive (iOS
không đọc được BLE MAC), chỉ READ từ char và dùng raw. Khi backend ship
per-device PSK (Phase 2), UUID sai sẽ bị AUTH_FAIL.

## Cấu trúc

| Layer | File | Vai trò |
|---|---|---|
| const | `pairing_constants.dart` | UUIDs, status codes, timing — CỐ ĐỊNH |
| crypto | `data/crypto/pairing_crypto.dart` | HMAC/HKDF (cryptography) + AES-CCM (pointycastle) |
| data | `data/datasources/osprey_adv_parser.dart` | Parse manufacturer data (frameCtrl + productType BE + hash) |
| data | `data/datasources/ble_pairing_datasource.dart` | Scan + GATT session (flutter_blue_plus) |
| data | `data/datasources/pairing_remote_datasource.dart` | REST `/api/smarthome/products`, `/pairing/*` |
| data | `data/datasources/product_catalog_cache.dart` | Cache catalog 24h (SharedPreferences) |
| data | `data/repositories/pairing_repository_impl.dart` | Orchestrate flow, emit `Stream<PairingProgress>` |
| domain | `domain/...` | Entities + repository interface + 3 usecases |
| UI | `presentation/pages/osprey_add_device_page.dart` | Scan UI (radar + list) |
| UI | `presentation/pages/osprey_pairing_page.dart` | WiFi form + progress stepper |

## Crypto verification

`test/features/pairing/pairing_crypto_test.dart` đối chiếu **byte-by-byte**
với golden oracle `tools/sim_pairing.py` của firmware vendor:

- HMAC (PSK=0xAA×32, nonce=0×16): `3dde8f26...` ✓
- Session key: `08df2a1f...` ✓
- PAIRING_DATA ciphertext 317 B: khớp toàn bộ ✓

Đã verify live với dev backend (2026-06-04): `POST /pairing/auth-challenge`
với zero nonce trả về đúng 2 giá trị reference trên.

**Lưu ý:** handoff doc gợi ý `AesCcm` từ package `cryptography` — class đó
KHÔNG tồn tại. AES-CCM dùng `pointycastle` (`CCMBlockCipher`).

## Known gaps (chờ backend/firmware)

1. **device_uuid mapping**: BLE adv chưa chứa device UUID — đang dùng
   `PairingConstants.devFallbackDeviceUuid` (thiết bị test
   `11111111-...`). Chờ backend bổ sung mapping MAC → device_uuid.
2. **Firmware J3**: firmware đang hardcode WiFi dev — vendor sẽ patch
   trước E2E session đầu tiên (app gửi credentials nào cũng được).
3. **iOS MTU**: iOS tự negotiate MTU khi connect (không có requestMtu).
   BK7238 phải support MTU ≥ 247; nếu negotiate thấp hơn, app báo lỗi
   rõ ràng thay vì long-write (firmware chưa support).

## Test

```bash
fvm flutter test test/features/pairing/   # 43 tests
```

Phase B (nRF Connect làm BLE peer) + Phase C (E2E firmware thật):
xem test workflow trong handoff message — chạy `python3 sim_pairing.py`
để lấy bytes paste vào nRF Connect.
