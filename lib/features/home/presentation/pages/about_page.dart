import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/app_config.dart';

/// Thông tin phiên bản app + liên kết pháp lý.
class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  static const _pageBg = Color(0xFFF2F4F7);

  PackageInfo? _info;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _info = info);
  }

  Future<void> _open(String url) async {
    final ok = await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
            const SnackBar(content: Text('Could not open the link.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = _info;
    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(
        backgroundColor: _pageBg,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('About',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 28),
          Center(
            child: Column(
              children: [
                SizedBox(
                  width: 84,
                  height: 84,
                  child: Image.asset(
                    'assets/osprey_life_logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(Icons.apps_rounded,
                        size: 60, color: Colors.grey.shade400),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  info?.appName ?? 'Osprey Life',
                  style: const TextStyle(
                      fontSize: 19, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  info == null
                      ? ''
                      : 'Version ${info.version} (${info.buildNumber})',
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                _AboutRow(
                  label: 'Privacy Policy',
                  onTap: () => _open(AppConfig.privacyPolicyUrl),
                ),
                _AboutRow(
                  label: 'Terms of Service',
                  onTap: () => _open(AppConfig.userAgreementUrl),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                _AboutRow(label: 'Bundle ID', value: info?.packageName ?? ''),
                // Hữu ích khi hỗ trợ người dùng: biết app đang nói chuyện với
                // server nào (production hay test).
                _AboutRow(
                  label: 'Server',
                  value: Uri.parse(AppConfig.thingsboardBaseUrl).host,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback? onTap;

  const _AboutRow({required this.label, this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Text(label,
                style: const TextStyle(fontSize: 17, color: Colors.black87)),
            const Spacer(),
            if (value != null && value!.isNotEmpty)
              Flexible(
                child: Text(
                  value!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style:
                      TextStyle(fontSize: 16, color: Colors.grey.shade500),
                ),
              ),
            if (onTap != null) ...[
              const SizedBox(width: 6),
              Icon(Icons.chevron_right,
                  size: 22, color: Colors.grey.shade400),
            ],
          ],
        ),
      ),
    );
  }
}
