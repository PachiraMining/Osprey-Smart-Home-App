import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/app_config.dart';
import '../../../../l10n/gen/app_l10n.dart';
import '../../../../core/theme/app_surfaces.dart';

/// Thông tin phiên bản app + liên kết pháp lý.
class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {

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
            SnackBar(content: Text(AppL10n.of(context).couldNotOpenLink)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final info = _info;
    return Scaffold(
      backgroundColor: context.surfaces.pageBg,
      appBar: AppBar(
        backgroundColor: context.surfaces.pageBg,
        elevation: 0,
        centerTitle: true,
        foregroundColor: context.surfaces.textPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l10n.about,
            style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
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
                        size: 60, color: context.surfaces.textMuted),
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
                      : l10n.aboutVersion(info.version, info.buildNumber),
                  style: TextStyle(fontSize: 15, color: context.surfaces.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Container(
            color: context.surfaces.card,
            child: Column(
              children: [
                _AboutRow(
                  label: l10n.privacyPolicy,
                  onTap: () => _open(AppConfig.privacyPolicyUrl),
                ),
                _AboutRow(
                  label: l10n.termsOfService,
                  onTap: () => _open(AppConfig.userAgreementUrl),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            color: context.surfaces.card,
            child: Column(
              children: [
                _AboutRow(
                    label: l10n.bundleId, value: info?.packageName ?? ''),
                // Hữu ích khi hỗ trợ người dùng: biết app đang nói chuyện với
                // server nào (production hay test).
                _AboutRow(
                  label: l10n.server,
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
                style:  TextStyle(fontSize: 17, color: context.surfaces.textPrimary)),
            const Spacer(),
            if (value != null && value!.isNotEmpty)
              Flexible(
                child: Text(
                  value!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style:
                      TextStyle(fontSize: 16, color: context.surfaces.textSecondary),
                ),
              ),
            if (onTap != null) ...[
              const SizedBox(width: 6),
              Icon(Icons.chevron_right,
                  size: 22, color: context.surfaces.textMuted),
            ],
          ],
        ),
      ),
    );
  }
}
