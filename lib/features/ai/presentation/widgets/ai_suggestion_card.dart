import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/liquid_glass.dart';
import '../../domain/entities/automation_suggestion.dart';
import '../bloc/ai_suggestion_bloc.dart';

const _weekdayShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

class AiSuggestionCard extends StatelessWidget {
  final ValueChanged<AutomationSuggestion>? onAccept;

  const AiSuggestionCard({super.key, this.onAccept});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AiSuggestionBloc, AiSuggestionState>(
      builder: (context, state) {
        if (state is! AiSuggestionsLoaded) return const SizedBox.shrink();
        final top = state.suggestions.first;
        final theme = Theme.of(context);
        final weekday = _weekdayShort[(top.weekdays.first - 1).clamp(0, 6)];
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: LiquidGlass(
            radius: 20,
            fillColor: AppColors.glassFill,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('✨ ', style: TextStyle(fontSize: 18)),
                      Text(
                        'AI Suggestion',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You usually run "${top.action}" at $weekday ${top.hour.toString().padLeft(2, '0')}:00 — '
                    'automate it?',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${top.occurrences} times in 30 days',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.tonalIcon(
                      onPressed: () => onAccept?.call(top),
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Create scene'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
