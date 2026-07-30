import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:smart_curtain_app/core/widgets/app_dialog.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../../core/settings/app_settings_store.dart';
import '../../../../core/settings/cache_manager.dart';
import 'about_page.dart';
import 'account_security_page.dart';
import 'network_diagnosis_page.dart';
import 'personal_info_page.dart';
import '../../../ai/presentation/pages/ai_chat_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _settings = GetIt.instance<AppSettingsStore>();
  static const _cache = CacheManager();

  int? _cacheBytes;
  bool _clearing = false;

  @override
  void initState() {
    super.initState();
    _measureCache();
  }

  Future<void> _measureCache() async {
    final bytes = await _cache.sizeInBytes();
    if (mounted) setState(() => _cacheBytes = bytes);
  }

  Future<void> _clearCache() async {
    if (_clearing) return;
    final confirmed = await AppDialog.confirm(
      context,
      title: 'Clear Cache',
      message: 'Cached scenes, home data and images will be re-downloaded on '
          'next use. Your account and devices are not affected.',
      confirmText: 'Clear',
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    setState(() => _clearing = true);
    final freed = await _cache.clear();
    if (!mounted) return;
    setState(() => _clearing = false);
    await _measureCache();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('Freed ${CacheManager.formatBytes(freed)}'),
      ));
  }

  Future<void> _pickTemperatureUnit() async {
    final picked = await showModalBottomSheet<TemperatureUnit>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 10,
          right: 10,
          bottom: 10 + MediaQuery.of(ctx).padding.bottom,
        ),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text('Temperature Unit',
                    style:
                        TextStyle(fontSize: 15, color: Colors.grey.shade500)),
              ),
              for (final unit in TemperatureUnit.values)
                InkWell(
                  onTap: () => Navigator.pop(ctx, unit),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(unit.symbol,
                                style: const TextStyle(fontSize: 16))),
                        if (unit == _settings.temperatureUnit)
                          const Icon(Icons.check,
                              color: Color(0xFF1B4332), size: 22),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
    if (picked != null && mounted) {
      await _settings.setTemperatureUnit(picked);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: ListView(
        children: [
          // Section 1: Account
          _buildSection([
            _buildNavItem('Personal Information', onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PersonalInfoPage()),
              );
            }),
            _buildNavItem('Account and Security', onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AccountSecurityPage()),
              );
            }),
          ]),

          // Section 2: App Settings
          _buildSection([
            _buildSwitchItem(
              'Touch Tone on Panel',
              value: _settings.touchTone,
              onChanged: (v) async {
                await _settings.setTouchTone(v);
                if (mounted) setState(() {});
              },
            ),
            _buildNavItem(
              'AI Assistant',
              trailing: '✨',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AiChatPage()),
                );
              },
            ),
            _buildNavItem(
              'Temperature Unit',
              trailing: _settings.temperatureUnit.symbol,
              onTap: _pickTemperatureUnit,
            ),
          ]),

          // Section 3: chẩn đoán + thông tin app
          _buildSection([
            _buildNavItem('About', onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutPage()),
              );
            }),
            _buildNavItem('Network Diagnosis', onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NetworkDiagnosisPage()),
              );
            }),
            _buildNavItem(
              'Clear Cache',
              trailing: _clearing
                  ? '...'
                  : (_cacheBytes == null
                      ? ''
                      : CacheManager.formatBytes(_cacheBytes!)),
              onTap: _clearCache,
            ),
          ]),

          // Log Out button
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () => _showLogOutDialog(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'Log Out',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSection(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      color: Colors.white,
      child: Column(
        children: List.generate(children.length * 2 - 1, (index) {
          if (index.isOdd) {
            return Divider(
              height: 0.5,
              thickness: 0.5,
              indent: 16,
              color: Colors.grey.shade200,
            );
          }
          return children[index ~/ 2];
        }),
      ),
    );
  }

  Widget _buildNavItem(
    String title, {
    String? trailing,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
            ),
            if (trailing != null)
              Text(
                trailing,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 20, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem(
    String title, {
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: const Color(0xFFB7727D),
          ),
        ],
      ),
    );
  }

  Future<void> _showLogOutDialog() async {
    final ok = await AppDialog.confirm(
      context,
      title: 'Log Out',
      message: 'Are you sure you want to log out?',
      confirmText: 'Log Out',
      cancelText: 'Cancel',
      destructive: true,
    );
    if (!ok || !mounted) return;
    GetIt.instance<AuthBloc>().add(LogoutEvent());
    Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
  }
}
