# Alexa Account Linking — Design Spec

**Date:** 2026-03-13
**Feature:** In-app Alexa account linking via native Login with Amazon SDK
**Branch:** `feat/ui-redesign-osprey`

## Overview

Allow users to link their Osprey smart home account with Amazon Alexa directly from the app, enabling voice control of their devices. The linking flow uses native LWA (Login with Amazon) SDK on both iOS and Android, combined with Osprey backend auth code generation and Amazon Skill Enablement API.

## Flow

```
User taps Alexa icon (Me tab → Third-Party Services)
  │
  ├─ API 0: GET /api/alexa/app-linking/status
  │
  ├─ [linked=false] → "Link Osprey with Alexa" screen
  │    └─ User taps LINK
  │         ├─ Step 1: POST /api/alexa/app-linking/generate-code → authCode
  │         ├─ Step 2: Native LWA SDK → amazon_access_token
  │         ├─ Step 3: POST amazonalexa.com/.../enablement → LINKED
  │         └─ Step 4: Show "Already linked" screen
  │
  └─ [linked=true] → "Already linked" screen
       └─ User taps UNLINK
            ├─ LWA signOut
            ├─ DELETE amazonalexa.com/.../enablement
            └─ Show "Link Osprey with Alexa" screen
```

## What Already Exists

### Android (complete)
- `MainActivity.kt`: Platform channel `com.osprey/alexa_lwa` with `signIn`/`signOut` methods
- `login-with-amazon-sdk.jar` in `android/app/libs/`
- `api_key.txt` in `android/app/src/main/assets/`
- `WorkflowActivity` registered in `AndroidManifest.xml`
- URL scheme `amzn://com.example.smart_curtain_app`

### iOS (config only, no code)
- `APIKey` in `Info.plist` for LWA
- URL scheme `amzn-com.example.smartCurtainApp` in `Info.plist`
- `SceneDelegate.swift` exists but is empty
- **Missing:** LoginWithAmazon framework, platform channel code

### Dart (UI + API 0 only)
- `alexa_linking_page.dart`: Check status API, linked/unlinked/error views
- `_startLinking()` currently just opens browser URL (incorrect flow)

## Implementation Plan

### Part 1: iOS Native LWA Integration

**1a. Add LoginWithAmazon framework**
- Add `pod 'LoginWithAmazon'` to `ios/Podfile`
- Run `pod install`

**1b. Implement platform channel in AppDelegate.swift**
- Channel name: `com.osprey/alexa_lwa` (matches Android)
- Methods:
  - `signIn(scopes: [String])` → triggers LWA authorize with given scopes → returns `{status, accessToken}` or `{status, error}`
  - `signOut()` → calls `AMZNAuthorizationManager.shared().signOut()` → returns `{status}`
- Handle URL callback via `application(_:open:options:)` → forward to `AMZNAuthorizationManager`

### Part 2: Dart — Rewrite Linking Flow

**2a. Replace `_startLinking()` with 3-step flow:**

```dart
Future<void> _startLinking() async {
  // Step 1: Generate auth code from Osprey backend
  POST /api/alexa/app-linking/generate-code
  → authCode

  // Step 2: Login with Amazon via platform channel
  MethodChannel('com.osprey/alexa_lwa').invokeMethod('signIn', {
    'scopes': ['alexa::skills:account_linking']
  })
  → amazonAccessToken

  // Step 3: Enable skill + link account via Amazon API
  POST https://api.amazonalexa.com/v1/users/~current/skills/{SKILL_ID}/enablement
  Headers: Authorization: Bearer <amazonAccessToken>
  Body: { stage: "development", accountLinkRequest: { redirectUri, authCode, type: "AUTH_CODE" } }
  → 201 Created = success, 409 = already linked
}
```

**2b. Add Unlink functionality on linked view:**
- Call platform channel `signOut`
- Call `DELETE https://api.amazonalexa.com/v1/users/~current/skills/{SKILL_ID}/enablement`
- Re-check status

### Part 3: No New Architecture Layers

Keep the existing pattern in `alexa_linking_page.dart`:
- Direct `http.Client` calls (already injected via GetIt)
- Platform channel calls via `MethodChannel`
- Local state management with `setState`
- No BLoC/Repository/UseCase — feature is self-contained

## Constants

| Key | Value |
|-----|-------|
| OSPREY_BASE_URL | `https://performentmarketing.ddnsgeek.com` |
| ALEXA_SKILL_ID | `amzn1.ask.skill.2cef70ff-5632-411b-9948-994b959ea8a7` |
| LWA_CLIENT_ID | `amzn1.application-oa2-client.f8ec0b9e3f79445085e81825737feadd` |
| ALEXA_REDIRECT_URI | `https://layla.amazon.com/api/skill/link/M2NOX6EY61J6ZS` |
| PLATFORM_CHANNEL | `com.osprey/alexa_lwa` |
| SKILL_STAGE | `development` (change to `live` when published) |

## Error Handling

| Scenario | Handling |
|----------|----------|
| API 1 fails (generate code) | Show error, allow retry |
| LWA login cancelled | Reset linking state, no error shown |
| LWA login error | Show error with message from SDK |
| API 3 returns 401 | Amazon token expired — show "Please try again" |
| API 3 returns 400 | Auth code expired/invalid — regenerate and retry |
| API 3 returns 403 | User not dev/beta tester — show specific error |
| API 3 returns 409 | Already linked — treat as success |
| Network error | Show generic connection error with retry |

## Files to Create/Modify

| File | Action |
|------|--------|
| `ios/Podfile` | Add `pod 'LoginWithAmazon'` |
| `ios/Runner/AppDelegate.swift` | Add LWA platform channel + URL handling |
| `lib/features/home/presentation/pages/alexa_linking_page.dart` | Rewrite linking flow, add unlink |

## Testing

- Test on Android device (LWA SDK already working)
- Test on iOS device (after adding framework)
- Test with Amazon dev account (skill in development stage)
- Verify: link → check status → unlink → check status cycle
