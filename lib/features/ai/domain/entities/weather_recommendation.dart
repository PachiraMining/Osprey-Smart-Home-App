import 'package:equatable/equatable.dart';

/// AI-derived curtain position recommendation driven by current weather.
///
/// Computed locally from open-meteo data (no model inference required —
/// deterministic rule engine in [GetWeatherRecommendation]).
class WeatherRecommendation extends Equatable {
  /// Recommended curtain position percentage 0..100.
  final int position;

  /// Short user-facing reason, e.g. "Sunny 32°C — lower curtains to reduce heat".
  final String reason;

  /// Source weather snapshot used for the recommendation.
  final double temperatureCelsius;
  final int cloudCoverPercent;
  final bool isDay;

  /// Extras for the home-screen weather card (null when unavailable).
  final double? humidityPercent;
  final double? pressureHpa;
  final double? windSpeedMs;
  final double? pm25;

  const WeatherRecommendation({
    required this.position,
    required this.reason,
    required this.temperatureCelsius,
    required this.cloudCoverPercent,
    required this.isDay,
    this.humidityPercent,
    this.pressureHpa,
    this.windSpeedMs,
    this.pm25,
  });

  @override
  List<Object?> get props => [
        position,
        reason,
        temperatureCelsius,
        cloudCoverPercent,
        isDay,
        humidityPercent,
        pressureHpa,
        windSpeedMs,
        pm25,
      ];
}
