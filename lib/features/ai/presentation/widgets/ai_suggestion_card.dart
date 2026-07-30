import 'package:flutter/material.dart';
import '../../../../l10n/gen/app_l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/liquid_glass.dart';
import '../../domain/entities/automation_suggestion.dart';
import '../bloc/ai_suggestion_bloc.dart';

/// Tên thứ viết tắt theo locale đang dùng. `weekday` là 1=Mon..7=Sun như
/// `DateTime.weekday`.
String _weekdayShort(BuildContext context, int weekday) {
  // 2024-01-01 là thứ Hai, nên cộng offset ra đúng thứ cần hiển thị.
  final day = DateTime(2024, 1, weekday);
  return DateFormat.E(Localizations.localeOf(context).toLanguageTag())
      .format(day);
}

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
        final weekday =
            _weekdayShort(context, top.weekdays.first.clamp(1, 7));
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
                        AppL10n.of(context).aiSuggestion,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppL10n.of(context).aiSuggestionBody(top.action, weekday,
                        top.hour.toString().padLeft(2, '0')),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppL10n.of(context).occurrencesIn30Days(top.occurrences),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: FilledButton.tonalIcon(
                      onPressed: () => onAccept?.call(top),
                      icon: const Icon(Icons.auto_awesome),
                      label: Text(AppL10n.of(context).createScene2),
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
