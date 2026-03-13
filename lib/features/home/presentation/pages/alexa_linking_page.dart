import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import '../../../../core/auth/token_manager.dart';
import '../../../../core/config/alexa_secrets.dart' as secrets;

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

  /// Alexa Client ID and Secret loaded from gitignored secrets file
  static const _alexaClientId = secrets.alexaClientId;
  static const _alexaClientSecret = secrets.alexaClientSecret;

  /// App callback scheme (registered in AndroidManifest.xml and Info.plist)
  static const _appCallbackScheme = 'osprey';
  static const _appCallbackUri = 'osprey://alexa-callback';

  /// Native LWA platform channel (for signOut only)
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
      if (authCode == null) return;

      // Step 2: Login with Amazon (web-based OAuth with Alexa Client ID)
      log('Step 2: Login with Amazon...', name: _tag);
      final amazonToken = await _loginWithAmazon();
      if (amazonToken == null) return;

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

  /// API 2: Login with Amazon via web-based OAuth flow.
  ///
  /// Uses the Alexa Client ID (not Security Profile Client ID) because
  /// only the Alexa Client ID supports the alexa::skills:account_linking scope.
  /// The native LWA SDK cannot use this scope — it's a known limitation.
  Future<String?> _loginWithAmazon() async {
    // Build LWA authorization URL with Alexa Client ID
    final authUrl = Uri.https('www.amazon.com', '/ap/oa', {
      'client_id': _alexaClientId,
      'scope': 'alexa::skills:account_linking',
      'response_type': 'code',
      'redirect_uri': _appCallbackUri,
    });

    log('Opening LWA auth URL: $authUrl', name: _tag);

    try {
      // Open browser for Amazon login, capture redirect with auth code
      final resultUrl = await FlutterWebAuth2.authenticate(
        url: authUrl.toString(),
        callbackUrlScheme: _appCallbackScheme,
      );

      log('LWA callback URL: $resultUrl', name: _tag);

      // Extract authorization code from callback URL
      final uri = Uri.parse(resultUrl);
      final code = uri.queryParameters['code'];
      final error = uri.queryParameters['error'];

      if (error != null) {
        log('LWA auth error: $error', name: _tag);
        final desc = uri.queryParameters['error_description'] ?? error;
        _setError('Amazon login failed: $desc');
        return null;
      }

      if (code == null || code.isEmpty) {
        _setError('Amazon login failed: no authorization code received');
        return null;
      }

      log('LWA auth code received, exchanging for token...', name: _tag);

      // Exchange authorization code for access token
      return await _exchangeCodeForToken(code);
    } catch (e) {
      log('LWA error: $e', name: _tag);
      // User cancelled the browser or other error
      if (e.toString().contains('CANCELED') ||
          e.toString().contains('cancelled')) {
        log('User cancelled Amazon login', name: _tag);
        if (mounted) {
          setState(() => _isLinking = false);
        }
        return null;
      }
      _setError('Amazon login failed: $e');
      return null;
    }
  }

  /// Exchange LWA authorization code for access token using Alexa Client credentials
  Future<String?> _exchangeCodeForToken(String code) async {
    const tokenUrl = 'https://api.amazon.com/auth/o2/token';
    log('Exchanging code for token at $tokenUrl', name: _tag);

    try {
      final response = await _client.post(
        Uri.parse(tokenUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': _appCallbackUri,
          'client_id': _alexaClientId,
          'client_secret': _alexaClientSecret,
        },
      );

      log('Token exchange response: ${response.statusCode}', name: _tag);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data['access_token'] as String?;
        if (accessToken != null && accessToken.isNotEmpty) {
          log('Amazon access token received (${accessToken.length} chars)',
              name: _tag);
          return accessToken;
        }
      }

      log('Token exchange failed: ${response.body}', name: _tag);
      _setError('Failed to get Amazon token. Please try again.');
      return null;
    } catch (e) {
      log('Token exchange error: $e', name: _tag);
      _setError('Connection error during token exchange.');
      return null;
    }
  }

  /// API 3: Enable skill + link account via Amazon Skill Enablement API
  Future<void> _enableSkill(String amazonToken, String authCode) async {
    final url =
        '$_alexaApiBase/v1/users/~current/skills/$_skillId/enablement';
    log('API 3: POST $url', name: _tag);

    final body = jsonEncode({
      'stage': 'development',
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
          log('Account linked successfully!', name: _tag);
          setState(() {
            _isLinked = true;
            _isLinking = false;
          });
          _showSnackBar('Account linked successfully!', Colors.green);

        case 409:
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
          _setError(
              'Linking failed (${response.statusCode}). Please try again.');
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
      // Step 1: Get Amazon token via web-based LWA
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

      // Step 3: Sign out of LWA (native SDK to clear cached tokens)
      log('Unlink Step 3: LWA signOut...', name: _tag);
      try {
        await _lwaChannel.invokeMethod('signOut');
      } catch (e) {
        log('LWA signOut error (non-critical): $e', name: _tag);
      }

      if (!mounted) return;

      if (response.statusCode == 204 || response.statusCode == 200) {
        setState(() {
          _isLinked = false;
          _isUnlinking = false;
        });
        _showSnackBar('Account unlinked.', Colors.orange);
      } else if (response.statusCode == 404) {
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
