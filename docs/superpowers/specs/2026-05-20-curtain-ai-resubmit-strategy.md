# Curtain AI Resubmit Strategy — Approach B

**Date:** 2026-05-20
**Author:** Thuận + Claude
**Branch:** `feat/ui-redesign-osprey`
**Status:** Design — pending user approval before plan generation

## Context

App `com.osprey.homeapp` (Curtain AI, ASC id `6767100866`) was rejected twice under Guideline 4.3(a) "Design — Spam":

1. **Reject 1 (2026-05-09):** functional duplicate of `osprey.i01.i01` (Osprey Smart Home, live since 2023) + 2.1(a) bugs.
2. **Reject 2 (2026-05-18):** same 4.3(a) + identical eagle "S" icon.

**Hard constraints:**

- `osprey.i01.i01` must stay live in US (cannot pause/remove). It is **OEM'd from Tuya** — different binary signature than Curtain AI.
- Dracaena does not have its own Apple Developer Program account (no DUNS).
- Same dev team `FJU9H2Z6H8` will be used for the resubmission.
- Codebase is kept (no native Swift rewrite).

**Goal:** Pass App Review on the next submission. Target success rate **~35-45%** with the trimmed approach below, with a documented Plan B if rejected.

**Decisions recorded (2026-05-20):**

- Approach B selected — chat-first home, voice onboarding, HealthKit nhẹ, new bundle ID.
- **App name: "Osprey Life"** — user chose to keep brand consistency with the Osprey family (sister product to Osprey Smart Home). Justified by Apple's brand-family precedent (Apple Music + Apple TV+ + Apple Fitness+; Disney+ + ESPN), but only works if the App Review notes lead clearly with the *different primary purpose* (AI curtain assistant vs generic smart home). Cost vs an "AI-first" distinct name: ~10 percentage points.
- **Bundle ID: `io.dracaena.curtainai`** — deliberately contains no "osprey" string so Apple's auto-detection does not cross-reference the rejected `com.osprey.homeapp`.
- **Meet with Apple: SKIP** — user chose not to book pre-clearance. Cost: ~10 percentage points of success rate.
- **Backend proxy: SKIP** — app points directly at the existing ThingsBoard server. Cost: ~3 percentage points.
- **App icon: KEEP Osprey Life eagle wordmark** — user confirmed osprey.i01.i01's icon is a stripped "O" without text, while Osprey Life is a full eagle+wordmark. User treats these as visually distinct fingerprints; Claude flagged risk but defers to user's brand judgment. Cost vs a clean curtain-only icon: ~7 percentage points.

The cumulative success-rate impact is reflected in the headline ~35-45% number. With brand and icon now both in the Osprey family, **the functional differentiation pillars (chat-first home, voice onboarding, HealthKit, Tuya-OEM-vs-custom-Flutter) must do the entire load-bearing work in the App Review notes.**

## Architecture Overview

The new submission is a **fresh app record** in App Store Connect with a fresh bundle ID. The Flutter codebase remains, but five user-facing differentiators are added on top so the first-impression experience is unambiguously distinct from `osprey.i01.i01`:

```
┌─────────────────────────────────────────────────────────────┐
│  Welcome (Aurora glow) ──► Sign in with Apple ──► Onboarding │
│                                                              │
│  Voice-guided 4-step onboarding                              │
│      ├── Mic permission                                      │
│      ├── HealthKit permission (iOS)                          │
│      ├── Persona quiz ("Bạn muốn tôi giúp gì nhất?")        │
│      └── Ready                                               │
│                                                              │
│  ┌─────────────── Chat-First Home ─────────────────────┐    │
│  │  AI greeting card (based on time + sleep)           │    │
│  │  Chat thread (LLM via Foundation Models)            │    │
│  │  Slash commands: /device /scene /schedule           │    │
│  │  Voice FAB (bottom-right)                           │    │
│  │  Hamburger drawer (top-left): Devices, Scenes,      │    │
│  │    Profile, Settings                                │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

Existing pages (`device_control_page.dart`, scene pages, `home_tab.dart` grid) are kept and reachable from the drawer + slash commands, but are no longer the default entry point. The default route changes from `HomePage` (4-tab) to `ChatHomePage` (single-screen chat).

## Section 1 — Chat-First Home Layout

**Why:** Apple reviewers spend the first 60 seconds judging visual identity. `osprey.i01.i01` opens to a device grid + bottom-nav. Curtain AI must open to a clearly different surface.

**Components:**

- `lib/features/home/presentation/pages/chat_home_page.dart` *(new)* — Scaffold with:
  - `drawer:` side menu (Devices, Scenes, Profile, Settings)
  - `body:` `AiChatPage` content (already exists at `lib/features/ai/presentation/pages/ai_chat_page.dart` — reuse, do not duplicate)
  - `floatingActionButton:` `VoiceCommandButton` (already exists)
- `lib/features/home/presentation/widgets/chat_slash_command_bar.dart` *(new)* — input bar that intercepts `/device`, `/scene`, `/schedule` and opens a bottom-sheet picker instead of navigating.
- `lib/features/home/presentation/widgets/ai_greeting_card.dart` *(new)* — top card in the chat thread, generated from time-of-day + weather + (if iOS) HealthKit wake schedule. Aurora glow when "thinking".
- `lib/main.dart` *(modify)* — change `home:` route from `HomePage` to `ChatHomePage`.
- `lib/features/home/presentation/pages/home_page.dart` *(deprecate, not delete)* — keep accessible from drawer as "Classic View" for power users, but it's not the default surface.

**What it replaces:**

- `_BrandBottomNav` (Home/Scene/Mall/Me 4-tab) — no longer the primary nav.
- The initial device grid — moved one tap deeper.

**Acceptance criteria:**

- App opens directly to chat thread. No bottom nav visible by default.
- Slash command `/device` brings up a bottom-sheet listing all devices; tapping one opens existing `device_control_page.dart`.
- Drawer toggles via hamburger icon top-left.
- Side-by-side screenshot of Curtain AI vs `osprey.i01.i01` opening screens makes the difference instantly obvious.

## Section 2 — Onboarding & Signin Flow

**Why:** `osprey.i01.i01` uses a classic email/password form on launch. Curtain AI must lead with a visibly different auth experience — Apple Sign In primary + voice-guided onboarding — so the binary similarity argument is weakened in the reviewer's eyes.

**Components:**

- `lib/features/auth/presentation/pages/welcome_page.dart` *(new)* — full-bleed Aurora glow background, app name + tagline, single primary button "Sign in with Apple", and a small "Other sign-in methods" link below.
- `lib/features/auth/presentation/pages/other_signin_methods_page.dart` *(new)* — bottom sheet or sub-page containing Google + Phone OTP + Email/Password. Existing `login_page.dart` content moves here as the email/password option.
- `lib/features/auth/presentation/pages/voice_onboarding_page.dart` *(new)* — 4-step `PageView`:
  1. Mic permission request (with AI voice intro via Foundation Models)
  2. HealthKit permission (iOS only, gracefully skipped on Android)
  3. Persona chips: `Wake up gently`, `Save energy`, `Sleep better`, `Just control devices`
  4. Ready screen with personalised greeting preview
- `lib/features/auth/presentation/bloc/onboarding_bloc.dart` *(new)* — stores `OnboardingPreferences { persona, micGranted, healthkitGranted }` to `flutter_secure_storage`.
- `lib/features/auth/presentation/pages/login_page.dart` *(modify)* — keep file, but it is now reached only via "Other sign-in methods" path, not the welcome screen.
- `lib/main.dart` *(modify)* — initial route logic: if `OnboardingPreferences.completed == false` after auth, push voice onboarding before chat home.

**Acceptance criteria:**

- First launch after install: Welcome screen with Aurora glow + single "Sign in with Apple" button.
- Email/password form is reachable in 3 taps, not 0.
- After first successful auth, voice onboarding runs once; subsequent launches skip it.
- Persona choice influences the AI greeting on chat home.

## Section 3 — HealthKit Wellness Bridge

**Why:** Adds a use case `osprey.i01.i01` (and the Tuya OEM shell beneath it) does not have — Sleep-aware curtain timing. This is concrete differentiation Apple can verify, and it pairs naturally with Apple's own ecosystem.

**Components:**

- `ios/Runner/AppDelegate.swift` *(modify)* — add MethodChannel `com.curtainai.app/healthkit` inline with methods:
  - `requestPermission` → request `HKCategoryTypeIdentifierSleepAnalysis` read access
  - `getNextWakeTime` → query the next-day's earliest alarm or sleep-end estimate
  - `getSleepBaseline` → 7-day average bedtime/wake time
- `ios/Runner/Info.plist` *(modify)* — add `NSHealthShareUsageDescription`: "Curtain AI uses your sleep schedule to gently open shades before you wake."
- `lib/features/ai/data/datasources/healthkit_datasource.dart` *(new)* — Dart wrapper over the MethodChannel.
- `lib/features/ai/domain/repositories/healthkit_repository.dart` *(new)* — interface.
- `lib/features/ai/data/repositories/healthkit_repository_impl.dart` *(new)* — implementation, returns `Either<Failure, WakeSchedule>`.
- `lib/features/ai/domain/usecases/get_wake_aware_recommendation.dart` *(new)* — combines wake time + user persona + curtain device list to produce a recommendation entity.
- `lib/features/ai/presentation/bloc/wake_aware_bloc.dart` *(new)* — emits `WakeAwareSuggested` state with the recommendation; consumed by `chat_home_page.dart` to render a special suggestion card.
- Android: graceful degrade — `healthkit_datasource.dart` returns `Left(PlatformUnsupportedFailure())` and the suggestion card simply does not render.

**Acceptance criteria:**

- On iOS, the chat thread shows a "Mai 6:30 báo thức → tôi sẽ hé rèm 6:15 nhé?" card when a wake schedule is detectable.
- HealthKit permission is requested only during voice onboarding step 2, never re-prompted on the home screen.
- No HealthKit data is sent over the network (verifiable by inspecting `HealthKitDatasource` — no Dio/http import).
- Android build does not include any HealthKit references; the feature module compiles cleanly.

## Section 4 — Identity, Bundle ID, Backend Proxy, Icon

**Why:** Apple's automated 4.3(a) detection cross-references bundle ID, app icon hash, primary backend hostname, and binary frameworks. We change every one of those that we have control over.

**Tasks:**

- **iOS bundle ID:** `io.dracaena.curtainai`
  - User registers the identifier at https://developer.apple.com/account/resources/identifiers
  - User creates a new app record in App Store Connect with this bundle ID
  - I update `ios/Runner.xcodeproj/project.pbxproj` — `PRODUCT_BUNDLE_IDENTIFIER` in all three configs (Debug, Release, Profile)
- **Android applicationId:** `io.dracaena.curtainai` — update `android/app/build.gradle.kts`
- **App config:** `lib/core/config/app_config.dart` — `pkgName = 'io.dracaena.curtainai'`
- **Backend proxy:** SKIPPED. App continues to point directly at the existing ThingsBoard server. Network fingerprint is the same as `com.osprey.homeapp`; mitigated only by the fact that `osprey.i01.i01` uses Tuya hosts, so we're still differentiated from the *live* app Apple compared us to.
- **App icon (1024×1024 master):** user supplies the **Osprey Life logo** (eagle wings + "Osprey LIFE" wordmark, ®-marked). User confirmed this is visually distinct from `osprey.i01.i01`'s icon (which is a stripped "O" letterform without the full wordmark). I will render 13 iOS sizes + 5 Android density buckets from the user-provided 1024×1024 master.
  - File expected at: `assets/icon/osprey_life_master_1024.png` (user to drop in).
  - Risk note: at 60×60 device-rendered size, the wordmark becomes illegible and only the eagle silhouette is visible. If Apple's auto-hash compares the rendered small size, the differentiation from the previously rejected eagle "S" attempt is weaker. We accept this risk and rely on the rejection notes + new functional differentiators (chat-first home, voice onboarding, HealthKit) to carry the appeal.
- **Display name:** "Osprey Life" (new ASC record). `CFBundleDisplayName` in `ios/Runner/Info.plist` and `android:label` in `android/app/src/main/AndroidManifest.xml` set to "Osprey Life".
- **URL scheme / deep links:** keep `osprey://` scheme for now because Alexa and Google OAuth consoles are registered against it. Document this as a known limitation; revisit only if Apple flags it.

**Acceptance criteria:**

- `flutter build ios --release --no-tree-shake-icons --dart-define=APP_ENV=prod` produces an IPA with `CFBundleIdentifier = io.dracaena.curtainai`.
- The same IPA's frameworks include FoundationModels, HealthKit, Aurora (or fallback) — and do NOT include any Tuya SDK.
- API calls go to the existing ThingsBoard host (`performentmarketing.ddnsgeek.com`). No proxy required.
- App icon visible on home screen is the rendered Osprey Life eagle; ASC submission attaches the full 1024×1024 with wordmark so reviewers see the brand differentiation.

## Section 5 — Pre-Submission Ops

This section is operational, not code.

**5.1 Meet with Apple (pre-clearance)** — SKIPPED for this submission

User chose not to book the 30-minute App Review consultation session for this iteration. If we get rejected, B2 in the Plan B section reopens this option as a post-mortem.

**5.2 App Review Notes v2 (lead with the strongest argument)**

Structure of the notes (in this order):

1. **Lead paragraph:** "Osprey Life" is a new AI-powered curtain-focused product within the Osprey product family — a sibling to (not a duplicate of) "Osprey Smart Home" (`osprey.i01.i01`). The two apps share a brand parent but have fundamentally different products: Osprey Smart Home is built on Tuya's OEM SDK shell as a generic multi-device controller; Osprey Life is a separate codebase built from scratch in Flutter on top of ThingsBoard, with on-device AI (Foundation Models) as the primary user interaction surface. The binaries share no frameworks. This brand-family-with-distinct-products pattern follows the multi-product publishing model Apple already accepts for Apple Music / Apple TV+ / Apple Fitness+, Disney+ / ESPN, and for B2B publishers like VEXERE JOINT STOCK COMPANY (developer id 1183279478, 11+ travel apps for different bus operators).
2. **Four screenshots highlighting the new differentiators**, each captioned: chat-first home, voice onboarding, HealthKit wake-aware card, slash command picker.
3. **Backend distinction:** ThingsBoard (custom) vs Tuya (OEM), separate hosts, separate auth.
4. **Privacy posture:** Foundation Models run on-device; HealthKit data never leaves the device.
5. **Demo credentials:** `lam.nguyen@dracaena.io` / `Lam1234`.
6. **Step-by-step test:** how to reproduce voice flow, chat flow, HealthKit suggestion.
7. **B2B context:** Dracaena is a curtain manufacturer; this app ships to their customers. The reference Osprey Smart Home serves a different customer base entirely.

**5.3 Submission package**

- IPA built with `fvm flutter build ios --release --no-tree-shake-icons --dart-define=APP_ENV=prod`.
- 18 sized icons rendered from the new 1024×1024 master.
- Screenshots: 4 iPhone 6.7" + 3 iPad Pro 12.9" highlighting the differentiators (re-shoot, don't reuse the eagle-era ones).
- ASC metadata: name, subtitle, description, keywords, promotional text — copy from the existing `com.osprey.homeapp` record (already AI-focused) to the new app record via the asc-mcp tools once user provides the new app ID.

## Plan B — If Rejected Again

A rejected app keeps its bundle ID. Bundle IDs are only retired upon deletion, which Apple blocks for rejected apps anyway. So a third rejection is recoverable, not terminal.

**B1. Formal appeal** — submit through the Resolution Center "Submit an Appeal" link within 7 days of the rejection. Attach Dracaena business registration, the four differentiator screenshots, and a side-by-side framework manifest showing no Tuya SDK in Curtain AI. Appeal letter template is drafted upfront and stored at `docs/asc-appeal-letter-template.md` (to be created).

**B2. Meet with Apple post-mortem** — if the appeal stalls, book another 1:1 session, this time post-rejection. Bring the rejection text and ask specifically which differentiator the reviewer found insufficient.

**B3. Backup bundle IDs** — register `ai.curtainshade.app` and `com.curtainai.app` in parallel with the primary `io.dracaena.curtainai`. If the primary's bundle ID becomes irrecoverable, we can ship from a backup with another round of changes.

**B4. B2B Custom App Distribution** — Apple's Custom App program lets us distribute privately to specific Apple Business Manager organisations without going through public App Store review. Requires Dracaena's customers to have ABM accounts, which is a higher bar but bypasses 4.3 entirely. Treat as escape hatch, not primary path.

**B5. Radical pivot** — if B1-B4 fail, pause submission for 4-6 weeks, refactor the app into a Health & Fitness category (Sleep & Circadian Wellness Assistant where curtain control is one of several wellness actions), then submit from a backup bundle ID. This is last resort because it requires real product re-design.

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| Reviewer still sees same Flutter binary signature | Medium | Heavy native additions (HealthKit, FoundationModels, Aurora PlatformView) change linked frameworks; reviewer notes lead with the Tuya OEM vs custom Flutter framework manifest |
| Same dev team `FJU9H2Z6H8` triggers spam pattern | Medium | VEXERE precedent cited; B2B Dracaena positioning |
| App name "Osprey Life" reads as a sister product to "Osprey Smart Home" | Medium-High (user-accepted) | App Review notes lead with brand-family precedent (Apple Music / Apple TV+ / Disney+ / ESPN); rely on functional differentiators (chat-first, voice, HealthKit) to carry the "different primary purpose" argument |
| **Keyword squat risk**: `osprey.i01.i01` keywords include "Osprey Smart Life" + domain `osprey.life`; our app name "Osprey Life" is one word short of theirs and matches their domain | **Medium-High (user-accepted 2026-05-20)** | Confirmed by ASC pull: `osprey.i01.i01` keywords = "Osprey Smart Life,Osprey"; marketing/support URL = `osprey.life`. User chose to keep "Osprey Life" name despite this overlap. Categories changed to PRODUCTIVITY + HEALTH_AND_FITNESS to differentiate at the category layer; description vocabulary intentionally diverges (AI/Apple Intelligence/HealthKit vs. their "seamless living/connected world") |
| Icon auto-hash still matches osprey.i01.i01 at small render size | **Higher (user-accepted)** | Full Osprey Life wordmark visible in 1024×1024 master attached to ASC; rejection notes explicitly call out the eagle+wordmark vs stripped-"O" distinction; if flagged, Plan B1 (formal appeal) leads with this evidence |
| No backend proxy ⇒ ThingsBoard host is same as previous rejected submission | Low-Medium (user-accepted) | The *live* reference (`osprey.i01.i01`) uses Tuya hosts, so we're still differentiated from the comparison target. The previous Curtain AI submission's host being the same doesn't matter because that submission is in Rejected state, not live |
| No Meet with Apple ⇒ no pre-clearance feedback | Medium (user-accepted) | Plan B2 reopens this option if rejected |
| HealthKit permission rejected by reviewer (privacy concern) | Low | Clear `NSHealthShareUsageDescription`; on-device only; user can skip in onboarding |
| URL scheme `osprey://` flagged as inconsistent with new brand | Low | Documented as legacy OAuth scheme; only revisit if Apple raises it |
| `--no-tree-shake-icons` flag forgotten during release build | Medium | Add a `tool/build-release.sh` script that always sets the flag; document in `README.md` build section |
| Backend proxy `curtain-api.dracaena.io` not ready by submission day | Medium | User sets up DNS + nginx proxy as the first task; app config defaults to proxy hostname; fallback to direct ThingsBoard only in dev builds |

## Out of Scope (explicitly)

- Native Swift rewrite of iOS layer
- Migrating off Flutter
- Pivoting to Health & Fitness category as primary (only as Plan B5)
- Removing curtain device control from the app
- Changing the OAuth `osprey://` callback scheme (would break Alexa + Google links)
- Building an Android-specific equivalent of the HealthKit feature (Android graceful-degrades)

## Open Questions for User

All three previously open questions were resolved on 2026-05-20:

1. ~~Backend proxy~~ → SKIPPED (point directly at existing ThingsBoard).
2. ~~App icon designer / ETA~~ → User provides the Osprey Life 1024×1024 master; drop into `assets/icon/osprey_life_master_1024.png`.
3. ~~Meet with Apple booking~~ → SKIPPED for this submission; revisit only if rejected (Plan B2).

Remaining items needing user action before implementation begins:

- User registers the new bundle identifier `io.dracaena.curtainai` (or an alternative they prefer) at developer.apple.com/account/resources/identifiers.
- User creates the new app record in App Store Connect for the chosen bundle ID and shares the new app ID with Claude (for asc-mcp metadata population).
- User confirms `assets/icon/osprey_life_master_1024.png` will land in the repo before the icon-rendering step runs.

## Next Step

After user reviews and approves this updated spec, invoke the `writing-plans` skill to convert the five sections into a sequenced implementation plan with dependencies and verification steps.
