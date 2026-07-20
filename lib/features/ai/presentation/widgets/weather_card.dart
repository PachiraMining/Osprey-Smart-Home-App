import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/weather_recommendation.dart';
import '../bloc/weather_ai_bloc.dart';
import '../pages/weather_detail_page.dart';

/// Tuya-style weather cell for the Home tab: big outdoor temperature with a
/// condition icon, and a row of outdoor metrics (PM2.5 quality / humidity /
/// air pressure).
///
/// The card frame is ALWAYS present — before the first load (and if weather is
/// unavailable) it shows `--` placeholders, so the first cell never pops in or
/// out and the layout never jumps. Tapping retries when unavailable.
class WeatherCard extends StatelessWidget {
  const WeatherCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherAiBloc, WeatherAiState>(
      builder: (context, state) {
        final w = state is WeatherLoaded ? state.recommendation : null;
        return GestureDetector(
          onTap: () {
            // Unavailable → retry silently on the way in; the detail page
            // shows placeholders until data lands.
            if (state is WeatherUnavailable) {
              context.read<WeatherAiBloc>().add(const RefreshWeather());
            }
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WeatherDetailPage()),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(180),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _ConditionIcon(w: w),
                    const SizedBox(width: 8),
                    Text(
                      w != null
                          ? '${w.temperatureCelsius.round()}°C'
                          : '--°C',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _Metric(
                      value: _pm25Label(w?.pm25),
                      caption: 'Outdoor PM2.5',
                    ),
                    _Metric(
                      value: w?.humidityPercent != null
                          ? '${w!.humidityPercent!.toStringAsFixed(1)}%'
                          : '--',
                      caption: 'Outdoor humidity',
                    ),
                    _Metric(
                      value: w?.pressureHpa != null
                          ? '${w!.pressureHpa!.round()}hPa'
                          : '--',
                      caption: 'Outdoor air pressure',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// US-EPA-style PM2.5 (µg/m³) quality bucket, like Tuya's wording.
  static String _pm25Label(double? pm25) {
    if (pm25 == null) return '--';
    if (pm25 <= 12) return 'Excellent';
    if (pm25 <= 35.4) return 'Good';
    if (pm25 <= 55.4) return 'Moderate';
    if (pm25 <= 150.4) return 'Poor';
    return 'Very Poor';
  }
}

class _ConditionIcon extends StatelessWidget {
  final WeatherRecommendation? w;
  const _ConditionIcon({required this.w});

  @override
  Widget build(BuildContext context) {
    final w = this.w;
    final IconData icon;
    final Color color;
    if (w == null) {
      icon = Icons.cloud_outlined;
      color = const Color(0xFFB0BEC5);
    } else if (!w.isDay) {
      icon = Icons.nightlight_round;
      color = const Color(0xFF5C6BC0);
    } else if (w.cloudCoverPercent < 30) {
      icon = Icons.wb_sunny_rounded;
      color = const Color(0xFFFFB300);
    } else if (w.cloudCoverPercent < 75) {
      icon = Icons.cloud_outlined;
      color = const Color(0xFF90A4AE);
    } else {
      icon = Icons.cloud;
      color = const Color(0xFF90A4AE);
    }
    return Icon(icon, size: 24, color: color);
  }
}

class _Metric extends StatelessWidget {
  final String value;
  final String caption;

  const _Metric({required this.value, required this.caption});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
