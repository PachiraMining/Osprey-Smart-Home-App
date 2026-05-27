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
      '&longitude=$longitude&current=temperature_2m,cloud_cover,is_day',
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
    );
  }
}

class WeatherSnapshot {
  final double temperatureCelsius;
  final int cloudCoverPercent;
  final bool isDay;

  const WeatherSnapshot({
    required this.temperatureCelsius,
    required this.cloudCoverPercent,
    required this.isDay,
  });
}
