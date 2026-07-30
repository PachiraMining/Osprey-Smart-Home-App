import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/voice_command_bloc.dart';
import '../../../../l10n/gen/app_l10n.dart';

/// Floating mic button — tap to start, tap to stop / cancel.
/// Shows a pulsing halo while listening.
class VoiceCommandButton extends StatelessWidget {
  final ValueChanged<VoiceCommandReady>? onIntentReady;

  const VoiceCommandButton({super.key, this.onIntentReady});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VoiceCommandBloc, VoiceCommandState>(
      listener: (context, state) {
        if (state is VoiceCommandReady) {
          onIntentReady?.call(state);
        } else if (state is VoiceError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Voice: ${state.message}')),
          );
        }
      },
      builder: (context, state) {
        final listening = state is VoiceListening;
        final parsing = state is VoiceParsing;
        return FloatingActionButton.extended(
          heroTag: 'voice_command_fab',
          onPressed: () {
            final bloc = context.read<VoiceCommandBloc>();
            if (listening) {
              bloc.add(const StopListening());
            } else {
              bloc.add(const StartListening());
            }
          },
          backgroundColor: listening
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.primary,
          icon: Icon(listening ? Icons.stop_rounded : Icons.mic_rounded),
          label: Text(
            listening
                ? (state.partial.isEmpty ? AppL10n.of(context).listening : state.partial)
                : parsing
                    ? AppL10n.of(context).parsing
                    : 'Voice ✨',
          ),
        );
      },
    );
  }
}
