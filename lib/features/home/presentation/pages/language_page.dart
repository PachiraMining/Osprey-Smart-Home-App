import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/settings/app_settings_store.dart';
import '../../../../l10n/gen/app_l10n.dart';
import '../../../../core/theme/app_surfaces.dart';

/// Chọn ngôn ngữ app. `null` = theo ngôn ngữ hệ thống.
class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {

  final _settings = GetIt.instance<AppSettingsStore>();

  Future<void> _select(Locale? locale) async {
    await _settings.setLocale(locale);
    if (mounted) setState(() {});
  }

  /// So sánh theo thẻ đầy đủ để `zh` không khớp nhầm `zh_Hant`.
  bool _isSelected(Locale? option, Locale? current) {
    if (option == null || current == null) return option == current;
    return option.languageCode == current.languageCode &&
        option.scriptCode == current.scriptCode &&
        option.countryCode == current.countryCode;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final current = _settings.locale;

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
        title: Text(l10n.language,
            style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 12, bottom: 24),
        children: [
          Container(
            color: context.surfaces.card,
            child: Column(
              children: [
                _LanguageRow(
                  label: l10n.languageSystemDefault,
                  selected: current == null,
                  onTap: () => _select(null),
                ),
                for (final (locale, label)
                    in AppSettingsStore.supportedLanguages)
                  _LanguageRow(
                    label: label,
                    selected: _isSelected(locale, current),
                    onTap: () => _select(locale),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style:
                       TextStyle(fontSize: 17, color: context.surfaces.textPrimary)),
            ),
            if (selected)
              const Icon(Icons.check, size: 22, color: Color(0xFF1B4332)),
          ],
        ),
      ),
    );
  }
}
