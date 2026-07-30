import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:smart_curtain_app/core/widgets/app_dialog.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../../core/settings/app_settings_store.dart';
import '../../../../core/settings/cache_manager.dart';
import 'about_page.dart';
import '../../../../l10n/gen/app_l10n.dart';
import 'account_security_page.dart';
import 'language_page.dart';
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
    final l10n = AppL10n.of(context);
    final confirmed = await AppDialog.confirm(
      context,
      title: l10n.clearCache,
      message: l10n.clearCacheMessage,
      confirmText: l10n.clear,
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
        content: Text(l10n.freedSpace(CacheManager.formatBytes(freed))),
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
                child: Text(AppL10n.of(ctx).temperatureUnit,
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
    final l10n = AppL10n.of(context);
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
        title: Text(
          l10n.settingsTitle,
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
            _buildNavItem(l10n.personalInformation, onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PersonalInfoPage()),
              );
            }),
            _buildNavItem(l10n.accountAndSecurity, onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AccountSecurityPage()),
              );
            }),
          ]),

          // Section 2: App Settings
          _buildSection([
            _buildSwitchItem(
              l10n.touchToneOnPanel,
              value: _settings.touchTone,
              onChanged: (v) async {
                await _settings.setTouchTone(v);
                if (mounted) setState(() {});
              },
            ),
            _buildNavItem(
              l10n.aiAssistant,
              trailing: '✨',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AiChatPage()),
                );
              },
            ),
            _buildNavItem(
              l10n.language,
              trailing: _languageLabel(l10n),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LanguagePage()),
                );
                if (mounted) setState(() {});
              },
            ),
            _buildNavItem(
              l10n.temperatureUnit,
              trailing: _settings.temperatureUnit.symbol,
              onTap: _pickTemperatureUnit,
            ),
          ]),

          // Section 3: chẩn đoán + thông tin app
          _buildSection([
            _buildNavItem(l10n.about, onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutPage()),
              );
            }),
            _buildNavItem(l10n.networkDiagnosis, onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NetworkDiagnosisPage()),
              );
            }),
            _buildNavItem(
              l10n.clearCache,
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
                child: Center(
                  child: Text(
                    AppL10n.of(context).logOut,
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

  /// Nhãn bên phải hàng Language: tên ngôn ngữ đang chọn (viết bằng chính ngôn
  /// ngữ đó), hoặc "theo hệ thống".
  String _languageLabel(AppL10n l10n) =>
      _settings.localeLabel ?? l10n.languageSystemDefault;

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
      title: AppL10n.of(context).logOut,
      message: AppL10n.of(context).areYouSureYouWantToLogOut,
      confirmText: AppL10n.of(context).logOut,
      cancelText: AppL10n.of(context).cancel,
      destructive: true,
    );
    if (!ok || !mounted) return;
    GetIt.instance<AuthBloc>().add(LogoutEvent());
    Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
  }
}
