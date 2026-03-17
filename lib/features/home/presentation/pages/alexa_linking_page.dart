import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import '../../../../core/auth/token_manager.dart';

class AlexaLinkingPage extends StatefulWidget {
  const AlexaLinkingPage({super.key});

  @override
  State<AlexaLinkingPage> createState() => _AlexaLinkingPageState();
}

class _AlexaLinkingPageState extends State<AlexaLinkingPage> {
  static const _baseUrl = 'https://performentmarketing.ddnsgeek.com';
  static const _callbackScheme = 'osprey';

  final _tokenManager = GetIt.instance<TokenManager>();
  final _client = GetIt.instance<http.Client>();

  bool _isLoading = true;
  bool _isLinked = false;
  bool _isLinking = false;
  String? _error;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'accept': 'application/json',
        'X-Authorization': 'Bearer ${_tokenManager.getTokenSync() ?? ''}',
      };

  @override
  void initState() {
    super.initState();
    debugPrint('[Alexa]initState — checking linking status');
    _checkStatus();
  }

  // ─── API 0: Check trạng thái linking ───
  Future<void> _checkStatus() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final url = '$_baseUrl/api/alexa/app-linking/status';
    debugPrint('[Alexa]API 0: GET $url');

    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: _headers,
      );

      debugPrint('[Alexa]API 0 response: ${response.statusCode} — ${response.body}');

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
    } catch (e, stack) {
      debugPrint('[Alexa]API 0 error: $e');
      if (!mounted) return;
      setState(() {
        _error = 'Connection error';
        _isLoading = false;
      });
    }
  }

  // ─── 3-step linking flow (V2 — backend-driven) ───
  Future<void> _startLinking() async {
    setState(() {
      _isLinking = true;
      _error = null;
    });

    try {
      // Step 1: POST /start → get URLs and state from backend
      debugPrint('[Alexa]Step 1: Starting linking...');
      final startUrl = '$_baseUrl/api/alexa/app-linking/start';
      final startRes = await _client.post(
        Uri.parse(startUrl),
        headers: _headers,
      );

      debugPrint('[Alexa]API 1 response: ${startRes.statusCode} — ${startRes.body}');

      if (startRes.statusCode != 200 && startRes.statusCode != 201) {
        _setError('Failed to start linking: ${startRes.statusCode}');
        return;
      }

      final startData = jsonDecode(startRes.body);
      final lwaUrl = startData['lwaFallbackUrl'] as String;
      final state = startData['state'] as String;
      debugPrint('[Alexa]Got LWA URL and state from backend');

      // Step 2: Open browser → user login Amazon → receive callback
      debugPrint('[Alexa]Step 2: Opening Amazon login...');
      final resultUrl = await FlutterWebAuth2.authenticate(
        url: lwaUrl,
        callbackUrlScheme: _callbackScheme,
      );

      debugPrint('[Alexa]Callback URL: $resultUrl');

      final uri = Uri.parse(resultUrl);
      final code = uri.queryParameters['code'];
      final error = uri.queryParameters['error'];

      if (error != null) {
        final desc = uri.queryParameters['error_description'] ?? error;
        _setError('Amazon login failed: $desc');
        return;
      }

      if (code == null || code.isEmpty) {
        _setError('No authorization code received');
        return;
      }

      // Step 3: POST /complete → backend handles everything
      debugPrint('[Alexa]Step 3: Completing linking...');
      final completeUrl = '$_baseUrl/api/alexa/app-linking/complete';
      final completeRes = await _client.post(
        Uri.parse(completeUrl),
        headers: _headers,
        body: jsonEncode({
          'amazonAuthCode': code,
          'state': state,
        }),
      );

      debugPrint('[Alexa]API 3 response: ${completeRes.statusCode} — ${completeRes.body}');

      if (!mounted) return;

      final completeData = jsonDecode(completeRes.body);
      if (completeData['success'] == true) {
        setState(() {
          _isLinked = true;
          _isLinking = false;
        });
        _showSnackBar('Account linked successfully!', Colors.green);
      } else {
        _setError(completeData['message'] as String? ?? 'Linking failed');
      }
    } catch (e, stack) {
      debugPrint('[Alexa]Linking error: $e');
      if (e.toString().contains('CANCELED') ||
          e.toString().contains('cancelled')) {
        if (mounted) setState(() => _isLinking = false);
        return;
      }
      _setError('An error occurred. Please try again.');
    }
  }

  void _setError(String msg) {
    debugPrint('[Alexa]ERROR: $msg');
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

  Widget _buildUnlinkedView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Alexa logo + title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/icons/alexa_logo.png', width: 40, height: 40),
              const SizedBox(width: 10),
              const Text(
                'amazon alexa',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
          // Illustration row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Speech bubble
              Icon(Icons.chat_bubble, size: 44, color: Colors.cyan.shade400),
              const SizedBox(width: 12),
              // WiFi signal
              Icon(Icons.wifi, size: 36, color: Colors.amber.shade600),
              const SizedBox(width: 12),
              // Echo speaker
              Icon(Icons.speaker, size: 52, color: Colors.cyan.shade300),
              const SizedBox(width: 12),
              // Arrow
              Icon(Icons.arrow_forward, size: 32, color: Colors.amber.shade600),
              const SizedBox(width: 12),
              // Lightbulb
              Icon(Icons.lightbulb, size: 44, color: Colors.cyan.shade400),
            ],
          ),
          const SizedBox(height: 40),
          // Description text
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Binding your app account to your Amazon account allows '
              'you to control Alexa-enabled devices through Amazon '
              'Echo speakers (ex. "Alexa, turn on light.")',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.6,
              ),
            ),
          ),
          const Spacer(),
          // Sign In With Amazon button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLinking ? null : _startLinking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196C8),
                  disabledBackgroundColor: const Color(0xFF2196C8).withAlpha(150),
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
                        'Sign In With Amazon',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // View more ways to link
          TextButton(
            onPressed: () {},
            child: Text(
              'View more ways to link',
              style: TextStyle(
                fontSize: 15,
                color: Colors.cyan.shade600,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildLinkedView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 32),
          // Alexa logo
          Image.asset('assets/icons/alexa_logo.png', width: 80, height: 80),
          const SizedBox(height: 24),
          // Title
          const Text(
            'Already linked with Amazon Alexa',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          // Subtitle
          Text(
            'You can control Alexa-enabled devices with\nAmazon Alexa speakers, such as',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          // Example commands
          Text(
            'Alexa, turn on light',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 12),
          Text(
            'Alexa, set air conditioning to 20°C',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 12),
          Text(
            'Alexa, turn off diffuser',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 12),
          Text(
            'Alexa, increase air conditioner by 3 degrees',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 20),
          // View more ways to link
          TextButton(
            onPressed: () {},
            child: Text(
              'View more ways to link',
              style: TextStyle(
                fontSize: 15,
                color: Colors.cyan.shade600,
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
          // Unlink instructions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Disable Osprey skill on the Amazon Alexa app or tap '
              'Me > the Setting button in the top right corner > '
              'Account and Security to unauthorize it.',
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
