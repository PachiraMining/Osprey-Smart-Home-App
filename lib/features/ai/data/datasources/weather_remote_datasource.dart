import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/error/exceptions.dart';

/// Open-Meteo free weather API (no key required).
class WeatherRemoteDataSource {
  final http.Client _client;

  WeatherRemoteDataSource(this._client);

  /// Fetches current weather snapshot at the given coordinates.
  Future<WeatherSnapshot> fetchCurrent({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=$latitude'
      '&longitude=$longitude'
      '&current=temperature_2m,cloud_cover,is_day,relative_humidity_2m,'
      'surface_pressure,wind_speed_10m',
    );
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw ServerException(message: 'Weather API ${response.statusCode}');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final current = body['current'] as Map<String, dynamic>?;
    if (current == null) {
      throw ServerException(message: 'Weather API: missing "current" payload');
    }
    return WeatherSnapshot(
      temperatureCelsius: (current['temperature_2m'] as num).toDouble(),
      cloudCoverPercent: (current['cloud_cover'] as num).toInt(),
      isDay: (current['is_day'] as num).toInt() == 1,
      // Extras for the home-screen weather card — parsed defensively so a
      // missing field never sinks the whole snapshot.
      humidityPercent: (current['relative_humidity_2m'] as num?)?.toDouble(),
      pressureHpa: (current['surface_pressure'] as num?)?.toDouble(),
      windSpeedMs: (current['wind_speed_10m'] as num?)?.toDouble(),
    );
  }

  /// Current PM2.5 (µg/m³) from Open-Meteo's air-quality API. Returns null on
  /// any failure — air quality is nice-to-have and must never break weather.
  Future<double?> fetchPm25({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final uri = Uri.parse(
        'https://air-quality-api.open-meteo.com/v1/air-quality'
        '?latitude=$latitude&longitude=$longitude&current=pm2_5',
      );
      final response = await _client.get(uri);
      if (response.statusCode != 200) return null;
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final current = body['current'] as Map<String, dynamic>?;
      return (current?['pm2_5'] as num?)?.toDouble();
    } catch (_) {
      return null;
    }
  }
}

class WeatherSnapshot {
  final double temperatureCelsius;
  final int cloudCoverPercent;
  final bool isDay;
  final double? humidityPercent;
  final double? pressureHpa;
  final double? windSpeedMs;

  const WeatherSnapshot({
    required this.temperatureCelsius,
    required this.cloudCoverPercent,
    required this.isDay,
    this.humidityPercent,
    this.pressureHpa,
    this.windSpeedMs,
  });
}
