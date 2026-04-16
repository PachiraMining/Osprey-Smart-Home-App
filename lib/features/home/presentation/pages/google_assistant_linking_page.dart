import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/auth/token_manager.dart';
import '../../../../core/config/app_config.dart';

class GoogleAssistantLinkingPage extends StatefulWidget {
  const GoogleAssistantLinkingPage({super.key});

  @override
  State<GoogleAssistantLinkingPage> createState() =>
      _GoogleAssistantLinkingPageState();
}

class _GoogleAssistantLinkingPageState
    extends State<GoogleAssistantLinkingPage> with WidgetsBindingObserver {
  static const _baseUrl = AppConfig.thingsboardBaseUrl;
  static const _callbackScheme = AppConfig.callbackScheme;

  final _tokenManager = GetIt.instance<TokenManager>();
  final _client = GetIt.instance<http.Client>();

  bool _isLoading = true;
  bool _isLinked = false;
  bool _isLinking = false;
  bool _waitingForGoogleHome = false;
  String? _error;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'accept': 'application/json',
        'X-Authorization': 'Bearer ${_tokenManager.getTokenSync() ?? ''}',
      };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-check status when user returns from Google Home app
    if (state == AppLifecycleState.resumed && _waitingForGoogleHome) {
      _waitingForGoogleHome = false;
      _checkStatus();
    }
  }

  // ─── API 0: Check trạng thái linking ───
  Future<void> _checkStatus() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final url = '$_baseUrl/api/google/app-linking/status';

    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: _headers,
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _isLinked = data['linked'] == true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to check status: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Connection error';
        _isLoading = false;
      });
    }
  }

  // ─── API 1: Start linking ───
  Future<void> _startLinking() async {
    setState(() {
      _isLinking = true;
      _error = null;
    });

    try {
      // Step 1: POST /start → get URLs and state from backend
      final startUrl = '$_baseUrl/api/google/app-linking/start';
      final startRes = await _client.post(
        Uri.parse(startUrl),
        headers: _headers,
      );

      if (startRes.statusCode != 200 && startRes.statusCode != 201) {
        _setError('Failed to start linking: ${startRes.statusCode}');
        return;
      }

      final startData = jsonDecode(startRes.body);
      final googleHomeUrl = startData['googleHomeUrl'] as String;
      final browserFallbackUrl = startData['browserFallbackUrl'] as String;

      // Step 2: Check if Google Home app is installed
      final hasGoogleHome = await _isGoogleHomeInstalled();

      if (hasGoogleHome) {
        // Open Google Home app
        _waitingForGoogleHome = true;
        final launched = await launchUrl(
          Uri.parse(googleHomeUrl),
          mode: LaunchMode.externalApplication,
        );
        if (!launched) {
          _waitingForGoogleHome = false;
          _setError('Could not open Google Home app');
          return;
        }
        // Status will be re-checked in didChangeAppLifecycleState
        if (mounted) setState(() => _isLinking = false);
      } else {
        // Open browser fallback
        final resultUrl = await FlutterWebAuth2.authenticate(
          url: browserFallbackUrl,
          callbackUrlScheme: _callbackScheme,
        );

        final uri = Uri.parse(resultUrl);
        final error = uri.queryParameters['error'];

        if (error != null) {
          _setError('Linking failed: $error');
          return;
        }

        // Step 3: Re-check status
        if (mounted) {
          setState(() => _isLinking = false);
          await _checkStatus();
          if (_isLinked) {
            _showSnackBar('Account linked successfully!', Colors.green);
          }
        }
      }
    } catch (e) {
      if (e.toString().contains('CANCELED') ||
          e.toString().contains('cancelled')) {
        if (mounted) setState(() => _isLinking = false);
        return;
      }
      _setError('An error occurred. Please try again.');
    }
  }

  Future<bool> _isGoogleHomeInstalled() async {
    try {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          // Try to launch Google Home package on Android
          return await canLaunchUrl(
            Uri.parse(
                'android-app://com.google.android.apps.chromecast.app'),
          );
        case TargetPlatform.iOS:
          return await canLaunchUrl(Uri.parse('googlehome://'));
        default:
          return false;
      }
    } catch (_) {
      return false;
    }
  }

  void _setError(String msg) {
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
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isLinked)
            TextButton(
              onPressed: _startLinking,
              child: const Text(
                'Re-Login',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null && !_isLinked
                ? _buildErrorView()
                : _isLinked
                    ? _buildLinkedView()
                    : _buildUnlinkedView(),
      ),
    );
  }

  // ─── Chưa linked ───
  Widget _buildUnlinkedView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Google Assistant logo + title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icons/google_assistant_logo.png',
                width: 40,
                height: 40,
              ),
              const SizedBox(width: 10),
              const Text(
                'Google Assistant',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          // Illustration row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Chat bubble
              Icon(Icons.chat_bubble, size: 44, color: Colors.lightBlue.shade400),
              const SizedBox(width: 8),
              // Sound waves
              Icon(Icons.sensors, size: 36, color: Colors.amber.shade600),
              const SizedBox(width: 8),
              // Smart speaker
              Icon(Icons.speaker, size: 48, color: Colors.lightBlue.shade300),
              const SizedBox(width: 8),
              // Arrow
              Icon(Icons.arrow_forward, size: 32, color: Colors.amber.shade600),
              const SizedBox(width: 8),
              // Lightbulb
              Icon(Icons.lightbulb_outline, size: 44, color: Colors.lightBlue.shade400),
            ],
          ),
          const SizedBox(height: 40),
          // Description text
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'After connecting your App account and Google  account, '
              'you can use Google Home Smart Speakers to control '
              'devices that work with Google Assistant.  For example, '
              'you can say, "OK Google, please turn on  the light."',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.6,
              ),
            ),
          ),
          const Spacer(),
          // Link button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLinking ? null : _startLinking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  disabledBackgroundColor:
                      const Color(0xFF2196F3).withAlpha(150),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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
                        'Link with Google Assistant',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // View more ways to link
          TextButton(
            onPressed: () {},
            child: Text(
              'View more ways to link',
              style: TextStyle(
                fontSize: 15,
                color: Colors.blue.shade600,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ─── Đã linked ───
  Widget _buildLinkedView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Google Assistant logo (centered, larger)
          Image.asset(
            'assets/icons/google_assistant_logo.png',
            width: 80,
            height: 80,
          ),
          const SizedBox(height: 24),
          // Title
          const Text(
            'Linked with Google Assistant',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          // Subtitle
          Text(
            'You can now use Google Home voicebox to\ncontrol Google Assistant devices, like',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          // Example commands
          _buildExampleCommand('OK Google, turn on light'),
          _buildExampleCommand('OK Google, brighten my light'),
          _buildExampleCommand('OK Google, change kitchen lamp to blue'),
          _buildExampleCommand('OK Google, set my light to 50%'),
          const SizedBox(height: 8),
          // View more ways to link
          TextButton(
            onPressed: () {},
            child: Text(
              'View more ways to link',
              style: TextStyle(
                fontSize: 15,
                color: Colors.blue.shade600,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Back button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Note about unlinking
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Disable Osprey skill on the Google Home app '
              'or tap Me > the Setting button in the top right corner '
              '> Account and Security to unauthorize it.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildExampleCommand(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
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
              onPressed: _checkStatus,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
