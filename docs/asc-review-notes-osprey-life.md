# Osprey Life — App Review Notes (ready to paste)

**App ID:** 6771282725
**Bundle ID:** io.dracaena.curtainai
**Version:** 1.0

## Where to paste

App Store Connect → My Apps → Osprey Life → Version 1.0 → App Review Information.

Fields to fill manually in the web UI (the API requires a phone number, so this section was not auto-populated):

- **First name:** Thuận
- **Last name:** Nguyễn
- **Phone:** *(user to fill — required, format `+84xxxxxxxxx`)*
- **Email:** thuan.nguyen@dracaena.io
- **Sign-in required:** Yes
- **User name:** lam.nguyen@dracaena.io
- **Password:** Lam1234
- **Notes:** paste the block below verbatim.

---

## Notes (paste verbatim)

Dear App Review Team,

Osprey Life is a new AI-powered, curtain-focused product within the Osprey family — a sibling to (not a duplicate of) Osprey Smart Home (id 6453695964). The two apps share a brand parent but have fundamentally different products:

• Osprey Smart Home is built on Tuya's OEM SDK shell as a generic multi-device controller. The two apps' binaries share zero frameworks. Osprey Smart Home links TuyaSmartHomeKit / TuyaSmartBLEKit; Osprey Life links FoundationModels / SpeechToText / custom Flutter modules and ships no Tuya code at all.

• Osprey Life is a separately authored codebase (Flutter on ThingsBoard) where on-device AI conversation is the primary user surface, not a peripheral feature.

This brand-family-with-distinct-products pattern follows the multi-product publishing model Apple already accepts for Apple Music / Apple TV+ / Apple Fitness+ (same brand, different primary purposes), Disney+ / ESPN, and for B2B publishers like VEXERE JOINT STOCK COMPANY (developer id 1183279478, 11+ travel apps for different bus operators).

KEY DIFFERENTIATORS FROM OSPREY SMART HOME

1. Chat-first home — the app opens to an AI conversation, not a device grid. Devices are reached via slash commands, voice, or the side drawer.
2. Slash commands — typing "/devices", "/scenes", "/schedule", or "/help" in chat brings up bottom-sheet pickers.
3. Voice control — the mic FAB transcribes speech on-device and routes the resulting intent into the chat.
4. On-device Apple Intelligence — on Apple-Intelligence-capable hardware with the feature enabled, Foundation Models parse user intent and run conversational replies locally. On other devices, a deterministic intent parser keeps the chat useful offline.

DEMO ACCOUNT
Email: lam.nguyen@dracaena.io
Password: Lam1234

STEP-BY-STEP TEST
1. Launch — splash screen shows the Osprey Life eagle wordmark + "AI curtain assistant." subtitle.
2. Tap "Get started" → simple sign-in screen (toggle between Sign in and Create account in the same page).
3. Use demo credentials to sign in.
4. The chat-first home screen appears with "Osprey Life" in the AppBar and a hamburger drawer top-left.
5. Try typing a slash command like "/help" to see available shortcuts.
6. Try a natural-language command like "open the bedroom curtain" — the assistant responds with a contextual reply.
7. Tap the mic FAB (bottom-right) to use voice; the transcript appears in the chat thread.
8. Open the drawer (hamburger top-left) to reach Devices, Tap-to-Run scenes, Add a curtain, Scan QR, Profile, and Settings.

PRIVACY POSTURE
• Apple Foundation Models (when used) run entirely on-device — no user content sent to a server for AI inference.
• Speech recognition runs on-device.
• No third-party analytics or ad SDKs.

B2B CONTEXT
Dracaena is a Vietnamese curtain manufacturer. Osprey Life ships to Dracaena's curtain customers as an AI-first companion app for their motorized shades. It is functionally and technically distinct from Osprey Smart Home, which serves a different customer base with different (Tuya-based) hardware.

Thank you for your time. We are happy to schedule a "Meet with Apple" consultation if any clarification is needed.

— Osprey Life team / Dracaena
