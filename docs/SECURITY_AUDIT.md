# OWASP Mobile Top 10 Security Audit

Date: 2026-05-07
Branch: `feat/ui-redesign-osprey`
Tool: `~/.claude/skills/owasp-mobile-security-checker`

## Summary

| Category | Status | Issues |
|---|---|---|
| M1 — Hardcoded Secrets | ✅ Pass | 0 |
| M2 — Dependency Hygiene | ✅ Fixed | 2 → 0 |
| M5 — Network Security | ⚠️ Partial | 2 (1 by design, 1 P2) |
| M9 — Insecure Storage | ✅ Pass | 0 |

## M1 — Hardcoded Secrets ✅

OAuth secrets `appSecretAndroid` / `appSecretIos` previously had `defaultValue` literals
in `lib/core/config/app_config.dart`. Now require `--dart-define` at build time
and throw `StateError` in `social_login_service.dart` if missing.

**Action remaining:** Rotate the leaked secrets on the ThingsBoard server. They live
in git history at commit `f8256e1`.

## M2 — Dependencies ✅ Fixed

Two unconstrained dependencies in `pubspec.yaml` (HIGH):
- `permission_handler:` → pinned to `^11.3.1`
- `get:` → pinned to `^4.6.6`

## M5 — Network Security ⚠️

### HIGH — `schedulerBaseUrl` uses HTTP

`lib/core/config/app_config.dart:6` — `http://42.118.11.87:8000`

**Status:** Allowed by `android/app/src/main/res/xml/network_security_config.xml`
as a scoped exception for this single IP. Cleartext is denied for all other domains.

**Mitigation in place.** Real fix: ask backend team to terminate TLS at the scheduler.

### MEDIUM — No certificate pinning

`network_security_config.xml` has no `<pin-set>` element. For a production smart home
app, certificate pinning would defend against compromised CA / corporate MitM.

**Recommendation (P2):** Pin the ThingsBoard certificate. Example:

```xml
<domain-config>
    <domain includeSubdomains="true">performentmarketing.ddnsgeek.com</domain>
    <pin-set expiration="2027-01-01">
        <pin digest="SHA-256">BASE64_OF_SPKI_HASH</pin>
        <pin digest="SHA-256">BASE64_OF_BACKUP_PIN</pin>
    </pin-set>
</domain-config>
```

Get the SPKI pin via:
```bash
openssl s_client -servername performentmarketing.ddnsgeek.com \
  -connect performentmarketing.ddnsgeek.com:443 < /dev/null 2>/dev/null \
  | openssl x509 -pubkey -noout \
  | openssl pkey -pubin -outform der \
  | openssl dgst -sha256 -binary \
  | openssl enc -base64
```

Skip for dev — too painful to rotate. Add before final App Store build.

## M9 — Storage ✅

Only `flutter_secure_storage` used (Keychain / EncryptedSharedPreferences). No raw
SharedPreferences, no plaintext file writes for tokens.

## Re-run audit

```bash
python3 ~/.claude/skills/owasp-mobile-security-checker/scripts/scan_hardcoded_secrets.py
python3 ~/.claude/skills/owasp-mobile-security-checker/scripts/check_dependencies.py
python3 ~/.claude/skills/owasp-mobile-security-checker/scripts/check_network_security.py
python3 ~/.claude/skills/owasp-mobile-security-checker/scripts/analyze_storage_security.py
```

JSON reports land in project root: `owasp_m1_secrets_scan.json` etc. (gitignored).
