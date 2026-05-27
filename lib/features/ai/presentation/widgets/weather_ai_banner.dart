import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/liquid_glass.dart';
import '../bloc/weather_ai_bloc.dart';

class WeatherAiBanner extends StatelessWidget {
  final ValueChanged<int>? onApply;
  const WeatherAiBanner({super.key, this.onApply});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherAiBloc, WeatherAiState>(
      builder: (context, state) {
        if (state is! WeatherLoaded) return const SizedBox.shrink();
        final r = state.recommendation;
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: LiquidGlass(
            radius: 20,
            fillColor: AppColors.glassFillStrong,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Text('🌤️', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${r.reason}  AI suggests ${r.position}%.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () => onApply?.call(r.position),
                    child: const Text('Apply'),
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
