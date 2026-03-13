import 'dart:convert';
import 'dart:developer';

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
  static const _tag = 'AlexaLinking';
  static const _baseUrl = 'https://performentmarketing.ddnsgeek.com';
  static const _callbackScheme = 'osprey';

  final _tokenManager = GetIt.instance<TokenManager>();
  final _client = GetIt.instance<http.Client>();

  bool _isLoading = true;
  bool _isLinked = false;
  bool _isLinking = false;
  bool _isUnlinking = false;
  String? _error;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'accept': 'application/json',
        'X-Authorization': 'Bearer ${_tokenManager.getTokenSync() ?? ''}',
      };

  @override
  void initState() {
    super.initState();
    log('initState — checking linking status', name: _tag);
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
    log('API 0: GET $url', name: _tag);

    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: _headers,
      );

      log('API 0 response: ${response.statusCode} — ${response.body}',
          name: _tag);

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
      log('API 0 error: $e', name: _tag, error: e, stackTrace: stack);
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
      log('Step 1: Starting linking...', name: _tag);
      final startUrl = '$_baseUrl/api/alexa/app-linking/start';
      final startRes = await _client.post(
        Uri.parse(startUrl),
        headers: _headers,
      );

      log('API 1 response: ${startRes.statusCode} — ${startRes.body}',
          name: _tag);

      if (startRes.statusCode != 200 && startRes.statusCode != 201) {
        _setError('Failed to start linking: ${startRes.statusCode}');
        return;
      }

      final startData = jsonDecode(startRes.body);
      final lwaUrl = startData['lwaFallbackUrl'] as String;
      final state = startData['state'] as String;
      log('Got LWA URL and state from backend', name: _tag);

      // Step 2: Open browser → user login Amazon → receive callback
      log('Step 2: Opening Amazon login...', name: _tag);
      final resultUrl = await FlutterWebAuth2.authenticate(
        url: lwaUrl,
        callbackUrlScheme: _callbackScheme,
      );

      log('Callback URL: $resultUrl', name: _tag);

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
      log('Step 3: Completing linking...', name: _tag);
      final completeUrl = '$_baseUrl/api/alexa/app-linking/complete';
      final completeRes = await _client.post(
        Uri.parse(completeUrl),
        headers: _headers,
        body: jsonEncode({
          'amazonAuthCode': code,
          'state': state,
        }),
      );

      log('API 3 response: ${completeRes.statusCode} — ${completeRes.body}',
          name: _tag);

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
      log('Linking error: $e', name: _tag, error: e, stackTrace: stack);
      if (e.toString().contains('CANCELED') ||
          e.toString().contains('cancelled')) {
        if (mounted) setState(() => _isLinking = false);
        return;
      }
      _setError('An error occurred. Please try again.');
    }
  }

  // ─── Unlink ───
  Future<void> _unlinkAccount() async {
    setState(() {
      _isUnlinking = true;
      _error = null;
    });

    try {
      final url = '$_baseUrl/api/alexa/app-linking/unlink';
      log('Unlink: POST $url', name: _tag);

      final response = await _client.post(
        Uri.parse(url),
        headers: _headers,
      );

      log('Unlink response: ${response.statusCode} — ${response.body}',
          name: _tag);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _isLinked = false;
            _isUnlinking = false;
          });
          _showSnackBar('Account unlinked.', Colors.orange);
          return;
        }
      }

      // Fallback: even if API fails, re-check status
      setState(() => _isUnlinking = false);
      await _checkStatus();
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
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black87),
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
              onPressed: _checkStatus,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
