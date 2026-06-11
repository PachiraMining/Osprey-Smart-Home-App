import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/aurora_glow.dart';
import '../../../ai/domain/entities/chat_message.dart';
import '../../../ai/presentation/bloc/ai_chat_bloc.dart';
import '../../../ai/presentation/widgets/voice_command_button.dart';
import '../../../device/domain/entities/device_entity.dart';

/// Tab Chat AI bên trong [HomePage] (thay cho ChatHomePage standalone cũ).
///
/// Không có Scaffold/AppBar riêng — sống trong IndexedStack của HomePage,
/// dưới top bar thương hiệu và trên pill bottom nav (extendBody nên phải tự
/// chừa khoảng trống đáy cho composer).
class ChatTab extends StatefulWidget {
  /// Chuyển sang tab Scenes (HomePage truyền vào) — dùng cho chip "Scenes"
  /// và lệnh /scenes thay vì mở sheet thông tin suông.
  final VoidCallback? onOpenScenes;
  const ChatTab({super.key, this.onOpenScenes});

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send([String? overrideText]) {
    final text = (overrideText ?? _input.text).trim();
    if (text.isEmpty) return;

    if (_maybeHandleSlashCommand(text)) {
      _input.clear();
      return;
    }

    context.read<AiChatBloc>().add(SendMessage(text));
    _input.clear();
    _scrollToBottom();
  }

  /// Returns true if the text was a slash command that has been handled.
  bool _maybeHandleSlashCommand(String text) {
    if (!text.startsWith('/')) return false;
    final command = text.substring(1).trim().toLowerCase();
    switch (command) {
      case 'devices':
      case 'device':
        _showDevicesPicker();
        return true;
      case 'scenes':
      case 'scene':
        _showScenesSheet();
        return true;
      case 'schedule':
      case 'schedules':
        _showScheduleSheet();
        return true;
      case 'help':
      case '?':
        _showHelpSheet();
        return true;
      default:
        return false;
    }
  }

  void _showDevicesPicker() async {
    final bloc = context.read<AiChatBloc>();
    final devices = await bloc.getDeviceList();

    if (!mounted) return;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Devices', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 12),
              if (devices.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('No devices found.'),
                )
              else
                ...devices.map(
                  (d) => _DeviceControlTile(
                    device: d,
                    onCommand: (action) {
                      Navigator.pop(ctx);
                      bloc.add(ControlDevice(
                        deviceId: d.id,
                        deviceName: d.name,
                        action: action,
                      ));
                      _scrollToBottom();
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showScenesSheet() {
    // Có HomePage bọc ngoài → nhảy thẳng sang tab Scenes.
    final openScenes = widget.onOpenScenes;
    if (openScenes != null) {
      openScenes();
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Scenes', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 12),
              const Text(
                'Create and manage Tap-to-Run scenes from the Scenes tab. '
                'Scenes let you chain multiple curtain actions with delays '
                'into a single tap.',
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Got it'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showScheduleSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Schedule', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 12),
              const Text(
                'Set up automated schedules for your curtains. '
                'Open the Scenes tab to create daily, weekly, or one-time '
                'automation schedules.',
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Got it'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHelpSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Slash commands',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
              const SizedBox(height: 12),
              const _HelpRow(
                  cmd: '/devices', desc: 'Browse and control your curtains.'),
              const _HelpRow(cmd: '/scenes', desc: 'Run a tap-to-run scene.'),
              const _HelpRow(
                  cmd: '/schedule', desc: 'Open the automation schedule.'),
              const _HelpRow(cmd: '/help', desc: 'Show this list.'),
              const SizedBox(height: 8),
              const Text(
                'You can also speak — tap the mic button.',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // extendBody của HomePage đã đưa chiều cao pill nav vào
    // MediaQuery.padding.bottom → SafeArea trong _Composer tự né nav,
    // chỉ cần đệm nhỏ. Khi mở bàn phím thì bỏ SafeArea (viewInsets lo).
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Stack(
      children: [
        BlocBuilder<AiChatBloc, AiChatState>(
          buildWhen: (a, b) => a.isThinking != b.isThinking,
          builder: (context, state) => Positioned.fill(
            child: IgnorePointer(
              child: AuroraGlow(
                style: AuroraGlowStyle.subtle,
                active: state.isThinking,
              ),
            ),
          ),
        ),
        Column(
          children: [
            Expanded(
              child: BlocConsumer<AiChatBloc, AiChatState>(
                listenWhen: (a, b) => a.messages.length != b.messages.length,
                listener: (_, __) => _scrollToBottom(),
                builder: (context, state) {
                  if (state.messages.isEmpty && !state.isThinking) {
                    return _EmptyHint(onSuggestionTap: _send);
                  }
                  return ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(16),
                    itemCount:
                        state.messages.length + (state.isThinking ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i == state.messages.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: _ThinkingDot(),
                        );
                      }
                      return _Bubble(message: state.messages[i]);
                    },
                  );
                },
              ),
            ),
            // Mic trong flow layout (hàng riêng) — không bao giờ đè composer.
            Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 6),
              child: Align(
                alignment: Alignment.centerRight,
                child: VoiceCommandButton(
                  onIntentReady: (ready) {
                    // Đưa transcript vào thread chat để user thấy 1 lịch sử
                    // duy nhất.
                    final transcript = ready.intent.transcript;
                    if (transcript.isNotEmpty) {
                      _send(transcript);
                    }
                  },
                ),
              ),
            ),
            _QuickActions(
              onDevices: _showDevicesPicker,
              onScenes: () => _send('/scenes'),
              onHelp: () => _send('/help'),
            ),
            _Composer(
              controller: _input,
              onSend: _send,
              safeBottom: !keyboardOpen,
            ),
          ],
        ),
      ],
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final ValueChanged<String> onSuggestionTap;
  const _EmptyHint({required this.onSuggestionTap});

  @override
  Widget build(BuildContext context) {
    const suggestions = <String>[
      'Open the bedroom curtain',
      'Close all curtains at sunset',
      '/devices',
      '/help',
    ];
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 32),
            const Icon(Icons.auto_awesome, size: 48),
            const SizedBox(height: 12),
            const Text(
              'osprey.life Assistant',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'On-device AI for your motorized curtains.\n'
              'Type, speak, or use slash commands.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in suggestions)
                  ActionChip(
                    label: Text(s),
                    onPressed: () => onSuggestionTap(s),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final ChatMessage message;
  const _Bubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    final theme = Theme.of(context);
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: isUser
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _ThinkingDot extends StatelessWidget {
  const _ThinkingDot();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: const [
        SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        SizedBox(width: 12),
        Text('Thinking…'),
      ],
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final void Function([String?]) onSend;
  final bool safeBottom;
  const _Composer({
    required this.controller,
    required this.onSend,
    required this.safeBottom,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: safeBottom,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: const InputDecoration(
                  hintText: 'Ask about your curtains, or try /help…',
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: () => onSend(),
              icon: const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onDevices;
  final VoidCallback onScenes;
  final VoidCallback onHelp;

  const _QuickActions({
    required this.onDevices,
    required this.onScenes,
    required this.onHelp,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          _QuickChip(
            icon: Icons.curtains,
            label: 'Devices',
            onTap: onDevices,
          ),
          const SizedBox(width: 8),
          _QuickChip(
            icon: Icons.play_circle_outline,
            label: 'Scenes',
            onTap: onScenes,
          ),
          const SizedBox(width: 8),
          _QuickChip(
            icon: Icons.help_outline,
            label: 'Help',
            onTap: onHelp,
          ),
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeviceControlTile extends StatelessWidget {
  final DeviceEntity device;
  final ValueChanged<String> onCommand;

  const _DeviceControlTile({required this.device, required this.onCommand});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.curtains,
            color: device.isOnline ? theme.colorScheme.primary : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  device.isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 12,
                    color: device.isOnline ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          _CommandButton(
            icon: Icons.arrow_back,
            label: 'Open',
            onTap: () => onCommand('OPEN'),
          ),
          const SizedBox(width: 6),
          _CommandButton(
            icon: Icons.pause,
            label: 'Stop',
            onTap: () => onCommand('STOP'),
          ),
          const SizedBox(width: 6),
          _CommandButton(
            icon: Icons.arrow_forward,
            label: 'Close',
            onTap: () => onCommand('CLOSE'),
          ),
        ],
      ),
    );
  }
}

class _CommandButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CommandButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20),
            Text(label, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _HelpRow extends StatelessWidget {
  final String cmd;
  final String desc;
  const _HelpRow({required this.cmd, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              cmd,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(desc)),
        ],
      ),
    );
  }
}
