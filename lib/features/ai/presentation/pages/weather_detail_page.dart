import 'package:flutter/material.dart';
import '../../../../l10n/gen/app_l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/weather_recommendation.dart';
import '../bloc/weather_ai_bloc.dart';
import 'weather_location_picker_page.dart';

/// Full-screen outdoor weather report (Tuya style): big condition icon +
/// label, temperature, then one rounded cell per metric. "Switch location"
/// opens the map picker and refreshes on return.
class WeatherDetailPage extends StatelessWidget {
  const WeatherDetailPage({super.key});

  static (IconData, String) _condition(WeatherRecommendation? w, AppL10n l10n) {
    if (w == null) return (Icons.cloud_outlined, '--');
    if (!w.isDay) return (Icons.nightlight_outlined, l10n.weatherClearNight);
    if (w.cloudCoverPercent < 20) return (Icons.wb_sunny_outlined, l10n.weatherSunny);
    if (w.cloudCoverPercent < 75) {
      return (Icons.cloud_outlined, l10n.weatherPartlyCloudy);
    }
    return (Icons.cloud, l10n.weatherCloudy);
  }

  static String _pm25Label(double? pm25, AppL10n l10n) {
    if (pm25 == null) return '--';
    if (pm25 <= 12) return l10n.qualityExcellent;
    if (pm25 <= 35.4) return l10n.qualityGood;
    if (pm25 <= 55.4) return l10n.qualityModerate;
    if (pm25 <= 150.4) return l10n.qualityPoor;
    return l10n.qualityVeryPoor;
  }

  Future<void> _switchLocation(BuildContext context) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const WeatherLocationPickerPage()),
    );
    if (changed == true && context.mounted) {
      context.read<WeatherAiBloc>().add(const RefreshWeather());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              size: 20, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () => _switchLocation(context),
            child:  Text(
              AppL10n.of(context).switchLocation,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
      body: BlocBuilder<WeatherAiBloc, WeatherAiState>(
        builder: (context, state) {
          final w = state is WeatherLoaded ? state.recommendation : null;
          final (icon, label) = _condition(w, AppL10n.of(context));
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            children: [
              const SizedBox(height: 18),
              Icon(icon, size: 48, color: Colors.black87),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                w != null
                    ? AppL10n.of(context).outdoorTemperatureValue(w.temperatureCelsius.round())
                    : 'Outdoor temperature: --',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              _MetricCell(
                icon: Icons.blur_linear,
                label: AppL10n.of(context).outdoorPm25,
                value: _pm25Label(w?.pm25, AppL10n.of(context)),
              ),
              _MetricCell(
                icon: Icons.water_drop_outlined,
                label: AppL10n.of(context).outdoorHumidity,
                value: w?.humidityPercent != null
                    ? '${w!.humidityPercent!.toStringAsFixed(1)}%'
                    : '--',
              ),
              _MetricCell(
                icon: Icons.compress,
                label: AppL10n.of(context).outdoorAirPressure,
                value: w?.pressureHpa != null
                    ? '${w!.pressureHpa!.round()}hPa'
                    : '--',
              ),
              _MetricCell(
                icon: Icons.flag_outlined,
                label: AppL10n.of(context).outdoorWindSpeed,
                value: w?.windSpeedMs != null
                    ? '${w!.windSpeedMs!.toStringAsFixed(1)}m/s'
                    : '--',
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MetricCell extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetricCell({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black87),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
