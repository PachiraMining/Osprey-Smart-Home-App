import 'package:flutter/material.dart';
import '../../../../l10n/gen/app_l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/aurora_glow.dart';
import '../../domain/entities/chat_message.dart';
import '../bloc/ai_chat_bloc.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    context.read<AiChatBloc>().add(SendMessage(text));
    _input.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Assistant ✨')),
      body: Stack(
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
            child: BlocBuilder<AiChatBloc, AiChatState>(
              builder: (context, state) {
                if (state.messages.isEmpty && !state.isThinking) {
                  return const _EmptyHint();
                }
                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(16),
                  itemCount: state.messages.length + (state.isThinking ? 1 : 0),
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
          _Composer(controller: _input, onSend: _send),
        ],
      ),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();
  @override
  Widget build(BuildContext context) {
    return  Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          AppL10n.of(context).aiChatEmptyState,
          textAlign: TextAlign.center,
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
      alignment: isUser ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
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
      children: [
        SizedBox(
          width: 18, height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        SizedBox(width: 12),
        Text(AppL10n.of(context).thinking),
      ],
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  const _Composer({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: AppL10n.of(context).askAboutYourCurtains,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: onSend,
              icon: const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
