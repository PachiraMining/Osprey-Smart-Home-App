import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../../core/theme/scene_style.dart';
import '../../../data/siri_shortcuts_service.dart';
import '../../../domain/entities/tap_to_run_scene_entity.dart';

/// Trang "Siri Shortcut": mỗi scene một thẻ màu — dấu `+` khi chưa gán câu
/// lệnh, mũi tên `›` kèm câu lệnh khi đã gán. Chạm để mở sheet hệ thống.
class SiriShortcutsPage extends StatefulWidget {
  final List<TapToRunSceneEntity> scenes;

  const SiriShortcutsPage({super.key, required this.scenes});

  @override
  State<SiriShortcutsPage> createState() => _SiriShortcutsPageState();
}

class _SiriShortcutsPageState extends State<SiriShortcutsPage> {
  final _service = GetIt.instance<SiriShortcutsService>();

  /// `{sceneId: câu lệnh}` — scene vắng mặt nghĩa là chưa thêm vào Siri.
  Map<String, String> _phrases = const {};
  bool _loading = true;
  String? _diagnostic;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final phrases = await _service.listShortcuts();
    final diag = await _service.diagnostics();
    if (!mounted) return;
    setState(() {
      _phrases = phrases;
      _diagnostic = diag.summary;
      _loading = false;
    });
  }

  Future<void> _onSceneTap(TapToRunSceneEntity scene) async {
    try {
      await _service.presentAddToSiri(
        sceneId: scene.id,
        sceneName: scene.name,
      );
    } on SiriUnavailableException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
      return;
    }
    // Đọc lại từ hệ thống thay vì tin giá trị trả về: user có thể đã xoá
    // shortcut, hoặc sửa câu lệnh trong app Shortcuts.
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F4F7),
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black87,
        title: const Text(
          'Siri Shortcut',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: _showHelp,
            child: const Text(
              'Help',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : widget.scenes.isEmpty
              ? const Center(
                  child: Text(
                    'Create a Tap-to-Run scene first.',
                    style: TextStyle(color: Colors.black54),
                  ),
                )
              : Column(
                  children: [
                    if (_diagnostic != null)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF4E5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _diagnostic!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF8A5A00),
                          ),
                        ),
                      ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: widget.scenes.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final scene = widget.scenes[index];
                          return _SiriSceneCard(
                            scene: scene,
                            phrase: _phrases[scene.id],
                            onTap: () => _onSceneTap(scene),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  void _showHelp() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Using Siri'),
        content: const Text(
          'Tap a scene to record a voice phrase, then say '
          '"Hey Siri" followed by that phrase to run the scene — '
          'even when the app is closed.\n\n'
          'Tap a scene you already added to change its phrase or remove it.',
          style: TextStyle(fontSize: 14, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _SiriSceneCard extends StatelessWidget {
  final TapToRunSceneEntity scene;
  final String? phrase;
  final VoidCallback onTap;

  const _SiriSceneCard({
    required this.scene,
    required this.phrase,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final (color, _) = SceneStyle.decode(scene.icon, scene.id);
    final added = phrase != null && phrase!.isNotEmpty;

    return Material(
      color: color,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      scene.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (added) ...[
                      const SizedBox(height: 4),
                      Text(
                        '"${phrase!}"',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                added ? Icons.chevron_right : Icons.add,
                color: Colors.white,
                size: added ? 28 : 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
