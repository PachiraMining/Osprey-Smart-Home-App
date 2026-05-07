# Build Instructions

## Required `--dart-define` flags

Secrets and environment-specific config must be passed at build time. **Never hardcode in source.**

| Flag | Purpose | Required |
|---|---|---|
| `APP_SECRET_ANDROID` | Base64 HMAC-SHA256 secret for Android OAuth2 | Yes |
| `APP_SECRET_IOS` | Base64 HMAC-SHA256 secret for iOS OAuth2 | Yes |
| `SENTRY_DSN` | Sentry DSN for crash reporting | No (empty disables Sentry) |
| `MQTT_HOST` | MQTT broker hostname | No (defaults to `performentmarketing.ddnsgeek.com`) |
| `MQTT_PORT` | MQTT broker port | No (defaults to `1883`) |
| `APP_ENV` | Build environment (`dev`/`staging`/`prod`) | No (defaults to `dev`) |

## Run / Debug (dev)

```bash
fvm flutter run \
  --dart-define=APP_SECRET_ANDROID=<base64-secret> \
  --dart-define=APP_SECRET_IOS=<base64-secret> \
  --dart-define=SENTRY_DSN=<dsn-from-sentry-dashboard> \
  --dart-define=APP_ENV=dev
```

## Build APK (Android release)

```bash
fvm flutter build apk --release \
  --dart-define=APP_SECRET_ANDROID=<base64-secret> \
  --dart-define=APP_SECRET_IOS=<base64-secret> \
  --dart-define=SENTRY_DSN=<dsn> \
  --dart-define=APP_ENV=prod
```

## Build iOS (release)

```bash
fvm flutter build ios --release \
  --dart-define=APP_SECRET_ANDROID=<base64-secret> \
  --dart-define=APP_SECRET_IOS=<base64-secret> \
  --dart-define=SENTRY_DSN=<dsn> \
  --dart-define=APP_ENV=prod
```

## ⚠️ Security Notes

The OAuth secrets `APP_SECRET_ANDROID` and `APP_SECRET_IOS` were previously committed
to git history (see commit `f8256e1`). Even though they are now removed from source,
git history still contains them. **Rotate these secrets on the ThingsBoard server**
to invalidate the leaked values:

1. Generate new base64 HMAC-SHA256 secrets on ThingsBoard
2. Update build flags to use the new values
3. (Optional) Use `git filter-repo` to scrub history if the repo is public

## Using a `.env` file (alternative)

If you prefer a `.env` file, add to project root (already gitignored):

```env
APP_SECRET_ANDROID=...
APP_SECRET_IOS=...
SENTRY_DSN=...
APP_ENV=dev
```

Then source it before running:

```bash
export $(cat .env | xargs) && fvm flutter run \
  --dart-define=APP_SECRET_ANDROID=$APP_SECRET_ANDROID \
  --dart-define=APP_SECRET_IOS=$APP_SECRET_IOS \
  --dart-define=SENTRY_DSN=$SENTRY_DSN \
  --dart-define=APP_ENV=$APP_ENV
```
