import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/settings/app_settings_store.dart';
import '../../../../core/theme/app_surfaces.dart';
import '../../../../l10n/gen/app_l10n.dart';

/// Chọn chế độ sáng/tối.
///
/// Bố cục theo app tham chiếu: một công tắc "System" ở trên, và CHỈ khi tắt nó
/// mới hiện hai lựa chọn Normal / Dark. Không dùng danh sách 3 mục ngang hàng —
/// "theo hệ thống" là một trạng thái khác loại, không phải lựa chọn thứ ba.
class DarkModePage extends StatefulWidget {
  const DarkModePage({super.key});

  @override
  State<DarkModePage> createState() => _DarkModePageState();
}

/// Xanh của dấu check, đo từ ảnh app tham chiếu.
const _checkBlue = Color(0xFF4A90E2);

class _DarkModePageState extends State<DarkModePage> {
  final _settings = GetIt.instance<AppSettingsStore>();

  ThemeMode get _mode => _settings.themeMode;
  bool get _followSystem => _mode == ThemeMode.system;

  Future<void> _set(ThemeMode mode) async {
    await _settings.setThemeMode(mode);
    if (mounted) setState(() {});
  }

  /// Tắt "System" thì phải chốt về một chế độ cụ thể — lấy đúng chế độ đang
  /// hiển thị lúc đó để giao diện không nhảy màu.
  Future<void> _toggleSystem(bool follow) {
    if (follow) return _set(ThemeMode.system);
    final isDarkNow = Theme.of(context).brightness == Brightness.dark;
    return _set(isDarkNow ? ThemeMode.dark : ThemeMode.light);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final s = context.surfaces;

    return Scaffold(
      backgroundColor: s.pageBg,
      appBar: AppBar(
        backgroundColor: s.sheet,
        elevation: 0,
        centerTitle: true,
        foregroundColor: s.textPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l10n.darkMode,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: s.textPrimary)),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 12, bottom: 24),
        children: [
          // ─── Công tắc theo hệ thống ───
          Container(
            color: s.card,
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.system,
                          style: TextStyle(
                              fontSize: 17, color: s.textPrimary)),
                      const SizedBox(height: 4),
                      Text(l10n.systemDarkModeHint,
                          style: TextStyle(
                              fontSize: 14,
                              height: 1.35,
                              color: s.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Switch.adaptive(
                  value: _followSystem,
                  onChanged: _toggleSystem,
                ),
              ],
            ),
          ),

          // ─── Chọn tay, chỉ hiện khi KHÔNG theo hệ thống ───
          if (!_followSystem) ...[
            const SizedBox(height: 12),
            Container(
              color: s.card,
              child: Column(
                children: [
                  _ModeRow(
                    label: l10n.normalMode,
                    selected: _mode == ThemeMode.light,
                    onTap: () => _set(ThemeMode.light),
                  ),
                  _ModeRow(
                    label: l10n.darkMode,
                    selected: _mode == ThemeMode.dark,
                    onTap: () => _set(ThemeMode.dark),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ModeRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.surfaces;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: TextStyle(fontSize: 17, color: s.textPrimary)),
            ),
            if (selected)
              const Icon(Icons.check_circle,
                  size: 26, color: _checkBlue)
            else
              Icon(Icons.circle_outlined, size: 26, color: s.divider),
          ],
        ),
      ),
    );
  }
}
