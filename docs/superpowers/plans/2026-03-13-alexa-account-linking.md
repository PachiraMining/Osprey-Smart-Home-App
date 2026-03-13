# Alexa Account Linking Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement native Alexa account linking flow — generate auth code, login with Amazon via native SDK, enable skill via Amazon API — replacing the current browser-redirect approach.

**Architecture:** Dart page calls Osprey backend for auth code, then invokes native LWA SDK via platform channel for Amazon token, then calls Amazon Skill Enablement API to complete linking. Android platform channel already exists; iOS needs to be implemented.

**Tech Stack:** Flutter (Dart), native LWA SDK (Android: jar already included, iOS: CocoaPods `LoginWithAmazon`), platform channels, http package

**Spec:** `docs/superpowers/specs/2026-03-13-alexa-account-linking-design.md`

---

## File Map

| File | Action | Responsibility |
|------|--------|---------------|
| `ios/Podfile` | Modify | Add LoginWithAmazon pod dependency |
| `ios/Runner/AppDelegate.swift` | Modify | LWA platform channel (`signIn`/`signOut`) + URL handling |
| `lib/features/home/presentation/pages/alexa_linking_page.dart` | Modify | 3-step linking flow, unlink, remove browser approach |

**Files that remain unchanged:**
- `android/` — Android LWA integration is already complete
- `lib/core/` — No new DI, repositories, or BLoCs needed
- `home_page.dart` — Navigation to AlexaLinkingPage already wired

---

## Task 1: iOS — Add LoginWithAmazon CocoaPods Dependency

**Files:**
- Modify: `ios/Podfile`

- [ ] **Step 1: Add pod to Podfile**

In `ios/Podfile`, inside the `target 'Runner' do` block, add `pod 'LoginWithAmazon'` after `use_frameworks!`:

```ruby
target 'Runner' do
  use_frameworks!
  pod 'LoginWithAmazon'

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
```

- [ ] **Step 2: Run pod install**

```bash
cd ios && pod install --repo-update
```

Expected: Pod installed successfully. If `LoginWithAmazon` pod is not found on CocoaPods, skip this step — the user will need to manually download and embed the LoginWithAmazon.framework from Amazon Developer Portal into `ios/Frameworks/` and link it in Xcode.

- [ ] **Step 3: Commit**

```bash
git add ios/Podfile ios/Podfile.lock
git commit -m "feat(ios): add LoginWithAmazon pod dependency"
```

---

## Task 2: iOS — Implement LWA Platform Channel

**Files:**
- Modify: `ios/Runner/AppDelegate.swift`

The platform channel name and method signatures MUST match the existing Android implementation in `MainActivity.kt` (channel: `com.osprey/alexa_lwa`, methods: `signIn`, `signOut`).

- [ ] **Step 1: Write AppDelegate.swift with LWA platform channel**

Replace the entire `ios/Runner/AppDelegate.swift` with:

```swift
import Flutter
import UIKit
import LoginWithAmazon

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
    private var pendingResult: FlutterResult?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

        let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "AlexaLwaPlugin")
        guard let messenger = registrar?.messenger() else { return }

        let channel = FlutterMethodChannel(name: "com.osprey/alexa_lwa", binaryMessenger: messenger)
        channel.setMethodCallHandler { [weak self] (call, result) in
            switch call.method {
            case "signIn":
                self?.handleSignIn(call: call, result: result)
            case "signOut":
                self?.handleSignOut(result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    // MARK: - LWA Sign In

    private func handleSignIn(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let scopes = args["scopes"] as? [String] else {
            result(["status": "error", "error": "Invalid arguments"])
            return
        }

        pendingResult = result

        var scopeObjects: [AMZNScope] = []
        for scope in scopes {
            switch scope {
            case "profile":
                scopeObjects.append(AMZNProfileScope.profile())
            case "postal_code":
                scopeObjects.append(AMZNProfileScope.postalCode())
            default:
                scopeObjects.append(AMZNScopeFactory.scope(withName: scope))
            }
        }

        let request = AMZNAuthorizeRequest()
        request.scopes = scopeObjects
        request.interactiveStrategy = .always

        AMZNAuthorizationManager.shared().authorize(request) { [weak self] (authResult, userDidCancel, error) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let error = error {
                    self.pendingResult?([
                        "status": "error",
                        "error": error.localizedDescription,
                        "errorType": String(describing: type(of: error))
                    ])
                } else if userDidCancel {
                    self.pendingResult?([
                        "status": "cancelled",
                        "description": "User cancelled"
                    ])
                } else if let authResult = authResult {
                    self.pendingResult?([
                        "status": "success",
                        "accessToken": authResult.token ?? ""
                    ])
                } else {
                    self.pendingResult?(["status": "error", "error": "Unknown error"])
                }
                self.pendingResult = nil
            }
        }
    }

    // MARK: - LWA Sign Out

    private func handleSignOut(result: @escaping FlutterResult) {
        AMZNAuthorizationManager.shared().signOut { (error) in
            DispatchQueue.main.async {
                if let error = error {
                    result(["status": "error", "error": error.localizedDescription])
                } else {
                    result(["status": "success"])
                }
            }
        }
    }

    // MARK: - URL Handling for LWA callback

    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if AMZNAuthorizationManager.handleOpen(url, sourceApplication: options[.sourceApplication] as? String) {
            return true
        }
        return super.application(app, open: url, options: options)
    }
}
```

**Key points:**
- Channel name `com.osprey/alexa_lwa` matches Android's `MainActivity.kt`
- `signIn` method accepts `scopes` list, uses `AMZNScopeFactory.scope(withName:)` for custom scopes like `alexa::skills:account_linking`
- `interactiveStrategy = .always` forces fresh login (matches Android's `clearLwaCache()` approach)
- Response format matches Android: `{"status": "success", "accessToken": "..."}` or `{"status": "error", "error": "..."}`
- URL handling forwards LWA callbacks via `AMZNAuthorizationManager.handleOpen`

- [ ] **Step 2: Verify build**

```bash
cd /Users/thuannguyen/Smart_Home_App && flutter build ios --no-codesign
```

Expected: Build succeeds. If LoginWithAmazon pod import fails, the user needs to download the framework manually from Amazon Developer Portal.

- [ ] **Step 3: Commit**

```bash
git add ios/Runner/AppDelegate.swift
git commit -m "feat(ios): implement LWA platform channel for Alexa account linking"
```

---

## Task 3: Dart — Rewrite Alexa Linking Flow

**Files:**
- Modify: `lib/features/home/presentation/pages/alexa_linking_page.dart`

This task replaces the browser-redirect approach with the proper 3-step native flow and adds unlink functionality.

- [ ] **Step 1: Rewrite alexa_linking_page.dart**

Replace the entire file with the implementation below. Key changes from the current version:
- Remove `url_launcher` import and `WidgetsBindingObserver` (no longer opening browser)
- Add `MethodChannel` for native LWA SDK calls
- Add constants: `_skillId`, `_alexaRedirectUri`, `_alexaApiBase`
- Rewrite `_startLinking()` with 3-step flow (generate code → LWA login → enable skill)
- Add `_unlinkAccount()` method
- Add UNLINK button to `_buildLinkedView()`

```dart
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import '../../../../core/auth/token_manager.dart';

class AlexaLinkingPage extends StatefulWidget {
  const AlexaLinkingPage({super.key});

  @override
  State<AlexaLinkingPage> createState() => _AlexaLinkingPageState();
}

class _AlexaLinkingPageState extends State<AlexaLinkingPage> {
  static const _tag = 'AlexaLinking';
  static const _baseUrl = 'https://performentmarketing.ddnsgeek.com';
  static const _skillId =
      'amzn1.ask.skill.2cef70ff-5632-411b-9948-994b959ea8a7';
  static const _alexaRedirectUri =
      'https://layla.amazon.com/api/skill/link/M2NOX6EY61J6ZS';
  static const _alexaApiBase = 'https://api.amazonalexa.com';

  /// Platform channel matching Android (MainActivity.kt) and iOS (AppDelegate.swift)
  static const _lwaChannel = MethodChannel('com.osprey/alexa_lwa');

  final _tokenManager = GetIt.instance<TokenManager>();
  final _client = GetIt.instance<http.Client>();

  bool _isLoading = true;
  bool _isLinked = false;
  bool _isLinking = false;
  bool _isUnlinking = false;
  String? _error;

  Map<String, String> get _ospreyHeaders => {
        'Content-Type': 'application/json',
        'accept': 'application/json',
        'X-Authorization': 'Bearer ${_tokenManager.getTokenSync() ?? ''}',
      };

  @override
  void initState() {
    super.initState();
    log('initState — checking linking status', name: _tag);
    _checkLinkingStatus();
  }

  // ─── API 0: Check trạng thái linking ───
  Future<void> _checkLinkingStatus() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final url = '$_baseUrl/api/alexa/app-linking/status';
    log('API 0: GET $url', name: _tag);

    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: _ospreyHeaders,
      );

      log('API 0 response: ${response.statusCode} — ${response.body}',
          name: _tag);

      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final linked = data['linked'] == true;
        log('Linked: $linked', name: _tag);
        setState(() {
          _isLinked = linked;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to check status: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      log('API 0 error: $e', name: _tag, error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() {
        _error = 'Connection error';
        _isLoading = false;
      });
    }
  }

  // ─── 3-step linking flow ───
  Future<void> _startLinking() async {
    setState(() {
      _isLinking = true;
      _error = null;
    });

    try {
      // Step 1: Generate auth code from Osprey backend
      log('Step 1: Generating auth code...', name: _tag);
      final authCode = await _generateAuthCode();
      if (authCode == null) return; // error already set

      // Step 2: Login with Amazon (native SDK via platform channel)
      log('Step 2: Login with Amazon...', name: _tag);
      final amazonToken = await _loginWithAmazon();
      if (amazonToken == null) return; // cancelled or error already set

      // Step 3: Enable skill + link account via Amazon API
      log('Step 3: Enabling skill...', name: _tag);
      await _enableSkill(amazonToken, authCode);
    } catch (e, stack) {
      log('Linking error: $e', name: _tag, error: e, stackTrace: stack);
      _setError('An error occurred. Please try again.');
    }
  }

  /// API 1: POST /api/alexa/app-linking/generate-code → authCode
  Future<String?> _generateAuthCode() async {
    final url = '$_baseUrl/api/alexa/app-linking/generate-code';
    log('API 1: POST $url', name: _tag);

    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: _ospreyHeaders,
      );

      log('API 1 response: ${response.statusCode} — ${response.body}',
          name: _tag);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final code = data['authCode'] as String?;
        if (code != null && code.isNotEmpty) {
          log('Auth code received (${code.length} chars)', name: _tag);
          return code;
        }
      }
      _setError('Failed to generate auth code: ${response.statusCode}');
      return null;
    } catch (e) {
      log('API 1 error: $e', name: _tag);
      _setError('Connection error. Please try again.');
      return null;
    }
  }

  /// API 2: Login with Amazon via native SDK (platform channel)
  Future<String?> _loginWithAmazon() async {
    try {
      final result = await _lwaChannel.invokeMethod<Map<Object?, Object?>>(
        'signIn',
        {'scopes': ['alexa::skills:account_linking']},
      );

      if (result == null) {
        _setError('Login with Amazon failed: no response');
        return null;
      }

      final status = result['status'] as String?;
      log('LWA result: status=$status', name: _tag);

      switch (status) {
        case 'success':
          final token = result['accessToken'] as String?;
          if (token != null && token.isNotEmpty) {
            log('Amazon access token received (${token.length} chars)',
                name: _tag);
            return token;
          }
          _setError('Login with Amazon failed: empty token');
          return null;

        case 'cancelled':
          log('User cancelled Amazon login', name: _tag);
          // Don't show error — user intentionally cancelled
          if (mounted) {
            setState(() {
              _isLinking = false;
            });
          }
          return null;

        case 'error':
          final error = result['error'] as String? ?? 'Unknown error';
          log('LWA error: $error', name: _tag);
          _setError('Amazon login failed: $error');
          return null;

        default:
          _setError('Unexpected login response');
          return null;
      }
    } on PlatformException catch (e) {
      log('Platform channel error: ${e.message}', name: _tag);
      _setError('Login with Amazon not available: ${e.message}');
      return null;
    }
  }

  /// API 3: Enable skill + link account via Amazon Skill Enablement API
  Future<void> _enableSkill(String amazonToken, String authCode) async {
    final url =
        '$_alexaApiBase/v1/users/~current/skills/$_skillId/enablement';
    log('API 3: POST $url', name: _tag);

    final body = jsonEncode({
      'stage': 'development', // Change to 'live' when skill is published
      'accountLinkRequest': {
        'redirectUri': _alexaRedirectUri,
        'authCode': authCode,
        'type': 'AUTH_CODE',
      },
    });

    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $amazonToken',
        },
        body: body,
      );

      log('API 3 response: ${response.statusCode} — ${response.body}',
          name: _tag);

      if (!mounted) return;

      switch (response.statusCode) {
        case 200:
        case 201:
          // Successfully linked
          log('Account linked successfully!', name: _tag);
          setState(() {
            _isLinked = true;
            _isLinking = false;
          });
          _showSnackBar('Account linked successfully!', Colors.green);

        case 409:
          // Already linked — treat as success
          log('Skill already enabled (409)', name: _tag);
          setState(() {
            _isLinked = true;
            _isLinking = false;
          });
          _showSnackBar('Account already linked.', Colors.green);

        case 401:
          _setError('Amazon token expired. Please try again.');
        case 400:
          _setError('Auth code expired. Please try again.');
        case 403:
          _setError(
              'Access denied. Your Amazon account must be a developer or beta tester for this skill.');
        default:
          _setError('Linking failed (${response.statusCode}). Please try again.');
      }
    } catch (e) {
      log('API 3 error: $e', name: _tag);
      _setError('Connection error. Please try again.');
    }
  }

  // ─── Unlink ───
  Future<void> _unlinkAccount() async {
    setState(() {
      _isUnlinking = true;
      _error = null;
    });

    try {
      // Step 1: Get Amazon token via LWA signIn (need token for DELETE call)
      log('Unlink Step 1: Getting Amazon token...', name: _tag);
      final amazonToken = await _loginWithAmazon();
      if (amazonToken == null) {
        if (mounted) setState(() => _isUnlinking = false);
        return;
      }

      // Step 2: Delete skill enablement via Amazon API
      final url =
          '$_alexaApiBase/v1/users/~current/skills/$_skillId/enablement';
      log('Unlink Step 2: DELETE $url', name: _tag);

      final response = await _client.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $amazonToken',
        },
      );

      log('Unlink response: ${response.statusCode}', name: _tag);

      // Step 3: Sign out of LWA
      log('Unlink Step 3: LWA signOut...', name: _tag);
      await _lwaChannel.invokeMethod('signOut');

      if (!mounted) return;

      if (response.statusCode == 204 || response.statusCode == 200) {
        setState(() {
          _isLinked = false;
          _isUnlinking = false;
        });
        _showSnackBar('Account unlinked.', Colors.orange);
      } else if (response.statusCode == 404) {
        // Not linked — just update UI
        setState(() {
          _isLinked = false;
          _isUnlinking = false;
        });
      } else {
        _setError('Unlink failed (${response.statusCode}).');
        setState(() => _isUnlinking = false);
      }
    } catch (e, stack) {
      log('Unlink error: $e', name: _tag, error: e, stackTrace: stack);
      if (mounted) {
        _setError('Failed to unlink. Please try again.');
        setState(() => _isUnlinking = false);
      }
    }
  }

  void _setError(String msg) {
    log('ERROR: $msg', name: _tag);
    if (!mounted) return;
    setState(() {
      _error = msg;
      _isLinking = false;
    });
  }

  void _showSnackBar(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Amazon Alexa',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null && !_isLinked
              ? _buildErrorView()
              : _isLinked
                  ? _buildLinkedView()
                  : _buildUnlinkedView(),
    );
  }

  Widget _buildUnlinkedView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Image.asset('assets/icons/alexa_logo.png', width: 80, height: 80),
          const SizedBox(height: 24),
          const Text(
            'Link Osprey with Alexa',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Link your Osprey account with Amazon Alexa to control your smart home devices with voice commands.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLinking ? null : _startLinking,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF31C4F3),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 0,
              ),
              child: _isLinking
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'LINK',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }

  Widget _buildLinkedView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Image.asset('assets/icons/alexa_logo.png', width: 80, height: 80),
              Positioned(
                right: -4,
                bottom: -4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle,
                      color: Colors.green, size: 28),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Already linked with\nAmazon Alexa',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your Osprey account is linked with Amazon Alexa. You can now control your devices with voice commands.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: _isUnlinking ? null : _unlinkAccount,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade400,
                side: BorderSide(color: Colors.red.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: _isUnlinking
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.red.shade400,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'UNLINK',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: _checkLinkingStatus,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Remove unused url_launcher dependency if not used elsewhere**

Check if `url_launcher` is imported anywhere else in the project. If `alexa_linking_page.dart` was the only user, consider removing it from `pubspec.yaml`. If used elsewhere, skip this step.

```bash
grep -r "url_launcher" lib/ --include="*.dart" -l
```

- [ ] **Step 3: Verify build**

```bash
flutter analyze lib/features/home/presentation/pages/alexa_linking_page.dart
```

Expected: No analysis issues.

- [ ] **Step 4: Commit**

```bash
git add lib/features/home/presentation/pages/alexa_linking_page.dart
git commit -m "feat(alexa): implement native 3-step account linking flow with unlink"
```

---

## Task 4: Manual Testing on Device

This feature requires real devices (LWA SDK doesn't work in simulators).

- [ ] **Step 1: Test on Android**

```bash
flutter run -d <android-device-id>
```

Test flow:
1. Go to Me tab → tap Alexa icon
2. Verify status check loads (linked=false expected for fresh account)
3. Tap LINK → verify auth code generation
4. Verify Amazon login popup appears
5. Login with Amazon dev/beta tester account
6. Verify skill enablement succeeds → shows "Already linked" screen
7. Tap UNLINK → verify unlink flow → shows "Link Osprey with Alexa"

- [ ] **Step 2: Test on iOS**

```bash
flutter run -d <ios-device-id>
```

Same test flow as Android. Verify LWA SDK popup works on iOS.

- [ ] **Step 3: Final commit if any fixes needed**

```bash
git add -A
git commit -m "fix(alexa): address issues found during device testing"
```
